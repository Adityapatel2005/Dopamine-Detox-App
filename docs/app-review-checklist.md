# App Review Checklist

Use this checklist before TestFlight external testing and App Store submission.

## Privacy

- Public Privacy Policy URL is live and matches the app.
- App Store Connect privacy answers match the current data map.
- `PrivacyInfo.xcprivacy` is present and accurate.
- No third-party SDK is included without privacy manifest and signature review.
- No tracking prompt is shown unless tracking is actually added and approved.

## Screen Time and Entitlements

- Family Controls and Device Activity entitlements are configured before release.
- Permission prompts explain why Screen Time access is needed.
- The app functions gracefully if permission is denied.

## Subscriptions

- All paid digital features use Apple In-App Purchase.
- Price, billing period, trial, renewal, cancellation, and restore purchase are visible.
- Terms of Service and Privacy Policy are reachable from the paywall.

## Safety

- No medical diagnosis, treatment, cure, prevention, or crisis claims.
- Not submitted in the Kids Category.
- Not intended for children under 13.
- User-generated sharing is opt-in.

## Accessibility

- VoiceOver labels exist for icon-only actions.
- Dynamic Type does not clip essential text.
- Reduced Motion is respected.
- Touch targets are at least 44 points.

## Export Compliance

- Confirm encryption/export compliance answers in App Store Connect based on final network and crypto use.
