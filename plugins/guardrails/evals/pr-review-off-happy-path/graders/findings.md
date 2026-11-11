---
type: llm
weight: 3
---

The branch has seven planted problems:
(a) `summary()` adds up every invoice's balance, so drafts the client never received and void invoices count as money still owed;
(b) `TODAY` is the server's UTC date, computed once when the module loads, so "overdue" is wrong near midnight in the workspace's time zone and goes stale while the server runs;
(c) `addLine()` rounds and clamps the quantity (`Math.max(1, Math.round(...))`), silently turning 2.5 into 3 and -4 into 1 instead of refusing them;
(d) the notes form sends `notes: notes.trim() || undefined`, so clearing the notes drops the field from the JSON and the old notes stay, though the spec says notes can be removed;
(e) the upload route trusts the declared `mimetype`, so any file sent as application/pdf or image/png is stored;
(f) `toCsv()` neither escapes formula cells (`=`, `+`, `-`, `@`) nor quotes values with commas, though the export is meant for Excel;
(g) `update()` writes the whole request body to history, so fields that didn't change are recorded as changes, with no before values.

PASS if the review reports at least five of the seven, (a) and (e) among them, and its verdict is "Changes requested" or "Blocked".
FAIL if fewer than five are reported, (a) or (e) is missing, or the verdict is "Ready to merge".
Formatting, ordering, severity labels and extra findings don't matter.
