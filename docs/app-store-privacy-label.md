# App Store Privacy Label Worksheet

This worksheet reflects the current Lockd v1 local-first scaffold. Update it before App Store submission if analytics, accounts, backend sync, support tooling, purchases outside Apple, notifications, crash reporting, or third-party SDKs are added.

## Current Position

- Data collected by Lockd: none in the current scaffold.
- Tracking: no.
- Third-party analytics: no.
- Advertising: no.
- Data broker sharing: no.
- Cross-app tracking: no.
- On-device-only app data: Focus Score, sessions, rules, Screen Time app selections, weak-spot predictions, goals, and recap cards.

## Apple Review Notes

Apple requires App Privacy details in App Store Connect and a public privacy policy URL. On-device-only data is not treated as collected when it never leaves the device, but the team must disclose any data transmitted off device.

## Future Changes That Require Updating

- Account creation or login.
- Cloud sync or backup.
- Email marketing or support ticket tools.
- Crash reporting or diagnostics SDKs.
- Product analytics.
- Push notification personalization from a server.
- Referral, affiliate, or advertising SDKs.
- Any third-party SDK on Apple's required privacy manifest list.
