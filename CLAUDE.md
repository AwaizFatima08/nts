# Prep Simulator for NTS (HomiLabs) — project notes

Flutter Android app: timed NTS-style mock tests (NAT, GAT General, Recruitment), topic practice, guidance.
Package `nts_prep`, app id `com.homilabs.nts_prep` (locked after the first Play upload).

## Locations
- Code: `/mnt/storage/projects/nts` · GitHub `AwaizFatima08/nts` (PUBLIC repo: no secrets)
- Local backup: `/mnt/storage/project_backups/nts_backup`
- Google Drive backup: https://drive.google.com/drive/folders/1_2JPT8BPYaH76ASWfzAaa4x1CjbbtQ-0
- Backups: `bash scripts/backup.sh` (all three layers)
- Site: https://nts.homilabs.org (Hostinger), source in `website/`

## Decisions (Homi, 2 Nov 2026)
- Three modes on one shared bank; 20 tests each. NAT streams IE, IM, ICS, IA.
- Name "Prep Simulator for NTS"; NTS used descriptively, with a not-affiliated notice in app, listing and site.
- Whole build first, then Homi reviews. AdMob and Hostinger through the built-in browser (Homi signs in).

## Content
- Source: `content/bank/<section>/<topic>.jsonl` (format in `docs/content-schema.md`), targets and exam patterns in `tool/make_blueprint.py` → `content/blueprint.json`.
- Every question and passage is original HomiLabs work (`docs/writer-brief.md`). Never copy NTS papers or prep books.
- `python3 tool/validate.py` checks the bank; `python3 tool/build_content.py` builds `assets/data/` (fixed seed: papers stay stable);
  `tool/blind.py` runs the independent answer check. `flutter test test/content` checks the built papers.
- Practice pool is separate from the test pool, so practice never spoils a test. Modes share the test pool, so NAT, GAT and Recruitment papers overlap by design.
- No facts that go out of date. Islamic content, Pakistan Studies and flagged items are for Homi's review: `docs/review-flags.md`.

## Ads
Ids in `config/admob.json`. Banner on Home tabs only; interstitial when leaving results or a practice set, 5 minutes apart. Never on exam, review or practice question screens. Debug builds use Google test units.

## Gate before commit
```
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```
Heavy jobs follow `~/.claude/heavy-jobs.md`: use `jobq`, then `./gradlew --stop`.
