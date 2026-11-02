# Question bank format

Source files: `content/bank/<section>/<topic>.jsonl` (large topics may split: `<topic>-2.jsonl`). One JSON object per line, UTF-8. Sections and topics are in `content/blueprint.json`.

Question line:
```json
{"id":"pc-t0001","pool":"test","level":2,"stem":"...","options":["...","...","...","..."],"answer":1,"explanation":"..."}
```
| Field | Rule |
|---|---|
| `id` | `<prefix>-t0001` for the test pool, `<prefix>-p0001` for practice; prefix is in the blueprint |
| `pool` | `test` (goes into the 20 papers) or `practice` (topic practice only). Never reuse an item across pools |
| `level` | 1 easy, 2 medium, 3 hard. Aim for about 30 / 50 / 20 % |
| `options` | exactly 4 strings |
| `answer` | index 0-3 of the correct option. Spread evenly; never a pattern |
| `explanation` | why the answer is right (with the working) and what makes the tempting wrong choice wrong. 1-4 sentences |
| `set` | optional: id of a set line, for shared passage or scenario |
| `table` | optional: rows of strings, first row is the header. Data questions only |

Set line (comes before its questions):
```json
{"type":"set","id":"pz-s001","pool":"test","title":"Office parking","text":"..."}
```
