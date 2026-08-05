import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

type AgentRequest = {
  message?: string;
  screen?: string;
  history?: Array<{ role?: string; content?: string }>;
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (request.method !== "POST") {
    return json({ message: "Method not allowed", suggestions: [] }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const geminiKey = Deno.env.get("GEMINI_API_KEY");
  const huggingFaceKey = Deno.env.get("HUGGINGFACE_API_KEY") ??
    Deno.env.get("HF_TOKEN");
  if (!supabaseUrl || !supabaseAnonKey) {
    return json(
      {
        message:
          "Atlas Agent is missing Supabase environment variables on the server.",
        suggestions: [],
      },
      500,
    );
  }

  const authorization = request.headers.get("Authorization") ?? "";
  const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false },
  });
  const { data: authData, error: authError } = await supabase.auth.getUser();
  if (authError || !authData.user) {
    return json(
      {
        message: "Sign in again so Atlas Agent can read your training data.",
        suggestions: [],
      },
      401,
    );
  }

  const body = (await request.json().catch(() => ({}))) as AgentRequest;
  const message = (body.message ?? "").trim();
  if (!message) {
    return json({
      message: "Ask me about your training, recovery, goals, or progress.",
      suggestions: defaultSuggestions(body.screen),
    });
  }

  const context = await buildAtlasContext(supabase, message, body.screen);
  if (geminiKey) {
    const geminiReply = await callGemini({
      apiKey: geminiKey,
      message,
      screen: body.screen,
      history: body.history,
      context,
    });
    if (geminiReply) return json(geminiReply);
  }

  if (huggingFaceKey) {
    const huggingFaceReply = await callHuggingFace({
      apiKey: huggingFaceKey,
      message,
      screen: body.screen,
      history: body.history,
      context,
    });
    if (huggingFaceReply) return json(huggingFaceReply);
  }

  return json(localCoachReply(message, context));
});

async function callGemini({
  apiKey,
  message,
  screen,
  history,
  context,
}: {
  apiKey: string;
  message: string;
  screen?: string;
  history?: AgentRequest["history"];
  context: Awaited<ReturnType<typeof buildAtlasContext>>;
}) {
  const model = Deno.env.get("GEMINI_MODEL") ?? "gemini-2.0-flash";
  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        systemInstruction: {
          parts: [{ text: agentInstructions }],
        },
        contents: [
          {
            role: "user",
            parts: [
              {
                text: JSON.stringify({
                  userQuestion: message,
                  currentScreen: screen ?? "Atlas",
                  recentConversation: sanitizeHistory(history),
                  atlasContext: context,
                }),
              },
            ],
          },
        ],
        generationConfig: {
          temperature: 0.35,
          responseMimeType: "application/json",
        },
      }),
    },
  );

  if (!response.ok) {
    console.error("Gemini response failed", response.status, await response.text());
    return null;
  }
  const payload = await response.json();
  const text =
    payload?.candidates?.[0]?.content?.parts
      ?.map((part: Record<string, unknown>) => part.text)
      ?.filter((part: unknown) => typeof part === "string")
      ?.join("\n") ?? "";
  return parseAgentText(text, context, screen);
}

async function callHuggingFace({
  apiKey,
  message,
  screen,
  history,
  context,
}: {
  apiKey: string;
  message: string;
  screen?: string;
  history?: AgentRequest["history"];
  context: Awaited<ReturnType<typeof buildAtlasContext>>;
}) {
  const model = Deno.env.get("HUGGINGFACE_MODEL") ??
    "openai/gpt-oss-120b:fastest";
  const response = await fetch(
    "https://router.huggingface.co/v1/chat/completions",
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model,
        messages: [
          { role: "system", content: agentInstructions },
          {
            role: "user",
            content: JSON.stringify({
              userQuestion: message,
              currentScreen: screen ?? "Atlas",
              recentConversation: sanitizeHistory(history),
              atlasContext: context,
            }),
          },
        ],
        temperature: 0.35,
        max_tokens: 900,
        response_format: { type: "json_object" },
      }),
    },
  );

  if (!response.ok) {
    console.error(
      "Hugging Face response failed",
      response.status,
      await response.text(),
    );
    return null;
  }
  const payload = await response.json();
  const text = payload?.choices?.[0]?.message?.content ?? "";
  return parseAgentText(text, context, screen);
}

async function buildAtlasContext(supabase: ReturnType<typeof createClient>, message: string, screen?: string) {
  const today = new Date().toISOString().slice(0, 10);
  const requestedDate = requestedDateFromMessage(message, today);
  const search = searchTerms(message);

  const [
    profile,
    todayWorkout,
    sessions,
    goals,
    weights,
    hydration,
    exercises,
    requestedDateSummary,
  ] = await Promise.all([
    supabase
      .from("profiles")
      .select("display_name, email, weekly_workout_target, cycle_anchor_date")
      .limit(1)
      .maybeSingle(),
    supabase.rpc("get_today_workout", {}),
    supabase
      .from("workout_sessions")
      .select(
        "id, session_date, started_at, completed_at, status, title, workout_session_exercises(display_order, name_snapshot, workout_sets(set_number, reps, weight, weight_unit))",
      )
      .eq("status", "completed")
      .order("session_date", { ascending: false })
      .limit(14),
    supabase
      .from("v_active_goals")
      .select("title, goal_type, target_value, target_unit, current_value, progress_percent")
      .order("created_at", { ascending: false })
      .limit(8),
    supabase
      .from("body_weight_logs")
      .select("measured_on, weight, unit")
      .order("measured_on", { ascending: false })
      .limit(10),
    supabase
      .from("hydration_events")
      .select("id", { count: "exact", head: true })
      .gte("occurred_at", `${today}T00:00:00.000Z`),
    loadRelevantExercises(supabase, search),
    requestedDate ? loadDaySummary(supabase, requestedDate) : Promise.resolve(null),
  ]);

  const workoutRows = Array.isArray(todayWorkout.data) ? todayWorkout.data : [];
  const recentSessions = Array.isArray(sessions.data) ? sessions.data : [];
  const workoutDates = new Set(
    recentSessions
      .map((session: Record<string, unknown>) => session.session_date)
      .filter(Boolean),
  );

  return {
    today,
    currentScreen: screen ?? "Atlas",
    profile: profile.data ?? null,
    todayWorkout: workoutRows[0] ?? null,
    recentWorkoutCount: recentSessions.length,
    recentWorkoutDates: [...workoutDates],
    currentStreak: calculateStreak([...workoutDates].map(String)),
    recentSessions: recentSessions.map(compactSession),
    goals: goals.data ?? [],
    weightLogs: weights.data ?? [],
    hydrationToday: hydration.count ?? 0,
    requestedDate,
    requestedDateSummary,
    relevantExercises: exercises,
    contextUsed: [
      "today workout",
      "recent workout logs",
      "exercise sets/reps/weight",
      ...(requestedDateSummary ? ["requested date report"] : []),
      "goals",
      "weight logs",
      "hydration",
      "exercise library",
    ],
  };
}

async function loadDaySummary(supabase: ReturnType<typeof createClient>, date: string) {
  const next = nextDateKey(date);
  const [
    workouts,
    cardio,
    sports,
    hydration,
    weight,
  ] = await Promise.all([
    supabase
      .from("workout_sessions")
      .select(
        "id, session_date, started_at, completed_at, status, title, workout_session_exercises(display_order, name_snapshot, workout_sets(set_number, reps, weight, weight_unit))",
      )
      .eq("status", "completed")
      .eq("session_date", date)
      .order("completed_at", { ascending: false })
      .limit(1),
    supabase
      .from("cardio_sessions")
      .select("activity_type, duration_minutes, distance, distance_unit, notes")
      .eq("session_date", date)
      .order("created_at", { ascending: true }),
    supabase
      .from("sports_sessions")
      .select("sport_name, duration_minutes, notes")
      .eq("session_date", date)
      .order("created_at", { ascending: true }),
    supabase
      .from("hydration_events")
      .select("id", { count: "exact", head: true })
      .gte("occurred_at", `${date}T00:00:00.000Z`)
      .lt("occurred_at", `${next}T00:00:00.000Z`),
    supabase
      .from("body_weight_logs")
      .select("measured_on, weight, unit")
      .eq("measured_on", date)
      .order("created_at", { ascending: false })
      .limit(1),
  ]);
  const workoutRows = Array.isArray(workouts.data) ? workouts.data : [];
  const cardioRows = Array.isArray(cardio.data) ? cardio.data : [];
  const sportRows = Array.isArray(sports.data) ? sports.data : [];
  const weightRows = Array.isArray(weight.data) ? weight.data : [];
  return {
    date,
    workout: workoutRows[0] ? compactSession(workoutRows[0]) : null,
    cardio: cardioRows,
    sports: sportRows,
    hydrationSips: hydration.count ?? 0,
    weight: weightRows[0] ?? null,
    hasAnyLog:
      workoutRows.length > 0 ||
      cardioRows.length > 0 ||
      sportRows.length > 0 ||
      (hydration.count ?? 0) > 0 ||
      weightRows.length > 0,
  };
}

async function loadRelevantExercises(supabase: ReturnType<typeof createClient>, terms: string[]) {
  const columns =
    "name, target_muscle, equipment, difficulty, movement_pattern, image_url, gif_url";
  const safeTerms = terms.slice(0, 4).map((term) => term.replace(/[%(),]/g, ""));
  if (safeTerms.length === 0) {
    const { data } = await supabase
      .from("exercises")
      .select(columns)
      .eq("is_active", true)
      .order("name")
      .limit(40);
    return data ?? [];
  }

  const filters = safeTerms.flatMap((term) => [
    `name.ilike.%${term}%`,
    `target_muscle.ilike.%${term}%`,
    `equipment.ilike.%${term}%`,
    `movement_pattern.ilike.%${term}%`,
  ]);
  const { data } = await supabase
    .from("exercises")
    .select(columns)
    .eq("is_active", true)
    .or(filters.join(","))
    .order("name")
    .limit(80);
  return data ?? [];
}

function compactSession(session: Record<string, unknown>) {
  const exercises = Array.isArray(session.workout_session_exercises)
    ? session.workout_session_exercises
    : [];
  return {
    date: session.session_date,
    title: session.title,
    completedAt: session.completed_at,
    exercises: exercises.map((exercise: Record<string, unknown>) => {
      const sets = Array.isArray(exercise.workout_sets)
        ? exercise.workout_sets
        : [];
      return {
        name: exercise.name_snapshot,
        sets: sets.map((set: Record<string, unknown>) => ({
          set: set.set_number,
          reps: set.reps,
          weight: set.weight,
          unit: set.weight_unit,
        })),
      };
    }),
  };
}

function searchTerms(message: string) {
  const stop = new Set([
    "what",
    "should",
    "today",
    "with",
    "from",
    "show",
    "give",
    "make",
    "workout",
    "exercise",
    "exercises",
  ]);
  return [...new Set(
    message
      .toLowerCase()
      .replace(/[^a-z0-9 ]/g, " ")
      .split(/\s+/)
      .filter((term) => term.length > 2 && !stop.has(term)),
  )];
}

function requestedDateFromMessage(message: string, todayKey: string) {
  const lower = message.toLowerCase();
  if (/\btoday\b/.test(lower)) return todayKey;
  const today = parseDateKey(todayKey);
  if (/\byesterday\b/.test(lower)) {
    today.setDate(today.getDate() - 1);
    return dateKey(today);
  }
  if (/day before yesterday/.test(lower)) {
    today.setDate(today.getDate() - 2);
    return dateKey(today);
  }

  const iso = lower.match(/\b(20\d{2})[-/](\d{1,2})[-/](\d{1,2})\b/);
  if (iso) {
    return dateKey(new Date(Number(iso[1]), Number(iso[2]) - 1, Number(iso[3])));
  }

  const numeric = lower.match(/\b(\d{1,2})[-/](\d{1,2})(?:[-/](20\d{2}))?\b/);
  if (numeric) {
    return dateKey(
      new Date(
        numeric[3] ? Number(numeric[3]) : today.getFullYear(),
        Number(numeric[2]) - 1,
        Number(numeric[1]),
      ),
    );
  }

  const monthNames = new Map([
    ["jan", 0],
    ["january", 0],
    ["feb", 1],
    ["february", 1],
    ["mar", 2],
    ["march", 2],
    ["apr", 3],
    ["april", 3],
    ["may", 4],
    ["jun", 5],
    ["june", 5],
    ["jul", 6],
    ["july", 6],
    ["aug", 7],
    ["august", 7],
    ["sep", 8],
    ["sept", 8],
    ["september", 8],
    ["oct", 9],
    ["october", 9],
    ["nov", 10],
    ["november", 10],
    ["dec", 11],
    ["december", 11],
  ]);
  const monthText = lower.match(/\b(\d{1,2})\s+([a-z]+)(?:\s+(20\d{2}))?\b/);
  if (monthText && monthNames.has(monthText[2])) {
    return dateKey(
      new Date(
        monthText[3] ? Number(monthText[3]) : today.getFullYear(),
        monthNames.get(monthText[2])!,
        Number(monthText[1]),
      ),
    );
  }
  return null;
}

function parseDateKey(key: string) {
  const [year, month, day] = key.split("-").map(Number);
  return new Date(year, month - 1, day);
}

function dateKey(date: Date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

function nextDateKey(key: string) {
  const date = parseDateKey(key);
  date.setDate(date.getDate() + 1);
  return dateKey(date);
}

function calculateStreak(dates: string[]) {
  const set = new Set(dates);
  const now = new Date();
  let cursor = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const key = (date: Date) => date.toISOString().slice(0, 10);
  if (!set.has(key(cursor))) {
    cursor.setDate(cursor.getDate() - 1);
  }
  let streak = 0;
  while (set.has(key(cursor))) {
    streak += 1;
    cursor.setDate(cursor.getDate() - 1);
  }
  return streak;
}

function sanitizeHistory(history?: AgentRequest["history"]) {
  if (!Array.isArray(history)) return [];
  return history.slice(-8).map((item) => ({
    role: item.role === "user" ? "user" : "assistant",
    content: String(item.content ?? "").slice(0, 700),
  }));
}

function normalizeAgentReply(reply: Record<string, unknown>, context: { contextUsed: string[] }) {
  const suggestions = Array.isArray(reply.suggestions)
    ? reply.suggestions.filter((item) => typeof item === "string").slice(0, 4)
    : defaultSuggestions();
  return {
    message:
      typeof reply.message === "string" && reply.message.trim().length > 0
        ? reply.message.trim()
        : "I read your Atlas data, but could not form a useful response.",
    mode: typeof reply.mode === "string" ? reply.mode : "Coach",
    suggestions,
    contextUsed: Array.isArray(reply.contextUsed)
      ? reply.contextUsed.filter((item) => typeof item === "string")
      : context.contextUsed,
  };
}

function parseAgentText(
  text: string,
  context: { contextUsed: string[] },
  screen?: string,
) {
  try {
    const parsed = JSON.parse(text);
    return normalizeAgentReply(parsed, context);
  } catch (_) {
    return {
      message: text || "Atlas Agent could not format the response.",
      mode: "Coach",
      suggestions: defaultSuggestions(screen),
      contextUsed: context.contextUsed,
    };
  }
}

function localCoachReply(message: string, context: Awaited<ReturnType<typeof buildAtlasContext>>) {
  const latest = context.recentSessions[0];
  const todayName = context.todayWorkout?.workout_name ?? "today's workout";
  const lower = message.toLowerCase();
  let answer =
    `Locked in. I can read your Atlas logs. Today is ${todayName}. You have ${context.recentWorkoutCount} recent sessions in context, a ${context.currentStreak}-day streak, and ${context.hydrationToday} water logs today.`;

  if (context.requestedDateSummary) {
    const day = context.requestedDateSummary;
    if (!day.hasAnyLog) {
      answer = `I checked ${day.date}. No Atlas logs are saved for that day: no workout, cardio, sport, weight, or hydration entries.`;
    } else {
      const workout = day.workout
        ? `${day.workout.title ?? "Workout"} with ${(day.workout.exercises ?? []).map((exercise: Record<string, unknown>) => exercise.name).join(", ")}`
        : "no saved workout";
      const extras = [
        day.hydrationSips > 0 ? `${day.hydrationSips} water sips` : null,
        day.weight ? `${day.weight.weight} ${day.weight.unit ?? "kg"} body weight` : null,
        day.cardio.length > 0 ? `${day.cardio.length} cardio log(s)` : null,
        day.sports.length > 0 ? `${day.sports.length} sport log(s)` : null,
      ].filter(Boolean);
      answer = `For ${day.date}: ${workout}.${extras.length ? ` Also logged ${extras.join(", ")}.` : ""}`;
    }
  } else if (lower.includes("last") || lower.includes("yesterday") || lower.includes("review")) {
    answer = latest
      ? `Solid. Your latest saved workout was ${latest.title ?? "Workout"} on ${latest.date}. It had ${(latest.exercises ?? []).length} exercises. Ask me about one lift and I will compare sets, reps, and weight.`
      : "I do not see a completed workout yet. Save one clean session and I can review it properly.";
  } else if (lower.includes("skip") || lower.includes("miss")) {
    answer =
      "No stress. If you skipped a day, do not restart the whole plan. Continue the current Atlas day, keep it slightly shorter, and save it so the streak can rebuild clean.";
  } else if (lower.includes("rest")) {
    answer =
      "Rest day plan: 20-30 min walk, easy treadmill if you want, mobility, stretching, foam rolling, water, and sleep. Recovery is the workout today.";
  }

  return {
    message: answer,
    mode: "Coach",
    suggestions: [],
    contextUsed: context.contextUsed,
  };
}

function defaultSuggestions(screen = "Atlas") {
  return [];
}

const agentInstructions = `
You are Atlas Buddy, a premium fitness companion inside the Atlas app.
Use the provided Atlas data only. Sound like a sharp gym buddy: casual, confident, modern, and a little Gen Z, but never cringe or noisy.
Use short lines. Be useful first. A little "bro", "solid", "locked in", or "we" is okay when natural.
You are a trainer/gym buddy, not a medical professional. Do not diagnose injuries.
Never claim to save, delete, or modify app data. You may recommend actions and say the user should confirm inside Atlas.
Prioritize the user's actual logs, current workout, goals, streak, hydration, weight logs, and exercise library.
If the user asks about a specific date, yesterday, or today, answer from requestedDateSummary. Include workouts, exercises, cardio, sport, hydration sips, and weight when present. If nothing is saved for that date, say that clearly.
When comparing workouts, mention dates, exercises, sets, reps, and weight when available.
Keep responses concise enough for a mobile overlay. Avoid long paragraphs.
Return strict JSON:
{
  "message": "useful gym buddy response",
  "mode": "Coach | Workout | Review | Recovery | Data",
  "suggestions": ["next prompt", "next prompt", "next prompt"],
  "contextUsed": ["today workout", "recent workout logs"]
}
`;

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}
