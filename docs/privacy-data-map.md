# Privacy Data Map

This map reflects the current v1 local-first design.

| Data element | Purpose | Location | Shared | Retention |
| --- | --- | --- | --- | --- |
| Screen Time app selections | Build blocking rules | On device | No | Until local deletion or uninstall |
| Focus sessions | Show progress and session state | On device | No | Until local deletion or uninstall |
| Focus Score | Summarize focus progress | On device | No | Until local deletion or uninstall |
| Weak-spot prediction inputs | Predict high-risk times | On device | No | Until local deletion or uninstall |
| Goals and modes | Personalize focus flows | On device | No | Until local deletion or uninstall |
| Recap cards | Optional sharing | On device | Only when user shares | User controlled |
| Subscription entitlement | Unlock paid features | Apple / device receipt | Apple handles purchase records | According to Apple policies |

## Data Minimization Rules

- No third-party analytics in v1.
- No advertising SDKs in v1.
- No tracking domains in v1.
- No backend sync in v1.
- Do not collect precise location, contacts, photos, microphone, camera, health data, or browsing content for v1.

## Change Control

Any new data element must be added here before release and reviewed against the Privacy Policy, App Store privacy label, GDPR, California rights, security controls, and vendor register.
