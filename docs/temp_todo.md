# Temporary Clarification List — Road of the Beasts

Central list of open design decisions and validation tasks from the three GDDs. The order below is a proposed work sequence, not a new game rule. **Work only in `docs/` and on `docs/update_gdd`.**

## Usage

- The GDDs describe the current working state; existing proposals and numbers are **not automatically approved** by moving open tasks here.
- Open questions, alternatives and review tasks are maintained exclusively here. The GDDs hold the current design, including labelled content drafts and prototype deviations needed to distinguish it from historical implementations. Use Git history to trace changes; do not maintain changelogs in the GDDs or this file. Keep the handoff current rather than appending a running change history.
- Complete the items listed under “Prerequisites” before deciding the topic. Independent items in the same phase may be worked on in parallel.
- **Session close:** refresh [Context Handoff](#context-handoff) after every session so another agent/computer can resume without chat history. Reusable instructions belong under [AI Prompts](#ai-prompts), not in the active task list.
- On completion: incorporate the decision into the specified GDD sections, synchronize affected companion files and check off the item here. For playtests, document measurements and results before changing rules if necessary.
- **Task fields:** every editable task carries **Status**, **Prerequisites**, **Sources**, the concrete gap/decision bullets and **Done when** (completion conditions). Status values: *Open* (no decision yet), *Partly drafted/decided* (working draft or partial decision exists, not validated), *Blocked* (named prerequisite or user decision missing). Completed tasks move to [Completed Tasks](#completed-tasks-ids-retained-for-references) with their IDs retained; IDs are never reused for other topics. Validation tasks close only with tests actually performed and documented.
- **D** = design decision, **V** = validation/balance, **K** = consistency correction. Sources refer to the current GDD section numbers unless explicitly labelled historical.
- **Central skill specification:** [Monsters chapter 4](gdd_monsters.md#4-skills). It defines the kit, construction kit, schema, validation, access and slot development. Battle describes generic runtime/board resolution; Overworld only meta integration, economy and its own tamer/loadout content. Do not maintain parallel monster-skill price lists or upgrade rules. Historical statements are not active specifications.

# Context Handoff

**Last updated: 2026-11-09.** Read this section when changing agents or computers; do not rely on earlier chat history. **Update it at the end of every session**, replacing stale context rather than appending a log. Keep rules and prices in their owning GDDs.

## Current State and Immediate Next Step

- **Focus/result:** continued T02's shared authoring/calibration foundation before existing skill development. Integrated evaluation with the existing model, selected shared valuation standards, added the temporary arithmetic checker, and documented the user's square-control and body-relative movement decisions. Latest resolved topic: hit-independent self retreat after the attack, including failed-retreat behaviour. Owners and status are linked below; T02/T04/T06/T09/T13 are not complete.
- **Next actions (in order):**
  1. Ask the user to settle remaining self-retreat traversal/entry/height rules, including diagonal obstruction and Mountain transitions. Start with [Monsters' body-relative variants](gdd_monsters.md#body-relative-damage-and-movement-variants), [self movement/effect contracts](gdd_monsters.md#44-effect-and-board-operation-contracts), [Battle ground](gdd_battle.md#47-ground--neutral-hazard-and-blessed) and [collision/fall](gdd_battle.md#63-collision-fall--debris). Do not reopen the confirmed hit independence, attack-before-retreat order or no-effect failed retreat. The user's “like push” analogy did not explicitly approve a blanket removal of forced-movement collision damage; retain that distinction unless separately decided.
  2. Resolve ordering within the attack payload, multi-target movement/deduplication and owner-removal cases (T04). Use [Battle displacement](gdd_battle.md#65-displacement) and the central effect contracts; do not infer order from data-field order. Non-adjacent/off-axis and 2×2 mappings remain T09; no invented direction normalization or self retreat for ambiguous patterns.
  3. Reconcile the new variants' access and Winged/Scaled identity with [Kin Strikes](gdd_monsters.md#32-strike-by-kin), then draft their related AP/component costs together in [§4.5](gdd_monsters.md#45-construction-points-and-ap-efficiency) (T02/T06). Do not silently replace existing Kin packages, import the old direct-Shove fee or introduce a damage-for-distance trade. Extend [the checker](temp_kalkscript.py) only after the relevant contracts/prices are resolved.
  4. Continue remaining event/recursion, non-offensive utility and prop-reaction foundations before returning to old-skill calibration/development paths. T05 still needs advancement-step/slot-level mapping, supply, deferral, choice location and respec decisions under [§4.6](gdd_monsters.md#46-slot-levels-development-replacement-and-upgrades)/[Overworld §6.3.2](gdd_overworld.md#632-permanent-skill-slot-development-confirmed). T26's Ambitious Standing comparison remains an independent user decision.
- **Blockers:** new movement variants lack complete traversal/order/access/price contracts; repeatable and other unpriced event availability, special prop reactions and later-resolution semantics remain unresolved. Existing budget conflicts are not approved content restrictions, unlocks or reasons for automatic AP/budget changes. T13 has no executed current-design battle tests; neither historical prototype is a current-design validation baseline.
- **Git/commit observation:** branch `docs/update_gdd`; pre-commit HEAD `653ded9`. The user explicitly requested committing all session changes: `docs/gdd_battle.md`, `docs/gdd_monsters.md`, `docs/temp_todo.md` and the new `docs/temp_kalkscript.py`. This handoff is included in that commit; obtain its resulting hash and working-tree state from Git rather than a self-referential hash here. No branch change or remote synchronization requested/performed; remote freshness/ahead-behind not checked. Recheck Git on the next machine.
- **Validation actually performed:** during this session the checker's 17 self-tests passed, all eight example JSON roundtrips and expected success/over-budget/unsupported exit codes were checked, and scoped price/decimal arithmetic plus the adjacent-direction equations were recomputed. Relative links/anchors were checked after structural edits; later retreat decisions received targeted text assertions and `git diff --check`. At handoff close: re-read `CLAUDE.md`, Usage, handoff, affected tasks and current owning sections; reran the 17 checker self-tests, local links/anchors and `git diff --check`; verified that tasks, AI Prompts and other files were preserved. **Not performed:** full GDD content/rate audit, full-model or new movement-variant calculator support, browser/prototype execution, gameplay/balance/landing/collision/recursion tests. Passing arithmetic is not design or balance validation.

## Decisions Versus Drafts

| Class | Content (owner section holds the details) |
|-------|-------------------------------------------|
| Confirmed design / scope | [§4.2](gdd_monsters.md#42-data-oriented-skill-construction-kit): one model and internal pre-release evaluation, independent activation/repetition fields, per-equipped-copy allowances and valid-activation consumption; shared zones, no generic team filters or direct unit-targeted monster attacks/offensive push-pull. [§4.3](gdd_monsters.md#43-skill-execution-profiles): concurrent Surges under skill-instance policies, spatial no-overlap retained; additional body-relative damage/movement variants and the scoped coupled geometry/retreat decisions. Skill rarity was rejected; existing [shared-budget principles](gdd_monsters.md#45-construction-points-and-ap-efficiency) and [slot-development policy](gdd_monsters.md#46-slot-levels-development-replacement-and-upgrades) remain. Neither new concrete skill content nor automatic Kin changes follow. |
| User-selected calibration, not validated balance | [Shared standards](gdd_monsters.md#shared-valuation-standards), [availability by activation and usage](gdd_monsters.md#availability-by-activation-and-usage), [active round-limit calibration](gdd_monsters.md#round-limited-availability-calibration) and their owning §4.5 tables. The event rate applies only when the authored usage policy explicitly supplies its round cap; it is not a default for event-driven skills. Keep prices in their owner, not in the handoff. |
| Still proposals / incomplete | Other labelled §4.5 packages, [conditional-outcome costing](gdd_monsters.md#ground-and-board-costs) and the separate [Mountain-price candidate](gdd_monsters.md#mountain-destruction-calibration-proposal) are not approved merely because shared standards were selected. New body-relative AP/component costs and complete skill paths remain open. Repeatable/other event availability has no general price; missing contracts/prices never mean zero. |
| Earlier decisions preserved | No aspect/Attunement system (completed T01/T33/T34); Mountain end state in [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed); no physical evolution/EP currency (T36), advancement-based slot development in §4.6; Staff model B and Favor + Standing principles, with numbers open. Expedition HP/retreat remains the working design; no new decision reopens it. Day-AP values remain a proposal, not a session approval. |
| Validation / tool boundary | [temp_kalkscript.py](temp_kalkscript.py) is the explicitly authorized temporary implementation inside docs, not an engine/prototype change or a second price/model authority. It supports selected reference arithmetic and rejects unsupported effects; it does not validate the new body-relative variants, passive/event effects or full battle behaviour. T02/T04/T05/T06/T09/T13 remain open; no task closes from a numeric fit. |

- Preserve the [basic-Surge AP target](gdd_monsters.md#combination-policy-and-basic-surge-target) and existing [Strike damage contract](gdd_monsters.md#32-strike-by-kin) while resolving calibration conflicts. New movement variants do not authorize direct-damage upgrades or a generic damage/movement exchange. Large-body hit multiplicity remains unresolved.

## Working Practices

- Follow [CLAUDE.md](../CLAUDE.md): only `docs/update_gdd`, docs-only writes, preserve user work, no unrequested Git actions. The user's checker exception is confined to the temporary script in docs; prototype/engine implementation remains outside scope. The closeout authorizes the handoff update and the subsequently requested commit of session changes, not further design/code changes or remote synchronization.
- Resume from the current tasks and linked owners, not prior chat. Complete the shared foundation before revisiting existing skill paths. Use the existing §4.2 fields/contracts and §4.5 rates, never a parallel model, copied price list or name-specific budget-fit exception.
- New recommendations/numbers require explicit status; general design changes require user decisions. Earlier editorial consolidation and successful arithmetic do not finish design/validation tasks. Keep history in Git, replace stale handoff text rather than appending a log.

# Open Tasks

## Recommended Work Order (2026-11-08 review)

The order is a proposal, not a rule. Statuses and prerequisites below are authoritative per task.

| Step | Work | Tasks | Reason |
|------|------|-------|--------|
| 1 | Complete shared valuation coverage and draft standards through the existing data model | T02 (part) | Current user priority: finish the foundation before calibrating existing skills; no duplicated effect schema or skill-specific fit exceptions |
| 2 | Finish the Surge cross-check, then draft same-AP development paths (Run, Slowing Zone, Surge with ground effect, Jab) | T02 | Established sequence; do not reopen budget/AP/damage principles |
| 3 | Draft the slot-development step model (steps granted at advancements, no EP currency) | T05 | T36 is decided; T05 needs the T02 development paths |
| 4 | Editorial and consistency corrections that need no gameplay decision | T03 (K findings), T06 naming, T13 wording | Can run in parallel; report each fix |
| 5 | Remaining resolution contracts | T04, T07, T08, T09 | Prerequisites for T10–T13 |
| Parallel | City powers and non-battle catalogues | T15, T16 (non-battle part) | Independent of monster-skill work |
| Parallel | Ambitious Standing comparison | T26 (user decision) | Small, independent decision |
| Parallel | Remaining editorial deduplication | T37 | No prerequisites; coordinate with T35 |
| Later | Skills/roster, battle tests, then meta numbers | T10–T14, T17–T35 | Follow the prerequisites in each task |

## Phase 1 — Clarify Foundations and Conflicting Rules

### [ ] T02 · Complete the Data Model, Point Calculation and AP Efficiency (D/K)
**Status:** Partly decided/drafted — internal authoring-only evaluation and two repetition policies confirmed; skill rarity removed. Active round-limited and event/explicit-once-per-round availability selected, still unvalidated; repeatable/other event valuation and remaining event-order/recursion and later-resolution contracts are unresolved. Integrated model/evaluation bindings and shared-standards extension selected by the user; numeric balance remains unvalidated. Affected paper references are synchronized, budget conflicts unresolved and special-reaction/event/utility-targeting coverage incomplete. Skill-specific recalibration is deferred until the shared foundation is complete.
**Prerequisites:** T01.
**Sources:** Monsters [§4.1](gdd_monsters.md#41-the-kit)–[§4.7](gdd_monsters.md#47-complete-references-and-validation); Battle [§2.3](gdd_battle.md#23-action-points)/[§5.1](gdd_battle.md#51-monster-skills-central-specification); [Overworld §6.3.2](gdd_overworld.md#632-permanent-skill-slot-development-confirmed).

**Drafted and documented:**
- Shared model for all monster skills, central profiles/contracts and six references; no parallel skill sources or custom special structures. Designer-authored skills/upgrade choices instead of player construction.
- Shared budget ceilings 24/30/36, AP efficiency 12/6/3/1/0, damage factor 2 and 50% exclusively for telegraphed, avoidable Surge damage as selected working drafts. **No combination surcharges.**
- Draft tables for all Strikes/movement profiles, self/passive, zones/protection/healing and ground/board. Six references with initial totals, not yet full content/balance validation. Maintain prices only in [Monsters §4.5](gdd_monsters.md#45-construction-points-and-ap-efficiency), not duplicated here.
- Surge residue = delayed ground change; concrete profiles retain their authored ground types. Permanent aftermath uses the selected no-delay-discount standard in §4.5. Basic Surges retain the 1-AP target; budget conflicts remain open.

**Current priority — complete the shared foundation before existing skills:** §4.2's [evaluation contract](gdd_monsters.md#evaluation-contract--one-definition-one-calculation) binds all 14 existing field groups to their costing responsibilities. Do not add a parallel price-input schema or duplicate §4.4 mechanics. Complete the owning §4.5 standards as one coordinated draft; existing skill comparisons/development paths follow afterward.

- Apply the user-selected [shared valuation standards](gdd_monsters.md#shared-valuation-standards) and extensions in the owning movement/passive/board sections; balance remains unvalidated. Movement increments must not create different prices for identical resolved presets. Extra prop damage must not also be charged through a Kin package.
- Remaining coverage gaps: new coupled body-relative movement packages, authorized utility/layer/recipient contracts (not general area filters or direct-unit offensive displacement); event-driven/repeating/team-wide passive limits and availability; special prop reactions beyond extra on-hit damage; other rule permissions and non-covered movement patches. Mark missing rates separately from missing mechanic contracts; neither means zero cost or permission to invent a default.
- Existing shared standard drafts already cover active AP efficiency, basic selection/geometry, damage, ordinary displacement, current zone effects, movement presets, the limited self/passive references and listed board packages. Their numeric balance is not confirmed. The separate alternative Mountain price remains unapproved, not a general standard.


**Body-relative damage/movement foundations (T02/T04/T06/T09):**
- Confirmed geometry and variant options are owned by [Monsters §4.3](gdd_monsters.md#body-relative-damage-and-movement-variants), not repeated here. New variants are additional authored skills, not replacements for all Strikes or a freely adjustable damage/movement trade.
- Self retreat's hit independence is confirmed in §4.3; do not reopen it or price it using hit probability. Attack-before-retreat and no-effect blocked retreat are also confirmed there. Define remaining path/entry/height behaviour; distinguish self movement from forced displacement. Battle §6.3 still damages monster/prop on blocked prop push, so the user's “like push” analogy is not a blanket collision-law change; clarify separately if the user wants that broader change. Retreat does not implicitly damage props or destroy Mountains; authored payload permissions remain binding.
- Reconcile access and Kin identity: Scaled's chosen push direction and Winged's existing retreat are not automatically replaced by the new coupled geometry. Preserve existing definitions/prices until explicitly decided; no transfer of all Kin packages to all skills.
- Calibrate AP and component prices together after these contracts; the existing cardinal displacement/retreat rows are not automatically the prices of coupled eight-direction variants. No approved direct-damage reduction upgrade or distance increase follows. Define multi-target ordering/deduplication in T04 and unsupported non-adjacent/2×2 mappings in T09; no direction normalization or retreat for ambiguous shapes.
- The temporary checker still supports cardinal zone push/pull only, not this new geometry. Extend it after contracts/prices are resolved; do not use its old cardinal examples as validation of diagonal behaviour.

**Temporary arithmetic checker:** [temp_kalkscript.py](temp_kalkscript.py), Python 3 standard library. From the repository root:

```sh
python3 docs/temp_kalkscript.py --self-test
python3 docs/temp_kalkscript.py --example slow
python3 docs/temp_kalkscript.py --example surge --slot-level 2
python3 docs/temp_kalkscript.py --example ground --slot-level 2
python3 docs/temp_kalkscript.py --example hallowed
python3 docs/temp_kalkscript.py --example mountain --slot-level 2
python3 docs/temp_kalkscript.py --example zone_push --slot-level 2
python3 docs/temp_kalkscript.py --example zone_pull --slot-level 2
python3 docs/temp_kalkscript.py --example jab --export-example
python3 docs/temp_kalkscript.py docs/temp_skill.json --slot-level 1
```

`--export-example` prints editable JSON using the same 14 field groups, not a new engine schema. Input `-` reads stdin. Set `usage.repetition` to `once_per_global_round` to test the selected active limit on reference geometry; Slow duration 3 demonstrates fractional totals. Decimal report values are JSON strings to preserve precision. Exit codes: **0** numeric fit, **1** over ceiling, **2** incomplete/unsupported/invalid input or failed self-tests. The script does not write files. Supported arithmetic for 1×1 bodies: Slow zones (2/3 rounds), fixed one-square cardinal zone push or cast-anchor pull (alone or combined with Slow), residue-free Surge, cardinal Beast Jab, standalone Lava/Thornbed/Blight I, Hearth/Umbra/Hallowed and Mountain creation including its coupled Plain reset. Board packages include persistence and ordinary source-bound occupant consequences; do not add a second damage/buff/cleanse charge. Blessed standalone ground retains its owning AP price. `ground`, `hallowed`, `mountain`, `zone_push` and `zone_pull` export examples using the existing fields. The effect list can combine one Slow and one displacement without repeating shared fees; the sum is not interaction/order/content approval. Mossbed/re-entry, Water/Voidscar edits, prop packages/special reactions, direct unit displacement, authored Surge aftermath/push/collapse combinations, other Kins and passive/event evaluation remain unsupported. Missing contracts/prices are not zero-cost defaults. It does not prove footprint legality, access or interaction contracts. Do not omit unsupported components to obtain a passing result. GDD heading/table changes intentionally fail closed until parser review; the script owns no alternative price list. Full coverage is still T02, battle validation T13.

**Shared repetition — decisions and remaining gaps (T02/T04/T05):**

- **Authoring/test boundary (clarified):** calculate from a complete authored definition before adding the skill to the game, like a script/test. No in-battle construction calculation, actual-destruction pricing or user-facing point system. Runtime triggers matter only as declared capability/conditions; no new positive-damage trigger rule or once-per-causal-chain restriction was approved. The user explicitly authorized the temporary checker inside docs; this grants no engine/prototype implementation scope.

- **Event valuation selected, unvalidated:** use the [availability table](gdd_monsters.md#availability-by-activation-and-usage) derived from existing activation and repetition fields. The selected event rate requires an explicitly authored round cap and a resolved one-activation package; no probability credit or active availability discount. Repeatable event and team-wide availability remain unpriced; no automatic round cap or new skill class.
- **Shared repetition options confirmed:** use [Monsters §4.2](gdd_monsters.md#usage-and-repetition), not a passive-only workaround. No existing skill is silently assigned the round limit; active availability calibration is selected in §4.5, and the event/explicit-once-per-round rate is selected; repeatable/other event availability remains open. Remaining dimensions:

| Existing model responsibility | Decision needed |
|---|---|
| `usage`: count and scope | Per-equipped-instance allowance and valid-activation consumption are confirmed in §4.2. Invalid attempts consume neither AP nor allowance; later-resolution validity/cancellation still requires T04 |
| `usage`: reset boundary | Two options selected: repeatable under existing limits or once per global round. No owner-turn reset, multi-round lockout or additional count category is introduced; existing profile limits remain binding |
| `execution` / effect application | Distinguish recasting a zone from its existing effects applying again; passive activation count from recipient count; no automatic per-target/per-prop multiplication |
| `persistence` | Existing state/zone lifetime is separate from usage reset; reapplying/levelling/refreshing rules need consistent integration |
| `evaluation` | Derive authoring-time availability from these declared limits; no live counters or observed event probabilities in the price calculation |

Select the policy explicitly for future authored skills; do not assume all zones/passives share one limit or alter existing content without review. Recursion safety, simultaneous order and owner removal still need T04; no causal-chain cap was approved. Apply the [selected active round-limit calibration](gdd_monsters.md#round-limited-availability-calibration) only within its scope; it excludes ineffective caps and unresolved event-driven availability. Skill rarity is removed; monster rarity is unchanged.

**Cost-structure review (documentation only, not price approval):**

Reviewed Monsters §4.5 price families and §4.7's three area-reference records plus the non-area references' scope declarations. No demonstrated duplicate charge was found in the reviewed baseline formulas; unresolved prices and effect contracts prevent a blanket completeness claim. “One-time damage” was relabelled “One-shot damage” to distinguish event timing from flat-per-use pricing.

| Charging basis | Existing component families | Review result |
|---|---|---|
| Once at applicable use/availability scope | AP efficiency or passive availability; anchor/selection; complete marker; footprint direction; ground/air coverage | Structurally consistent. Selection alternatives are not cumulative; footprint direction and push direction are distinct permissions. |
| Potential effect cells, with explicit magnitude/duration where applicable | Damage; distant Strike cells; per-target Kin effects; displacement; zones; ground/height operations | Structurally consistent. The footprint is already priced; no second blanket area charge. Per-cell maxima still need legal coexistence under the conditional-outcome draft. |
| Authored non-area or object package | Movement preset; one retreat per Strike use; rotation permission; self-buff magnitude/duration; created/relocated prop | Structurally consistent, not an exception requiring universal cell pricing. A path is not an effect footprint; a prop package is per object, not an additional area fee. |
| Included consequences | Permanent ground's existing future occupant effects; ordinary offensive prop reactions; Mountain creation's coupled reset | Already bundled, not separately charged again. This does not settle special reactions or authorize missing effects. |

**Decisions still needed, rather than editorial inconsistencies:**
- **Decided working valuation:** shared one-shot displacement timing and permanent-ground treatment are selected, not a universal whole-skill multiplier. Runtime effect permissions remain unchanged; validate values later under T13.
- **Duration/repetition basis:** zones are priced by authored rounds; ground is a permanent per-cell package; self-buffs and the sample passive use their own lifetime/availability basis. The categories are coherent, but comparative value depends on unresolved recasts, stacking, triggers and healing loops (T04/T07/T13). No invented lifetime multiplier can resolve that contract gap.
- **Selection/coverage completeness:** remaining non-offensive utility target eligibility/LOS and authorized layer variants need resolved contracts before pricing. Offensive monster push/pull now uses spatial patterns; do not reopen or price a direct unit-targeted Shove. General ally-only/enemy-only area filters and generic direct unit-targeted damage are excluded by [Monsters §4.2](gdd_monsters.md#42-data-oriented-skill-construction-kit); do not maintain a filter-price task. Existing adjacent-anchor selection has a selected rate, not an unresolved price gap.
- **Board packages and reactions:** coupled Mountain creation/reset is one package; explicit destruction plus residue is confirmed additive. Special prop reactions and conditional-outcome valuation still require review with T04. Their absence is a pricing gap, not evidence of double-charging or zero value.
- **Calibration rather than structure:** movement alternatives, passive availability, Kin components and board packages still need comparative evidence. The Mountain candidate remains budget-derived and unapproved; large-Strike/healing conflicts are not solved by the confirmed cost structure.

**Still to do:**
- Complete the scoped [1-AP Surge comparison](gdd_monsters.md#basic-surge-profile-cross-check) only after the foundation gaps are resolved. Current arithmetic follows selected shared rates and exposes budget conflicts, not approved restrictions or unlocks. Conditional-outcome costing remains draft; collapse and residue stay additive, with collapse damage environmental rather than skill damage. Extra on-hit prop damage has a selected rate, but other reactions/combined outcomes and runtime order remain T04/T07; unsupported spatial cases remain T09.
- Review the [Mountain-destruction calibration proposal](gdd_monsters.md#mountain-destruction-calibration-proposal): shared-component repricing affects Ancient Strike too; the separate candidate no longer fits the shown Rift subsets under current ground pricing and does not resolve full profile pricing.
- Resolve budget conflicts for large Strikes, healing and complex Surges specifically, without automatically changing budgets/AP/damage or introducing separate skill-type pools. No double-charging for area/flags/sources.
- Draft complete development paths at original AP, especially Jab; larger shapes retain existing AP until a new decision. No direct damage, AP-reduction or cast-range upgrades. Then T05.
- Complete missing footprints/anchors/orientations, visibility/target validity, effect values/caps, triggers/end conditions and interaction order. Explicitly define self/passive stacking, source groups, death/removal and repetition/recursion. The self-buff reference remains a draft; no new mechanic is authorized solely by a schema field.
- Review combinations and repetition as balance/contract questions, **not as an additional price category**. Include props, healing, air and 2×2 under T04/T07–T09. Validate numbers only through suitable tests; T13 remains open.
- **Decided:** costing structure and decimal-point handling are defined in [§4.5](gdd_monsters.md#45-construction-points-and-ap-efficiency). This resolves the fractional-point policy gap, not the documented calibration conflicts above the working ceilings (large Strikes, mend zone, longer Slow zone, height-capable Surge); arithmetic consistency is not balance validation.
- **Done when:** (a) the scoped [1-AP Surge comparison](gdd_monsters.md#basic-surge-profile-cross-check) is re-run without unresolved profile gaps; (b) each budget/calibration conflict is either resolved by an explicit user decision or documented as an accepted content restriction, with no hidden price, budget, AP or damage change; (c) same-AP development paths for Run, the Slowing Zone, a Surge with intended ground effect and Beast Jab are drafted and reviewed; (d) the footprint/anchor/orientation, effect-value, trigger, stacking contracts are decided or explicitly handed to T04/T07/T09; (e) [§4.5](gdd_monsters.md#45-construction-points-and-ap-efficiency)/[§4.7](gdd_monsters.md#47-complete-references-and-validation) are recalculated. Balance approval stays with T13.

### [ ] T03 · Review Stat Budgets, Frames and Progression Limits (V/K)
**Status:** Open — consistency findings confirmed by the 2026-11-08 review (see bullets marked *new*); no frame/budget playtests run.
**Prerequisites:** T02.
**Sources:** Monsters [§2.1](gdd_monsters.md#21-the-stats)–[§2.3](gdd_monsters.md#23-stat-ceilings-per-stage), [§7.4](gdd_monsters.md#74-monster-progression-the-18-steps); Overworld [§1.2](gdd_overworld.md#12-design-pillars), [§2.4](gdd_overworld.md#24-cultivation-loop).
- Check prices, budgets and all scaled frames; Reach costs 3 points per level and now affects all casts. Test Reach-2 individuals against current Surge footprints and Reach ceilings (the former “old Surge radius 3” reference no longer appears in any GDD).
- Init on roll: 1 point = 1.0; on level-up: 0.1. Equal points received do not necessarily mean equal resulting strength; compare freshly rolled and raised individuals.
- Unify Stage versus exact sub-tier as the monster cap ([Monsters §7.4](gdd_monsters.md#74-monster-progression-the-18-steps) names the step, other texts only the Stage).
- Some Overworld texts still limit spent points by the frame; the monster GDD limits only the roll by the frame.
- Step-only monsters: explicitly resolve random Movement points versus “stays at frame minimum”.
- *New (K):* the stage-scaling text in [Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups) says Reach scales with *stage ceiling ÷ Core ceiling*, but the all-stages table is reproduced only with a ratio of (ceiling − 1) ÷ (Core ceiling − 1) and round-half-up (e.g. Reach 2 becomes 3 at Soul+); the literal text gives Reach 2 and lowers the Soul+ ranges by up to 3 points. Rounding is unspecified. Fix either the rule text or the table.
- *Done (K):* the “unspent points” note in Monsters §2.2 now also lists Qi Balanced/Fragile (max 20 against Qi High 21, 1 point unspent), checked against the all-stages table.
- *New (D/K):* “TPR 2+ frames cap AP at 2” versus “TPR 2+ caps AP at 3”: clarify whether a TPR 2 body may spend level-up points on AP 3 from Core.
- **Done when:** each finding above is resolved in its owning section (Monsters §2.2/§2.3/§7.4, Overworld §1.2/§2.6) or consciously deferred; the V part closes only after documented frame/price/budget/ceiling tests (shared with T13).

### [ ] T04 · Make Resolution Rules and Edge Cases Consistent (D/K)
**Status:** Open — the height-collapse end state is decided (user, 2026-11-08, applied in Battle §4.7); combined-order, Strike-plus-collapse damage and prop-redesign questions remain.
**Prerequisites:** T01, T02.
**Sources:** Battle [§2.2](gdd_battle.md#22-initiative-rules), [§4.1](gdd_battle.md#41-battlefield-generation), [§4.4](gdd_battle.md#44-square-data-model), [§4.8](gdd_battle.md#48-no-attunement), [§4.10](gdd_battle.md#410-damage-shatter--prop-types), [§6.1](gdd_battle.md#61-the-damage-law)–[§6.3](gdd_battle.md#63-collision-fall--debris); [Monsters §5](gdd_monsters.md#5-passives).
- Collision: the damage law includes monster collisions, but the detailed rule says no damage. Cross-check Crashlander. Retired collision bonuses (the roster still lists Shockwave as a utility skill) remain unapproved per [Monsters §4.4](gdd_monsters.md#44-effect-and-board-operation-contracts); no exception to the fixed event-damage law has been approved.
- Define the resolution order for Surge damage/residue/displacement and Strike damage/displacement; explicitly define Pull ties and behaviour when the anchor is already occupied. Preserve each source's explicit permissions.
- Protection sources: define stacking, order and consumption when damage is reduced to 0; distinguish passive-, zone- and ground-based protection sources without transferring permissions between them. Coordinate tamer exceptions with T20.
- Combined board operations: define the order of Mountain collapse (1 additional damage), skill damage, Residue, Debris and Cleanse. The final ground is decided (destroying skill's own ground, otherwise Rubble); order is not. Specify Relocate distance, path, legal targets and reactions. Do not derive free defaults from data-field order.
- Ancient Slam destroys a Mountain: the 1 collapse damage is environmental (like Voidscar), so it is not Strike damage and the “Strike: max 2” law is unaffected.
- T01 removes the Attunement/Elevated conflict; check remaining combinations of height and concrete ground types.
- **Elevation / Mountain (user decisions, applied to the GDDs):** Elevated stays and is renamed **Mountain** (all height-creating skills create one). Destroying one needs an explicit authored operation; the occupant takes **1 environmental collapse damage** (independent of skills, like Voidscar damage; not skill damage); the ground then becomes the destroying skill's own ground if it can change ground on a Mountain, otherwise Rubble. Creating one keeps the Plain reset (non-Voidscar). **Props and Mountains are independent** (debris no longer collapses neighbouring Mountains). Ground-layer monsters on a Mountain can hit air-layer monsters on squares adjacent to their own square with all attacks, at no extra price (details T09). Yardstick: “easy to learn, hard to master” ([CLAUDE.md](../CLAUDE.md)). Remaining: check the Raise Ground Plain-reset wording and the per-profile Surge Mountain behaviour (Eruption: no ground change on a Mountain; Flood: cannot reach; Rift: destroys) against this rule once pricing is decided.
- Zone values without Attunement: keep hard caps for Slow (2) and Push/Pull (1) consistent with level scaling.
- **Prop revision:** shared impact/reaction contracts; define broadly destructible props and concrete exceptions/resistances. Destruction type determines splinter/fall effects and residue instead of identical Shatter every time. A tree may split; initially use falling effects plus ground/visual residue, not separately movable halves. Predict fall direction, hit squares, damage and resulting state deterministically. Impact categories, prop catalogue, HP/damage matrix, chain reactions and event order remain open. Existing numbers are interim, with no new blanket hit permissions. For pricing, ordinary prop damage is provisionally a shared baseline without surcharge ([Monsters §4.5](gdd_monsters.md#45-construction-points-and-ap-efficiency)); review special advantages and costs after the redesign.
- Sigil is enterable; the prop rule says “the prop takes damage, not the monster there”. Define hit order for monsters on field props.
- Clarify target validity on resolution: moved, fallen or removed unit/prop targets and placements that have become invalid. No implicit tracking, retargeting or invented cancellation/refund defaults. Define simultaneous events and expiry/trigger order deterministically.
- Specify Surge behaviour with multiple turns per round, changed initiative or a dead caster: “next caster turn” does not guarantee everyone else acts first. Multiple concurrent casts are now allowed; define deterministic ordering when several are due at the same event, including interacting board changes. Do not infer cast-order resolution or simultaneous snapshot evaluation.
- Define deterministic ties for Voidscar selection, Push/Pull destinations and free dodge squares.
- Check point-symmetric generation against odd prop counts; define legal central single objects for each board size.
- **Done when:** the user's end-state decision is recorded in [Monsters §4.3](gdd_monsters.md#43-skill-execution-profiles) and Battle §4.7/§4.9; every contract listed above has a deterministic rule in Battle §2.4/§4/§6 with the Monsters §4.4 interfaces updated; the interim prop rules are replaced or explicitly kept; no resolved item still carries a T04 marker in the GDDs.

## Phase 2 — Skills, Development and Monster Identity

### [ ] T05 · Complete Skill Improvements (D)
**Status:** Partly decided — principles confirmed (slot development granted at advancement steps, no EP currency, pill-based replacement, no damage/AP/range upgrades); step-to-level mapping, supply, deferral and respec rules open. Needs T02.
**Prerequisites:** T02.
**Sources:** [Monsters §4.6](gdd_monsters.md#46-slot-levels-development-replacement-and-upgrades) (slot development), [§7.2](gdd_monsters.md#72-monster-rarity)/[§7.4](gdd_monsters.md#74-monster-progression-the-18-steps) (step supply/progression draft); [Overworld §6.3.2](gdd_overworld.md#632-permanent-skill-slot-development-confirmed) (integration).
- **Decided (user, 2026-11-08):** permanent skill-slot development is granted only at advancement steps ([Monsters §7.4](gdd_monsters.md#74-monster-progression-the-18-steps): the five breakthroughs plus the listed later sub-tier steps) as an option to develop one slot; there is no EP currency, no purchase and no physical evolution. Each step directly grants a designer-authored, skill-dependent upgrade choice; no additional player point currency. Rarity sets steps per advancement (1 Normal/Rare, 2 Epic/Legendary, legacy values).
- **Decided:** replacing a skill from the unlocked species learnlist outside expeditions costs a valuable relearning pill. Slot development is preserved; suitable upgrades for the new skill are reselected within the existing development extent. No free re-slotting or step-paid swap path.

- **Next step:** draft the step model: steps per advancement, Normal's total of only two steps (Foundation and Core), how steps relate to slot levels 1–3 (ceilings 24/30/36), whether the choice may be deferred, and whether the Evolution Pillar keeps a role or the choice happens at the breakthrough (Trial Pillar). Check investment across multiple slots.
- **Decided:** slot levels 1–3 with increasing budget ceilings, no skill ratings. Define unlocks and possible intermediate development within these levels; do not assume another rank hierarchy.
- **Decided:** retain small fixed damage values. Slot upgrades do not increase direct damage, lower AP costs or increase cast range. Allowed improvement types: area, shape/orientation, duration, movement/displacement and explicitly designed additional effects, each with skill-dependent limits. Still check total impact through more targets or triggers.
- Design enough upgrade choices visible in advance, prerequisites, exclusions and caps for every skill; examine Shape, Size, Twist and Small value as candidates. Do not reintroduce removed legacy swap paths; replacement remains pill-based.
- Clarify how to handle slots with different numbers of legal upgrade offers, passive/passive-only slots and active/passive replacement. Do not lose slot investment on replacement.
- Still open: cost of reselecting existing upgrades of the same skill, refunding spent development steps and possible transfers between slots. Pill costs for upgrade respec are only a recommendation, not a decision.
- Specify the relearning pill: coordinate reliable acquisition, recipe, tier, price and day-AP with T16/T30/T31; deliberate replacement rather than constant rebuilding, without permanently penalizing experimentation.
- Distinguish generic Size maximum 4 from Strike shapes of up to 8 squares. Old conflicting Shape prices are obsolete; define concrete upgrade offers per step in the shared model.
- **Done when:** step supply (including the Normal rarity), step-to-level mapping, deferral, unlocks, upgrade offers per reference skill, passive-slot and active/passive replacement rules, same-skill respec/refund/transfer decisions, the Evolution Pillar's role and the relearning pill's acquisition path are decided; [Monsters §4.6/§7.2/§7.4](gdd_monsters.md#46-slot-levels-development-replacement-and-upgrades) and [Overworld §6.3.2](gdd_overworld.md#632-permanent-skill-slot-development-confirmed) are synchronized.

### [ ] T06 · Complete Strike Shapes and Kin Effects (D/V)
**Status:** Open.
**Prerequisites:** T02, T03, T05.
**Sources:** [Monsters §3.2](gdd_monsters.md#32-strike-by-kin).
- Only Jab before Core: do interesting shapes arrive too late? Storm/5-AP shapes only reach late TPR-1 builds.
- Test Whirl (4 squares) against Arc (3) at the same battle AP (3; their construction prices in §4.5 differ), and the value of Thrust's range. Naming is resolved: only “Thrust” remains in the GDDs.
- Beast Bite: give it its own effect without violating the damage ceiling, or deliberately accept the lack of an effect.
- **Done when:** every Kin's Strike shape access across the AP/stage gates and the Beast Bite effect question are decided, the Whirl/Arc/Thrust checks are documented, and [§3.2](gdd_monsters.md#32-strike-by-kin) and the §4.5 Strike cost table (which takes its AP and hit cells from §3.2) agree.

### [ ] T07 · Align Ground Interactions and Healing (D/V)
**Status:** Open — ordering questions wait for T04.
**Prerequisites:** T01, T02, T04.
**Sources:** Battle [§4.6](gdd_battle.md#46-zones-effects-rules--opposites)–[§4.8](gdd_battle.md#48-no-attunement); Monsters [§4.2](gdd_monsters.md#42-data-oriented-skill-construction-kit), [§4.4](gdd_monsters.md#44-effect-and-board-operation-contracts)–[§4.5](gdd_monsters.md#45-construction-points-and-ap-efficiency).
- Permanent residue: does the board fill too quickly, making start-turn hazard placement overpowered?
- Measure hazard coverage on 7×7 by round 5. If needed, examine Field at 2 AP or a maximum of N Field squares per monster as alternatives.
- Without the triangle, define whether and how zones change existing ground; do not infer automatic superiority from monster themes.
- T01 removes Attunement and painting snowball. Instead review counters to permanent hazard ground and their accessibility.
- Blessing: is 2 AP appropriate for 3–4 permanent squares? Limit Mossbed per turn?
- Zone `mend` (formerly “Boon”): check healing at HP 1–10; may zone level increase healing, or does it stay fixed at 1? Explicitly define the numerical healing cap and Mossbed re-entry/per-turn limit; persistence grants no additional healing triggers.
- Evaluate level-II residue as a concrete extension; the former name “Deep Residue” and +1 AP are not confirmed universal rules.
- **Done when:** the zone × ground rule is decided or explicitly deferred, the healing cap, `mend` scaling and Mossbed loop limits are decided, and hazard coverage is measured (with T13).

### [ ] T08 · Define Water and Swim (D)
**Status:** Open — water origin and Swim access undecided.
**Prerequisites:** T02, T07.
**Sources:** Battle [§4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed), [§5.1](gdd_battle.md#51-monster-skills-central-specification) (integration); Monsters [§3.3](gdd_monsters.md#33-movement-by-kin), [§4.3](gdd_monsters.md#43-skill-execution-profiles) (movement profiles).
- Where does water originate: generator only, or skills too? May generated hazard/blessed ground replace water?
- Which Kins receive Swim? Check its cost profile and flag exceptions against the general movement table.
- **Done when:** Water origin and Swim access are decided in Battle §4.7 and Monsters §3.3/§4.3, and the Swim price row is confirmed or removed.

### [ ] T09 · Specify the Air Layer and 2×2 Rules (D/K)
**Status:** Open — blocks Winged air content, 2×2 content and Beast Swap.
**Prerequisites:** T02, T04, T06, T07.
**Sources:** Battle [§4.3](gdd_battle.md#43-the-square-stack-zones--ground), [§5.1](gdd_battle.md#51-monster-skills-central-specification) (integration); Monsters [§3.1](gdd_monsters.md#31-kin-table), [§4.2](gdd_monsters.md#42-data-oriented-skill-construction-kit), [§4.3](gdd_monsters.md#43-skill-execution-profiles), [§4.4](gdd_monsters.md#44-effect-and-board-operation-contracts), [§4.7](gdd_monsters.md#47-complete-references-and-validation).
- Which effects besides Strike may have air recipients? Define layers per effect, not as a global `affects_air` authoring flag. Ensure at least sufficiently readable counters to Winged from Soul onward.
- Specify flight movement, occupancy and interaction with props/ground. For 2×2, also define distance origin, area overlap, recipient deduplication and entry/exit evaluation across multiple squares; the generic area model does not decide these cases.
- *Mountain air rule (decided in principle, details open):* ground-layer monsters on a Mountain hit air-layer monsters on squares adjacent to their own square with all attacks ([Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed)). Define whether adjacent means orthogonal or eight neighbours, how delayed Surges and area footprints apply it, and the 2×2 case; it changes no skill price.
- Additional analysis finding: 2×2 is announced, but area hits, damage multiplication, placement, movement and displacement are insufficiently defined. Occupying multiple squares must not create an implicit multiple-damage rule.
- **Done when:** air-layer and 2×2 contracts are specified in Battle §4.3 and Monsters §4.2–§4.4, or air/2×2 content is explicitly gated as deferred.

### [ ] T10 · Build Concrete Skills in the Shared Schema (D)
**Status:** Open — blocked until T05–T09 are decided.
**Prerequisites:** T05–T09.
**Sources:** Monsters [§4.2](gdd_monsters.md#42-data-oriented-skill-construction-kit)–[§4.7](gdd_monsters.md#47-complete-references-and-validation).
- Create concrete skills exclusively in the shared schema [§4.2](gdd_monsters.md#42-data-oriented-skill-construction-kit) and validate under [§4.7](gdd_monsters.md#47-complete-references-and-validation); no new parallel blueprint/example table. Fully define effects, triggers, targeting, footprints, interactions, costs and authorized upgrade patches.
- Species-exclusive and Signature skills use the same schema; express differences through access, authorship and explicit rules. Earlier named ideas are not promised content. Select concrete skills and sufficiently deep upgrade choices only after budgets are confirmed.
- *New:* the reference roster ([Monsters §6.1](gdd_monsters.md#61-first-roster-draft--9-monsters)) names utility and prop skills (e.g. Lava Field, Shockwave, Raise Wall, Raise Ground, Bark Veil, Mire, Void Pull, Gale, Shade Veil, Thornbed) that have no central definition; each needs a complete record or removal. The same applies to Sanctify, Shove, Relocate and Raise Prop mentioned in the Kin tables.
- **Done when:** the first concrete skills are complete records under [§4.2](gdd_monsters.md#42-data-oriented-skill-construction-kit)/[§4.7](gdd_monsters.md#47-complete-references-and-validation) with upgrade choices, fit the confirmed ceilings and carry no unresolved contract.

### [ ] T11 · Revise Learnlists, Passives and Reference Roster (D)
**Status:** Open — blocked by T03, T06, T10.
**Prerequisites:** T03, T06, T10.
**Sources:** Monsters [§4.1](gdd_monsters.md#41-the-kit), [§5](gdd_monsters.md#5-passives), [§6.1](gdd_monsters.md#61-first-roster-draft--9-monsters), [§7.4](gdd_monsters.md#74-monster-progression-the-18-steps).
- Define learnable skills (current target roughly 8) and available passives for each species: distinguish species binding from individual binding; free themes are not an additional learning restriction. Revise or remove formerly aspect-dependent passives.
- The nine reference monsters currently have four active skills plus passives; reduce to four shared slots and handle the Epic+ additional slot separately.
- Give every species a Species Twist instead of the shared placeholder, plus a concrete Strike shape and fixed Surge orientation.
- Check roster descriptions of weaker Surge variants against current damage and AP rules; descriptive wording grants no damage exception.
- *New:* the Berserker frame text says it “escalates one Surge with Empower”, but no section defines Empower; define it through the shared model or remove the wording.
- **Done when:** learnlists and passives for the reference species are decided with legal 4-slot kits, each species has a one-sentence identity, and legacy passives and undefined names (see bullets) are redefined or removed.

### [ ] T12 · Select the Launch Roster (D)
**Status:** Open — blocked by T11.
**Prerequisites:** T11.
**Sources:** Monsters [§6.1](gdd_monsters.md#61-first-roster-draft--9-monsters)–[§6.2](gdd_monsters.md#62-additional-species-candidates).
- Without a mandatory Kin×aspect matrix, select a diverse roster from the nine reference monsters and additional name ideas (previous target about 15); prioritize free themes and distinct playstyles over category completeness.
- Check missing blueprint/movement coverage and distinct one-sentence identities.
- **Done when:** the launch roster is recorded in [Monsters §6](gdd_monsters.md#6-roster) with a documented coverage and identity review.

## Phase 3 — Validate Battle Before the Meta Fixes Numbers

### [ ] T13 · Plan and Evaluate Battle Tests with the Revised Rules (V)
**Status:** Open — blocked; **no battle tests have been run** and the documented Godot build is the historical v6.0 ruleset, not the current design.
**Prerequisites:** T04, T07, T11; T08/T09 for water/Soul tests.
**Sources:** [Battle §7.2](gdd_battle.md#72-prototype--playtests); historical Battle §8; [Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups), historical Monsters §8.
- First ensure that the tested build implements the draft under examination: the documented Godot baseline is the historical battle v6.0 ruleset, not the current GDD design. Code changes are outside this documentation task.
- **HTML calculator/test suitability (read-only inspection):** [`battle-prototype-v5-zones-ground.html`](../html_prototype/battle-prototype-v5-zones-ground.html) has no construction-budget evaluator/shared §4.2 record. Its `SKILLS` records use aspect/range/cooldown fields (lines 390–407); `castSkill` writes cooldowns (550–568); `fireDue` uses old timing/height/Attunement outcomes (632–652); the UI prevents a second pending Surge (802). It cannot validate current construction arithmetic, round-limited event skills or current battle balance unchanged. The temporary [authoring checker](temp_kalkscript.py) now covers a limited arithmetic subset, not a battle simulation or full-model evaluator. Adapting the battle harness remains a separate implementation task; no browser/playtest was run.
- Residue: do Surges indirectly hit even when dodged, or force meaningful routes?
- Readable combos: Current → Surge/Lava, Pull → Strike; check Pull anchors and push direction.
- Strike from 2 AP: worthwhile or unused, melee too sticky?
- Check no-cooldown spam and repeated protection-zone casting (two 1-AP casts → level II, Shield 3). Fallback: level-up only once per turn and square.
- Test zone-based Surge reduction 2, level/Attunement and Surge damage 3 for genuine counters. Attunement is a historical test reference, removed by T01; do not reintroduce it.
- Check movement prices, Step-only viability and Movement cap 5.
- Three Surge types against Mountains; props as tactical resources rather than obstacles.
- 3v3/7×7: readability, round count, Collapse share and starting distances; test Reach 4 + Mountain = 5 against the promise of a safe opening.
- Test first-Surge-claims-square and initiative chains/focus fire. Fallback if dominant: make initiative more expensive.
- Compare Dusk Moth (historical 87% simulation win rate) with humans and AI; examine Native Ground/Wide/Blight separately.
- Evaluate stat/Strike/healing tests from T03/T06/T07 together; adjust prices only based on results.
- *New (K):* [Battle §4.1](gdd_battle.md#41-battlefield-generation) states an intended “5–6-row” start separation on 7×7, but back-two-row start areas give a minimum front-line distance of 4 rows (rows 2 and 6) and a maximum of 6. Correct the wording or the start areas, then test the “no hit on the enemy line in round 1” target against Reach 3–4.
- Test the profile-specific delayed one-square push of the damage-2/Thornbed Surge profile together with the entry hazard ([Monsters §4.5](gdd_monsters.md#zone-protection-and-healing-costs)); budget fit does not validate the reduced rate, and no further automatic timing discount applies.
- **Done when:** a test plan is executed on a build that implements the drafts under test, results are documented before any rule or price change, and [Battle §7.2](gdd_battle.md#72-prototype--playtests) is updated.

### [ ] T14 · Safeguard Reshape Against Reroll Exploitation (D/V)
**Status:** Open — blocked by T03, T13.
**Prerequisites:** T03, T13.
**Sources:** [Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups); Overworld [§2.6](gdd_overworld.md#26-action-catalog), [§7.5](gdd_overworld.md#75-materials-seeds-and-grades).
- Are a rare elixir and ritual costs sufficient, or is a cap/cooldown needed against repeated optimization rolls?
- **Done when:** the elixir/ritual cost is confirmed sufficient or a cap/cooldown is decided, backed by documented T13 results.

## Phase 4 — World, Catalogues and Equipment (Partly Parallel to Phase 2/3)

### [ ] T15 · Define City Powers, Responsibilities and Content (D)
**Status:** Open — independent of battle design; can start now.
**Prerequisites:** none; may run in parallel with battle design.
**Sources:** Overworld [§3.1](gdd_overworld.md#31-the-city)–[§3.2](gdd_overworld.md#32-the-powers-of-the-city), [§7.2](gdd_overworld.md#72-favor--faction).
- Define faction names, profiles and offerings for the three families.
- Confirm operators of Arena, Teleport Plaza and Business District: proposal is City Lord, City Lord, Guild.
- Clarify buildings/access for Rival Compounds and the purpose of the Slums; Black Stall remains an optional idea, not a promised feature.
- **Done when:** faction profiles, district operators, Rival Compound access and the Slums purpose are recorded in Overworld §3.1/§3.2/§7.2.

### [ ] T16 · Complete Material, Item and Recipe Catalogues (D)
**Status:** Open — can start for non-battle products; battle-related products wait for T10.
**Prerequisites:** T01; T10 for battle-related products.
**Sources:** Overworld [§6.6](gdd_overworld.md#66-pills--medicines)–[§6.8](gdd_overworld.md#68-arrays-artifacts-for-places), [§7.5](gdd_overworld.md#75-materials-seeds-and-grades)–[§7.8](gdd_overworld.md#78-acquisition-sources).
- Derive concrete materials, herbs, seeds, recipes, seals, scrolls and blueprints from patterns; determine counts, tiers and grades.
- Reconcile the quantity assumption “four tiers/~40 pills” with six cultivation stages and missing Sovereign XP values.
- Check grade dependencies and acquisition sources against “money never buys exclusive power”; Legendary bloodline ingredients are currently described both as story-only and as boss/quest/auction rewards.
- Confirm Array recipes and the Forge route (Ore + Beast Parts); decide whether Upper Stones are currency only or also ritual materials.
- **Done when:** catalogue counts, tiers and grades are defined and the listed conflicts (pill count versus stages, Legendary sources, Upper-stone role, Array/Forge routes) are resolved in Overworld §6.6–§7.8.

### [ ] T17 · Define Artifact Rules and Stacking (D/K)
**Status:** Open — blocked by T03, T11, T16; slot-access conflict between Overworld §6.3 and §6.7 is unresolved.
**Prerequisites:** T03, T11, T16.
**Sources:** Overworld [§6.7](gdd_overworld.md#67-artifacts-equipment--socketed-passives), [§6.9](gdd_overworld.md#69-hard-caps), [§7.5](gdd_overworld.md#75-materials-seeds-and-grades); [Monsters §7.2](gdd_monsters.md#72-monster-rarity).
- Tamer: two or three slots, and when? Monster: second slot at Epic+, or additionally only from Core? Synchronize tables.
- Clarify passive OR stat modifier versus the schema “passive + small stat modifier”; limit duplicate passives and multiple artifacts.
- Check +1 AP/day, capacity and skill modifiers against day economy, Stage caps and the options-not-numbers rule.
- **Done when:** slot counts and unlock timing, the passive-versus-stat rule and stacking limits are decided and Overworld §6.3/§6.7/§6.9 agree.

### [ ] T18 · Specify Medicines and Arrays (D)
**Status:** Open — blocked by T07, T10, T16.
**Prerequisites:** T07, T10, T16.
**Sources:** Overworld [§6.6](gdd_overworld.md#66-pills--medicines), [§6.8](gdd_overworld.md#68-arrays-artifacts-for-places), [§7.5](gdd_overworld.md#75-materials-seeds-and-grades)–[§7.6](gdd_overworld.md#76-item-schema).
- Determine Medicine effects, recipes, item kind and distinction from pills. Protection/healing/board effects need their own source, consumption and timing contracts in the shared data model; monster-effect contracts do not automatically approve items.
- Which Arrays are consumable, and which reusable? Define durability, placement and battle effects.
- Confirm pre-battle Arrays as a limited exception to a neutral/point-symmetric start; review the four existing Array drafts.
- *New:* the battle-prep pills Swift (+1 initiative next battle) and Ward (first-hit immunity next battle) in [Overworld §7.5](gdd_overworld.md#75-materials-seeds-and-grades) are neither medicines nor arrays; decide their item treatment, timing and effect contract. “Immunity” sits against the shared protection model (reduction, no generic immunity) in [Monsters §4.4](gdd_monsters.md#44-effect-and-board-operation-contracts); Warding Array (“first Surge damage −1”) and Spirit Shield (“next Surge damage is 0”) use different wording again. Also reconcile “pre-battle modifiers (pills, arrays)” in the Battle request ([Overworld §8](gdd_overworld.md#8-technical-notes-overworld--development-phases)) with the loadout categories.
- **Done when:** Medicine/Array item kinds, effects, recipes, consumption and timing contracts are specified in the shared model, and the Swift/Ward pill classification is decided.

### [ ] T19 · Complete Battle Loadout and Timing (D)
**Status:** Open — blocked by T18 (item effects/costs first, then loadout limits).
**Prerequisites:** T18.
**Sources:** [Battle §5.2](gdd_battle.md#52-tamer-skills-and-battle-loadout) (integration); Overworld [§2.1](gdd_overworld.md#21-battle-loop), [§7.9](gdd_overworld.md#79-inventory-and-loadout), [§8](gdd_overworld.md#8-technical-notes-overworld--development-phases).
- Define Medicine/Array counts, activation windows (own turn or anytime), AP costs and consumption.
- Apply the same rules to human opponents; specify visibility, preview, pre-battle locking and reporting consumed items in BattleResult.
- Dependency is directional: item effects/costs first, then loadout limits; do not let them block each other mutually.
- **Done when:** loadout counts, activation windows, AP costs, consumption, human-opponent visibility and BattleResult reporting are specified in Overworld §7.9/§8 and Battle §5.2.

### [ ] T20 · Validate Tamer Skills Including Beast Swap (D/V)
**Status:** Open — blocked by T09, T13, T19; tamer rows marked *proposal* are unconfirmed.
**Prerequisites:** T09, T13, T19.
**Sources:** [Overworld §6.4](gdd_overworld.md#64-tamer-skills); [Battle §5.2](gdd_battle.md#52-tamer-skills-and-battle-loadout) (integration).
- Confirm/change/reject proposed Swap Places, Urgent Order, Second Wind, Life Thread, Double Bind and Seal Mastery; T01 removed Attune. Explicitly define tamer sources in the shared effect model without transferring monster-skill permissions or AP classes.
- Test Life Thread against Spirit Shield and Urgent Order against initiative; define usage timing for free skills.
- Beast Swap: define HP, injury, queue, own charging Surges, 2×2 space requirements and replacement-entry rules.
- Scrolls teach skills earlier; Beast Swap may only be slotted from Soul: clearly distinguish learning from use and Stage gates.
- *New:* Domain Glimpse (not marked as proposal) has no specification: footprint family/orientation, range, and whether it affects Voidscar, props, Mountains or charging Surge markers. Monsters §4.4 states there is no generic cleanse of Voidscar and calls the combined zone-removal/Plain reset a tamer-source operation, but §6.4 does not exclude Voidscar. Coordinate with T04.
- **Done when:** each tamer skill is confirmed, changed or rejected, tamer sources exist in the shared effect model, and Beast Swap and Domain Glimpse rules are specified and tested against the listed interactions.

## Phase 5 — Expeditions, Collection and the Spatial World

### [ ] T21 · Define the Dungeon Node ↔ Board Generator Contract (D)
**Status:** Open — blocked by T04, T08, T12.
**Prerequisites:** T04, T08, T12.
**Sources:** [Overworld §3.3](gdd_overworld.md#33-dungeons); [Battle §4.1](gdd_battle.md#41-battlefield-generation).
- What does the node fix, and what does the generator generate? Proposal: node determines mode, theme/ground families and prop-count range; generator places everything point-symmetrically.
- Check encounter access against required team size and available healthy monsters.
- **Done when:** the node ↔ generator contract is recorded in Overworld §3.3 and Battle §4.1.

### [ ] T22 · Complete Expeditions and Loot Tables (D/V)
**Status:** Open — blocked by T16, T19, T21; HP persistence and free retreat with loot are the working state.
**Prerequisites:** T16, T19, T21.
**Sources:** Overworld [§2.2](gdd_overworld.md#22-expedition-loop), [§7.8](gdd_overworld.md#78-acquisition-sources).
- Determine floors/battles per run, deeper entry (1/2 day-AP), retreat and reward tables per floor/boss.
- HP persistence and free retreat with loot are already the working state; do not reopen them without cause. Build open edge cases on that basis.
- Clarify “Healing Pill is the only healing during a run” against Mend/Mossbed, healing passives and Second Wind: outside battles only, or also during battles?
- **Done when:** floors/battles per run, deeper entry, retreat edge cases, reward tables and the run-healing scope are decided in Overworld §2.2/§6.6/§7.8.

### [ ] T23 · Align Injury and Deadly Dungeons (D/V)
**Status:** Open — blocked by T16, T20, T22.
**Prerequisites:** T16, T20, T22.
**Sources:** Overworld [§5.2](gdd_overworld.md#52-defeat-and-injury), [§6.6](gdd_overworld.md#66-pills--medicines).
- Review two nights of downtime, Revival price and Deadly loot bonus; confirm or defer optional Deadly dungeons for launch.
- Recovery Spring already halves downtime to one night; define a minimum for the additional −1-night adjacency bonus.
- Define healing on return/overnight for uninjured monsters and HP after recovery; check Soul Tether/Life Thread against permanent loss.
- **Done when:** injury downtime, Revival price, Deadly-dungeon scope and the healing-on-return rules are decided in Overworld §5.2, with the adjacency minimum coordinated with T25.

### [ ] T24 · Specify Binding, Eggs, Breeding and Hive (D/V)
**Status:** Open — blocked by T12, T16, T20, T22.
**Prerequisites:** T12, T16, T20, T22.
**Sources:** Overworld [§5.1](gdd_overworld.md#51-obtaining-monsters), [§7.5](gdd_overworld.md#75-materials-seeds-and-grades).
- Balance seal prices/grades and the second binding; check Seal Mastery against the player Stage cap.
- Define breeding/Hive/hatching times per rarity and incubation conditions; clarify same species versus “species of one parent”.
- Make egg rarity, species visibility and timing of randomization explicit.
- *New:* eggs are not an item kind in the [item schema](gdd_overworld.md#76-item-schema) although they are found, bought and traded; decide whether eggs are items or monster-side records.
- **Done when:** seal grades, second binding, breeding/Hive/hatching times, egg visibility/randomization and egg representation are decided in Overworld §5.1.

### [ ] T25 · Internal World: Capacity, Buildings, Adjacency (D/V)
**Status:** Open — blocked by T09, T16, T23, T24; Trial Pillar access conflict confirmed.
**Prerequisites:** T09, T16, T23, T24.
**Sources:** Overworld [§4.2](gdd_overworld.md#42-building-system)–[§4.4](gdd_overworld.md#44-capacity-and-growth).
- Confirm grid/capacity curve, footprints, unlocks and new structures.
- Define housing capacity bonus, Mood/Loyalty and their concrete benefits, or remove an unnecessary system.
- Define hatching at full capacity, rented monsters and bench size.
- Trial Pillar unlocks only at Foundation but is needed to reach it; clarify access to the first breakthrough.
- Adjacency bonuses: minimum times, multiple neighbours and stacking limits; reconcile Furnace −1 AP down to 0 with “execution costs AP”.
- Staff remain excluded from the interior for now. Reconsider only for concrete benefits; no implementation merely because it is possible.
- **Done when:** grid/capacity, footprints, unlocks, Mood/Loyalty, hatching at full capacity, Trial Pillar access and adjacency limits are decided in Overworld §4.2–§4.4.

## Phase 6 — Economy, Progression and Day Balance

### [ ] T26 · Draft Staff Traits and Numbers (D/V)
**Status:** Open — **user decision pending:** Ambitious poaching Standing comparison (whose Standing, against what, which direction); model B itself is chosen.
**Prerequisites:** T15, T16.
**Sources:** [Overworld §7.1.1](gdd_overworld.md#711-staff-model-b-chosen).
- Model B is selected: visible Skill/Loyalty values plus one trait. Do not choose between models A/B/C again.
- Define trait list, wages, output, Loyalty changes, dismissal, poaching and counteroffers.
- Ambitious poaching offers: resolve the previously contradictory Standing condition in [Overworld §7.1.1](gdd_overworld.md#711-staff-model-b-chosen). Specify whose Standing is compared, the faction/reference it is compared against, and the comparison direction. No comparison condition is selected yet.
- Treat hidden Deception at most as a later scripted story idea, not for random hires.
- **Done when:** trait list, wages, output, Loyalty changes, dismissal and poaching rules are drafted, and the Ambitious comparison is decided by the user and recorded in Overworld §7.1.1.

### [ ] T27 · Align Favor/Standing and Request Pools (D/V)
**Status:** Open — blocked by T15, T16, T26; Favor + Standing model selected, numbers unvalidated.
**Prerequisites:** T15, T16, T26.
**Sources:** [Overworld §7.2](gdd_overworld.md#72-favor--faction).
- Favor + lifetime Earned Total/Standing is the selected model; test numbers, request sizes, durations and thresholds.
- Confirm the rivalry rule (Allied with one family caps the other at Trusted).
- Own family: calculate concrete progression through strength/Arena.
- Standing unlocks access, but the table additionally lists licences/recruitment/invitations as Favor expenses: distinguish access requirements from purchase prices clearly.
- Define request pools per faction and Stage, repeat limits and rewards.
- **Done when:** access requirements and purchase prices are cleanly separated, numbers/request pools/rival rule are tested or reviewed, and Overworld §7.2 has no conflicting drafts.

### [ ] T28 · Balance the Market, Properties and Businesses (D/V)
**Status:** Open — blocked by T16, T22, T26, T27 (catalogues first).
**Prerequisites:** T16, T22, T26, T27.
**Sources:** Overworld [§3.1.5](gdd_overworld.md#315-business-district), [§7.1](gdd_overworld.md#71-businesses), [§7.5](gdd_overworld.md#75-materials-seeds-and-grades)–[§7.8](gdd_overworld.md#78-acquisition-sources).
- Only after the catalogues: determine price fluctuation model, base prices, buying/selling and safeguards against endless arbitrage.
- Compare property costs, licences, facility output, queue duration, sale quantities and staff automation with dungeon income.
- Deal covers many activities: one activity per AP or several in one Deal? Distinguish free Queue from immediate Work production.
- Specify Monster Hall sales, Dojo and Dungeon Company as data configurations.
- **Done when:** the price model, arbitrage safeguards, Deal scope and business configurations are decided, with property/facility economics compared against dungeon income.

### [ ] T29 · Review XP Curves and Cultivation Pacing (V)
**Status:** Open — blocked by T05, T22, T25, T28; no XP or pacing tests run.
**Prerequisites:** T05, T22, T25, T28.
**Sources:** [Monsters §7.4](gdd_monsters.md#74-monster-progression-the-18-steps); [Overworld §2.4](gdd_overworld.md#24-cultivation-loop).
- Check the initial 18-step XP curve, pill XP, win XP, Training/Cultivate and idle XP; determine player values separately if necessary.
- Check the target of 3–6 focused days per sub-tier against farm/purchase/staff income; do not treat old prototype numbers as confirmation.
- **Done when:** the XP curve, pill XP, win XP and idle XP are checked with documented calculations/tests, not prototype numbers, and the 3–6 day pacing target is confirmed or revised.

### [ ] T30 · Complete Breakthrough Trials and Rituals (D/V)
**Status:** Open — blocked by T20, T25, T27, T29; trial draft contains confirmed conflicts.
**Prerequisites:** T20, T25, T27, T29.
**Sources:** [Overworld §6.3.1](gdd_overworld.md#631-breakthrough-trials); [Monsters §7.3](gdd_monsters.md#73-rarity-ascension).
- Check the first trial draft against prototype/game flow; confirm material quantities and pill effect.
- “Player starts at half HP”/“player on the winning team” conflicts with the non-combatant tamer role: which monster/team is meant?
- Define player/monster trials, repetition, failure costs and trial access; synchronize rarity-ascension ingredients and acquisition routes.
- **Done when:** trial requirements, player-versus-monster wording, repetition/failure costs, Trial Pillar access and rarity-ascension ingredients/site are decided in Overworld §6.3.1 and Monsters §7.3.

### [ ] T31 · Finalize Day-AP and Action Costs (D/V)
**Status:** Open — blocked by T22, T25, T28–T30; day-AP curve is a proposal only.
**Prerequisites:** T22, T25, T28–T30.
**Sources:** Overworld [§2.3](gdd_overworld.md#23-day-loop), [§2.6](gdd_overworld.md#26-action-catalog).
- Review proposed 3/4/4/5/5/6 AP per Stage and Arena price per tournament round.
- Balance expeditions, cultivation, story and work against each other; account for staff reducing the workload.
- Keep free decisions/queuing/rearranging consistent with paid execution.
- **Done when:** the day-AP curve and every action cost in [Overworld §2.6](gdd_overworld.md#26-action-catalog) are balanced against each other with documented checks.

## Phase 7 — Late Game and Completion

### [ ] T32 · Design Major Surges and Signatures (D)
**Status:** Open — blocked by T09, T12, T13.
**Prerequisites:** T09, T12, T13.
**Sources:** Monsters [§3.1](gdd_monsters.md#31-kin-table), [§4.1](gdd_monsters.md#41-the-kit) (access), [§4.2](gdd_monsters.md#42-data-oriented-skill-construction-kit), [§4.3](gdd_monsters.md#43-skill-execution-profiles) (Surge profiles), [§4.6](gdd_monsters.md#46-slot-levels-development-replacement-and-upgrades), [§7.4](gdd_monsters.md#74-monster-progression-the-18-steps); [Battle §5.1](gdd_battle.md#51-monster-skills-central-specification) (integration only).
- Determine concrete shapes, area and range; review half-board/2 AP/once per battle.
- Synchronize access for Ancient AND Legendary from Sovereign against tables sometimes saying only “Ancient”; distinguish Signatures of other Legendary Kins.
- **Done when:** Major Surge shapes/range/access and Signature access are decided and the Ancient/Legendary wording agrees in Monsters §3.1/§4.1/§7.4 and Overworld §6.3.

### [ ] T35 · Update GDD Synchronization and Implementation Plan (K)
**Status:** Open — ongoing; closes last.
**Prerequisites:** the respective affected decisions; overall completion after T01–T34, T36 and T37.
**Sources:** all three GDDs, especially technical notes and Development Phases.
- Clearly distinguish decided rules, proposals, the existing prototype and later features.
- Synchronize tables, schema fields, section references and version states. The technical validator currently requires Surge/Utility, although open kits require neither; reconcile species passives with slot-bound learnlists.
- Update development phases based on clarified dependencies; do not mix implementation tasks with open design decisions.
- Keep change history in Git, not in the GDDs or this task list. Maintain a current handoff and preserve only prototype comparisons needed to distinguish implementation from the current design.
- *New:* reconcile the Overworld §6.3 “Monster unlock” column with [Monsters §7.4](gdd_monsters.md#74-monster-progression-the-18-steps) (it lists a second artifact slot at Epic+ and a historical “Dual-aspect unlock removed” note for Immortal that §7.4 does not carry); keep historical removal notes out of active tables unless needed to delimit the current design.
- *New:* keep the [Battle §7.1](gdd_battle.md#71-technical-notes-battle) legacy validator note consistent with the open kit rule; the “physical Size path” wording was removed with T36.
- **Done when:** all other tasks are closed or consciously deferred, tables/schema fields/references are synchronized, the development phases are updated and prototype comparisons are limited to what distinguishes implementation from design.

### [ ] T37 · Editorial Deduplication Pass (K)
**Status:** Mostly done — see the handoff for the applied batches; the bullets below list what is still a candidate.
**Prerequisites:** none; coordinate with T35.
**Sources:** all three GDDs.
- *Done:* Monsters §4.7 Slowing Zone now has one representation (field entries plus paper checks); upgrade candidates are a list; Strike AP/hit cells live only in [Monsters §3.2](gdd_monsters.md#32-strike-by-kin).
- Strike “max 2 damage” still appears in Battle §6.1 (law) and Monsters §3.2/§4.3/§4.4/§4.7 (restatements at profile and reference level); kept as interface statements unless the user wants links only.
- Monsters §4.2 spatial contracts (layer occupancy, fixed bindings) still overlap Battle §4.3/§4.4/§6.5, and the Surge prop/height table in §4.3 overlaps Battle §4.7/§4.10/§4.11 (recipient rules and interaction-field rows are already merged).
- Slot development is summarized in Monsters §4.6/§7.1 and Overworld §2.6/§4.3/§6.3.2; stage gains appear in Monsters §7.4 and Overworld §6.3 (the “Monster unlock” column still partly differs from §7.4; reconcile under T35); pill XP in Monsters §7.4 and Overworld §7.5 is already linked.
- Repeated per-statement “unresolved Tnn” disclaimers (mostly Monsters §4.2–§4.4) could become one section status each, as CLAUDE.md prefers.
- Table cells: none over ~450 characters remain; two list bullets (Monsters §4.2 `Fixed bindings`, §4.7 Slowing Zone `effects` entry) are ~460 characters including link markup and are kept.
- **Done when:** each candidate is merged into one owning section with links elsewhere, or consciously kept; a before/after information check (conditions, exceptions, status) and the link check pass.

## Completed Tasks (IDs Retained for References)

IDs stay valid for references in the GDDs and this file; completion was verified against the current text of all three GDDs.

### [x] T01 · Confirm the Aspect System (D/V)
**Prerequisites:** none.
**Sources:** [Monsters §7.4](gdd_monsters.md#74-monster-progression-the-18-steps); Battle [§3.2](gdd_battle.md#32-monster-identity--skill-access), [§4.8](gdd_battle.md#48-no-attunement).
- **Decided:** remove the triangle and fixed monster aspects; no fixed replacement elements. Monsters receive free descriptive themes; deliberately designed species learnlists determine their allowed abilities.
- Remove Attunement. Concrete skills, ground types and Surge behaviour remain available in the construction kit, without fixed aspect binding or mandatory sets of three variants.
- Incorporated into all three GDDs. New ground interactions are addressed under T07; concrete learnlists and roster under T10–T12. This does not validate the balance of the remaining mechanics.

### [x] T36 · Define Physical Evolution (D) — decided: removed
**Status:** Decided by the user (2026-11-08): physical evolution does not exist. It was a relic of the former per-skill evolutions. EP as a spendable currency is removed; slot development is granted only at advancement steps ([Monsters §7.4](gdd_monsters.md#74-monster-progression-the-18-steps)) as an option to develop one skill slot. Applied in all three GDDs; the Evolution Pillar's remaining role and the Overworld “take back” action are open under T05/T25.
**Prerequisites:** none.
**Sources:** [Monsters §4.6](gdd_monsters.md#46-slot-levels-development-replacement-and-upgrades), [§7.2](gdd_monsters.md#72-monster-rarity), [§7.4](gdd_monsters.md#74-monster-progression-the-18-steps); Overworld [§2.6](gdd_overworld.md#26-action-catalog), [§6.3.2](gdd_overworld.md#632-permanent-skill-slot-development-confirmed).
- Removed: “physical evolution”, the shared EP pool, “Paths offered per evolution”, “physical Size path”, the “Take back physical evolutions” action. Historical prototype mentions remain only as prototype notes in Overworld §8.
- Rarity now sets development steps per advancement (1 for Normal/Rare, 2 for Epic/Legendary; legacy working values) next to slots and maximum stage.

### [x] T33 · Legendary Aspect Change Removed (D)
**Prerequisites:** T01, T11, T30.
**Sources:** [Monsters §7.2](gdd_monsters.md#72-monster-rarity).
- Removed by T01: without fixed aspects, there is no aspect change. No replacement feature approved; other Legendary development remains part of existing progression tasks.

### [x] T34 · Dual-Aspect System Removed (D)
**Prerequisites:** T01, T09, T13.
**Sources:** [Monsters §7.4](gdd_monsters.md#74-monster-progression-the-18-steps); [Overworld §6.3](gdd_overworld.md#63-stage-unlock-table).
- Removed by T01: no dual aspects or corresponding Immortal unlock. Multiple free themes require no separate unlock or special mechanic.

## Dependency Overview

```mermaid
flowchart TD
    A[T01 Aspects - completed] --> B[T02 Data Model, Costs and AP Efficiency]
    B --> C[T03 Stats and T04 Resolution]
    C --> D[T05 to T11 Skills and Reference Roster]
    Q[T37 Editorial Deduplication] --> N
    D --> E[T12 Launch Roster, T13 Battle Tests, T14 Reshape]
    A --> F[T16 Item and Recipe Catalogues]
    D --> F
    F --> G[T17 to T20 Equipment and Loadout]
    E --> H[T21 to T25 Expeditions and Collection]
    G --> H
    I[T15 City Powers] --> J[T26 to T28 Staff Favor and Market]
    F --> J
    H --> J
    J --> K[T29 XP and T30 Trials]
    K --> L[T31 Day-AP]
    E --> M[T32 Major Surges - T33/T34 completed]
    L --> N[T35 GDD Synchronization]
    M --> N
    P --> N
```

The detailed prerequisites per task are authoritative; the diagram summarizes only the main work streams.

# AI Prompts

Reusable German chat prompts and subsection titles are an explicit exception to the English documentation rule. These are instructions, not design rules or an execution log. Copy the relevant prompt into a new agent session; the agent must read current files rather than assume the prompt embeds the latest state.

## Alle GDDs prüfen und Aufgabenliste aktualisieren

```text
Analysiere alle GDDs von Road of the Beasts und aktualisiere docs/temp_todo.md passend zum aktuellen Projektstand. Verlasse dich nicht auf frühere Chatverläufe.

Sicherheit und Umfang:
- Lies CLAUDE.md. Prüfe zuerst Branch und Git-Status: nur auf docs/update_gdd arbeiten; andernfalls anhalten und nachfragen, nicht selbst wechseln.
- Erhalte Nutzeränderungen. Bearbeite für diese Prüfung ausschließlich docs/temp_todo.md; keine Spielimplementierung und keine GDD-Änderungen. Keine Commits, Branchwechsel, Pulls, Pushes, Resets oder automatische Synchronisierung.
- Chat Deutsch, Dokumentation Englisch. Ausnahme: wiederverwendbare Chat-Prompts samt Unterüberschriften unter AI Prompts bleiben Deutsch. Nutze kompakte thematische Stichpunkte und hilfreiche Übersichtstabellen; bewahre Bedingungen, Ausnahmen, Negationen, Einheiten und Entscheidungsstatus. Kein Changelog.

Lesen und analysieren:
1. Lies die gesamte aktuelle temp_todo.md, besonders Context Handoff, danach alle drei GDDs vollständig: docs/gdd_battle.md, docs/gdd_monsters.md und docs/gdd_overworld.md. Große Dateien abschnittsweise lesen; eine Gliederungsübersicht allein ist keine vollständige Prüfung.
2. Gleiche jede vorhandene Aufgabe mit den zuständigen GDD-Abschnitten ab: noch offen, teilweise bearbeitet, nachweislich abgeschlossen, ersetzt, doppelt oder blockiert. Bestehende Aufgabenformulierungen und Arbeitswerte sind nicht automatisch Beschlüsse; GDD-Texte sind nicht automatisch validiert.
3. Prüfe fehlende Regeln, Widersprüche, offene Alternativen, Zuständigkeiten, doppelte Definitionen, veraltete Verweise, Sprache/Lesbarkeit, quellenspezifische Ausnahmen und den Status als Entwurf/Beschluss/Historie. Prüfe gegebenenfalls Rechensummen; Rechenproben und Prototypergebnisse sind keine Gameplay-/Balancevalidierung.
4. Entscheide keine offenen Gameplayvarianten, erfinde keine Standardannahmen und öffne bestätigte Prinzipien nicht ohne neuen Anlass. Der Endzustand Rubble oder Gefahrenboden nach einem Höhenbruch ist offen, sofern die aktuellen Dateien keine spätere ausdrückliche Freigabe dokumentieren. Unklarheiten benennen, nicht stillschweigend eine Variante bestätigen.

Aufgabenliste aktualisieren:
- Überarbeite oder erstelle temp_todo.md erst neu, nachdem du ihren Bestand mit allen drei GDDs abgeglichen hast. Erhalte alle weiterhin relevanten Entscheidungen, Einschränkungen, ausschließlich in der Übergabe enthaltenen Informationen und offenen Fragen. Nicht aus dem Gedächtnis ersetzen oder Punkte nur deshalb streichen, weil sie im GDD fehlen.
- Erhalte Context Handoff und AI Prompts als Hauptabschnitte, einschließlich dieser wiederverwendbaren Prompts. Vorhandene Aufgaben-IDs und gültige Abhängigkeiten möglichst bewahren; bei Zusammenlegung/Ersatz Nachvollziehbarkeit erhalten und alle betroffenen Verweise/Diagrammkanten innerhalb dieser Datei aktualisieren. IDs nie für sachfremde Themen wiederverwenden.
- Eindeutig ersetzte oder abgeschlossene Arbeit erst nach Prüfung ihrer restlichen Informationen und Abschlussbedingungen aus dem aktiven Backlog entfernen. Validierungsaufgaben brauchen tatsächlich durchgeführte geeignete Tests mit dokumentierten Ergebnissen; andernfalls offen lassen.
- Jede bearbeitbare Aufgabe erhält Status, zuständige Quellenlinks, konkrete Lücke/Entscheidung, Voraussetzungen und Abschlussbedingungen. Zusammengehöriges bündeln, Prioritäten und eine sinnvolle nächste Reihenfolge festlegen; unabhängige Arbeit darf parallel bleiben. Neue Lücken ohne doppelte Aufgaben ergänzen.
- Regeln, Preise und vollständige Referenzrechnungen bleiben in den zuständigen GDDs: verlinken statt kopieren. Vorgeschlagene GDD-Korrekturen als Aufgaben erfassen, nicht als unbestätigte neue Regeln.
- Veraltete Übergabe durch einen knappen aktuellen Stand ersetzen: Fokus, Beschlüsse gegenüber Entwürfen, Blocker, nächste konkrete Aktion/Fragen, betroffene Quellen, beobachteter Git-Stand und tatsächlich erfolgte Prüfungen. Zum Sessionende aktualisieren.

Prüfung und Antwort:
- Fokussierten Diff auf Informationsverlust und unbeabsichtigte Entscheidungsänderungen prüfen; relative Links, Aufgabenverweise, Abhängigkeiten und durchgeführte Rechnungen kontrollieren. git diff --check ausführen.
- Auf Deutsch berichten: tatsächlich geprüfter Umfang, wichtigste Befunde, Aufgabenänderungen, offene Entscheidungen, erfolgte Prüfungen und empfohlene nächste Besprechung. Bei unvollständiger Analyse genau benennen, was fehlt; keine vollständige Prüfung behaupten.
```

## Mit anderem Agent oder Rechner weiterarbeiten

```text
Setze die Dokumentationsarbeit an Road of the Beasts fort, ohne frühere Chatverläufe vorauszusetzen. Lies CLAUDE.md, prüfe Branch/Git-Status und halte an, falls nicht docs/update_gdd aktiv ist. Keine eigenständigen Branchwechsel oder automatische Synchronisierung; lokale Nutzeränderungen erhalten.

Lies in docs/temp_todo.md Usage, Context Handoff und die betroffenen offenen Aufgaben; danach die zuständigen GDD-Abschnitte und verlinkten Schnittstellen. Aktueller ausdrücklicher Nutzerauftrag hat Vorrang vor älteren Übergabeanweisungen. Chat Deutsch, Dokumentation Englisch; wiederverwendbare Chat-Prompts samt Unterüberschriften unter AI Prompts bleiben Deutsch. Nur in docs/ arbeiten; keine Implementierung oder unaufgeforderten Git-Eingriffe.

Fasse Fokus und nächsten Schritt kurz zusammen. Belegte redaktionelle Korrekturen direkt bearbeiten; grundlegende Gameplayentscheidungen vorher klären. Entwürfe, Budget-Fit oder historisches Prototypverhalten nicht als bestätigte Regeln behandeln. Zum Abschluss Context Handoff mit tatsächlichem Ergebnis, Blockern, nächstem Schritt, beobachtetem Git-Stand und Validierung aktualisieren; veralteten Text ersetzen statt Historie anzuhängen.
```

## Session abschließen und Kontextübergabe aktualisieren

```text
Aktualisiere ausschließlich docs/temp_todo.md für die Übergabe dieser Dokumentationssession. Lies CLAUDE.md, prüfe docs/update_gdd und erhalte Nutzeränderungen. Nutze die aktuellen Dateien und ausdrücklichen Entscheidungen dieser Session; Empfehlungen sind keine Freigaben.

Aktualisiere Context Handoff: Fokus, Beschlüsse gegenüber Vorschlägen, offene Fragen/Blocker, genaue nächste Schritte/Quellenlinks, beobachteter Git-/Commit-Stand und tatsächlich erfolgte oder noch fehlende Prüfungen. Aufgabenstatus nur bei erfüllten Abschlussbedingungen ändern. AI Prompts und unbeteiligte Aufgaben erhalten. Keine Regel-/Preiskopien oder laufende Historie; veralteten Kontext ersetzen. Dokumentation Englisch, Antwort Deutsch; wiederverwendbare Chat-Prompts samt Unterüberschriften unter AI Prompts bleiben Deutsch. git diff --check ausführen; ohne ausdrücklichen Auftrag weder committen noch synchronisieren.
```

## GDDs redaktionell refactoren (Duplikate und Fließtext)

```text
Refactore die GDDs von Road of the Beasts redaktionell gemäß CLAUDE.md. Verlasse dich nicht auf frühere Chatverläufe.

Sicherheit und Umfang:
- Lies CLAUDE.md. Prüfe zuerst Branch und Git-Status: nur auf docs/update_gdd arbeiten; andernfalls anhalten und nachfragen, nicht selbst wechseln.
- Erhalte Nutzeränderungen. Schreibe nur in docs/ (docs/gdd_battle.md, docs/gdd_monsters.md, docs/gdd_overworld.md; docs/temp_todo.md nur für Verweise und Übergabe). Keine Spielimplementierung, keine Commits, Branchwechsel, Pulls, Pushes oder Resets ohne ausdrücklichen Auftrag.
- Chat Deutsch; alle Dokumentation unter docs/ bleibt Englisch (Ausnahme: Chat-Prompts samt Unterüberschriften unter AI Prompts). Deutsche Bestandsabschnitte ins Englische übersetzen, ohne Regeln oder Entscheidungsstatus zu ändern.

Analyse zuerst:
1. Lies docs/temp_todo.md (Context Handoff, offene Aufgaben) und danach alle drei GDDs vollständig, abschnittsweise. Eine Gliederungsübersicht allein genügt nicht.
2. Erstelle vor dem Bearbeiten eine Befundliste: (a) Spielmechaniken, Regeln, Formeln, Preislisten oder Datenstrukturen, die an mehreren Stellen definiert oder fast wortgleich wiederholt werden; (b) lange Fließtext-Absätze und überlange Tabellenzellen; (c) deutsche Reste; (d) Verweise, die nach Umbauten brechen würden. Lege die Liste dem Nutzer kurz vor, wenn du mehr als nur eindeutige Duplikate zusammenführen willst.

Refactoring-Ziele (in dieser Priorität):
1. Keine doppelten oder mehrfachen Definitionen: Jede Regel, Formel, Preisliste und Datenstruktur hat genau einen zuständigen Abschnitt (Zuständigkeiten laut CLAUDE.md, Tabelle „Dokumentzuständigkeiten“). Alle anderen Stellen verlinken per relativem Markdown-Link und beschreiben nur ihre eigene Schnittstelle, keine Regelkopien. Beispiele und Referenzrechnungen folgen den zentralen Regeln und bilden keine zweite Regelversion. Allgemeine Regeln beschreiben Effekt-/Skillklassen statt Namenslisten; Skill-Ausnahmen nie auf ganze Klassen übertragen.
2. Keine Fließtext-Absätze: Längeren Fließtext in thematische Stichpunktlisten umwandeln, zusammengehörige Aussagen bündeln (nicht jeden Satz einzeln aufzählen), Unterlisten nur für echte Unterstruktur, Abläufe nummerieren, Vergleiche und Referenzwerte in kompakten Tabellen. Kurze Überblicks- und Begründungssätze dürfen bleiben.
3. Sprache: Englisch, einheitliche GDD-Terminologie und Bezeichner.

Harte Grenzen:
- Reines Refactoring: keine Regel, Zahl, Bedingung, Ausnahme, Negation, Einheit und kein Entscheidungsstatus (beschlossen / Arbeitsentwurf / nicht validiert) darf sich ändern. Keine neuen Mechaniken, keine Standardannahmen, offene Alternativen nicht entscheiden (z. B. Endzustand nach Höhenbruch bleibt offen). Widersprüche nicht still auflösen, sondern als Aufgabe in docs/temp_todo.md erfassen.
- Informationserhalt prüfen: tatsächlichen Zeichenumfang vergleichen, mehr Zeilen sind keine Kürzung. Beim Zusammenführen von Duplikaten die vollständigste Fassung behalten und nur wirklich redundante Teile entfernen; Bedingungen nur in einer Quelle nicht verlieren.
- Überschriften stabil halten; nach Verschiebungen oder Umbenennungen alle Links, Abschnittsnummern und Anker in allen GDDs und in temp_todo.md aktualisieren. Aufgaben-IDs in temp_todo.md bleiben erhalten.
- Arbeite in kleinen, thematisch geschlossenen Schritten (ein Kapitel oder eine Mechanik pro Schritt) und prüfe jeden Schritt, bevor du fortfährst.

Prüfung und Antwort:
- Prüfe Diff auf Informationsverlust und unbeabsichtigte Entscheidungsänderungen, alle relativen Links und Anker (per Skript), Rechensummen, verbliebene doppelte Definitionen (gezielte Suche nach Schlüsselbegriffen) und `git diff --check`.
- Aktualisiere Context Handoff in docs/temp_todo.md auf den tatsächlichen Stand (Fokus, Blocker, nächster Schritt, Git-Stand, erfolgte Prüfungen).
- Berichte auf Deutsch: geprüfter Umfang, zusammengeführte Duplikate (mit zuständigem Abschnitt), umgewandelte Fließtexte, gefundene Widersprüche und neue Aufgaben, durchgeführte Prüfungen, offene Punkte. Keine vollständige Prüfung behaupten, wenn etwas fehlt.
```
