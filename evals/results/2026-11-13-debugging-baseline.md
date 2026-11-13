# Debugging baseline: one copied code works, another is refused

**Question:** Can the unmodified guide locate the first wrong read and rule
out a plausible checksum problem from a report and two inputs? This tests
diagnosis after skill selection, not routing or the ability to find the
parser in a whole application.

## What the session received

One fresh, read-only Codex CLI 0.162.1 session (GPT-6.1-Sol, medium) used
the debugging guide at `96b6e12`, Elixir 1.19.5 and OTP 27. The extract
contained the pre-fix parser, its text helper and its original test module
from a real application. Two synthetic static payment codes had the same
fields except for one character in the description and the resulting checksum.
Neither was a customer record.

The brief said that sample A was accepted and B refused in the same
registration flow; it asked why, what could be reproduced and what to do
next, without editing files. It did not identify the differing field, unit of
length, suspect function or intended fix. The session had no application
history, later tests, evaluator notes or corrected source. Before the run,
the evaluator required reproduction at the public entry point, the first
divergent read, evidence discriminating the checksum hypothesis and a
localized diagnosis. The writer was a separate follow-up, not a pass condition.

## What the session demonstrated

The original 14 tests passed. The parser accepted A and rejected B as
malformed. The reviewer independently recalculated both original checksums:
both matched. The enclosing field declared length 74 in both inputs; its
value occupied 74 bytes in A and 75 in B. Reading 74 bytes split a two-byte
character and left its continuation byte at the start of the next field ID.
The parser rejected that header **before** validating the checksum or
checking any payment details.

| Session probe on B | Observed result |
|---|---|
| Original sample | Malformed fields |
| Adjust the nested and enclosing lengths to byte counts; retain the original checksum | Fields read successfully; checksum rejected |
| Same adjusted lengths; recompute the checksum | Accepted |

The reviewer identified the reader as the first failing operation, noted
that the writer also emits byte lengths and recommended checking the
integration's intended unit before fixing either. It did not claim to have
tested the registration screen or established the external format standard.

## Evaluator replay and decision

Outside the session, the evaluator ran the same public inputs against the
historical implementation and the real later fix. A parsed in both; B was
refused before and accepted after. With only the checksum changed, the old
reader still reported malformed fields for B; the corrected reader reached
the checksum error. The evaluator also exercised the public writer: adding
an amount to B returned the original unreadable payload before the fix;
afterward the output parsed with the requested 6,000 cents. The session
identified this adjacent risk but did not demonstrate that round trip itself.

**Decision:** the guide met the predeclared diagnosis criteria in this one
bounded case. Keep it unchanged. A useful next control is a different
historical symptom where the apparent parser error originates in the caller:
include both layers and observe whether the session follows the evidence to
the right owner. One run with the parser already isolated cannot answer that.

## Inverse control: a reader given no selection

On a historical monthly desk, opening totals for a past month with no
reading sent the operator back to the current month. Two fresh sessions got
the same pre-fix caller, destination and two route declarations, with just
that symptom. A had no Kit guide; B received the unchanged debugging guide
at `5f59112`. Both used Codex CLI 0.162.1, GPT-6.1-Sol, medium, read-only.
Neither received history, an expected owner, a corrected URL or the other's
output. Before either run, the evaluator required an observed outgoing
value, an independent control on the reader and a localized diagnosis.

| Observation | A: unaided | B: with guide |
|---|---|---|
| Exercise missing-reading path under a fixed November clock | Selected October, returned November | Selected September, returned November |
| Feed that earlier month directly to the destination | October retained | September retained |
| Identify first loss and preserve the normal default | Caller navigated without the month; keep the reader's fallback | Same; ruled out parsing and the save path as immediate causes |

Both executed in-memory probes using extracted functions and stand-ins for
missing dependencies. Both also identified a second missing-reading return
during refresh. Neither demonstrated that the database *should* have had a
reading, or claimed a full browser run.

The evaluator independently replayed the actual missing-branch destination
expression and the historical reader, with September selected and the clock
fixed in November. Before the field fix, the outgoing URL had no query and
the reader returned November 1. With the corrected caller and **the same
reader**, the URL carried the month and bank tab and returned September 1.
A direct visit without a month still returned November 1. The application
already contained this fix; no application changes were needed.

**Decision:** both arms passed. Together with the reader-side baseline, this
supports keeping the current workflow. It does not demonstrate an advantage
over an unaided reviewer or measure discovery in a whole application.
