# Lockd iOS Design Spec

## Summary

Lockd is an iOS-native dopamine detox and focus app for users who want help stopping distraction before it starts. The acquisition tone is competitive: "lock in before the weak spot hits." The in-app tone is balanced: calm control, clear prediction, and recovery without shame.

The first build target is native SwiftUI. The app should be architected for Apple's Screen Time technology stack: Family Controls, DeviceActivity, and ManagedSettings. Development should use mock Screen Time adapters until entitlement and device integration are ready.

## Approved Direction

Build an iOS-native SwiftUI MVP with a beautiful mocked vertical slice first. The architecture should be real, but early screens can run on mock Screen Time data while entitlement work proceeds.

This means:

- SwiftUI app structure from day one.
- Protocol-based adapters for app selection, blocking, device activity, and prediction inputs.
- Local-first storage for sessions, app selections, rules, scores, weak-spot windows, challenges, and recap data.
- Mock adapters in development and tests.
- Real Screen Time integrations behind the same interfaces when entitlements are available.

## Product Model

Lockd has three primary tabs.

### Today

Today is the command center. It shows the current Focus Score, the next predicted weak spot, the primary Lock In action, active session state, and recovery actions.

Required states:

- No session yet today.
- Predicted weak spot upcoming.
- Session starting.
- Session active.
- Session complete.
- Session interrupted or bypass attempted.
- Screen Time permissions missing.
- Screen Time entitlement unavailable in the current build.

Primary actions:

- Start lock-in.
- Extend active session.
- End session where allowed.
- Start rescue mode after attempted bypass.
- View why a weak spot was predicted.

### Rules

Rules is practical and quiet. Users manage app selections, schedules, hard block versus soft friction, and Predictive Protection.

Required states:

- No apps selected.
- Apps selected.
- Hard block schedule configured.
- Soft friction configured.
- Predictive Protection locked behind Pro.
- Permission missing.
- Screen Time selection unavailable in simulator or mock mode.

Primary actions:

- Choose distracting apps.
- Set goal.
- Set schedule.
- Choose friction level.
- Enable Predictive Protection.

### Insights

Insights is where competitive energy lives. It contains daily and weekly Focus Score, streaks, weak-spot patterns, time reclaimed, challenge progress, and shareable recap cards.

Required states:

- No data yet.
- First session complete.
- Daily summary.
- Weekly summary.
- Challenge active.
- Share card preview.

Primary actions:

- Open daily score details.
- Open weak-spot pattern explanation.
- Start a challenge.
- Generate share recap.
- Save or share recap.

Settings should be secondary and reachable from the tab header, not a fourth primary tab.

## Onboarding

Onboarding should deliver value before asking for everything.

### Step 1: Hook

Opening promise:

"Your weak spots are predictable. Lockd helps you stop before the scroll starts."

Primary action:

"Find my weak spots"

### Step 2: Choose Apps

Ask the user to choose three distracting apps first. The app list can include TikTok, Instagram, YouTube, X, Reddit, Safari, and a custom selection flow through Family Controls when available.

### Step 3: Choose Goal

Goal presets:

- Cut brain rot.
- Study without folding.
- Sleep without scrolling.
- Monk Mode challenge.
- Custom.

### Step 4: First Quick Lock

Start a short 10-minute lock-in demo before heavy setup. The first emotional reward is "I am protected now."

### Step 5: Permission Ladder

After the first win, ask for Screen Time access with plain copy:

"Lockd needs Screen Time access to block the apps you chose. Your app choices stay on-device."

### Step 6: Paywall

Do not paywall before setup. Paywall after the user has seen:

- Selected apps.
- Weak Spot Preview.
- Focus Score preview.
- First lock-in outcome.

Pro offer:

"Unlock Predictive Protection"

Pro features:

- Automatic weak-spot detection.
- Unlimited lock-ins.
- Advanced schedules.
- Weekly insight cards.
- Premium recap cards.
- Challenge packs.

Initial pricing to test:

- $5.99 monthly.
- $39.99 yearly.
- 7-day free trial.
- Yearly selected by default, with a clear monthly option.

## Marketing And Product Tone

Marketing tone is competitive. Product tone is balanced.

Marketing examples:

- "Your phone knows when you are about to fold."
- "Stop losing 4 hours a day to brain rot."
- "Lock in before the weak spot hits."
- "7-day Monk Mode. See your Focus Score climb."
- "Your 9 PM scroll spiral is predictable."

In-app examples:

- "Weak spot" instead of "relapse."
- "Drift window" instead of "failure."
- "Protect this hour" instead of "do not fold."
- "Recover the streak" instead of "you lost."

The product should never humiliate the user. It should create identity momentum without creating shame.

## Habit Loop

Trigger: predicted weak spot, scheduled lock-in, challenge reminder, or user intent.

Action: start lock-in, accept soft friction, choose rescue mode, or adjust rules.

Variable reward: protected time, Focus Score lift, streak preservation, insight discovery, recap card.

Investment: selected apps, schedules, goals, challenge progress, weak-spot learning, recap history.

Ethics requirements:

- Focus Score is private by default.
- Sharing is opt-in.
- The app explains why a weak spot was predicted.
- Users can pause or change rules without dark patterns.
- Notifications must be useful, sparse, and tied to user goals.
- Failure copy must route to recovery.

## Visual Language

Lockd should feel like a premium iOS control system.

Base:

- Dark-first graphite and near-black surfaces.
- Strong contrast.
- Clean native typography.
- No generic AI-purple gradient treatment.
- No gamer neon overload.

Accent system:

- Electric green for protected focus and successful sessions.
- Red or orange for weak-spot risk.
- Cool blue for insights and calm informational states.

Shape:

- Native iOS radius language.
- Large touch targets.
- No over-rounded cards.
- Clear hierarchy between controls, sheets, and content.

Surface philosophy:

- Today can feel cinematic but not busy.
- Rules should be restrained and practical.
- Insights can be more expressive because it is where scores and share cards live.

## Motion And Interaction

Motion should communicate feedback, state change, hierarchy, or a score moment. It should not exist only to look fancy.

Core motion:

- Lock In button compresses instantly on press with haptic feedback.
- Session starts with a ring tightening into protected mode.
- Focus Score counts up after a completed session.
- Weak-spot warning slides in from the top, not as a blocking modal.
- Share card animates into a screenshot-ready layout.
- Paywall feature rows reveal with a short stagger.

Timing:

- Button feedback: 100-160 ms.
- Small transitions: 150-250 ms.
- Bottom sheets and larger state changes: 200-300 ms.
- Avoid long repeated animations in core workflows.

Reduced motion:

- No breathing expansion loops.
- No score spinning.
- No animated background.
- Prefer fades and instant state changes.

All interactive controls need default, pressed, loading, disabled, success, error where applicable, and VoiceOver labels.

## Signature Features

### Weak Spot Radar

A Today screen module that shows the next likely drift window:

- "9:10 PM - high risk"
- "Why: TikTok opens usually spike here"

The module should make prediction feel explainable and worth paying for.

### Rescue Mode

If the user tries to bypass or hits soft friction, Lockd offers a short recovery action:

- 10-second pause.
- Open anyway.
- Start 15-minute lock-in.
- Remind me after this session.

Rescue Mode is not a shame wall. It is a decision point.

### Weak Spot Preview

During onboarding, show:

"Most people lose control at night. Lockd will learn your pattern after 2 days."

This previews the predictor before enough personal data exists.

### Monk Mode Beta

Test a 7-day Monk Mode Beta as the trial wrapper. It should feel like a challenge rather than a generic subscription trap.

## Architecture Boundaries

The codebase should separate:

- UI screens and components.
- Domain models.
- Local persistence.
- Prediction logic.
- Screen Time adapters.
- Paywall and entitlement logic.
- Share card rendering.

Every Screen Time capability should sit behind a protocol so tests and preview builds can use mock adapters.

Suggested modules:

- `LockdApp`
- `Today`
- `Rules`
- `Insights`
- `Onboarding`
- `Paywall`
- `Domain`
- `Prediction`
- `ScreenTimeAdapters`
- `Persistence`
- `DesignSystem`

## Data Model

Initial local entities:

- App selection token references where available.
- Distracting app display metadata.
- Goal preset and custom goal.
- Lock-in session.
- Friction rule.
- Schedule.
- Weak spot window.
- Focus score snapshot.
- Challenge.
- Share recap.
- Paywall entitlement state.

Focus Score formula for v1:

```text
adherence = honored lock-in minutes / intended lock-in minutes
goalRate = min(goal app minutes under goal / goal app minutes target, 1)
sessionRate = sessions completed / sessions started
focusScore = round(100 * (0.5 * adherence + 0.3 * goalRate + 0.2 * sessionRate))
```

The implementation should handle zero-session and zero-goal cases explicitly.

## Prediction V1

Prediction should be local and statistical first.

Inputs:

- Hour of day.
- Day of week.
- Recent app open attempts.
- Session completions and interruptions.
- Soft friction outcomes.
- Goal context.

Output:

- Weak spot windows.
- Risk level.
- Human-readable explanation.

The predictor should not require a network call. LLM-style nudges are deferred. Templated copy is enough for v1.

## Testing And QA

Implementation must follow TDD for domain and behavior changes.

Required test areas:

- Focus Score edge cases.
- Prediction bucket behavior.
- Rules state transitions.
- Session lifecycle.
- Paywall entitlement gating.
- Share card data formatting.
- Permission and unavailable entitlement states.

Visual QA targets:

- iPhone SE-sized layout.
- Standard iPhone layout.
- Large iPhone layout.
- Dynamic Type.
- VoiceOver labels.
- Reduced motion.
- Dark contrast.
- No clipping, overlap, or misaligned controls.
- No broken button states.

## Operational Risks

Apple Family Controls entitlement is a real launch gate. The team should apply early and plan for development mocks.

Distribution may require approval for app extensions as well as the main app. App IDs, provisioning profiles, entitlements, and extension bundle IDs should be treated as release-critical.

React Native and web wrappers are not the first build target because the core promise requires native iOS Screen Time APIs.

## References

- Apple Family Controls configuration: https://developer.apple.com/documentation/xcode/configuring-family-controls
- Apple Screen Time technology frameworks: https://developer.apple.com/documentation/screentimeapidocumentation
- Apple Family Controls documentation: https://developer.apple.com/documentation/familycontrols
- Opal positioning reference: https://www.opal.so/
- one sec positioning reference: https://one-sec.app/
