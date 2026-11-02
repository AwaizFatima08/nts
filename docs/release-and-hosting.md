# Release and hosting kit: Prep Simulator for NTS

## Build
- Package `com.homilabs.nts_prep` (locked after the first Play upload). Version 1.0.0 (versionCode 1).
- Build: `jobq run --name nts-release-aab -- flutter build appbundle --release`, then `./gradlew --stop` in `android/`.
- Bundle: `releases/v1.0.0-1/nts-prep-1.0.0-1.aab` (49 MB, local and Drive only). SHA-256 `3e414afe62fc913a7aa310590ee1f02516f63c22153a8cd3689b6d688bb9975c` (rebuilt 2 Nov 2026 with the About screen's Privacy choices link; the earlier build was never uploaded).
- Upload key SHA-1: `58:65:D1:36:B7:E1:45:FD:77:45:62:11:D0:86:48:54:2C:C1:12:10`.
- Before every release: `bash scripts/check-release-ad-ids.sh`, `python3 tool/validate.py`, `flutter test`.
- Signing: `android/key.properties` → `.secrets/nts-upload.keystore` (credentials in `.secrets/nts-upload-keystore-credentials.txt`). `.secrets/` is in the local and Drive backups, not in GitHub. Losing it means a support request to Google.

## Website: https://nts.homilabs.org
- Own PHP/HTML website in hPanel, deployed by Hostinger Git from the `deploy` branch (auto-deployment).
- Change `website/`, commit, then `bash scripts/publish-site.sh`. Flush the CDN cache in hPanel if pages look stale.
- Pages: landing, `/privacy.html`, `/terms.html`, `/app-ads.txt`.
- After Play launch: replace "Coming soon on Google Play" with the Play link, and add the app to homilabs.org.

## Play Console
| Item | Value |
|---|---|
| App icon 512×512 | `store-assets/icon-512.png` |
| Feature graphic | `store-assets/feature-graphic.png` |
| Privacy policy URL | https://nts.homilabs.org/privacy.html |
| Website | https://nts.homilabs.org |
| Contact email | homilabs.smc@gmail.com |
| Ads | Yes (AdMob banner on home tabs; one interstitial after results or practice) |
| App access | All functionality available without login |
| Data safety | Collected and shared: Device or other IDs (advertising ID) and app activity via the ads SDK, purpose Advertising, shared with Google AdMob; encrypted in transit. Test attempts stay on the device. Declare Advertising ID use as Advertising |
| Content rating | Reference/educational; No to violence, sexuality, language, drugs, gambling, purchases, user interaction |
| Target audience | 13+ |
| Category | Education |
| Track | Internal testing, then Closed testing; a new personal developer account needs 12 testers for 14 days before production |

**App name** (22 characters): `Prep Simulator for NTS`

**Short description** (80 max): `Timed NAT, GAT and job test practice with scores and every answer explained.`

**Full description**:
```
Prepare for NTS tests in Pakistan the way they feel on the day. Prep Simulator for NTS gives you full-length timed mock tests, topic practice in every area tested, and clear guidance on what to expect.

20 FULL-LENGTH TESTS FOR EACH PATH
• NAT: 90 questions in 120 minutes, following the pattern NTS publishes. Papers for Pre-Engineering (IE), Pre-Medical (IM), Computer Science (ICS) and Arts (IA).
• GAT General: 100 questions in 120 minutes across verbal, analytical and quantitative reasoning.
• Recruitment: a typical job-test mix of English, maths, analytical reasoning, General Knowledge, Islamic Studies or Ethics, and Pakistan Studies.

SCORES THAT HELP
• Your result by section, with the topics to work on next.
• Every question explained after the test, with the working and why the tempting option is wrong.
• Progress across your attempts.

TOPIC PRACTICE
• Short sets with instant answers in English, analytical reasoning, quantitative, Physics, Chemistry, Mathematics, Biology, Computer Science, General Knowledge, Islamic Studies, Ethics and Pakistan Studies.
• Practice questions are separate from the 20 tests.

GUIDANCE AND TIPS
• Test patterns, study plans, time management, bubble sheet advice and tips for each section.

PRIVATE AND OFFLINE
• Tests and practice work offline, with no account.
• Your scores stay on your phone.
• Free, with light ads, never during a test.

Prep Simulator for NTS is independent practice material by HomiLabs. It is not affiliated with, endorsed by or connected to the National Testing Service (NTS). All questions are original practice material, not real papers, and scores are for practice only. Always follow your own test notice.
```

## AdMob
- Account homilabs.smc@gmail.com. App ID `ca-app-pub-2087846699268567~6482489070`; units in `config/admob.json`. Debug builds use Google test units.
- "Limited ad serving" until the Play listing is live: after publishing, AdMob → Apps → this app → Add store (com.homilabs.nts_prep).
- `app-ads.txt` is live at https://nts.homilabs.org/app-ads.txt.
- Consent: the app logs "no form(s) configured" because no European message is published. Ads still load in Pakistan. To serve EEA/UK users properly, publish the draft message "Prep Simulator for NTS consent" (Privacy & messaging → European regulations).

## Before production (open items)
- Homi reviews Islamic Studies, Pakistan Studies and flagged items: `docs/review-flags.md`.
- Trademark: the name uses "NTS" descriptively, and the notice is in the About screen, listing and website, but Play can still ask for proof of permission.
- Phone screenshots (2-8) for the listing.
