-- Atlas backend foundation.
-- This migration creates schema, relationships, indexes, RLS, views, storage
-- buckets, and small database functions. It intentionally avoids Flutter logic.

create extension if not exists pgcrypto with schema extensions;

create type public.workout_session_status as enum (
  'planned',
  'in_progress',
  'completed',
  'skipped',
  'deleted'
);

create type public.goal_type as enum (
  'weight',
  'strength',
  'habit',
  'deadline'
);

create type public.goal_status as enum (
  'active',
  'completed',
  'paused',
  'archived'
);

create type public.activity_intensity as enum (
  'low',
  'moderate',
  'high'
);

create type public.notification_event_status as enum (
  'scheduled',
  'shown',
  'tapped',
  'dismissed',
  'suppressed'
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.is_record_owner(record_owner uuid)
returns boolean
language sql
stable
set search_path = public
as $$
  select auth.uid() = record_owner;
$$;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'Pranav',
  email text,
  avatar_url text,
  height_cm numeric(5,2),
  date_of_birth date,
  unit_system text not null default 'metric' check (unit_system in ('metric', 'imperial')),
  timezone text not null default 'Asia/Kolkata',
  cycle_anchor_date date not null default current_date,
  weekly_workout_target integer not null default 5 check (weekly_workout_target between 1 and 14),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create table public.user_settings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  setting_key text not null,
  setting_value jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, setting_key)
);

create trigger user_settings_set_updated_at
before update on public.user_settings
for each row execute function public.set_updated_at();

create table public.default_settings (
  setting_key text primary key,
  setting_value jsonb not null,
  description text,
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name, email, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name', 'Pranav'),
    new.email,
    new.raw_user_meta_data ->> 'avatar_url'
  )
  on conflict (id) do update
  set email = excluded.email,
      avatar_url = coalesce(excluded.avatar_url, public.profiles.avatar_url),
      updated_at = now();

  insert into public.user_settings (user_id, setting_key, setting_value)
  select new.id, setting_key, setting_value
  from public.default_settings
  on conflict (user_id, setting_key) do nothing;

  insert into public.hydration_preferences (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  insert into public.notification_preferences (user_id, notification_type, enabled, local_time, metadata)
  values
    (new.id, 'morning_greeting', true, '07:30', '{}'::jsonb),
    (new.id, 'workout_reminder', true, '18:30', '{}'::jsonb),
    (new.id, 'water_reminder', true, null, '{"interval_minutes":120}'::jsonb),
    (new.id, 'weekly_summary', true, '19:00', '{}'::jsonb)
  on conflict (user_id, notification_type) do nothing;

  return new;
end;
$$;

create trigger on_auth_user_created_create_atlas_profile
after insert on auth.users
for each row execute function public.handle_new_auth_user();

create table public.workout_cycles (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  description text,
  cycle_length integer not null check (cycle_length > 0),
  is_system boolean not null default true,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger workout_cycles_set_updated_at
before update on public.workout_cycles
for each row execute function public.set_updated_at();

create table public.workout_days (
  id uuid primary key default gen_random_uuid(),
  cycle_id uuid not null references public.workout_cycles(id) on delete cascade,
  day_number integer not null check (day_number > 0),
  name text not null,
  focus text not null,
  is_rest_day boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (cycle_id, day_number)
);

create trigger workout_days_set_updated_at
before update on public.workout_days
for each row execute function public.set_updated_at();

create table public.exercise_categories (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  display_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table public.muscle_groups (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  display_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table public.equipment (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  created_at timestamptz not null default now()
);

create table public.exercises (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references public.profiles(id) on delete cascade,
  category_id uuid references public.exercise_categories(id) on delete set null,
  equipment_id uuid references public.equipment(id) on delete set null,
  name text not null,
  movement_pattern text,
  default_sets integer check (default_sets is null or default_sets > 0),
  default_reps text,
  is_system boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint exercises_owner_for_custom_check check (
    is_system = true or owner_id is not null
  )
);

create unique index exercises_system_name_unique
on public.exercises (lower(name))
where is_system = true and deleted_at is null;

create unique index exercises_owner_name_unique
on public.exercises (owner_id, lower(name))
where owner_id is not null and deleted_at is null;

create trigger exercises_set_updated_at
before update on public.exercises
for each row execute function public.set_updated_at();

create table public.exercise_muscle_groups (
  exercise_id uuid not null references public.exercises(id) on delete cascade,
  muscle_group_id uuid not null references public.muscle_groups(id) on delete cascade,
  is_primary boolean not null default false,
  created_at timestamptz not null default now(),
  primary key (exercise_id, muscle_group_id)
);

create table public.workout_templates (
  id uuid primary key default gen_random_uuid(),
  workout_day_id uuid not null references public.workout_days(id) on delete cascade,
  owner_id uuid references public.profiles(id) on delete cascade,
  name text not null,
  version integer not null default 1 check (version > 0),
  is_system boolean not null default true,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint workout_templates_owner_for_custom_check check (
    is_system = true or owner_id is not null
  )
);

create unique index workout_templates_system_day_version_unique
on public.workout_templates (workout_day_id, version)
where is_system = true;

create unique index workout_templates_owner_day_version_unique
on public.workout_templates (owner_id, workout_day_id, version)
where owner_id is not null;

create trigger workout_templates_set_updated_at
before update on public.workout_templates
for each row execute function public.set_updated_at();

create table public.workout_template_exercises (
  id uuid primary key default gen_random_uuid(),
  template_id uuid not null references public.workout_templates(id) on delete cascade,
  exercise_id uuid not null references public.exercises(id) on delete restrict,
  display_order integer not null check (display_order > 0),
  target_sets integer not null check (target_sets > 0),
  target_reps text not null,
  notes text,
  created_at timestamptz not null default now(),
  unique (template_id, display_order),
  unique (template_id, exercise_id)
);

create table public.workout_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  workout_day_id uuid references public.workout_days(id) on delete set null,
  template_id uuid references public.workout_templates(id) on delete set null,
  session_date date not null,
  started_at timestamptz,
  completed_at timestamptz,
  status public.workout_session_status not null default 'planned',
  title text not null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index workout_sessions_user_date_idx
on public.workout_sessions (user_id, session_date desc)
where deleted_at is null;

create index workout_sessions_user_status_idx
on public.workout_sessions (user_id, status)
where deleted_at is null;

create trigger workout_sessions_set_updated_at
before update on public.workout_sessions
for each row execute function public.set_updated_at();

create table public.workout_session_exercises (
  id uuid primary key default gen_random_uuid(),
  workout_session_id uuid not null references public.workout_sessions(id) on delete cascade,
  exercise_id uuid references public.exercises(id) on delete set null,
  display_order integer not null check (display_order > 0),
  name_snapshot text not null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (workout_session_id, display_order)
);

create trigger workout_session_exercises_set_updated_at
before update on public.workout_session_exercises
for each row execute function public.set_updated_at();

create table public.workout_sets (
  id uuid primary key default gen_random_uuid(),
  workout_session_exercise_id uuid not null references public.workout_session_exercises(id) on delete cascade,
  set_number integer not null check (set_number > 0),
  reps integer check (reps is null or reps >= 0),
  weight numeric(7,2) check (weight is null or weight >= 0),
  weight_unit text check (weight_unit is null or weight_unit in ('kg', 'lb')),
  is_completed boolean not null default true,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (workout_session_exercise_id, set_number)
);

create trigger workout_sets_set_updated_at
before update on public.workout_sets
for each row execute function public.set_updated_at();

create table public.body_weight_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  measured_on date not null,
  weight numeric(6,2) not null check (weight > 0),
  unit text not null check (unit in ('kg', 'lb')),
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (user_id, measured_on)
);

create index body_weight_logs_user_measured_idx
on public.body_weight_logs (user_id, measured_on desc)
where deleted_at is null;

create trigger body_weight_logs_set_updated_at
before update on public.body_weight_logs
for each row execute function public.set_updated_at();

create table public.wellness_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  logged_on date not null,
  mood integer not null check (mood between 1 and 5),
  energy integer not null check (energy between 1 and 5),
  stress integer not null check (stress between 1 and 5),
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (user_id, logged_on)
);

create index wellness_logs_user_logged_idx
on public.wellness_logs (user_id, logged_on desc)
where deleted_at is null;

create trigger wellness_logs_set_updated_at
before update on public.wellness_logs
for each row execute function public.set_updated_at();

create table public.recovery_score_snapshots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  score_date date not null,
  score integer not null check (score between 0 and 100),
  label text not null,
  inputs jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (user_id, score_date)
);

create index recovery_score_user_date_idx
on public.recovery_score_snapshots (user_id, score_date desc);

create table public.fitness_score_snapshots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  score_date date not null,
  score integer not null check (score between 0 and 100),
  label text not null,
  inputs jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (user_id, score_date)
);

create index fitness_score_user_date_idx
on public.fitness_score_snapshots (user_id, score_date desc);

create table public.hydration_preferences (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  reminder_interval_minutes integer not null default 120 check (reminder_interval_minutes between 30 and 360),
  reminders_enabled boolean not null default true,
  quiet_start time,
  quiet_end time,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger hydration_preferences_set_updated_at
before update on public.hydration_preferences
for each row execute function public.set_updated_at();

create table public.hydration_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  occurred_at timestamptz not null default now(),
  source text not null default 'manual',
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index hydration_events_user_occurred_idx
on public.hydration_events (user_id, occurred_at desc)
where deleted_at is null;

create table public.goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  goal_type public.goal_type not null,
  title text not null,
  target_value numeric(10,2),
  target_unit text,
  current_value numeric(10,2),
  start_date date not null default current_date,
  deadline date,
  status public.goal_status not null default 'active',
  progress_method text not null default 'manual',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index goals_user_status_idx
on public.goals (user_id, status, deadline)
where deleted_at is null;

create trigger goals_set_updated_at
before update on public.goals
for each row execute function public.set_updated_at();

create table public.default_goal_templates (
  id uuid primary key default gen_random_uuid(),
  goal_type public.goal_type not null,
  title text not null,
  target_value numeric(10,2),
  target_unit text,
  progress_method text not null,
  display_order integer not null default 0,
  created_at timestamptz not null default now()
);

create unique index default_goal_templates_type_title_unique
on public.default_goal_templates (goal_type, lower(title));

create table public.goal_progress_snapshots (
  id uuid primary key default gen_random_uuid(),
  goal_id uuid not null references public.goals(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  snapshot_date date not null,
  progress_percent numeric(5,2) not null check (progress_percent between 0 and 100),
  current_value numeric(10,2),
  note text,
  created_at timestamptz not null default now(),
  unique (goal_id, snapshot_date)
);

create index goal_progress_user_date_idx
on public.goal_progress_snapshots (user_id, snapshot_date desc);

create table public.goal_milestones (
  id uuid primary key default gen_random_uuid(),
  goal_id uuid not null references public.goals(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  target_progress_percent numeric(5,2) not null check (target_progress_percent between 0 and 100),
  achieved_at timestamptz,
  created_at timestamptz not null default now()
);

create index goal_milestones_user_goal_idx
on public.goal_milestones (user_id, goal_id);

create table public.cardio_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  activity_type text not null,
  session_date date not null,
  duration_minutes integer not null check (duration_minutes > 0),
  distance numeric(8,2) check (distance is null or distance >= 0),
  distance_unit text check (distance_unit is null or distance_unit in ('km', 'mi')),
  intensity public.activity_intensity,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index cardio_sessions_user_date_idx
on public.cardio_sessions (user_id, session_date desc)
where deleted_at is null;

create trigger cardio_sessions_set_updated_at
before update on public.cardio_sessions
for each row execute function public.set_updated_at();

create table public.sports_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  sport_name text not null,
  session_date date not null,
  duration_minutes integer not null check (duration_minutes > 0),
  intensity public.activity_intensity,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index sports_sessions_user_date_idx
on public.sports_sessions (user_id, session_date desc)
where deleted_at is null;

create trigger sports_sessions_set_updated_at
before update on public.sports_sessions
for each row execute function public.set_updated_at();

create table public.motivational_quotes (
  id uuid primary key default gen_random_uuid(),
  quote_text text not null,
  author text,
  display_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create unique index motivational_quotes_text_unique
on public.motivational_quotes (lower(quote_text));

create table public.notification_preferences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  notification_type text not null,
  enabled boolean not null default true,
  local_time time,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, notification_type)
);

create trigger notification_preferences_set_updated_at
before update on public.notification_preferences
for each row execute function public.set_updated_at();

create table public.notification_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  notification_type text not null,
  status public.notification_event_status not null,
  scheduled_for timestamptz,
  occurred_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index notification_events_user_scheduled_idx
on public.notification_events (user_id, scheduled_for desc);

create table public.sync_change_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  entity_name text not null,
  entity_id uuid not null,
  operation text not null check (operation in ('create', 'update', 'delete')),
  changed_at timestamptz not null default now(),
  metadata jsonb not null default '{}'::jsonb
);

create index sync_change_log_user_changed_idx
on public.sync_change_log (user_id, changed_at desc);

create or replace function public.current_cycle_day(
  anchor_date date,
  cycle_length integer,
  target_date date default current_date
)
returns integer
language sql
stable
set search_path = public
as $$
  select (((target_date - anchor_date) % cycle_length + cycle_length) % cycle_length) + 1;
$$;

create or replace function public.get_today_workout(target_date date default current_date)
returns table (
  user_id uuid,
  workout_date date,
  cycle_day integer,
  workout_day_id uuid,
  workout_name text,
  focus text,
  is_rest_day boolean,
  template_id uuid
)
language sql
stable
security invoker
set search_path = public
as $$
  select
    p.id as user_id,
    target_date as workout_date,
    public.current_cycle_day(p.cycle_anchor_date, wc.cycle_length, target_date) as cycle_day,
    wd.id as workout_day_id,
    wd.name as workout_name,
    wd.focus,
    wd.is_rest_day,
    wt.id as template_id
  from public.profiles p
  join public.workout_cycles wc
    on wc.code = 'atlas_default'
   and wc.is_active = true
  join public.workout_days wd
    on wd.cycle_id = wc.id
   and wd.day_number = public.current_cycle_day(p.cycle_anchor_date, wc.cycle_length, target_date)
  left join public.workout_templates wt
    on wt.workout_day_id = wd.id
   and wt.is_active = true
   and (wt.is_system = true or wt.owner_id = p.id)
  where p.id = auth.uid();
$$;

create or replace function public.advance_workout_cycle(
  target_user_id uuid,
  new_anchor_date date default current_date
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
begin
  if auth.uid() is null or auth.uid() <> target_user_id then
    raise exception 'Not allowed';
  end if;

  update public.profiles
     set cycle_anchor_date = new_anchor_date
   where id = target_user_id;
end;
$$;

create or replace function public.calculate_dashboard_summary(
  target_date date default current_date
)
returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
  with profile as (
    select id, weekly_workout_target
    from public.profiles
    where id = auth.uid()
  ),
  week_window as (
    select
      date_trunc('week', target_date::timestamp)::date as week_start,
      (date_trunc('week', target_date::timestamp)::date + 6) as week_end
  ),
  workouts as (
    select count(*)::integer as completed_count
    from public.workout_sessions ws, week_window ww
    where ws.user_id = auth.uid()
      and ws.status = 'completed'
      and ws.deleted_at is null
      and ws.session_date between ww.week_start and ww.week_end
  ),
  latest_weight as (
    select weight, unit, measured_on
    from public.body_weight_logs
    where user_id = auth.uid()
      and deleted_at is null
    order by measured_on desc
    limit 1
  ),
  recovery as (
    select score, label
    from public.recovery_score_snapshots
    where user_id = auth.uid()
    order by score_date desc
    limit 1
  ),
  fitness as (
    select score, label
    from public.fitness_score_snapshots
    where user_id = auth.uid()
    order by score_date desc
    limit 1
  )
  select jsonb_build_object(
    'weekly_workouts_completed', coalesce((select completed_count from workouts), 0),
    'weekly_workout_target', coalesce((select weekly_workout_target from profile), 5),
    'latest_weight', (select to_jsonb(latest_weight) from latest_weight),
    'recovery', (select to_jsonb(recovery) from recovery),
    'fitness', (select to_jsonb(fitness) from fitness),
    'today_workout', (
      select to_jsonb(tw)
      from public.get_today_workout(target_date) tw
      limit 1
    )
  );
$$;

create or replace function public.generate_weekly_report(
  week_start date default date_trunc('week', current_date::timestamp)::date
)
returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
  with bounds as (
    select week_start as start_date, week_start + 6 as end_date
  ),
  workouts as (
    select count(*)::integer as completed_workouts
    from public.workout_sessions ws, bounds b
    where ws.user_id = auth.uid()
      and ws.status = 'completed'
      and ws.deleted_at is null
      and ws.session_date between b.start_date and b.end_date
  ),
  sets as (
    select count(wset.id)::integer as total_sets
    from public.workout_sessions ws
    join public.workout_session_exercises wse on wse.workout_session_id = ws.id
    join public.workout_sets wset on wset.workout_session_exercise_id = wse.id
    join bounds b on true
    where ws.user_id = auth.uid()
      and ws.deleted_at is null
      and ws.session_date between b.start_date and b.end_date
      and wset.is_completed = true
  ),
  cardio as (
    select coalesce(sum(duration_minutes), 0)::integer as cardio_minutes
    from public.cardio_sessions cs, bounds b
    where cs.user_id = auth.uid()
      and cs.deleted_at is null
      and cs.session_date between b.start_date and b.end_date
  )
  select jsonb_build_object(
    'week_start', week_start,
    'week_end', week_start + 6,
    'completed_workouts', coalesce((select completed_workouts from workouts), 0),
    'total_sets', coalesce((select total_sets from sets), 0),
    'cardio_minutes', coalesce((select cardio_minutes from cardio), 0)
  );
$$;

create or replace view public.v_today_workout
with (security_invoker = true)
as
select *
from public.get_today_workout(current_date);

create or replace view public.v_weekly_progress
with (security_invoker = true)
as
with week_window as (
  select
    date_trunc('week', current_date::timestamp)::date as week_start,
    (date_trunc('week', current_date::timestamp)::date + 6) as week_end
)
select
  p.id as user_id,
  ww.week_start,
  ww.week_end,
  p.weekly_workout_target,
  count(ws.id)::integer as workouts_completed,
  least(
    100,
    round((count(ws.id)::numeric / greatest(p.weekly_workout_target, 1)) * 100, 2)
  ) as progress_percent
from public.profiles p
cross join week_window ww
left join public.workout_sessions ws
  on ws.user_id = p.id
 and ws.status = 'completed'
 and ws.deleted_at is null
 and ws.session_date between ww.week_start and ww.week_end
where p.id = auth.uid()
group by p.id, ww.week_start, ww.week_end, p.weekly_workout_target;

create or replace view public.v_latest_weight
with (security_invoker = true)
as
select distinct on (bwl.user_id)
  bwl.user_id,
  bwl.measured_on,
  bwl.weight,
  bwl.unit,
  bwl.note
from public.body_weight_logs bwl
where bwl.user_id = auth.uid()
  and bwl.deleted_at is null
order by bwl.user_id, bwl.measured_on desc, bwl.created_at desc;

create or replace view public.v_active_goals
with (security_invoker = true)
as
select
  g.*,
  gps.progress_percent,
  gps.snapshot_date as latest_progress_date
from public.goals g
left join lateral (
  select progress_percent, snapshot_date
  from public.goal_progress_snapshots gps
  where gps.goal_id = g.id
  order by gps.snapshot_date desc
  limit 1
) gps on true
where g.user_id = auth.uid()
  and g.status = 'active'
  and g.deleted_at is null;

create or replace view public.v_dashboard_summary
with (security_invoker = true)
as
select
  auth.uid() as user_id,
  public.calculate_dashboard_summary(current_date) as summary;

alter table public.profiles enable row level security;
alter table public.user_settings enable row level security;
alter table public.default_settings enable row level security;
alter table public.workout_cycles enable row level security;
alter table public.workout_days enable row level security;
alter table public.exercise_categories enable row level security;
alter table public.muscle_groups enable row level security;
alter table public.equipment enable row level security;
alter table public.exercises enable row level security;
alter table public.exercise_muscle_groups enable row level security;
alter table public.workout_templates enable row level security;
alter table public.workout_template_exercises enable row level security;
alter table public.workout_sessions enable row level security;
alter table public.workout_session_exercises enable row level security;
alter table public.workout_sets enable row level security;
alter table public.body_weight_logs enable row level security;
alter table public.wellness_logs enable row level security;
alter table public.recovery_score_snapshots enable row level security;
alter table public.fitness_score_snapshots enable row level security;
alter table public.hydration_preferences enable row level security;
alter table public.hydration_events enable row level security;
alter table public.goals enable row level security;
alter table public.default_goal_templates enable row level security;
alter table public.goal_progress_snapshots enable row level security;
alter table public.goal_milestones enable row level security;
alter table public.cardio_sessions enable row level security;
alter table public.sports_sessions enable row level security;
alter table public.motivational_quotes enable row level security;
alter table public.notification_preferences enable row level security;
alter table public.notification_events enable row level security;
alter table public.sync_change_log enable row level security;

create policy "profiles_select_own" on public.profiles
for select to authenticated using (public.is_record_owner(id));
create policy "profiles_insert_own" on public.profiles
for insert to authenticated with check (public.is_record_owner(id));
create policy "profiles_update_own" on public.profiles
for update to authenticated using (public.is_record_owner(id)) with check (public.is_record_owner(id));

create policy "default_settings_read" on public.default_settings
for select to authenticated using (true);
create policy "workout_cycles_read" on public.workout_cycles
for select to authenticated using (is_active = true);
create policy "workout_days_read" on public.workout_days
for select to authenticated using (true);
create policy "exercise_categories_read" on public.exercise_categories
for select to authenticated using (true);
create policy "muscle_groups_read" on public.muscle_groups
for select to authenticated using (true);
create policy "equipment_read" on public.equipment
for select to authenticated using (true);
create policy "motivational_quotes_read" on public.motivational_quotes
for select to authenticated using (is_active = true);
create policy "default_goal_templates_read" on public.default_goal_templates
for select to authenticated using (true);

create policy "exercises_select_system_or_own" on public.exercises
for select to authenticated using (
  deleted_at is null and (is_system = true or public.is_record_owner(owner_id))
);
create policy "exercises_insert_own" on public.exercises
for insert to authenticated with check (
  is_system = false and public.is_record_owner(owner_id)
);
create policy "exercises_update_own" on public.exercises
for update to authenticated using (
  is_system = false and public.is_record_owner(owner_id)
) with check (
  is_system = false and public.is_record_owner(owner_id)
);

create policy "exercise_muscle_groups_read_visible_exercises" on public.exercise_muscle_groups
for select to authenticated using (
  exists (
    select 1 from public.exercises e
    where e.id = exercise_id
      and e.deleted_at is null
      and (e.is_system = true or e.owner_id = auth.uid())
  )
);
create policy "exercise_muscle_groups_insert_own_custom" on public.exercise_muscle_groups
for insert to authenticated with check (
  exists (
    select 1 from public.exercises e
    where e.id = exercise_id
      and e.is_system = false
      and e.owner_id = auth.uid()
  )
);
create policy "exercise_muscle_groups_update_own_custom" on public.exercise_muscle_groups
for update to authenticated using (
  exists (
    select 1 from public.exercises e
    where e.id = exercise_id
      and e.is_system = false
      and e.owner_id = auth.uid()
  )
) with check (
  exists (
    select 1 from public.exercises e
    where e.id = exercise_id
      and e.is_system = false
      and e.owner_id = auth.uid()
  )
);
create policy "exercise_muscle_groups_delete_own_custom" on public.exercise_muscle_groups
for delete to authenticated using (
  exists (
    select 1 from public.exercises e
    where e.id = exercise_id
      and e.is_system = false
      and e.owner_id = auth.uid()
  )
);

create policy "workout_templates_select_system_or_own" on public.workout_templates
for select to authenticated using (
  is_active = true and (is_system = true or public.is_record_owner(owner_id))
);
create policy "workout_templates_insert_own" on public.workout_templates
for insert to authenticated with check (
  is_system = false and public.is_record_owner(owner_id)
);
create policy "workout_templates_update_own" on public.workout_templates
for update to authenticated using (
  is_system = false and public.is_record_owner(owner_id)
) with check (
  is_system = false and public.is_record_owner(owner_id)
);

create policy "workout_template_exercises_read_visible_templates" on public.workout_template_exercises
for select to authenticated using (
  exists (
    select 1 from public.workout_templates wt
    where wt.id = template_id
      and wt.is_active = true
      and (wt.is_system = true or wt.owner_id = auth.uid())
  )
);
create policy "workout_template_exercises_insert_own_custom" on public.workout_template_exercises
for insert to authenticated with check (
  exists (
    select 1 from public.workout_templates wt
    where wt.id = template_id
      and wt.is_system = false
      and wt.owner_id = auth.uid()
  )
);
create policy "workout_template_exercises_update_own_custom" on public.workout_template_exercises
for update to authenticated using (
  exists (
    select 1 from public.workout_templates wt
    where wt.id = template_id
      and wt.is_system = false
      and wt.owner_id = auth.uid()
  )
) with check (
  exists (
    select 1 from public.workout_templates wt
    where wt.id = template_id
      and wt.is_system = false
      and wt.owner_id = auth.uid()
  )
);
create policy "workout_template_exercises_delete_own_custom" on public.workout_template_exercises
for delete to authenticated using (
  exists (
    select 1 from public.workout_templates wt
    where wt.id = template_id
      and wt.is_system = false
      and wt.owner_id = auth.uid()
  )
);

create policy "user_settings_all_own" on public.user_settings
for all to authenticated using (public.is_record_owner(user_id)) with check (public.is_record_owner(user_id));
create policy "workout_sessions_all_own" on public.workout_sessions
for all to authenticated using (public.is_record_owner(user_id)) with check (public.is_record_owner(user_id));
create policy "body_weight_logs_all_own" on public.body_weight_logs
for all to authenticated using (public.is_record_owner(user_id)) with check (public.is_record_owner(user_id));
create policy "wellness_logs_all_own" on public.wellness_logs
for all to authenticated using (public.is_record_owner(user_id)) with check (public.is_record_owner(user_id));
create policy "recovery_scores_all_own" on public.recovery_score_snapshots
for all to authenticated using (public.is_record_owner(user_id)) with check (public.is_record_owner(user_id));
create policy "fitness_scores_all_own" on public.fitness_score_snapshots
for all to authenticated using (public.is_record_owner(user_id)) with check (public.is_record_owner(user_id));
create policy "hydration_preferences_all_own" on public.hydration_preferences
for all to authenticated using (public.is_record_owner(user_id)) with check (public.is_record_owner(user_id));
create policy "hydration_events_all_own" on public.hydration_events
for all to authenticated using (public.is_record_owner(user_id)) with check (public.is_record_owner(user_id));
create policy "goals_all_own" on public.goals
for all to authenticated using (public.is_record_owner(user_id)) with check (public.is_record_owner(user_id));
create policy "goal_progress_all_own" on public.goal_progress_snapshots
for all to authenticated using (public.is_record_owner(user_id)) with check (public.is_record_owner(user_id));
create policy "goal_milestones_all_own" on public.goal_milestones
for all to authenticated using (public.is_record_owner(user_id)) with check (public.is_record_owner(user_id));
create policy "cardio_sessions_all_own" on public.cardio_sessions
for all to authenticated using (public.is_record_owner(user_id)) with check (public.is_record_owner(user_id));
create policy "sports_sessions_all_own" on public.sports_sessions
for all to authenticated using (public.is_record_owner(user_id)) with check (public.is_record_owner(user_id));
create policy "notification_preferences_all_own" on public.notification_preferences
for all to authenticated using (public.is_record_owner(user_id)) with check (public.is_record_owner(user_id));
create policy "notification_events_all_own" on public.notification_events
for all to authenticated using (public.is_record_owner(user_id)) with check (public.is_record_owner(user_id));
create policy "sync_change_log_all_own" on public.sync_change_log
for all to authenticated using (public.is_record_owner(user_id)) with check (public.is_record_owner(user_id));

create policy "workout_session_exercises_all_own" on public.workout_session_exercises
for all to authenticated using (
  exists (
    select 1 from public.workout_sessions ws
    where ws.id = workout_session_id
      and ws.user_id = auth.uid()
  )
) with check (
  exists (
    select 1 from public.workout_sessions ws
    where ws.id = workout_session_id
      and ws.user_id = auth.uid()
  )
);

create policy "workout_sets_all_own" on public.workout_sets
for all to authenticated using (
  exists (
    select 1
    from public.workout_session_exercises wse
    join public.workout_sessions ws on ws.id = wse.workout_session_id
    where wse.id = workout_session_exercise_id
      and ws.user_id = auth.uid()
  )
) with check (
  exists (
    select 1
    from public.workout_session_exercises wse
    join public.workout_sessions ws on ws.id = wse.workout_session_id
    where wse.id = workout_session_exercise_id
      and ws.user_id = auth.uid()
  )
);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('avatars', 'avatars', false, 5242880, array['image/png', 'image/jpeg', 'image/webp']),
  ('progress_photos', 'progress_photos', false, 10485760, array['image/png', 'image/jpeg', 'image/webp']),
  ('exports', 'exports', false, 52428800, array['text/csv', 'application/pdf', 'application/json', 'application/zip'])
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy "storage_read_own_folder" on storage.objects
for select to authenticated using (
  bucket_id in ('avatars', 'progress_photos', 'exports')
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "storage_insert_own_folder" on storage.objects
for insert to authenticated with check (
  bucket_id in ('avatars', 'progress_photos', 'exports')
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "storage_update_own_folder" on storage.objects
for update to authenticated using (
  bucket_id in ('avatars', 'progress_photos', 'exports')
  and (storage.foldername(name))[1] = auth.uid()::text
) with check (
  bucket_id in ('avatars', 'progress_photos', 'exports')
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "storage_delete_own_folder" on storage.objects
for delete to authenticated using (
  bucket_id in ('avatars', 'progress_photos', 'exports')
  and (storage.foldername(name))[1] = auth.uid()::text
);
