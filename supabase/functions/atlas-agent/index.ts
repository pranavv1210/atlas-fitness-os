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
  const openAiKey = Deno.env.get("OPENAI_API_KEY");
  if (!supabaseUrl || !supabaseAnonKey) {
    return json(
      {
        message:
          "Atlas Agent is missing Supabase environment variables on the server.",
        suggestions: ["Review my last workout", "What should I train today?"],
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
        suggestions: ["Review my week", "What should I train today?"],
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
  if (!openAiKey) {
    return json(localCoachReply(message, context));
  }

  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${openAiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: Deno.env.get("OPENAI_MODEL") ?? "gpt-4.1-mini",
      instructions: agentInstructions,
      input: [
        {
          role: "user",
          content: [
            {
              type: "input_text",
              text: JSON.stringify({
                userQuestion: message,
                currentScreen: body.screen ?? "Atlas",
                recentConversation: sanitizeHistory(body.history),
                atlasContext: context,
              }),
            },
          ],
        },
      ],
      text: { format: { type: "json_object" } },
    }),
  });

  if (!response.ok) {
    const detail = await response.text();
    console.error("OpenAI response failed", response.status, detail);
    return json(localCoachReply(message, context));
  }

  const payload = await response.json();
  const text = extractOutputText(payload);
  try {
    const parsed = JSON.parse(text);
    return json(normalizeAgentReply(parsed, context));
  } catch (_) {
    return json({
      message: text || "Atlas Agent could not format the response.",
      mode: "Coach",
      suggestions: defaultSuggestions(body.screen),
      contextUsed: context.contextUsed,
    });
  }
});

async function buildAtlasContext(supabase: ReturnType<typeof createClient>, message: string, screen?: string) {
  const today = new Date().toISOString().slice(0, 10);
  const search = searchTerms(message);

  const [
    profile,
    todayWorkout,
    sessions,
    goals,
    weights,
    hydration,
    exercises,
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
    relevantExercises: exercises,
    contextUsed: [
      "today workout",
      "recent workout logs",
      "exercise sets/reps/weight",
      "goals",
      "weight logs",
      "hydration",
      "exercise library",
    ],
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

function extractOutputText(payload: Record<string, unknown>) {
  if (typeof payload.output_text === "string") return payload.output_text;
  const output = Array.isArray(payload.output) ? payload.output : [];
  for (const item of output) {
    const content = (item as Record<string, unknown>).content;
    if (!Array.isArray(content)) continue;
    for (const part of content) {
      const text = (part as Record<string, unknown>).text;
      if (typeof text === "string") return text;
    }
  }
  return "";
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

function localCoachReply(message: string, context: Awaited<ReturnType<typeof buildAtlasContext>>) {
  const latest = context.recentSessions[0];
  const todayName = context.todayWorkout?.workout_name ?? "today's workout";
  const lower = message.toLowerCase();
  let answer =
    `I can read your Atlas logs now. Today is ${todayName}. You have ${context.recentWorkoutCount} recent completed sessions in context, a ${context.currentStreak}-day active streak, and ${context.hydrationToday} water logs today.`;

  if (lower.includes("last") || lower.includes("yesterday") || lower.includes("review")) {
    answer = latest
      ? `Your latest saved workout was ${latest.title ?? "Workout"} on ${latest.date}. It included ${(latest.exercises ?? []).length} exercises. Ask me about a specific exercise and I can compare sets, reps, and weight from your logs.`
      : "I do not see a completed workout yet. Save a session and I can review it here.";
  } else if (lower.includes("skip") || lower.includes("miss")) {
    answer =
      "If you skipped a day, do not restart the whole plan. Continue with the current Atlas day, keep the session slightly shorter, and save it so your history stays clean.";
  } else if (lower.includes("rest")) {
    answer =
      "For rest, keep it recovery-focused: 20-30 minutes walking, light treadmill, mobility, stretching, foam rolling, hydration, and sleep. Avoid turning rest into another heavy lifting day.";
  }

  return {
    message: answer,
    mode: "Coach",
    suggestions: defaultSuggestions(context.currentScreen),
    contextUsed: context.contextUsed,
  };
}

function defaultSuggestions(screen = "Atlas") {
  if (screen === "Train") {
    return [
      "What should I train today?",
      "Suggest weights from last time",
      "Replace an exercise",
      "Make this workout shorter",
    ];
  }
  if (screen === "Progress") {
    return [
      "Review my week",
      "What improved most?",
      "What am I skipping?",
      "Explain my streak",
    ];
  }
  return [
    "What should I train today?",
    "Review my last workout",
    "I skipped a day, what now?",
    "Suggest a rest day plan",
  ];
}

const agentInstructions = `
You are Atlas Agent, a premium fitness companion inside the Atlas app.
Use the provided Atlas data only. Be calm, practical, and direct.
You are a trainer/gym buddy, not a medical professional. Do not diagnose injuries.
Never claim to save, delete, or modify app data. You may recommend actions and say the user should confirm inside Atlas.
Prioritize the user's actual logs, current workout, goals, streak, hydration, weight logs, and exercise library.
When comparing workouts, mention dates, exercises, sets, reps, and weight when available.
Keep responses concise enough for a mobile overlay.
Return strict JSON:
{
  "message": "useful coach response",
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
