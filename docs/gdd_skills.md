# GDD — SKILLS
*Working Draft · companion specifications: [Monsters](gdd_monsters.md) (what a monster is), [Battle System](gdd_battle.md) (how a fight works), [Overworld & Meta](gdd_overworld.md) (the world around it) · source of truth for everything that defines a monster skill*


## Scope and Status

- **Ownership:** this file owns every monster skill rule and every concrete skill: kit/access (§1), shared model and spatial/temporal contracts (§2), execution profiles (§3), effect/board operations (§4), point/AP calculations (§5), slot development (§6), validation (§7), Kin Strike and movement tables (§8), passives (§9), prior-draft species assignments (§10) and concrete skill records (§11). Monster identity, stats, Kins, roster and growth stay in [gdd_monsters.md](gdd_monsters.md). Every concrete skill is defined exactly once here, with its exceptions; other documents refer to skills by name or id and never copy a record.
- **Boundary:** gdd_battle owns turns/events, board state, zone/ground/prop interactions and generic damage/displacement/collision resolution, not parallel skill execution rules. gdd_overworld owns tamer skills, loadout and meta logistics/economy; monster-skill budgets do not automatically apply there.
- Confirmed rules override legacy conflicts; open decisions remain in temp_todo.md.
- **Open rules:** a missing or unresolved rule grants no default, permission or implicit behaviour; content that depends on it stays blocked, and the T-references in this chapter name the owning task.
- **Status:** the records in §11 are **draft structural/calibration references, not approved content, balance or unlocks**; §8–§10 hold working and prior-draft content. Open decisions and tasks live only in [temp_todo.md](temp_todo.md) (T02, T05, T10, T11).
- **Section references:** `§n` without a file name means this file; other files are named explicitly (Monsters, Battle, Overworld).


## 1. The Kit

```
Monster = Step (always, no slot)
        + 4 slots, each an active (movement skill, Strike (Kin), Surge, utility) or a passive,
          at least one active      — Epic+ get a 5th, passive-only slot ([Monsters §5.1](gdd_monsters.md#51-monster-rarity))
```

- **Slots:** all 4 open on day one; movement skills occupy a normal slot, unlike universal **Step** (1 square, 2 AP, slot-free). No skill kind is mandatory; repeats, including identical skills in separate legal slots, are allowed. Each copy occupies its own slot and has independent activation usage under [§2](#usage-and-repetition); access and passive-only slot restrictions still apply.
- **Limits:** species learnable list and Kin lock-outs ([Monsters §3.1](gdd_monsters.md#31-kin-table)/§8.2); each skill's [usage policy](#usage-and-repetition) and [Surge placement rules](#surge) remain binding. There is no monster-wide cap on simultaneously charging Surges.
- **Default-kit tip:** pair a Surge with a *different effect family* of utility (protection, slowing or displacement), preserving an answer. Skills define zones/ground/effects; descriptive themes grant no bonuses or penalties. The prototype Tiger's 7 skills are a test bench, not a kit.

### Species-Specific and Signature Access

- **Species exclusivity** means authorship/learn-list access, not a `unique` mechanical kind, perk category or construction system. Use the §2 schema (concrete records: [gdd_skills.md](gdd_skills.md)), a normal legal slot, actual profile/constraints, existing interactions and explicitly validated usage/points (§5); ownership grants no effect permission.
- Map companion documents' legacy `Unique` labels to concrete profiles/definitions before implementation, never a catch-all profile.

- **Signature/Major access:** Signature remains Legendary/progression-bound ([Monsters §5.1](gdd_monsters.md#51-monster-rarity)/[Monsters §5.3](gdd_monsters.md#53-monster-progression-the-18-steps)), without a decided slot treatment or effect. Major Surge retains Ancient access at Sovereign, 2 AP, once per battle. Their legacy access ambiguity remains [temp_todo.md](temp_todo.md) T02/T32, not an active Battle rule or Major permission for every Legendary. No new access/values are decided here.

- **Effects/upgrades:** new effects need authored, validated definitions; exclusivity grants no arbitrary boosts, damage, healing, board removal or targeting. Use authorized field patches (§6), without a separate per-skill step count. Unresolved content stays central T02/T10–T12/T32, not a parallel catalogue.

## 2. Data-Oriented Skill Construction Kit

- **One model:** active actions, passives, self buffs, targeted utility, movement, Strikes, Surges, zones and species-exclusive/Signature skills share fields. No `unique` effect, opaque script hook or separate passive/buff schema bypasses construction/costing. Players select finished definitions/authored upgrades, not arbitrary components.
- **Representation ≠ approval:** self buffs/conditional passives need no structural exception, but their numbers, stacking, triggers, access and combinations still need approval. Existing profiles preserve rules; new content stays draft until its rules/cost are agreed. Genuinely new mechanics extend the shared vocabulary with explicit parameters, resolution, limits and costing, not skill-specific escape hatches.

### Common Field Structure

Every resolved definition contains all groups below: `none`/`[]` where genuinely inapplicable; `pending` for unresolved drafts, blocking approval and never a runtime default. Names are documentation notation, not required engine serialization.

| Field group | Required meaning | Evaluation binding (derived, not a second input model) |
|-------------|------------------|--------------------------------------------------------|
| `metadata` | Stable id/name, descriptive tags, optional classification (`kind`) and optional reusable `rule_profile`. Classification is not an effect permission or price. | No name/tag/profile fee. |
| `access` | Species learn-list/exclusivity, Kin, progression and slot restrictions. No skill rarity/rating. | Eligibility check, not a rarity/exclusivity budget bonus. |
| `usage_type` | `active` or `passive`; independent of theme, recipients or effect family. | Select active or passive availability in [§5](#5-construction-points-and-ap-efficiency), never both. |
| `execution` | Activation (`player_action`, `while_equipped`, or a defined event), qualifying condition, resolution timing, telegraph/charging and any autonomous delayed execution. Always-on and event-driven passives are distinguishable. | [Component prices](#component-price-sheet): timing and complete marker; [passive availability](#self-buff-and-passive-costs). Undefined event frequency/conditions block complete valuation. |
| `targeting` | What is selected (`self`, `unit`, `tile`, `prop`, or `none`), eligibility, distance source and sight. Event-driven effects may bind their recipient from the event without player selection. | [Selection costs](#zone-protection-and-healing-costs), resolved together with placement; no second fee for the same selection. |
| `placement` | Body/board anchor, selected destination/path, binding and direction, or `none`. A self buff does not create a board anchor. | [Anchor/direction costs](#component-price-sheet); movement path/destination is included in its [preset](#movement-costs), not an additional ranged anchor. |
| `area` | Explicit footprint/count/orientation and boundary rules, or `none` for non-area effects. Area is not cast range. | Supplies potential cells/distant cells to component formulas, not a second area fee. `none` creates no artificial one-cell area charge. |
| `effects` | Typed effect definitions with parameters/value sources, per-effect recipients/layers, application event, conditions, lifetime reference, stacking/refresh and resolution dependencies. Includes stat modifiers and rule modifiers, not just attacks. | Resolve [§4 contracts](#4-effect-and-board-operation-contracts) to the applicable §5 component: damage, displacement, modifiers, protection/healing, self movement or rule permission. Recipients determine authorized coverage. |
| `persistence` | Named lifetimes for created zones, states, props or pending actions: owner, duration/clock or end/consumption condition. Effects reference these entries; all effects of one zone share its clock. Delay is distinct from a buff's lifetime. | Supplies duration/availability to the applicable component; permanent [board packages](#ground-and-board-costs) already include persistence. No duplicate timer or future-trigger charge. |
| `board_changes` | Explicit typed ground, height and prop operations with targets, trigger/order and lifetime references, or `[]`. Natural damage reactions are resolved by their existing source rules. | [Ground/board components](#ground-and-board-costs); included reactions are not separate authored payloads. Missing special-reaction valuation is unresolved, not free. |
| `interactions` | Placement/effect/path blocking and other profile constraints. Recipient layers belong to each effect, not to global hit flags. | Resolve the applicable effect/package constraints; no generic flag fee or automatic restriction discount. Changed permissions require an applicable rate. |
| `usage` | Active battle AP cost and explicit activation/repetition limits for active or event-driven skills. A defined limit identifies what is counted, its owner/scope and reset event; absence of a new approved limit preserves the current profile rules. Passives use `ap_cost: none`, not a zero-AP active action. AP is the only battle-use resource for active monster skills; [shared repetition policies](#usage-and-repetition) apply without a generic mana or multi-round cooldown system. | [AP efficiency](#ap-efficiency-working-scale) once per active use; limits constrain valuation but grant no unpriced discount. |
| `upgrades` | Authored patches to these same fields, slot-level requirements, prerequisites/exclusions and explicit AP consequences. Empty while a draft's development path is unresolved. | Re-evaluate the resolved patched definition, not a second upgrade-component model or duplicate enlargement charge. |
| `evaluation` | Internal pre-release authoring/test report: derived component costs, AP-efficiency or passive-availability cost, total points and required slot-level ceiling. Legacy `combination_cost` fields are fixed at 0, not an additional price channel. Neither a runtime requirement nor a player currency. | Derived result under [§5](#5-construction-points-and-ap-efficiency), not independently editable mechanics, prices or permissions. |

- **Profiles are reusable bundles, not a closed menu:** Strike supplies body-relative hits, Surge telegraphing/charging, Zone persistent board area, movement presets traversal. Fully defined self buffs/passives may use `rule_profile: none`, without bypassing damage delivery, access or hard limits.
- Evaluate resolved mechanics once; `kind`/`rule_profile` are not separately purchased advantages.


- **No redundant flags:** retired `affects_ground`/`affects_air` authoring inputs and historical/prototype names are not current schema. Ground changes belong only in `board_changes`, layers only in effect recipients; UI summaries such as “changes ground” are derived, not separately priced.

- **Events/lifetimes:** each effect names application event, state owner if any, lifetime reference/`none`, and stacking group plus stacking/refresh rule where reapplication is possible. States may have distinct lifetimes; each zone shares one clock. Persistent states specify termination/removal and recipient/condition reevaluation. Missing event/stacking/termination rules stay unresolved.
- **Bindings:** profiles §3, shared effects §4, evaluation §5, validation §7, six structurally different draft records in [gdd_skills.md](gdd_skills.md). No aspect/attunement field, automatic new trigger or budget override.

**Spatial contracts — targeting, placement and recipients**

These are separate responsibilities, resolved against [gdd_battle §4.3–4.11](gdd_battle.md#43-the-square-stack-zones--ground) and the central execution profiles (§3). References may supply fixed fields; an unresolved rule is not a configurable permission.

**Confirmed square-control boundary:** attacks define affected squares through their authored footprint/body shape, not a generic directly selected-unit damage action. Eligible occupants are hit under the owning profile's caster/layer/blocking rules, without ally-only/enemy-only area filters. Zones retain their shared field effects for both sides. Self movement and source-defined unit-bound utility remain separate; this principle neither bans them nor authorizes new utility effects.

- **`targeting` — what is selected**
  - Required resolved data: Selection type (`self`, `unit`, `tile`, `prop`, `none`), eligible target definition including side/layer where applicable, distance source and LOS rule
  - Binding rules / open cases: `none` means no player selection, not no effect recipient; event bindings must be explicit.
    - `self` selects the caster; `unit` selects an eligible monster; `tile` selects a board cell, not its occupant; `prop` selects an eligible existing prop, not permission to create or relocate it.
    - Side eligibility must come from the source; no generic ally/enemy filter is granted. Monster offensive push/pull selects affected squares through its authored spatial pattern, not a directly selected unit; source-defined self/tamer utility is not made into an attack by this restriction.
- **`placement` — where it resolves**
  - Required resolved data: Binding from selection to board anchor or body footprint, required adjacency, occupancy/layer constraints and separately selected direction/pull anchor
  - Binding rules / open cases: Zone/ground/prop/Surge anchors use effective Reach, Manhattan distance from caster to anchor, not distance to every affected cell. There is no independent skill-range stat.
    - Strike uses its body shape without a ranged anchor; movement uses Movement ([§3](#3-skill-execution-profiles)).
    - Authored twist exceptions stay explicit.
- **Effect `recipients` — what receives an effect**
  - Required resolved data: Referenced recipient rule per effect, spatial scope (self, selected unit, area occupants or event-bound), relationship/side, authorized `ground`/`air` layers, relevant prop eligibility and evaluation event/application condition
  - Binding rules / open cases: Selection does not restrict an area to the selected unit or its side. Effects of one skill may differ under their source contracts; ally-only/enemy-only area filtering is not an authoring option, and recipient data grants no new air access. Self-bound modifiers affect their owner in its legal layer unless explicitly narrowed.
    - Zones affect everyone occupying their cells; Strike hits allies but excludes its caster; Surge includes its caster and allies.
    - Ground affects ground-layer occupants; prop reactions and Surge prop/occupant handling use their own rules, not a generic occupant hit ([gdd_battle §4.6–4.7](gdd_battle.md#46-zones-effects-rules--opposites) and §3 here).

- **LOS ≠ placement legality:** zone/ground/prop/Surge casts and self boosts need no LOS; source-defined unit-targeted utility needs its explicit sight contract. Monster offensive push/pull uses spatial hit patterns, not direct unit selection. Reach, occupancy, layer and blocking checks still apply. Exact sight geometry/unspecified direct-target eligibility remain [temp_todo.md](temp_todo.md) T02/T04/T09.
- **Layer-specific occupancy:** per-cell layer limits, props under zones/Surges and ground-on-prop rules: [Battle §4.3](gdd_battle.md#43-the-square-stack-zones--ground). Skill-side additions: prop creation needs empty cells; charging Surges cannot overlap (§3 here). Air occupancy follows Battle §4.3; no universal cross-layer `empty` test (open details: T09).
- **Fixed bindings:** board footprints stay at cast cells; push direction/pull anchor are fixed at cast ([gdd_battle §4.4](gdd_battle.md#44-square-data-model)/[§6.5](gdd_battle.md#65-displacement); §2 here). Selecting a unit grants no homing area, following zone, moving pull anchor or automatic retarget after movement/death. Author unspecified unit-target resolution/validity (T02/T04); immediate body-relative Strike placement is no tracking precedent.

**Area contract — explicit footprint, not cast range**

- **Required area data:** shape/profile, distinct integer offsets from a declared anchor/body origin, matching `cell_count`, authored orientation/selection policy, boundary and blocking/placement references. Reusable footprints may own offsets; family names/unexplained orientation numbers cannot reconstruct cells. Non-area skills use `area: none`, without cell count/artificial footprint.
- **Anchor/caps:** [Footprints and Placement](#footprints-and-placement) lists tetris families/counts/orientations. Author the centre-most anchor's exact offset mapping; no runtime tie-break. Caps: [§5](#5-construction-points-and-ap-efficiency). Strike body footprints (§8.1) and Major Surge access/profile are not generic size overrides.
- **Orientation:** normal tetris skills have one family and one fixed absolute board orientation for both teams, not facing, team mirroring or default rotation. Only the owner-scoped [passive permission](#non-area-and-passive-coverage-references) allows in-battle rotation; Strike separately selects eight directions (§2–§3). Push direction is not rotation; missing mappings remain T02.
- **Boundaries:** all cells must be on-board (§2); no automatic trimming, shifting or rotation to fit. Keep profile-specific Strike solid-prop blocking, ground/prop occupancy and Mountain blanking separate ([gdd_battle §4.3](gdd_battle.md#43-the-square-stack-zones--ground); §2–§3 here), not universal obstacle clipping/resizing. Forced-movement collision uses [gdd_battle §6.3](gdd_battle.md#63-collision-fall--debris), not area placement.
- **Hits/2×2:** a monster covered by several hit cells is struck once per use ([§3](#body-relative-damage-and-movement-variants)); cells are not otherwise distinct hits. 2×2 geometry is decided in [Battle §4.3](gdd_battle.md#43-the-square-stack-zones--ground) and the *2×2 bodies* entry below; layer mixing, landing and the remaining cases stay open (T04/T09). Infer neither per-cell/per-unit hits, partial placement nor collision defaults; preview/validation must expose unsupported cases.

**Temporal contract — execution, effect events and lifetime**

| Responsibility | Required resolved data | Existing binding rule |
|----------------|------------------------|-----------------------|
| `execution` | Immediate vs telegraphed delay, exact resolution event, charging/telegraph and autonomy rules where applicable | Immediate resolves the action now, not every effect now. Bind Surge execution to the [Surge profile](#surge) and its scheduling interface in [Battle §2.2](gdd_battle.md#22-initiative-rules); do not substitute a generic one-round delay. |
| Effect trigger/application | Referenced event, whose turn/entry it is, recipients at that event and ordering dependencies | Existing resolution, `start_of_turn`, `on_enter`, `while_inside`, Surge-damage protection and `end_of_turn` events remain definition-bound ([gdd_battle §2.4](gdd_battle.md#24-effect-timing-reference)/[§4.6–4.7](gdd_battle.md#46-zones-effects-rules--opposites)). `while_inside` is continuous, not a repeating cast. |
| `persistence` | Owner of the lifetime, clock/event, duration or consumption/removal condition, expiry result | Reference [Battle §4.5](gdd_battle.md#45-lifecycles) for board-state lifecycles and [Battle §4.10–§4.11](gdd_battle.md#410-prop-catalogue-and-damage) for prop removal/reactions. Distinguish pending execution, any authored aftermath and self-bound states; effects of one zone share its clock. |

- **Runtime bindings:** use turn/round sequence [Battle §2.1](gdd_battle.md#21-core-battle-loop), event meanings/order [Battle §2.4](gdd_battle.md#24-effect-timing-reference), ground entry [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed). Round duration does not count caster actions.
- **Repetition:** persistence adds no undefined payload/repeat trigger; action repetition follows [Battle §2.3](gdd_battle.md#23-action-points). Missing trigger/lifetime/timing contracts remain [temp_todo.md](temp_todo.md) T02/T04/T07/T09/T19.

### Usage and Repetition

**Confirmed shared authoring options:** every resolved active or event-driven skill declares its repetition policy through `usage`, directly or by an unambiguous profile reference. These are runtime capability limits read by the internal evaluation, not construction points spent during play. No existing skill is assigned a new limit by introducing these options.

| Policy | Meaning |
|--------|---------|
| Repeatable | No additional repetition cap from this policy. Activation still requires its defined event/conditions and, for active actions, sufficient Battle-AP; all existing profile and usage limits remain binding. |
| Once per global round | At most one cast/activation of each equipped skill instance in the global battle round. It becomes available in the next global round, not at the owner's next turn; extra turns within one round do not reset it. |

- **Scope:** each equipped skill instance has its own usage allowance, not a shared allowance by skill name, monster or team. Two identical round-limited copies in two legal slots allow one activation from each per global round, each active cast paying its own Battle-AP. This deliberately trades kit flexibility for additional uses. Independent instance allowances do not override placement rules or separately authored profile-wide limits and grant no additional stacking of identical continuous permissions. Multiple pending Surge casts are separate actions, not stacking of a continuous permission.
- **Activation versus effect:** the policy counts a cast or event-driven activation, not every recipient or subsequent application of an existing zone/state. Casting again to level/refresh a zone is another cast; the zone's scheduled/continuous effects retain their own trigger and lifetime contracts. The policy grants no new trigger or stacking permission.
- **Consumption:** an invalid selection/activation attempt consumes neither Battle-AP nor the instance's usage allowance. A valid activation consumes its authored Battle-AP and one use of any applicable activation limit at activation, regardless of whether its effects later produce a benefit; a valid Surge whose targets leave still spent its activation. Passives spend no Battle-AP but consume their applicable instance allowance on valid activation. Subsequent effects of an existing zone/state do not consume another activation. This defines consumption, not unresolved target-validity, cancellation or event-order behaviour at later resolution.
- **Other limits:** retain independent placement restrictions and existing once-per-battle profile limits. A pending Surge does not by itself prevent another Surge cast; its skill instance's policy determines repeat availability. These two repetition options do not remove them or create a multi-round cooldown system. Continuous permissions are not repeatedly activated actions.
- **Evaluation:** read the declared policy before release; active round-limited availability uses the [selected calibration rule](#round-limited-availability-calibration). Runtime activation bookkeeping is not runtime construction costing. Repeatability does not settle recursion, simultaneous ordering, later-resolution target validity/cancellation or owner-removal cases (T02/T04).

### Evaluation Contract — One Definition, One Calculation

Evaluation is an **internal, pre-release calculation/check of an authored definition**, not an in-battle calculation, player-facing resource or required runtime field. It can be produced by an authoring script/test before a skill is admitted to the game. The temporary [arithmetic checker](temp_kalkscript.py) covers only the explicitly supported reference subsets, not the full model or content admission. The calculation is part of this data model, not a parallel skill blueprint. The field table above binds authored mechanics to costing; [§4](#4-effect-and-board-operation-contracts) owns effect/operation contracts and [§5](#5-construction-points-and-ap-efficiency) owns their rates, units and package inclusions. Neither costing nor reference records redefine those contracts.

1. Resolve the skill's authored fields and referenced profiles/contracts, including any selected upgrade patches, before release. Runtime trigger/usage definitions describe the capability being evaluated; actual casts, hits, destroyed props or observed trigger counts never determine its construction price.
2. Derive each charge's quantity from those resolved fields and apply the owning §5 rate once. Attribute it to the source field/effect/operation and referenced rate; do not copy mechanics or introduce separately authored cost-only cell counts, durations, layers or timing flags.
3. Keep distinct authorized effects additive, but omit charges already included in a package. Availability, selection and shared marker costs use their declared scope rather than repeating for every effect.
4. Record component subtotals, availability, full unrounded total and comparison with the applicable working ceiling in the internal `evaluation` report. A missing rate or unresolved contract makes the result **incomplete**, not zero or a passing budget check. Numeric fit grants no progression access.

A new mechanic extends its owning typed contract and the corresponding §5 valuation together, then uses the existing field groups. Standard rates apply to shared mechanics/conditions, not names. Legacy profile-scoped test prices remain explicitly scoped drafts, not general defaults or grounds for new exceptions. This contract adds no new effect permissions or numeric prices.

### Footprints and Placement

Existing tetris families/authoring orientations below follow the spatial/area contracts above for selection, anchor distance, occupancy, binding and boundaries. Step/non-area effects need no footprint; Strike uses [body shapes](#81-strike-by-kin).

|  Family | Cells | Orientations (incl. mirror) |
|---------|-------|-----------------------------|
| I2      |     2 |                           2 |
| I3      |     3 |                           2 |
| L3      |     3 |                           4 |
| O4      |     4 |                           1 |
| T4      |     4 |                           4 |
| S4 / Z4 |     4 |                           4 |
| L4 / J4 |     4 |                           8 |

- **Orientation counts** are authoring options, not battle choices; fixed orientation/passive rotation follow the area contract above. Outside-battle changes: [§6](#6-slot-levels-development-replacement-and-upgrades). Rotation shortcuts: `R` / right-click.
- **Preview:** colour squares **new / levels up / replaces / weakens / cancels / blocked**; list ground/prop reactions, displacement landings and Surge damage after reductions. Referenced Battle rules determine outcomes, not preview labels.

### Interaction Fields

Blocking is scoped to placement, effect propagation or movement traversal; a shared flag name does not imply the same test in each scope.

| Field / responsibility | Meaning |
|------------------------|---------|
| `blocked_by_objects` | Profile-specific prop blocking; does not grant LOS or imply a universal empty-square test. |
| `blocked_by_height` | Whether the relevant placement/effect/path can reach Mountain cells. |
| `blocked_by_monsters`, `blocked_by_surges`, `ground_costs`, `distance_mod`, `path` | Movement-profile parameters (§3), resolved with path and landing rules. |

Lifetimes belong to `persistence` and their effect references, not an interaction flag. Fixed profile values may be referenced instead of duplicated, but must resolve unambiguously.

### Sight and Target Eligibility

Reference the spatial contracts above through `targeting`/`placement` for LOS, selection and placement eligibility. Sight geometry/target-validity gaps remain [temp_todo.md](temp_todo.md) T02/T04/T09.

### Reading a Complete Skill Definition

- **Read:** equip access → active/passive activation → selection/placement if any → effect recipients/event → lifetime/stacking → board operations → usage/points.
- Application need not equal activation: a cast zone may apply its modifier continuously after the action ends; an available passive may produce effects only at its declared event.
- All six records in [gdd_skills.md](gdd_skills.md) resolve these groups; skills need not create an area, pending marker or status. Access/profile references/descriptive tags grant no effects or unpriced bonuses.

## 3. Skill Execution Profiles

Central monster-skill execution definitions; [Battle chapter 5](gdd_battle.md#5-skill-integration) links here. Generic board state, scheduling, mitigation and collisions remain in gdd_battle chapters 2, 4 and 6.

### Profile Overview

|   Kind   |      Writes to      |                                         In battle                                          |
|----------|---------------------|--------------------------------------------------------------------------------------------|
| `strike` | squares around the body | small direct damage in a shape around the monster ([Strike profile](#strike))                               |
| `surge`  | Surge layer; ground only via explicit `board_changes` | telegraphed delayed execution ([Surge profile](#surge)), including the existing burst profiles; optional, separately budgeted residue; multiple casts may charge concurrently under their skill-instance policies |
| `zone`   | zone layer          | timed control or support on squares ([gdd_battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites)), lasts for the skill's `duration`               |
| `ground` | ground layer        | hazard ground or Mountain ([gdd_battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed))                                                           |
| `prop`   | object layer        | places or moves props ([gdd_battle §4.9](gdd_battle.md#49-props))                                                               |
| `direct` | a unit / self | Only source-defined unit/self utility with explicit effect contracts; no generic direct unit-targeted damage or offensive push/pull. Shove uses a body-relative spatial pattern below. |
| `move`   | the caster          | moves the caster ([Movement profile](#movement))                                                                    |

Profiles are reusable, not a closed menu. Direct buffs/passives use the common model without posing as Strike/Surge/Zone; passive activation needs no separate format, and species exclusivity is access data, not `unique` execution.

### Strike

- **Immediate body shape:** starts adjacent to the monster, without anchor, range or Reach. Damage: [Battle §6.1](gdd_battle.md#61-the-damage-law); Swarm's existing 4-damage exception affects props, not monsters. Spend the selected shape's price (§8.1; costing §5); larger area never trades away damage.
- **Selection/hits:** no facing; choose one of 8 directions (§8.1 shapes/Kin effects). Hit every monster/prop in the shape, including allies, excluding the striker. Solid props take the hit and block cells behind them.

### Body-Relative Damage and Movement Variants

**Confirmed additional authoring direction, not a replacement for existing Kin Strikes or a priced skill catalogue.** Body-relative shaped actions may be authored as damage only, movement only with no direct damage, or damage plus movement. Each is a finished variant in the shared §2 model; no cast-time damage-for-movement exchange, free component choice or separate construction system. Shove names the movement-only direction, not a direct unit-targeted attack. Existing Strike damage, Kin effects and authored AP remain unchanged pending their reconciliation (T02/T06).

- **Supported geometric scope:** attacker and target are 1×1 bodies; the hit square is adjacent to the attacker's origin. Its offset `d = (dx, dy)` is one of the eight neighbouring unit vectors, including diagonals. Preview the hit and destination before activation; there is no independently chosen displacement direction.
- **Target-movement variant:** for a target on the hit square, destination = hit square + `d`, one square farther from the attacker. It is forced displacement under §4 and Battle §6.3/§6.5, not prop relocation or extra skill damage.
- **Self-movement variant:** destination = attacker origin − the uniquely defined attack-direction vector, once per use, never once per struck target. It uses the self-movement contract, not an assumed copy of forced-movement collision behaviour. A larger/symmetric/otherwise ambiguous pattern without one unique geometric retreat direction has **no self movement**; do not choose a hit target, average offsets or add a free retreat-direction selector.
- **Hit-independent retreat:** the authored self retreat is triggered by a valid activation, not by striking a monster/prop, dealing damage or destroying anything. An empty hit pattern still allows it as a movement tool, subject to the same unique-direction and legal-destination constraints. The attack/board payload resolves independently: prop damage requires its authorized damage source, and Mountain destruction requires an explicit authored operation (§4/Battle §4.7); retreat alone grants neither. The internal valuation must include this unconditional movement capability, not discount it by an assumed hit probability.
- **Attack before self retreat:** resolve the attack payload first, then attempt the single retreat to its geometrically fixed destination using the resulting board state. If that destination is absent or illegal (including blocked/occupied/off-board), the attacker stays in place: no alternative destination, no retreat collision damage or other effect from the failed movement. The attack remains resolved and its activation costs/usage stay consumed. This scoped failed-retreat rule does not redefine forced push/pull collision consequences.
- **Retreat traversal** *(user decision)*: the retreat is a voluntary one-cell self movement that checks only the destination cell, with no corner-cutting check on the two orthogonally adjacent cells for diagonals. Moving **up onto a Mountain** from below is blocked like for forced movement (failed retreat, no effect). Moving **down from a Mountain** causes **no fall damage**; fall damage stays exclusive to forced movement ([Battle §6.3](gdd_battle.md#63-collision-fall--debris)). A successful retreat **triggers entry effects** of the destination ground (e.g. Thornbed, Mossbed; [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed)). Layer/air restrictions remain T09; 2×2 attackers: see *2×2 bodies* below.
- **Multi-cell shapes** *(user decision, 1×1 targets)*: the target-movement variant applies **per struck monster standing on a hit cell adjacent to the attacker's origin**, each pushed one square along its own offset `d` away from the attacker (Whirl/Storm push outward, Arc fans out). Monsters on non-adjacent hit cells (e.g. Thrust tip, Cleave rear row, Long Whirl/Cross) are damaged as usual but **not moved**; no direction normalization is added. Radial destinations of 1×1 targets are pairwise distinct, so no destination ties arise. Self retreat is unchanged: it still needs one uniquely defined attack direction, and no multi-cell shape gains a retreat by this rule.
- **Retreat direction for shapes** *(user decision)*: the retreat goes **opposite to the centre of the hit shape**, one cell from the attacker's origin. The direction is the geometric centre (mean of the shape's hit-cell offsets) relative to the origin and exists only if that centre lies on one of the eight directions (on an axis or exactly diagonal); the retreat is then the opposite unit vector. Shapes whose centre is the origin (Pincer, Whirl, Cross, Storm, Long Whirl/Cross) or lies off all eight directions have **no self retreat**. Jab, Thrust, Diagonal Thrust, Arc and cardinal Cleave qualify. A retreat variant needs a hit shape (a movement-only retreat uses a damage-free hit shape, no empty pattern), and the direction is the Strike direction selection already priced. The user confirmed this reading on 2026-11-10.
- **One hit per monster** *(user decision)*: a monster covered by several hit cells (mainly 2×2 bodies) is struck **once per use**: damage, Kin effect and push/retreat trigger once, regardless of covered cells. Construction prices stay per potential cell (hit multiplicity is not priced). 2×2 specifics: see *2×2 bodies* below.
- **2×2 bodies** *(user decision 2026-11-10; body rules in [Battle §4.3](gdd_battle.md#43-the-square-stack-zones--ground))*: for a 2×2 **target**, the push offset `d` is the mean of the offsets of its covered hit cells adjacent to the attacker's origin; it applies only if that mean lies on one of the eight directions, otherwise the body takes damage and Kin effect but is not pushed. A 2×2 **attacker** with a retreat variant retreats with its whole body one square along the opposite unit vector; legal only if all four destination squares are legal, else it stays in place (failed-retreat rule above). A 2×2 attacker chooses one of its four covered squares as the shape origin together with the direction, shown in the preview; its own body squares are not hit. A 2×2 target of a pull moves one cardinal step of the whole body, with the direction taken from the covered square nearest the anchor (ties as for 1×1, T04). A 2×2 is affected by any zone, Surge footprint or hit shape that overlaps at least one covered square, once per event or use. Open (T09): Mountain air rule for 2×2 and entry/exit details.
- **Access** *(user decision)*: the variants are **Kin-bound**: target-movement (push) variants, damage-plus-push or movement-only, only for Scaled; self-retreat variants only for Winged. The existing Kin Strikes (Scaled push 1 with its push-direction choice, Winged retreat 1) stay unchanged and are separate skills. No variant is open to other Kin, and no Kin package is transferred. Shape AP and stage limits follow [§8.1](#81-strike-by-kin); concrete species lists remain content work (T11).
- **Authored alternatives:** target movement or self movement is fixed by the skill, not selected after a hit. Preserve source-specific side/caster/layer permissions and legal landing rules. Blocked/occupied destinations grant no automatic alternative square. Collision, fall and entry consequences remain environmental/runtime consequences, not an extra authored damage component.
- **Spatial boundary:** non-adjacent off-axis hits have no inferred normalization/tie-break; 2×2 geometry follows the *2×2 bodies* entry above, but the 2×2 variants stay unapproved until the checker and cost notes cover them (T09/T02). This coupled eight-direction rule does not change existing cardinal zone/Surge push/pull or silently replace Scaled's selected direction and Winged's existing retreat package. Prices, AP, access and unresolved ordering within the attack payload/multi-target resolution remain T02/T04/T06; neither a damage value nor a damage-for-distance exchange is approved by this section.

### Surge

- **Surge:** telegraphed delayed execution, pending marker/timer, zone shapes/placement but its own slot/lifecycle.
- **Concurrent casts:** a monster may have multiple pending Surges from different equipped skills or repeated casts of the same skill instance when its [usage policy](#usage-and-repetition) permits. Each cast pays its own authored Battle-AP and creates its own pending marker/timer under the existing scheduling contract. No monster-wide charging cap applies. Placement still forbids overlap with any pending Surge; ordering when multiple casts resolve at the same event remains T04, not an implied cast-order rule.
- **Aftermath:** optional, explicit, separately budgeted `board_changes`, never implied by Surge alone. Damage precedes authored ground aftermath. No new prices here; legality/evaluation/validation: §4/§5/§7.

```
MINOR SURGE
  shape/placement: resolved authored footprint and constraints (§2/§3), checked under [central skill rules](#2-data-oriented-skill-construction-kit)
  range: effective Reach to anchor unless an explicitly approved baseline profile says otherwise
  charging: visible, blocks movement through its squares
  fires: at the START of the caster's next turn (simple alternating 1v1: after the opponent's turn)
         if the caster died, it fires at the start of the next round ([Battle §2.2](gdd_battle.md#22-initiative-rules))
  autonomous: not cancelled by displacing / killing the caster
  per-square result:
    monster  → authored value, reduced by zone shield and Hallowed (minimum 0 damage)
               (hits every monster on its squares — allies and the caster included)
    prop     → ordinary interception instead of its occupant (Battle §4.10); profile exceptions below
               select reactions resolved under Battle §4.10–§4.11
    Mountain → depends on the Surge profile (table below)
  afterwards: only if explicitly authored, apply the separately budgeted RESIDUE
              board_changes effect (permanent ground, gdd_battle §4.7), subject to its profile's
              height rules below; otherwise no residue; no repaint
  usage: spend authored AP (§5) per cast; repeat availability follows the equipped instance's usage policy (§2)
  claims squares: can't be placed on squares already holding any charging Surge (the first one claims them)

MAJOR SURGE
  shape/range: requires an explicitly authored large-area profile, not a generic size/range override
  usage: once per battle; authored AP and access: §5/§1
  open: legacy up-to-half-board/long-range wording needs a concrete definition (T02);
        Ancient vs Legendary Signature access remains T02/T32, not permission for either by inference
```

- Prop interception, ordinary prop damage and destruction are resolved by [Battle §4.10](gdd_battle.md#410-prop-catalogue-and-damage). *(User decision 2026-11-11:)* the three profiles carry **no prop-specific exceptions**; props take ordinary Surge handling (2 damage, intercepting the hit) and only the `heavy` tag of [Battle §4.11](gdd_battle.md#411-prop-reactions) applies.

- **Concrete profiles:** existing Surges specify **Eruption**, **Flood** or **Rift**, independent of theme. Their authored residue remains mandatory for those profiles despite the general model's optional residue.
- Timing alone neither requires these profiles nor authorizes new combinations; validate definitions under §7. These are mechanical profiles, not aspects/replacement elements; “Flood” is never a zone and need not resemble water.
- Existing damage/residue/prop/height effects:

|     Type     | Damage |     Residue (permanent, level I)      |                                                                     Props                                                                     |                            Mountain                           |
|--------------|--------|---------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------|
| **Eruption** |      3 | **Lava I** — burns at end of turn | ordinary prop handling | hit normally, cannot change ground on a Mountain (**no residue** there; lava runs off), does not destroy it |
| **Flood** |      2 | **Thornbed I** — hurts when entered | ordinary prop handling | **can't reach it** (square blanked) |
| **Rift** |      3 | **Blight I** — hurts at start of turn | ordinary prop handling | **destroys it** ([Mountain-destruction rule](gdd_battle.md#47-ground--neutral-hazard-and-blessed)): the monster on it takes the Surge damage plus the environmental 1 collapse damage; its Blight I residue becomes the new ground |

- **Push order:** damage-2/Thornbed also pushes struck monsters **1 square in the cast-fixed direction**, toward the squares that will receive residue afterwards. The order damage → push → residue follows the [payload resolution order](gdd_battle.md#62-surge-resolution-integration), so struck monsters are pushed before the residue is laid and do not enter it through this push; T07 only reviews the ground interactions.
- **Collapse state:** the final ground after a Mountain is destroyed follows the Mountain-destruction rule in Battle §4.7 (the destroying skill's own ground, otherwise Rubble). Order of Surge damage, displacement and board operations (incl. collapse damage and residue): [payload resolution order](gdd_battle.md#62-surge-resolution-integration).

A Mountain therefore offers profile-specific protection, not a universal Surge counter.

**Runtime counter menu** (authoring validation of live counters: §2/§4/§5/§7):

|            Counter             |                                                         How                                                          |
|--------------------------------|----------------------------------------------------------------------------------------------------------------------|
| **Leave**                      | move out of its squares before it fires — but mind any explicitly authored residue                                             |
| **Zone shield** | `shield` over its squares: reduction 2 (up to 3 with level) cuts damage 1:1 per square; recast to level up |
| **Pick the height** | Create Mountain where legal; protection, residue exclusion or collapse depends on the profile table above |
| **Stand on Hallowed** | Use its Surge reduction and replacement contract in [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) |
| **Fly over it**                | Existing Surge damage recipients exclude air unless a definition authors air recipients ([Battle §4.3](gdd_battle.md#43-the-square-stack-zones--ground)); the air layer is out of reach (Winged, Soul+), except from attackers standing on a Mountain ([gdd_battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed))                                       |
| **Props / debris** | Use the interception/destruction rules in [Battle §4.10](gdd_battle.md#410-prop-catalogue-and-damage), subject to the draft prop catalogue |
| **Answer with your own Surge** | race it — but you can't claim squares already held by a charging Surge                                               |
| **Control the tempo**          | slow / pull / push zones to steer where the target can stand; drain the caster's initiative to delay its next turn      |

### Movement

Resolve **Step** as the universal one-square action; slotted movement uses the presets below. Kit/access and AP evaluation are defined in §1/§5; Kin preset access remains §8.2. Movement distance uses effective **Movement**, not Reach.

Movement skills use **flag profiles**, not special-case lists. Modes are authorized presets, not player permissions; separately authored profiles still need access/full validation (§2/§4/§5/§7).

|          Flag          |                                     Meaning                                     |
|------------------------|---------------------------------------------------------------------------------|
| `path`                 | `walk` square by square · `line` straight line, only the landing square counts · `free` any path, only the landing square counts · `teleport` any free square in range |
| `blocked_by_objects`   | solid props block the path                                                      |
| `blocked_by_monsters`  | monsters block the path                                                         |
| `blocked_by_surges`    | charging Surges block the path                                                  |
| `blocked_by_height`    | can't start or end the move on Mountain                                         |
| `ground_costs`         | Rubble and climbing cost 2 movement, Thornbed fires on every square entered (walk only) |
| `distance_mod`         | distance = Movement + this (min 1)                                              |

|       Preset       | path | objects | monsters | Surges | height | ground costs | distance_mod |
|--------------------|------|---------|----------|--------|--------|--------------|--------------|
| **Step**           | walk | yes     | yes      | yes    | no     | no (and ignores `slow`) | always 1 |
| **Run**            | walk | yes     | yes      | yes    | no     | yes          | 0            |
| **Leap**           | line | no      | no       | no     | no     | no           | 0            |
| **Glide**          | free | no      | no       | yes    | no     | no           | −1           |
| **Burrow**         | free | no      | no       | no     | yes    | no           | −1           |
| **Phase**          | walk | no      | yes      | yes    | no     | yes          | −1           |
| **Blink**          | teleport | no  | no       | no     | no     | no           | −2           |

- **Price rule:** every restriction a preset drops is paid for in distance or in direction (Leap: straight line only). New modes follow it
- Apply only the resolved, authorized movement variant; upgrade allowances and AP consequences belong to [§6](#6-slot-levels-development-replacement-and-upgrades), not a second battle upgrade rule
- Min 1 square for every movement skill. Step ignores slow and extra ground costs, but still requires a legal unblocked destination
- Ignoring path blockers permits no occupied landing. Walk processes entered cells; line/free/teleport only landing, with destination effects still applying.
- Glide grants no persistent flight; flight rules: [Battle §4.3](gdd_battle.md#43-the-square-stack-zones--ground); layer change/landing remain T09.

### Surge Constraints and Species Access

- **At most one twist:** one preview-readable extra rule, advantage priced under §5/§6. Represent it through placement/area/execution/effect/residue data and explicit profile constraints, not another schema or universal named-power menu.
- Battle rules (§2–§3) remain binding; old damage/range candidates grant no exceptions/upgrades.

Preserve the existing structural restrictions when authoring or upgrading a constrained Surge:

| Authored constraint | Validation |
|---------------------|------------|
| Adjacent anchor | Anchor stays adjacent; an existing 4-cell footprint has no Size path. |
| Straight trail from an adjacent cell | Footprint starts adjacent and stays straight; only legal I2/I3 families/orientations. |
| Four cardinal neighbours of the caster | Excludes the caster cell; no Shape or Size path. This special footprint is not generic ranged targeting. |
| Enlarged footprint | Result stays within its profile/Kin cell cap; do not charge the same enlargement twice. AP consequences follow §6, not an automatic surcharge. |
| Pull after damage | Existing one-square cardinal displacement toward an anchor fixed at cast; [gdd_battle §6.5](gdd_battle.md#65-displacement). |

- **Species Surge:** one per species, with its own twist; included in default kit/learnable list but optional as a normal slot skill (§1). Shape/Size upgrades preserve constraints; no Twist replacement path. Ownership is access/authorship on the same definition, not a new kind. Concrete twists/roster placeholders still need design/validation (T10–T12).

## 4. Effect and Board-Operation Contracts

**Effect catalogue — data, not skill blueprints**

- `damage`, `displacement`, `stat_change`, protection, healing, self movement and board operations are **typed contracts**, not purchasable permissions. Each needs an effect definition, legal owning profile/source, recipients, trigger/application and resolution order.
- Definitions own allowed parameters, caps, interactions and termination; skills supply only permitted values, never independently editable copies of fixed fields. References are documentation contracts, not new engine identifiers.

**`damage` — apply an existing damage source**

- Required data: source/profile definition, profile-authorized value or value source, footprint/recipients, trigger and ordering reference.
- Reduction, height and air eligibility come from that profile, never from a generic damage flag.

| Existing source/profile | Permitted value and recipients | Trigger, order and limits |
|-------------------------|--------------------------------|---------------------------|
| Strike | Values, monster/prop recipients and Kin exceptions: [§8.1](#81-strike-by-kin) and [Strike profile](#strike) | Bind immediate body-relative execution, prop blocking and ground/air coverage to that profile; no Reach targeting. |
| Surge | Values, recipients, ordinary prop interception and concrete prop/height exceptions: [Surge profile](#surge); the residue-free Delayed Burst record in [gdd_skills.md](gdd_skills.md) remains a separate draft, not balance approval | Bind delay, reductions, ground-layer eligibility and damage-before-authored-residue order to that profile and Battle §6.2. Do not substitute one profile's payload or exceptions for another's. |
| Hazard ground | Reference the concrete ground definition in [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) for value, recipients and caps | Bind its existing event under [Battle §2.4](gdd_battle.md#24-effect-timing-reference). Placement is `board_changes`, not immediate damage. |
| Collision / fall / debris | Reference [Battle §6.3](gdd_battle.md#63-collision-fall--debris) for event damage and recipient exceptions | Derived runtime consequences, not free castable payloads. Monster collision: 1 damage to each monster ([Battle §6.1](gdd_battle.md#61-the-damage-law)). |

- **Damage permissions:** [Surge profiles](#surge) own damage recipients; they currently carry no prop exceptions, and the prop catalogue is in Battle §4.10. Major/baseline twist exceptions need authored definitions/access/usage; no new damage values here.
- **No zone damage, immediate ranged burst, new damage zones or generic direct unit-targeted damage.** Retired collision bonuses remain unapproved (T04), not collision-law exceptions. Damage values are not slot-upgrade parameters (§6).

**`displacement` — forced movement under an existing source**

- **Required:** definition/source, `mode: push | pull`, recipients, `steps`, trigger/order, direction/anchor binding. Use [Battle §6.5](gdd_battle.md#65-displacement) for generic cardinal displacement and the scoped geometric exception in the [body-relative variants](#body-relative-damage-and-movement-variants); Scaled retains its existing chosen push direction pending reconciliation. Preview landing; fields grant no beyond-cap distance upgrade.

| Existing source | Recipients and trigger | Binding constraints |
|-----------------|------------------------|---------------------|
| Zone `push` / `pull` | Occupants under [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites) | Bind direction/anchor and trigger to [Battle §6.5](gdd_battle.md#65-displacement), with ordering under [Battle §2.4](gdd_battle.md#24-effect-timing-reference). Persistence creates no additional trigger. |
| Geometrically coupled body-relative target movement | Occupants struck by the authored hit pattern, not a selected unit | Adjacent 1×1 geometry and one-square outward direction: [body-relative variants](#body-relative-damage-and-movement-variants). No independent direction, new layer access or prop relocation. |
| Scaled Strike | Struck monsters under the Kin push definition | Existing Kin twist (§8.1); chosen direction and Strike constraints. |
| Surge profile with cast-direction push | Recipients, distance and trigger from the [Surge profile](#surge) | Preserve that profile's complete damage, residue, height and prop contract; unresolved ordering is not an override. |
| Authored pull twist | Struck monsters, pull 1 toward cast anchor after damage | Existing twist (§3); no arbitrary extra target or trigger. |

- **Consequences:** blocking/collision/fall [Battle §6.3](gdd_battle.md#63-collision-fall--debris), entry [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed), prop destruction [Battle §4.10](gdd_battle.md#410-prop-catalogue-and-damage). No implied chain push, extra step or air/prop eligibility. Diagonal displacement is limited to the explicitly coupled adjacent-hit contract; other sources retain cardinal rules.
- **Order:** payload order, board-operation categories, same-category conflicts and dead-caster scheduling are decided in [Battle §6.2](gdd_battle.md#62-surge-resolution-integration) and [§2.2](gdd_battle.md#22-initiative-rules); no list-order or cast-order defaults.

**`stat_change` — referenced effective modifiers, not arbitrary stat edits**

- **Required:** typed `stat_change` definition, stat/operation, value/source, recipients, condition, lifetime, stacking group/rule, caps/floors and ordering. Timed self buffs, conditional passives and zones share this model; approved definitions restrict skill parameters. Named definitions keep fixed stat/sign/timing; new combinations remain drafts until validated. Effective modifiers never rewrite base stats.
- **Zones:** affect **everyone while inside**, end on exit/removal/expiry and use replacement/opposition/level rules (max III), not permanent cumulative deductions ([gdd_battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites)).
  - Level III does not authorize value 3 for every effect.
  - Definitions own `base`/`cap`; use [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites) for level-to-value computation, never unrestricted deltas.
  - Missing caps/scaling remain open.

| Existing definition | Meaning / existing authored values | Bounds and timing |
|---------------------|------------------------------------|-------------------|
| `slow` / `haste` | Movement −value / +value; retain authored values such as slow 1 | Bounds, timing and Step exception: [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites). Changes Movement-skill effectiveness, not AP cost, TPR or a permanent stat. |
| `drain_init` / `quicken` | Effective initiative −value / +value; examples include −1, −2 and +1 | Timing and order recalculation: [Battle §2.2](gdd_battle.md#22-initiative-rules). No immediate queue rewrite or arbitrary numeric interval. General effect-value caps/floors are not specified by [gdd_battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites) and remain open. |
| `drain_range` / `extend` | Effective Reach −value / +value; examples include −1, −2 and +1 | Floor: [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites). No independent per-skill range stat. Upper modifier/value caps require clarification, not extrapolation from progression ceilings. |

- **Timed Kin modifier:** Spirit Strike applies target initiative −1 next round (§8.1), not `while_inside`. Its distinct timed `stat_change` definition preserves trigger/expiry; stacking, refresh and expiry follow the [stat-modifier rule](gdd_battle.md#31-effective-stats) (same source refreshes only, other sources add; N-round effects end at the round end of the N-th following round). This is neither a free timing override on zone `drain_init` nor arbitrary timed Initiative/Reach/Movement permission.

- **Other sources:** Hearth/Shrine provide `quicken 1`, Umbra `extend 1`, occupied Mountain +1 Reach. Keep ground/prop/height conditions, not zone expiry or free source substitution (gdd_battle §3.1/§4.7/§4.10).
- **Distinct contracts:** `shield` uses existing Surge reduction ([counter menu](#surge)), `mend` caps at max HP, `expose` is reserved without a zone. Reduction/healing/reserved definitions grant no generic stat edits.

- **Prohibitions:** no general temporary **TPR/AP/max-HP/movement-rule/flag** edits. Species-specific timed boosts need definitions, duration, limits and validation (§1), not arbitrary stat permission. Base-skill Reach debuffs/positional buffs are temporary battle effects, not cast-range upgrades; slow is not AP reduction. Budgets never authorize slot damage increases, AP reductions or cast-range increases (§6).

**Persistent self buffs and passive rule modifiers — shared contracts**

- **Timed self state:** ordinary `stat_change`/applicable typed effect, self recipients, explicit lifetime. Status is created runtime state, not a skill kind. Reapplication follows [Battle §3.1](gdd_battle.md#31-effective-stats) (same source and owner: refresh duration only; different sources add without a cap); specify the source identity, removal and caster/recipient death dependencies. the Focus record in [gdd_skills.md](gdd_skills.md) is structural draft, not generic timed-boost approval.
- **Passive rule/stat modifiers:** use continuous/conditional `stat_change` or typed **`rule_modifier`**. Each `rule_modifier` names the exact changed rule, scope (e.g. owner's shapes), operation/parameters, activation condition, lifetime, stacking and precedence. the Adaptive record in [gdd_skills.md](gdd_skills.md) (owner-scoped rotation) grants no arbitrary mutation.
- **Event-driven passives:** same effect/board contracts, explicit event source, recipient binding, repeat/recursion limits and order; undefined policies block content.
- **Extensions:** opaque `custom_effect`, per-skill callbacks and ownership permissions are incomplete definitions. Extend shared typed contracts/common costing; source-specific validation restricts content, not representable families.

**`shield` / protection — referenced reduction, not shield HP**

- Required data: protection definition and owning source/profile, permitted reduction/value source, protected recipients and damage sources, application condition, damage-event ordering, lifetime/consumption and stacking/cap references.
- Protection neither grants temporary HP nor edits a defense stat.
- Fixed source rules cannot be replaced by a generic immunity or damage-filter field.

| Existing definition/source | Recipients, trigger and lifetime | Ordering and caps |
|----------------------------|----------------------------------|-------------------|
| Zone `shield` | Bind recipients/application to [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites) and lifetime to [Battle §4.5](gdd_battle.md#45-lifecycles) | Reduction and scaling/cap follow the [Surge profile counter menu](#surge). No independent charges or effect timer. |
| **Nullify** *(draft, user 2026-11-11)* | Sets the protected monster's next Surge damage to 0 after the damage sum ([Battle §6.1](gdd_battle.md#61-the-damage-law)); sources: tamer Spirit Shield and, as a separate authored effect, monster skills | Consumed by the first Surge damage instance of at least 1 after the sum; one per monster, no stacking. Price far above value reduction (§5, open T02); monster access needs its own authored definition and validation |
| Hallowed ground | Reference [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) for occupants, reduction and ground lifetime | Preserve the Surge profile's residue/height interaction; do not invent a separate hit-consumption rule. |

- **Protection exclusions:** retired Lava immunity/prop reinforcement/Strike reduction proposals need separate validation (T02/T04/T10), not generic `shield` options; `expose` stays reserved. Once-per-battle tamer protection ([gdd_overworld §6.4](gdd_overworld.md#64-tamer-skills)) grants no repeatable monster immunity; monster Nullify is its own authored effect above. Additional sources need authored definitions, not source substitution/default stacking (T02/T04/T20).

**`heal` — restore current HP only at an existing trigger**

- Required data: healing definition/source, authorized amount/value source, recipients, trigger, ordering, lifetime and cap/usage references.
- Healing never exceeds the recipient's existing max HP, changes max HP, revives a fallen monster or removes Injury.
- Definitions bind the event; persistence alone grants no heal on cast, per tick or extra activation.

| Existing definition/source | Recipients and trigger | Lifetime, order and caps |
|----------------------------|------------------------|--------------------------|
| Zone `mend` | Reference recipients/trigger in [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites); magnitude `min(2, zone level)` per Battle §4.6 (user decision 2026-11-10; price open) | Ordering uses [Battle §2.4](gdd_battle.md#24-effect-timing-reference); zone lifetime is shared. Level scaling and numeric healing cap remain open under T07, not implied by max zone level III. |
| Mossbed | Reference occupants, entry trigger and heal amount in [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) | No additional placement or continuous heal. No per-turn or re-entry limit (user decision 2026-11-10); every entry heals as in Battle §4.7. |

- **Healing boundaries:** no generic immediate/direct monster heal, ally-only zone or new repeat trigger. The proposed tamer heal ([gdd_overworld §6.4](gdd_overworld.md#64-tamer-skills)) is no monster definition. Pills heal **between battles**; expedition HP persists; Revival ends Injury, not battle HP loss (gdd_overworld §5.2/§6.4–6.6).
- Planned battle medicines/arrays need source, consumption, loadout and timing contracts (T18/T19), not generic `heal` permission. Economy/repeat-entry balance remain T07.

**Self `movement` — voluntary relocation of the caster**

- Required data: movement definition/source and authorized preset/exception, `recipients: self`, resolution trigger, origin and selected path/destination, distance source, path/landing/occupancy constraints, ordered traversal/entry events, action lifetime and usage/cap references.
- This is not forced `displacement`, unit relocation or prop movement.
- Resolve one movement action under [§3](#3-skill-execution-profiles); it creates no persistent movement permission.

- **Step:** resolves as the universal one-square action under the [Movement profile](#movement) (slot-free, 2 AP, exactly 1 square); not freely upgradable.
- **Slotted movement:** authorized [preset](#movement) (path, blocking, ground-cost and landing rules there), AP baseline (§5), **Movement, not Reach**.
- **Access:** §8.2 owns presets/foreign modes, body/stage restrictions. `path: teleport` grants no access without an authorized profile; free paths grant neither persistent flight nor air access. Winged air requires Soul; flight movement and air occupancy: [Battle §4.3](gdd_battle.md#43-the-square-stack-zones--ground), layer change/landing remain T09. Planned Water/Swim remain T08, not legal for unspecified Kins.
- **Custom modes/upgrades:** satisfy distance/direction pricing and access; fields are no player bypasses. §6's named one-flag-flip/distance-penalty patches grant no unrestricted path-mode, flight, teleport, extra action or range upgrade. Validate complete profile, entry order and destination preview; large-body/movement gaps remain T04/T09.

Tamer-source unit relocation and unit-swap effects retain their separate definitions (including proposal status where applicable), not self-movement presets or a shortcut around monster access rules ([gdd_overworld §6.4](gdd_overworld.md#64-tamer-skills); T19/T20).

**`board_changes` — typed ground, height and prop operations**

- **Required:** operation definition, legal source/profile, selected cells or prop/destination where relevant, cast/resolution trigger, damage/reaction ordering dependencies, resulting state/lifetime, placement/blocking/occupancy and cap references.
- **Scope:** recipients are board cells/props, not ally/enemy filters on later occupants; resulting hazards/healing/modifiers retain their effect contracts. Operations are one-time transitions unless explicitly assigned later events; permanent state is not repeated execution.

- **Ground placement / replacement**
  - Required data / source: Concrete ground definition and permitted level/source, footprint; immediate hazard cast, blessed-ground cast or specified Surge residue
  - Binding lifetime, ordering and limits: State, replacement/levelling, entry semantics and Voidscar exception: [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed).
    - Placement uses §2; prop reactions use [Battle §4.11](gdd_battle.md#411-prop-reactions).
    - Surge aftermath follows its §3 profile.
    - Zones never change ground (Battle §4.6).
- **Height change**
  - Required data / source: Separate height definition, affected cells and authorized source: Mountain creation with coupled ground reset, or an explicit Mountain-destruction operation
  - Binding lifetime, ordering and limits: Reference [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) for height state, the Mountain-creation source's coupled Plain reset and the Mountain-destruction rule (collapse damage, resulting ground), and [Battle §6.3](gdd_battle.md#63-collision-fall--debris) for fall consequences.
    - Declare coupled operations explicitly; height edits grant no generic damage or displacement payload.
    - Surge-specific height handling remains §3; no new height levels or timed expiry.
- **Prop create / place**
  - Required data / source: Existing prop definition from the [catalogue](gdd_battle.md#410-prop-catalogue-and-damage) (HP, class, tags, `on_destroy`), legal footprint and creation source
  - Binding lifetime, ordering and limits: Placement uses §2; state and prop definitions use [Battle §4.9–§4.10](gdd_battle.md#49-props).
    - Reference existing lifetime/HP; unsupported occupancy/layer cases remain T04/T09.
- **Prop move / relocate**
  - Required data / source: Authorized source, selected prop, origin/destination and applicable path/placement constraints
  - Binding lifetime, ordering and limits: Reference placement in §2 and prop restrictions in [Battle §4.10–§4.11](gdd_battle.md#410-prop-catalogue-and-damage).
    - Generic unit push/pull is not a prop-move definition.
    - *Relocate contract (user-confirmed 2026-11-10; the source itself is not yet approved content):* an authorized source moves one selected eligible prop exactly one square orthogonally to a legal empty square (placement rules of Battle §4.9–§4.10; not onto monsters, props, edges or illegal ground); heavy props are not eligible; legality is checked at execution (Battle §6.2), an illegal move does nothing; a relocated prop keeps its HP, tags and lifetime and triggers no destruction aftermath, only the entry/placement effects its type already defines. Longer distances or paths need a separate authorized contract.
- **Prop destroy / remove**
  - Required data / source: Existing destruction/reaction definition and eligible prop; damage-derived destruction references the damage source, not a free deletion flag
  - Binding lifetime, ordering and limits: Reference the prop catalogue and aftermath in [Battle §4.10](gdd_battle.md#410-prop-catalogue-and-damage) and the destruction order in [Battle §6.2](gdd_battle.md#62-surge-resolution-integration).
    - Direct deletion or suppressed aftermath requires a separately approved source; removal does not imply the type's aftermath unless that source says so.
- **Cleanse**
  - Required data / source: Explicit source, exact affected layer/state, legal footprint/recipients and resulting state
  - Binding lifetime, ordering and limits: The existing Mountain-creation source clears non-Voidscar ground to Plain as above; no further monster Cleanse source exists (user decision 2026-11-10); a new one needs an explicit definition and validation and is parked under Potential Extensions.
    - Zone removal ends its effects, not ground/height/props or a charging Surge.
    - The combined zone-removal/Plain-reset exception is a tamer-source operation ([gdd_overworld §6.4](gdd_overworld.md#64-tamer-skills)), not a reusable monster permission.
    - No generic cleanse of all layers, negative effects, Injury or Voidscar; unresolved combinations remain T02/T07/T20.

- **Validation:** retain owning-profile Reach/anchor, fixed/on-board footprint, LOS and blocking ([gdd_battle §4.3–4.11](gdd_battle.md#43-the-square-stack-zones--ground); §2–§3 here). No-LOS ground/prop casts still obey their empty-cell requirements. Preview resulting ground/height/props, reactions and derived damage.
- Simultaneous damage/collapse/aftermath/residue/relocation order: [Battle §6.2](gdd_battle.md#62-surge-resolution-integration) (decided); never list-order defaults. Planned loadout operations stay T18/T19. This catalogue approves no new props, conversion, board erasure or movement modes.

## 5. Construction Points and AP Efficiency

**Evaluation rules for the [shared data model](#evaluation-contract--one-definition-one-calculation), not a second skill definition.** This section owns prices/calculation only; use the §2 field bindings and §4 effect/operation contracts rather than reproducing their fields or mechanics here.

**Confirmed: one shared base budget, no skill ratings, upper bounds only.** All regular monster skills share construction; no Rare/Epic/Legendary/Mythical budget classes or automatic rarity/exclusivity bonus. Slot levels 1–3 raise ceilings. Major/Signature still need access/profile review, not a general higher-budget rating.

```text
skill point cost = mechanical component costs
                 + availability cost

availability cost = AP-efficiency cost (active skills)
                  or passive-availability cost (passive skills)


allowed ceiling = shared base budget + slot-level allowance

skill point cost <= allowed ceiling
```

- **AP efficiency:** fewer battle AP/use buys a powerful advantage, costing more construction points; higher AP leaves more effect room, never costs extra merely for spending AP. Author the finished skill/AP, then evaluate total points: AP cost is part of valuation, not an AP-class budget ladder or separate budget source.
- **Confirmed costing structure:** combine one-time use/availability costs with effect-extent costs. Charge AP efficiency, free-anchor choice and the complete Surge marker once at their applicable scope, not per footprint cell. Price area effects per potentially affected cell; non-area effects use their authored package (e.g. movement). Duration, magnitude and other explicit effect dimensions remain part of the component formula. No generic activation surcharge per added effect or blanket area surcharge on top of its cell price.
- **Shared component prices:** charge actual mechanics once, never redundant tags/flags or the same enlargement twice; no combination surcharge ([policy](#combination-policy-and-basic-surge-target)). Evaluate telegraphing/blocking/restrictions in context, without arbitrary negative credits or uncalibrated exceptions.
- **Confirmed decimal-point handling:** construction prices and totals may be decimal values. Do not round components or totals for budget comparison; compare the full calculated value with the ceiling. Display-only rounding must not change that result. This applies to internal skill construction points, not combat damage, Battle-AP, stats or other currencies; it changes neither existing prices nor ceilings.
- **Purpose:** construction costing screens for gross outliers and supports comparable skill power; numeric agreement does not guarantee equal strength, justify fitting every skill into a ceiling or replace interaction/balance tests.
- **Residue:** optional, separately priced board operation including interactions; delay/damage implies no ground payload.
- **Upper bound only:** no minimum, target band, exact spend or random budget; simpler skills may leave points unused. Unchanged skills get no automatic AP reduction; development at original AP and optional higher-AP extensions: [§6](#6-slot-levels-development-replacement-and-upgrades).
- **Passives:** no AP spend/free efficiency; explicitly price availability, conditions, event frequency and repeat/recursion exposure under the same total/slot ceiling, not a separate budget or zero-AP active tier. Initial availability reference below; other/event-driven patterns need separate evaluation.
- **Hard limits:** budgets never override damage caps, access, targeting, effect legality or profiles. Slot upgrade limits: [§6](#6-slot-levels-development-replacement-and-upgrades).
- **Calibration:** budgets/AP scale/components below are not validated balance. Unpriced components, combination reviews and tests remain temp_todo T02; all six [gdd_skills.md](gdd_skills.md) records remain incompletely validated.

| Slot level | Budget ceiling — preferred working draft |
|------------|------------------------------------------|
| 1 | 24 points (shared base budget) |
| 2 | 30 points (base +6) |
| 3 | 36 points (base +12) |

Maximums only: no spending targets, balance/component-price approval, step prices or unlock conditions.

### Component Price Sheet

**Calibration drafts, not validated balance. All prices are construction points, not combat damage.** Cells are potential footprint cells, not guaranteed hits; a 2×2 body is struck once per use (§3); 2×2 variant prices remain T02/T09.

| Component | Price | Scope |
|-----------|-------|-------|
| One-shot damage | damage × cells × 2 | One damage event; scales per potential cell, not a flat per-use fee. Area included; no second blanket area charge |
| Immediate timing | 100% of damage base price | No blanket surcharge |
| Telegraphed, avoidable Surge timing | 50% of damage base price | Discount on damage only, not other components |
| Ground + air damage coverage | +2 per damage effect | Once, not per cell; authorized sources only |
| Free board anchor within Reach, no LOS | +2 | Combined property, not two charges |
| Strike footprint-direction choice | +2 | Only when selection changes hit cells |
| Strike distant hit cells | +2 per distant cell | Outside adjacent eight-cell ring |
| Fixed non-Strike shape alone | No blanket surcharge | Additional advantages/combinations still count |
| Slow zone | rate: [Zone, Protection and Healing Costs](#zone-protection-and-healing-costs) | Existing base 1/cap 2 contract |
| Charging Surge blocking | +1 per complete marker | Not per cell; existing exceptions retained |
| Ordinary prop damage / derived destruction | No generic surcharge for now | Relevant offensive sources only; special advantages separate |
| Optional residue / other board operations | Ground/board price sheet below | Never implied by Surge timing/damage |

- **Geometry:** retain placement/occupancy/fixed orientation; adjacent-anchor selection uses the [shared standard](#shared-valuation-standards); other unresolved targeting variants remain unpriced. Symmetric Strikes pay no direction fee when cells stay unchanged. A distant 1×1 Strike cell satisfies `max(abs(dx), abs(dy)) > 1`, not Manhattan Reach.
- Equal-size/equal-mechanics non-Strike shapes start equally priced; review special advantages such as chokepoints. No rotation, range upgrade or new placement permission.

### Shared Valuation Standards

**User-selected working standards, not validated balance or new mechanic permissions.** These standards use the [§2 evaluation bindings](#evaluation-contract--one-definition-one-calculation) and existing [§4 contracts](#4-effect-and-board-operation-contracts). Rates are comparison anchors, not measured value or prices reverse-engineered from a particular skill's budget. Arithmetic references follow the selected rates without content/development approval.

**Timing/avoidability:** retain the existing damage-timing rates in the component sheet. For an authorized one-shot displacement that is telegraphed, fixed to board cells and avoidable by leaving those cells before resolution, use **50% of its immediate displacement component**, independent of profile name. No tracking, repetition or enhanced blocking is covered. This is a shared condition-based rate, not a profile-specific exception; it authorizes no additional source to push or pull.

- All other components retain their own full rate unless a separately reviewed shared rate explicitly applies. No whole-skill multiplier, discount to AP efficiency/selection/marker, or discount inferred merely from a later application event.
- Value delayed permanent ground at its immediate package rate: it still creates the persistent state. No delay discount is applied to that package. Test whether this overvalues lost immediate board control; selection is not balance validation.
- Lifetime is already included in round-based formulas or permanent packages. Do not apply the one-shot timing factor to a whole zone, passive or future ground triggers. Undefined timing/avoidability remains incomplete, not assumed to qualify.

**Selection:** use the existing free-anchor rate as the full board-selection component. Any source-defined non-offensive unit utility needs its own resolved selection contract/rate; it inherits no retired direct-Shove fee. For an authorized selected board anchor restricted to cells adjacent to the caster, use **1 point per use**; this modest reduction values fewer placement options, not lower effect strength. Self/body/event binding with no independent target choice adds **0 selection points**; this does not waive separately priced direction or effect coverage. Fixed body footprints and trail placement are not automatically adjacent-anchor casts. Undefined LOS, homing or new ground/air coverage have no generic rate or assumed discount; they first require their owning contracts. Ally-only/enemy-only area filters are excluded by the [square-control contract](#2-data-oriented-skill-construction-kit), not missing purchasable components. Do not derive a new cast-range upgrade from selection prices.

Movement, passive and prop standards are maintained only in their owning sections below. Package replacements are alternatives, never extra fees on top of an unchanged package. Unrelated content drafts and the separate Mountain-price candidate remain unapproved.

### Strike Costs

**Damage per struck monster and shapes: [§8.1](#81-strike-by-kin).** Calibration drafts, not proof of equal strength; Spirit/Swarm/Ancient were designer-authored under the instruction to complete Strikes without individual approvals.

| Kin | Existing additional effect | Construction-point component |
|-----|----------------------------|------------------------------|
| Beast | None | 0 |
| Winged | One retreat of 1 cell after the Strike | +3 once per use, not per target |
| Scaled | Push 1, including existing push-direction selection | +2 per potentially affected hit cell |
| Spirit | Target Initiative −1 next round | +2 per potentially affected hit cell |
| Swarm | Props take 4 rather than ordinary Strike damage 2 | +2 per potentially affected hit cell; provisional pending prop redesign |
| Ancient | Mountain under the target is destroyed (Rubble unless a ground change is authored); the environmental 1 collapse damage is not Strike damage | +2 per potentially affected hit cell; provisional pending height/board resolution |

- **Kin packages:** bound, not interchangeable. Scaled includes push-direction choice, distinct from footprint direction; charge neither twice. Winged retreats once/use, not per target, without extra battle AP. Existing collision/fall/entry rules apply. Swarm grants no extra monster damage; Ancient no extra collapse/debris damage or arbitrary ground removal.
- **Unresolved:** Winged multi-target reference/ties/legal retreat, Scaled follows the payload resolution order; 2×2/layer pricing remains T02/T09. No blanket damage-plus-Kin surcharge; review specific combinations.
- **Body-relative variant cost drafts** *(draft, not validated or approved content)*: 1×1 Jab-shaped references at the existing 2 battle AP (6 AP-efficiency points); the AP of movement-only variants is not otherwise decided and uses the Jab AP here. Anchors are existing rates only, with no new rates: forced one-cell displacement 2 per potential recipient cell (direction included, [Zone, Protection and Healing Costs](#zone-protection-and-healing-costs)); self retreat 3 once per use (Winged package rate, unconditional, never discounted by hit chance); footprint-direction cost 2 where the direction changes hit cells; ground/air coverage 2 only per damage effect.

| Variant (Kin) | Calculation | Total |
|---|---|---:|
| Damage + push (Scaled) | damage 4 + direction 2 + ground/air 2 + push 2 + AP efficiency 6 | 16 |
| Push only, no damage (Scaled) | direction 2 + push 2 + AP efficiency 6 (no damage, so no ground/air coverage) | 10 |
| Damage + retreat (Winged) | damage 4 + direction 2 + ground/air 2 + retreat 3 + AP efficiency 6 | 17 |
| Retreat only, no damage, with hit cell (Winged) | direction 2 + retreat 3 + AP efficiency 6 | 11 |

- **Reading:** damage + push/retreat totals equal the existing Scaled/Winged Jab totals above because the rates are the same anchors; the new geometry adds no points. Movement-only variants are cheaper only because the absent damage is not paid for. All fit slot level 1 (24) numerically. This is arithmetic, not balance, and grants no unlock.
- **Multi-cell push drafts** *(draft)*: push is priced 2 per **adjacent** hit cell only, since only those cells can move a recipient; all other components follow the formula below (Beast values from the table). Damage + push totals: Jab 16, Pincer 19, Arc 25, Whirl 29, Cross 29, Storm 51 (equal to the Scaled column, as all hit cells are adjacent) and Thrust 19 (Scaled 21), Cleave 40 (46), Long Whirl/Long Cross 50 (58), because distant cells are not moved. Movement-only variants omit damage 4 per cell and the ground/air 2. Budget fit follows the existing Beast/Scaled budget findings and is not a recommendation.
- **Multi-cell retreat drafts** *(draft)*: retreat is 3 once per use, so damage + retreat equals the Winged column above for qualifying shapes: Jab 17, Thrust 20, Diagonal Thrust 20, Arc 22, cardinal Cleave 37. Pincer, Whirl, Cross, Storm and Long Whirl/Cross have no retreat variant (their existing Winged Strikes are unchanged). Retreat-only is priced only for the 1-cell Jab shape (11 above); damage-free multi-cell shapes are not priced.
- **Open:** diagonal Cleave and 2×2/layers need T09; hit multiplicity for retreat is decided as once per use. [temp_kalkscript.py](temp_kalkscript.py) does not support these variants.

- **Construction-point formula, 1×1 references:** `4 × hit cells + 2 × cells outside the adjacent eight-cell ring + effective footprint-direction cost + 2 ground/air coverage + AP-efficiency cost + Kin component`. Direction costs 2 only if cells change; ordinary prop interaction has no generic surcharge. Table values are **not damage** and decide no 2×2 hit multiplicity.

| Shape | Distant cells | Footprint-direction points | Beast points | Winged points | Scaled points | Spirit points | Swarm points | Ancient points |
|-------|---------------|----------------------------|--------------|---------------|---------------|---------------|--------------|----------------|
| Jab | 0 | 2 | 14 | 17 | 16 | 16 | 16 | 16 |
| Thrust | 1 | 2 | 17 | 20 | 21 | 21 | 21 | 21 |
| Diagonal Thrust | 1 | 2 | 17 | 20 | 21 | 21 | 21 | 21 |
| Pincer | 0 | 2 | 15 | 18 | 19 | 19 | 19 | 19 |
| Arc | 0 | 2 | 19 | 22 | 25 | 25 | 25 | 25 |
| Whirl | 0 | 0 | 21 | 24 | 29 | 29 | 29 | 29 |
| Cross | 0 | 0 | 21 | 24 | 29 | 29 | 29 | 29 |
| Storm | 0 | 0 | 35 | 38 | 51 | 51 | 51 | 51 |
| Cleave (cardinal reference) | 3 | 2 | 34 | 37 | 46 | 46 | 46 | 46 |
| Long Whirl | 4 | 0 | 42 | 45 | 58 | 58 | 58 | 58 |
| Long Cross | 4 | 0 | 42 | 45 | 58 | 58 | 58 | 58 |

- **Inputs:** hit cells and existing battle AP per shape are the Squares and AP columns of [§8.1](#81-strike-by-kin).
- **Geometry:** Arc uses the adjacent row/wedge; Cleave the illustrated cardinal two rows (three adjacent/three distant cells). Exact offsets for every selectable orientation remain T02/T06; no diagonal Cleave inferred. Symmetric forms pay no redundant direction selector.
- **Scope:** paper calculation, not legal-content catalogue, completed upgrade path or engine test.
- **Budget findings (24/30/36):** all Jabs fit level 1 numerically; per-cell-Kin Arc/Whirl/Cross need at least level 2. Only Beast Storm/cardinal Cleave fit 36; other variants and all Long Whirl/Long Cross exceed it.
- **Legacy reconciliation:** T02/T05/T06 after broader calibration; preserve neither content by automatic budget/AP changes, damage reductions, waived Kin costs nor over-budget approvals. Numeric fit grants no slot/progression access; every skill still needs a complete original-AP development path.

### Movement Costs

**Working drafts:** price whole traversal presets with distance/direction restrictions, not travelled cells or Movement (already stat-budgeted). Run's 6-point component is selected; other modes are designer calibration drafts under the instruction to price all modes. Existing 2 battle AP add 6 efficiency points.

| Preset | Profile points | AP-efficiency points | Total construction points | Note (restrictions: [§3 presets](#movement)) |
|--------|----------------|----------------------|---------------------------|-----------------------------------------|
| Run | 6 | 6 | 12 | Baseline walk |
| Leap | 8 | 6 | 14 | — |
| Glide | 8 | 6 | 14 | — |
| Burrow | 8 | 6 | 14 | — |
| Phase | 7 | 6 | 13 | — |
| Blink | 10 | 6 | 16 | — |
| Step (universal, no slot) | Not budgeted | Not applicable | Not applicable | Existing 2 AP, exactly 1 cell; no skill upgrades |

- **Package scope:** whole §3 presets, not additive flag prices/restriction exchange rates. Retain §8.2 Kin/stage access and the legal landing/occupancy/entry rules of the [§3 presets](#movement); self movement pays no ranged-anchor/ground-air-attack fee.
- **Status:** all existing slotted modes fit 24 numerically, without new access, completed upgrades, progression unlock or balance approval. Unmodified baseline walk uses the table total, combination 0, passive availability inapplicable.
- **Custom profiles/upgrades:** unused budget grants no free upgrade, base restrictions no second charge. Test low/high Movement including floor, barriers, hazards and exits; air/2×2 remain T09.

**User-selected working standards, unvalidated:** evaluate an authorized patched preset as its base mechanical package plus the applicable increment below; add AP efficiency once. Preserve §6's one-patch limit. These are sensitivity-test anchors, not equal-value claims for every blocker or permission to change path mode, landing, air access or unsupported flags.

| Existing patch dimension | Mechanical increment | Valuation boundary |
|---|---:|---|
| Lower an existing negative distance penalty by 1 | +2 once per movement use | Price the authored capability, not actual travelled cells; no extra Movement-stat charge |
| Turn off one authorized blocking restriction | +2 once per movement use | Existing path and legal landing unchanged; different blocker types require separate comparative tests |
| Turn off the existing extra ground-cost restriction, where authorized | +2 once per movement use | Does not grant immunity to entry effects; includes only that restriction change |
| Other flags/path changes or combinations | No standard rate | Require a resolved contract and valuation, not extrapolation from the increments above |

If the resolved variant exactly matches an already priced preset, use that preset's package instead of charging both the package and a patch increment. A different route to the same resolved mechanics must not produce two prices. Other variants are new package drafts; these increments do not establish a universal additive flag economy.

### Self-Buff and Passive Costs

**Designer calibration drafts** for self-buff/passive [coverage references](#non-area-and-passive-coverage-references), not approval of content, legacy passives (§9), new stat effects or unresolved stacking/triggers.

| Component / reference | Mechanical points | AP-efficiency / availability points | Combination points | Total points |
|-----------------------|-------------------|-------------------------------------|--------------------|--------------|
| Self Initiative +1, 2 rounds, proposed 1 AP | 4 × 1 magnitude × 2 rounds = 8 | 12 AP efficiency | 0 | 20 |
| Owner may rotate its eligible fixed tetris shapes while equipped | 6 for rotation permission | 12 passive availability | 0 | 18 |

- **Self Initiative:** 4 points per +1/round, no artificial area/anchor/ground-air-attack fee.
  - Assumes draft refresh without magnitude stacking; normal AP-paid refresh adds no blanket surcharge.
  - Not a rate for arbitrary stats, targeted/team buffs or cumulative Initiative.
  - Round-end duration/normal round queue recalculation apply; stacking and expiry follow Battle §3.1; removal/death/exact termination of the Focus record remain open.
  - Same draft rate can cost longer duration, not approve upgrades.
- **Passive availability:** initial 12-point premium for continuously equipped, self-scoped boolean permission (owner rotation), replacing active efficiency; mechanics priced separately. Neither 0-AP active nor extra budget. Conditions grant no automatic discount; event-driven/repeating/proccing/team-wide/other patterns need frequency/recursion/combination review before pricing/approval.
- **Rotation:** covers all owner's legal eligible-shape rotations while equipped, not each cast; identical boolean permissions do not stack. No mirroring, Strike geometry changes, cells, range or new profiles. Test equipped shapes, symmetry, action frequency, fixed-shape kits and placement options; equal value across kits is not guaranteed.
- **Validation:** both fit 24 numerically, not unlocks/full paths. Test self Initiative against tempo/queue changes and paid refresh. Other passive mechanics/combined statuses need explicit follow-through, not unused-point-funded free additions.

**User-selected working standard, unvalidated:** extend the existing passive-availability rate, without adding another numeric price, to a conditional self-scoped boolean permission only when its lifetime, reevaluation, stacking and removal contracts are resolved. Use the same availability rate as continuous self permission, with **no condition discount**; the hypothesis is a conservative upper bound because some conditions may be maintained deliberately. Mechanical permission cost remains separate. This does not price arbitrary stat passives or make the rotation rate a universal rule-modifier price. Event-driven combinations use the [availability table](#availability-by-activation-and-usage) only where a selected rate and resolved contracts exist; repeatable event-driven and team-wide availability remain unpriced. Do not multiply an invented expected trigger count by an active-skill price.

### Availability by Activation and Usage

**User-selected approach and working values, not validated balance or new effect permissions.** Derive availability from the existing `usage_type`, `execution` and `usage` fields together, not from a new skill class. Event activation never implies a round cap: the skill's authored repetition policy supplies it explicitly.

| Resolved activation / availability | Authored repetition policy | Availability component |
|------------------------------------|----------------------------|------------------------|
| AP-paid player action | Repeatable | [AP-efficiency scale](#ap-efficiency-working-scale) |
| AP-paid player action | Once per global round | [Active round-limit calibration](#round-limited-availability-calibration), including its effective-restriction guard |
| Continuous/conditional self-scoped boolean permission | Not a repeated activation | Existing [passive availability](#self-buff-and-passive-costs); no inferred activation limit |
| Defined event, no Battle-AP payment, resolved non-team-wide availability | Explicitly once per global round | **12 points per equipped instance** |
| Defined event, no Battle-AP payment | Repeatable | No general rate selected; not zero cost |
| Undefined event/recipient contract or other availability pattern | Any | Incomplete until its contract and rate are resolved |

For the selected event/once-per-round combination, add the independently priced maximum authorized effect package of one activation. Its availability component replaces active AP efficiency; it is not a zero-AP active action. Read trigger, recipients, limits and lifetime from the shared definition, not a second passive schema.

- **Rationale:** the round cap gives a known activation bound, but the activation spends no Battle-AP and may preserve the owner's turn for other actions. The initial availability anchor matches continuous self-permission availability; that is a comparison hypothesis, not evidence of equal strength. The selected active round-limit factor does not apply: it discounts an AP-paid availability component, not every round-limited skill.
- **No probability credit:** assume the authored trigger can occur each round when evaluating availability. No discount for being called reactive, situational or unlikely, and no live hit/destruction counters in the internal price. Where one activation has mutually exclusive outcomes, use the conditional-outcome draft; sum coexisting effects without a combination surcharge. The numeric price remains incomplete if any legal outcome lacks a contract or rate.
- **Effect scope:** the round limit caps activations, not recipients, footprint or the lifetime of effects created by that activation. Include the full authored scope in its mechanical price. Do not multiply a one-activation package by invented battle length, discount persistent effects as one-shot outcomes or reuse a source-bound effect rate without its matching contract. Existing damage/healing/movement permissions remain unchanged.
- **Instances and safety:** duplicate equipped copies are evaluated independently and keep their independent round allowances. This grants no automatic stacking of persistent states; stacking, recipient bounds, order, recursive interactions and owner removal must be resolved before admitting content. The selected availability charge alone does not certify a combination as safe.
- **Excluded:** repeatable event-driven effects, undefined event/recipient scope, team-wide availability and continuous modifiers do not inherit this rate. Missing contracts remain blockers rather than zero-cost assumptions. No existing skill is assigned this policy or repriced here.

**Arithmetic-only checks:** hypothetical, already-complete mechanical subtotals of 3, 6 and 12 would yield totals of 15, 18 and 24 respectively under the selected event/once-per-round rate. They define no actual skill, legal effect, trigger, unlock or balanced content. Compare AP-paid and reactive packages through later tests; numeric fit is not approval.

### Zone, Protection and Healing Costs

**Designer test prices for §4 contracts, not new effect permissions.** C = potential cells, R = authored rounds, V = authored base magnitude. Add AP efficiency once/skill and applicable selection costs to these mechanical components; combination surcharge 0. Effects share one zone clock, not independently purchased timers.

| Existing effect | Mechanical construction points | Calibration scope |
|-----------------|--------------------------------|-------------------|
| slow / haste | 1.5 × V × C × R | Slow reference unchanged; opposite sign gets same initial rate |
| drain_init / quicken | 2 × V × C × R | While inside; no immediate queue rewrite |
| drain_range / extend | 2 × V × C × R | Effective Reach only, not a cast-range upgrade |
| Zone push / pull | 2 × C × R | Existing one-square end-turn trigger; direction/fixed pull anchor included |
| Immediate one-time displacement under an authorized spatial source | 2 per potential recipient cell | Existing cardinal one-square component; direction/pull anchor included. New coupled eight-direction variants require separate calibration; no direct-unit Shove source is authorized |
| Telegraphed, fixed-footprint, avoidable one-shot displacement | 50% of the immediate component above | [Shared timing conditions](#shared-valuation-standards); direction included, no second timing multiplier or new source permission |
| Zone shield | 1 × V × C × R | Existing base 2, cap 3; Surge reduction, not shield HP |
| Zone mend | 3 × V × C × R | Existing heal 1 reference; magnitude now `min(2, level)`, price for the scaling and repeat balance pending T07 |
| expose | Not priced / reserved | No approved zone; no damage-boost permission |

- **Displacement timing:** only the shared standard's qualifying one-shot displacement gets the reduction. Existing immediate spatial, Scaled Strike and zone effects retain their own rates/contracts and distances; delay alone is insufficient.
- Not applicable to repeated/tracking/unavoidable/enhanced displacement. Test the entry-hazard combination; budget fit does not validate the reduced rate.

- **Selection:** ranged zones pay +2 board anchor once, no second direction/anchor-binding charge. Body-relative Shove is not a ranged unit-selection source; calibrate its spatial components through the new variant contract rather than retaining a direct-target selection fee.
- **Repetition/values:** normal AP-paid zone levelling/refresh included, extending Slow policy for calibration only. Resolve magnitude/cap/level formulas; no stronger values, heal scaling, extra triggers or ally-only filters. Test each effect's repetition independently.
- **Healing/protection:** retain max HP, events/source permissions; no direct heal, revival, Injury cure, general immunity, tamer protection or item permission. Stacking and order: [Battle §3.1](gdd_battle.md#31-effective-stats)/[§6.2](gdd_battle.md#62-surge-resolution-integration) (decided); `mend` scales `min(2, level)` and Mossbed has no loop limit (T07, decided); prices for the changed `mend` magnitude are still open. Prices set neither caps nor unbounded-healing permission.

### Ground and Board Costs

**Permanent-state packages:** fixed price per created cell, not invented duration/future-trigger counts. Includes existing occupant effects, ordinary placement/replacement and persistence; no duplicate instant-damage/heal/zone-modifier charge for future effects. Entry/start/end events stay unchanged. Level-I hazards include normal AP-paid recasts to existing II, not stronger damage/level-II-start upgrades.

| Existing state / operation | Mechanical construction points | Included / unresolved scope |
|----------------------------|--------------------------------|-----------------------------|
| Lava I / Thornbed I / Blight I, immediate cast or delayed aftermath | 4 × C | Permanent hazard package; no delay discount; trigger risks and loss of immediate control to test |
| Hearth / Umbra | 4 × C | Existing +1 Initiative / Reach while occupied, both sides |
| Mossbed | 6 × C | Existing heal 1 on every entry (no re-entry limit, user decision 2026-11-10); price provisional |
| Hallowed | 4 × C | Existing Surge reduction 1; no automatic hit consumption |
| Mountain creation with coupled Plain reset | 5 × C | Mountain plus its existing non-Voidscar → Plain cleanse, one package |
| Mountain-destruction operation (final ground: [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed)) | 2 × C | Source-specific; the operation is priced because it grants the capability; the environmental 1 collapse damage is not priced as skill damage; the price is the earlier draft, not re-derived |
| Create prop (any [catalogue](gdd_battle.md#410-prop-catalogue-and-damage) entry) | Not priced (T02) | The earlier Wall/Tree 4, Rock 6 and Shrine 8 packages belonged to the removed catalogue. Open: one price per prop class and the valuation of `on_destroy` operations, aura effects and Beam spawning; a missing price never means zero |
| Relocate eligible prop (one square, orthogonal; contract in §4) | 6 per moved prop | Provisional component; contract confirmed, price not recalibrated |
| Direct Rubble creation, direct prop deletion | Not priced / not authorized by this table | Need explicit source/contract |
| Voidscar alteration | Forbidden | No budget bypass |

- **Props:** prices grant no catalogue/access; retain empty-cell, `heavy` and interaction restrictions. Ordinary destruction has no generic surcharge; a prop's aftermath is part of its type, not a second authored operation, and never destroys Mountains.

**User-selected working standard, unvalidated:** for an existing authorized extra on-hit prop-damage effect, use **1 construction point per additional prop HP damage per potential affected cell**, above the source's included ordinary prop damage. This is a narrower damage channel than monster damage and preserves the current extra-prop-damage component's valuation scale; it is not a monster-damage discount. Do not also charge that same extra damage through a Kin package or generic damage component. Exact prop eligibility, interception and mutually exclusive outcomes still bind the calculation. No automatic timing discount applies.

No source currently has a prop reaction or extra prop damage, so this standard has no user. A future reaction that replaces ordinary damage is evaluated as complete legal outcomes under the conditional-outcome draft, not damage plus an invented surcharge. Missing special-reaction valuation keeps the affected package incomplete.

- **Cast fees/residue:** standalone ground/props add the applicable +2 anchor fee and AP-efficiency cost once. Residue means authored Surge **ground change, not prop creation**; [Surge profiles](#surge) own payloads/exceptions. Delayed hazard aftermath (rate in the table above) adds no second anchor/AP and gets no further 50% damage discount; immediate ground keeps its own rate. Source-specific height/prop exclusions remain binding.

**Conditional-outcome costing — designer working draft:**
- Price the most expensive explicitly mutually exclusive legal outcome; sum coexisting components within it. Maximize over legal board states for the authored skill, not the cast-time board; no probability weights/best-case discounts.
- Sum per-cell maxima only if those outcomes can coexist across the footprint; count shared activation/anchor/marker once. Missing prices/unresolved order block a complete maximum, not zero-cost branches.
- Valuation grants neither runtime exclusivity nor new effects. Collapse and residue on one cell end in a single ground (Battle §4.7); the operation is priced as a capability, so both are charged (additive; a maximum is not adopted).

### Combination Policy and Basic Surge Target

- **No combination surcharges**, including former damage-plus-hazard/displacement-plus-hazard rates: sum mechanics + AP efficiency/passive availability; retained combination fields = 0. Additional effects still cost points; legal combinations still need validation.

- **Target:** useful basic Surges with intended ground aftermath at **1 battle AP**. Concrete [profiles](#surge) include explicit `board_changes`; prop creation is separate, never a default. The generic residue-free reference remains, not a replacement.
- **Working status:** permanent aftermath uses the shared ground-package rate without a delay discount; scoped subtotals below. Existing 1-AP costs stay; budget conflicts remain unresolved, not grounds for an automatic price/AP change or content restriction.
- Resolve conflicts by calibration, not automatic 2-AP basic Surges. Review avoidability under enhanced blocking/guaranteed hits; test internal/team synergies.

### Basic Surge Profile Cross-check

**Paper calculation at existing 1 battle AP using current working rates; not content/balance approval.** Recalculated solely to keep these references consistent with the [shared standards](#shared-valuation-standards), not to resume skill-specific calibration before the foundation is complete.
- Hypothetical fixed 2/3-cell footprints, not approved new shapes; potential ground recipients, no air permission. Every row includes anchor 2, normal marker 1, AP efficiency 12 and the authored level-I hazard package.
- No combination surcharge or second anchor/AP. Damage uses existing avoidable-Surge pricing; qualifying displacement uses the shared timing rate. Permanent aftermath gets no timing discount.

| Existing profile | Costed components on Low, prop-free cells | 2-cell subtotal | 3-cell subtotal | Remaining profile evaluation |
|---|---|---|---|---|
| Eruption | `15 + 3 × cells` damage + `4 × cells` Lava aftermath | 29 | 36 | No profile-specific prop exception (§3) |
| Flood | `15 + 2 × cells` damage + `4 × cells` Thornbed aftermath + `1 × cells` one-square push | 29 | 36 | Qualifying push uses shared timing conditions; damage/push/residue order follows Battle §6.2 (decided) |
| Rift | `15 + 3 × cells` damage + `4 × cells` Blight aftermath | 29 | 36 | Collapse is excluded from these Low, prop-free subtotals (§3) |

**Scoped subtotals, not complete profile prices:** ordinary offensive prop damage/destruction has no generic surcharge. Legal combined outcomes/order still prevent complete pricing.

- **Collapse/hazard:** include the explicit destruction capability additively with residue under the [Mountain-destruction rule](gdd_battle.md#47-ground--neutral-hazard-and-blessed). The priced subset is `15 + (3 + 2 + 4) × cells`: **33/42** for two/three cells. Environmental collapse damage is not separately priced as skill damage; ground exclusivity does not waive the destruction capability.
- No-residue-on-Mountain/Mountain-exclusion rules grant no automatic credits.
- **Budget finding:** all three Low, prop-free two-cell subsets exceed 24; three cells reach 36 before additional capabilities/reactions. Height-capable Rift exceeds 24 in both shown cases and 36 for three cells. These are unresolved calibration conflicts, not automatic higher-level unlocks, content restrictions or approvals.
- Preserve damage, 1-AP baselines, mechanics and shared ceilings; special-reaction valuation remains a T02/T07 blocker.

### Mountain-Destruction Calibration Proposal

**Separate unapproved sensitivity candidate, not selected by approval of the shared standards.** The current destruction rate remains in the price sheet. These comparisons use current permanent-ground pricing; no skill-specific budget repair is proposed.

- **Constraint:** the two-cell Rift subset costs `15 + 2 × (3 + 4 + destruction rate)`. Even zero destruction cost gives 29, above 24. Lowering this component alone cannot resolve the base-budget conflict.
- **Candidate:** test **0.5 point per potentially affected cell** for the explicit Mountain-destruction capability wherever it is authored, including Ancient Strike. Environmental collapse damage remains a consequence of the board operation, not a second skill-damage charge. This is a valuation hypothesis, not evidence that the capability is weak: removing height, changing ground and causing collapse can be tactically valuable.

| Priced subset / component | Existing draft | Candidate | Interpretation |
|---|---:|---:|---|
| Rift, two cells, including collapse and Blight | 33 | 30 | Still exceeds the level-1 ceiling before special prop reactions |
| Rift, three cells, including collapse and Blight | 42 | 37.5 | Still exceeds the level-3 working ceiling; no content approval |
| Ancient Strike, destruction component per potential hit cell | 2 | 0.5 | Apply the shared component consistently; other Strike charges stay unchanged |
| Eruption / Flood, two-cell Low subsets | 29 / 29 | 29 / 29 | No destruction component; complete special-reaction pricing remains unresolved |

- **Recommendation:** retain this as a paper-test candidate, not a replacement price. It changes one shared capability rather than globally lowering AP availability or damage prices. Its large reduction and Ancient's collateral repricing require explicit review; the 0.5 rate is derived only from the desired budget fit and has no independent balance justification.
- **Limit:** this candidate no longer yields a base-budget fit under current ground pricing; full profile pricing also remains unresolved. Compare the three-cell result of 37.5 without rounding. Do not remove reactions, restrict content, infer slot access or alter prices further merely to fit.
- **Before adoption:** decide special-reaction valuation (T02), then compare the capability's actual impact on height-heavy and height-free boards, including Ancient Strike and combined ground effects (T04/T07/T13). No gameplay or balance tests have been performed for this proposal.

### Calibration Examples

| Reference | Construction-point calculation | Provisional subtotal |
|-----------|--------------------------------|----------------------|
| Beast Strike: 1 cell, 2 damage, 2 AP | damage 4 + direction 2 + ground/air 2 + AP efficiency 6 | 14 |
| Slow zone: 3 cells, 2 rounds, 1 AP | slow 9 + anchor 2 + AP efficiency 12 | 23 |
| Same slow zone: 3 rounds | slow 13.5 + anchor 2 + AP efficiency 12 | 27.5 |
| Residue-free Surge: 3 cells, 3 damage, 1 AP | damage 18 × 50% + anchor 2 + marker 1 + AP efficiency 12 | 24 |
| Zone quicken 1: 3 cells, 2 rounds, existing 1 AP | effect 12 + anchor 2 + AP efficiency 12 | 26 |
| Zone shield base 2: 3 cells, 2 rounds, existing 1 AP | protection 12 + anchor 2 + AP efficiency 12 | 26 |
| Mend 1 zone: 3 cells, 2 rounds, existing 1 AP | healing 18 + anchor 2 + AP efficiency 12 | 32 |
| Immediate hazard ground: 3 cells, existing 1 AP | hazard package 12 + anchor 2 + AP efficiency 12 | 26 |
| Hallowed ground cast: 3 cells, existing 2 AP | ground package 12 + anchor 2 + AP efficiency 6 | 20 |
| Mountain creation/Plain reset: 3 cells, existing 1 AP | height/cleanse package 15 + anchor 2 + AP efficiency 12 | 29 |

- **Status:** paper calculations, not complete validation, approved content/paths or engine tests. Above 24/30/36 means calibration conflict, not automatic unlock/AP change/budget exception. Decimal totals use the unrounded budget comparison defined above.
- Hazard-Surge subtotals belong to the cross-check above; special reactions/profile interactions need review. Movement/self Initiative/passive rotation calculations stay in their respective tables.

### Included Behaviour and Validation Limits

- **Slow:** base 1/cap 2, Movement minimum 1, Step unaffected. Includes normal AP-paid recasts/levelling/duration refresh, not level-II starts, free recasts or enhanced repetition. No pricing of other stats; rounds do not guarantee personal turns. Test repetition.
- **Marker:** existing temporary voluntary-movement blocking only, not enhanced blocking/duration; retain movement/displacement exceptions. Test chokepoints, props/height and prevented escape against the 50% damage rate: price does not guarantee avoidability.
- **Combinations:** [no surcharge](#combination-policy-and-basic-surge-target) within/between skills/monsters. Validate full interactions; revise responsible components/rules on evidence. Guaranteed hits do not automatically qualify for avoidable-damage discounts.
- **Props:** ordinary interaction is baseline for relevant offensive sources only, not movement/support damage or universal destruction. Evaluate special damage, resistance bypass and enhanced reactions against the redesigned catalogue (Battle §4.10), without blocking unrelated calibration.
- **Permissions:** prices override no access/profile/damage/targeting/layer limits. Missing spatial/event/stacking contracts block affected content (T02/T04–T06/T09/T13).

### Round-Limited Availability Calibration

**User-selected authoring-time working standard, not validated balance or a new skill assignment.** Read the authored [repetition policy](#usage-and-repetition) from the same definition. For an active skill with an effective once-per-global-round restriction, use **75% of its AP-efficiency component**, leaving all mechanical, selection and marker components unchanged. Repeatable skills retain the full availability rate. The percentage is a conservative test anchor, not a measured frequency ratio or a discount on the entire skill.

- **Effective restriction:** compare the authored policy with the same definition without that round cap across its legal users, including extra-turn users. If independent AP/profile limits already prevent more than one activation per round for every legal user, apply **no reduction**. If that comparison is unresolved, availability valuation is incomplete. This is a pre-release capability check, never a live cast count or per-individual price.
- **Rationale/limits:** an active skill still spends AP for its one use and retains full single-use impact. The cap removes repeat opportunities, not damage, duration or footprint. AP already limits repetition, so no inverse-trigger-count multiplier or negative credit is introduced. Skills whose existing availability component is zero gain no budget credit from this rule.
- **Other sources:** do not apply this factor to continuous boolean passives, event-driven availability without its own rate/contract, existing once-per-battle limits or an additional restriction that adds no independent limitation. Overlapping limits are not multiplied into extra rebates.
- **Status:** selecting this rule does not assign a new policy to existing skills; their current totals remain unchanged. Test whether this anchor distinguishes repeatable and limited skills without funding overpowered single uses; independent duplicate-instance use and activation consumption follow §2; recursion and balance remain unresolved. Missing event-passive frequency contracts remain incomplete, not free.

### AP-Efficiency Working Scale

**Selected for calibration, not validated balance.** These construction-point costs are added to the other evaluated mechanics of an active skill; they are not separate AP-class budgets.

| Battle AP per use | AP-efficiency cost in construction points |
|-------------------|------------------------------------------|
| 1 | 12 |
| 2 | 6 |
| 3 | 3 |
| 4 | 1 |
| 5 | 0 |

- **Limits:** higher battle AP grants no negative credits. This scale neither authorizes zero-AP actions/AP-reducing upgrades, changes existing AP costs, prices passive availability nor approves damage/area/timing drafts. Check complete skills, legal repetition and available AP/turn.
- **Existing prices below are calibration references, not a parallel final formula.** Retain until replacements are explicitly agreed; no silent repricing. Check §8.1's existing Strike shape prices against the new calculation.

| Authored action/profile | Existing battle AP cost / limit |
|-------------------------|---------------------------------|
| Step (no slot) | 2 AP |
| Slotted movement | 2 AP |
| Zone / ordinary ground / prop / direct | 1 AP |
| Minor Surge | 1 AP baseline per cast; repetition follows the equipped instance's usage policy |
| Strike | 2–5 AP by the selected authored shape (§8.1) |
| Blessing ground | 2 AP; not the ordinary-ground default |
| Major Surge | 2 AP; once per battle; access under §1 / [Monsters §5.3](gdd_monsters.md#53-monster-progression-the-18-steps) |

- **Baseline scope:** existing prices, not new values/final costs for every combination. Species-specific skills retain applicable profile costs pending calibration; “Unique = 1 AP, may set its own” grants neither a category nor unrestricted override. Explicitly validate retained exceptions (T02); optional higher-cost upgrades follow §6, not unconfirmed blanket Twist/Size surcharges.
- Tamer/planned medicine/array source-loadout contracts remain gdd_overworld §6.4–§6.6/[gdd_battle §5.2](gdd_battle.md#52-tamer-skills-and-battle-loadout); monster-action prices assign none of their costs.

**Preserved authoring constraints:**

- A zone's existing duration default is 2 rounds, but every resolved definition must state/reference its lifetime; the Slowing Zone record in [gdd_skills.md](gdd_skills.md) remains an unvalidated combination.
- Temporary species-specific effects must state N rounds or an explicit consumption/end-of-battle condition; the former flat `rounds` field is not a separate schema.
- A Surge needs at least three live counters to pass design validation (leaving, protection, height, air, props or tempo as applicable); a nominal counter that its actual profile prevents does not count.
- **Size:** 1–4 cells for ordinary skills with a tetris shape, 2 for Swarm Surges ([Monsters §3.1](gdd_monsters.md#31-kin-table)). Strikes have their own list (§8.1); Major Surge requires its explicitly authored large-area profile and access, not a generic cap override.

## 6. Slot Levels, Development, Replacement and Upgrades

**Confirmed: permanent slot development**, gained only at **advancement steps** ([Monsters §5.3](gdd_monsters.md#53-monster-progression-the-18-steps)): a stage breakthrough (or the listed later sub-tier steps) offers the individual monster the option to develop one skill slot. There is no separate experience/EP currency, no spending outside an advancement and no physical evolution. No separate player skill-point currency; construction/blueprint points are internal authoring data, neither intermediate spendable budget nor Overworld Blueprint items.
- **Ownership/choice:** a development step develops one slot on one monster, not its equipped skill or species globally.
  - Each development step directly grants a skill-specific upgrade choice.
  - Designers use §2–§7 for finished skills/upgrades, internal budgeting/AP pricing; players select authored options, not arbitrary components.
  - Equipped skills define legal upgrades/prerequisites/exclusions; slot progress determines available development, not simultaneous access to all upgrades.
- **Replacement:** outside expeditions, unlocked species learnable-list skill, valuable **relearning pill**. Preserve all purchased slot progress; select legal replacement upgrades using it without spending another development step, not literal transfer of old effects. Pill acquisition/recipe/tier/price/overworld AP remain T05/T16/T31.
- **Levels 1–3:** increasing construction ceilings (§5), no separate skill ratings/ranks. How steps map to levels, unlocks, intermediate steps, total supply (including Normal's two steps) and whether an unused step can be deferred remain undecided (T05).
- **Open:** pill use for same-skill upgrade reselection; passive-only slot development and active/passive replacement rules are required before implementation.

**Confirmed construction budget and AP policy**

**Superseded prices and legacy reconciliation:**

- The former per-skill prices (1 EP for Shape/Twist/Value/Swap, 2 EP for Size) are superseded; no EP currency exists.
- Legacy “Shape always free”, blanket “Twist = 2 AP”, “Size adds 1 AP”, Twist-plus-Size totals and double-charging an already enlarged footprint remain T02/T05 reconciliation work; none overrides the confirmed policy below.

- **Budget:** ceilings and AP efficiency: [§5](#5-construction-points-and-ap-efficiency); balance remains open (temp_todo T02/T05).
- **AP policy:** bounded improvements and a complete path at original AP for every skill. Larger extensions may optionally cost more AP, shown before selection, never mandatory for slot development.
- **Patches:** authorized fields on the same definition (§7), not a parallel model; area, shape/orientation, duration, movement/displacement or explicitly designed secondary effects, within skill limits/prerequisites.
- **Limits:** no direct-damage, AP-reduction or cast-range upgrades; existing Strike/Surge/ground damage caps hold. More cells/duration may increase total impact and still require budgeting/validation. Budget guidelines bypass no hard caps/legal combinations; reconcile legacy blanket AP surcharges, never apply automatically.

**Candidate catalogue, not final step prices/unlocks.** Cast range is excluded; slot development supersedes old per-skill evolution counts and prices. Review concrete offers/AP effects under temp_todo T02/T05.

|           Family           |                                       What changes                                      |                                                                                         Rules                                                                                         |
|----------------------------|-----------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Shape** | Other shape family or orientation, **same cell count** | I2 orientation, I3↔L3 or legal 4-cell families; Strike swaps same-size shapes from §8.1. Family must respect Kin and twist constraints; shapes remain fixed in battle. Legacy ‘always free’ grants no free development step or respec; costs remain T05. |
| **Size** | **+1 cell** within the owning profile's cap; Strike selects a larger §8.1 shape | Ordinary tetris max 4; Swarm Surge cannot enlarge. A larger Strike uses its existing shape AP price as an optional higher-cost branch, never the only development path. The old automatic Surge +1 AP is unconfirmed; requirements, step costs and optional AP effects remain T02/T05. |
| **Twist** *(Surge only)* | Replace/add an authored extra rule; not on a Species Surge | At most one; preserve §3 constraints and exclude damage/range increases, including legacy delayed-damage or extended-range candidates. Validate under the confirmed AP policy. |
| **Small value** | Zones: `duration` +1 round total per skill. Movement: one flag flip total, turning off one restriction or lowering its distance penalty by 1 (§3) | Bounded candidate patches, not free upgrades. No damage increase or level-II start; the level-II-start passive remains a separate candidate (§9), not an approval through this table. A **residue level-II start** is a separate upgrade candidate *(user decision 2026-11-11)*: it needs its own price (T02) and board-fill tests (T13) before it becomes a patch, and until then residue starts at level I. |

- **Shared process:** authorize patches to [§2](#2-data-oriented-skill-construction-kit), validate through [§7](#7-validation-and-concrete-skill-records), including species-specific/Signature (§1); no per-kind schema. Replacement is never a patch and follows this section's opening rules. Legacy named examples/evolution counts are retired pending T02/T05/T10.
- **Identity:** different slot-development choices within one species yield different playstyles without new art. Shaped skills retain **one shape/fixed orientation**, except existing rotation permissions; Surges have **at most one, not mandatory, twist**. Non-area skills gain no footprint. Battle rules remain valid; preview the resolved variant normally.
- **Granting/logistics:** development steps are granted by advancements ([Monsters §5.3](gdd_monsters.md#53-monster-progression-the-18-steps)), not bought and not a focused-XP Train reward. Where and when the choice is made, and day AP: [Overworld §6.3.2](gdd_overworld.md#632-permanent-skill-slot-development-confirmed). Step supply ([Monsters §5.1](gdd_monsters.md#51-monster-rarity)/[Monsters §5.3](gdd_monsters.md#53-monster-progression-the-18-steps)) remains unvalidated; reversal/transfer/same-skill reselection remain [temp_todo.md](temp_todo.md) T05, not free resets.
- **Validation:** enforce candidate limits, owning [Surge constraints](#surge-constraints-and-species-access), Kin access ([Monsters §3](gdd_monsters.md#3-kins)) and [§7](#7-validation-and-concrete-skill-records). The development UI offers only passing paths. Unsupported 2×2/spatial cases stay T09; slot development grants no exceptions/air access.

## 7. Validation and Concrete Skill Records

- **Author:** legal profile → §2 dimensions resolved through definitions → access/interactions/budget. Use this section's single schema; footprints/effect definitions are data references, not fundamental skill blueprints.
- **Validate complete records, not components:** selection → placement → footprint → recipients; execution → effect events/order → lifetime; then Kin/species access, usage limits/cost. Preview cells, recipients, displacement landings and board reactions; missing rules block content.
- **Content status:** former named example table retired; §10 roster names are unvalidated ideas, not definitions/permissions. Concrete records: [gdd_skills.md](gdd_skills.md); rebuild/extend only after central [temp_todo.md](temp_todo.md) decisions, especially T02/T04/T05/T07/T09/T10.

- **Concrete records:** all concrete skill records are in [§11](#11-concrete-skill-records); this chapter holds only the validation rules.

## 8. Kin Strikes and Movement

Kin identity itself (body fantasy, layer, stat lean, Surge access, lock-outs) stays in [Monsters §3.1](gdd_monsters.md#31-kin-table); the concrete Strike and movement tables follow here.

### 8.1 Strike by Kin

Every Strike is a **shape around the body** plus a **Kin twist** (rule: [§3](#3-skill-execution-profiles)). The species picks the shape, the Kin gives the twist.

**Strike shapes** (second version).
- A bigger shape costs more AP and is simply better; it never deals less damage.
- The player picks the direction when striking (8 directions, no facing). "Forward" means along that direction; a line is stopped by the first solid prop in it.

| Squares | AP |                          Shape                          |                  Name                  |
|---------|----|---------------------------------------------------------|----------------------------------------|
|       1 |  2 | next to `M`, any of the 8 directions                    | **Jab**                                |
|       2 |  3 | 2 forward in a straight line (4 directions)             | **Thrust**                             |
|       2 |  3 | 2 forward on a diagonal (4 diagonals)                   | **Diagonal Thrust**                    |
|       2 |  3 | next to `M` in the chosen direction **and** the opposite side | **Pincer**                       |
|       3 |  3 | the 3 squares in front of `M` (a row, or on a diagonal the wedge `(dx,0)`, `(dx,dy)`, `(0,dy)` for direction `(dx,dy)`) | **Arc**                        |
|       4 |  3 | the 4 neighbours of `M`                                 | **Whirl**                              |
|       4 |  3 | the 4 diagonals of `M`                                  | **Cross**                              |
|       8 |  4 | all 8 squares around `M`                                | **Storm**                              |
|       6 |  5 | the 3 squares in front of `M` and the 3 behind those    | **Cleave**                             |
|       8 |  5 | 2 forward in each of the 4 directions                   | **Long Whirl**                         |
|       8 |  5 | 2 forward in each of the 4 diagonals                    | **Long Cross**                         |

```
  x       x          x           x      x x x
  M       x        x             M        M
          M      M               x
Jab     Thrust   Diag Thrust   Pincer   Arc

  x     x   x   x x x
x M x     M     x M x
  x     x   x   x x x
Whirl   Cross   Storm

             x        x       x
             x          x   x
x x x    x x M x x        M
x x x        x          x   x
  M          x        x       x
Cleave   Long Whirl   Long Cross
```
`M` is the monster, `x` a hit square. Straight shapes are drawn for "up", diagonal ones for "up-right"; the player turns them to any of the 8 directions.

**Self-retreat cell for the body-relative variants** *(draft illustration of the rule in [§3](#body-relative-damage-and-movement-variants))*: `R` is the single cell the attacker moves to, opposite the centre of the hit shape. Only shapes whose centre lies on one of the eight directions have it; the cell is checked and entered as defined in §3.

```
       x               x                                   x x x
x      x             x          x x x      x x             x x x
M      M           M              M        M x               M
R      R         R                R      R                   R

Jab    Thrust    Diag Thrust    Arc      Arc (diagonal)    Cleave
```

- **No retreat cell:** Pincer, Whirl, Cross, Storm, Long Whirl and Long Cross (centre is the attacker itself); a diagonal Cleave is not defined (T09).
- The existing Winged Strike (Dive, below) keeps its own package and is not replaced by these illustrations.

- **AP decides when:** AP 2 is the ceiling until Core, so Qi and Foundation Strikes are all Jabs and differ by Kin twist only. AP 3 opens at Core, AP 4 at Immortal and AP 5 at Sovereign, the last two only with TPR 1 ([Monsters §2.3](gdd_monsters.md#23-stat-ceilings-per-stage))
- **Every shape hits allies too.** The bigger the shape, the more of them stand in it. A 2×2 monster starts the shape at a chosen covered square ([2×2 bodies](#body-relative-damage-and-movement-variants))
- The shape is part of the species and changes through slot-development upgrades (Shape and Size, §6)

**Kin twists:** every Strike deals **2 damage per struck monster**, plus its bound Kin effect. Under confirmed policy, Kin advantages consume the shared construction budget (§5); Beast has none to price.
- §5 prices all Kins/existing shapes as unvalidated calibration drafts; full combination evaluation is pending. Existing effects and battle-AP prices remain unchanged.
- Table values are gameplay effects, **not construction points**.

|   Kin   |   Strike   |                                          Effect                                          |
|---------|------------|------------------------------------------------------------------------------------------|
| Beast   | Bite       | no effect                                                                   |
| Winged  | Dive       | then move 1 square away for free (the free neighbour farthest from the target)           |
| Scaled  | Tail Sweep | push the target 1 square (direction chosen with WASD)                                    |
| Swarm   | Gnaw       | props take double (4)                                                                    |
| Spirit  | Siphon     | target −1 initiative next round                                                          |
| Ancient | Slam       | destroys the Mountain under the target (Mountain-destruction rule: [gdd_battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed); no ground change authored → Rubble) |

### 8.2 Movement by Kin

Every monster has **Step**. Anything better is a movement skill in one of the 4 slots, and each Kin only has some of them. Each mode is a preset of movement flags ([§3](#3-skill-execution-profiles)).

|         Mode        |      Kin       |
|---------------------|----------------|
| **Step**            | all, no slot   |
| **Run**             | all but Spirit |
| **Leap**            | Beast          |
| **Glide**           | Winged         |
| **Burrow**          | Scaled, Swarm  |
| **Phase**           | Spirit         |
| **Blink**           | Spirit         |

- **Foreign movement:** from **Soul Tier**, learn **one other Kin's mode** unless body-forbidden; Ancient never gets Glide/Blink.
- Normal ends at Core, retaining only its Kin's modes: rarity = flexibility ([Monsters §5.1](gdd_monsters.md#51-monster-rarity)).

Points in Movement only pay off with a movement skill; a Step-only monster stays at the frame's min.

## 9. Passives

- **Slots/model:** passives occupy normal kit slots (§1), use §2 and spend no active AP; evaluate availability/trigger frequency (§5). Equipped availability does not mean continuous effect: explicitly define continuous, conditional or event-driven application.
- **Access:** species learnable list/individual (Epic+ extra slot, artifacts), within Kin/progression limits, never theme/aspect. 1 active + 3 passives is legal but weak.
- **Prior-draft candidates, not approved perks or exceptions to §1–§7:** effects/access/interactions need T02/T04/T11 validation. Momentum damage, AP discounts, Crashlander collision wording and automatic movement/target selection remain unresolved; grant no damage/AP-reduction upgrades, new collision rules or unspecified tie-breaks.

**Terrain Identity:**

- Adaptive (may rotate its skill shapes in battle)
- Purifier (adjacent enemy zones lose 1 round at round end)
- Overgrowth (your zones start at level II).
- Native Ground, Painter, Trailblazer and Deep Roots remain non-mechanical placeholders after aspect removal ([temp_todo.md](temp_todo.md) T11); no replacement effects or values are established.

**Position & Movement:**

- Highlander (+2 init on a Mountain)
- Turret (can't move, +1 Reach)
- Skittish (free 1-square move after taking Surge damage — to the safest free neighbour)
- Phasing (moves through props)
- Momentum (after a max-distance move, the next Surge this turn deals +1)

**Displacement:**

- Crashlander (when it is pushed or pulled into a prop or monster, the collision damage *it* takes is reduced by 1, i.e. to 0; the other side still takes the fixed 1 under [Battle §6.3](gdd_battle.md#63-collision-fall--debris))
- Immovable (ignores push/pull)
- Counterweight (allies orthogonally adjacent to it can't be pushed or pulled)

**Combat:**

- Thick Hide (damage this monster *receives* from Strikes and from collisions is reduced by 1; it is summed with other modifiers in one step and floored at 0 under [Battle §6.1](gdd_battle.md#61-the-damage-law); fall, collapse, debris and Surge damage are unaffected)
- Pack Hunter (Strike costs 1 AP less if an ally is adjacent to the target)
- First Blood (its first Strike each battle costs 1 AP less)
- Vengeful (after taking Surge damage, its next Strike costs 1 AP less)
- Scavenger (heals 1 when a prop within its Reach is destroyed)
- Frenzy (+1 shape cell at 1–2 HP)
- Bulwark (team: allies orthogonally adjacent to it take 1 less Surge damage)

**Ground & Zone Resistance:**

- Sure-footed (ignores `slow`)
- Clear Mind (ignores `drain_*`)
- Heatproof (ignores Lava)
- Thornwalker (ignores Thornbed)
- Void-touched (ignores Blight) — the unit-level way of shrugging a specific effect.

## 10. Species Skill Assignments (Prior Draft)

**Non-authoritative prior-draft ideas:** no skill/access/cost specification, blueprint catalogue or approved damage/range exceptions. Names, old twists, passives, descriptions and overfilled loadouts grant no exceptions to §1–§9; retain for later validation, not implementation/redesign here. Rebuild under §2–§7; species access: §3 / §1. Monster identity, stats and shapes: [Monsters §4.1](gdd_monsters.md#41-first-roster-draft--9-monsters).
- **Legacy loadouts:** movement (§8.2) + Kin Strike (§8.1) + Surge + utility = 4 slots, plus table passive. Under the [current kit rule](#1-the-kit), passives need their own slot: these are not finalized legal kits. Forge Golem uses only Step and takes a second utility.

| Monster | Kin | Movement | Surge (type · shape · twist) | Utility | Passive |
|---|---|---|---|---|---|
| **Blaze Tiger** | Beast | Leap | *Magma Pounce* · Eruption · O4 · **Pounce** | Lava Field | Momentum |
| **Ember Hawk** | Winged | Glide | *Cinder Dive* · Eruption · I3 · **Trail** | Shockwave | Skittish |
| **Forge Golem** | Ancient | — | *Crucible* · Eruption · ring of 4 · **Ring** | Raise Prop (type open, T10), Raise Ground | Immovable |
| **Moss Turtle** | Scaled | Run | *Tidal Shell* · Flood · I3 · **Slow-burn** | Bark Veil | Deep Roots |
| **Thorn Mites** | Swarm | Burrow | *Bramble Tide* · Flood · I2 · **Deep Residue** | Thornbed | Thornwalker |
| **Grove Wisp** | Spirit | Phase | *Spring Burst* · Flood · L3 · **Lob** | Gale | Adaptive |
| **Gloom Wolf** | Beast | Run | *Gloom Rift* · Rift · I3 / L3 · — (baseline) | Mire | Pack Hunter |
| **Dusk Moth** | Winged | Glide | *Eclipse* · Rift · I3 → 4 cells · **Wide** | Shade Veil | Native Ground |
| **Hollow Serpent** | Scaled | Burrow | *Coiling Rift* · Rift · L4 · **Constrict** | Void Pull | Thick Hide |

One sentence each (design test):
- **Blaze Tiger** — dives into melee range, lays Lava behind the enemy and pounces with a big Eruption next to itself.
- **Ember Hawk** — strafes a burning line from where it stands, pushes enemies with Shockwave, and dodges away after taking a hit.
- **Forge Golem** — walls itself in and erupts around its own body; you have to come to it.
- **Moss Turtle** — a slow, heavy Flood that hits one turn later but harder, behind Bark Veils, and has a terrain passive awaiting redesign (Deep Roots; [temp_todo.md](temp_todo.md) T11).
- **Thorn Mites** — weak little Floods that leave level II thorns, on top of a Thornbed they walk through unharmed.
- **Grove Wisp** — throws weak Floods from far away, phases through props, and is the only one that can turn its shapes in battle.
- **Gloom Wolf** — the baseline: Mire flips the turn order, its Rift does the rest; much stronger with an ally next to the target.
- **Dusk Moth** — a wide Rift under a Shade Veil; Native Ground remains a placeholder ([temp_todo.md](temp_todo.md) T11).
- **Hollow Serpent** — pulls you in with Void Pull, then its Rift drags everything it hits toward the centre.

Other kits the 4 slots allow (not in the first roster): four Surges, moving by Step only, a stationary battery · Leap + Strike + Shove + a Veil, a mobile fighter without a Surge · Run + Surge + Surge + Veil, a caster with one answer.

Coverage gaps in the reference roster: Raise Ground (except Forge Golem), Sanctify, Shove, Blink. Roster and species-list coverage remain unvalidated ([temp_todo.md](temp_todo.md) T11/T12); no Kin × aspect quota applies.

Coverage gaps in the reference roster: Raise Ground (except Forge Golem), Sanctify, Shove, Blink. Roster and species-list coverage remain unvalidated ([temp_todo.md](temp_todo.md) T11/T12); no Kin × aspect quota applies.

### 6.2 Additional Species Candidates

The former Kin × aspect grid is not a roster requirement. These names remain an unordered idea pool within each Kin, without fixed theme categories or a required number of variants:

| Kin | Additional candidates |
|-----|-----------------------|
| Beast | Vine Panther |
| Winged | Gale Crane |
| Scaled | Magma Drake |
| Swarm | Cinder Wasps, Grave Rats |
| Spirit | War Echo, Wailing Shade |
| Ancient | Elder Treant, Bone Colossus |

**Status:** candidate pool only; launch selection and species definitions remain open under [temp_todo.md](temp_todo.md) T11/T12. No replacement roster quota is set here.

Coverage gaps in the reference roster: Raise Ground (except Forge Golem), Sanctify, Shove, Blink. Roster and species-list coverage remain unvalidated ([temp_todo.md](temp_todo.md) T11/T12); no Kin × aspect quota applies.

## 11. Concrete Skill Records

Draft structural references (Strike, Surge, Zone, Movement, self-buff, passive); not approved content. Layout and field groups: [§2](#2-data-oriented-skill-construction-kit).

### Slowing Zone, Beast Jab and Delayed Burst (area and Strike references)

**Documentation template, not implementation:** one §2 model including species skills/upgraded variants. Field names show responsibilities, not required serialization; referenced effects supply mechanics/caps, not a parallel zone schema.

**Slowing-zone walkthrough — unapproved draft:** proposed 1 AP, fixed horizontal I3, 2 rounds, `slow` base 1/cap 2, no ignition/secondary effect. Area/AP are calibration proposals; a centred three-cell footprint avoids two-cell midpoint ambiguity.
- The full field-by-field record is the Slowing Zone entry of each field group below.
- **Paper checks, not engine tests:** anchor (3,3) yields (2,3)/(3,3)/(4,3); (0,3) is invalid because (-1,3) is off-board. Ground Movement 3 becomes 2 at level I, returns to 3 on exit; Step stays normal, allies behave identically. Props are not slowed, air is excluded, underlying ground unchanged. General 2×2/unrelated gaps remain open.
- **Bindings:** single authored footprint, not cast-time shape choice. Placement: [§2](#2-data-oriented-skill-construction-kit); lifetime: [Battle §4.5](gdd_battle.md#45-lifecycles); value/replacement: [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites). Evaluation: provisional [Slow calculation](#calibration-examples)/[AP scale](#ap-efficiency-working-scale), not unlock/content approval.
- **Representation:** The table below is the single baseline record; candidate patches stay separate/unapproved.
  - References are documentation contracts, not invented runtime identifiers.
  - Ground operations use `board_changes`, layers per-effect, no duplicate flags.
  - The superseded flat blueprint's behaviour/targeting/direction/duration/usage belong to these dimensions; Surge twists/species ownership are profile constraints/metadata on this same model.

**Draft structural/calibration references, not approved catalogue or balance:** Slowing Zone, Beast Jab, Delayed Burst; Run, Focus, Adaptive below complete six cases.
- Same top-level schema; groups explicit or bound to §2/§8.1. Unresolved access/upgrades/runtime remain draft. Jab covers only fully costed Beast, not other Kins' unresolved contracts (T02/T06).
- No runtime identifiers. Coordinates `[dx, dy]`, **1×1 bodies only**; 2×2 records need the unapproved 2×2 variants (T09).

Cases per field below: **Slowing Zone reference (draft)**; **Beast Jab reference (draft record of existing Strike)**; **Delayed Burst reference (draft Minor Surge)**.

- **`metadata`**
  - Slowing Zone: `id: slowing_zone_example`; `name: Slowing Zone (draft)`; `kind: zone`; `rule_profile: zone`; `tags: [control]`; ordinary species access
  - Beast Jab: `id: jab_reference`; `name: Jab`; `kind: strike`; `rule_profile: strike`; `tags: [reference]`; Beast Kin binding (§8.1), no additional Kin effect
  - Delayed Burst: `id: delayed_burst_reference`; `name: Delayed Burst (draft)`; `kind: surge`; `rule_profile: minor_surge_residue_free`; `tags: [reference]`; no species twist; ordinary Kin/access limits
- **`access`**
  - Slowing Zone: Authored species list; existing Kin/progression constraints
  - Beast Jab: Authored species list; Beast Kin and existing Strike access (§8.1); concrete species list pending
  - Delayed Burst: Authored species list and ordinary Kin constraints; Swarm cannot use this 3-cell footprint
- **`usage_type`**
  - Slowing Zone: `active`
  - Beast Jab: `active`
  - Delayed Burst: `active`
- **`execution`**
  - Slowing Zone: `activation: player_action`; legal-cast condition; `timing: immediate`; `resolution: cast_resolution`
  - Beast Jab: `activation: player_action`; legal-Strike condition; `timing: immediate`; `resolution: cast_resolution`
  - Delayed Burst: `activation: player_action`; legal-Surge condition; `timing: telegraphed_delayed`; `resolution: caster_next_turn_start_before_start_effects`; marker/charging under §2; autonomous after displacement or death; a Surge of a dead caster detonates at the start of the next round ([Battle §2.2](gdd_battle.md#22-initiative-rules))
- **`targeting`**
  - Slowing Zone: `type: tile`; existing zone target eligibility; `distance_source: caster_reach`; no LOS
  - Beast Jab: `type: self`; `eligibility: caster`; `distance_source: body_footprint_not_reach`; `line_of_sight: not_required`
  - Delayed Burst: `type: tile`; any legal board anchor; `distance_source: caster_reach` (Manhattan to anchor); `line_of_sight: not_required`
- **`placement`**
  - Slowing Zone: Selected tile anchor; fixed board cells at cast; no direction selection; existing zone placement including props/replacement rules
  - Beast Jab: `anchor: caster_body`; `binding: immediate_body_relative`; `direction_selection: one_of_eight`; existing §8.1 body placement, caster excluded
  - Delayed Burst: `anchor: selected_tile`; `binding: fixed_board_cells_at_cast`; `direction_selection: none`; props permitted, no overlap with a charging Surge; existing Surge placement
- **`area`**
  - Slowing Zone: Fixed horizontal I3; offsets `[[-1,0],[0,0],[1,0]]`; 3 cells; all cells on-board; no clipping/rotation
  - Beast Jab: `shape: Jab`; `offsets: [d]`, where selected `d` is exactly one of `(−1,−1), (0,−1), (1,−1), (−1,0), (1,0), (−1,1), (0,1), (1,1)`; `cell_count: 1`; orientation = selected direction; `orientation_policy: strike_direction_selection`; `boundary_rule: all_cells_on_board`; solid-prop blocking under §8.1
  - Delayed Burst: `shape: I3`; `offsets: [[-1,0],[0,0],[1,0]]`; `cell_count: 3`; `orientation: horizontal`; `orientation_policy: fixed_board`; `boundary_rule: all_cells_on_board`; no clipping/rotation; props do not block placement; damage hits a Mountain square normally, without destroying it
- **`effects`**
  - Slowing Zone: `stat_change: slow`; base 1/cap 2, same-zone levelling `min(2, 1 + level - 1)` (battle-zone level, not slot level); level I subtracts 1 Movement, minimum 1, Step unaffected; applied immediately on placement and continuously while inside, no damage/entry payload; all ground-layer occupants including allies/caster, no air, props, height or ground-state effect; existing zone stacking/level rules, shared created-zone lifetime; ends on exit/removal
  - Beast Jab: `damage`: Beast Strike under §8.1, fixed 2 against monsters/props; recipients = all struck monsters including allies, excluding caster, and struck props; evaluate/apply once at cast resolution, action lifetime none/no retained damage stack. Beast has no additional Kin effect
  - Delayed Burst:
    - `damage`: fixed 3 against all ground-layer monsters in the footprint at resolution, including caster/allies/enemies
    - no air. Existing ordinary Surge prop handling: 2 to prop instead of occupant
    - shield/Hallowed reduction, minimum 0. Apply once at detonation
    - no push, pull or prop-specific reaction
    - no repeat payload
    - one-shot damage has no retained stack
    - pending marker lifetime ends at resolution
- **`persistence`**
  - Slowing Zone: Created zone; 2 rounds; shared clock decrements at round end, zone removed at 0; 2 rounds do not guarantee two full personal turns per monster
  - Beast Jab: `none`; immediate action with no retained Kin state
  - Delayed Burst: `type: until_resolution`; `owner: pending_surge`; expires at detonation; no post-resolution effect lifetime
- **`board_changes`**
  - Slowing Zone: `[]`: no ground, height or prop operation
  - Beast Jab: `[]`: no authored ground/height/prop operation; ordinary damage-derived prop destruction uses Battle §4.10
  - Delayed Burst: `[]`: no authored ground placement, residue or height change; ordinary damage-derived prop destruction and aftermath remain §2, not an added residue component
- **`interactions`**
  - Slowing Zone: Placement not blocked by props/height; recipient layers are specified in `effects`; no ground-changing operation
  - Beast Jab: Monster damage recipients include ground and air; `blocked_by_objects: true` (solid-prop line rule); `blocked_by_height: false`; no additional Beast operation
  - Delayed Burst: Damage recipients are ground-layer only; `blocked_by_objects: false` for placement (prop intercepts damage); `blocked_by_height: false`; no ground reset, including Hallowed consumption without residue
- **`usage`**
  - Slowing Zone: `ap_cost: 1` proposed; existing zone limits
  - Beast Jab: `ap_cost: 2`; existing AP repetition, no charging limit
  - Delayed Burst: `ap_cost: 1` proposed; existing AP spending/repetition rules allow separate concurrent casts on legal non-overlapping footprints; no cooldown/mana
- **`upgrades`**
  - Slowing Zone: `[]` in baseline; separate candidate patches below, no approved requirements
  - Beast Jab: `[]` in baseline; separate candidate patches below, none approved
  - Delayed Burst: `[]` in baseline; separate candidate patches below, none approved
- **`evaluation`**
  - Slowing Zone: Provisional Slow zone calculation in [§5](#calibration-examples); passive availability `none`, combination 0; unlock conditions pending
  - Beast Jab: Provisional Beast Jab calculation in [§5](#calibration-examples); passive availability `none`, combination 0; unlock conditions pending
  - Delayed Burst: Provisional residue-free Surge calculation in [§5](#calibration-examples); passive availability `none`, combination 0; unlock conditions pending

**Paper checks, not executed tests:**
- Beast Jab from (3,3), `d = (1,0)`: only (4,3), 2 monster damage even to an ally, no extra Kin effect/Reach cast.
- Burst at (3,3): marks (2,3)/(3,3)/(4,3), evaluates occupants only at caster's next turn start. Leaving avoids damage; death does not cancel; air unaffected. Surviving ground stays unchanged, no invented residue consumption of Hallowed. Leaving/protection/air provide at least three live counters.

**Upgrade candidate choices — all DRAFT, not balance approval or unlocks.**

- Patches use the same schema and must pass §6.
- Each offer is an alternative, not automatically cumulative; no level requirements or step prices are assigned; upgrade limits: [§6](#6-slot-levels-development-replacement-and-upgrades).

- **Slowing Zone**
  - Same-AP candidate choice: At 1 AP: choose fixed vertical I3 (`offsets: [[0,-1],[0,0],[0,1]]`, orientation vertical), or `persistence.duration: 3` (the +1 total cap); other fields unchanged
  - Optional higher-AP candidate choice: At proposed 2 AP: choose fixed T4 (`offsets: [[-1,0],[0,0],[1,0],[0,1]]`, centre junction anchor, count 4), keeping duration 2 and the same slow formula
- **Beast Jab**
  - Same-AP candidate choice: A meaningful 2-AP Beast development offer remains unresolved under [temp_todo.md](temp_todo.md) T02/T05. No lawful larger shape exists at this price in §8.1; selecting a direction is baseline use, not an upgrade. This reference does not claim a completed same-AP path
  - Optional higher-AP candidate choice: Existing Thrust at 3 AP: `shape: Thrust`, offsets `[d, 2d]` for selected cardinal `d`, count 2, solid-prop blocking unchanged; damage 2 and Beast's lack of an additional Kin effect unchanged. Optional branch, never required
- **Delayed Burst**
  - Same-AP candidate choice: At proposed 1 AP: choose fixed L3 (`offsets: [[0,-1],[0,0],[1,0]]`, junction anchor, count 3); other fields unchanged
  - Optional higher-AP candidate choice: At proposed 2 AP: choose fixed T4 with the offsets/anchor above, count 4; damage 3, delay, recipients and `board_changes: []` unchanged. This is not Major Surge access; Swarm cannot use either 3/4-cell reference

- **Status:** calibration/same-AP development incomplete ([temp_todo.md](temp_todo.md) T02/T05); large bodies remain T09. Residue is a board component, not combination surcharge (§5); residue-free references do not replace [concrete profiles](#surge).
- **Resolution:** resolve all definitions/required parameters before validation (§2–§7). No skill override of fixed fields; rules determine effect/operation order, never field-list position. Unsupported/unspecified cases remain central TODO.
- **Upgrades:** authorized named-field patches with prerequisites/exclusions/budget/AP consequences (§6), not another schema. Revalidate profile, Kin/species access, execution, placement, footprint, effect/trigger legality, persistence, interactions, usage and budget. Shared repetition policies: [§2](#usage-and-repetition); no generic multi-round cooldowns/mana/aspect/attunement. Upgrade limits: §6.

### Non-Area and Passive Coverage References

**Additional reference coverage:**

- These three records use exactly the same field groups as the preceding three.
- **Run** records an existing preset for a legal user; **Focus** is a new, unapproved self-buff proposal; **Adaptive** is a structural transcription of the existing passive candidate, not a finalized learn-list/upgrade/balance approval.
- Names below are documentation references, not runtime identifiers.

Cases per field below: **Run reference**; **Focus self-buff reference (DRAFT)**; **Adaptive passive reference (DRAFT content)**.

- **`metadata`**
  - Run: `id: run_reference`; name Run; `kind: move`; `rule_profile: run`; tags movement
  - Focus (draft): `id: focus_reference`; name Focus; `kind: utility`; `rule_profile: none`; tags buff
  - Adaptive (draft content): `id: adaptive_reference`; name Adaptive; `kind: passive`; `rule_profile: none`; tags shape
- **`access`**
  - Run: Species learns Run and Kin/preset access permits it (§8.2); no grant to Step-only users
  - Focus (draft): One authored species learn-list; exact species/progression pending; exclusivity grants no extra budget
  - Adaptive (draft content): Authored species learn-list and legal active/passive slot; concrete list pending
- **`usage_type`**
  - Run: `active`
  - Focus (draft): `active`
  - Adaptive (draft content): `passive`
- **`execution`**
  - Run: Player action; legal-movement condition; immediate movement resolution
  - Focus (draft): Player action; caster alive/able to act; immediate application
  - Adaptive (draft content): `activation: while_equipped`; active while owner participates in battle and the skill occupies a legal slot; continuous rule evaluation, not a repeatedly cast action
- **`targeting`**
  - Run: Self mover plus player-selected legal path/destination; distance source Movement, not Reach; Run preset sight/path rules
  - Focus (draft): `type: self`; no distance or LOS check
  - Adaptive (draft content): `type: none`; owner bound by equipment, no player-selected recipient
- **`placement`**
  - Run: Caster origin, selected walk path/destination, existing Run path/landing rules; no persistent board placement
  - Focus (draft): `none`; buff attaches to caster, not its tile
  - Adaptive (draft content): `none`; permission belongs to owner, not a board tile
- **`area`**
  - Run: `none`; a movement path is traversal, not a damage/zone footprint
  - Focus (draft): `none`
  - Adaptive (draft content): `none`; modifying another skill's orientation does not create an area
- **`effects`**
  - Run: Typed self `movement`, Run preset, distance effective Movement (minimum 1); once at action resolution; owner's legal layer; no retained state/stack; process walk entry effects under existing rules
  - Focus (draft): Typed `stat_change`: effective Initiative +1 to self in its legal layer; apply at resolution; bind to `focus_state`; same-skill/same-owner group refreshes duration, never adds magnitude, and other sources add (Battle §3.1); removal/death policies pending
  - Adaptive (draft content):
    - Typed `rule_modifier`: permit owner to rotate otherwise fixed tetris shapes when previewing/casting its own eligible skills
    - self scope in owner's legal layer
    - activation while equipped
    - boolean/idempotent permission, not extra magnitude
    - does not change Strike direction rules or authorize other profile changes
- **`persistence`**
  - Run: `none`; action completes after traversal/landing
  - Focus (draft): `focus_state`: proposed 2 rounds, tick round end, remove modifier at 0; exact queue application follows normal round initiative recalculation; other termination policies pending
  - Adaptive (draft content): `adaptive_permission`: while owner participates in battle with this passive equipped; ends when that condition fails/battle ends; no round counter
- **`board_changes`**
  - Run: `[]`; entry-triggered board reactions remain ordinary runtime rules
  - Focus (draft): `[]`
  - Adaptive (draft content): `[]`
- **`interactions`**
  - Run: Walk; blocked by solid props, monsters and charging Surges; height allowed; ground costs apply; distance modifier 0; legal destination required; air/2×2 remain T09
  - Focus (draft): No placement/path blocking; no air attack or ground interaction is introduced by a self-bound modifier
  - Adaptive (draft content): Affects only owner's authorized shape orientation choice; no targeting, footprint, layer or terrain exceptions
- **`usage`**
  - Run: Existing 2 AP; ordinary action repetition; no cooldown/mana
  - Focus (draft): Proposed 1 AP; ordinary active-action repetition; recasting refresh is only a draft policy, not a finalized balance rule
  - Adaptive (draft content): `ap_cost: none`; no active cast or player-action repetition; no separate activation button
- **`upgrades`**
  - Run: None approved; existing movement-upgrade limits still apply; full three-level path pending T05
  - Focus (draft): None approved; may explore bounded duration/secondary effects, not direct damage/AP/range upgrades; full path pending
  - Adaptive (draft content): None approved; passive development/active-passive replacement remain T05; no automatic extra permission from slot level
- **`evaluation`**
  - Run: [Movement cost reference](#movement-costs); passive availability `none`, combination 0; unlock/content/development validation pending
  - Focus (draft): [Self-buff cost reference](#self-buff-and-passive-costs); passive availability `none`, combination 0; content/development validation pending
  - Adaptive (draft content): [Passive rotation cost reference](#self-buff-and-passive-costs); AP efficiency `none`, combination 0; content/interaction/development validation pending

**Six-case paper checks:**
- **Strike:** immediate body-relative Beast Jab, ground/air, no extra Kin effect, Reach targeting or zone lifetime.
- **Surge:** declaration ≠ delayed resolution; marker lifetime implies neither residue nor lasting damage.
- **Zone:** one cast/shared lifetime; continuous slow is no extra action/repeated damage.
- **Movement:** path/destination, not artificial area; entry retains ordinary board rules.
- **Self buff:** movement off the original tile does not remove self state; no tile placement/ground payload/`unique` effect. Round-end duration does not guarantee two personal turns; termination gaps block approval; stacking follows Battle §3.1.
- **Passive:** equipped rotation is a scoped rule modifier, not AP-zero cast/separate schema. Identical boolean permissions grant no extra rotations/rule changes; author other passive interactions.

- **Coverage limits:** structural walkthroughs, not engine tests/content approval. Event-driven passives fit declared activation events/conditions, event-bound recipients and typed effects; resolve repetition/recursion/order before approval (T02/T04/T11).
- **Evaluation:** §5 owns [Calibration Examples](#calibration-examples), [Movement Costs](#movement-costs), [Self-Buff and Passive Costs](#self-buff-and-passive-costs). All six have initial calculations, none a complete three-level path; interaction/content gaps block full validation. Same evaluation fields throughout; `none` means inapplicable, not free unpriced advantage.
