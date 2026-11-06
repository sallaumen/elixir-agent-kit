---
name: asset-lineage
description: "Use when previews or generated assets lack clear source, version, orientation or ownership."
---

# Asset Lineage

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when previews or generated assets lack clear source, version, orientation or ownership.

## Inputs to inspect

- Asset sources, licensing or permission, original versus derived files, associated entity/variant/version and display surfaces.
- Generation and transformation jobs, storage keys, selection rules, loading/error states and cache invalidation.

## Workflow

1. Trace each asset from input and generation or upload through storage, transformation and display. Record the parent entity and revision.

2. Check whether thumbnails, front/back views and selected versions represent the correct underlying artifact. Late generation must not silently change the selected asset.

3. Represent pending, failed and missing assets honestly. Provide useful fallback behavior without displaying unrelated or invented output.

4. Exercise regeneration, selection changes, refresh and failed processing. Preserve historical associations and verify access controls on stored artifacts.

## Decision points

- Separate a mockup or generated illustration from a verified catalog image when their evidentiary meaning differs.
- If choosing an old asset changes the selected product revision, pair with version-lineage for that separate state risk.

## Quality criteria

- Carry stable source, version and ownership identifiers through generation, transformation, storage and display.
- Prevent filename collisions and stale previews from attaching an image to the wrong variant, orientation or approval state.
- Choose a primary image for the user’s decision and allow inspection of relevant secondary views without silently changing canonical selection.
- Make missing, pending, failed and unverified visuals explicit; do not imply that an illustration proves a purchasable variant.

## Validation and evidence

- Trace one asset from source to rendered page and test a version/variant switch while another preview is loading.
- Report what the image proves, which transformations ran, and whether its origin/license and current version are known.

## Avoid

- Do not use a visual resemblance or filename as proof of product identity.
- Do not publish or overwrite real assets merely to test an unverified generation flow.

## Completion

Accurate previews and traceable asset lineage across creation, selection and presentation.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
