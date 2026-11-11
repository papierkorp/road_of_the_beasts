# GDD — SKILLS
*Working Draft · companion specifications: [Monsters](gdd_monsters.md) (what a monster is), [Battle System](gdd_battle.md) (how a fight works), [Overworld & Meta](gdd_overworld.md) (the world around it) · source of truth for everything that defines a monster skill*


## Scope and Status

- **Ownership:** all monster-skill rules/content live here; each concrete skill is defined once, with its exceptions. Other documents refer by name/id, never copied records. Monster identity, stats, Kins, roster and growth stay in [gdd_monsters.md](gdd_monsters.md).
  - **Rule owners:** kit/access (§1), model/spatial/temporal contracts (§2), execution profiles (§3), effect/board operations (§4), point/AP calculations (§5), slot development (§6), validation (§7).
  - **Content owners:** Kin Strike/movement tables (§8), passives (§9), prior-draft species assignments (§10), concrete records (§11).
- **Boundary:** gdd_battle owns turns/events, board state, zone/ground/prop interactions and generic damage/displacement/collision resolution, not parallel skill execution rules. gdd_overworld owns tamer skills, loadout and meta logistics/economy; monster-skill budgets do not automatically apply there.
- Confirmed rules override legacy conflicts; open decisions remain in temp_todo.md.
- **Open rules:** a missing or unresolved rule grants no default, permission or implicit behaviour; content that depends on it stays blocked, and the T-references in this chapter name the owning task.
- **Status:** the records in §11 are **draft structural/calibration references, not approved content, balance or unlocks**; §8–§10 hold working and prior-draft content. Open decisions and tasks live only in [temp_todo.md](temp_todo.md) (T02, T05, T10, T11).
- **Section references:** `§n` without a file name means this file; other files are named explicitly (Monsters, Battle, Overworld).


## 1. The Kit

```
Monster = Step (always, no slot)
        + 4 slots, each an active (movement skill, Strike (Kin), Surge, utility) or a passive,
          at least one active      — Epic+ get a 5th, passive-only slot
```

Rarity access: [Monsters §5.1](gdd_monsters.md#51-monster-rarity). Step mechanics: [Movement](#movement); Battle-AP: [§5](#ap-efficiency-working-scale).

- **Slots:** all 4 open on day one; movement skills occupy a normal slot, unlike universal slot-free Step. No skill kind is mandatory; repeats, including identical skills in separate legal slots, are allowed. Each copy occupies its own slot; activation allowances follow [§2](#usage-and-repetition), with access and passive-only restrictions unchanged.
- **Limits:** species learnable list and Kin lock-outs ([Monsters §3.1](gdd_monsters.md#31-kin-table)/§8.2); [usage](#usage-and-repetition) and [Surge placement/concurrency](#surge) remain binding.
- **Species Surge:** one per species, included in its default kit/learnable list but optional as a normal slot skill; authored constraints follow [§3](#surge-constraints-and-species-access).
- **Default-kit tip:** pair a Surge with a *different effect family* of utility (protection, slowing or displacement), preserving an answer. Skills define zones/ground/effects; descriptive themes grant no bonuses or penalties. The prototype Tiger's 7 skills are a test bench, not a kit.

### Species-Specific and Signature Access

- **Species exclusivity** means authorship/learn-list access, not a `unique` mechanical kind, perk category or construction system. Use the §2 schema (concrete records: [§11](#11-concrete-skill-records)), a normal legal slot, actual profile/constraints, existing interactions and explicitly validated usage/points (§5); ownership grants no effect permission.
- Map companion documents' legacy `Unique` labels to concrete profiles/definitions before implementation, never a catch-all profile.

- **Signature/Major access — no new access/values decided here:**
  - **Signature:** Legendary/progression-bound ([Monsters §5.1](gdd_monsters.md#51-monster-rarity)/[§5.3](gdd_monsters.md#53-monster-progression-the-18-steps)); slot treatment and effect undecided.
  - **Major Surge:** Ancient access at Sovereign; AP/once-per-battle limit: [§5](#ap-efficiency-working-scale). Legacy access ambiguity remains [temp_todo.md](temp_todo.md) T02/T32, not an active Battle rule or permission for every Legendary.

- **Effects/upgrades:** new effects need authored, validated definitions; exclusivity grants no arbitrary boosts, damage, healing, board removal or targeting. Use the [slot-development policy](#6-slot-levels-development-replacement-and-upgrades). Unresolved content stays central T02/T10–T12/T32, not a parallel catalogue.

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
| `targeting` | Selection, eligibility, distance source and sight under the spatial contract below; event-driven recipients may be bound without player selection. | [Selection costs](#zone-protection-and-healing-costs), resolved together with placement; no second fee for the same selection. |
| `placement` | Body/board anchor, selected destination/path, binding and direction, or `none`. A self buff does not create a board anchor. | [Anchor/direction costs](#component-price-sheet); movement path/destination is included in its [preset](#movement-costs), not an additional ranged anchor. |
| `area` | Explicit footprint/count/orientation and boundary rules, or `none` for non-area effects. Area is not cast range. | Supplies potential cells/distant cells to component formulas, not a second area fee. `none` creates no artificial one-cell area charge. |
| `effects` | Typed effect definitions with parameters/value sources, per-effect recipients/layers, application event, conditions, lifetime reference, stacking/refresh and resolution dependencies. Includes stat modifiers and rule modifiers, not just attacks. | Resolve [§4 contracts](#4-effect-and-board-operation-contracts) to the applicable §5 component: damage, displacement, modifiers, protection/healing, self movement or rule permission. Recipients determine authorized coverage. |
| `persistence` | Named lifetimes for zones, states, props or pending actions: owner, duration/clock or end/consumption condition. Effects reference these entries; all effects of one zone share one clock. Delay is distinct from buff lifetime. | Supplies duration/availability to the applicable component; permanent [board packages](#ground-and-board-costs) already include persistence. No duplicate timer or future-trigger charge. |
| `board_changes` | Explicit typed ground, height and prop operations with targets, trigger/order and lifetime references, or `[]`. Natural damage reactions are resolved by their existing source rules. | [Ground/board components](#ground-and-board-costs); included reactions are not separate authored payloads. Missing special-reaction valuation is unresolved, not free. |
| `interactions` | Placement/effect/path blocking and other profile constraints. Recipient layers belong to each effect, not to global hit flags. | Resolve the applicable effect/package constraints; no generic flag fee or automatic restriction discount. Changed permissions require an applicable rate. |
| `usage` | Battle-AP cost and explicit activation/repetition limits for active or event-driven skills; count, scope and reset follow [Usage and Repetition](#usage-and-repetition). | [AP efficiency](#ap-efficiency-working-scale) once per active use; limits constrain valuation but grant no unpriced discount. |
| `upgrades` | Authored patches to these same fields, slot-level requirements, prerequisites/exclusions and explicit AP consequences. Empty while a draft's development path is unresolved. | Re-evaluate the resolved patched definition, not a second upgrade-component model or duplicate enlargement charge. |
| `evaluation` | Derived authoring/test report: component costs, AP-efficiency or passive availability, total points and required slot-level ceiling. Legacy `combination_cost` follows the [combination policy](#combination-policy-and-basic-surge-target). | Derived result under [§5](#5-construction-points-and-ap-efficiency), not independently editable mechanics, prices or permissions. |

- **Profiles are reusable bundles, not a closed menu:** Strike supplies body-relative hits, Surge telegraphing/charging, Zone persistent board area, movement presets traversal. Fully defined self buffs/passives may use `rule_profile: none`, without bypassing damage delivery, access or hard limits.

- **No redundant flags:** retired `affects_ground`/`affects_air` authoring inputs and historical/prototype names are not current schema. Ground changes belong only in `board_changes`, layers only in effect recipients; UI summaries such as “changes ground” are derived, not separately priced.

- **Events/lifetimes:** each effect names its application event, state owner if any, lifetime reference/`none`, and stacking group plus stacking/refresh rule where reapplication is possible.
  - States may have distinct lifetimes; persistent states specify termination/removal and recipient/condition reevaluation. Missing event/stacking/termination rules stay unresolved.
  - Temporary species-specific effects state N rounds or an explicit consumption/end-of-battle condition; the former flat `rounds` field is not a separate schema.
- **Bindings:** profiles §3, shared effects §4, evaluation §5, validation §7, six structurally different draft records in [§11](#11-concrete-skill-records). No aspect/attunement field, automatic new trigger or budget override.

**Spatial contracts — targeting, placement and recipients**

These are separate responsibilities, resolved against [gdd_battle §4.3–4.11](gdd_battle.md#43-the-square-stack-zones--ground) and the central execution profiles (§3). References may supply fixed fields; an unresolved rule is not a configurable permission.

- **Confirmed square-control boundary:** attacks define affected squares through their authored footprint/body shape, not a generic directly selected-unit damage action.
- Eligible occupants are hit under the owning profile's caster/layer/blocking rules, without ally-only/enemy-only area filters. Zones retain their shared field effects for both sides.
- Self movement and source-defined unit-bound utility remain separate; this principle neither bans them nor authorizes new utility effects.

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
  - Binding rules / open cases: Selection does not restrict an area to the selected unit or its side; the square-control boundary above applies. Effects of one skill may differ under their source contracts, and recipient data grants no new air access. Self-bound modifiers affect their owner in its legal layer unless explicitly narrowed.
    - Recipient contracts: [Strike](#strike), [Surge](#surge) and [zones (Battle §4.6)](gdd_battle.md#46-zones-effects-rules--opposites).
    - Ground affects ground-layer occupants; prop reactions and Surge prop/occupant handling use their own rules, not a generic occupant hit ([gdd_battle §4.6–4.7](gdd_battle.md#46-zones-effects-rules--opposites) and §3 here).

- **LOS ≠ placement legality:** zone/ground/prop/Surge casts and self boosts need no LOS; source-defined unit-targeted utility needs its explicit sight contract. Reach, occupancy, layer and blocking checks still apply. Exact sight geometry/unspecified direct-target eligibility remain [temp_todo.md](temp_todo.md) T02/T04/T09.
- **Layer-specific occupancy:** per-cell layer limits, props under zones/Surges and ground-on-prop rules: [Battle §4.3](gdd_battle.md#43-the-square-stack-zones--ground). Skill-side additions: prop creation needs empty cells; charging Surges cannot overlap (§3 here). Air occupancy follows Battle §4.3; no universal cross-layer `empty` test (open details: T09).
- **Fixed bindings:** board-cell and displacement bindings use [Battle §4.4](gdd_battle.md#44-square-data-model)/[§6.5](gdd_battle.md#65-displacement). Selecting a unit grants no homing area, following zone, moving pull anchor or automatic retarget after movement/death. Author unspecified unit-target resolution/validity (T02/T04); immediate body-relative Strike placement is no tracking precedent.

**Area contract — explicit footprint, not cast range**

- **Required area data:** shape/profile, distinct integer offsets from a declared anchor/body origin, matching `cell_count`, authored orientation/selection policy, boundary and blocking/placement references. Reusable footprints may own offsets; family names/unexplained orientation numbers cannot reconstruct cells. Non-area skills use `area: none`, without cell count/artificial footprint.
- **Anchor/caps:** [Footprints and Placement](#footprints-and-placement) lists tetris families/counts/orientations. Author the centre-most anchor's exact offset mapping; no runtime tie-break. Ordinary tetris skills use 1–4 cells; Swarm Surges 2 ([Monsters §3.1](gdd_monsters.md#31-kin-table)). Strikes use their own list (§8.1); Major Surge needs its explicitly authored large-area profile/access, not a generic cap override.
- **Orientation:** normal tetris skills have one family and one fixed absolute board orientation for both teams, not facing, team mirroring or default rotation. Only the owner-scoped [passive permission](#non-area-and-passive-coverage-references) allows in-battle rotation; Strike separately selects eight directions (§2–§3). Push direction is not rotation; missing mappings remain T02.
- **Boundaries:** all cells must be on-board (§2); no automatic trimming, shifting or rotation to fit. Keep profile-specific Strike solid-prop blocking, ground/prop occupancy and Mountain blanking separate ([gdd_battle §4.3](gdd_battle.md#43-the-square-stack-zones--ground); §2–§3 here), not universal obstacle clipping/resizing. Forced-movement collision uses [gdd_battle §6.3](gdd_battle.md#63-collision-fall--debris), not area placement.
- **Hits/2×2:** hit deduplication follows [§3](#body-relative-damage-and-movement-variants); cells are not otherwise distinct hits. 2×2 geometry is decided in [Battle §4.3](gdd_battle.md#43-the-square-stack-zones--ground) and §3's *2×2 bodies* entry; no 2×2 board case is left open; the remaining open part is concrete air-capable definitions and prices (T09/T02). Infer neither per-cell/per-unit hits, partial placement nor collision defaults; preview/validation must expose unsupported cases.

**Temporal contract — execution, effect events and lifetime**

| Responsibility | Required resolved data | Existing binding rule |
|----------------|------------------------|-----------------------|
| `execution` | Immediate vs telegraphed delay, exact resolution event, charging/telegraph and autonomy rules where applicable | Immediate resolves the action now, not every effect now. Bind Surge execution to the [Surge profile](#surge) and its scheduling interface in [Battle §2.2](gdd_battle.md#22-initiative-rules); do not substitute a generic one-round delay. |
| Effect trigger/application | Referenced event, whose turn/entry it is, recipients at that event and ordering dependencies | Application events remain definition-bound under [Battle §2.4](gdd_battle.md#24-effect-timing-reference)/[§4.6–4.7](gdd_battle.md#46-zones-effects-rules--opposites). `while_inside` is continuous, not a repeating cast. |
| `persistence` | Owner of the lifetime, clock/event, duration or consumption/removal condition, expiry result | Board lifecycles: [Battle §4.5](gdd_battle.md#45-lifecycles); prop removal/reactions: [§4.10–§4.11](gdd_battle.md#410-prop-catalogue-and-damage). Pending execution, authored aftermath and self-bound states use the named lifetimes above. |

- **Runtime bindings:** use turn/round sequence [Battle §2.1](gdd_battle.md#21-core-battle-loop), event meanings/order [Battle §2.4](gdd_battle.md#24-effect-timing-reference), ground entry [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed). Round duration does not count caster actions.
- **Repetition:** persistence adds no undefined payload/repeat trigger; action repetition follows [Battle §2.3](gdd_battle.md#23-action-points). Missing trigger/lifetime/timing contracts remain [temp_todo.md](temp_todo.md) T02/T04/T07/T09/T19.

### Usage and Repetition

**Confirmed shared authoring options:** every resolved active or event-driven skill declares its repetition policy through `usage`, directly or by an unambiguous profile reference. These are runtime capability limits read by the internal evaluation, not construction points spent during play. No existing skill is assigned a new limit by introducing these options.

- **Resource and limit fields:** Battle-AP is the only battle-use resource for active monster skills; passives use `ap_cost: none`, not a zero-AP active action. Each limit identifies what is counted, its owner/scope and reset event; without a new approved limit, current profile rules remain in force. No generic mana or multi-round cooldown system is introduced.

| Policy | Meaning |
|--------|---------|
| Repeatable | No additional repetition cap from this policy. Activation still requires its defined event/conditions and, for active actions, sufficient Battle-AP; all existing profile and usage limits remain binding. |
| Once per global round | At most one cast/activation of each equipped skill instance in the global battle round. It becomes available in the next global round, not at the owner's next turn; extra turns within one round do not reset it. |

- **Scope:** each equipped skill instance has its own usage allowance, not a shared allowance by skill name, monster or team.
  - Two identical round-limited copies in two legal slots allow one activation each per global round, each active cast paying its own Battle-AP. This trades kit flexibility for additional uses.
  - Independent allowances override neither placement nor separately authored profile-wide limits and add no stacking of identical continuous permissions. Multiple pending Surge casts are separate actions, not stacking of a continuous permission.
- **Activation versus effect:** the policy counts a cast or event-driven activation, not every recipient or subsequent application of an existing zone/state. Casting again to level/refresh a zone is another cast; the zone's scheduled/continuous effects retain their own trigger and lifetime contracts. The policy grants no new trigger or stacking permission.
- **Consumption:** an invalid selection/activation attempt consumes neither Battle-AP nor the instance's allowance.
  - A valid activation consumes its authored Battle-AP and one use of any applicable activation limit at activation, even without later benefit; a valid Surge whose targets leave still spent its activation. Passives consume their applicable instance allowance on valid activation but spend no Battle-AP.
  - Subsequent effects of an existing zone/state consume no new activation. This defines consumption, not unresolved later-resolution target validity, cancellation or event order.
- **Other limits:** retain independent placement restrictions and existing once-per-battle profile limits. A pending Surge does not by itself prevent another Surge cast; its skill instance's policy determines repeat availability. These two repetition options do not remove them or create a multi-round cooldown system. Continuous permissions are not repeatedly activated actions.
- **Evaluation:** read the declared policy before release; active round-limited availability uses the [selected calibration rule](#round-limited-availability-calibration). Runtime activation bookkeeping is not runtime construction costing. Repeatability does not settle recursion, simultaneous ordering, later-resolution target validity/cancellation or owner-removal cases (T02/T04).

### Evaluation Contract — One Definition, One Calculation

Evaluation is an **internal, pre-release calculation/check of an authored definition**, not an in-battle calculation, player-facing resource or required runtime field.

- **Tool boundary:** an authoring script/test may produce it before content admission. The [price calculator](../tools/simulator/pricing.py) covers only explicitly supported reference subsets, not the full model or content admission.
- **Ownership:** the field table binds mechanics to costing within this model, not a parallel blueprint. [§4](#4-effect-and-board-operation-contracts) owns effect/operation contracts; [§5](#5-construction-points-and-ap-efficiency) owns rates, units and package inclusions. Costing and reference records do not redefine either.

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
- All six records in [§11](#11-concrete-skill-records) resolve these groups; skills need not create an area, pending marker or status. Access/profile references/descriptive tags grant no effects or unpriced bonuses.

## 3. Skill Execution Profiles

Central monster-skill execution definitions; [Battle chapter 5](gdd_battle.md#5-skill-integration) links here. Generic board state, scheduling, mitigation and collisions remain in gdd_battle chapters 2, 4 and 6.

### Profile Overview

|   Kind   |      Writes to      |                                         In battle                                          |
|----------|---------------------|--------------------------------------------------------------------------------------------|
| `strike` | squares around the body | small direct damage in a shape around the monster ([Strike profile](#strike))                               |
| `surge`  | Surge layer; ground only via explicit `board_changes` | telegraphed delayed execution, including burst profiles; residue and concurrent casts follow the [Surge profile](#surge) |
| `zone`   | zone layer          | timed control/support ([Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites)); default duration 2 rounds, but every resolved definition must state/reference its lifetime               |
| `ground` | ground layer        | hazard ground or Mountain ([gdd_battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed))                                                           |
| `prop`   | object layer        | places or moves props ([gdd_battle §4.9](gdd_battle.md#49-props))                                                               |
| `direct` | a unit / self | Only source-defined unit/self utility with explicit effect contracts; no generic direct unit-targeted damage or offensive push/pull. Shove uses a body-relative spatial pattern below. |
| `move`   | the caster          | moves the caster ([Movement profile](#movement))                                                                    |

Profiles are reusable, not a closed menu. Direct buffs/passives use the common model without posing as Strike/Surge/Zone; passive activation needs no separate format, and species exclusivity is access data, not `unique` execution.

### Strike

- **Immediate body shape:** starts adjacent to the monster, without anchor, range or Reach. Hard damage ceiling: [Battle §6.1](gdd_battle.md#61-the-damage-law); exact damage and Kin effects: [§8.1](#81-strike-by-kin). Use the selected shape's Battle-AP (§8.1; construction costing §5); larger area never trades away damage.
- **Selection/hits:** no facing; choose one of 8 directions (§8.1 shapes/Kin effects). Hit every monster/prop in the shape, including allies, excluding the striker. Solid props take the hit and block cells behind them.

### Body-Relative Damage and Movement Variants

**Confirmed additional authoring direction, not a replacement for existing Kin Strikes or a priced skill catalogue.**

- **Variants:** finished body-relative actions in the shared §2 model: damage only, movement only without direct damage, or damage plus movement. No cast-time damage-for-movement exchange, free component choice or separate construction system; Shove names the movement-only direction, not a direct unit-targeted attack.
- **Existing content:** Strike damage, Kin effects and authored AP remain unchanged pending reconciliation (T02/T06).

- **Supported geometric scope:** attacker and target are 1×1 bodies; the hit square is adjacent to the attacker's origin. Its offset `d = (dx, dy)` is one of the eight neighbouring unit vectors, including diagonals. Preview the hit and destination before activation; there is no independently chosen displacement direction.
- **Target-movement variant:** for a target on the hit square, destination = hit square + `d`, one square farther from the attacker. It is forced displacement under §4 and Battle §6.3/§6.5, not prop relocation or extra skill damage.
- **Self-movement variant:** destination = attacker origin − the uniquely defined attack-direction vector, once per use, never once per struck target. It uses the self-movement contract, not an assumed copy of forced-movement collision behaviour. A larger/symmetric/otherwise ambiguous pattern without one unique geometric retreat direction has **no self movement**; do not choose a hit target, average offsets or add a free retreat-direction selector.
- **Hit-independent retreat:** a valid activation triggers it, not striking a monster/prop, dealing damage or destroying anything. An empty hit pattern still allows it as a movement tool under the same unique-direction and legal-destination constraints.
  - The attack/board payload resolves independently: prop damage needs its authorized source; Mountain destruction needs an explicit authored operation (§4/Battle §4.7). Retreat alone grants neither.
  - Valuation includes this unconditional movement capability, with no assumed-hit-probability discount.
- **Attack before self retreat:** resolve the attack payload, then attempt one retreat to its geometrically fixed destination on the resulting board.
  - **Failed retreat:** if the destination is absent or illegal (blocked/occupied/off-board included), stay in place: no alternative, retreat collision damage or other failed-movement effect. The attack remains resolved and activation costs/usage consumed. This does not redefine forced push/pull collision consequences.
- **Retreat traversal** *(user decision)*: voluntary one-cell self movement, checking only the destination; diagonals have no corner-cutting check on the two orthogonally adjacent cells.
  - **Height:** moving **up onto a Mountain** from below is blocked like forced movement (failed retreat, no effect). Moving **down** causes **no fall damage**; that remains exclusive to forced movement ([Battle §6.3](gdd_battle.md#63-collision-fall--debris)).
  - **Entry/scope:** success **triggers destination-ground entry effects** (e.g. Thornbed, Mossbed; [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed)). Layer/air restrictions remain T09; 2×2 attackers: below.
- **Multi-cell shapes** *(user decision, 1×1 targets)*: target movement applies **per struck monster on a hit cell adjacent to the attacker's origin**, one square along its own offset `d` away from the attacker (Whirl/Storm push outward, Arc fans out).
  - **Non-adjacent cells** (Thrust tip, Cleave rear row, Long Whirl/Cross): normal damage but **no movement**; no direction normalization. Radial destinations of 1×1 targets are pairwise distinct, with no destination ties.
  - **Self retreat:** still needs a unique attack direction; this rule grants no multi-cell shape a retreat.
- **Retreat direction for shapes** *(user decision; reading confirmed 2026-11-10)*: one cell **opposite to the hit shape's centre**, measured from the attacker's origin.
  - **Direction:** take the geometric centre (mean of hit-cell offsets) relative to the origin. Only a centre on an axis or exactly diagonal defines one of the eight directions; retreat uses the opposite unit vector.
  - **Shapes:** centre at the origin (Pincer, Whirl, Cross, Storm, Long Whirl/Cross) or off all eight directions means **no self retreat**. Jab, Thrust, Diagonal Thrust, Arc and cardinal Cleave qualify.
  - **Required pattern:** even movement-only retreat uses a damage-free hit shape, not an empty pattern. Direction is the already-priced Strike direction selection.
- **One hit per monster** *(user decision)*: a monster covered by several hit cells (mainly 2×2 bodies) is struck **once per use**: damage, Kin effect and push/retreat trigger once, regardless of covered cells. Construction prices stay per potential cell (hit multiplicity is not priced). 2×2 specifics: see *2×2 bodies* below.
- **2×2 bodies** *(user decision 2026-11-10; body rules: [Battle §4.3](gdd_battle.md#43-the-square-stack-zones--ground))*:
  - **Target push:** `d` is the mean of offsets of its covered hit cells adjacent to the attacker's origin. Only a mean on one of the eight directions gives a push; otherwise damage and Kin effect apply without pushing.
  - **Attacker:** choose one of its four covered squares as shape origin together with direction, both previewed; its own body squares are not hit. A retreat moves the whole body one square along the opposite unit vector, only if all four destination squares are legal; otherwise apply the failed-retreat rule.
  - **Target pull:** move the whole body one cardinal step, using the covered square nearest the anchor for direction (ties as for 1×1, T04).
  - **Overlap/board:** a zone, Surge footprint or hit shape overlapping any covered square affects it once per event or use. Mountain, entry and landing rules are decided in [Battle §4.3](gdd_battle.md#43-the-square-stack-zones--ground)/[§6.3](gdd_battle.md#63-collision-fall--debris).
- **Access** *(user decision)*: the variants are **Kin-bound**: target-movement (push) variants, damage-plus-push or movement-only, only for Scaled; self-retreat variants only for Winged. The existing [Kin Strikes](#81-strike-by-kin) stay unchanged and are separate skills. No variant is open to other Kin, and no Kin package is transferred. Shape AP and stage limits follow [§8.1](#81-strike-by-kin); concrete species lists remain content work (T11).
- **Authored alternatives:** target movement or self movement is fixed by the skill, not selected after a hit. Preserve source-specific side/caster/layer permissions and legal landing rules. Blocked/occupied destinations grant no automatic alternative square. Collision, fall and entry consequences remain environmental/runtime consequences, not an extra authored damage component.
- **Spatial boundary:** non-adjacent off-axis hits have no inferred normalization/tie-break.
  - **2×2:** geometry follows the entry above; variants stay unapproved until the price calculator/cost notes cover them (T09/T02).
  - **Compatibility:** coupled eight-direction movement does not change cardinal zone/Surge push/pull or silently replace Scaled's selected direction; Winged Dive uses the same centre-based retreat.
  - **Open/status:** prices, AP, access and unresolved attack-payload/multi-target ordering remain T02/T04/T06. This section approves neither a damage value nor a damage-for-distance exchange.

### Surge

- **Surge:** telegraphed delayed execution, pending marker/timer, zone shapes/placement but its own slot/lifecycle.
- **Concurrent casts:** multiple Surges may charge from different equipped skills or repeated casts of one instance when its [usage policy](#usage-and-repetition) permits; no monster-wide charging cap. Each cast creates its own marker/timer and pays its authored Battle-AP under the activation-consumption contract.
- **Placement/scheduling:** no overlap with any pending Surge; the first claims its squares. Queue timing and same-event phase-wise resolution, with no cast-order rule, use [Battle §2.2](gdd_battle.md#22-initiative-rules)/[§6.2](gdd_battle.md#62-surge-resolution-integration).
- **Aftermath:** optional, explicit, separately budgeted `board_changes`, never implied by Surge alone. Damage precedes authored ground aftermath. No new prices here; legality/evaluation/validation: §4/§5/§7.

**Minor Surge**

- **Footprint/charging:** resolved authored footprint and constraints under [§2](#2-data-oriented-skill-construction-kit); effective Reach to anchor unless an explicitly approved baseline profile says otherwise. Charging is visible and blocks movement through its squares.
- **Autonomy:** displacement/death of the caster does not cancel it. Detonation, including dead-caster timing, follows [Battle §2.2](gdd_battle.md#22-initiative-rules); in simple alternating 1v1 it follows the opponent's turn.
- **Recipients:** every monster on its squares, including allies/caster, under the profile's layer rules. Authored damage, zone shield/Hallowed reduction and the zero floor resolve under [Battle §6.1](gdd_battle.md#61-the-damage-law); props use [Battle §4.10–§4.11](gdd_battle.md#410-prop-catalogue-and-damage). Mountain handling is profile-specific below.
- **Afterwards:** only explicit, separately budgeted residue `board_changes` creates permanent ground ([Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed)), subject to the profile's height rules; otherwise no residue or repaint. Activation/repetition uses §2, authored AP §5.

**Major Surge**

- **Footprint/range:** requires an explicitly authored large-area profile, not a generic size/range override. AP/once-per-battle limit: [§5](#ap-efficiency-working-scale); access: [§1](#species-specific-and-signature-access).
- **Open:** legacy up-to-half-board/long-range wording needs a concrete definition (T02); Ancient versus Legendary Signature access remains T02/T32, not permission for either by inference.

- **Prop interface** *(user decision 2026-11-11)*: the three profiles carry **no prop-specific exceptions**. Ordinary Surge interception/damage/destruction: [Battle §4.10](gdd_battle.md#410-prop-catalogue-and-damage); the only applicable reaction tag is `heavy` ([Battle §4.11](gdd_battle.md#411-prop-reactions)).

- **Concrete profiles:** existing Surges specify **Eruption**, **Flood** or **Rift**, independent of theme. Their authored residue remains mandatory for those profiles despite the general model's optional residue.
- Timing alone neither requires these profiles nor authorizes new combinations; validate definitions under §7. These are mechanical profiles, not aspects/replacement elements; “Flood” is never a zone and need not resemble water.
- Existing damage/residue/prop/height effects:

| Type | Damage | Residue (permanent, level I; effects: [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed)) | Mountain |
|------|--------|-------------------------------|----------|
| **Eruption** | 3 | **Lava I** | hit normally, cannot change ground on a Mountain (**no residue** there; lava runs off), does not destroy it |
| **Flood** | 2 | **Thornbed I** | **can't reach it** (square blanked) |
| **Rift** | 3 | **Blight I** | **destroys it**; collapse damage and resulting ground reference the [Mountain-destruction contract](gdd_battle.md#47-ground--neutral-hazard-and-blessed), not a separate end-state rule here |

- **Push order:** damage-2/Thornbed also pushes struck monsters **1 square in the cast-fixed direction**. The order damage → push → residue follows the [payload resolution order](gdd_battle.md#62-surge-resolution-integration), so struck monsters are pushed before the residue is laid and do not enter it through this push; T07 only reviews the ground interactions.
- **Collapse state:** reference the [Mountain-destruction contract](gdd_battle.md#47-ground--neutral-hazard-and-blessed) for resulting ground, and [Battle §6.2](gdd_battle.md#62-surge-resolution-integration) for Surge damage, displacement and board operations including collapse damage/residue. This profile supplies no separate end-state rule.

A Mountain therefore offers profile-specific protection, not a universal Surge counter.

**Runtime counter menu** (authoring validation of live counters: §2/§4/§5/§7):

|            Counter             |                                                         How                                                          |
|--------------------------------|----------------------------------------------------------------------------------------------------------------------|
| **Leave**                      | move out of its squares before it fires — but mind any explicitly authored residue                                             |
| **Zone shield** | Place/level `shield` over its squares under the [protection contract](#4-effect-and-board-operation-contracts) |
| **Pick the height** | Create Mountain where legal; protection, residue exclusion or collapse depends on the profile table above |
| **Stand on Hallowed** | Use its Surge reduction and replacement contract in [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) |
| **Fly over it** | Existing Surges exclude air (Winged, Soul+) unless air recipients are authored ([Battle §4.3](gdd_battle.md#43-the-square-stack-zones--ground)); Mountain-attacker exception: [§4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) |
| **Props / debris** | Use the interception/destruction rules in [Battle §4.10](gdd_battle.md#410-prop-catalogue-and-damage), subject to the draft prop catalogue |
| **Answer with your own Surge** | race it — but you can't claim squares already held by a charging Surge                                               |
| **Control the tempo**          | slow / pull / push zones to steer where the target can stand; drain the caster's initiative to delay its next turn      |

### Movement

**Step** moves exactly one square; it has no skill upgrades. Kit/slot access: [§1](#1-the-kit); Battle-AP: [§5](#ap-efficiency-working-scale). Slotted movement uses the presets below and effective **Movement**, not Reach; Kin access remains §8.2.

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

- **Valuation:** [§5 Movement Costs](#movement-costs) owns package valuation and its distance/direction authoring constraint.
- Apply only the resolved, authorized movement variant; upgrade allowances and AP consequences belong to [§6](#6-slot-levels-development-replacement-and-upgrades), not a second battle upgrade rule
- Min 1 square for every movement skill. Step ignores slow and extra ground costs, but still requires a legal unblocked destination
- Ignoring path blockers permits no occupied landing. Walk processes entered cells; line/free/teleport only landing, with destination effects still applying.
- Glide grants no persistent flight; flight rules: [Battle §4.3](gdd_battle.md#43-the-square-stack-zones--ground); layer change/landing remain T09.

### Surge Constraints and Species Access

- **At most one twist:** one preview-readable extra rule, advantage priced under §5/§6. Represent it through placement/area/execution/effect/residue data and explicit profile constraints, not another schema or universal named-power menu.
- [Battle §2–§3](gdd_battle.md#2-battle-flow) remains binding; old damage/range candidates grant no exceptions/upgrades.

Preserve the existing structural restrictions when authoring or upgrading a constrained Surge:

| Authored constraint | Validation |
|---------------------|------------|
| Adjacent anchor | Anchor stays adjacent; an existing 4-cell footprint has no Size path. |
| Straight trail from an adjacent cell | Footprint starts adjacent and stays straight; only legal I2/I3 families/orientations. |
| Four cardinal neighbours of the caster | Excludes the caster cell; no Shape or Size path. This special footprint is not generic ranged targeting. |
| Enlarged footprint | Result stays within its profile/Kin cell cap; do not charge the same enlargement twice. AP consequences follow §6, not an automatic surcharge. |
| Pull after damage | Existing one-square cardinal displacement toward an anchor fixed at cast; [gdd_battle §6.5](gdd_battle.md#65-displacement). |

- **Species Surge:** with its own twist; kit/access: [§1](#1-the-kit), slot development: [§6](#6-slot-levels-development-replacement-and-upgrades). Ownership is access/authorship on the same definition, not a new kind. Concrete twists/roster placeholders still need design/validation (T10–T12).

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
| Surge | Values, recipients, ordinary prop interception and concrete prop/height exceptions: [Surge profile](#surge); the residue-free [Delayed Burst record](#slowing-zone-beast-jab-and-delayed-burst-area-and-strike-references) remains a separate draft, not balance approval | Bind delay, reductions, ground-layer eligibility and damage-before-authored-residue order to that profile and Battle §6.2. Do not substitute one profile's payload or exceptions for another's. |
| Hazard ground | Reference the concrete ground definition in [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) for value, recipients and caps | Bind its existing event under [Battle §2.4](gdd_battle.md#24-effect-timing-reference). Placement is `board_changes`, not immediate damage. |
| Collision / fall / debris | Reference [Battle §6.3](gdd_battle.md#63-collision-fall--debris) for event damage and recipient exceptions | Derived runtime consequences under [Battle §6.1](gdd_battle.md#61-the-damage-law), not free castable payloads. |

- **Damage permissions:** recipients and prop-exception scope follow the [Surge profiles](#surge); prop catalogue: [Battle §4.10](gdd_battle.md#410-prop-catalogue-and-damage). Major/baseline twist exceptions need authored definitions/access/usage; no new damage values here.
- **No zone damage, immediate ranged burst, new damage zones or generic direct unit-targeted damage.** Retired collision bonuses remain unapproved (T04), not collision-law exceptions. Slot-upgrade limits: [§6](#6-slot-levels-development-replacement-and-upgrades).

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
- **Zones:** occupants, exit/removal/expiry and replacement/opposition/levels follow [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites), not permanent cumulative deductions.
  - Level III does not authorize value 3 for every effect.
  - Definitions own `base`/`cap`; use [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites) for level-to-value computation, never unrestricted deltas.
  - Missing caps/scaling remain open.

| Existing definition | Meaning / existing authored values | Bounds and timing |
|---------------------|------------------------------------|-------------------|
| `slow` / `haste` | Movement −value / +value; retain authored values such as slow 1 | Bounds, timing and Step exception: [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites). Changes Movement-skill effectiveness, not AP cost, TPR or a permanent stat. |
| `drain_init` / `quicken` | Effective initiative −value / +value; examples include −1, −2 and +1 | Timing and order recalculation: [Battle §2.2](gdd_battle.md#22-initiative-rules). No immediate queue rewrite or arbitrary numeric interval. General effect-value caps/floors are not specified by [gdd_battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites) and remain open. |
| `drain_range` / `extend` | Effective Reach −value / +value; examples include −1, −2 and +1 | Floor: [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites). No independent per-skill range stat. Upper modifier/value caps require clarification, not extrapolation from progression ceilings. |

- **Timed Kin modifier:** Spirit Strike's [§8.1 effect](#81-strike-by-kin) is a distinct timed `stat_change`, not `while_inside`. Preserve its trigger/expiry; stacking, refresh and expiry reference [Battle §3.1](gdd_battle.md#31-effective-stats). This grants neither a free timing override on zone `drain_init` nor arbitrary timed Initiative/Reach/Movement permission.

- **Board sources:** Hearth/Umbra/Mountain modifiers reference [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed), Shrine [§4.10](gdd_battle.md#410-prop-catalogue-and-damage), aggregation [§3.1](gdd_battle.md#31-effective-stats). Keep their ground/prop/height conditions, not zone expiry or free source substitution.
- **Distinct contracts:** `shield` uses existing Surge reduction ([counter menu](#surge)), `mend` caps at max HP, `expose` is reserved without a zone. Reduction/healing/reserved definitions grant no generic stat edits.

- **Prohibitions:** no general temporary **TPR/AP/max-HP/movement-rule/flag** edits. Species-specific timed boosts need definitions, duration, limits and validation (§1), not arbitrary stat permission. Base-skill Reach debuffs/positional buffs are temporary battle effects, not cast-range upgrades; slow is not AP reduction. Slot-upgrade limits remain [§6](#6-slot-levels-development-replacement-and-upgrades).

**Persistent self buffs and passive rule modifiers — shared contracts**

- **Timed self state:** ordinary `stat_change`/applicable typed effect, self recipients and explicit lifetime; status is runtime state, not a skill kind. Reference [Battle §3.1](gdd_battle.md#31-effective-stats) for reapplication; specify source identity, removal and caster/recipient death dependencies. The [Focus record](#non-area-and-passive-coverage-references) is a structural draft, not generic timed-boost approval.
- **Passive rule/stat modifiers:** use continuous/conditional `stat_change` or typed **`rule_modifier`**. Each `rule_modifier` names the exact changed rule, scope (e.g. owner's shapes), operation/parameters, activation condition, lifetime, stacking and precedence. The [Adaptive record](#non-area-and-passive-coverage-references) (owner-scoped rotation) grants no arbitrary mutation.
- **Event-driven passives:** same effect/board contracts, explicit event source, recipient binding, repeat/recursion limits and order; undefined policies block content.
- **Extensions:** opaque `custom_effect`, per-skill callbacks and ownership permissions are incomplete definitions. Extend shared typed contracts/common costing; source-specific validation restricts content, not representable families.

**`shield` / protection — referenced reduction, not shield HP**

- Required data: protection definition and owning source/profile, permitted reduction/value source, protected recipients and damage sources, application condition, damage-event ordering, lifetime/consumption and stacking/cap references.
- Protection neither grants temporary HP nor edits a defense stat.
- Fixed source rules cannot be replaced by a generic immunity or damage-filter field.

| Existing definition/source | Recipients, trigger and lifetime | Ordering and caps |
|----------------------------|----------------------------------|-------------------|
| Zone `shield` | Recipients/application: [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites); shared zone lifetime: [Battle §4.5](gdd_battle.md#45-lifecycles) | Authored reduction base 2, cap 3; 1:1 Surge damage reduction under [Battle §6.1](gdd_battle.md#61-the-damage-law), levelled by recasting. No independent charges or effect timer. |
| **Nullify** *(draft, user 2026-11-11)* | Monster skills use a separately authored effect under [Battle §6.1's override/consumption/stacking contract](gdd_battle.md#61-the-damage-law); tamer Spirit Shield: [Overworld §6.4](gdd_overworld.md#64-tamer-skills) | Price far above value reduction ([§5 sketch](#price-completion-sketch-for-the-remaining-gaps), open T02); monster access needs its own authored definition and validation |
| Hallowed ground | Reference [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) for occupants, reduction and ground lifetime | Preserve the Surge profile's residue/height interaction; do not invent a separate hit-consumption rule. |

- **Protection exclusions:** retired Lava immunity/prop reinforcement/Strike reduction proposals need separate validation (T02/T04/T10), not generic `shield` options; `expose` stays reserved. Once-per-battle tamer protection ([gdd_overworld §6.4](gdd_overworld.md#64-tamer-skills)) grants no repeatable monster immunity; monster Nullify is its own authored effect above. Additional sources need authored definitions, not source substitution/default stacking (T02/T04/T20).

**`heal` — restore current HP only at an existing trigger**

- Required data: healing definition/source, authorized amount/value source, recipients, trigger, ordering, lifetime and cap/usage references.
- Healing never exceeds the recipient's existing max HP, changes max HP, revives a fallen monster or removes Injury.
- Definitions bind the event; persistence alone grants no heal on cast, per tick or extra activation.

| Existing definition/source | Recipients and trigger | Lifetime, order and caps |
|----------------------------|------------------------|--------------------------|
| Zone `mend` | Recipients, trigger and decided healing cap: [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites) (user decision 2026-11-10) | Shared zone lifetime; order: [Battle §2.4](gdd_battle.md#24-effect-timing-reference). Level-I price remains a draft ([§5](#zone-protection-and-healing-costs), T02). |
| Mossbed | Occupants, entry trigger/amount and unlimited re-entry: [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) (user decision 2026-11-10) | No additional placement or continuous heal; persistence grants no extra trigger. |

- **Healing boundaries:** no generic immediate/direct monster heal, ally-only zone or new repeat trigger. The proposed tamer heal ([gdd_overworld §6.4](gdd_overworld.md#64-tamer-skills)) is no monster definition. Pills heal **between battles**; expedition HP persists; Revival ends Injury, not battle HP loss (gdd_overworld §5.2/§6.4–6.6).
- Planned battle medicines/arrays need source, consumption, loadout and timing contracts (T18/T19), not generic `heal` permission. Economy/repeat-entry balance remain T07.

**Self `movement` — voluntary relocation of the caster**

- Required data: movement definition/source and authorized preset/exception, `recipients: self`, resolution trigger, origin and selected path/destination, distance source, path/landing/occupancy constraints, ordered traversal/entry events, action lifetime and usage/cap references.
- This is not forced `displacement`, unit relocation or prop movement.
- Resolve one movement action under [§3](#3-skill-execution-profiles); it creates no persistent movement permission.

- **Step/slotted movement:** resolve the authorized [Movement baseline](#movement) for traversal, blocking, ground costs, landing and distance source; AP baseline: [§5](#ap-efficiency-working-scale), kit: [§1](#1-the-kit).
- **Access:** §8.2 owns presets/foreign modes, body/stage restrictions. `path: teleport` grants no access without an authorized profile; free paths grant neither persistent flight nor air access. Winged air requires Soul; flight movement and air occupancy: [Battle §4.3](gdd_battle.md#43-the-square-stack-zones--ground), a Soul+ Winged stays on the air layer with no landing effect. Water/Swim is removed.
- **Custom modes/upgrades:** satisfy distance/direction pricing and access; fields are no player bypasses. [§6's candidate patches](#6-slot-levels-development-replacement-and-upgrades) grant no unrestricted path-mode, flight, teleport, extra action or range upgrade. Validate complete profile, entry order and destination preview; large-body/movement gaps remain T04/T09.

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
    - *Relocate contract (user-confirmed 2026-11-10; the source itself is not yet approved content):*
      - **Selection/destination:** move one selected eligible, non-heavy prop exactly one square orthogonally to a legal empty square ([Battle §4.9–§4.10](gdd_battle.md#49-props)); not onto monsters, props, edges or illegal ground.
      - **Execution:** check legality at execution ([Battle §6.2](gdd_battle.md#62-surge-resolution-integration)); an illegal move does nothing. Longer distances or paths need a separate authorized contract.
      - **Retained state/effects:** keep HP, tags and lifetime; no destruction aftermath, only entry/placement effects already defined by the prop type.
- **Prop destroy / remove**
  - Required data / source: Existing destruction/reaction definition and eligible prop; damage-derived destruction references the damage source, not a free deletion flag
  - Binding lifetime, ordering and limits: Reference the prop catalogue and aftermath in [Battle §4.10](gdd_battle.md#410-prop-catalogue-and-damage) and the destruction order in [Battle §6.2](gdd_battle.md#62-surge-resolution-integration).
    - Direct deletion or suppressed aftermath requires a separately approved source; removal does not imply the type's aftermath unless that source says so.
- **Cleanse**
  - Required data / source: Explicit source, exact affected layer/state, legal footprint/recipients and resulting state
  - Binding lifetime, ordering and limits: The existing Mountain-creation source clears non-Voidscar ground to Plain as above; no further monster Cleanse source exists (user decision 2026-11-10); a new one needs an explicit definition and validation and is parked under [Potential Extensions](temp_todo.md#potential-extensions-and-improvements).
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
- **Confirmed costing structure:** combine one-time use/availability costs with effect-extent costs.
  - **Use scope:** AP efficiency, free-anchor choice and complete Surge marker once at their applicable scope, not per footprint cell.
  - **Effect scope:** area effects per potential cell; non-area effects by authored package (e.g. movement). Duration, magnitude and other explicit dimensions stay in the formula. No generic activation surcharge per added effect or blanket area surcharge above cell pricing.
- **Shared component prices:** charge actual mechanics once, never redundant tags/flags or the same enlargement twice; no combination surcharge ([policy](#combination-policy-and-basic-surge-target)). Evaluate telegraphing/blocking/restrictions in context, without arbitrary negative credits or uncalibrated exceptions.
- **Confirmed decimal-point handling:** construction prices and totals may be decimal values. Do not round components or totals for budget comparison; compare the full calculated value with the ceiling. Display-only rounding must not change that result. This applies to internal skill construction points, not combat damage, Battle-AP, stats or other currencies; it changes neither existing prices nor ceilings.
- **Purpose:** construction costing screens for gross outliers and supports comparable skill power; numeric agreement does not guarantee equal strength, justify fitting every skill into a ceiling or replace interaction/balance tests.
- **Residue:** valuation uses [Ground and Board Costs](#ground-and-board-costs); payload permission follows the [Surge profile](#surge), not timing/damage alone.
- **Upper bound only:** no minimum, target band, exact spend or random budget; simpler skills may leave points unused. Unchanged skills get no automatic AP reduction; development at original AP and optional higher-AP extensions: [§6](#6-slot-levels-development-replacement-and-upgrades).
- **Passives:** no AP spend/free efficiency; explicitly price availability, conditions, event frequency and repeat/recursion exposure under the same total/slot ceiling, not a separate budget or zero-AP active tier. Initial availability reference below; other/event-driven patterns need separate evaluation.
- **Hard limits:** budgets never override damage caps, access, targeting, effect legality or profiles. Slot upgrade limits: [§6](#6-slot-levels-development-replacement-and-upgrades).
- **Calibration:** budgets/AP scale/components below are not validated balance. Unpriced components, combination reviews and tests remain temp_todo T02; all six [§11 records](#11-concrete-skill-records) remain incompletely validated.

| Slot level | Budget ceiling — preferred working draft |
|------------|------------------------------------------|
| 1 | 24 points (shared base budget) |
| 2 | 30 points (base +6) |
| 3 | 36 points (base +12) |

These working ceilings grant no balance/component-price approval, step prices or unlock conditions.

### Component Price Sheet

**Calibration drafts, not validated balance. All prices are construction points, not combat damage.** Cells are potential footprint cells, not guaranteed hits; a 2×2 body is struck once per use (§3); 2×2 variant prices remain T02/T09.

| Component | Price | Scope |
|-----------|-------|-------|
| One-shot damage | damage × cells × 2 | One damage event; scales per potential cell, not a flat per-use fee. Area included; no second blanket area charge |
| Immediate timing | 100% of damage base price | No blanket surcharge |
| Telegraphed, avoidable Surge timing | 50% of damage base price | Discount on damage only, not other components |
| Ground + air damage coverage | +2 per damage effect | Once, not per cell; authorized sources only |
| Free board anchor within Reach, no LOS | +2 | Full board-selection component; combined property, not two charges |
| Selected board anchor restricted to cells adjacent to caster | 1 per use | Authorized sources only; values fewer placement options, not lower effect strength |
| Self/body/event binding without independent target choice | 0 selection points | Direction/effect coverage remain separately priced |
| Strike footprint-direction choice | +2 | Only when selection changes hit cells |
| Strike distant hit cells | +2 per distant cell | Outside adjacent eight-cell ring |
| Fixed non-Strike shape alone | No blanket surcharge | Additional advantages/combinations still count |
| Slow zone | rate: [Zone, Protection and Healing Costs](#zone-protection-and-healing-costs) | Existing base 1/cap 2 contract |
| Charging Surge blocking | +1 per complete marker | Not per cell; existing exceptions retained |
| Ordinary prop damage / derived destruction | No generic surcharge for now | Relevant offensive sources only; special advantages separate |
| Authorized extra on-hit prop damage | 1 per additional prop HP damage per potential affected cell | Above included ordinary prop damage; no automatic timing discount or duplicate Kin/generic damage charge |
| Optional residue / other board operations | Ground/board price sheet below | Never implied by Surge timing/damage |

- **Geometry:** retain placement/occupancy/fixed orientation; adjacent-anchor selection uses the [shared standard](#shared-valuation-standards); other unresolved targeting variants remain unpriced. Symmetric Strikes pay no direction fee when cells stay unchanged. A distant 1×1 Strike cell satisfies `max(abs(dx), abs(dy)) > 1`, not Manhattan Reach.
- Equal-size/equal-mechanics non-Strike shapes start equally priced; review special advantages such as chokepoints. No rotation, range upgrade or new placement permission.

### Shared Valuation Standards

- **User-selected working standards, not validated balance or new mechanic permissions.** These standards use the [§2 evaluation bindings](#evaluation-contract--one-definition-one-calculation) and existing [§4 contracts](#4-effect-and-board-operation-contracts).
- Rates are comparison anchors, not measured value or prices reverse-engineered from a particular skill's budget. Arithmetic references follow the selected rates without content/development approval.

**Timing/avoidability:** damage uses the [component-sheet rates](#component-price-sheet); qualifying one-shot displacement uses the [displacement timing row](#zone-protection-and-healing-costs).

- **Qualifying conditions:** the authorized one-shot displacement is telegraphed, fixed to board cells and avoidable by leaving before resolution. No tracking, repetition or enhanced blocking is covered.
- The rate is condition-based, independent of profile name, not a profile-specific exception or permission for additional push/pull sources.

- All other components retain their own full rate unless a separately reviewed shared rate explicitly applies. No whole-skill multiplier, discount to AP efficiency/selection/marker, or discount inferred merely from a later application event.
- Value delayed permanent ground at its immediate package rate: it still creates the persistent state. No delay discount is applied to that package. Test whether this overvalues lost immediate board control; selection is not balance validation.
- Lifetime is already included in round-based formulas or permanent packages. Do not apply the one-shot timing factor to a whole zone, passive or future ground triggers. Undefined timing/avoidability remains incomplete, not assumed to qualify.

**Selection:** use the [component-sheet selection rows](#component-price-sheet), once for the resolved choice.

- **Bindings:** fixed body footprints and trails are not automatically adjacent-anchor casts. Selection prices grant no cast-range upgrade.
- **Unpriced contracts:** source-defined non-offensive unit utility needs its own selection contract/rate, not a retired direct-Shove fee. Undefined LOS, homing or new ground/air coverage has no generic rate or assumed discount; resolve the owning contracts first.
- **Excluded:** ally-only/enemy-only area filters are barred by the [square-control contract](#2-data-oriented-skill-construction-kit), not missing purchasable components.

Movement, passive and prop standards are maintained only in their owning sections below. Package replacements are alternatives, never extra fees on top of an unchanged package. Unrelated content drafts and the separate Mountain-price candidate remain unapproved.

### Strike Costs

**Damage per struck monster and shapes: [§8.1](#81-strike-by-kin).** Calibration drafts, not proof of equal strength; Spirit/Swarm/Ancient were designer-authored under the instruction to complete Strikes without individual approvals.

Effects are defined only in [§8.1](#81-strike-by-kin); this table prices their bound packages.

| Kin package | Construction-point component |
|-------------|------------------------------|
| Beast | 0 |
| Winged | +3 once per use, not per target |
| Scaled | +2 per potentially affected hit cell; existing push-direction selection included |
| Spirit | +2 per potentially affected hit cell |
| Swarm | +2 per potentially affected hit cell; provisional pending prop redesign |
| Ancient | +2 per potentially affected hit cell; provisional pending height/board resolution |

- **Package scope:** Scaled's included push-direction choice is distinct from footprint direction; charge neither twice. Winged's retreat component is once/use, not per target. Effect permissions/exclusions: [§8.1](#81-strike-by-kin); collision/fall/entry remain referenced runtime consequences.
- **Unresolved:** Winged multi-target reference/ties/legal retreat, Scaled follows the payload resolution order; 2×2/layer pricing remains T02/T09. No blanket damage-plus-Kin surcharge; review specific combinations.
- **Body-relative variant cost drafts** *(draft, not validated or approved content)*: 1×1 Jab-shaped arithmetic references at existing 2 Battle-AP (6 efficiency points). Movement-only AP is not otherwise decided; these checks use Jab AP.
  - **Existing anchors, not new rates:** displacement from [Zone, Protection and Healing Costs](#zone-protection-and-healing-costs), retreat from the Winged package above, direction/coverage from the [component sheet](#component-price-sheet).
  - Displacement includes direction; retreat is unconditional and once/use, never hit-chance discounted. Direction is charged only when hit cells change; ground/air coverage applies only to damage effects.

| Variant (Kin) | Calculation | Total |
|---|---|---:|
| Damage + push (Scaled) | damage 4 + direction 2 + ground/air 2 + push 2 + AP efficiency 6 | 16 |
| Push only, no damage (Scaled) | direction 2 + push 2 + AP efficiency 6 (no damage, so no ground/air coverage) | 10 |
| Damage + retreat (Winged) | damage 4 + direction 2 + ground/air 2 + retreat 3 + AP efficiency 6 | 17 |
| Retreat only, no damage, with hit cell (Winged) | direction 2 + retreat 3 + AP efficiency 6 | 11 |

- **Reading:** damage + push/retreat totals equal the existing Scaled/Winged Jab totals above because the rates are the same anchors; the new geometry adds no points. Movement-only variants are cheaper only because the absent damage is not paid for. All fit slot level 1 (24) numerically. This is arithmetic, not balance, and grants no unlock.
- **Multi-cell push drafts** *(draft calculations)*: apply the displacement anchor to **adjacent** hit cells only; only those cells can move a recipient. Other components use the formula below (Beast values from the table).
  - **Damage + push:** Jab 16, Pincer 19, Arc 25, Whirl 29, Cross 29, Storm 51 equal the Scaled column because all hit cells are adjacent. Thrust 19 (Scaled 21), Cleave 40 (46), Long Whirl/Long Cross 50 (58) omit push on distant cells.
  - **Movement-only:** omit damage 4 per cell and ground/air 2. Budget fit follows the Beast/Scaled findings, not a recommendation.
- **Multi-cell retreat drafts** *(draft)*: retreat is 3 once per use, so damage + retreat equals the Winged column above for qualifying shapes: Jab 17, Thrust 20, Diagonal Thrust 20, Arc 22, cardinal Cleave 37. Pincer, Whirl, Cross, Storm and Long Whirl/Cross have no retreat variant (their existing Winged Strikes are unchanged). Retreat-only is priced only for the 1-cell Jab shape (11 above); damage-free multi-cell shapes are not priced.
- **Open:** 2×2/layers need T09; Cleave is cardinal-only (decided); hit multiplicity for retreat is decided as once per use. The [price calculator](../tools/simulator/pricing.py) prices them only through the Scaled/Winged package rows.

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
- **Geometry:** Arc uses the adjacent row/wedge; Cleave the illustrated cardinal two rows (three adjacent/three distant cells). Cleave is selectable in the 4 straight directions only (user decision 2026-11-11); no diagonal Cleave exists or is inferred. Symmetric forms pay no redundant direction selector.
- **Scope:** paper calculation, not legal-content catalogue, completed upgrade path or engine test.
- **Budget findings (24/30/36):** all Jabs fit level 1 numerically; per-cell-Kin Arc/Whirl/Cross need at least level 2. Only Beast Storm/cardinal Cleave fit 36; other variants and all Long Whirl/Long Cross exceed it.
- **Legacy reconciliation:** T02/T05/T06 after broader calibration; preserve neither content by automatic budget/AP changes, damage reductions, waived Kin costs nor over-budget approvals. Numeric fit grants no slot/progression access; development policy: [§6](#6-slot-levels-development-replacement-and-upgrades).

### Movement Costs

**Working drafts:** price whole traversal presets with distance/direction restrictions, not travelled cells or Movement (already stat-budgeted). Run's 6-point component is selected; other modes are designer calibration drafts under the instruction to price all modes. Existing 2 battle AP add 6 efficiency points.

- **Package authoring constraint:** every restriction a preset drops is paid for in distance or direction (Leap: straight line only); new modes follow it.

| Preset | Profile points | AP-efficiency points | Total construction points | Note (restrictions: [§3 presets](#movement)) |
|--------|----------------|----------------------|---------------------------|-----------------------------------------|
| Run | 6 | 6 | 12 | Baseline walk |
| Leap | 8 | 6 | 14 | — |
| Glide | 8 | 6 | 14 | — |
| Burrow | 8 | 6 | 14 | — |
| Phase | 7 | 6 | 13 | — |
| Blink | 10 | 6 | 16 | — |
| Step | Not budgeted | Not applicable | Not applicable | [Movement baseline](#movement); kit: §1, Battle-AP: table below |

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
| Self Initiative +1, 2 rounds, proposed 1 AP | Rate 4 per +1/round; reference: 4 × 1 magnitude × 2 rounds = 8 | 12 AP efficiency | 0 | 20 |
| Owner may rotate its eligible fixed tetris shapes while equipped | 6 for rotation permission | 12 passive availability | 0 | 18 |

- **Self Initiative scope:** no artificial area/anchor/ground-air-attack fee; unit rate and arithmetic reference are in the table.
  - Assumes draft refresh without magnitude stacking; normal AP-paid refresh adds no blanket surcharge.
  - Not a rate for arbitrary stats, targeted/team buffs or cumulative Initiative.
  - Round-end duration/normal round queue recalculation apply; stacking and expiry follow Battle §3.1; removal/death/exact termination of the Focus record remain open.
  - Same draft rate can cost longer duration, not approve upgrades.
- **Passive availability scope:** the table's initial premium covers continuously equipped, self-scoped boolean permission (owner rotation), replacing active efficiency; mechanics are priced separately. Neither 0-AP active nor extra budget. Conditions grant no automatic discount; event-driven/repeating/proccing/team-wide/other patterns need frequency/recursion/combination review before pricing/approval.
- **Rotation scope:** prices the owner's full equipped permission, not each cast; the [Adaptive record](#non-area-and-passive-coverage-references) defines its limits. Test equipped shapes, symmetry, action frequency, fixed-shape kits and placement options; equal value across kits is not guaranteed.
- **Validation:** both fit 24 numerically, not unlocks/full paths. Test self Initiative against tempo/queue changes and paid refresh. Other passive mechanics/combined statuses need explicit follow-through, not unused-point-funded free additions.

**User-selected working standard, unvalidated — conditional self-scoped boolean permission:**

- **Eligibility/price:** only with resolved lifetime, reevaluation, stacking and removal contracts; use the table's continuous-self availability rate, **no condition discount** or additional numeric price. Mechanical permission cost stays separate. This conservative-upper-bound hypothesis accounts for deliberately maintainable conditions.
- **Boundary:** neither arbitrary stat-passive pricing nor a universal rotation/rule-modifier rate. Event-driven combinations use the [availability table](#availability-by-activation-and-usage) only with a selected rate and resolved contracts; repeatable event-driven and team-wide availability remain unpriced. Never multiply invented expected trigger counts by an active-skill price.

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
- **Instances and safety:** evaluate equipped copies independently under [§2's allowance contract](#usage-and-repetition). This grants no automatic stacking of persistent states; stacking, recipient bounds, order, recursive interactions and owner removal must be resolved before admitting content. The selected availability charge alone does not certify a combination as safe.
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
| Zone mend | 3 × V × C × R with V = 1 (level-I healing) | Level II (healing 2) comes from AP-paid recasting, as for Slow/Quicken *(user decision 2026-11-11, draft)*; repeat balance tested in T07/T13 |
| expose | Not priced / reserved | No approved zone; no damage-boost permission |

- **Displacement timing:** only the shared standard's qualifying one-shot displacement gets the reduction. Existing immediate spatial, Scaled Strike and zone effects retain their own rates/contracts and distances; delay alone is insufficient.
- Not applicable to repeated/tracking/unavoidable/enhanced displacement. Test the entry-hazard combination; budget fit does not validate the reduced rate.

- **Selection:** ranged zones use the [free-board-anchor row](#component-price-sheet) once, with no second direction/anchor-binding charge. Body-relative Shove is not a ranged unit-selection source; calibrate its spatial components through the new variant contract rather than retaining a direct-target selection fee.
- **Repetition/values:** normal AP-paid zone levelling/refresh included, extending Slow policy for calibration only. Resolve magnitude/cap/level formulas; no stronger values, heal scaling, extra triggers or ally-only filters. Test each effect's repetition independently.
- **Healing/protection:** retain [§4 source contracts](#4-effect-and-board-operation-contracts), including max HP and decided `mend`/Mossbed triggers/scaling (T07); no direct heal, revival, Injury cure, general immunity, tamer protection or item permission.
  - **Runtime/price boundary:** stacking/order use [Battle §3.1](gdd_battle.md#31-effective-stats)/[§6.2](gdd_battle.md#62-surge-resolution-integration) (decided). The table's level-I `mend` price is unvalidated; prices set neither caps nor unbounded-healing permission.

### Ground and Board Costs

- **Permanent-state packages:** fixed price per created cell, not invented duration/future-trigger counts.
- Includes existing occupant effects, ordinary placement/replacement and persistence; no duplicate instant-damage/heal/zone-modifier charge for future effects. Entry/start/end events stay unchanged.
- Level-I hazards include normal AP-paid recasts to existing II, not stronger damage/level-II-start upgrades.

| Existing state / operation | Mechanical construction points | Included / unresolved scope |
|----------------------------|--------------------------------|-----------------------------|
| Lava I / Thornbed I / Blight I, immediate cast or delayed aftermath | 4 × C | Permanent hazard package; no delay discount; trigger risks and loss of immediate control to test |
| Hearth / Umbra | 4 × C | Existing occupant modifiers, both sides: [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) |
| Mossbed | 6 × C | Existing unlimited-entry healing contract ([Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed), user decision 2026-11-10); price provisional |
| Hallowed | 4 × C | Existing Surge reduction/replacement contract: [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) |
| Mountain creation with coupled Plain reset | 5 × C | Mountain plus its existing non-Voidscar → Plain cleanse, one package |
| Mountain-destruction operation (final ground: [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed)) | 2 × C | Source-specific capability; environmental collapse follows [Battle §6.1](gdd_battle.md#61-the-damage-law), not priced as skill damage. Earlier draft price, not re-derived |
| Create prop (catalogue entry) | Draft: see [prop creation drafts](#prop-creation-price-drafts) | Per created prop; open items listed there; a missing price never means zero |
| Relocate eligible prop (one square, orthogonal; contract in §4) | 6 per moved prop | Provisional component; contract confirmed, price not recalibrated. The [one-shot displacement rate](#zone-protection-and-healing-costs) plus placement legality does not yet justify a change |
| Direct Rubble creation, direct prop deletion | Not priced / not authorized by this table | Need explicit source/contract |
| Voidscar alteration | Forbidden | No budget bypass |

#### Prop creation price drafts

**Working draft derived from existing rates, not validated balance and not a content approval (T02, tests T13).** Price per created prop = base + extras; add anchor and AP efficiency once per cast. Damage/push aftermath, occurring only on destruction, uses the table's telegraphed/avoidable derivations because it is previewed and avoidable. Aftermath ground uses the permanent-state rate for one cell.

| Component | Draft price | Derived from |
|-----------|-------------|--------------|
| Base prop (solid, 1–2 HP) | 4 | former Wall/Tree package |
| Sturdy prop (3 HP and/or `heavy`) | 6 | former Rock package |
| Air layer instead of ground | +2 | ground/air coverage component |
| Both layers | +2 on top of base | same component, once |
| Aftermath damage | 1 per potentially hit square | Derived from [one-shot damage and telegraphed timing](#component-price-sheet) |
| Aftermath push (1 square) | 1 per potentially hit square | shared push timing rate |
| Aftermath ground | [Permanent-state rate of the ground type](#ground-and-board-costs); Plain and Rubble free | Ground package table; no duplicate future-effect charge |
| Beam spawn | 4 per potential Beam at 50 % = 2 per cardinal square | base prop, conditional |
| Aura (orthogonal neighbours) | 4 per aura prop (all four auras) | former Shrine package 8 minus base 4 |

| Prop | Draft total |
|------|-------------|
| Stone Lion | 6 |
| Clay Urn (8 squares) | 4 + 8 = 12 |
| Bamboo Stand (4 squares) | 4 + 4 = 8 |
| Paper Lantern | 4 + 4 = 8 |
| Peach Tree | 4 + 6 = 10 |
| Ancestor Tablet | 4 + 4 = 8 |
| Bronze Gong (8 squares) | 4 + 8 = 12 |
| Pagoda Column (4 Beams) | 6 + 8 = 14 |
| Beam | not creatable separately |
| Shrine / Totem / Banner / Wardstone | 4 + 4 = 8 each |
| Wind Chime / Thunder Cloud (8 squares) / Gale Banner | 4 + 2 = 6 / 4 + 2 + 8 = 14 / 4 + 2 + 4 = 10 |
| Pagoda Bridge | 6 + 2 = 8 |

- **Open:** the aura price (4) is far below the matching ground package (4 per square, 16 for four neighbours) and must be tested for a prop-versus-zone choice (T13); whether aftermath on allies deserves any discount; the Beam spawn at 50 % is an analogy, not a derived rate.

#### Price completion sketch for the remaining gaps

**Working sketch derived only from existing rates (user asked for a complete draft on 2026-11-11 without further questions); not validated balance, no content approval, tests T13.** It fills the gaps named in T02 so that affected records can be evaluated; every row may change after tests.

| Gap | Draft price | Derivation |
|-----|-------------|------------|
| Monster **Nullify** ([effect contract](#4-effect-and-board-operation-contracts)) | 9 per protected monster | zone `shield` rate 1 × V × C × R with V = 3 (the Surge damage cap), one cell, one round = 3, times a ×3 premium because it ignores all later damage increases and all values |
| **Level-II residue start** (hazard ground starts at level II) | 8 per cell (twice the level-I hazard package 4) | hazard damage equals level, so the package scales linearly; Hearth/Umbra/blessed ground have no levels and are unaffected |
| Zone **`mend`** | [Zone price table](#zone-protection-and-healing-costs) | Level-I basis like Slow/Quicken, levelling by AP-paid recasting *(user decision 2026-11-11, draft)*; discarded cap-based comparison below |
| **Air recipients** for a zone effect or Surge damage | [Ground + air coverage component](#component-price-sheet), once per effect | Same component, applied by analogy to non-damage effects |
| **Relocate** a prop one square | [Ground/board price table](#ground-and-board-costs), unchanged | Provisional component and retained-price rationale are owned there |
| **2×2 body variants** (attacker or target) | +0 over the 1×1 reference | geometry mapping only; footprint is already priced per potential cell and a 2×2 is struck once per use |
| Direct Rubble creation, direct prop deletion, Voidscar alteration | still not authorized | need an explicit source and contract |
| Repeatable or team-wide event availability | still unpriced | event valuation remains T02/T04; no automatic round cap |

- **Reading:** Nullify at 9 for one monster compares with zone shield V = 3 over three cells for one round (also 9) and is therefore not cheap; test with Spirit Shield-like loadouts in T13.
- **Discarded `mend` comparison:** the earlier cap-based variant (`6 × C × R`; 3 cells, 2 rounds = 50 points, above every slot ceiling) is dropped, not an alternative price.
- Tamer skills have no construction points; their definitions and once-per-battle loadout usage are owned by [Overworld §6.4](gdd_overworld.md#64-tamer-skills).

- **Props:** prices grant no catalogue/access; retain empty-cell, `heavy` and interaction restrictions. Ordinary destruction has no generic surcharge; a prop's aftermath is part of its type, not a second authored operation, and never destroys Mountains.

**User-selected working standard, unvalidated — extra on-hit prop damage:** use the [component-sheet row](#component-price-sheet) only for an existing authorized effect above its source's included ordinary prop damage.

- **Scope:** a narrower damage channel than monster damage, preserving the current extra-prop-damage valuation scale; not a monster-damage discount. Exact prop eligibility, interception and mutually exclusive outcomes bind the calculation.
- **Inclusions:** the rate grants no duplicate Kin-package/generic-damage charge or automatic timing discount.

No source currently has a prop reaction or extra prop damage, so this standard has no user. A future reaction that replaces ordinary damage is evaluated as complete legal outcomes under the conditional-outcome draft, not damage plus an invented surcharge. Missing special-reaction valuation keeps the affected package incomplete.

- **Cast fees/residue:** standalone ground/props add the [free-board-anchor component](#component-price-sheet) and [AP efficiency](#ap-efficiency-working-scale) once. Residue means authored Surge **ground change, not prop creation**; [Surge profiles](#surge) own payloads/exceptions. Delayed hazard aftermath (rate in the table above) adds no second anchor/AP and gets no further 50% damage discount; immediate ground keeps its own rate. Source-specific height/prop exclusions remain binding.

**Conditional-outcome costing — designer working draft:**
- Price the most expensive explicitly mutually exclusive legal outcome; sum coexisting components within it. Maximize over legal board states for the authored skill, not the cast-time board; no probability weights/best-case discounts.
- Sum per-cell maxima only if those outcomes can coexist across the footprint; count shared activation/anchor/marker once. Missing prices/unresolved order block a complete maximum, not zero-cost branches.
- Valuation grants neither runtime exclusivity nor new effects. Collapse/residue outcomes reference [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed); pricing charges both capabilities additively, not a maximum. This specifies costing, not a runtime end state.

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

- **Collapse/hazard:** include the explicit destruction capability additively with residue under the [Mountain-destruction rule](gdd_battle.md#47-ground--neutral-hazard-and-blessed). The priced subset is `15 + (3 + 2 + 4) × cells`: **33/42** for two/three cells. Environmental collapse damage is not separately priced as skill damage; the runtime ground outcome does not waive the destruction capability's price.
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

**User-selected authoring-time working standard, not validated balance or a new skill assignment.** Read the authored [repetition policy](#usage-and-repetition) from the same definition. Apply the table only to active AP efficiency; mechanical, selection and marker components stay unchanged. The factor is a conservative test anchor, not a measured frequency ratio or whole-skill discount.

| Active repetition policy | AP-efficiency component |
|--------------------------|-------------------------|
| Repeatable | Full rate |
| Effective once per global round | 75% of the AP-efficiency component, subject to the guard below |

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
| Step | 2 AP |
| Slotted movement | 2 AP |
| Zone / ordinary ground / prop / direct | 1 AP |
| Minor Surge | 1 AP baseline per cast; repetition follows the equipped instance's usage policy |
| Strike | Selected authored shape's AP: [§8.1](#81-strike-by-kin) |
| Blessing ground | 2 AP; not the ordinary-ground default |
| Major Surge | 2 AP; once per battle; access under §1 / [Monsters §5.3](gdd_monsters.md#53-monster-progression-the-18-steps) |

- **Baseline scope:** existing prices, not new values/final costs for every combination. Species-specific skills retain applicable profile costs pending calibration; “Unique = 1 AP, may set its own” grants neither a category nor unrestricted override. Explicitly validate retained exceptions (T02); optional higher-cost upgrades follow §6, not unconfirmed blanket Twist/Size surcharges.
- Tamer/planned medicine/array source-loadout contracts remain gdd_overworld §6.4–§6.6/[gdd_battle §5.2](gdd_battle.md#52-tamer-skills-and-battle-loadout); monster-action prices assign none of their costs.

**Preserved authoring constraints:** area/lifetime contracts are owned by [§2](#common-field-structure), the zone-duration baseline by [§3](#profile-overview), live-counter validation by [§7](#7-validation-and-concrete-skill-records). The [Slowing Zone record](#slowing-zone-beast-jab-and-delayed-burst-area-and-strike-references) remains an unvalidated combination.

## 6. Slot Levels, Development, Replacement and Upgrades

**Confirmed: permanent slot development**, gained only at **advancement steps** ([Monsters §5.3](gdd_monsters.md#53-monster-progression-the-18-steps)): a stage breakthrough or listed later sub-tier step offers the individual monster the option to develop one skill slot.

- **Currency boundary:** no separate experience/EP currency, spending outside an advancement, physical evolution or separate player skill-point currency. Construction/blueprint points are internal authoring data, neither intermediate spendable budget nor Overworld Blueprint items.
- **Ownership/choice:** a development step develops one slot on one monster, not its equipped skill or species globally.
  - Each development step directly grants a skill-specific upgrade choice, without a separate per-skill step count.
  - Designers use §2–§7 for finished skills/upgrades, internal budgeting/AP pricing; players select authored options, not arbitrary components.
  - Equipped skills define legal upgrades/prerequisites/exclusions; slot progress determines available development, not simultaneous access to all upgrades.
- **Replacement:** outside expeditions, select an unlocked species learnable-list skill using a valuable **relearning pill**.
  - **Progress:** preserve all purchased slot progress; reselect legal upgrades within it without another development step, not a literal transfer of old effects.
  - **Logistics:** pill acquisition/recipe/tier/price/overworld AP remain T05/T16/T31.
- **Levels 1–3:** increasing construction ceilings (§5), no separate skill ratings/ranks. How steps map to levels, unlocks, intermediate steps, total supply (including Normal's two steps) and whether an unused step can be deferred remain undecided (T05).
- **Open:** pill use for same-skill upgrade reselection; passive-only slot development and active/passive replacement rules are required before implementation.

**Confirmed construction budget and AP policy**

**Superseded prices and legacy reconciliation:**

- The former per-skill prices (1 EP for Shape/Twist/Value/Swap, 2 EP for Size) are superseded; no EP currency exists.
- Legacy “Shape always free”, blanket “Twist = 2 AP”, “Size adds 1 AP”, Twist-plus-Size totals and double-charging an already enlarged footprint remain T02/T05 reconciliation work; none overrides the confirmed policy below.

- **Budget:** ceilings and AP efficiency: [§5](#5-construction-points-and-ap-efficiency); balance remains open (temp_todo T02/T05).
- **AP policy:** bounded improvements and a complete path at original AP for every skill. Larger extensions may optionally cost more AP, shown before selection, never mandatory for slot development.
- **Patches:** authorized fields of the same [§2 definition](#2-data-oriented-skill-construction-kit), validated under [§7](#7-validation-and-concrete-skill-records), not a parallel model; area, shape/orientation, duration, movement/displacement or explicitly designed secondary effects, within skill limits/prerequisites.
- **Limits:** no direct-damage, AP-reduction or cast-range upgrades; existing Strike/Surge/ground damage caps hold. More cells/duration may increase total impact and still require budgeting/validation. Budget guidelines bypass no hard caps/legal combinations; reconcile legacy blanket AP surcharges, never apply automatically.

**Candidate catalogue, not final step prices/unlocks.** Cast range is excluded; slot development supersedes old per-skill evolution counts and prices. Review concrete offers/AP effects under temp_todo T02/T05.

|           Family           |                                       What changes                                      |                                                                                         Rules                                                                                         |
|----------------------------|-----------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Shape** | Other shape family or orientation, **same cell count** | I2 orientation, I3↔L3 or legal 4-cell families; Strike swaps same-size shapes from §8.1. Family must respect Kin and twist constraints; shapes remain fixed in battle. Legacy ‘always free’ grants no free development step or respec; costs remain T05. |
| **Size** | **+1 cell** within the owning profile's cap; Strike selects a larger §8.1 shape | Ordinary tetris max 4; Swarm Surge cannot enlarge. A larger Strike uses its existing shape AP price as an optional higher-cost branch, never the only development path. The old automatic Surge +1 AP is unconfirmed; requirements, step costs and optional AP effects remain T02/T05. |
| **Twist** *(Surge only)* | Replace/add an authored extra rule; not on a Species Surge | At most one; preserve §3 constraints and exclude damage/range increases, including legacy delayed-damage or extended-range candidates. Validate under the confirmed AP policy. |
| **Small value** | Zones: `duration` +1 round total per skill. Movement: one flag flip total, turning off one restriction or lowering its distance penalty by 1 (§3) | Bounded candidates, not free upgrades. No damage increase or level-II start; separate level-II candidates below. |

- **Separate level-II candidates:** the level-II-start passive (§9) remains a separate candidate, not approved through this table. A **residue level-II start** is a separate upgrade candidate *(user decision 2026-11-11)*: it needs its own price (T02) and board-fill tests (T13) before becoming a patch; until then residue starts at level I.

- **Shared process:** authorize patches to [§2](#2-data-oriented-skill-construction-kit), validate through [§7](#7-validation-and-concrete-skill-records), including species-specific/Signature (§1); no per-kind schema. Replacement is never a patch and follows this section's opening rules. Legacy named examples/evolution counts are retired pending T02/T05/T10.
- **Identity:** different slot-development choices within one species yield different playstyles without new art. Shaped skills retain **one shape/fixed orientation**, except existing rotation permissions; Surges have **at most one, not mandatory, twist**. Non-area skills gain no footprint. Battle rules remain valid; preview the resolved variant normally.
- **Granting/logistics:** advancement grants above are not bought or focused-XP Train rewards. Choice location/timing and day AP: [Overworld §6.3.2](gdd_overworld.md#632-permanent-skill-slot-development-confirmed).
  - **Open supply/resets:** step supply ([Monsters §5.1](gdd_monsters.md#51-monster-rarity)/[§5.3](gdd_monsters.md#53-monster-progression-the-18-steps)) remains unvalidated; reversal/transfer/same-skill reselection remain [temp_todo.md](temp_todo.md) T05, not free resets.
- **Validation:** enforce candidate limits, owning [Surge constraints](#surge-constraints-and-species-access), Kin access ([Monsters §3](gdd_monsters.md#3-kins)) and [§7](#7-validation-and-concrete-skill-records). The development UI offers only passing paths. Unsupported 2×2/spatial cases stay T09; slot development grants no exceptions/air access.

## 7. Validation and Concrete Skill Records

- **Author:** legal profile → [§2 schema](#2-data-oriented-skill-construction-kit) resolved through definitions → access/interactions/budget. Footprints/effect definitions are data references, not fundamental skill blueprints.
- **Validate complete records, not components:** selection → placement → footprint → recipients; execution → effect events/order → lifetime; then Kin/species access, usage limits/cost. Preview cells, recipients, displacement landings and board reactions; missing rules block content.
- **Content status:** former named example table retired; §10 roster names are unvalidated ideas, not definitions/permissions. Rebuild/extend records only after central [temp_todo.md](temp_todo.md) decisions, especially T02/T04/T05/T07/T09/T10.

- **Surge counter check:** at least three live counters are required (leaving, protection, height, air, props or tempo as applicable); a nominal counter prevented by the actual profile does not count.
- **Concrete records:** [§11](#11-concrete-skill-records); this chapter holds only validation rules.

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
|       6 |  5 | the 3 squares in front of `M` and the 3 behind those (4 straight directions only, *user decision 2026-11-11*) | **Cleave**                             |
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

**Offsets per orientation** *(derived from the table above, adds no shape; origin `M = (0,0)`, direction `d = (dx, dy)`, `d⊥ = (|dy|, |dx|)` for straight `d`)*:

| Shape | Legal directions | Hit offsets |
|-------|------------------|-------------|
| Jab | 8 | `d` |
| Thrust | 4 straight | `d`, `2d` |
| Diagonal Thrust | 4 diagonal | `d`, `2d` |
| Pincer | 8 | `d`, `−d` |
| Arc | 4 straight / 4 diagonal | straight: `d`, `d + d⊥`, `d − d⊥`; diagonal: `(dx,0)`, `d`, `(0,dy)` |
| Whirl / Cross / Storm | symmetric | the 4 neighbours / the 4 diagonals / all 8 |
| Cleave | 4 straight (decided) | `k·d⊥ + d` and `k·d⊥ + 2d` for `k ∈ {−1, 0, 1}` |
| Long Whirl / Long Cross | symmetric | `c` and `2c` for each of the 4 neighbours / 4 diagonals `c` |

**Self-retreat cell for the body-relative variants** *(draft illustration of the rule in [§3](#body-relative-damage-and-movement-variants))*: `R` is the single cell the attacker moves to, opposite the centre of the hit shape. Only shapes whose centre lies on one of the eight directions have it; the cell is checked and entered as defined in §3.

```
       x               x                                   x x x
x      x             x          x x x      x x             x x x
M      M           M              M        M x               M
R      R         R                R      R                   R

Jab    Thrust    Diag Thrust    Arc      Arc (diagonal)    Cleave
```

- **No retreat cell:** Pincer, Whirl, Cross, Storm, Long Whirl and Long Cross (centre is the attacker itself); Cleave is cardinal-only, like Thrust (its diagonal counterpart would be a separate shape): a diagonal Cleave does not exist (user decision 2026-11-11).

- **AP decides when:** AP 2 is the ceiling until Core, so Qi and Foundation Strikes are all Jabs and differ by Kin twist only. AP 3 opens at Core, AP 4 at Immortal and AP 5 at Sovereign ([Monsters §2.3](gdd_monsters.md#23-stat-ceilings-per-stage))
- **Every shape hits allies too.** The bigger the shape, the more of them stand in it. A 2×2 monster starts the shape at a chosen covered square ([2×2 bodies](#body-relative-damage-and-movement-variants))
- The shape is part of the species and changes through slot-development upgrades (Shape and Size, §6)

**Kin twists:** every Strike deals **2 damage per struck monster**, plus its bound Kin effect; ordinary Strike prop damage is 2, with the Swarm exception below. Hard damage ceiling: [Battle §6.1](gdd_battle.md#61-the-damage-law); construction evaluation: [§5](#strike-costs).
- §5 prices all Kins/existing shapes as unvalidated calibration drafts; full combination evaluation is pending. Existing effects and battle-AP prices remain unchanged.
- Table values are gameplay effects, **not construction points**.

|   Kin   |   Strike   |                                          Effect                                          |
|---------|------------|------------------------------------------------------------------------------------------|
| Beast   | Bite       | no effect *(user decision 2026-11-11)*; baseline costing: [§5](#strike-costs) |
| Winged  | Dive       | then retreat 1 square for free, opposite the centre of the hit shape, once per use *(user decision 2026-11-11)*; rule/failed-retreat handling: [§3](#body-relative-damage-and-movement-variants), no retreat without a unique centre direction |
| Scaled  | Tail Sweep | push the target 1 square (direction chosen with WASD)                                    |
| Swarm   | Gnaw       | props take double (4)                                                                    |
| Spirit  | Siphon     | target −1 initiative next round                                                          |
| Ancient | Slam       | destroys the Mountain under the target; collapse and resulting ground reference the [Mountain-destruction contract](gdd_battle.md#47-ground--neutral-hazard-and-blessed) |

- **Bound effects:** Kin packages are not interchangeable. Swarm grants no extra monster damage; Ancient grants no extra collapse/debris damage or arbitrary ground removal. Collapse is environmental, not Strike damage ([Battle §6.1](gdd_battle.md#61-the-damage-law)).

### 8.2 Movement by Kin

Kit/Step access: [§1](#1-the-kit); movement mechanics/presets: [§3](#movement). This table owns Kin access to slotted presets.

|         Mode        |      Kin       |
|---------------------|----------------|
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

- **Model:** [kit/access §1](#1-the-kit), [activation/usage §2](#usage-and-repetition), [availability/trigger valuation §5](#self-buff-and-passive-costs). Equipped availability does not mean continuous effect: define continuous, conditional or event-driven application.
- **Access:** species learnable list/individual (Epic+ extra slot, artifacts), within Kin/progression limits, never theme/aspect. Kit example under §1: 1 active + 3 passives is legal but weak.
- **Prior-draft candidates, not approved perks or exceptions to §1–§7:** effects/access/interactions need T02/T04/T11 validation. Momentum damage, AP discounts, Crashlander collision wording and automatic movement/target selection remain unresolved; grant no damage/AP-reduction upgrades, new collision rules or unspecified tie-breaks.

**Terrain Identity:**

- Adaptive — [central candidate record](#non-area-and-passive-coverage-references)
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

### 6.2 Additional Species Candidates

Candidate catalogue and its status: [Monsters §4.2](gdd_monsters.md#42-additional-species-candidates). Skill-specific coverage gaps are listed above; this retained navigation heading is not a slot-development subsection.

## 11. Concrete Skill Records

Draft structural/calibration references (Strike, Surge, Zone, Movement, self-buff, passive), not approved content, catalogue, balance or unlocks. Each instantiates the [§2 field groups](#common-field-structure) and references owning baselines rather than redefining them.

### Slowing Zone, Beast Jab and Delayed Burst (area and Strike references)

**Documentation template, not implementation:** the §2 model includes species skills/upgraded variants. Field names/references are documentation notation, not required serialization or invented runtime identifiers; effects supply existing mechanics/caps, not a parallel zone schema.

**Slowing-zone walkthrough — unapproved draft:** the Slowing Zone entries below form its full baseline. Area/AP remain calibration proposals; a centred three-cell footprint avoids two-cell midpoint ambiguity.
- **Paper checks, not engine tests:** anchor (3,3) yields (2,3)/(3,3)/(4,3); (0,3) is invalid because (-1,3) is off-board. Ground Movement 3 becomes 2 at level I, returns to 3 on exit; Step stays normal, allies behave identically. Props are not slowed, air is excluded, underlying ground unchanged. General 2×2/unrelated gaps remain open.
- **Bindings:** single authored footprint, not cast-time shape choice. Placement: [§2](#2-data-oriented-skill-construction-kit); lifetime: [Battle §4.5](gdd_battle.md#45-lifecycles); value/replacement: [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites). Evaluation: provisional [Slow calculation](#calibration-examples)/[AP scale](#ap-efficiency-working-scale), not unlock/content approval.
- **Representation:** the field entries below are the sole baselines; candidate patches stay separate/unapproved. Shared dimensions, ground/layer ownership and former flat-blueprint responsibilities follow §2; Surge twists/species ownership remain profile constraints/metadata on that same model.

**Coverage:** Slowing Zone, Beast Jab and Delayed Burst here; Run, Focus and Adaptive below complete six cases. Groups are explicit or reference §2/§8.1; unresolved access/upgrades/runtime remain draft. Jab covers only fully costed Beast, not other Kins' unresolved contracts (T02/T06).

Coordinates `[dx, dy]`, **1×1 bodies only**; 2×2 records need the unapproved variants (T09).

Cases per field below: **Slowing Zone reference (draft)**; **Beast Jab reference (draft record of existing Strike)**; **Delayed Burst reference (draft Minor Surge)**.

- **`metadata`**
  - Slowing Zone: `id: slowing_zone_example`; `name: Slowing Zone (draft)`; `kind: zone`; `rule_profile: zone`; `tags: [control]`
  - Beast Jab: `id: jab_reference`; `name: Jab`; `kind: strike`; `rule_profile: strike`; `tags: [reference]`
  - Delayed Burst: `id: delayed_burst_reference`; `name: Delayed Burst (draft)`; `kind: surge`; `rule_profile: minor_surge_residue_free`; `tags: [reference]`; no species twist
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
  - Delayed Burst: `activation: player_action`; legal-Surge condition; `timing: telegraphed_delayed`; `resolution: caster_next_turn_start_before_start_effects`; marker/charging/autonomy: [Surge baseline](#surge), dead-caster timing: [Battle §2.2](gdd_battle.md#22-initiative-rules)
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
  - Slowing Zone: `stat_change: slow`, base 1/cap 2; battle-zone level, not slot level. Level-to-value, Movement floor and zone stacking: [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites); Step exception: [Movement](#movement).
    - **Application/recipients:** immediately on placement and continuously while inside, to all ground-layer occupants including allies/caster; no air or props.
    - **Exclusions/lifetime:** no damage/entry payload, ignition, secondary effect, height or ground-state effect. Uses the shared created-zone lifetime and ends on exit/removal.
  - Beast Jab: `damage` from the [Beast/Jab baseline](#81-strike-by-kin), with [Strike recipients/blocking](#strike); once at cast resolution, action lifetime `none`, no retained damage stack
  - Delayed Burst:
    - **Payload/recipients:** `damage` fixed 3, once at detonation, to all ground-layer monsters in the footprint at resolution including caster/allies/enemies; no air. Ordinary prop interception/damage: [Battle §4.10](gdd_battle.md#410-prop-catalogue-and-damage).
    - **Resolution/exclusions:** shield/Hallowed reduction and zero floor: [Battle §6.1](gdd_battle.md#61-the-damage-law). No push, pull, prop-specific reaction, repeat payload or retained damage stack; marker expiry is in `persistence`.
- **`persistence`**
  - Slowing Zone: Created zone, 2 rounds; shared-clock ticking/expiry: [Battle §2.4](gdd_battle.md#24-effect-timing-reference)/[§4.5](gdd_battle.md#45-lifecycles). Two rounds do not guarantee two full personal turns per monster
  - Beast Jab: `none`; immediate action with no retained Kin state
  - Delayed Burst: `type: until_resolution`; `owner: pending_surge`; expires at detonation; no post-resolution effect lifetime
- **`board_changes`**
  - Slowing Zone: `[]`: no ground, height or prop operation
  - Beast Jab: `[]`: no authored ground/height/prop operation; ordinary damage-derived prop destruction uses Battle §4.10
  - Delayed Burst: `[]`: no authored ground placement, residue or height change; ordinary damage-derived prop destruction/aftermath uses [Battle §4.10](gdd_battle.md#410-prop-catalogue-and-damage)/[§6.2](gdd_battle.md#62-surge-resolution-integration), not an added residue component
- **`interactions`**
  - Slowing Zone: Placement not blocked by props/height; recipient layers are specified in `effects`; no ground-changing operation
  - Beast Jab: Monster damage recipients include ground and air; `blocked_by_objects: true` (solid-prop line rule); `blocked_by_height: false`; no additional Beast operation
  - Delayed Burst: Damage recipients are ground-layer only; `blocked_by_objects: false` for placement (prop intercepts damage); `blocked_by_height: false`; no ground reset, including Hallowed consumption without residue
- **`usage`**
  - Slowing Zone: `ap_cost: 1` proposed; existing zone limits
  - Beast Jab: Jab's [authored AP baseline](#81-strike-by-kin); existing AP repetition, no charging limit
  - Delayed Burst: `ap_cost: 1` proposed; [Surge baseline](#surge) and [§2 repetition](#usage-and-repetition), including concurrent casts on legal non-overlapping footprints; no cooldown/mana
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
- **Resolution/validation:** resolve all definitions/parameters through [§2](#common-field-structure) and revalidate the whole record under [§7](#7-validation-and-concrete-skill-records). No override of fixed fields; effect/operation order follows [Battle §6.2](gdd_battle.md#62-surge-resolution-integration), never field-list position. Unsupported/unspecified cases remain central TODO.
- **Upgrades/usage:** [§6](#6-slot-levels-development-replacement-and-upgrades) owns patches, prerequisites/exclusions and budget/AP consequences; [§2](#usage-and-repetition) owns repetition. No second schema or generic cooldown/mana/aspect/attunement system.

### Non-Area and Passive Coverage References

**Additional reference coverage:**

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
  - Run: Self mover plus player-selected legal path/destination under the [Run baseline](#movement), including distance source and sight/path rules
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
  - Run: Typed self `movement` under the [Run baseline](#movement), once at action resolution in the owner's legal layer; no retained state/stack; process walk entry effects under existing rules
  - Focus (draft): Typed `stat_change`: effective Initiative +1 to self in its legal layer; apply at resolution; bind to `focus_state`; same-skill/same-owner group refreshes duration, never adds magnitude, and other sources add (Battle §3.1); removal/death policies pending
  - Adaptive (draft content): Typed `rule_modifier`, permitting owner rotation of otherwise fixed tetris shapes when previewing/casting its own eligible skills; self scope in owner's legal layer, while equipped.
    - **Permission limits:** boolean/idempotent, not extra magnitude; identical permissions do not stack. No mirroring, Strike geometry/direction changes, added cells/range, new profiles or other profile changes.
- **`persistence`**
  - Run: `none`; action completes after traversal/landing
  - Focus (draft): `focus_state`: proposed 2 rounds, tick round end, remove modifier at 0; exact queue application follows normal round initiative recalculation; other termination policies pending
  - Adaptive (draft content): `adaptive_permission`: while owner participates in battle with this passive equipped; ends when that condition fails/battle ends; no round counter
- **`board_changes`**
  - Run: `[]`; entry-triggered board reactions remain ordinary runtime rules
  - Focus (draft): `[]`
  - Adaptive (draft content): `[]`
- **`interactions`**
  - Run: Unmodified [Run preset](#movement), including blocking, height, ground costs and distance modifier; legal destination required; air/2×2 remain T09
  - Focus (draft): No placement/path blocking; no air attack or ground interaction is introduced by a self-bound modifier
  - Adaptive (draft content): Affects only owner's authorized shape orientation choice; no targeting, footprint, layer or terrain exceptions
- **`usage`**
  - Run: Existing [slotted-movement AP baseline](#ap-efficiency-working-scale); ordinary action repetition, no cooldown/mana
  - Focus (draft): Proposed 1 AP; ordinary active-action repetition; recasting refresh is only a draft policy, not a finalized balance rule
  - Adaptive (draft content): `ap_cost: none`; no active cast or player-action repetition; no separate activation button
- **`upgrades`**
  - Run: None approved; existing movement-upgrade limits still apply; full three-level path pending T05
  - Focus (draft): None approved; bounded duration/secondary-effect exploration under [§6](#6-slot-levels-development-replacement-and-upgrades); full path pending
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
