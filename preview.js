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
  onboardingAnswers: {},
  onboardingAppTargetIds: [],
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

const onboardingQuestions = [
  {
    id: 'outcome',
    title: 'What are you trying to get back?',
    body: 'Name the thing that will feel better when scrolling stops.',
    options: [
      ['sleep', 'Sleep', 'Stop the late-night loop.'],
      ['grades', 'Grades & studying', 'Stay with the work longer.'],
      ['deep-work', 'Deep work', 'Protect serious focus blocks.'],
      ['real-life', 'Real life', 'More time with people and plans.'],
      ['self-control', 'Self-control', 'Break the reflex open.'],
      ['health', 'Gym or health', 'Keep energy for your body.']
    ]
  },
  {
    id: 'trigger',
    title: 'What usually starts the spiral?',
    body: 'This helps Lockd frame the first intervention around your real trigger.',
    options: [
      ['boredom', 'Boredom', 'Nothing to do turns into a scroll.'],
      ['stress', 'Stress', 'You escape when pressure spikes.'],
      ['notifications', 'Notifications', 'One ping pulls you out.'],
      ['one-video', 'Just one video', 'The first hit becomes a session.'],
      ['avoidance', 'Avoiding work', 'Scrolling becomes delay mode.'],
      ['autopilot', 'Late-night autopilot', 'You open apps before thinking.']
    ]
  },
  {
    id: 'weakSpot',
    title: 'When are you easiest to break?',
    body: 'Choose the window where Lockd should watch for weak spots first.',
    options: [
      ['morning-bed', 'Morning in bed', 'Before the day gets moving.'],
      ['class-work', 'During class or work', 'When attention starts leaking.'],
      ['after-dinner', 'After dinner', 'The couch-scroll danger zone.'],
      ['before-sleep', 'Before sleep', 'The last scroll stretches out.'],
      ['weekends', 'Weekends', 'Unstructured time gets loud.'],
      ['alone', "Whenever I'm alone", 'Quiet moments turn into feeds.']
    ]
  },
  {
    id: 'apps',
    title: 'What do you lose the most time to?',
    body: 'Choose every category that fits. On iPhone you can choose any apps, categories, and websites with Screen Time.',
    options: [],
    allowsMultipleSelection: true
  },
  {
    id: 'strictness',
    title: 'How aggressive should Lockd be?',
    body: 'Pick the level of friction you will actually respect.',
    options: [
      ['gentle', 'Gentle pause', 'A short reset before opening.'],
      ['normal', 'Normal lock', 'Protect selected targets during a lock-in.'],
      ['hard', 'Hard block', 'No easy exits during protected time.'],
      ['monk', 'Monk Mode', 'Go strict for serious resets.']
    ]
  },
  {
    id: 'firstBlock',
    title: 'What should your first protected block be?',
    body: 'Lockd will turn this into your first recommended schedule.',
    options: [
      ['focus-25', '25 min focus', 'Quick lock-in, low friction.'],
      ['study-45', '45 min study', 'A classwork-sized session.'],
      ['deep-90', '90 min deep work', 'Long enough to get serious.'],
      ['bedtime', 'Bedtime lock', 'Protect sleep before it slips.'],
      ['morning', 'Morning lock', 'Start without feeds.'],
      ['weekend', 'Weekend reset', 'Block the drift when time is loose.']
    ]
  }
];

const appTargetGroups = [
  {
    id: 'short-video',
    title: 'Short video',
    subtitle: 'Fast reward loops and algorithmic feeds.',
    options: [
      ['tiktok', 'TikTok', 'For You Page.', 'music.note'],
      ['youtube-shorts', 'YouTube Shorts', 'Shorts feed.', 'play.rectangle'],
      ['instagram-reels', 'Instagram Reels', 'Reels and Explore.', 'camera'],
      ['snapchat-spotlight', 'Snapchat Spotlight', 'Spotlight videos.', 'bolt'],
      ['facebook-reels', 'Facebook Reels', 'Reels feed.', 'person.3'],
      ['twitch', 'Twitch', 'Streams and clips.', 'play.tv'],
      ['kick', 'Kick', 'Live streams.', 'bolt.fill']
    ]
  },
  {
    id: 'social-feeds',
    title: 'Social feeds',
    subtitle: 'Feeds, comments, trends, and rabbit holes.',
    options: [
      ['instagram', 'Instagram', 'Stories, feed, explore.', 'camera'],
      ['reddit', 'Reddit', 'Threads and communities.', 'bubble.left'],
      ['x', 'X', 'Timeline and trends.', 'xmark'],
      ['threads', 'Threads', 'Text social feed.', 'at'],
      ['facebook', 'Facebook', 'Feed and groups.', 'person.3'],
      ['pinterest', 'Pinterest', 'Idea rabbit holes.', 'pin'],
      ['tumblr', 'Tumblr', 'Blogs and fandoms.', 'text.bubble'],
      ['bluesky', 'Bluesky', 'Social timeline.', 'cloud'],
      ['lemon8', 'Lemon8', 'Lifestyle feed.', 'leaf']
    ]
  },
  {
    id: 'messaging',
    title: 'Messaging pull',
    subtitle: 'Apps that turn one reply into a loop.',
    options: [
      ['discord', 'Discord', 'Servers and DMs.', 'bubble.left.and.bubble.right'],
      ['snapchat', 'Snapchat', 'Streaks and stories.', 'camera.viewfinder'],
      ['whatsapp', 'WhatsApp', 'Chats and groups.', 'phone.bubble'],
      ['messenger', 'Messenger', 'DMs and calls.', 'message'],
      ['telegram', 'Telegram', 'Channels and chats.', 'paperplane'],
      ['imessage', 'iMessage', 'Text threads.', 'message.fill']
    ]
  },
  {
    id: 'streaming',
    title: 'Streaming',
    subtitle: 'Long-form video and binge sessions.',
    options: [
      ['youtube', 'YouTube', 'Videos and recommendations.', 'play.rectangle'],
      ['netflix', 'Netflix', 'Shows and autoplay.', 'tv'],
      ['hulu', 'Hulu', 'TV episodes.', 'tv'],
      ['disney', 'Disney+', 'Movies and shows.', 'sparkles'],
      ['prime-video', 'Prime Video', 'Streaming library.', 'play.tv'],
      ['max', 'Max', 'Shows and movies.', 'movieclapper'],
      ['crunchyroll', 'Crunchyroll', 'Anime episodes.', 'play.square.stack']
    ]
  },
  {
    id: 'dating',
    title: 'Dating',
    subtitle: 'Swipe loops and check-backs.',
    options: [
      ['tinder', 'Tinder', 'Swipe sessions.', 'flame'],
      ['hinge', 'Hinge', 'Profiles and messages.', 'heart'],
      ['bumble', 'Bumble', 'Matches and chats.', 'sparkles']
    ]
  },
  {
    id: 'shopping-food',
    title: 'Shopping & food',
    subtitle: 'Impulse browsing and delivery loops.',
    options: [
      ['amazon', 'Amazon', 'Browsing and deals.', 'cart'],
      ['temu', 'Temu', 'Deals feed.', 'tag'],
      ['shein', 'Shein', 'Shopping feed.', 'bag'],
      ['doordash', 'DoorDash', 'Food delivery.', 'takeoutbag.and.cup.and.straw'],
      ['uber-eats', 'Uber Eats', 'Food delivery.', 'fork.knife']
    ]
  },
  {
    id: 'browsers-web',
    title: 'Browsers & web',
    subtitle: 'Search loops and websites you want blocked.',
    options: [
      ['safari', 'Safari', 'Web browsing.', 'safari'],
      ['chrome', 'Chrome', 'Web browsing.', 'globe'],
      ['google', 'Google', 'Search loops.', 'magnifyingglass'],
      ['reddit-web', 'Reddit web', 'Browser rabbit holes.', 'network'],
      ['adult-websites', 'Adult websites', 'Web domains.', 'shield']
    ]
  },
  {
    id: 'games',
    title: 'Games',
    subtitle: 'Matches, quests, streaks, and daily rewards.',
    options: [
      ['roblox', 'Roblox', 'Games and worlds.', 'gamecontroller'],
      ['clash-royale', 'Clash Royale', 'Matches and chests.', 'crown'],
      ['brawl-stars', 'Brawl Stars', 'Quick matches.', 'star'],
      ['fortnite', 'Fortnite', 'Matches and quests.', 'scope'],
      ['cod-mobile', 'Call of Duty Mobile', 'Ranked matches.', 'target'],
      ['pokemon-go', 'Pokemon GO', 'Walks and raids.', 'mappin.and.ellipse']
    ]
  }
];

const apps = appTargetGroups.flatMap((group) => group.options.map(([, title, , symbol]) => [title, symbol]));

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
  if (state.onboardingStep === onboardingQuestions.length) {
    setState({ onboarded: true });
    return;
  }

  const question = onboardingQuestions[state.onboardingStep];
  if (question.allowsMultipleSelection) {
    if (state.onboardingAppTargetIds.length === 0) return;
    setState({ onboardingStep: state.onboardingStep + 1 });
    return;
  }

  if (!state.onboardingAnswers[question.id]) return;

  setState({ onboardingStep: state.onboardingStep + 1 });
}

function selectOnboardingAnswer(questionID, answerID) {
  const question = onboardingQuestions.find((item) => item.id === questionID);
  const answer = question?.options.find(([id]) => id === answerID);
  if (!answer) return;

  setState({
    onboardingAnswers: {
      ...state.onboardingAnswers,
      [questionID]: {
        id: answer[0],
        title: answer[1],
        subtitle: answer[2]
      }
    }
  });
}

function selectOnboardingAppTarget(answerID) {
  const selected = new Set(state.onboardingAppTargetIds);
  if (selected.has(answerID)) {
    selected.delete(answerID);
  } else {
    selected.add(answerID);
  }

  setState({ onboardingAppTargetIds: [...selected] });
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
  const totalSteps = onboardingQuestions.length + 1;
  const isPlanStep = state.onboardingStep === onboardingQuestions.length;

  if (isPlanStep) {
    const rows = onboardingPlanRows();
    return `
      <section class="onboarding">
        <div class="progress-dots" aria-label="Onboarding progress">
          ${Array.from({ length: totalSteps }, (_, index) => `<span class="dot ${index === state.onboardingStep ? 'active' : ''}"></span>`).join('')}
        </div>
        <div class="onboarding-scroll">
          <div>
            <p class="kicker">Lockd</p>
            <h1>Your Lockd setup is ready</h1>
            <p class="subcopy" style="margin-top: 14px">Lockd will start with the pattern you named, then use Apple's Screen Time picker so you can select exact apps, categories, and web domains on iPhone.</p>
          </div>
          <div class="choice-grid">
            ${rows.map((row) => `
              <div class="choice selected">
                <span class="label-stack">
                  <span class="line-title">${row.title}</span>
                  <span class="line-subtitle">${row.subtitle}</span>
                </span>
                <span class="pill protected">Ready</span>
              </div>
            `).join('')}
          </div>
        </div>
        <div class="onboarding-footer">
          <button class="primary-button" data-action="next-onboarding">Start 7-day trial</button>
        </div>
      </section>
    `;
  }

  const step = onboardingQuestions[state.onboardingStep];
  const selected = state.onboardingAnswers[step.id]?.id;
  const appSelectionCount = state.onboardingAppTargetIds.length;
  const canAdvance = step.allowsMultipleSelection ? appSelectionCount > 0 : Boolean(selected);
  const actionLabel = canAdvance ? 'Next' : step.allowsMultipleSelection ? 'Choose at least one' : 'Choose one';

  return `
    <section class="onboarding">
      <div class="progress-dots" aria-label="Onboarding progress">
        ${Array.from({ length: totalSteps }, (_, index) => `<span class="dot ${index === state.onboardingStep ? 'active' : ''}"></span>`).join('')}
      </div>
      <div class="onboarding-scroll">
        <div>
          <p class="kicker">Lockd</p>
          <h1>${step.title}</h1>
          <p class="subcopy" style="margin-top: 14px">${step.body}</p>
        </div>
        <div class="choice-grid">
          ${step.allowsMultipleSelection ? renderOnboardingAppTargets() : step.options.map(([id, title, subtitle]) => `
              <button class="choice ${selected === id ? 'selected' : ''}" data-action="select-onboarding-answer" data-question="${step.id}" data-answer="${id}">
                <span class="label-stack">
                  <span class="line-title">${title}</span>
                  <span class="line-subtitle">${subtitle}</span>
                </span>
                <span class="pill">${selected === id ? 'Selected' : 'Pick'}</span>
              </button>
            `).join('')}
        </div>
      </div>
      <div class="onboarding-footer">
        <button class="primary-button" data-action="next-onboarding">${actionLabel}</button>
      </div>
    </section>
  `;
}

function renderOnboardingAppTargets() {
  const selected = new Set(state.onboardingAppTargetIds);

  return `
    <div class="selection-summary">
      <span class="label-stack">
        <span class="line-title">${state.onboardingAppTargetIds.length} selected</span>
        <span class="line-subtitle">${selectedAppTargetSummary()}</span>
      </span>
    </div>
    ${appTargetGroups.map((group, index) => {
      const selectedInGroup = group.options.filter(([id]) => selected.has(id)).length;
      const shouldOpen = index < 2 || selectedInGroup > 0;
      return `
    <details class="app-choice-group" ${shouldOpen ? 'open' : ''}>
      <summary class="app-choice-heading">
        <span class="label-stack">
          <span class="line-title">${group.title}</span>
          <span class="line-subtitle">${group.subtitle}</span>
        </span>
        <span class="pill ${selectedInGroup > 0 ? 'protected' : ''}">${selectedInGroup}</span>
      </summary>
      <div class="choice-grid compact">
        ${group.options.map(([id, title, subtitle]) => `
          <button class="choice ${selected.has(id) ? 'selected' : ''}" data-action="select-onboarding-app-target" data-answer="${id}">
            <span class="label-stack">
              <span class="line-title">${title}</span>
              <span class="line-subtitle">${subtitle}</span>
            </span>
            <span class="pill">${selected.has(id) ? 'Selected' : 'Add'}</span>
          </button>
        `).join('')}
      </div>
    </details>
  `;
    }).join('')}
  `;
}

function onboardingPlanRows() {
  return [
    ['What you want back', state.onboardingAnswers.outcome?.title ?? 'Protect attention'],
    ['Spiral trigger', state.onboardingAnswers.trigger?.title ?? 'Your main trigger'],
    ['Weak spot window', state.onboardingAnswers.weakSpot?.title ?? 'Your highest-risk time'],
    ['First targets', selectedAppTargetSummary()],
    ['Protection level', state.onboardingAnswers.strictness?.title ?? 'Normal lock'],
    ['First lock', state.onboardingAnswers.firstBlock?.title ?? '25 min focus']
  ].map(([title, subtitle]) => ({ title, subtitle }));
}

function selectedAppTargetSummary() {
  const titles = appTargetGroups
    .flatMap((group) => group.options)
    .filter(([id]) => state.onboardingAppTargetIds.includes(id))
    .map(([, title]) => title);

  if (titles.length === 0) return 'Choose apps with Screen Time';
  if (titles.length <= 3) return titles.join(', ');
  return `${titles.slice(0, 3).join(', ')} + ${titles.length - 3} more`;
}

function renderRequiredPaywall() {
  return `
    <section class="screen">
      <div class="topbar">
        <div class="title-block">
          <p class="kicker">Trial required</p>
          <h1>Your Lockd plan is ready</h1>
        </div>
      </div>
      <article class="panel">
        <p class="subcopy">Start with 7 days free. Then Lockd protects selected apps, weak spots, schedules, insight cards, rescue mode, and recap cards with one subscription.</p>
        <div class="metric-line"><span class="line-title">$39.99 / year</span><span class="pill protected">7-day trial</span></div>
        <div class="metric-line"><span class="line-title">$5.99 / month</span><span class="pill">Monthly</span></div>
        <div class="metric-line"><span class="line-title">Subscription terms</span><span class="line-subtitle">7 days free, then your selected App Store plan renews automatically unless cancelled at least 24 hours before renewal.</span></div>
      </article>
      <button class="primary-button" data-action="enable-pro" style="margin-top: 14px">Start 7-day trial</button>
      <button class="secondary-button" data-action="restore-pro-preview" style="margin-top: 10px">Restore purchases</button>
      <button class="ghost-button" data-action="policy-center" style="margin-top: 10px">Terms and privacy</button>
      ${renderSheet()}
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
      <div class="setting-line">
        <div class="label-stack">
          <span class="line-title">Popular preview targets</span>
          <span class="line-subtitle">The real iPhone picker can choose any installed apps, categories, and websites; this preview shows common targets.</span>
        </div>
      </div>
      ${renderRulesAppTargetGroups()}
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

function renderRulesAppTargetGroups() {
  return appTargetGroups.map((group) => `
    <section class="app-choice-group" aria-label="${group.title}">
      <div class="app-choice-heading">
        <span class="line-title">${group.title}</span>
        <span class="line-subtitle">${group.subtitle}</span>
      </div>
      <div class="choice-grid compact">
        ${group.options.map(([, name, subtitle, symbol]) => `
          <button class="app-line choice ${state.selectedApps.includes(name) ? 'selected' : ''}" data-action="toggle-app" data-app="${name}">
            <span class="label-stack">
              <span class="line-title">${name}</span>
              <span class="line-subtitle">${subtitle} ${symbol}</span>
            </span>
            <span class="pill">${state.selectedApps.includes(name) ? 'Selected' : 'Add'}</span>
          </button>
        `).join('')}
      </div>
    </section>
  `).join('');
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
        <span class="label-stack">
          <span class="line-title">Why Lockd needs Screen Time</span>
          <span class="line-subtitle">Lockd uses Apple's Screen Time permission to protect only the apps, categories, and websites you select.</span>
        </span>
      </div>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">Screen Time</span><span class="line-subtitle">${state.screenTimeStatus}</span></span>
        <button class="ghost-button inline-action" data-action="request-screen-time-preview">Request</button>
      </div>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">Notifications</span><span class="line-subtitle">${state.notificationStatus}</span></span>
        <button class="ghost-button inline-action" data-action="request-notifications-preview">Request</button>
      </div>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">Open iPhone Settings</span><span class="line-subtitle">Use this if Screen Time or notifications were denied.</span></span>
        <button class="ghost-button inline-action" data-action="request-screen-time-preview">Open</button>
      </div>
      <h3 class="sheet-section-title">Protection Defaults</h3>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">Screen Time app blocking</span><span class="line-subtitle">${state.phase2BlockingStatus}</span></span>
        <span class="pill info">ManagedSettings</span>
      </div>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">Private app selections</span><span class="line-subtitle">FamilyActivityPicker stores opaque Screen Time tokens instead of readable app lists.</span></span>
        <span class="pill protected">Private</span>
      </div>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">Shield screen</span><span class="line-subtitle">${state.phase3ShieldStatus}</span></span>
        <span class="pill info">Shield UX</span>
      </div>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">Weekly insights</span><span class="line-subtitle">${state.phase4InsightStatus}</span></span>
        <span class="pill info">Reports</span>
      </div>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">Default lock duration</span><span class="line-subtitle">${state.defaultLockDurationMinutes} minutes</span></span>
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
      <h3 class="sheet-section-title">Notification Preferences</h3>
      ${notificationOptions.map((option) => `
        <div class="setting-line">
          <span class="label-stack">
            <span class="line-title">${option.title}</span>
            <span class="line-subtitle">${option.subtitle}</span>
          </span>
          <button class="switch ${state.notificationPreferences[option.key] ? 'on' : ''}" data-action="toggle-notification" data-kind="${option.key}" aria-label="Toggle ${option.title}"></button>
        </div>
      `).join('')}
      <h3 class="sheet-section-title">Account & Legal</h3>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">Subscription & purchases</span><span class="line-subtitle">StoreKit 2 currentEntitlements controls Pro gates.</span></span>
        <span class="pill ${state.proEntitlement === 'pro' ? 'protected' : ''}">${state.proEntitlement}</span>
      </div>
      <button class="setting-line legal-row" data-action="policy-center" aria-label="Open Policies & Compliance">
        <span class="label-stack">
          <span class="line-title">Policies & Compliance</span>
          <span class="line-subtitle">Privacy, terms, data rights, accessibility, subscriptions, and safety.</span>
        </span>
        <span class="pill">Open</span>
      </button>
      <div class="setting-line">
        <span class="label-stack"><span class="line-title">Local activity</span><span class="line-subtitle">${state.bypassAttempts} bypass attempt${state.bypassAttempts === 1 ? '' : 's'}, ${state.emergencyUnlocks} emergency unlock${state.emergencyUnlocks === 1 ? '' : 's'} in this preview.</span></span>
        <span class="pill">Local</span>
      </div>
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
        <div class="metric-line"><span class="line-title">Trial terms</span><span class="line-subtitle">7 days free, then your selected App Store plan renews automatically unless cancelled at least 24 hours before renewal.</span></div>
        <div class="metric-line"><span class="line-title">StoreKit 2</span><span class="pill info">Product.products</span></div>
        <div class="metric-line"><span class="line-title">Restore</span><span class="pill info">currentEntitlements</span></div>
      </div>
      <button class="primary-button" data-action="enable-pro" style="margin-top: 14px">Start 7-day trial</button>
      <button class="secondary-button" data-action="restore-pro-preview" style="margin-top: 10px">Restore purchases</button>
      <button class="ghost-button" data-action="close-sheet" style="margin-top: 10px">Close</button>
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

  if (state.proEntitlement !== 'pro') {
    app.innerHTML = renderRequiredPaywall();
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
  if (action === 'select-onboarding-answer') selectOnboardingAnswer(actionTarget.dataset.question, actionTarget.dataset.answer);
  if (action === 'select-onboarding-app-target') selectOnboardingAppTarget(actionTarget.dataset.answer);
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
