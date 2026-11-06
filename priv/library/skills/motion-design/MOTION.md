# Motion reference

Ammunition for deciding interface motion, not a style to copy. The rules that point here are in [SKILL.md](SKILL.md). Values are CSS `cubic-bezier(x1, y1, x2, y2)`, so the same numbers work in CSS, the Web Animations API, a GSAP timeline or a design tool's curve editor.

The method, the curve families and the timing model are adapted from [motion-kit](https://github.com/hughminhphan/motion-kit) by Hugh Phan (MIT, revision `6173e5c408f81f1989435843af3f0788b74bda96`), rewritten for product interfaces. Curve values come from [easings.net](https://easings.net), [Material 3](https://m3.material.io/styles/motion/easing-and-duration) and [IBM Carbon](https://carbondesignsystem.com/elements/motion/overview). Video-only devices from the source (seek-safe timelines, `wiggle`, time remapping, text ranges) are not part of this workflow.

## 1. Pick a register

| Register | What it should feel like | Curves to start from | Timing |
|---|---|---|---|
| Technical / product | Precise, efficient, in control | `m3.standard`, `carbon.productive.*` | Short, tight, no device |
| Editorial / content | Clear cause and effect, guided eye | `kit.land`, `kit.reveal`, `m3.emphasized*` | Distance-driven, few entrances |
| Premium / cinematic | Weight and long settles | `easings.outExpo`, `m3.emphasizedDecelerate`, springs at damping 1 | Longer, fewer, larger moves |
| Expressive / launch | A moment meant to be noticed | `carbon.expressive.*`, `kit.whip`, springs 0.7 to 0.8 | Snaps against holds |
| Playful / consumer | Elastic and physical | springs 0.55 to 0.7, `easings.outBack` sparingly | Quicker reactions, visible settle |
| Calm / ambient | Breathing, continuous | `easings.inOutSine`, `kit.drift` | Long overlapping, no hard stops |

One dominant register per product surface. Mixing is allowed for a single deliberate moment; every register at once reads like a demo reel.

## 2. Curves

**Interface systems.** These are designed for screens at arm's length; start here for product work.

| Name | Bezier | Character and use |
|---|---|---|
| `m3.standard` | 0.2, 0, 0, 1 | Utility: in-place value changes, expand and collapse, selected state. |
| `m3.standardDecelerate` | 0, 0, 0, 1 | An element entering from off-screen or from a hidden container. |
| `m3.standardAccelerate` | 0.3, 0, 1, 1 | An element leaving the screen. |
| `m3.emphasizedDecelerate` | 0.05, 0.7, 0.1, 1 | The entrance that matters: sheet, dialog, primary content. |
| `m3.emphasizedAccelerate` | 0.3, 0, 0.8, 0.15 | The matching exit; quicker and accelerating. |
| `carbon.productive.standard` | 0.2, 0, 0.38, 0.9 | Task UI that should get out of the way. |
| `carbon.productive.entrance` | 0, 0, 0.38, 0.9 | Task UI entrance, short distance. |
| `carbon.productive.exit` | 0.2, 0, 1, 0.9 | Task UI exit. |
| `carbon.expressive.standard` | 0.4, 0.14, 0.3, 1 | Significant state change the product wants felt. |
| `carbon.expressive.entrance` | 0, 0, 0.3, 1 | Significant entrance. |
| `carbon.expressive.exit` | 0.4, 0.14, 1, 1 | Significant exit. |

**Motion-design curves.** Authored from keyframe practice (easy ease with high influence). Each is a character, not a strength; they suit larger surfaces and signature moments.

| Name | Bezier | Character |
|---|---|---|
| `kit.land` | 0.1, 0.75, 0.15, 1 | Arrives at speed, long confident settle. Entrances from off-screen. |
| `kit.heavy` | 0.75, 0, 0.18, 1 | Slow push-off, decisive arrival. Large panels, full-screen surfaces. |
| `kit.whip` | 0.85, 0, 0.15, 1 | Hang, snap, hang. A deliberate state change. |
| `kit.reveal` | 0.22, 1, 0.36, 1 | Almost all travel early, then hold. Masked reveals. |
| `kit.leave` | 0.55, 0, 0.9, 0.35 | Accelerates out, never settles. Exits. |
| `kit.wind` | 0.45, 0, 0.55, 1 | Anticipation counter-move. |
| `kit.drift` | 0.4, 0, 0.6, 1 | Continuous, even motion. Ambient detail only. |

**easings.net families.** Sine < Quad < Cubic < Quart < Quint < Expo in strength. Circ starts or ends abruptly; Back overshoots and is easy to overuse.

| Family | in | out | inOut |
|---|---|---|---|
| Sine | 0.12, 0, 0.39, 0 | 0.61, 1, 0.88, 1 | 0.37, 0, 0.63, 1 |
| Quad | 0.11, 0, 0.5, 0 | 0.5, 1, 0.89, 1 | 0.45, 0, 0.55, 1 |
| Cubic | 0.32, 0, 0.67, 0 | 0.33, 1, 0.68, 1 | 0.65, 0, 0.35, 1 |
| Quart | 0.5, 0, 0.75, 0 | 0.25, 1, 0.5, 1 | 0.76, 0, 0.24, 1 |
| Quint | 0.64, 0, 0.78, 0 | 0.22, 1, 0.36, 1 | 0.83, 0, 0.17, 1 |
| Expo | 0.7, 0, 0.84, 0 | 0.16, 1, 0.3, 1 | 0.87, 0, 0.13, 1 |
| Circ | 0.55, 0, 1, 0.45 | 0, 0.55, 0.45, 1 | 0.85, 0, 0.15, 1 |
| Back | 0.36, 0, 0.66, -0.56 | 0.34, 1.56, 0.64, 1 | 0.68, -0.6, 0.32, 1.6 |

Different properties may take different curves: a panel that slides and lifts can use `kit.land` horizontally and `kit.heavy` vertically, so the path bends instead of moving on a rail.

## 3. Duration

Derive it. A short move and a long one do not take the same time, and a heavy surface is not a light one.

```text
ms = clamp(70, (70 + 10 * sqrt(distancePx)) * weight, 520)
```

Weight: 0.8 light (label, chip, toast), 1 normal (card, row, menu), 1.3 heavy (panel, drawer), 1.6 full-screen surface. At 0 px the floor applies; use it only for a small presence change.

| Move | Typical duration |
|---|---|
| Press, hover, focus feedback | 80 to 140 ms |
| In-place value, selection, icon swap | 140 to 200 ms |
| Menu, popover, small surface | 180 to 240 ms |
| Dialog, drawer, medium panel | 220 to 320 ms |
| Full-screen surface or page transition | 300 to 480 ms |
| Exit of any of the above | about 0.65 of its entrance, accelerating |

Rules:

- Entrances may be slow enough to read; exits are quicker and never settle.
- When a state must feel immediate, change the state now and let the residual settle afterward. Input feedback must not wait for the animation.
- A list of simultaneous updates is not one entrance; stagger only elements a person perceives as a group.
- UI timing is shorter than video timing for the same distance. A 1080 px frame and a 1080 px viewport are not the same event.

## 4. Lead and reactions

A group has one lead and followers at uneven offsets, in milliseconds:

```text
0, 40, 90, 150, 220, 300
```

For more followers, keep adding about 70 ms and cap the group at a duration a person will wait for. An even stagger (0, 80, 160, 240) reads as a loop; uneven offsets read as a chain of causes. A tight wave one frame apart across many small items is a different effect, and it is fine when it communicates a single sweep.

## 5. Springs

Use a spring for direct manipulation and physical arrival: a dragged card settling, a sheet landing, an item added to a list. A spring passes its target, so never put one on opacity, colour or a value read as data; transforms only.

| Damping | Feel |
|---|---|
| 1.0 | No overshoot, long premium tail |
| 0.8 to 0.85 | Alive; overshoot felt more than seen |
| 0.6 to 0.75 | Physical, visible settle |
| below 0.55 | Cartoon; only for a deliberately comic beat |

`response` sets speed: 0.2 to 0.3 s snappy, 0.35 to 0.5 s standard, 0.5 to 0.7 s weighty. In CSS, approximate the result with `linear()` from a spring solver or use the Web Animations API; do not hand-write a `cubic-bezier` and call it a spring.

## 6. Text and content

Most interface text should simply be there. Decide the treatment per element before choosing a curve.

| Treatment | Reads as | Use |
|---|---|---|
| Hard cut | Confident, editorial | The default for labels, values, rows, supporting copy and state text. |
| In-place swap | A value changed | Counters, status, selected option. Animate the swap, not the container. |
| Line or block reveal | A new context arrived | The primary heading of a new surface, once. |
| Typed text | Something is literally being written | Streaming responses, terminals, search-as-you-type. Not ordinary copy. |
| Character resolve / scramble | Machine output, identifiers | Session ids, hashes, short machine states. |
| Tracking settle | Premium, cinematic | A hero wordmark or a single title; not body text. |
| Opacity fade | Quiet presence change | Secondary overlays and crossfades that mean "becomes". Never every element. |

Avoid blur-in, fade-up on every section, gradient or shimmer text, drifting glow, and animated underlines on every link. Those are template tells. Motion blur belongs to fast travel, not to appearing.

## 7. Continuity and layout change

- **Shared element.** When the same object persists across two layouts (card opens into a detail), keep it continuous: the browser View Transitions API, a library's shared-layout helper, or a measured FLIP. Feature-detect it and gate it behind reduced motion.
- **List reorder.** Animate the moved item's transform, not `top` or `order`. Use FLIP when the layout is measured; otherwise insert with a short settle and keep the rest still.
- **Expand and collapse.** Prefer `clip-path` or a scale on a wrapper over animating `height`; when height is unavoidable, keep the duration short and never block the disclosure on it.
- **Origin.** A surface that opens from a control should share that control's transform-origin. A menu that appears from nowhere is a teleport.
- **Holds.** A hold with no living detail is a dead frame only if the piece is a video. In an interface, a still state is correct; do not add motion to fill time.

## 8. Server-rendered and LiveView surfaces

- Animate an element on **mount**, not on every patch. A stream append should make the new item appear without replaying the list's entrance.
- Keep animated state in the DOM (`[open]`, `[aria-expanded]`, `data-state`, `phx-click-loading`) and let CSS transition it. Prefer CSS over client timers that can fight a patch.
- Do not animate a container that the server replaces; the animation restarts and the page looks unstable.
- Use JavaScript hooks only for what CSS cannot express: measured FLIP, pointer-follow, drag. Recompute after patch with the framework's lifecycle, and clean up listeners.
- Do not hide a pending action behind an animation: `phx-click-loading` feedback may be motion, but the action itself proceeds.

## 9. Reduced motion

Under `prefers-reduced-motion: reduce`:

- Replace travel with a cut or an opacity change of 100 ms or less. The state must remain readable.
- Stop loops, parallax, wiggle and auto-playing motion; keep essential progress legible without a decorative loop.
- Keep the same information order and the same feedback timing; do not remove feedback, only its movement.
- Offer a user toggle only if the product also exposes other motion preferences; the media query is the baseline, not a substitute for a real preference.

## 10. Check

Step through the flow and ask:

- Does any property use a named preset or `transition: all` because it was the default? Replace it with a curve chosen for that move.
- Do simultaneous elements start together or in an even line? Give the group a lead and uneven reactions, or make one change instead of many.
- Does every text block animate in? Cut most of them; keep one crafted entrance where it means something.
- Are exits shorter than entrances and accelerating out?
- Does a stream, poll or reconnect replay an entrance? Fix that first.
- Is anything looping without meaning, or moving after the state already arrived?
- Is there a reduced-motion path that keeps the state legible?
- Count the devices. More than one signature transition per surface, or a device on every change, is too many.
