alter table public.exercises
  add column if not exists target_muscle text,
  add column if not exists equipment text,
  add column if not exists difficulty text not null default 'Moderate',
  add column if not exists image_url text,
  add column if not exists gif_url text,
  add column if not exists search_keywords text[] not null default '{}';

create index if not exists exercises_search_keywords_gin_idx
on public.exercises using gin (search_keywords);

update public.exercises
set
  target_muscle = coalesce(target_muscle, 'Chest'),
  equipment = coalesce(equipment, 'Barbell'),
  image_url = coalesce(image_url, 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Bench_Press/0.jpg'),
  search_keywords = array['bench', 'chest', 'press', 'barbell']
where name = 'Barbell Bench Press';

update public.exercises
set
  target_muscle = coalesce(target_muscle, 'Chest'),
  equipment = coalesce(equipment, 'Dumbbells'),
  image_url = coalesce(image_url, 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Incline_Dumbbell_Bench_Press/0.jpg'),
  search_keywords = array['incline', 'chest', 'press', 'dumbbell']
where name = 'Incline Dumbbell Press';

update public.exercises
set
  target_muscle = coalesce(target_muscle, 'Chest'),
  equipment = coalesce(equipment, 'Cable'),
  image_url = coalesce(image_url, 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Cable_Crossover/0.jpg'),
  search_keywords = array['cable', 'fly', 'chest']
where name = 'Cable Fly';

update public.exercises
set
  target_muscle = coalesce(target_muscle, 'Chest'),
  equipment = coalesce(equipment, 'Bodyweight'),
  image_url = coalesce(image_url, 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Triceps_Dip/0.jpg'),
  search_keywords = array['dips', 'chest', 'triceps', 'bodyweight']
where name = 'Dips';

update public.exercises
set
  target_muscle = coalesce(target_muscle, 'Triceps'),
  equipment = coalesce(equipment, 'Cable'),
  image_url = coalesce(image_url, 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Triceps_Pushdown/0.jpg'),
  search_keywords = array['rope', 'pushdown', 'triceps', 'cable']
where name = 'Rope Pushdown';

update public.exercises
set
  target_muscle = coalesce(target_muscle, 'Triceps'),
  equipment = coalesce(equipment, 'Dumbbell'),
  image_url = coalesce(image_url, 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Standing_Dumbbell_Triceps_Extension/0.jpg'),
  search_keywords = array['overhead', 'extension', 'triceps']
where name = 'Overhead Extension';

update public.exercises
set
  target_muscle = coalesce(target_muscle, 'Back'),
  equipment = coalesce(equipment, 'Barbell'),
  image_url = coalesce(image_url, 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Deadlift/0.jpg'),
  search_keywords = array['deadlift', 'back', 'hinge', 'barbell']
where name = 'Deadlift';

update public.exercises
set
  target_muscle = coalesce(target_muscle, 'Back'),
  equipment = coalesce(equipment, 'Cable'),
  image_url = coalesce(image_url, 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Lat_Pulldown/0.jpg'),
  search_keywords = array['lat', 'pulldown', 'back', 'cable']
where name = 'Lat Pulldown';

update public.exercises
set
  target_muscle = coalesce(target_muscle, 'Back'),
  equipment = coalesce(equipment, 'Cable'),
  image_url = coalesce(image_url, 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Seated_Cable_Row/0.jpg'),
  search_keywords = array['row', 'back', 'cable']
where name = 'Seated Cable Row';

update public.exercises
set
  target_muscle = coalesce(target_muscle, 'Biceps'),
  equipment = coalesce(equipment, 'Dumbbells'),
  image_url = coalesce(image_url, 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dumbbell_Bicep_Curl/0.jpg'),
  search_keywords = array['curl', 'biceps', 'dumbbell']
where name = 'Dumbbell Curl';

update public.exercises
set
  target_muscle = coalesce(target_muscle, 'Shoulders'),
  equipment = coalesce(equipment, 'Dumbbells'),
  image_url = coalesce(image_url, 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dumbbell_Lateral_Raise/0.jpg'),
  search_keywords = array['lateral', 'raise', 'shoulders', 'dumbbell']
where name = 'Lateral Raise';

update public.exercises
set
  target_muscle = coalesce(target_muscle, 'Shoulders'),
  equipment = coalesce(equipment, 'Barbell'),
  image_url = coalesce(image_url, 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Standing_Military_Press/0.jpg'),
  search_keywords = array['overhead', 'press', 'shoulders', 'barbell']
where name = 'Overhead Press';

update public.exercises
set
  target_muscle = coalesce(target_muscle, 'Legs'),
  equipment = coalesce(equipment, 'Barbell'),
  image_url = coalesce(image_url, 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Squat/0.jpg'),
  search_keywords = array['squat', 'legs', 'barbell']
where name = 'Back Squat';

update public.exercises
set
  target_muscle = coalesce(target_muscle, 'Legs'),
  equipment = coalesce(equipment, 'Machine'),
  image_url = coalesce(image_url, 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Leg_Press/0.jpg'),
  search_keywords = array['leg', 'press', 'machine']
where name = 'Leg Press';

update public.exercises
set
  target_muscle = coalesce(target_muscle, 'Core'),
  equipment = coalesce(equipment, 'Bodyweight'),
  image_url = coalesce(image_url, 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Plank/0.jpg'),
  search_keywords = array['plank', 'core', 'bodyweight']
where name = 'Plank';
