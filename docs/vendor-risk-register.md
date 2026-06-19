# Vendor Risk Register

Review every vendor before production use.

| Vendor | Purpose | Current status | Data exposure | Required review |
| --- | --- | --- | --- | --- |
| Apple App Store | Distribution, IAP, subscriptions | Required | Purchase and app distribution data handled by Apple | App Store terms and privacy disclosures |
| Apple Screen Time APIs | App blocking and activity controls | Required | On-device permissions and system frameworks | Entitlement and permission review |
| GitHub | Source control | Active | Source code and project documentation | Access review and branch protections |
| Email/support provider | User support and privacy requests | Not selected | Support messages if added | DPA, retention, access, security |
| Analytics provider | Product analytics | Not used | Personal or usage data if added | Privacy label, SDK manifest, opt-out review |
| Crash reporting provider | Diagnostics | Not used | Diagnostics if added | Data map and retention review |

## Rule

No new vendor should be added to the production app until this register, the privacy data map, and App Store privacy answers are updated.
