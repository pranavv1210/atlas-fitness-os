import { BarChart3, CalendarDays, Droplets, Dumbbell, Search, Settings, Target } from 'lucide-react';

export type PhoneMode = 'dashboard' | 'train' | 'library' | 'logger' | 'progress' | 'history' | 'goals' | 'settings';

type ProductPhoneProps = {
  mode?: PhoneMode;
};

export function ProductPhone({ mode = 'dashboard' }: ProductPhoneProps) {
  return (
    <div className="atlas-phone" aria-hidden="true">
      <div className="atlas-phone-frame">
        <div className="atlas-phone-notch" />
        <div className={`atlas-phone-screen phone-mode-${mode}`}>
          <PhoneContent mode={mode} />
        </div>
      </div>
    </div>
  );
}

function PhoneContent({ mode }: { mode: PhoneMode }) {
  if (mode === 'train') {
    return (
      <div className="phone-app">
        <ScreenHeader eyebrow="Today's workout" title="Chest + Triceps" />
        <div className="phone-hero-card"><Dumbbell size={18} /><strong>4 moves ready</strong><span>Day 1 / Manual build</span></div>
        <div className="phone-list compact"><b>Dumbbell Bench Press</b><b>Decline Bench Press</b><b>Triceps Pushdown</b></div>
      </div>
    );
  }

  if (mode === 'library') {
    return (
      <div className="phone-app">
        <ScreenHeader eyebrow="Exercise Library" title="2,069+ moves" />
        <div className="phone-search-row"><Search size={16} /> bench</div>
        <div className="phone-chips"><span>Chest</span><span>Dumbbell</span><span>Beginner</span></div>
        <div className="phone-list"><b>Dumbbell Bench Press</b><b>Incline Dumbbell Press</b><b>Smith Machine Press</b></div>
      </div>
    );
  }

  if (mode === 'logger') {
    return (
      <div className="phone-app">
        <ScreenHeader eyebrow="Workout Logger" title="Log key sets" />
        <div className="phone-hero-card"><Dumbbell size={18} /><strong>Dumbbell Bench</strong><span>Chest / Dumbbell</span></div>
        <div className="phone-set-grid"><span>Set</span><span>Reps</span><span>Kg</span><b>1</b><b>12</b><b>12.5</b><b>2</b><b>10</b><b>15</b></div>
      </div>
    );
  }

  if (mode === 'progress') {
    return (
      <div className="phone-app">
        <ScreenHeader eyebrow="Progress" title="Weekly rhythm" />
        <div className="phone-bars"><i /><i /><i /><i /><i /></div>
        <div className="phone-stats"><span>Recovery <b>88%</b></span><span>Score <b>78</b></span></div>
      </div>
    );
  }

  if (mode === 'history') {
    return (
      <div className="phone-app">
        <ScreenHeader eyebrow="Workout History" title="27 July" />
        <div className="phone-date-row"><span>25</span><span>26</span><b>27</b><span>28</span></div>
        <div className="phone-hero-card"><CalendarDays size={18} /><strong>Chest + Triceps</strong><span>42 min / 12 sets / 1,420 kg</span></div>
      </div>
    );
  }

  if (mode === 'goals') {
    return (
      <div className="phone-app">
        <ScreenHeader eyebrow="Goals" title="Bench 60 kg" />
        <div className="phone-ring"><Target size={30} /><strong>80%</strong><span>Next milestone</span></div>
        <div className="phone-hero-card small"><strong>Goal momentum</strong><span>On track this week</span></div>
      </div>
    );
  }

  if (mode === 'settings') {
    return (
      <div className="phone-app">
        <ScreenHeader eyebrow="Settings" title="Private by default" />
        <div className="phone-list settings"><b><Settings size={15} /> Google login</b><b><Droplets size={15} /> Water reminders</b><b><Target size={15} /> Biometric lock</b></div>
      </div>
    );
  }

  return (
    <div className="phone-app">
      <ScreenHeader eyebrow="Dashboard" title="Good Evening" />
      <div className="phone-focus">Discipline builds freedom.</div>
      <div className="phone-hero-card dark"><Dumbbell size={18} /><strong>Rest</strong><span>Recovery, mobility, hydration</span></div>
      <div className="phone-stats"><span><BarChart3 size={14} /> Score <b>78</b></span><span>Streak <b>5</b></span></div>
    </div>
  );
}

function ScreenHeader({ eyebrow, title }: { eyebrow: string; title: string }) {
  return (
    <header className="phone-screen-header">
      <span>{eyebrow}</span>
      <strong>{title}</strong>
    </header>
  );
}
