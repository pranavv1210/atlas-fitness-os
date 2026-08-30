import { BarChart3, CalendarDays, Check, Dumbbell, Droplets, Search, Target } from 'lucide-react';
import { SITE } from '@/lib/site';

export type PhoneScreen =
  | 'dashboard'
  | 'train'
  | 'library'
  | 'logger'
  | 'history'
  | 'progress'
  | 'hydration'
  | 'goals'
  | 'complete';

type PhoneMockProps = {
  mode?: PhoneScreen;
  className?: string;
  hideFrame?: boolean;
};

/** Pure-CSS Atlas phone mockup. Sized with container-query units so it scales
 *  cleanly from 320px viewports up to desktop. Mirrors the real app surfaces. */
export function PhoneMock({ mode = 'dashboard', className = '', hideFrame = false }: PhoneMockProps) {
  if (hideFrame) {
    return (
      <div className={`pm-app pms-${mode} h-full w-full bg-atlas-paper rounded-[10cqw] overflow-hidden`}>
        <Screen mode={mode} />
      </div>
    );
  }

  return (
    <div className={`pm-shell ${className}`}>
      <div className="pm" aria-hidden="true">
        <div className="pm-frame">
          <div className="pm-notch" />
          <div className="pm-screen">
            <div className="pm-status">
              <span>9:41</span>
              <span className="pm-tray">
                <i />
                <i />
                <i />
              </span>
            </div>
            <div className={`pm-app pms-${mode}`}>
              <Screen mode={mode} />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function Screen({ mode }: { mode: PhoneScreen }) {
  switch (mode) {
    case 'train':
      return (
        <>
          <span className="pm-eyebrow">Train</span>
          <strong className="pm-title">Chest + Triceps</strong>
          <span className="pm-sub">Day 1 of the cycle</span>
          <div className="pm-row">
            <Dumbbell /> Dumbbell Bench Press <span>3x12</span>
          </div>
          <div className="pm-row">
            <Dumbbell /> Decline Bench Press <span>3x10</span>
          </div>
          <div className="pm-row">
            <Dumbbell /> Triceps Pushdown <span>3x12</span>
          </div>
          <div className="pm-btn">Log workout</div>
        </>
      );

    case 'library':
      return (
        <>
          <span className="pm-eyebrow">Exercise library</span>
          <strong className="pm-title">{SITE.exerciseCount} moves</strong>
          <div className="pm-search">
            <Search /> bench press
          </div>
          <div className="pm-chip-row">
            <span className="pm-chip pm-chip-active">Chest</span>
            <span className="pm-chip">Dumbbell</span>
            <span className="pm-chip">Beginner</span>
          </div>
          <div className="pm-row">
            <Dumbbell /> Dumbbell Bench Press <span>Chest</span>
          </div>
          <div className="pm-row">
            <Dumbbell /> Incline Dumbbell Press <span>Chest</span>
          </div>
          <div className="pm-row">
            <Dumbbell /> Smith Machine Press <span>Chest</span>
          </div>
        </>
      );

    case 'logger':
      return (
        <>
          <span className="pm-eyebrow">Workout logger</span>
          <strong className="pm-title">Chest + Triceps</strong>
          <div className="pm-card">
            <span className="pm-card-label">
              <Dumbbell /> Dumbbell Bench Press
            </span>
          </div>
          <div className="pm-set">
            <span>Set</span>
            <span>Reps</span>
            <span>Kg</span>
            <b>1</b>
            <b>12</b>
            <b className="pm-kg">12.5</b>
            <b>2</b>
            <b>10</b>
            <b className="pm-kg">15</b>
            <b>3</b>
            <b>8</b>
            <b className="pm-kg">17</b>
          </div>
          <span className="pm-footnote">Enter the work. Keep the signal.</span>
          <div className="pm-btn">Save workout</div>
        </>
      );

    case 'history':
      return (
        <>
          <span className="pm-eyebrow">Workout history</span>
          <strong className="pm-title">This week</strong>
          <div className="pm-date-strip">
            <span>23</span>
            <span>24</span>
            <span>25</span>
            <b>26</b>
            <span>27</span>
            <span>28</span>
            <span>29</span>
          </div>
          <div className="pm-card">
            <span className="pm-card-label">
              <CalendarDays /> 26 July
            </span>
            <strong className="pm-card-title">Chest + Triceps</strong>
            <span className="pm-card-sub">42 min - 12 sets - 1,420 kg</span>
          </div>
          <div className="pm-card">
            <span className="pm-card-label">
              <CalendarDays /> 25 July
            </span>
            <strong className="pm-card-title">Back + Biceps</strong>
            <span className="pm-card-sub">40 min - 14 sets - 1,610 kg</span>
          </div>
        </>
      );

    case 'progress':
      return (
        <>
          <span className="pm-eyebrow">Progress</span>
          <strong className="pm-title">Weekly rhythm</strong>
          <div className="pm-bars">
            <i style={{ height: '38%' }} />
            <i style={{ height: '72%' }} />
            <i className="hi" style={{ height: '55%' }} />
            <i className="hi" style={{ height: '88%' }} />
            <i style={{ height: '64%' }} />
          </div>
          <div className="pm-stat-row">
            <div className="pm-stat">
              <span>
                <BarChart3 /> Volume
              </span>
              <b>6.8k</b>
            </div>
            <div className="pm-stat">
              <span>Recovery</span>
              <b>88%</b>
            </div>
          </div>
          <span className="pm-footnote">4 of 5 workouts this week</span>
        </>
      );

    case 'hydration':
      return (
        <>
          <span className="pm-eyebrow">Hydration</span>
          <strong className="pm-title">Today</strong>
          <div className="pm-meter">
            <i style={{ height: '78%' }} />
          </div>
          <div className="pm-stat-row">
            <div className="pm-stat">
              <span>
                <Droplets /> Logged
              </span>
              <b>16 sips</b>
            </div>
            <div className="pm-stat">
              <span>Goal</span>
              <b>24 sips</b>
            </div>
          </div>
          <div className="pm-btn">+ 1 sip</div>
        </>
      );

    case 'goals':
      return (
        <>
          <span className="pm-eyebrow">Goals</span>
          <strong className="pm-title">Bench 60 kg</strong>
          <div className="pm-ring">
            <b>80%</b>
          </div>
          <div className="pm-card">
            <span className="pm-card-label">
              <Target /> Momentum
            </span>
            <strong className="pm-card-title">On track this week</strong>
            <span className="pm-card-sub">12 kg from the milestone</span>
          </div>
        </>
      );

    case 'complete':
      return (
        <>
          <div className="pm-check">
            <Check />
          </div>
          <strong className="pm-title">Workout saved</strong>
          <span className="pm-sub">Chest + Triceps - 42 min</span>
          <div className="pm-stat-row">
            <div className="pm-stat">
              <span>Sets</span>
              <b>12</b>
            </div>
            <div className="pm-stat">
              <span>Volume</span>
              <b>1.4 t</b>
            </div>
          </div>
          <div className="pm-btn pm-btn-dark">View report</div>
          <span className="pm-footnote">The system remembers.</span>
        </>
      );

    default:
      return (
        <>
          <span className="pm-eyebrow">Today</span>
          <strong className="pm-title">Day 5 - Rest</strong>
          <span className="pm-sub">Recovery, mobility, hydration</span>
          <div className="pm-card pm-card-dark">
            <span className="pm-card-label">
              <Dumbbell /> Training status
            </span>
            <strong className="pm-card-title">Rest day</strong>
            <span className="pm-card-sub">Next session: Chest + Triceps</span>
          </div>
          <div className="pm-stat-row">
            <div className="pm-stat">
              <span>Fitness score</span>
              <b>78</b>
            </div>
            <div className="pm-stat">
              <span>Streak</span>
              <b>5</b>
            </div>
          </div>
          <div className="pm-chip-row">
            <span className="pm-chip">
              <Droplets /> 16 sips
            </span>
            <span className="pm-chip">74.6 kg</span>
          </div>
        </>
      );
  }
}
