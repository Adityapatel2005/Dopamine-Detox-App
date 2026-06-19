# Lockd Visual QA

Run these checks on macOS with Xcode after generating `Lockd.xcodeproj`.

## Build

- Generate project: `xcodegen generate`
- Run tests: `xcodebuild test -project Lockd.xcodeproj -scheme Lockd -destination 'platform=iOS Simulator,name=iPhone 16'`
- Run app: open `Lockd.xcodeproj`, select an iPhone simulator, and press Run.

## Viewports

- iPhone SE sized simulator: no clipped buttons, tab labels, or score text.
- Standard iPhone simulator: Today, Rules, Insights fit with comfortable spacing.
- Large iPhone simulator: cards do not stretch into awkward low-density layouts.

## Accessibility

- VoiceOver reads Focus Score, Settings, Lock In, Rules choices, and share recap clearly.
- Dynamic Type Large keeps buttons at or above 44pt and prevents text overlap.
- Reduce Motion disables springy press scale and avoids repeated animation loops.
- Risk states are not color-only: icons and text labels are present.

## Product States

- Fresh install opens onboarding.
- Onboarding completion opens Today.
- Today Lock In button enters protected state.
- Rules can select app rows without duplicate entries.
- Predictive Protection shows Pro-required state in mock mode.
- Insights shows weekly score, reclaimed time, streak, and private-by-default recap copy.

## Visual Standard

- Dark graphite base, green protected accent, orange risk accent, blue insight accent.
- No generic purple AI gradient treatment.
- No nested cards inside cards.
- No hero-scale type inside compact controls.
- Buttons do not wrap or resize on press.
