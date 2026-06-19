# Security Controls

## Product Security

- Keep focus and Screen Time data on device for v1.
- Do not include third-party analytics, advertising, or tracking SDKs in v1.
- Review any network request before release.
- Use Apple frameworks and App Store receipt validation patterns for subscriptions.
- Do not store secrets in source code.

## Engineering Controls

- Require branch review before merging release code.
- Run smoke tests before release.
- Keep dependencies minimal.
- Review privacy manifests for app and third-party SDKs.
- Keep GitHub and Apple Developer access limited to necessary contributors.

## Device and Account Controls

- Use multi-factor authentication for GitHub, Apple Developer, and email.
- Remove access promptly when a contributor leaves.
- Review access at least quarterly.

## Logging

Do not log Screen Time selections, Focus Score inputs, or other private focus data to a server in v1.
