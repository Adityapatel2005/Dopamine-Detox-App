const state = {
  onboarded: false,
  onboardingStep: 0,
  tab: 'today',
  score: 82,
  sessionActive: false,
  secondsLeft: 25 * 60,
  selectedApps: ['TikTok', 'Instagram', 'YouTube'],
  goal: 'Cut brain rot',
  defaultLockDurationMinutes: 25,
  hardBlock: false,
  predictiveProtection: false,
  screenTimeStatus: 'Not requested',
  notificationStatus: 'Not requested',
  phase2BlockingStatus: 'Choose apps with FamilyActivityPicker, then start a lock-in.',
  phase3ShieldStatus: 'ShieldConfiguration will show humane Lockd copy when a selected app is blocked.',
  phase4InsightStatus: 'DeviceActivityReport will generate privacy-preserving weekly insights on iPhone.',
  proEntitlement: 'free',
  bypassAttempts: 0,
  emergencyUnlocks: 0,
  notificationPreferences: {
    weakSpotWarning: true,
    lockStarted: true,
    lockEndingSoon: true,
    lockCompleted: true,
    rescueNudge: true,
    dailyPlan: false,
    weeklyRecap: true
  },
  selectedResource: null,
  sheet: null
};

const app = document.querySelector('#app');
let timerId = null;

const onboarding = [
  {
    title: 'Your weak spots are predictable.',
    body: 'Lockd helps you stop before the scroll starts.',
    button: 'Find my weak spots'
  },
  {
    title: 'Pick three apps to guard.',
    body: 'Start small. TikTok, Instagram, YouTube, Reddit, Safari, or your own selections later.',
    button: 'Choose apps'
  },
  {
    title: 'Choose the lock-in goal.',
    body: 'Cut brain rot, study without folding, sleep without scrolling, or start Monk Mode.',
    button: 'Set my goal'
  },
  {
    title: 'Try a 10-minute quick lock.',
    body: 'Feel protected now. Permissions and Pro come after the first win.',
    button: 'Start Lockd'
  }
];

const apps = [
  ['TikTok', 'music.note'],
  ['Instagram', 'camera'],
  ['YouTube', 'play.rectangle'],
  ['Reddit', 'bubble.left'],
  ['Safari', 'safari']
];

const notificationOptions = [
  {
    key: 'weakSpotWarning',
    title: 'Weak spot warning',
    subtitle: 'A risky scroll window is coming up.'
  },
  {
    key: 'lockStarted',
    title: 'Lock-in started',
    subtitle: 'Confirm selected apps are protected.'
  },
  {
    key: 'lockEndingSoon',
    title: 'Lock-in ending soon',
    subtitle: 'A calm heads-up before the block ends.'
  },
  {
    key: 'lockCompleted',
    title: 'Lock-in completed',
    subtitle: 'Private progress feedback after a protected block.'
  },
  {
    key: 'rescueNudge',
    title: 'Rescue nudge',
    subtitle: 'A short pause after a bypass attempt.'
  },
  {
    key: 'dailyPlan',
    title: 'Daily plan',
    subtitle: 'Optional daily reminder to choose a focus block.'
  },
  {
    key: 'weeklyRecap',
    title: 'Weekly recap',
    subtitle: 'A private weekly summary when it is ready.'
  }
];

const complianceResources = [
  {
    title: 'Privacy Policy',
    section: 'Privacy & Legal',
    subtitle: 'Local-first focus data, no tracking, no third-party analytics.'
  },
  {
    title: 'Terms of Service',
    section: 'Privacy & Legal',
    subtitle: 'Focus tool terms with Apple In-App Purchase for Lockd Pro.'
  },
  {
    title: 'Privacy Rights',
    section: 'Data Rights',
    subtitle: 'GDPR, California, access, correction, and deletion rights.'
  },
  {
    title: 'Delete Local Data',
    section: 'Data Rights',
    subtitle: 'Remove on-device sessions, rules, predictions, goals, and recaps.'
  },
  {
    title: 'Accessibility',
    section: 'Access & Safety',
    subtitle: 'VoiceOver, Dynamic Type, Reduced Motion, and 44 pt touch targets.'
  },
  {
    title: 'Subscription Terms',
    section: 'Subscription',
    subtitle: 'Pricing, trial, renewal, restore, and cancellation details.'
  },
  {
    title: 'Medical Disclaimer',
    section: 'Access & Safety',
    subtitle: 'Lockd is not medical advice and does not treat health conditions.'
  }
];

const policySections = [
  {
    title: 'Privacy & Legal',
    resources: ['Privacy Policy', 'Terms of Service']
  },
  {
    title: 'Data Rights',
    resources: ['Privacy Rights', 'Delete Local Data']
  },
  {
    title: 'Access & Safety',
    resources: ['Accessibility', 'Medical Disclaimer']
  },
  {
    title: 'Subscription',
    resources: ['Subscription Terms']
  }
];

function formatTime(totalSeconds) {
  const minutes = Math.floor(totalSeconds / 60).toString().padStart(2, '0');
  const seconds = (totalSeconds % 60).toString().padStart(2, '0');
  return `${minutes}:${seconds}`;
}

function setState(patch) {
  Object.assign(state, patch);
  render();
}

function nextOnboarding() {
  if (state.onboardingStep === onboarding.length - 1) {
    setState({ onboarded: true });
    return;
  }
  setState({ onboardingStep: state.onboardingStep + 1 });
}

function startLockIn() {
  setState({
    sessionActive: true,
    secondsLeft: 25 * 60,
    score: Math.max(state.score, 82),
    phase2BlockingStatus: 'ManagedSettings shields are simulated; DeviceActivityMonitor would clear them on iPhone.',
    phase3ShieldStatus: 'ShieldActionDelegate is ready to record bypass attempts from the blocked-app shield.',
    bypassAttempts: 0,
    emergencyUnlocks: 0,
    sheet: null
  });
  window.clearInterval(timerId);
  timerId = window.setInterval(() => {
    state.secondsLeft = Math.max(0, state.secondsLeft - 1);
    if (state.secondsLeft === 0) {
      window.clearInterval(timerId);
      setState({
        sessionActive: false,
        score: 94,
        phase2BlockingStatus: 'Lock-in completed. Native iOS would remove ManagedSettings shields.',
        phase3ShieldStatus: 'Shield session ended. Rescue counts remain local for the recap.',
        sheet: 'complete'
      });
      return;
    }
    renderTodayOnly();
  }, 1000);
}

function completeSession() {
  window.clearInterval(timerId);
  setState({
    sessionActive: false,
    score: 94,
    phase2BlockingStatus: 'Lock-in completed. Native iOS would remove ManagedSettings shields.',
    phase3ShieldStatus: 'Shield session ended. Rescue counts remain local for the recap.',
    sheet: 'complete'
  });
}

function recordBypassAttempt() {
  setState({
    bypassAttempts: state.bypassAttempts + 1,
    phase3ShieldStatus: state.hardBlock
      ? 'Hard block recorded the attempt and kept the shield in place.'
      : 'Soft shield recorded the attempt and closed the blocked app.'
  });
}

function emergencyUnlock() {
  if (state.hardBlock) {
    setState({
      bypassAttempts: state.bypassAttempts + 1,
      phase3ShieldStatus: 'Hard block does not expose emergency unlock during an active lock-in.',
      sheet: null
    });
    return;
  }

  window.clearInterval(timerId);
  setState({
    sessionActive: false,
    emergencyUnlocks: state.emergencyUnlocks + 1,
    phase2BlockingStatus: 'Emergency unlock simulated: native iOS would clear ManagedSettings shields.',
    phase3ShieldStatus: 'Emergency unlock recorded locally. Lockd treats this as recovery, not failure.',
    sheet: null
  });
}

function enableProPreview() {
  setState({
    predictiveProtection: true,
    proEntitlement: 'pro',
    phase4InsightStatus: 'StoreKit 2 purchase simulated. currentEntitlements now unlock advanced insights.',
    sheet: null
  });
}

function restorePurchasesPreview() {
  setState({
    proEntitlement: 'pro',
    phase4InsightStatus: 'AppStore.sync and Transaction.currentEntitlements restore simulated.',
    sheet: null
  });
}

function toggleApp(appName) {
  const selected = new Set(state.selectedApps);
  if (selected.has(appName)) {
    selected.delete(appName);
  } else {
    selected.add(appName);
  }
  setState({ selectedApps: [...selected] });
}

function adjustDefaultDuration(delta) {
  const nextDuration = Math.min(180, Math.max(5, state.defaultLockDurationMinutes + delta));
  setState({ defaultLockDurationMinutes: nextDuration });
}

function toggleNotificationPreference(kind) {
  setState({
    notificationPreferences: {
      ...state.notificationPreferences,
      [kind]: !state.notificationPreferences[kind]
    }
  });
}

function openComplianceResource(resourceTitle) {
  const resource = complianceResources.find((item) => item.title === resourceTitle);
  if (resource) {
    setState({ selectedResource: resource, sheet: 'resource' });
  }
}

function openPolicyCenter() {
  setState({ selectedResource: null, sheet: 'policyCenter' });
}

function closeSheet() {
  setState({ selectedResource: null, sheet: null });
}

function renderOnboarding() {
  const step = onboarding[state.onboardingStep];
  return `
    <section class="onboarding">
      <div class="progress-dots" aria-label="Onboarding progress">
        ${onboarding.map((_, index) => `<span class="dot ${index === state.onboardingStep ? 'active' : ''}"></span>`).join('')}
      </div>
      <div>
        <p class="kicker">Lockd</p>
        <h1>${step.title}</h1>
        <p class="subcopy" style="margin-top: 18px">${step.body}</p>
      </div>
      <button class="primary-button" data-action="next-onboarding">${step.button}</button>
    </section>
  `;
}

function renderShell(content) {
  return `
    <section class="screen">
      ${content}
    </section>
    ${renderTabbar()}
    ${renderSheet()}
  `;
}

function renderTopbar(title, subtitle, action = 'settings') {
  return `
    <header class="topbar">
      <div class="title-block">
        <p class="kicker">${subtitle}</p>
        <h1>${title}</h1>
      </div>
      <button class="icon-button" data-action="${action}" aria-label="${action === 'settings' ? 'Settings' : 'Open'}">⚙</button>
    </header>
  `;
}

function renderToday() {
  const lockLabel = state.sessionActive ? 'Protected' : 'Lock In';
  const status = state.sessionActive ? 'Protected mode active' : 'No session active';
  const statusBody = state.sessionActive
    ? 'ManagedSettings shields are active in the iOS build; this localhost preview simulates that state.'
    : state.phase2BlockingStatus;
  const rescueSummary = state.emergencyUnlocks > 0
    ? `${state.emergencyUnlocks} emergency unlock${state.emergencyUnlocks === 1 ? '' : 's'} recorded.`
    : `${state.bypassAttempts} bypass attempt${state.bypassAttempts === 1 ? '' : 's'} paused.`;

  return renderShell(`
    ${renderTopbar('Protect the next block.', 'Today')}
    <article class="panel score-panel">
      <div>
        <p class="score-caption">Focus Score</p>
        <div class="score-number" aria-label="Focus Score ${state.score}">${state.score}</div>
      </div>
      <button class="primary-button" data-action="start-lock">${lockLabel}</button>
    </article>
    <article class="panel">
      <div class="risk-line">
        <div class="label-stack">
          <span class="line-title">9:10 PM - high risk</span>
          <span class="line-subtitle">Why: TikTok opens usually spike here.</span>
        </div>
        <span class="pill risk">Weak spot</span>
      </div>
      <div class="risk-line">
        <div class="label-stack">
          <span class="line-title">Rescue mode ready</span>
          <span class="line-subtitle">A short pause before opening a distracting app.</span>
        </div>
        <button class="ghost-button" data-action="rescue">Open</button>
      </div>
      <div class="risk-line">
        <div class="label-stack">
          <span class="line-title">Shield UX</span>
          <span class="line-subtitle">${state.phase3ShieldStatus}</span>
        </div>
        <span class="pill ${state.hardBlock ? 'risk' : 'info'}">${state.hardBlock ? 'Hard' : 'Soft'}</span>
      </div>
    </article>
    <article class="panel" id="session-panel">
      <div class="metric-line">
        <div class="label-stack">
          <span class="line-title">${status}</span>
          <span class="line-subtitle">${statusBody}</span>
        </div>
        <span class="pill ${state.sessionActive ? 'protected' : ''}">${state.sessionActive ? formatTime(state.secondsLeft) : 'Ready'}</span>
      </div>
      <div class="metric-line">
        <div class="label-stack">
          <span class="line-title">Rescue attempts</span>
          <span class="line-subtitle">${rescueSummary}</span>
        </div>
        <span class="pill">${state.bypassAttempts}</span>
      </div>
      ${state.sessionActive ? '<button class="secondary-button" data-action="complete-session">Finish demo session</button>' : ''}
    </article>
  `);
}

function renderTodayOnly() {
  if (state.tab === 'today' && state.onboarded) {
    render();
  }
}

function renderRules() {
  return renderShell(`
    ${renderTopbar('Rules', `${state.selectedApps.length} apps selected`)}
    <article class="panel">
      <div class="setting-line">
        <div class="label-stack">
          <span class="line-title">FamilyActivityPicker</span>
          <span class="line-subtitle">Native iOS opens Apple's app/category/web-domain picker and saves opaque tokens.</span>
        </div>
        <span class="pill info">Phase 2</span>
      </div>
      <div class="setting-line">
        <div class="label-stack">
          <span class="line-title">Saved Screen Time selection</span>
          <span class="line-subtitle">${state.selectedApps.length} app tokens shown in preview; iPhone uses app-group storage.</span>
        </div>
        <span class="pill protected">${state.selectedApps.length}</span>
      </div>
    </article>
    <article class="panel">
      ${apps.map(([name, symbol]) => `
        <button class="app-line choice ${state.selectedApps.includes(name) ? 'selected' : ''}" data-action="toggle-app" data-app="${name}">
          <span class="label-stack">
            <span class="line-title">${name}</span>
            <span class="line-subtitle">${symbol}</span>
          </span>
          <span class="pill">${state.selectedApps.includes(name) ? 'Selected' : 'Add'}</span>
        </button>
      `).join('')}
    </article>
    <article class="panel">
      <div class="setting-line">
        <div class="label-stack">
          <span class="line-title">Goal</span>
          <span class="line-subtitle">${state.goal}</span>
        </div>
        <span class="pill info">Active</span>
      </div>
      <div class="setting-line">
        <div class="label-stack">
          <span class="line-title">Hard block</span>
          <span class="line-subtitle">Use stricter friction during lock-ins.</span>
        </div>
        <button class="switch ${state.hardBlock ? 'on' : ''}" data-action="toggle-hard" aria-label="Toggle hard block"></button>
      </div>
      <div class="setting-line">
        <div class="label-stack">
          <span class="line-title">Predictive Protection</span>
          <span class="line-subtitle">Unlock automatic weak-spot detection.</span>
        </div>
        <button class="switch ${state.predictiveProtection ? 'on' : ''}" data-action="paywall" aria-label="Open Predictive Protection"></button>
      </div>
    </article>
    <article class="panel">
      <div class="setting-line">
        <div class="label-stack">
          <span class="line-title">ShieldConfiguration</span>
          <span class="line-subtitle">Blocked apps show Lockd copy, color, icon, and button labels.</span>
        </div>
        <span class="pill protected">Wired</span>
      </div>
      <div class="setting-line">
        <div class="label-stack">
          <span class="line-title">ShieldActionDelegate</span>
          <span class="line-subtitle">Primary closes the blocked app; Emergency unlock clears shields only in soft mode.</span>
        </div>
        <span class="pill info">Rescue</span>
      </div>
    </article>
  `);
}

function renderInsights() {
  const advancedLocked = state.proEntitlement !== 'pro';
  const focusScore = state.score + 4;
  const reclaimedHours = state.sessionActive ? 12 : 11;
  const protectedStreak = state.proEntitlement === 'pro' ? 6 : 5;

  return renderShell(`
    ${renderTopbar('Weekly control', 'Insights')}
    <article class="panel">
      <div class="metric-line">
        <span class="line-title">Weekly Focus Score</span>
        <span class="pill protected">${focusScore}</span>
      </div>
      <div class="metric-line">
        <span class="line-title">Time reclaimed</span>
        <span class="pill info">${reclaimedHours}h</span>
      </div>
      <div class="metric-line">
        <span class="line-title">Protected streak</span>
        <span class="pill risk">${protectedStreak}d</span>
      </div>
      <div class="metric-line">
        <div class="label-stack">
          <span class="line-title">DeviceActivityReport</span>
          <span class="line-subtitle">${state.phase4InsightStatus}</span>
        </div>
        <span class="pill ${advancedLocked ? '' : 'protected'}">${advancedLocked ? 'Locked' : 'Pro'}</span>
      </div>
    </article>
    <article class="panel">
      <div class="setting-line">
        <div class="label-stack">
          <span class="line-title">Next weak spot</span>
          <span class="line-subtitle">${advancedLocked ? 'Advanced weak-spot prediction requires Lockd Pro.' : 'Night drift windows are your highest-risk pattern.'}</span>
        </div>
        <button class="ghost-button inline-action" data-action="${advancedLocked ? 'paywall' : 'share'}">${advancedLocked ? 'Unlock' : 'Save'}</button>
      </div>
      <div class="setting-line">
        <div class="label-stack">
          <span class="line-title">StoreKit 2 entitlement</span>
          <span class="line-subtitle">Transaction.currentEntitlements gates predictive protection and advanced insights.</span>
        </div>
        <span class="pill info">${state.proEntitlement}</span>
      </div>
    </article>
    <article class="share-card" aria-label="Share recap preview">
      <p class="kicker">LOCKD RECAP</p>
      <div class="share-score">${focusScore}</div>
      <h2>${reclaimedHours} hours reclaimed</h2>
      <p class="subcopy" style="margin-top: 6px">${protectedStreak}-day protected streak</p>
      <p class="fine-print" style="margin-top: 22px">Private by default. Shared only when you choose.</p>
    </article>
    <div class="button-row">
      <button class="secondary-button" data-action="paywall">Unlock Pro</button>
      <button class="primary-button" data-action="share">Save recap</button>
    </div>
  `);
}

function renderTabbar() {
  const tabs = [
    ['today', '⌂', 'Today'],
    ['rules', '☰', 'Rules'],
    ['insights', '↗', 'Insights']
  ];

  return `
    <nav class="tabbar" aria-label="Primary">
      ${tabs.map(([key, icon, label]) => `
        <button class="tab ${state.tab === key ? 'active' : ''}" data-tab="${key}">
          <span class="symbol">${icon}</span>
          <span>${label}</span>
        </button>
      `).join('')}
    </nav>
  `;
}

function renderSheet() {
  if (!state.sheet) return '';

  const selectedResource = state.selectedResource ?? complianceResources[0];

  const sheets = {
    settings: `
      <h2>Settings</h2>
      <h3 class="sheet-section-title">iPhone Setup</h3>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">Screen Time</span><span class="line-subtitle">${state.screenTimeStatus}</span></span>
        <button class="ghost-button inline-action" data-action="request-screen-time-preview">Request</button>
      </div>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">Phase 2 Blocking</span><span class="line-subtitle">${state.phase2BlockingStatus}</span></span>
        <span class="pill info">ManagedSettings</span>
      </div>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">DeviceActivityMonitor</span><span class="line-subtitle">Scheduled iOS extension clears shields at the end of the lock-in.</span></span>
        <span class="pill protected">Wired</span>
      </div>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">Phase 3 Shield UX</span><span class="line-subtitle">${state.phase3ShieldStatus}</span></span>
        <span class="pill info">ShieldConfiguration</span>
      </div>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">Phase 4 Insights</span><span class="line-subtitle">${state.phase4InsightStatus}</span></span>
        <span class="pill info">DeviceActivityReport</span>
      </div>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">Pro entitlement</span><span class="line-subtitle">StoreKit 2 currentEntitlements controls Pro gates.</span></span>
        <span class="pill ${state.proEntitlement === 'pro' ? 'protected' : ''}">${state.proEntitlement}</span>
      </div>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">Bypass attempts</span><span class="line-subtitle">${state.bypassAttempts} attempt${state.bypassAttempts === 1 ? '' : 's'}, ${state.emergencyUnlocks} emergency unlock${state.emergencyUnlocks === 1 ? '' : 's'}</span></span>
        <span class="pill">Local</span>
      </div>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">Notifications</span><span class="line-subtitle">${state.notificationStatus}</span></span>
        <button class="ghost-button inline-action" data-action="request-notifications-preview">Request</button>
      </div>
      <h3 class="sheet-section-title">Lock defaults</h3>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">Default duration</span><span class="line-subtitle">${state.defaultLockDurationMinutes} minutes</span></span>
        <span class="stepper-control" aria-label="Default duration controls">
          <button class="stepper-button" data-action="decrease-duration" aria-label="Decrease default duration">-</button>
          <button class="stepper-button" data-action="increase-duration" aria-label="Increase default duration">+</button>
        </span>
      </div>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">Hard block</span><span class="line-subtitle">Use stricter friction during lock-ins.</span></span>
        <button class="switch ${state.hardBlock ? 'on' : ''}" data-action="toggle-hard" aria-label="Toggle hard block"></button>
      </div>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">Predictive Protection</span><span class="line-subtitle">Prepare weak-spot warnings for Pro.</span></span>
        <button class="switch ${state.predictiveProtection ? 'on' : ''}" data-action="toggle-predictive-preview" aria-label="Toggle Predictive Protection"></button>
      </div>
      <h3 class="sheet-section-title">Notifications</h3>
      ${notificationOptions.map((option) => `
        <div class="setting-line">
          <span class="label-stack">
            <span class="line-title">${option.title}</span>
            <span class="line-subtitle">${option.subtitle}</span>
          </span>
          <button class="switch ${state.notificationPreferences[option.key] ? 'on' : ''}" data-action="toggle-notification" data-kind="${option.key}" aria-label="Toggle ${option.title}"></button>
        </div>
      `).join('')}
      <h3 class="sheet-section-title">Policies</h3>
      <button class="setting-line legal-row" data-action="policy-center" aria-label="Open Policies & Compliance">
        <span class="label-stack">
          <span class="line-title">Policies & Compliance</span>
          <span class="line-subtitle">Privacy, terms, data rights, accessibility, subscriptions, and safety.</span>
        </span>
        <span class="pill">Open</span>
      </button>
      <button class="secondary-button" data-action="close-sheet">Done</button>
    `,
    policyCenter: `
      <h2>Policies & Compliance</h2>
      <p class="subcopy" style="margin-top: 8px">Review Lockd's policy, privacy, data rights, safety, accessibility, and subscription details.</p>
      ${policySections.map((section) => `
        <h3 class="sheet-section-title">${section.title}</h3>
        ${section.resources.map((resourceTitle) => {
          const resource = complianceResources.find((item) => item.title === resourceTitle);
          return `
            <button class="setting-line legal-row" data-action="resource" data-resource="${resource.title}" aria-label="View ${resource.title}">
              <span class="label-stack">
                <span class="line-title">${resource.title}</span>
                <span class="line-subtitle">${resource.subtitle}</span>
              </span>
              <span class="pill">View</span>
            </button>
          `;
        }).join('')}
      `).join('')}
      <button class="ghost-button" data-action="settings" style="margin-top: 10px">Back to Settings</button>
      <button class="secondary-button" data-action="close-sheet" style="margin-top: 10px">Done</button>
    `,
    resource: `
      <h2>${selectedResource.title}</h2>
      <p class="subcopy" style="margin-top: 8px">${selectedResource.subtitle}</p>
      <div class="panel" style="margin-top: 16px">
        <div class="setting-line">
          <span class="label-stack">
            <span class="line-title">Current v1 stance</span>
            <span class="line-subtitle">Local-first, no tracking, no third-party analytics, and no medical claims.</span>
          </span>
          <span class="pill protected">Active</span>
        </div>
      </div>
      <button class="ghost-button" data-action="policy-center" style="margin-top: 10px">Back to Policies</button>
      <button class="secondary-button" data-action="close-sheet" style="margin-top: 10px">Done</button>
    `,
    paywall: `
      <h2>Unlock Predictive Protection</h2>
      <p class="subcopy" style="margin-top: 8px">Automatic weak-spot detection, unlimited lock-ins, advanced schedules, weekly insight cards, premium recap cards, and challenge packs.</p>
      <div class="panel" style="margin-top: 16px">
        <div class="metric-line"><span class="line-title">$39.99 / year</span><span class="pill protected">7-day trial</span></div>
        <div class="metric-line"><span class="line-title">$5.99 / month</span><span class="pill">Monthly</span></div>
        <div class="metric-line"><span class="line-title">StoreKit 2</span><span class="pill info">Product.products</span></div>
        <div class="metric-line"><span class="line-title">Restore</span><span class="pill info">currentEntitlements</span></div>
      </div>
      <button class="primary-button" data-action="enable-pro" style="margin-top: 14px">Start 7-day trial</button>
      <button class="secondary-button" data-action="restore-pro-preview" style="margin-top: 10px">Restore purchases</button>
      <button class="ghost-button" data-action="close-sheet" style="margin-top: 10px">Maybe later</button>
    `,
    rescue: `
      <h2>Protected by Lockd</h2>
      <p class="subcopy" style="margin-top: 8px">This ShieldConfiguration preview mirrors the native blocked-app screen. This is a decision point, not a shame wall.</p>
      <div class="panel" style="margin-top: 16px">
        <div class="metric-line"><span class="line-title">Mode</span><span class="pill ${state.hardBlock ? 'risk' : 'info'}">${state.hardBlock ? 'Hard block' : 'Soft friction'}</span></div>
        <div class="metric-line"><span class="line-title">Bypass attempts</span><span class="pill">${state.bypassAttempts}</span></div>
      </div>
      <div class="button-row" style="margin-top: 16px">
        <button class="secondary-button" data-action="emergency-unlock-preview">Emergency unlock</button>
        <button class="primary-button" data-action="record-bypass">Back to Lockd</button>
      </div>
    `,
    complete: `
      <h2>Session protected</h2>
      <p class="subcopy" style="margin-top: 8px">You reclaimed this block. Focus Score moved up.</p>
      <div class="score-number" style="font-size: 4rem; margin: 14px 0">+12</div>
      <button class="primary-button" data-action="close-sheet">Keep going</button>
    `,
    share: `
      <h2>Recap saved</h2>
      <p class="subcopy" style="margin-top: 8px">Your recap is private until you choose to share it.</p>
      <button class="primary-button" data-action="close-sheet" style="margin-top: 16px">Done</button>
    `
  };

  return `
    <div class="sheet-backdrop" data-action="close-sheet">
      <section class="sheet" role="dialog" aria-modal="true" onclick="event.stopPropagation()">
        ${sheets[state.sheet]}
      </section>
    </div>
  `;
}

function render() {
  if (!state.onboarded) {
    app.innerHTML = renderOnboarding();
    return;
  }

  if (state.tab === 'rules') {
    app.innerHTML = renderRules();
    return;
  }

  if (state.tab === 'insights') {
    app.innerHTML = renderInsights();
    return;
  }

  app.innerHTML = renderToday();
}

document.addEventListener('click', (event) => {
  const tab = event.target.closest('[data-tab]');
  if (tab) {
    setState({ tab: tab.dataset.tab });
    return;
  }

  const actionTarget = event.target.closest('[data-action]');
  if (!actionTarget) return;

  const action = actionTarget.dataset.action;
  if (action === 'next-onboarding') nextOnboarding();
  if (action === 'settings') setState({ sheet: 'settings' });
  if (action === 'policy-center') openPolicyCenter();
  if (action === 'request-screen-time-preview') {
    setState({
      screenTimeStatus: 'Requires real iPhone and Family Controls',
      phase2BlockingStatus: 'FamilyActivityPicker, ManagedSettings, and DeviceActivityMonitor are native-only.'
    });
  }
  if (action === 'request-notifications-preview') setState({ notificationStatus: 'Allowed in preview' });
  if (action === 'increase-duration') adjustDefaultDuration(5);
  if (action === 'decrease-duration') adjustDefaultDuration(-5);
  if (action === 'start-lock') startLockIn();
  if (action === 'complete-session') completeSession();
  if (action === 'rescue') setState({ sheet: 'rescue' });
  if (action === 'record-bypass') recordBypassAttempt();
  if (action === 'emergency-unlock-preview') emergencyUnlock();
  if (action === 'toggle-hard') {
    setState({
      hardBlock: !state.hardBlock,
      phase3ShieldStatus: !state.hardBlock
        ? 'Hard shield mode saved. Emergency unlock becomes a breathing pause.'
        : 'Soft shield mode saved. Emergency unlock can clear shields.'
    });
  }
  if (action === 'toggle-predictive-preview') setState({ predictiveProtection: !state.predictiveProtection });
  if (action === 'paywall') setState({ sheet: 'paywall' });
  if (action === 'enable-pro') enableProPreview();
  if (action === 'restore-pro-preview') restorePurchasesPreview();
  if (action === 'share') setState({ sheet: 'share' });
  if (action === 'resource') openComplianceResource(actionTarget.dataset.resource);
  if (action === 'toggle-notification') toggleNotificationPreference(actionTarget.dataset.kind);
  if (action === 'close-sheet') closeSheet();
  if (action === 'toggle-app') toggleApp(actionTarget.dataset.app);
});

render();
