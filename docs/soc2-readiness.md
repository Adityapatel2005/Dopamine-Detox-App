# SOC 2 Readiness Baseline

SOC 2 is an assurance report performed by an external CPA firm. Lockd cannot self-certify SOC 2 compliance. This document creates a readiness baseline for future audit preparation.

## Trust Services Categories

- Security: protect systems and data against unauthorized access.
- Availability: maintain system availability commitments if backend services are introduced.
- Confidentiality: protect confidential business and user information where applicable.
- Processing Integrity: ensure processing is complete, valid, accurate, timely, and authorized where applicable.
- Privacy: align personal information handling with notices and commitments.

## V1 Scope

Lockd v1 is local-first and has no production backend in this scaffold. Current SOC 2 work should focus on engineering change control, access control, vendor management, incident response, release evidence, privacy review, and secure development practices.

## Control Areas

- Access: least privilege for source code, Apple Developer, GitHub, support, and deployment systems.
- Change management: pull requests, review, tests, release checklist, and rollback notes.
- Risk management: maintain risk register and review major product changes.
- Vendor management: review Apple, GitHub, email/support, analytics, crash reporting, and hosting vendors before use.
- Incident response: maintain severity levels, owner, communication path, and evidence log.
- Business continuity: preserve code, documents, credentials, and release artifacts.

## Evidence Examples

Store dated evidence for access reviews, code review, test results, release approvals, vendor reviews, incident exercises, and privacy review.
