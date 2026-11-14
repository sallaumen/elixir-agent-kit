# UI identity: class handover holdout

## Protocol frozen before execution

Compare the current published workflow (A) with the unchanged, unpublished final
overlapping-state candidate from the [prior round](2026-11-13-frontend-ab.md) (B).
This historical class-management screen is new to the identity evaluations.
Use the pre-fix view, domain guard and a reduced rendering with fictitious people.
Exclude later fixes, test assertions, evaluator expectations and other answers.
Two independent sessions per arm get identical input except for the guide.
One fresh judge receives shuffled, unlabeled answers and the rubric. The examiner
checks the judgements against the answers and source before the release decision.

The selected successor is eligible to take over, while the **current recipient**
cannot receive payment for a published, priced class. The owner selected keeping
the current recipient and confirmed. Freeze these three binary checks per answer:

1. **First message:** explicitly lead the post-attempt state with a refusal:
   ownership did not move, and the selected destination for the money (the
   current recipient, here the owner) cannot receive. A generic error or
   blaming the successor fails. Accept equivalent wording and local placement.
2. **Next action:** make fixing the current recipient's ability to receive, or
   expressly revisiting the money choice, the actionable next step. Keep the
   real choices; do not silently reroute money, simply retry unchanged, promise
   an unsupported route, or imply that choosing is itself a transfer.
3. **Control and commitment:** identify what happens if the owner explicitly
   sends money to the eligible successor instead: confirmation must make clear
   who gets the class and who gets the money; ownership changes only on success.
   Do not require a payout fix for the outgoing owner on this branch.

B must pass all three checks in **both** runs to clear the release gate. If A
does as well, keep the shorter published guide. Otherwise adopt B only if its
two answers clear the gate without a contradictory or unsafe recommendation.
A failure does not trigger more wording changes or another draw on this screen.
The gate applies to this bounded diagnostic family; it does not certify all UI.

## Observations and decision

The pre-fix application displays a refusal referring to “that person” after the
dialog is accepted, with the successor visibly selected and the transfer button
still present. In the pictured branch the **outgoing** owner is the selected
payee. Historical application tests inspected separately assert the refusal's
addressee and unchanged ownership. A local Elixir probe executed the extracted
pre-fix choice, recipient and payout-guard functions with synthetic readiness,
stubbing the database and recording entry to the write boundary. With just the
owner blocked, keeping the money failed before write and moving it passed to
write; reversing the readiness records reversed both outcomes. This was not a
database transaction or a connected LiveView test. WebKit rendered a reduced
static screen at 390 px with sample data; it did not test the production layout.

Four fresh, tool-free Codex executions (gpt-6.1-sol, medium reasoning, maximum
450 requested words) saw the same screenshot, source, sample records, contract
and brief. No fixed implementation, test assertions or expected priority was
shown. A fifth session scored the answers in shuffled order without arm labels.
The examiner agreed with all twelve binary judgements before applying the rule.

| Guide / blinded answer | First message | Next action | Control and commitment |
|---|---:|---:|---:|
| Published / 1 | 1 | 0 | 1 |
| Published / 3 | 1 | 0 | 1 |
| Candidate / 2 | 1 | 1 | 1 |
| Candidate / 4 | 1 | 1 | 1 |

All four found the right blocker, preserved the explicit money choice and kept
confirmation distinct from success. Both published-guide answers prescribed
an “existing” setup destination without evidence for it in the supplied material.
Both candidate answers made that link conditional and offered the already
available choice on the page. This concerns evidence for a recovery route,
not proof that no such route exists elsewhere in the application.

**Decision: adopt the unchanged candidate; clear the UI identity release hold
for this field round.** It met all three requirements twice. The measured
difference was grounding the recovery action, not detecting the overlapping
states more often. Four answers on one new screen are not an estimate of
general improvement; earlier misses on the agreement, registration and payment
screens remain on record. This is a guided review, not autonomous routing or a
usability study. No external application change was necessary.

Full guide SHA-256: published
`c8a7bdadb404b96b61ed6ce92a706bc279afe2954e6fbcb437f6bcdc51a8ae03`;
candidate
`1619fd98766dfc134e4d08221b576eb4a51b4eb64f9cba3e850518661eb2aaaa`.
