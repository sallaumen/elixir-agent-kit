---
name: revision-lineage
description: "Use when a revision, preview, asset or selection is associated with the wrong version, or viewing an old version silently changes the current one."
---

# Revision Lineage

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when "the latest" and "the approved" versions disagree and the product shows the wrong one, when opening an old revision or thumbnail changes what the user has selected, when a generated asset (image, preview, export, render) arrives late and attaches to the wrong variant or revision, or when nobody can say which revision a displayed artifact came from.

This workflow concerns product revisions and the artifacts derived from them. Which build or dependency is running in an environment belongs to [delivery-validation](../delivery-validation/SKILL.md) and [build-dependencies](../build-dependencies/SKILL.md).

## Inputs to inspect

- The three identities in play: the stable entity (a product, a document, a design), its immutable revisions, and the mutable pointers that name one of them (selected, published, approved, default).
- Every artifact derived from a revision: thumbnails, previews, exports, generated images, caches; where each records its parent revision, variant and orientation, and where it relies on a filename, a position or "latest".
- The jobs that produce artifacts: inputs, duration, retries, and what happens when a result lands after the user moved on.
- The surfaces that display or let a user browse revisions, and which actions on them write a pointer.
- Storage keys and cache rules for artifacts, and access control on stored files. See [Oban](../../ELIXIR.md#oban) for late job results.

## Workflow

1. Write the identity model for the selected flow: entity, revision, pointers, derived artifacts, each with the identifier that names it. Mark every place that uses a weaker identity (filename, order, timestamp, "current").

2. Trace one revision from creation through preview, selection, publication and display, and one artifact from its generating job to the screen. Record where the parent revision is attached and where it could be lost.

3. Separate viewing from selecting. Browsing an old revision or opening a secondary view must not write a pointer unless the product defines that action explicitly; the pointer changes only on an explicit user action with its own control.

4. Key every late result by the revision and variant that requested it, and drop it when that key no longer matches; a regenerated asset for an older revision never replaces the current one. Give storage keys the revision in their name or path so two generations cannot collide.

5. Represent pending, failed, missing and unverified artifacts as such on the surface; a placeholder is not a result, and an illustration or mockup is labeled differently from a verified catalog image.

6. Exercise the risky orderings: switch revision while a preview is generating, regenerate for an old revision, refresh mid-change, roll a pointer back, and a migration that must preserve historical associations. Verify access control on stored artifacts.

## Decision points

- Immutable identifiers over words: "latest", "current" and "main" each name a different thing; make the pointer explicit in storage and on screen.
- Viewing is read-only with respect to pointers; selection and publication are explicit writes with their own authority.
- The primary image or artifact shown for a decision is chosen by a rule (variant, orientation, approval state), not by whichever job finished last.
- A derived artifact without a recorded parent revision is unverified, however convincing it looks.
- When choosing an old artifact would change the selected revision, that is two decisions on screen, not one click.

## Quality criteria

- Every revision, pointer and artifact can be named by an identifier that survives regeneration, migration and cache refresh.
- Opening, browsing or previewing never changes a selected or published pointer; the audit trail shows who moved each pointer and when.
- Late or duplicate artifact results cannot attach to a newer revision or variant; storage keys and caches include the revision.
- Pending, failed, missing and unverified visuals are explicit, and nothing implies that a rendering proves a purchasable or approved variant.
- Historical associations survive migrations and cleanups; an old revision still shows the artifacts it had.

## Validation and evidence

- The identity model (entity, revision, pointers, artifacts) with the identifiers found, and the weak-identity sites fixed.
- Tests that deliver an artifact for an older revision after a newer selection, regenerate while browsing, and reload mid-change, asserting both stored pointers and what is displayed.
- A trace of one artifact from job to screen with the transformations run and whether its origin, license and current revision are known.
- Any storage, provider or migration path not exercised, named.

## Avoid

- Do not let a thumbnail click, a preview or a browse action select or publish a revision.
- Do not key artifacts by filename, order or completion time, or treat visual resemblance as identity.
- Do not define "the latest" as "the approved" or make a cache refresh stand in for a revision change.
- Do not publish or overwrite real assets to test an unverified generation flow.
- Do not infer the deployed or running revision from the local checkout.

## Completion

One identity model with immutable revisions, explicit pointers and artifacts that carry their parent revision, viewing that never selects, late results that cannot misattach, and tests for the risky orderings. For the late-result mechanics in the interface use [async-state](../async-state/SKILL.md); for which combination of a product is sellable use [commercial-eligibility](../commercial-eligibility/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
