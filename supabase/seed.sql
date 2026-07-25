-- Atlas seed data.
-- Seeds only system/default records. User-owned data is created after auth.

insert into public.default_settings (setting_key, setting_value, description)
values
  ('appearance', '{"theme":"light","material":"premium_glass"}', 'Default visual appearance'),
  ('units', '{"system":"metric","weight":"kg","distance":"km"}', 'Default unit preferences'),
  ('hydration', '{"reminders_enabled":true,"interval_minutes":120}', 'Default hydration nudges'),
  ('notifications', '{"morning":true,"workout":true,"water":true,"weekly_summary":true}', 'Default notification toggles'),
  ('privacy', '{"app_lock_enabled":false,"exports_enabled":false}', 'Future privacy defaults')
on conflict (setting_key) do update
set setting_value = excluded.setting_value,
    description = excluded.description;

insert into public.workout_cycles (code, name, description, cycle_length, is_system, is_active)
values (
  'atlas_default',
  'Atlas Default Cycle',
  'Five-day repeating personal workout cycle.',
  5,
  true,
  true
)
on conflict (code) do update
set name = excluded.name,
    description = excluded.description,
    cycle_length = excluded.cycle_length,
    is_active = excluded.is_active;

with cycle as (
  select id from public.workout_cycles where code = 'atlas_default'
)
insert into public.workout_days (cycle_id, day_number, name, focus, is_rest_day)
select cycle.id, data.day_number, data.name, data.focus, data.is_rest_day
from cycle
cross join (
  values
    (1, 'Chest + Triceps', 'Push strength and upper-body pressing', false),
    (2, 'Back + Biceps', 'Pull strength and posterior upper body', false),
    (3, 'Arms + Abs', 'Arm volume and trunk control', false),
    (4, 'Shoulders + Legs', 'Shoulder strength and lower-body work', false),
    (5, 'Rest', 'Recovery, mobility, hydration, and readiness', true)
) as data(day_number, name, focus, is_rest_day)
on conflict (cycle_id, day_number) do update
set name = excluded.name,
    focus = excluded.focus,
    is_rest_day = excluded.is_rest_day;

insert into public.exercise_categories (code, name, display_order)
values
  ('strength', 'Strength', 1),
  ('accessory', 'Accessory', 2),
  ('core', 'Core', 3),
  ('cardio', 'Cardio', 4),
  ('mobility', 'Mobility', 5)
on conflict (code) do update
set name = excluded.name,
    display_order = excluded.display_order;

insert into public.muscle_groups (code, name, display_order)
values
  ('chest', 'Chest', 1),
  ('triceps', 'Triceps', 2),
  ('back', 'Back', 3),
  ('biceps', 'Biceps', 4),
  ('arms', 'Arms', 5),
  ('abs', 'Abs', 6),
  ('shoulders', 'Shoulders', 7),
  ('legs', 'Legs', 8),
  ('glutes', 'Glutes', 9),
  ('calves', 'Calves', 10),
  ('full_body', 'Full Body', 11)
on conflict (code) do update
set name = excluded.name,
    display_order = excluded.display_order;

insert into public.equipment (code, name)
values
  ('barbell', 'Barbell'),
  ('dumbbell', 'Dumbbell'),
  ('cable', 'Cable'),
  ('machine', 'Machine'),
  ('bodyweight', 'Bodyweight'),
  ('kettlebell', 'Kettlebell'),
  ('cardio_machine', 'Cardio Machine')
on conflict (code) do update
set name = excluded.name;

with category as (
  select code, id from public.exercise_categories
),
equip as (
  select code, id from public.equipment
)
insert into public.exercises (
  category_id,
  equipment_id,
  name,
  movement_pattern,
  default_sets,
  default_reps,
  is_system,
  is_active
)
select
  category.id,
  equip.id,
  data.name,
  data.movement_pattern,
  data.default_sets,
  data.default_reps,
  true,
  true
from (
  values
    ('strength', 'barbell', 'Barbell Bench Press', 'horizontal_push', 4, '8-10'),
    ('strength', 'dumbbell', 'Incline Dumbbell Press', 'incline_push', 3, '10'),
    ('accessory', 'cable', 'Cable Fly', 'chest_isolation', 3, '12-15'),
    ('strength', 'bodyweight', 'Dips', 'vertical_push', 3, '8-12'),
    ('accessory', 'cable', 'Rope Pushdown', 'triceps_isolation', 3, '12'),
    ('accessory', 'dumbbell', 'Overhead Extension', 'triceps_isolation', 2, '12-15'),
    ('strength', 'barbell', 'Deadlift', 'hinge_pull', 3, '5'),
    ('strength', 'machine', 'Lat Pulldown', 'vertical_pull', 4, '8-12'),
    ('strength', 'cable', 'Seated Cable Row', 'horizontal_pull', 3, '10-12'),
    ('accessory', 'dumbbell', 'Dumbbell Curl', 'biceps_isolation', 3, '10-12'),
    ('accessory', 'cable', 'Face Pull', 'rear_delt_pull', 3, '12-15'),
    ('accessory', 'dumbbell', 'Hammer Curl', 'biceps_isolation', 3, '10-12'),
    ('accessory', 'dumbbell', 'Lateral Raise', 'shoulder_isolation', 4, '12-15'),
    ('strength', 'barbell', 'Overhead Press', 'vertical_push', 4, '6-8'),
    ('strength', 'barbell', 'Back Squat', 'squat', 4, '6-10'),
    ('strength', 'machine', 'Leg Press', 'squat', 3, '10-12'),
    ('accessory', 'machine', 'Leg Curl', 'hamstring_isolation', 3, '12'),
    ('accessory', 'machine', 'Calf Raise', 'calf_isolation', 4, '12-15'),
    ('core', 'bodyweight', 'Plank', 'anti_extension', 3, '45-60 sec'),
    ('core', 'bodyweight', 'Hanging Knee Raise', 'trunk_flexion', 3, '10-15')
) as data(category_code, equipment_code, name, movement_pattern, default_sets, default_reps)
join category on category.code = data.category_code
join equip on equip.code = data.equipment_code
on conflict do nothing;

with exercise as (
  select id, name from public.exercises
),
muscle as (
  select id, code from public.muscle_groups
),
pairs as (
  select * from (
    values
      ('Barbell Bench Press', 'chest', true),
      ('Barbell Bench Press', 'triceps', false),
      ('Incline Dumbbell Press', 'chest', true),
      ('Incline Dumbbell Press', 'shoulders', false),
      ('Cable Fly', 'chest', true),
      ('Dips', 'chest', true),
      ('Dips', 'triceps', false),
      ('Rope Pushdown', 'triceps', true),
      ('Overhead Extension', 'triceps', true),
      ('Deadlift', 'back', true),
      ('Deadlift', 'legs', false),
      ('Lat Pulldown', 'back', true),
      ('Lat Pulldown', 'biceps', false),
      ('Seated Cable Row', 'back', true),
      ('Dumbbell Curl', 'biceps', true),
      ('Face Pull', 'shoulders', true),
      ('Hammer Curl', 'biceps', true),
      ('Lateral Raise', 'shoulders', true),
      ('Overhead Press', 'shoulders', true),
      ('Overhead Press', 'triceps', false),
      ('Back Squat', 'legs', true),
      ('Back Squat', 'glutes', false),
      ('Leg Press', 'legs', true),
      ('Leg Curl', 'legs', true),
      ('Calf Raise', 'calves', true),
      ('Plank', 'abs', true),
      ('Hanging Knee Raise', 'abs', true)
  ) as data(exercise_name, muscle_code, is_primary)
)
insert into public.exercise_muscle_groups (exercise_id, muscle_group_id, is_primary)
select exercise.id, muscle.id, pairs.is_primary
from pairs
join exercise on exercise.name = pairs.exercise_name
join muscle on muscle.code = pairs.muscle_code
on conflict (exercise_id, muscle_group_id) do update
set is_primary = excluded.is_primary;

with days as (
  select wd.id, wd.name
  from public.workout_days wd
  join public.workout_cycles wc on wc.id = wd.cycle_id
  where wc.code = 'atlas_default'
)
insert into public.workout_templates (workout_day_id, name, version, is_system, is_active)
select id, name, 1, true, true
from days
where name <> 'Rest'
on conflict do nothing;

with template as (
  select wt.id, wt.name
  from public.workout_templates wt
  where wt.is_system = true
),
exercise as (
  select id, name from public.exercises
),
plan as (
  select * from (
    values
      ('Chest + Triceps', 1, 'Barbell Bench Press', 4, '8-10', 'Main lift'),
      ('Chest + Triceps', 2, 'Incline Dumbbell Press', 3, '10', 'Controlled press'),
      ('Chest + Triceps', 3, 'Cable Fly', 3, '12-15', 'Full stretch'),
      ('Chest + Triceps', 4, 'Dips', 3, '8-12', 'Chest lean'),
      ('Chest + Triceps', 5, 'Rope Pushdown', 3, '12', 'Full lockout'),
      ('Chest + Triceps', 6, 'Overhead Extension', 2, '12-15', 'Slow eccentric'),
      ('Back + Biceps', 1, 'Deadlift', 3, '5', 'Heavy hinge'),
      ('Back + Biceps', 2, 'Lat Pulldown', 4, '8-12', 'Controlled pull'),
      ('Back + Biceps', 3, 'Seated Cable Row', 3, '10-12', 'Pause and squeeze'),
      ('Back + Biceps', 4, 'Face Pull', 3, '12-15', 'Rear delt control'),
      ('Back + Biceps', 5, 'Dumbbell Curl', 3, '10-12', 'Strict reps'),
      ('Back + Biceps', 6, 'Hammer Curl', 3, '10-12', 'Neutral grip'),
      ('Arms + Abs', 1, 'Dumbbell Curl', 4, '10-12', 'Strict curl'),
      ('Arms + Abs', 2, 'Hammer Curl', 3, '10-12', 'Forearm control'),
      ('Arms + Abs', 3, 'Rope Pushdown', 4, '12', 'Triceps volume'),
      ('Arms + Abs', 4, 'Overhead Extension', 3, '12-15', 'Long head focus'),
      ('Arms + Abs', 5, 'Plank', 3, '45-60 sec', 'Brace'),
      ('Arms + Abs', 6, 'Hanging Knee Raise', 3, '10-15', 'Controlled core'),
      ('Shoulders + Legs', 1, 'Overhead Press', 4, '6-8', 'Main press'),
      ('Shoulders + Legs', 2, 'Lateral Raise', 4, '12-15', 'No momentum'),
      ('Shoulders + Legs', 3, 'Back Squat', 4, '6-10', 'Main lower lift'),
      ('Shoulders + Legs', 4, 'Leg Press', 3, '10-12', 'Deep range'),
      ('Shoulders + Legs', 5, 'Leg Curl', 3, '12', 'Hamstrings'),
      ('Shoulders + Legs', 6, 'Calf Raise', 4, '12-15', 'Full stretch')
  ) as data(template_name, display_order, exercise_name, target_sets, target_reps, notes)
)
insert into public.workout_template_exercises (
  template_id,
  exercise_id,
  display_order,
  target_sets,
  target_reps,
  notes
)
select template.id, exercise.id, plan.display_order, plan.target_sets, plan.target_reps, plan.notes
from plan
join template on template.name = plan.template_name
join exercise on exercise.name = plan.exercise_name
on conflict (template_id, display_order) do update
set exercise_id = excluded.exercise_id,
    target_sets = excluded.target_sets,
    target_reps = excluded.target_reps,
    notes = excluded.notes;

insert into public.motivational_quotes (quote_text, author, display_order, is_active)
values
  ('Strength is built quietly, one precise session at a time.', 'Atlas', 1, true),
  ('The work compounds when the routine is simple.', 'Atlas', 2, true),
  ('Train with intent. Recover with respect.', 'Atlas', 3, true),
  ('Consistency is a system, not a mood.', 'Atlas', 4, true),
  ('Today only needs one honest entry.', 'Atlas', 5, true),
  ('Calm effort beats noisy ambition.', 'Atlas', 6, true)
on conflict do nothing;

insert into public.default_goal_templates (
  goal_type,
  title,
  target_value,
  target_unit,
  progress_method,
  display_order
)
values
  ('weight', 'Reach target body weight', 74.50, 'kg', 'weight_trend', 1),
  ('strength', 'Improve bench press strength', 80.00, 'kg', 'strength_log', 2),
  ('habit', 'Complete five workouts weekly', 5.00, 'workouts', 'weekly_count', 3),
  ('deadline', 'Finish the month strong', 1.00, 'month', 'deadline_completion', 4)
on conflict do nothing;
