# Accessibility Checklist

Lockd should target WCAG 2.2 AA principles and Apple's iOS accessibility expectations.

## VoiceOver

- Icon-only buttons have descriptive labels.
- Focus order follows visible reading order.
- Important state changes are announced.
- Decorative visuals are hidden from assistive technologies.

## Dynamic Type

- Text scales without clipping.
- Buttons and rows preserve at least 44 point tap targets.
- Long legal labels wrap or truncate intentionally.

## Motion

- Reduced Motion is respected.
- Timers and state changes remain understandable without animation.

## Color and Contrast

- Body text contrast meets at least 4.5:1.
- Large text and non-text UI meet applicable contrast thresholds.
- Focus state, risk state, and protected state are not communicated by color alone.

## Interaction

- All primary flows are reachable without precision gestures.
- Error, denied-permission, and empty states are readable and actionable.

## Evidence

Capture VoiceOver notes, Dynamic Type screenshots, Reduced Motion checks, and contrast results before each App Store submission.
