import type { ComponentType, ReactNode } from 'react';
import {
  Bell,
  Check,
  ChevronRight,
  Droplet,
  Dumbbell,
  House,
  Plus,
  Search,
  Send,
  Target,
  TrendingUp,
  User,
} from 'lucide-react';
import { SITE } from '@/lib/site';
import { PlateFace } from './marks';

/**
 * A recreation of the real Atlas Android UI in HTML and CSS.
 *
 * There are no product screenshots in this repository, so rather than
 * ship grey placeholder rectangles the interface is rebuilt from the
 * app's own theme values and its own strings - the set table really is
 * headed "Set / Reps / Kg", the hydration caption really does say
 * "sips today", and a saved session really is labelled "Saved session"
 * because the app records no duration.
 *
 * Sizing lives entirely in .device / device.css.
 */

export type ScreenId =
  | 'today'
  | 'train'
  | 'library'
  | 'reports'
  | 'progress'
  | 'hydration'
  | 'goals'
  | 'assistant';

type Tab = 'Today' | 'Train' | 'Progress' | 'Goals' | 'Me';

/** One-line descriptions read by assistive tech in place of the mock. */
export const SCREEN_ALT: Record<ScreenId, string> = {
  today:
    'The Today screen: tiles for fitness score, workouts this month, body weight and sips of water, above a card showing day 2 of the five-day cycle.',
  train:
    'The Train screen: day 2, Back and Biceps, with a bent over barbell row logged across three sets in a table headed Set, Reps and Kg.',
  library:
    'The exercise picker: a search field, muscle group filter chips, and a list of back exercises each with reference imagery.',
  reports:
    'A day report: one saved session listing six exercises and the total weight moved.',
  progress:
    'The Progress screen: a body-weight trend line and a bar chart of weekly training volume with the peak day called out.',
  hydration:
    'The hydration card: nine sips recorded today against the widget target of twenty-four, with reminders every 120 minutes.',
  goals:
    'The Goals screen: two goals the user created, each showing the value recorded when it was set.',
  assistant:
    'The assistant sheet: a question about last week\'s rows, answered from the user\'s own saved workouts.',
};

const TABS: { label: Tab; icon: ReactNode }[] = [
  { label: 'Today', icon: <House /> },
  { label: 'Train', icon: <Dumbbell /> },
  { label: 'Progress', icon: <TrendingUp /> },
  { label: 'Goals', icon: <Target /> },
  { label: 'Me', icon: <User /> },
];

function StatusBar() {
  return (
    <div className="dv-status">
      <span>9:41</span>
      <span className="dv-status-icons">
        <i />
        <i />
        <i />
      </span>
    </div>
  );
}

function AppBar({ title, sub, avatar }: { title: string; sub?: string; avatar?: boolean }) {
  return (
    <div className="dv-bar">
      <div style={{ minWidth: 0 }}>
        <div className="dv-bar-title">{title}</div>
        {sub ? <div className="dv-bar-sub">{sub}</div> : null}
      </div>
      {avatar ? <div className="dv-avatar">P</div> : null}
    </div>
  );
}

function Dock({ active }: { active: Tab }) {
  return (
    <nav className="dv-dock">
      {TABS.map((t) => (
        <span key={t.label} className={`dv-dock-item${t.label === active ? ' is-on' : ''}`}>
          {t.icon}
          {t.label}
        </span>
      ))}
    </nav>
  );
}

function Tile({
  label,
  value,
  unit,
  caption,
  accent,
  fill,
  water,
}: {
  label: string;
  value: string;
  unit?: string;
  caption?: string;
  accent?: boolean;
  fill?: number;
  water?: boolean;
}) {
  return (
    <div className={`dv-card dv-card-tight${accent ? ' dv-card-accent' : ''}`}>
      <div className="dv-tile-label">{label}</div>
      <div className="dv-tile-value">
        {value}
        {unit ? <small>{unit}</small> : null}
      </div>
      {caption ? <div className="dv-tile-caption">{caption}</div> : null}
      {typeof fill === 'number' ? (
        <div className="dv-track">
          <div
            className={`dv-track-fill${water ? ' is-water' : ''}`}
            style={{ width: `${fill}%` }}
          />
        </div>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */

function Today() {
  return (
    <>
      <StatusBar />
      <AppBar title="Today" sub="Day 2 / Back + Biceps" avatar />
      <div className="dv-body">
        <div className="dv-tiles">
          <Tile label="Fitness Score" value="68" caption="from logged work" fill={68} />
          <Tile label="This Month" value="14" caption="workouts saved" />
          <Tile label="Weight" value="74.2" unit="kg" caption="-> down 1.4" />
          <Tile label="Hydration" value="9" caption="sips today" fill={38} water />
        </div>

        <div className="dv-card">
          <div className="dv-row">
            <span className="dv-glyph">
              <Dumbbell />
            </span>
            <span className="dv-row-main">
              <span className="dv-row-title">Back + Biceps</span>
              <span className="dv-row-sub">Day 2 of 5 / 6 exercises</span>
            </span>
            <ChevronRight style={{ width: '4.4cqw', height: '4.4cqw', opacity: 0.4 }} />
          </div>
          <div className="dv-divider" />
          <span className="dv-btn dv-btn-fill">Start workout</span>
        </div>
      </div>
      <Dock active="Today" />
    </>
  );
}

function Train() {
  const sets = [
    ['1', '10', '60'],
    ['2', '10', '62.5'],
    ['3', '8', '65'],
  ];
  return (
    <>
      <StatusBar />
      <AppBar title="Train" sub="Day 2 / Back + Biceps" />
      <div className="dv-body">
        <div className="dv-card">
          <div className="dv-row">
            <span className="dv-thumb">BACK</span>
            <span className="dv-row-main">
              <span className="dv-row-title">Bent Over Barbell Row</span>
              <span className="dv-row-sub">Back / barbell</span>
            </span>
          </div>

          <div className="dv-sets">
            <div className="dv-set-row">
              <span className="dv-set-head">Set</span>
              <span className="dv-set-head">Reps</span>
              <span className="dv-set-head">Kg</span>
            </div>
            {sets.map((row) => (
              <div className="dv-set-row" key={row[0]}>
                <span className="dv-set-cell is-index">{row[0]}</span>
                <span className="dv-set-cell">{row[1]}</span>
                <span className="dv-set-cell">{row[2]}</span>
              </div>
            ))}
          </div>

          <div style={{ marginTop: '3cqw' }}>
            <span className="dv-btn dv-btn-ghost">
              <Plus />
              Add Set
            </span>
          </div>
        </div>

        <span className="dv-btn dv-btn-ghost">
          <Plus />
          Add Exercise
        </span>
        <span className="dv-btn dv-btn-done">
          <Check />
          Complete Workout
        </span>
      </div>
      <Dock active="Train" />
    </>
  );
}

function Library() {
  const rows = [
    ['Bent Over Barbell Row', 'Back / barbell'],
    ['Pullups', 'Back / body only'],
    ['Wide-Grip Lat Pulldown', 'Back / cable'],
    ['T-Bar Row', 'Back / barbell'],
    ['Seated Cable Rows', 'Back / cable'],
  ];
  return (
    <>
      <StatusBar />
      <AppBar title="Add Exercise" sub={`${SITE.exerciseWithImages} with reference imagery`} />
      <div className="dv-body">
        <div className="dv-search">
          <Search />
          Search exercises
        </div>
        <div className="dv-chips">
          {['All', 'Chest', 'Triceps', 'Back', 'Biceps'].map((c) => (
            <span key={c} className={`dv-chip${c === 'Back' ? ' is-on' : ''}`}>
              {c}
            </span>
          ))}
        </div>
        <div className="dv-card">
          {rows.map((r, i) => (
            <div key={r[0]}>
              {i > 0 ? <div className="dv-divider" /> : null}
              <div className="dv-row">
                <span className="dv-thumb">BACK</span>
                <span className="dv-row-main">
                  <span className="dv-row-title">{r[0]}</span>
                  <span className="dv-row-sub">{r[1]}</span>
                </span>
                <Plus style={{ width: '4.6cqw', height: '4.6cqw', opacity: 0.45 }} />
              </div>
            </div>
          ))}
        </div>
      </div>
      <Dock active="Train" />
    </>
  );
}

function Reports() {
  return (
    <>
      <StatusBar />
      <AppBar title="Reports" sub="Thursday 27 August" />
      <div className="dv-body">
        <div className="dv-card">
          <div className="dv-row">
            <span className="dv-glyph is-done">
              <Check />
            </span>
            <span className="dv-row-main">
              <span className="dv-row-title">Saved session</span>
              <span className="dv-row-sub">Back + Biceps / 6 exercises</span>
            </span>
            <span className="dv-row-value">4820 kg</span>
          </div>
          <div className="dv-divider" />
          {[
            ['Bent Over Barbell Row', '3 x 10'],
            ['Pullups', '3 x 8'],
            ['Seated Cable Rows', '3 x 12'],
            ['Barbell Curl', '3 x 10'],
          ].map((r, i) => (
            <div className="dv-row" key={r[0]} style={{ marginTop: i ? '2.6cqw' : 0 }}>
              <span className="dv-row-main">
                <span className="dv-row-sub" style={{ marginTop: 0 }}>
                  {r[0]}
                </span>
              </span>
              <span className="dv-row-value">{r[1]}</span>
            </div>
          ))}
        </div>
        <div className="dv-card dv-card-tight">
          <div className="dv-row">
            <span className="dv-glyph is-water">
              <Droplet />
            </span>
            <span className="dv-row-main">
              <span className="dv-row-title">12 sips</span>
              <span className="dv-row-sub">recorded that day</span>
            </span>
          </div>
        </div>
      </div>
      <Dock active="Progress" />
    </>
  );
}

function Progress() {
  const bars = [42, 78, 30, 96, 55, 68, 12];
  const peak = bars.indexOf(Math.max(...bars));
  const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  return (
    <>
      <StatusBar />
      <AppBar title="Progress" sub="Built from what you saved" />
      <div className="dv-body">
        <div className="dv-card">
          <div className="dv-tile-label">Body weight</div>
          <div className="dv-tile-value">
            74.2<small>kg</small>
          </div>
          <div className="dv-tile-caption">-&gt; down 1.4 kg / last 30 days</div>
          <svg className="dv-trend" viewBox="0 0 100 34" preserveAspectRatio="none">
            <defs>
              <linearGradient id="atlas-trend" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stopColor="#2563FF" stopOpacity=".22" />
                <stop offset="1" stopColor="#2563FF" stopOpacity="0" />
              </linearGradient>
            </defs>
            <path
              d="M0 8 L14 11 L28 7 L42 15 L56 13 L70 21 L84 19 L100 26 L100 34 L0 34 Z"
              fill="url(#atlas-trend)"
            />
            <path
              d="M0 8 L14 11 L28 7 L42 15 L56 13 L70 21 L84 19 L100 26"
              fill="none"
              stroke="#2563FF"
              strokeWidth="1.6"
              strokeLinecap="round"
              strokeLinejoin="round"
              vectorEffect="non-scaling-stroke"
            />
          </svg>
        </div>

        <div className="dv-card">
          <div className="dv-tile-label">Weekly volume</div>
          <div className="dv-bars">
            {bars.map((h, i) => (
              <span key={i} className={`dv-bar${i === peak ? ' is-peak' : ''}`}>
                <span className="dv-bar-fill" style={{ height: `${h}%` }} />
                <span className="dv-bar-label">{labels[i]}</span>
              </span>
            ))}
          </div>
          <div className="dv-tile-caption" style={{ marginTop: '2.4cqw' }}>
            Peak day: 4820 kg lifted.
          </div>
        </div>
      </div>
      <Dock active="Progress" />
    </>
  );
}

function Hydration() {
  return (
    <>
      <StatusBar />
      <AppBar title="Hydration" sub="One tap, one sip" />
      <div className="dv-body">
        <div className="dv-card">
          <div className="dv-row">
            <span className="dv-glyph is-water">
              <Droplet />
            </span>
            <span className="dv-row-main">
              <span className="dv-row-title">Water</span>
              <span className="dv-row-sub">Target 24 / from the widget</span>
            </span>
          </div>
          <div className="dv-tile-value" style={{ marginTop: '3.4cqw' }}>
            9<small>sips today</small>
          </div>
          <div className="dv-track">
            <div className="dv-track-fill is-water" style={{ width: '38%' }} />
          </div>
          <div className="dv-divider" />
          <div className="dv-row">
            <span className="dv-glyph is-quiet">
              <Bell />
            </span>
            <span className="dv-row-main">
              <span className="dv-row-title">Remind me</span>
              <span className="dv-row-sub">Every 120 minutes</span>
            </span>
            <ChevronRight style={{ width: '4.4cqw', height: '4.4cqw', opacity: 0.4 }} />
          </div>
        </div>
        <span className="dv-btn dv-btn-fill">
          <Plus />
          Add a sip
        </span>
      </div>
      <Dock active="Today" />
    </>
  );
}

function Goals() {
  return (
    <>
      <StatusBar />
      <AppBar title="Goals" sub="Two open" />
      <div className="dv-body">
        {[
          { title: 'Reach 72 kg', sub: 'Recorded 74.2 kg when set', fill: 62 },
          { title: 'Train 16 times in August', sub: 'Recorded 14 when set', fill: 87 },
        ].map((g) => (
          <div className="dv-card" key={g.title}>
            <div className="dv-row">
              <span className="dv-glyph is-goal">
                <Target />
              </span>
              <span className="dv-row-main">
                <span className="dv-row-title">{g.title}</span>
                <span className="dv-row-sub">{g.sub}</span>
              </span>
            </div>
            <div className="dv-track">
              <div className="dv-track-fill" style={{ width: `${g.fill}%` }} />
            </div>
          </div>
        ))}
        <span className="dv-btn dv-btn-ghost">
          <Plus />
          New goal
        </span>
      </div>
      <Dock active="Goals" />
    </>
  );
}

function Assistant() {
  return (
    <>
      <StatusBar />
      <AppBar title="Today" sub="Day 2 / Back + Biceps" avatar />
      <div className="dv-body" style={{ paddingBottom: 0 }}>
        <div className="dv-tiles">
          <Tile label="Fitness Score" value="68" caption="from logged work" fill={68} />
          <Tile label="This Month" value="14" caption="workouts saved" />
        </div>
      </div>
      <div className="dv-sheet">
        <div className="dv-sheet-grip" />
        <div className="dv-bubble-tag">Buddy note</div>
        <div className="dv-bubble dv-bubble-bot">
          Tell me what you want to know. I can check your saved workouts, exercises, weight,
          hydration, cardio, goals, and missed days.
        </div>
        <div className="dv-bubble dv-bubble-user" style={{ marginTop: '2.6cqw' }}>
          How did my rows go last week?
        </div>
        <div className="dv-bubble dv-bubble-bot" style={{ marginTop: '2.6cqw' }}>
          You rowed twice: 3 x 10 at 60 kg on Monday, then 3 x 10 at 62.5 kg on Thursday. Same
          reps, more weight.
        </div>
        <div className="dv-input">
          Talk training, food, recovery...
          <span className="dv-input-send">
            <Send />
          </span>
        </div>
      </div>
    </>
  );
}

const SCREENS: Record<ScreenId, ComponentType> = {
  today: Today,
  train: Train,
  library: Library,
  reports: Reports,
  progress: Progress,
  hydration: Hydration,
  goals: Goals,
  assistant: Assistant,
};

/** A single phone. */
export function Phone({
  screen,
  dark = false,
  orb = false,
  className,
}: {
  screen: ScreenId;
  dark?: boolean;
  orb?: boolean;
  className?: string;
}) {
  const Body = SCREENS[screen];
  return (
    <div className={className ? `device ${className}` : 'device'}>
      <div
        className={`device-screen${dark ? ' is-dark' : ''}`}
        role="img"
        aria-label={SCREEN_ALT[screen]}
      >
        <div aria-hidden="true" style={{ display: 'contents' }}>
          <Body />
          {orb ? (
            <span className="dv-orb">
              <PlateFace />
            </span>
          ) : null}
        </div>
      </div>
    </div>
  );
}

/**
 * Several screens stacked in one frame, one visible at a time.
 * Layers share a single grid cell rather than using absolute inset,
 * so the frame cannot be overflowed by a taller screen.
 */
export function PhoneStack({
  screens,
  active,
  dark = false,
  className,
}: {
  screens: readonly ScreenId[];
  active: number;
  dark?: boolean;
  className?: string;
}) {
  const current = screens[Math.min(Math.max(active, 0), screens.length - 1)];
  return (
    <div className={className ? `device ${className}` : 'device'}>
      <div
        className={`device-screen${dark ? ' is-dark' : ''}`}
        role="img"
        aria-label={SCREEN_ALT[current]}
      >
        <div className="dv-stack" aria-hidden="true">
          {screens.map((id, i) => {
            const Body = SCREENS[id];
            return (
              <div
                key={id}
                className="dv-layer"
                data-active={i === active ? 'true' : 'false'}
                style={{ display: 'flex', flexDirection: 'column' }}
              >
                <Body />
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
