# Temporary Clarification List — Road of the Beasts

Central list of open design decisions and validation tasks from Battle, Monsters, Overworld and the central Skills GDD. **User priority (restated 2026-11-12): the Battle is the core and is finished first; the Overworld does not matter until the Battle stands and the user is satisfied with it, or until the user says otherwise. Overworld tasks stay listed here but are not worked on and do not constrain Battle decisions.** The sequence below organizes work; it does not approve new gameplay rules. **Branch and write scope follow [CLAUDE.md](../CLAUDE.md)** (GDD work: `docs/` on `main`, released by the user on 2026-11-12; the Godot battle implementation was released for `main` on 2026-11-11).

## Usage

- The GDDs describe the current working state; existing proposals and numbers are **not automatically approved** by moving open tasks here.
- Open questions, alternatives and review tasks are maintained exclusively here. The GDDs hold the current design, including labelled content drafts and prototype deviations needed to distinguish it from historical implementations. Use Git history to trace changes; do not maintain changelogs in the GDDs or this file. Keep the handoff current rather than appending a running change history.
- Prerequisites apply to the named deliverable, not automatically to the whole task. **D/K** contracts can precede pricing/content; **V** closes only after suitable executed tests. Do not make test inputs depend on the completion of their own validation. Independent work within the current priority may proceed in parallel; meta-only Overworld work is queued until the Battle gate.
- **Implementation:** open points of the Godot battle implementation live under [Implementation](#implementation). They decide no rule: a rule question found there is settled in the owning GDD section and task.
- **Session close:** refresh [Context Handoff](#context-handoff) after every session so another agent/computer can resume without chat history. Reusable instructions belong under [AI Prompts](#ai-prompts), not in the active task list.
- On completion: incorporate the decision into the specified GDD sections, synchronize affected companion files and check off the item here. For playtests, document measurements and results before changing rules if necessary.
- **Task fields:** every editable task carries **Status**, **Prerequisites**, **Sources**, the concrete gap/decision bullets and **Done when** (completion conditions). Status values: *Open* (no decision yet), *Partly drafted/decided* (working draft or partial decision exists, not validated), *Blocked* (named prerequisite or user decision missing). Completed tasks move to [Completed Tasks](#completed-tasks-ids-retained-for-references) with their IDs retained; IDs are never reused for other topics. Validation tasks close only with tests actually performed and documented.
- **D** = design decision, **V** = validation/balance, **K** = consistency correction. Sources refer to the current GDD section numbers unless explicitly labelled historical.
- **Central skill specification:** [gdd_skills.md](gdd_skills.md) is the single file for everything about monster skills: kit, the skill card, what a skill does itself and what it creates, value and prices, slot development, data and validation, Strike shapes and movement kinds, passives, the kits and the skill list. Battle owns the board: what grounds, zones and props do and when, and generic resolution; Overworld only meta integration, economy and its own tamer/loadout content; [gdd_monsters.md](gdd_monsters.md) keeps monster identity, stats, Kins, roster and growth. Do not maintain parallel monster-skill price lists or upgrade rules. Historical statements are not active specifications.

# Context Handoff

**Last updated: 2026-11-13, end of the day (reshape of square and skills built and documented: no height, no air layer, no Surges or traps; a skill only delivers; Dragon Veins by last touch; overview and skill builder; S016–S019; Godot 4.7.2).** Resume from current files, not chat history. Replace this handoff at session end; keep rules/prices in their owners.

## Current State and Immediate Next Step

- **Where the design stands (2026-11-13):** the user reopened the battle from its goals and rebuilt the square and the skills in one day. **Decided by the user** and written into the GDDs: no height and no air layer; **no Surges and no traps**; a square is ground + zone + occupant, **ground acts at a moment, a zone while a monster stands inside**; **a skill only delivers** (cost, place, Strike, own movement, effect on its user, and the ground, zone or prop it creates; what those do is defined once, with them); fair damage at range by construction; Dragon Veins (the earlier Wellsprings) owned by **last touch**; being pushed is movement; AP and turn effects only as rare `experiment` skills; 7×7 stays. Owners: [Battle §1.2](gdd_battle.md#12-battle-design-pillars), [§4](gdd_battle.md#4-battlefield), [§6](gdd_battle.md#6-damage--displacement); [Skills §2–§4](gdd_skills.md#2-the-skill-card). Work list: T40.
- **Working values chosen by the agent while building** (the user was away for an hour and asked for a list of every choice: table under T40): highest hit 2 and lowest HP 3, the ground Binding Vines as “2 damage on leaving”, the name Dragon Vein, 26 skills and nine kits, spread test stats, which records are archived.
- **Build:** plays all of it. Overview (menu) with tables for skills as cards, monsters, grounds, zones and props, read from the Resource files; **skill builder** that writes new skill files with the status `experiment` and can put them into a kit slot; `content_status` on skills, monsters, grounds, zones and props. Bot `tactic` (plans the whole turn; beats the game's `AiBrain` in 93 % of battles) and the random-draw variants of `sim.gd` (`mixstats`, `mixskills`, `mixkits`, `genskills`).
- **What the bot runs say (S016–S019; indications only):** play quality outweighs every stat price derived before; with kits and stats drawn at random **HP, AP and a second turn carry the value, initiative, Movement and Reach show none**; displacement is the strongest skill family; the parts of a skill are nearly equal in value; the hand-made kits make battles too short (about 3 rounds, a quarter under 3) and the fragile monsters lose; a first round without damage and Dragon Veins that only work while held are the measured brakes.
- **Open user decisions:** (1) how initiative and Movement get a job on the board (the goal “every stat matters” is not met); (2) squares that act once and vanish: the user still likes the idea and wants to think about the form later (Potential Extensions); (3) the short battles: tune the kits, start Dragon Vein damage in round 2 or keep a calm first round; (4) the Kins beyond their Strike effect, and the Ancient's effect (T06/T11); (5) Wardstone and Ancestor Tablet (their effects lost their object), Spirit Shield and two arrays (T18/T20); (6) whether a line-shaped skill keeps stopping at a prop is moot (no Surges), but props still give no cover by rule; (7) stat prices and frames (T03).
- **From the user's first look at the build (2026-11-13):** ground may be laid on a square that holds a prop (the cast was refused before; decided, built, Battle §4.3/§4.7); the hover card of a skill button now names what the skill creates and, below it, what that ground, zone or prop does (`BattleText.skill_rows` / `created_rows`).
- **Monster builder (user request, 2026-11-13):** the battle prototype has a button “Monster builder”: create a monster or change an existing one (name, Kin, the six stats, four kit slots) and save it as a Resource file; new skills come from the skill builder, which returns to it. Checked headless on a copy: create, change, reload, and the new monster stands in the team choice. Tests no longer assume exactly nine monsters.
- **First play by the user (2026-11-13), feedback, nothing decided beyond the length target:** (1) **too few ways to displace:** a monster with much HP could not be got off a Dragon Vein, neither by damage nor by push or pull (a monster standing on a vein also blocks touching it; the Forge Golem is Immovable); (2) **target length now 2–5 rounds** instead of 3–7 (Battle §1.2): seven rounds felt too long, two rounds already hold at least six decisions per monster; (3) **zones that raise stats were hardly ever used:** the fight for the Dragon Veins decides and every monster gets there quickly. **Decided by the user on these points:** no Shove for everyone but **more push and pull skills in the kits**; Dragon Veins unchanged (a monster may stand on one; last touch owns); **stat zones only as an extra** on another skill. Built: every kit holds a push or pull skill that needs no Strike (Quake Leap back in the game, Shove for 1 AP, the Golem with Gale instead of Immovable), Mire rides on Gloom Rift and Slowing on Thornbed, the skills Mire and Tailwind are archived; `sim.gd` reports battles ended in round 1 and after round 5. **The user's own trials are in the working tree** (skills `asdf`, `asdf_2`, `asdf_3`, `new_skill`, monster `asdf`; Blaze Tiger holds `new_skill` in slot 1): leave them alone; tests no longer assume fixed kits or stats.
- **Not done:** the user has played a first time, with the feedback above; the code for height, the air layer, Surges and traps is still in the battle core, the view and the texts, unused by the game (tests that build them by hand still run); the three stat grounds, the shield and healing zones, the air props and the retired skills are `archived` files, not deleted; the battle view shows no owner of a Dragon Vein; the overworld still uses the six earlier stat shapes and old prices; 1v1 and 2v2 have no Dragon Veins.
- **Immediate next step:** the user plays 3v3 in the draft sandbox and tries the skill builder; then the points under “Open user decisions”, starting with (1) and (3). After that: clean the code of the removed mechanics, delete the archived records the user does not want back, new kits and stat prices.
- **Focus rule (user, 2026-11-12, in `CLAUDE.md`):** the Battle is the core; the Overworld does not matter and is not worked on until the Battle stands and the user is satisfied, or the user says otherwise.
- **Git:** branch `main`; commit `eed1ade` holds the state before the reshape (Godot 4.7.2, bot `tactic`, S016/S017). **Everything since is uncommitted:** the reshape, the overview and skill builder, the rewritten GDDs. No fetch, pull, push or reset was done.
- **Checks at the end of the day (Godot 4.7.2 headless on a `/tmp` copy of `godot/`):** the whole `tests` folder: 301 cases, only the two known failures outside the battle (I46: `test_reference_individuals_keep_their_fixed_stats`, `test_a_roamer_wanders_and_never_leaves_free_ground`); the overview and the skill builder open without errors; building, saving, assigning and reloading a skill works on a copy; `tools/smoke_ui.gd -- 3v3 7` without script errors or refused clicks; a script check of every relative link and heading anchor of the docs; `git diff --check`. **Not checked:** any screen by eye; any play by a human.
- **Tools:** [godot/tools/README.md](../godot/tools/README.md). The bot `tactic` takes about 23 s per 3v3 battle: run one process per seed in parallel. Runs go into [simulation_log.md](simulation_log.md) (S001–S019); the content fingerprint changes with every content change.

## Decisions Versus Drafts

| Class | Content (owner section holds the details) |
|-------|-------------------------------------------|
| Decided by the user (2026-11-13, reshape) | No height, no air layer, no Surges, no traps; ground and zone with one role each; a skill only delivers ([Skills §2](gdd_skills.md#2-the-skill-card)); fair damage at range; Dragon Veins by last touch, at least one per map; displacement is movement; damage on leaving a square as an effect; AP and turn effects only as `experiment`; ground acts as long as it lies; 7×7 stays; `content_status` on grounds, zones and props. |
| Decided earlier and still valid | Chebyshev distance and Voidscar reading, payload order and execution-time legality, simultaneous damage and queue-order displacement ties, damage-modifier stacking, modifier bounds, prop principles and the class-based catalogue with fixed aftermath, 2×2 body rules, queue ties, zones independent of ground, no aspects or attunement, no physical evolution, slot development at advancement steps, no skill rarity, monster cap by stage, one AP ceiling. Owners: Battle §2–§6, Skills §6, Monsters §2. |
| Working values, not validated | Highest hit 2 and lowest HP 3; the 26 skills and nine kits ([Skills §10](gdd_skills.md#10-kits-of-the-nine-monsters)/[§11](gdd_skills.md#11-skill-list)); ground and zone values; three Dragon Veins on 7×7; ground laid in battle lasts 2 rounds; every Strike pushes; movement on the full Movement stat with 2 AP for all but Run; extra turns from round 2; prop catalogue values; test stats of the nine monsters. |
| Open | Stat prices, frames and budgets ([Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups) holds the draft from before the reshape); every skill price ([Skills §5](gdd_skills.md#5-value-and-prices)); Kin access and learn lists; what a slot level allows. |
| Validation / tool boundary | [godot/tools](../godot/tools/README.md) are tools for trying things out, not rule sources or price authorities. Runs use bots on test content and give indications only. No task closes from a numeric fit or a simulation run. |

## Working Practices

- Follow [CLAUDE.md](../CLAUDE.md) for branch and write scope, preserve user work, no unrequested Git actions. **An audit session writes only `docs/temp_todo.md`;** GDD corrections and calculator/simulation-tool work below are follow-up tasks, not permission to edit them during the audit (`docs/` and `godot/tools/` are otherwise in the write scope of CLAUDE.md). The earlier checker authorization covers only the temporary docs script, never engine/prototype implementation.
- Resume from the current tasks and linked owners, not prior chat. Use the skill card of Skills §2 and the ground, zone and prop definitions of Battle §4, never a parallel model or a copied list. Skill content is edited only in [gdd_skills.md](gdd_skills.md).
- New recommendations/numbers need explicit status; general design changes need user decisions. Keep history in Git and replace stale handoff text rather than appending a log.

# Open Tasks

## Recommended Work Order

**Selected work priority: Battle first, Overworld second.** The task sections below are thematic groups, not execution phases; this table and the scoped prerequisites determine execution order. Parallel work stays within the Battle workstream unless the user changes priority.

| Order | Deliverable | Tasks | Boundary |
|-------|-------------|-------|----------|
| B1 — next | The reshaped battle played and tuned: rules that give every stat a job, kits that fit the length target | T40, T39; D/K of T03/T04/T06 | The user plays first; bot runs with `tactic` and the random-draw variants measure candidates |
| B2 | Skill list, learn lists, passives, kits and roster on the skill card | T10/T11/T12; T06 content | No price needed to play; prices follow |
| B3 | Stat and skill prices, slot development | T02, T03, T05 | From play and the measured values of B1/B2, not from the earlier sheets |
| B4 | All battle-facing external effects and request/result interfaces | Battle parts of T17–T21 and T22/T23 conflicts | Tamer skills, artifacts, medicine/array effects, loadout limits, swap/HP/defeat/Draw result and board inputs; the effects that named Surges or height are redefined here |
| B5 | Core tests, then Signature content and full-scope interaction tests | T13 with T03/T06/T07/T20 V; T32 | |
| B6 | Battle acceptance, clean-up of the removed mechanics in code and data | Battle gate; T40 clean-up; battle deliverables of T35/T37 | Every in-scope combat feature needs complete rules, content and documented suitable tests |
| O1 — after Battle gate | Translate battle requirements into acquisition, progression execution and world systems | T14/T15/T16; meta parts of T05/T17–T25/T30 | Recipes/prices/availability, expeditions, injuries, catching, housing, ritual sites and replacement logistics follow the combat specification |
| O2 | Management, progression pacing and day economy | T26–T31; final T35/T37 | Use tested battle states and resource demands to tune supply/XP/day AP |

### Battle Completion Gate

**Status:** Open. A rules draft is not a validated Battle completion. This milestone does not close mixed Battle/Overworld tasks wholesale or authorize implementation.
**Prerequisites:** Battle deliverables in B1–B5 and their combat-source corrections; no completion of meta-only tasks.
**Sources:** [Battle §7](gdd_battle.md#7-technical--prototype), [Skills §6–§7](gdd_skills.md#6-slot-levels-development-and-replacement), [Monsters §2](gdd_monsters.md#2-stats), [Overworld §6.4–§6.9](gdd_overworld.md#64-tamer-skills); detailed owning links remain under each task.
**Done when:** all four acceptance conditions below are met for the user-agreed combat scope; unresolved test failures or unapproved omissions keep the gate open.

- **Design ready:** T02–T07/T09–T12 combat deliverables, combat parts of T17–T23, T32 and related T35/T37 corrections specify legal battle inputs, actions, developed variants, passives, external effects, board generation, timing, preview and result outputs. Final intended battle scope must be explicit; a reduced roster, omitted items or deferred air/2×2/late-game mechanics need user approval, not an assumed shortcut.
- **Validated:** T13 executes and documents suitable current-design tests across the agreed scope, including developed/high-stage states, core and full loadouts, source-specific exceptions and T03/T06/T07/T20 V. The Godot battle (`godot/battle`, rebuilt 2026-11-11) implements the confirmed rules and can serve as the harness; an implementation and its rule tests are not the validation itself, and the HTML prototype and paper calculations do not satisfy this gate.
- **Handoff to Overworld:** record the accepted combat constraints and still-open **meta-only** questions against their existing IDs. Use finished test sheets/loadouts without simulating the whole economy; keep reachable state/slot/upgrade limits explicit. Acquisition frequency, XP pacing, recipes, ritual locations and day AP stay open for Overworld, not invented free/instant defaults.
- **Integration safeguard:** resolve T22/T23 restrictions that could alter in-battle healing, HP or fall prevention before acceptance; defer their run/recovery economy. Later meta tuning must respect accepted battle contracts; any proposed combat change needs an explicit decision and affected regression tests.

### Audit Coverage and Disposition

Every existing ID was reconciled with its owner; none was renumbered, merged or closed by arithmetic. Links and detailed acceptance criteria remain in the task entries.

| Tasks | Current disposition |
|-------|---------------------|
| T01, T08, T33, T34, T36, T38 | Closed: removals and the superseded Surge task, kept as reference IDs |
| T40, T39 | The reshape and the Dragon Veins: decided in direction, built, not played; open points listed there |
| T02, T03, T05 | Prices reset: no skill price exists, the stat price draft predates the reshape; development principles stand |
| T04, T06, T07, T09 | Rewritten to what the reshape leaves open (Draw result, Kin effects and shapes, ground and zone values, 2×2 bodies) |
| T10–T12 | The skill list and kits exist as working drafts; learn lists, passives and the roster are open |
| T13 | No test by a human; bot evidence in the simulation log |
| T14 | After the stat prices |
| T15, T16 | Queued after the Battle gate |
| T17–T20 | Combat effects first; effects that named Surges or height need new definitions (Spirit Shield, two arrays) |
| T21–T25 | Battle board/HP/healing/defeat interfaces first; expedition, acquisition, recovery and housing details after the gate |
| T26–T31 | Meta work, queued |
| T32 | Signature content; Major Surges are gone with Surges |
| T35, T37 | Synchronization and editorial work; the battle GDDs were rewritten on 2026-11-13, the overworld GDD only at its battle interfaces |

## Battle Foundations — Resolution, Stats and Valuation

### [ ] T02 · Find Skill Prices (D/V)
**Status:** Open — **reset by the reshape of 2026-11-13.** No skill, ground, zone or prop has a price. The earlier construction-point sheets priced Surges, timers, Mountains and air coverage and were removed with that model.
**Prerequisites:** play of the reshaped build (T40, T13); a stable skill list (T10).
**Sources:** [Skills §5](gdd_skills.md#5-value-and-prices), [§2](gdd_skills.md#2-the-skill-card); [simulation_log.md](simulation_log.md) S017–S019.
- **Principles that stand** (earlier user decisions): a skill is paid with AP and its use limit; no skill rarity; a complete kit at original AP; stats and skills priced apart.
- **Evidence so far (bots):** parts of a skill are nearly equal in value (46–55 %); displacing zones lead (56–66 %); pure damage skills 43–50 %. A price per part looks like a weak tool; whole skills and combinations decide.
- **Open:** what a price is expressed in (AP only, or AP plus a kit budget); whether the 1-AP and 2-AP split of the build holds; the value of the two `experiment` effects (AP +1, one more turn) that the user wants rare and expensive; prices of created props.
- **`internal_calc_cost`** in the Resource files holds numbers of the removed sheets for older records and −1 for everything since: decide whether the field stays.
- **Done when:** the user has played, a price form is decided and written into Skills §5, and every skill of the game carries a price that play and runs support.

### [ ] T03 · Review Stat Budgets, Frames and Progression Limits (V/K)
**Status:** Open — consistency conflicts remain; Core frame and roster arithmetic rechecked, no frame/budget gameplay tests.
**Prerequisites:** D/K review can start from current Monsters rules; relevant T02 costs/content for comparative testing. V closes with T13, not before T11 can supply test kits.
**Reshape 2026-11-13:** the build fields spread test stats outside every frame (HP 3–8; [Monsters §4.1](gdd_monsters.md#41-first-roster-draft--9-monsters)); the price draft of Monsters §2.2 predates the reshape. Measured on the reshaped build with stats drawn at random (S018/S019): about 4 win-rate points per HP, 11 for AP 3 against 2, 7–12 for a second turn, **nothing for initiative, Movement and Reach**. Prices cannot repair that; rules have to (T40).
**Sources:** Monsters [§2.1](gdd_monsters.md#21-the-stats)–[§2.3](gdd_monsters.md#23-stat-ceilings-per-stage), [§5.3](gdd_monsters.md#53-monster-progression-the-18-steps); Overworld [§1.2](gdd_overworld.md#12-design-pillars), [§2.4](gdd_overworld.md#24-cultivation-loop).
- **Stat prices are untested initial values (user direction 2026-11-13);** first measurement in [simulation_log.md](simulation_log.md) S014 (bots only): HP is worth four to six win-rate points per price point, initiative and Movement about one, Reach and AP nothing to three and a half; a second turn is worth what its body is worth (+26 to +28 points on a sturdy or middle monster under the build rules, 10 on a 2-HP one; with TPR from round 2 and Wellsprings +5 to +12 and nothing). High initiative makes the 2-HP monster worse. User idea to test: **1 HP costs 2 or 3 points**; the figures support about 3 against initiative and Movement and about 2 against AP and Reach. A threat-aware bot does not lift the fragile monsters and loses to the plain one (43–45 %). **Corrected by S016:** that bot was too crude to tell; the bot `tactic` beats `greedy` in 93 % of battles and lifts the fast monsters (Hawk 44 → 54 %, Wisp 51 → 57 %) while the sturdy ones fall (Golem 41 → 36 %, Turtle 47 → 40 %), so the prices below, derived from `greedy` runs, overrate HP. A test set with HP 3–8 (S016 “wide”) shows a 3-HP monster with AP 3 at 46–58 % and both AP-2 monsters weak. Open: a frame with little HP and high Reach does not exist (Glass cannon is fixed at Reach 2); stat values depend on the kit (the Golem has no movement skill, its Movement stat does nothing).
- **Reset on 2026-11-13 (user request; working draft in [Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups), S015 Part B):** HP 2 per point from a base of 4 (no monster below 4 HP), initiative 0.5 per point, second turn 3, the rest unchanged; four frames (Bulwark, Skirmisher, Swift, Caster) replace the six; budget unchanged (16 at Core High). Of four simulated sets this one has the narrowest spread of win rates (41–57 % against 30–69 % before). Open: every reference monster buys AP 3; sturdy against middle (22 of 80); frames, ceilings and budgets of the other stages (the Qi HP ceiling of 4 equals the new base); a third turn and AP above 3 keep untested prices; overworld code and the overview screen still use the old shapes and prices.
- Check prices, budgets and all scaled frames; Reach costs 3 points per level and now affects all casts. Reach now only limits how far away a skill may create something; its value showed nothing in the runs (S017–S019).
- Init on roll: 1 point = 1.0; on level-up: 0.1. Equal points received do not necessarily mean equal resulting strength; compare freshly rolled and raised individuals.
- **Monster cap (decided, user 2026-11-11):** the player's **stage**, not the exact sub-tier ([Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups)); [§5.3](gdd_monsters.md#53-monster-progression-the-18-steps) sets no separate sub-tier cap.
- Some Overworld texts still limit spent points by the frame; the monster GDD limits only the roll by the frame.
- Step-only monsters: explicitly resolve random Movement points versus “stays at frame minimum”.
- **Reach stage scaling (decided, user 2026-11-11):** ratio (stage ceiling − 1) ÷ (Core ceiling − 1), round half up, written into the rule text of [Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups); the table is unchanged.
- **Arithmetic checked (re-run by script in the latest audit):** base total, all six Core frame ranges/headrooms and all nine Core High reference individuals (each 31 points, inside their frames, [Monsters §4.1](gdd_monsters.md#41-first-roster-draft--9-monsters)) match the listed prices/budget. The “unspent points” note includes Qi Balanced/Fragile correctly. The full all-stages table is reproducible using the alternative Reach ratio and round-half-up, but that is a diagnostic assumption, not an approved rule or balance test.
- **One AP ceiling (decided, user 2026-11-11, [Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups)):** every monster shares the stage AP ceiling of §2.3; the TPR/AP restrictions (TPR 2+ caps AP, AP 4–5 need TPR 1) are removed. **Open draft (D/V):** a TPR price that scales with actions per round (today 3/8/15 is additive: AP 3 + TPR 2 = 17 points for 6 AP/round versus AP 5 + TPR 1 = 24 points for 5 AP/round; with minimum other stats AP 4 + TPR 3 is exactly 35 points). The means to test it now exist (the battle core resolves extra turns; `godot/tools/compare.gd` plays two monsters side-swapped, T13), but no such run has been made and no formula is approved. Until then the unrestricted combinations are a known, untested gap.
- **Done when:** each finding above is resolved in its owning section (Monsters §2.2/§2.3/§5.3, Overworld §1.2/§2.6) or consciously deferred; the V part closes only after documented frame/price/budget/ceiling tests (shared with T13).

### [ ] T04 · Make Resolution Rules and Edge Cases Consistent (D/K)
**Status:** Partly decided — the rules that survive the reshape are in [Battle §2–§6](gdd_battle.md#2-battle-flow); the questions about Surge scheduling, Mountains and the air layer are gone with them.
**Prerequisites:** none.
**Sources:** [Battle §2.1](gdd_battle.md#21-core-battle-loop), [§2.4](gdd_battle.md#24-effect-timing-reference), [§6.2](gdd_battle.md#62-payload-resolution); [Implementation](#implementation).
- **Draw result:** both sides without monsters after one resolution is a Draw; what the BattleResult carries and what follows in an expedition is open (with T19/T23).
- **Late-round pressure:** start rounds for 2v2 and 5v5; whether the brake is still needed at all when Dragon Veins are owned by touch (it then never runs on 7×7).
- **Dragon Vein tie:** the owner's choice among equally near, equally strong enemies needs an input step; the build takes roster order.
- **Readings the code chose** (I01–I18): the ones about Mountains, the air layer and Surges are void; confirm or correct the rest in their owner sections: walking direction (I01), board-edge Strike legality (I02), Tail Sweep on multi-cell shapes (I04), total initiative (I11), late-round start rounds (I15).
- **Leaving and entering in one move:** a push off Binding Vines onto Thornbed fires both, the leaving effect first; confirm the order with the user once played.
- **Done when:** each point has a rule in its owner section and the readings are confirmed or corrected.

## Battle Content — Skills, Development and Monster Identity

## Battle Content — Skills, Development and Monster Identity

### [ ] T05 · Complete Skill Improvements (D)
**Status:** Partly decided — principles confirmed (slot development granted at advancement steps, no experience currency, pill-based replacement, no damage/AP/Reach upgrades); what a development changes on a skill card is open.
**Prerequisites:** T02 for prices; T10 for a stable skill list.
**Sources:** [Skills §6](gdd_skills.md#6-slot-levels-development-and-replacement); [Monsters §5.1](gdd_monsters.md#51-monster-rarity)/[§5.3](gdd_monsters.md#53-monster-progression-the-18-steps); [Overworld §6.3.2](gdd_overworld.md#632-permanent-skill-slot-development-confirmed).
- **Decided (user, 2026-11-08):** permanent slot development only at advancement steps, on one slot of one monster; replacement with a relearning pill keeps the slot's development; slot levels 1–3; never more damage, lower AP or more Reach.
- **Open on the skill card:** which parts a development may change (shape, zone rounds, what a movement passes over, a second thing created); step-to-level mapping; step supply incl. Normal rarity; deferral; respec; passive-only slots; the relearning pill's economy (T16/T31); the Evolution Pillar's function.
- **Done when:** these points are decided and Skills §6 lists the development options of every skill of the game.

### [ ] T06 · Complete Strike Shapes and Kin Effects (D/V)
**Status:** Partly decided — Cleave (cardinal only), Beast Bite (no effect) and the Winged Dive retreat are decided (user, 2026-11-11); every Strike pushes (build rule 2026-11-12).
**Prerequisites:** none for D; V with T13.
**Sources:** [Skills §3](gdd_skills.md#3-what-a-skill-does-itself), [§8.1](gdd_skills.md#81-strike-shapes); [Monsters §3.1](gdd_monsters.md#31-kin-table).
- **Ancient has no Strike effect any more** (it destroyed Mountains): a new one is needed.
- **Kins beyond the Strike:** with Surge sizes, movement layers and the air layer gone, the Kin table holds only a stat lean and a Strike effect. What else sets Kins apart (skill access, a passive each) is open, with T11.
- **Shapes in the game:** only Jab and Thrust are used by skills; the other nine shapes are archived files. Decide which return and at what AP; AP 2 monsters can only Jab.
- **Readings:** board-edge Strike legality (I02), Tail Sweep on multi-cell shapes (I04).
- **Displacement access (user decision 2026-11-12):** push skills are not bound to Scaled; which species get which displacement tool is T11.
- **Done when:** every Kin has its Strike effect and identity, the shape list of the game is decided, and T13 has compared the shapes.

### [ ] T07 · Ground and Zone Values (D/V)
**Status:** Partly decided — roles (ground at a moment, zone while inside), independence of zone and ground, no healing or damage by zones, unlimited Mossbed entries are decided; every value is a working draft.
**Prerequisites:** play (T13/T40).
**Sources:** [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites), [§4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed), [§4.5](gdd_battle.md#45-lifecycles).
- **Ranged damage is weak by design now:** hazards deal their level (1, at most 2), only Binding Vines 2. Check in play whether ground pressures enough or battles are decided by Strikes and Dragon Veins alone.
- **Binding Vines:** 2 on leaving, no levels, may be laid under a monster. Is a second cast a refresh only; does a blocked push count (no: no movement); is 2 right against HP 3.
- **Healing:** only Mossbed (1 on entering). Whether a ground that heals at the end of a turn is wanted (the earlier healing zone is archived).
- **Stat effects on a square:** only zones. The archived Hearth, Umbra and Hallowed could return as zones if wanted.
- **Levels:** hazards to II by laying again, zones to III by casting again; check whether levelling is used or only clutters the rules.
- **Wardstone and Ancestor Tablet** have lost their effect (Surge reduction, Hallowed): redefine or remove.
- **Done when:** the values are confirmed in play and written into Battle §4.6/§4.7 without the open marks.

### [ ] T09 · 2×2 Bodies (D/K)
**Status:** Partly decided — the air layer is removed (2026-11-13) and with it every open air question; the 2×2 board rules are decided ([Battle §4.3](gdd_battle.md#43-the-square-ground-zone-and-occupant), [§6.3](gdd_battle.md#63-collision)). No monster of the build has a 2×2 body.
**Prerequisites:** content that wants a 2×2 monster (T12).
**Sources:** [Battle §4.3](gdd_battle.md#43-the-square-ground-zone-and-occupant); [Skills §8.1](gdd_skills.md#81-strike-shapes).
- **Open:** leaving effects for a 2×2 body (the squares it no longer covers: written into Battle §4.3 as a reading, to confirm); Dragon Vein touch by a body that covers one; whether 2×2 stays in scope at all before the battle stands.
- **Done when:** the user decides the scope and the two readings are confirmed.

### [ ] T10 · The Skill List (D)
**Status:** Partly drafted — 26 skills on the skill card exist as working draft ([Skills §11](gdd_skills.md#11-skill-list)), chosen while building; not played.
**Prerequisites:** play; T40 for the open rules.
**Sources:** [Skills §2](gdd_skills.md#2-the-skill-card), [§11](gdd_skills.md#11-skill-list); skill builder and generator ([Skills §7](gdd_skills.md#7-data-and-validation)).
- **Open:** which of the 26 stay; skills that give initiative and Movement a use; combinations (Strike + zone, movement + zone) that no skill of the list uses yet; whether Quake Leap's “push all neighbours on landing” returns (strongest single part in the generator runs); skills around created props (the user's idea of throwing a prop across the board is not built).
- **Archived skill files** (26 and the six of the Surge and trap removal): delete what the user does not want back.
- **Done when:** the user has played and fixed a list, and Skills §11 carries it without the draft mark.

### [ ] T11 · Learn Lists, Passives and Kits (D)
**Status:** Open — nine hand-made kits exist ([Skills §10](gdd_skills.md#10-kits-of-the-nine-monsters)); no species has a learn list, one passive is in the game.
**Prerequisites:** T10; T06 for Kin identity.
**Sources:** [Skills §1](gdd_skills.md#1-the-kit), [§9](gdd_skills.md#9-passives), [§10](gdd_skills.md#10-kits-of-the-nine-monsters); [Monsters §4.1](gdd_monsters.md#41-first-roster-draft--9-monsters).
- **Kits:** the present ones end battles in about 3 rounds through pulls and collisions; the kits of Blaze Tiger and Dusk Moth test weakest (S018/S019). The user wants the player to shape kits: a learn list of about 8 skills per species (4 defaults + 1 per breakthrough, [Monsters §5.3](gdd_monsters.md#53-monster-progression-the-18-steps)).
- **Kin access:** the earlier movement and skill lock-outs are gone; a new access rule is open (with T06).
- **Passives:** candidates that still fit are listed in Skills §9 without numbers; passives that lower AP conflict with “no AP reduction”.
- **Done when:** every species of the roster has a learn list and default kit, the passive list is decided, and Skills §9/§10 carry them.

### [ ] T12 · Select the Launch Roster (D)
**Status:** Blocked — T11 identities/coverage are not ready; candidate names alone are not launch selection.
**Prerequisites:** T11.
**Sources:** Monsters [§4.1](gdd_monsters.md#41-first-roster-draft--9-monsters)–[§4.2](gdd_monsters.md#42-additional-species-candidates).
- Without a mandatory Kin×aspect matrix, select a diverse roster from the nine reference monsters and additional name ideas (previous target about 15); prioritize free themes and distinct playstyles over category completeness.
- Check missing blueprint/movement coverage and distinct one-sentence identities.
- **Done when:** the launch roster is recorded in [Monsters §4](gdd_monsters.md#4-roster) with a documented coverage and identity review.

## Battle Validation and the Post-Battle Reshape Follow-up

### [ ] T13 · Plan and Evaluate Battle Tests (V)
**Status:** Open — **no gameplay or balance test by a human has been run.** Bot runs S001–S019 are recorded in [simulation_log.md](simulation_log.md) and give indications only.
**Prerequisites:** the user's play of the reshaped build; for the full pass T12 roster and the battle parts of T17–T20.
**Sources:** [Battle §1.2](gdd_battle.md#12-battle-design-pillars) (goals), [§7.2](gdd_battle.md#72-prototype--playtests); [godot/tools/README.md](../godot/tools/README.md).
- **Goals as metrics (user, 2026-11-12/13):** 3v3 lasts **2–5 rounds** (changed after first play; the runs so far report “under 3” and “over 7”, the tool needs “under 2” and “over 5”), ended by fighting; no defeat in round 1 where possible; no defeat without a chance to act; no single skill wins by repetition; every skill has its situation; every stat matters; monsters differ.
- **What the bots have shown, in short:** S001–S012: permanent ground, markers and shield zones made waiting pay (11 rounds, 60 % ended by the collapse); S013–S015: Wellsprings and a ground clock gave 3.5–4 rounds; S016: the bot `tactic` beats the game's AI in 93 % of battles, so earlier stat values are weak; S017: with kits drawn at random bodies sort by HP, initiative and Movement show no value, a calm first round and fair Surges curb early defeats; S018/S019: the reshaped build is too fast with the hand-made kits (about 3 rounds), right in length with random skills (3.8–4.7), and still gives initiative and Movement no value.
- **To test by play first:** does the Dragon Vein by touch read well and is it worth running for; do Binding Vines create a real choice; are battles too short with the present kits; does the first round feel like positioning or like a trap; can one follow what ground and zones lie where.
- **To measure with bots** (`tactic` on both sides, 8–16 seeds × 20 battles): any rule that is meant to give initiative or Movement a job, against `mixstats` rows; new kits against the length target; a calm first round and Dragon Vein damage from round 2.
- **Limits of the bots:** `tactic` assumes a `greedy` opponent, cannot set up a dilemma or a surround, and sits about 58 % on side 1 against itself with the earlier kit stats (unexplained).
- **Done when:** core and full-scope test passes by play are executed on a build implementing the agreed combat scope, and their results are documented.

### [ ] T40 · Reshape the Square and the Skills (D/K)

**Status:** Partly decided — the direction and the form are decided by the user (2026-11-13), built and written into the GDDs; values and content are working drafts; nothing is played.
**Prerequisites:** the user's play.
**Sources:** [Battle §1.2](gdd_battle.md#12-battle-design-pillars), [§4](gdd_battle.md#4-battlefield), [§6](gdd_battle.md#6-damage--displacement); [Skills §2–§4](gdd_skills.md#2-the-skill-card); [simulation_log.md](simulation_log.md) S016–S019.

- **Why:** every stat is to matter and monsters are to differ, but with fixed damage initiative and Movement had no job on the board; the fragile bodies lost with any kit; the square stack (height, air, ground, zone, Surge / trap) carried rule packages that added little.
- **Decided by the user:** see “Current State” and Battle §1.2. Second step of the same day: **a skill only delivers**, and **Surges and traps go** (their removal had been the user's question in the first reshape message and was left unanswered by the agent, who had kept them as a “pending” layer); ground acts as long as it lies.
- **Open (user):**
  - **A job for initiative and Movement.** Named so far: Dragon Vein by touch (built; the bots do not turn it into wins for fast monsters), damage on leaving (built), choosing the moment of one's turn (two forms measured in S017 without effect). Not built: Dragon Vein damage that depends on who reached it first; ground or zones that reward distance moved.
  - **From first play (2026-11-13):** displacement is too scarce and a sturdy monster on a Dragon Vein cannot be removed; stat zones go unused. Options named by the agent, none decided: Shove as an action of every monster like Step; no ending a turn on a Dragon Vein (it is taken by running over it and cannot be blocked); ownership by the first touch of each round instead of the last touch (gives initiative a job); Immovable removed or barred from a vein; stat zones cut, or kept only as an extra on other skills.
  - **Battle length:** with the target now 2–5 rounds the measured 3.1 rounds of the hand-made kits fit; what is missing is the share of battles under 2 rounds.
  - *(Earlier note, before the target changed)* the hand-made kits end a quarter of the battles under 3 rounds. Levers measured: `calm=1` (no damage in round 1), `veinhold` (a Dragon Vein only works while held); not measured: Dragon Vein damage from round 2, fewer pulls in the kits.
  - **Squares that act once and vanish** (Potential Extensions): the user still wants them, form open (a prop, an “array”, something of its own).
  - **Dragon Veins:** count and squares for boards without a centre row; the owner's choice at a tie; a mark for the owner in the view.
  - **What lost its object:** Ancient's Strike effect, Wardstone, Ancestor Tablet, Spirit Shield, High Ground Array, Warding Array, the passives named in [Skills §9](gdd_skills.md#9-passives).
- **Clean-up still to do:** remove the code for height, the air layer, Surges and traps from `godot/battle` (core, view, texts, AI) with the tests that build them by hand; delete the archived grounds, zones, props and skills the user does not want back; the overworld's six stat shapes and old prices; `internal_calc_cost`.

- **Decisions taken by the agent (2026-11-13, during the hour the user was away and in the steps after; each is a working value the user may overturn):**

| Decision | Where | Why |
|---|---|---|
| Name **Dragon Vein** for the Wellspring | ground `data/grounds/dragon_vein.tres`, Battle §4.2 | Wuxia term for the lines of qi in the earth; a square of power one fights over. Code names (`wells`, `WELL`) kept to limit churn. |
| A Dragon Vein is touched by walking onto or across it, by being pushed or pulled onto it and by standing on it; nobody owns one at the start | `Battle.touch_veins`, `BattleTurn._positional`; switch `vein_touch` | The user's “last touched counts”; displacement is movement by the user's rule. |
| Highest single hit 2, lowest HP 3 | skill and ground files; Monsters §4.1 | Small HP without a floor of 4 needs “no hit from full HP to zero”. |
| Blight acts at the end of the round, Voidscar at the end of the turn | ground files | No damage at the start of a turn. |
| “Damage when moving” = **2 damage on leaving the square**, by walking or by displacement; ground Binding Vines, skill Snare | `GroundTrigger.ON_LEAVE`, `data/grounds/snare.tres` | The plainest reading that keeps the choice with the victim and lets a push combine with it. |
| Height, the air layer, Surges and traps are switched off at the source, their code is not deleted | `battle_boards.gd`, `unit_sheets.gd`; retired skills archived | Several hundred code places depend on them; removal in one go risked the build. |
| Hearth, Umbra, Hallowed, the shield and healing zones and the air props are archived; the Ancestor Tablet leaves Mossbed | `data/grounds`, `data/zones`, `data/props` | Ground changes no stat; zones neither heal nor shield; no air layer. |
| New zone Tailwind (Movement +2) | `data/zones/tailwind.tres` | Movement had no value and gets a tool. |
| 26 skills: reused where possible, six new (Fire Trail, Thorn Lash, Snare, Tailwind, Battle Trance, Time Split); Gloom Rift, Cinder Dive and Coiling Rift turned into skills that create ground | `data/skills`; [Skills §11](gdd_skills.md#11-skill-list) | Reuse was quicker and safer than writing all anew. |
| Tidal Shell, Spring Burst and Ambush Rift archived instead of converted | `data/skills` | As ground skills they would have doubled existing ones. |
| AP and turn effects as two self buffs with status `experiment`, once per battle | `FieldEffect` tags `vigor`, `sap`, `tempo` | Rare and expensive as the user asked; a self buff cannot stun anyone. No kit holds them. |
| A push zone left by a skill that also creates something else points where the placement is turned | `BattleCasting.rot_dir` | The user's idea to use rotation. |
| A prop that names no ground to leave (Clay Urn, Bamboo Stand, Gong, Vortex Urn, Beam) leaves the ground under it as it is; before, it reset the square to Plain | `battle_payload.gd`, Battle §4.10 | Followed from the user's decision that ground may be laid under a prop: otherwise that ground would vanish with the prop. |
| Stats of the nine monsters = the spread test set of S016; no price or budget checked | `data/monsters` | The user wants monsters to differ and called the prices open. |
| After the user's first play: the Forge Golem loses Immovable (Gale instead); Quake Leap returns; Shove costs 1 AP; Tailwind is dropped rather than attached to a skill | `data/monsters`, `data/skills` | The user could not remove a sturdy monster from a Dragon Vein and chose more displacement in the kits; an Immovable monster on a vein has no answer. No fitting carrier for Tailwind was found. |
| Kits rebuilt by hand, one idea per monster | `data/monsters`; [Skills §10](gdd_skills.md#10-kits-of-the-nine-monsters) | A first set to play. |
| The price sheets of the earlier model removed from Skills §5 | `docs/gdd_skills.md` | They priced Surges, timers, Mountains and air coverage; Git holds them. |

**Done when:** the user has played and decided the open points, the working values are confirmed or replaced, and the clean-up is done.

### [ ] T39 · Dragon Veins: Square Control as the Way to Win by Defeat (D/V)

**Status:** Partly decided *(user decisions 2026-11-13: three squares on the centre row, damage at the end of a round, surrounding, extra turns from round 2, late-round pressure only as a brake; ownership by last touch; all working drafts in [Battle §4.2](gdd_battle.md#42-dragon-veins-surrounding-and-late-round-pressure) / [§2.2](gdd_battle.md#22-initiative-rules), standard of the build; bot runs S013–S019; not played)*.
**Prerequisites:** play.
**Sources:** [Battle §1.2](gdd_battle.md#12-battle-design-pillars), [§4.2](gdd_battle.md#42-dragon-veins-surrounding-and-late-round-pressure); [simulation_log.md](simulation_log.md) S013, S017, S018.

- **User frame (2026-11-13):** the win condition stays “all enemy monsters defeated”; square control is the way there. Initiative order stays (no alternating activation), four free skill slots stay, monsters keep their variety. Rejected by the user: extra damage against a monster that cannot evade, armour by facing, alternating activation, healing or AP on these squares for the start.
- **Measured:** by touch the veins tick for both sides from round 1 and take a round off the battles (3.1 rounds against 4.1 while held, S018); they hit the nearest enemy, which wears down 3-HP monsters; surrounding hardly ever happens with bots.
- **Tried and not adopted:** one-time bonus squares (shield, extra turn; removed from the build), an HP band, postponing a turn in two forms (`delay=reverse`, `delay=first`), back-row starts.
- **Open:** count and squares per mode (even boards have no centre row); the owner's choice at the last tie (input step); whether damage starts in round 1; a mark in the view for the owner and for who is hit next; 2×2 bodies on a vein; whether surrounding stays.

**Done when:** the user has played and decided these points and T13 has measured the result.

### [ ] T14 · Safeguard Reshape Against Reroll Exploitation (D/V)
**Status:** Open — queued for post-Battle meta integration; reroll access/cost safeguards remain unvalidated.
**Prerequisites:** Battle gate, T03 and T13 results for legal stat states; relevant T16/T30/T31 economy/ritual inputs before declaring costs sufficient. T03 still checks rolled-versus-raised combat strength before the gate.
**Sources:** [Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups); Overworld [§2.6](gdd_overworld.md#26-action-catalog), [§7.5](gdd_overworld.md#75-materials-seeds-and-grades).
- Are a rare elixir and ritual costs sufficient, or is a cap/cooldown needed against repeated optimization rolls?
- **Done when:** the elixir/ritual cost is confirmed sufficient or a cap/cooldown is decided, backed by documented T13 results.

## Cross-Document Tasks — Combat Effects First, World Catalogues Later

### [ ] T15 · Define City Powers, Responsibilities and Content (D)
**Status:** Open — queued after the Battle gate by user priority; technically independent, not a combat blocker.
**Prerequisites:** no gameplay dependency on Battle; scheduling waits for its gate. Do not divert the current workstream into city design.
**Sources:** Overworld [§3.1](gdd_overworld.md#31-the-city)–[§3.2](gdd_overworld.md#32-the-powers-of-the-city), [§7.2](gdd_overworld.md#72-favor--faction).
- Define faction names, profiles and offerings for the three families.
- Confirm operators of Arena, Teleport Plaza and Business District: proposal is City Lord, City Lord, Guild.
- Clarify buildings/access for Rival Compounds and the purpose of the Slums; Black Stall remains an optional idea, not a promised feature.
- **Done when:** faction profiles, district operators, Rival Compound access and the Slums purpose are recorded in Overworld §3.1/§3.2/§7.2.

### [ ] T16 · Complete Material, Item and Recipe Catalogues (D)
**Status:** Open — catalogue/recipe/acquisition work queued after the Battle gate; combat effects are defined first under T17–T20.
**Prerequisites:** T01 (decided); Battle gate as scheduling prerequisite; relevant T10/T17–T20 outputs for battle-related products. Full recipes/material catalogues are not prerequisites to defining those combat effects.
**Sources:** Overworld [§6.6](gdd_overworld.md#66-pills--medicines)–[§6.8](gdd_overworld.md#68-arrays-artifacts-for-places), [§7.5](gdd_overworld.md#75-materials-seeds-and-grades)–[§7.8](gdd_overworld.md#78-acquisition-sources).
- Derive concrete materials, herbs, seeds, recipes, seals, scrolls and blueprints from patterns; determine counts, tiers and grades.
- Reconcile the legacy catalogue-count assumption (~40 pills, previously four tiers) with the current six-stage tier model, the §7.5 “ten families” wording, relearning pill and missing Sovereign XP value. Neither a full tier mapping nor a promised catalogue count is established.
- Check grade dependencies and acquisition sources against “money never buys exclusive power”; Legendary bloodline ingredients are currently described both as story-only and as boss/quest/auction rewards.
- Confirm Array recipes and the Forge route (Ore + Beast Parts); decide whether Upper Stones are currency only or also ritual materials. Align Bloodline requirements: Monsters §5.2 does not list the Upper-stone input in Overworld §7.5; do not adopt it from the optional ritual proposal.
- **Done when:** catalogue counts, tiers and grades are defined and the listed conflicts (pill count versus stages, Legendary sources, Upper-stone role, Array/Forge routes) are resolved in Overworld §6.6–§7.8.

### [ ] T17 · Define Artifact Rules and Stacking (D/K)
**Status:** Partly drafted — battle-facing slots/effects/stacking prioritized before the Battle gate; acquisition and meta-only gear bonuses remain later work.
**Prerequisites:** Relevant T03 stat rules, T11 passive definitions and T20 tamer interfaces for combat equipment; no full T16 catalogue prerequisite. T16/T25/T31 for later forging/acquisition, capacity and day-AP bonuses.
**Sources:** Overworld [§6.7](gdd_overworld.md#67-artifacts-equipment--socketed-passives), [§6.9](gdd_overworld.md#69-hard-caps), [§7.5](gdd_overworld.md#75-materials-seeds-and-grades); [Monsters §5.1](gdd_monsters.md#51-monster-rarity).
- **Battle deliverable:** legal equipment slots/Stage gates, effects/stat limits and passive stacking, including modifiers of tamer skills, must resolve into tested sheets/loadouts. **Meta deliverable:** forging/availability and day-AP/capacity/expedition-only bonuses follow after the gate; they remain open, not removed.
- Tamer: two or three slots, and when? Monster: second slot at Epic+, or additionally only from Core? Synchronize tables.
- Clarify passive OR stat modifier versus the schema “passive + small stat modifier”; limit duplicate passives and multiple artifacts.
- Check +1 AP/day, capacity and skill modifiers against day economy, Stage caps and the options-not-numbers rule.
- **Done when:** slot counts and unlock timing, the passive-versus-stat rule and stacking limits are decided and Overworld §6.3/§6.7/§6.9 agree.

### [ ] T18 · Specify Medicines and Arrays (D)
**Reshape 2026-11-13:** the High Ground Array (a start square as Mountain) and the Warding Array (less Surge damage) have lost their object ([Overworld §6.8](gdd_overworld.md#68-arrays-artifacts-for-places)); the user named arrays as a possible form for squares that act once (Potential Extensions).
**Status:** Partly drafted — medicine and battle-array contracts/classification prioritized for the Battle gate; recipe and non-combat Array work stays open afterward.
**Prerequisites:** Relevant T07-D/T10 effect contracts for battle definitions, not completed healing tests or the T16 catalogue. T16 supplies recipes/acquisition later; T19 consumes resolved combat effects/costs.
**Sources:** Overworld [§6.6](gdd_overworld.md#66-pills--medicines), [§6.8](gdd_overworld.md#68-arrays-artifacts-for-places), [§7.5](gdd_overworld.md#75-materials-seeds-and-grades)–[§7.6](gdd_overworld.md#76-item-schema).
- **Battle deliverable:** concrete medicine/array/battle-prep effects, item classification, consumption/durability, placement and source-specific timing feed T19 and T13. **Meta deliverable:** recipes, purchase/crafting supply and Internal World/business-protection Array content follow after the gate.
- Determine Medicine effects, recipes, item kind and distinction from pills. Protection/healing/board effects need their own source, consumption and timing contracts in the shared data model; monster-effect contracts do not automatically approve items.
- Which Arrays are consumable, and which reusable? Define durability, placement and battle effects.
- Confirm pre-battle Arrays as a limited exception to a neutral/point-symmetric start; review the three listed battle Array drafts and separately define the claimed Internal World/business-protection scope; no additional Array record is currently supplied.
- *New:* the battle-prep pills Swift (+1 initiative next battle) and Ward (first-hit immunity next battle) in [Overworld §7.5](gdd_overworld.md#75-materials-seeds-and-grades) are neither medicines nor arrays; decide their item treatment, timing and effect contract. “Immunity” sits against the shared protection model (reduction, no generic immunity) in [Skills §4](gdd_skills.md#4-what-a-skill-creates); Warding Array (“first Surge damage −1”) and Spirit Shield (“next Surge damage is 0”) use different wording again. Also reconcile “pre-battle modifiers (pills, arrays)” in the Battle request ([Overworld §8](gdd_overworld.md#8-technical-notes-overworld--development-phases)) with the loadout categories.
- **Done when:** Medicine/Array item kinds, effects, recipes, consumption and timing contracts are specified in the shared model, and the Swift/Ward pill classification is decided.

### [ ] T19 · Complete Battle Loadout and Timing (D)
**Status:** Partly drafted — visibility, pre-battle selection and BattleResult consumption fields exist; counts, activation windows and source handling remain blocked by T18 effects/costs.
**Prerequisites:** T18 combat effects and Battle-AP/consumption contracts, not recipes or market prices; coordinate T17/T20 loadout interfaces. Complete before full-scope T13.
**Sources:** [Battle §5.2](gdd_battle.md#52-tamer-skills-and-battle-loadout) (integration); Overworld [§2.1](gdd_overworld.md#21-battle-loop), [§7.9](gdd_overworld.md#79-inventory-and-loadout), [§8](gdd_overworld.md#8-technical-notes-overworld--development-phases).
- Define Medicine/Array counts, activation windows (own turn or anytime), AP costs and consumption.
- Apply the same rules to human opponents; specify visibility, preview, pre-battle locking and reporting consumed items in BattleResult.
- **Result schema (new gap):** [Battle §2.1](gdd_battle.md#21-core-battle-loop) decides that simultaneous defeat is a **Draw**, but [Overworld §2.1](gdd_overworld.md#21-battle-loop) lists only winner, HP left and kills. Define how a Draw is reported (no winner; per-monster HP/defeat facts); its meta consequence (rewards, XP, injury, Arena) is T23/meta and must not be assumed. The result line of [Overworld §8](gdd_overworld.md#8-technical-notes-overworld--development-phases) (winner, remaining HP, kills, used-up loadout items) does not name the Draw either; kill attribution is also undefined (I29).
- Dependency is directional: item combat effects/Battle-AP costs first, then loadout limits; no dependency on spirit-stone prices/recipes or mutual blocking. Acquisition frequency is tuned later against the accepted per-battle limits.
- **Done when:** loadout counts, activation windows, AP costs, consumption, human-opponent visibility, BattleResult reporting (including the Draw outcome) are specified in Overworld §7.9/§8 and Battle §5.2.

### [ ] T20 · Validate Tamer Skills Including Beast Swap (D/V)
**Reshape 2026-11-13:** Spirit Shield nullified Surge damage and has lost its object; Domain Glimpse no longer needs to spare Mountains and Surge markers; Swap Places counts as leaving and entering ([Battle §5.2](gdd_battle.md#52-tamer-skills-and-battle-loadout)). Redefine Spirit Shield here.
**Status:** Partly drafted — baseline summary table exists; *proposal* rows are unconfirmed. D can proceed on missing source contracts; V waits for the matching T13 tests.
**Prerequisites:** D uses existing shared contracts and only affected T09/T18/T19 interfaces; coordinate tamer exceptions with T04 now. V requires testable definitions/loadout timing and T13 execution, not a blanket T13 prerequisite to design.
**Sources:** [Overworld §6.4](gdd_overworld.md#64-tamer-skills); [Battle §5.2](gdd_battle.md#52-tamer-skills-and-battle-loadout) (integration).
- **Battle deliverable:** slots/Stage gates, in-battle effects, activation windows, swap/queue/HP/defeat handling and their T13 tests. Catching-only skills still need explicit loadout-slot/usage/output contracts; their seal supply/acquisition tuning follows with T24. Scroll availability/learning costs and permanent-loss logistics follow the gate, without changing combat permissions.
- Swap Places, Urgent Order, the activation window and Beast Swap runtime rules are confirmed (Battle §5.2, 2026-11-11). Second Wind and Life Thread are confirmed (2026-11-11, incl. Deadly-dungeon protection for Life Thread). Double Bind and Seal Mastery stay proposals until the catching rules (T24) are decided; T01 removed Attune. Explicitly define tamer sources in the shared effect model without transferring monster-skill permissions or AP classes.
- **Unconfirmed table rows (new gap):** Spatial Pull ("move an own monster to any empty square") and Qi Suppression ("an enemy monster −2 initiative next round") in [Overworld §6.4](gdd_overworld.md#64-tamer-skills) have no runtime contract in [Battle §5.2](gdd_battle.md#52-tamer-skills-and-battle-loadout). Decide confirm/change/reject; check Spatial Pull against Swap Places and Beast Swap (few uniform rules), its legality (range/LOS, body size, ground entry, layers, Surge markers), Qi Suppression against the stat-modifier rule ([Battle §3.1](gdd_battle.md#31-effective-stats): same source refreshes, N-round end) and its initiative timing within the recalculated-every-round queue, and the artifact variant ("−3 instead of −2", [Overworld §6.7](gdd_overworld.md#67-artifacts-equipment--socketed-passives)).
- Spirit Shield/Life Thread rules are decided (Battle §6.1); test them against each other and Urgent Order against initiative; define usage timing for free skills.
- Beast Swap: HP, queue and body-size rules are confirmed (Battle §5.2); injury interaction (T23) and the spatial-space capacity/logistics remain open.
- Scrolls teach skills earlier; Beast Swap may only be slotted from Soul: preserve this explicit gate. Define whether other early-learned later-stage skills may also be used early; do not silently extend the Beast Swap exception to all skills or waive it.
- *New:* Domain Glimpse is fully specified (Overworld §6.4: any tetromino, any orientation, anywhere on the board; Voidscar, Dragon Veins, props and monsters unaffected); its test belongs to T13.
- **Reading and pointers (K):** the build forbids swapping out the monster whose turn is running (I13); [Battle §5.2](gdd_battle.md#52-tamer-skills-and-battle-loadout) is silent on it. Battle §5.2's list of confirmed tamer rules names neither Spirit Shield (rule in [Battle §6.1](gdd_battle.md#61-the-damage-law)) nor Domain Glimpse (rule in Overworld §6.4); add pointers under T35 so that the seven confirmed skills are findable from the integration section.
- **Done when:** each tamer skill is confirmed, changed or rejected, the I13 reading is confirmed or corrected, tamer sources exist in the shared effect model, and Beast Swap and Domain Glimpse rules are specified and tested against the listed interactions.

## Battle Interfaces and Post-Battle Expeditions, Collection and Housing

### [ ] T21 · Define the Dungeon Node ↔ Board Generator Contract (D)
**Status:** Open — board-generation/BattleRequest contract prioritized for Battle; dungeon-node content and healthy-team availability follow afterward.
**Prerequisites:** T04 board rules for generator inputs now; T12 for final opponent/roster coverage tests. No full dungeon/loot/capacity design prerequisite to the board contract.
**Sources:** [Overworld §3.3](gdd_overworld.md#33-dungeons); [Battle §4.1](gdd_battle.md#41-battlefield-generation).
- **Battle deliverable:** finish the allowed board-generation inputs, mode/team-size constraints and deterministic placement responsibility before final T13; test requests can supply these without a whole dungeon run. **Meta deliverable:** populate dungeon nodes and check healthy-team/capacity access after the gate.
- Node-owned mode and wild-monster count are already the working design in Overworld §3.3. Define the remaining parameters: theme/ground families, prop-count ranges, start areas and seed/placement responsibility. Point-symmetric generation remains Battle §4.1's constraint; assigning all these parameters to the node is only a proposal.
- Check encounter access against required team size and available healthy monsters.
- **Done when:** the node ↔ generator contract is recorded in Overworld §3.3 and Battle §4.1.

### [ ] T22 · Complete Expeditions and Loot Tables (D/V)
**Status:** Partly drafted — persistent HP/free retreat with loot remain working design; run depth/rewards and healing-scope conflict unresolved. Final tuning waits for T16/T19/T21.
**Prerequisites:** Resolve the run-healing restriction's **in-battle** scope with T07/T20 before the Battle gate; do not wait for full expeditions to settle that conflict. Run/reward/supply tuning follows the gate with T16/T19/T21.
**Sources:** Overworld [§2.2](gdd_overworld.md#22-expedition-loop), [§7.8](gdd_overworld.md#78-acquisition-sources).
- Determine floors/battles per run, deeper entry (1/2 day-AP), retreat and reward tables per floor/boss.
- HP persistence and free retreat with loot are already the working state; do not reopen them without cause. Build open edge cases on that basis.
- Clarify “Healing Pill is the only healing during a run” against Mend/Mossbed, healing passives and Second Wind: outside battles only, or also during battles?
- **Done when:** floors/battles per run, deeper entry, retreat edge cases, reward tables and the run-healing scope are decided in Overworld §2.2/§6.6/§7.8.

### [ ] T23 · Align Injury and Deadly Dungeons (D/V)
**Status:** Open — combat fall-prevention/HP/defeat interfaces needed before Battle acceptance; recovery/pricing/Deadly-dungeon tuning queued afterward.
**Prerequisites:** Combat fall-prevention/HP/defeat-output interfaces with T04/T20 before the Battle gate, without deciding the Deadly-dungeon launch scope implicitly. Recovery/permanent-loss logistics and prices follow the gate with T16/T20/T22.
**Sources:** Overworld [§5.2](gdd_overworld.md#52-defeat-and-injury), [§6.6](gdd_overworld.md#66-pills--medicines).
- Review two nights of downtime, Revival price and Deadly loot bonus; confirm or defer optional Deadly dungeons for launch.
- Recovery Spring already halves downtime to one night; define a minimum for the additional −1-night adjacency bonus.
- Define healing on return/overnight for uninjured monsters and HP after recovery; check Soul Tether/Life Thread against permanent loss.
- **Life Thread versus Soul Tether:** Life Thread is confirmed including its Deadly-dungeon protection ([Battle §5.2](gdd_battle.md#52-tamer-skills-and-battle-loadout)), while [Overworld §5.2](gdd_overworld.md#52-defeat-and-injury) still calls it a “proposed own-monster fall-prevention tamer skill” (label sync T35). Open here: which of the two is consumed first when both protect the same monster, and the death/injury details Battle §5.2 hands to this task.
- **Draw consequence (new gap):** decide whether monsters defeated in a simultaneous-defeat Draw ([Battle §2.1](gdd_battle.md#21-core-battle-loop)) are Injured/lost in expeditions and Deadly dungeons and what Arena/expedition flow follows; the result schema itself is T19.
- **Done when:** injury downtime, Revival price, Deadly-dungeon scope, the Draw consequence and the healing-on-return rules are decided in Overworld §5.2, with the adjacency minimum coordinated with T25.

### [ ] T24 · Specify Binding, Eggs, Breeding and Hive (D/V)
**Status:** Open — blocked by T12, T16, T20, T22.
**Prerequisites:** T12, T16, T20, T22.
**Sources:** Overworld [§5.1](gdd_overworld.md#51-obtaining-monsters), [§7.5](gdd_overworld.md#75-materials-seeds-and-grades).
- Balance seal prices/grades and the **proposed** second binding (Double Bind, T20); keep deterministic post-win binding and player Stage cap. Seal Mastery is a proposal, not permission to exceed that player cap.
- Define breeding/Hive/hatching times per rarity and incubation conditions; clarify same species versus “species of one parent”.
- Preserve the current division: egg fixes species/rarity, hatching rolls shape; clarify visibility before purchase/hatching and when the egg's fixed data are generated. Do not reopen shape-at-hatch as if wholly unspecified. Define Hive offspring species/rarity/stage and its dependency on a housed/assigned Swarm; the current larva timer alone supplies no output contract.
- *New:* eggs are not an item kind in the [item schema](gdd_overworld.md#76-item-schema) although they are found, bought and traded; decide whether eggs are items or monster-side records.
- **Done when:** seal grades, proposed second binding, breeding/Hive output contracts and timers, egg visibility/generation timing and egg representation are decided in Overworld §5.1/§7.6, preserving the confirmed acquisition/roll boundaries.

### [ ] T25 · Internal World: Capacity, Buildings, Adjacency (D/V)
**Status:** Partly drafted — queued after the Battle gate; first-Trial-Pillar access conflict retained, not needed to construct legal combat test sheets.
**Prerequisites:** Battle gate as scheduling prerequisite. First-breakthrough access/Evolution Pillar role use T05/T30 interfaces without waiting for all collection/economy tuning. Final sizing/adjacency needs T09/T16/T23/T24; none blocks Battle's body/swap legality contracts.
**Sources:** Overworld [§4.2](gdd_overworld.md#42-building-system)–[§4.4](gdd_overworld.md#44-capacity-and-growth).
- Confirm grid/capacity curve, footprints, unlocks and new structures.
- Define housing capacity bonus, Mood/Loyalty and their concrete benefits, or remove an unnecessary system.
- Define hatching at full capacity, rented monsters and bench size.
- Trial Pillar unlocks only at Foundation but is needed to reach it; clarify access to the first breakthrough.
- Adjacency bonuses: minimum times, multiple neighbours and stacking limits; recovery must not silently become zero nights. The old aspect-matched Furnace AP bonus has been removed (§4.3), so it is not an active −1-AP contradiction; retain the general free-planning/paid-execution check under T31.
- Staff remain excluded from the interior for now. Reconsider only for concrete benefits; no implementation merely because it is possible.
- **Done when:** grid/capacity, footprints, unlocks, Mood/Loyalty, hatching at full capacity, Trial Pillar access and adjacency limits are decided in Overworld §4.2–§4.4.

## After Battle — Economy, Progression and Day Balance

### [ ] T26 · Draft Staff Traits and Numbers (D/V)
**Status:** Open — **user decision pending:** Ambitious poaching Standing comparison (whose Standing, against what, which direction); model B itself is chosen.
**Prerequisites:** Battle gate as scheduling prerequisite; no technical combat dependency for the Ambitious decision. T15/T16 for faction-specific wages/output/production tuning. Keep this independent question queued rather than parallel to the current Battle work.
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
**Prerequisites:** Battle gate and T05's battle-facing state/step-supply model, T22/T25/T28 meta outputs. Do not require T05's final day-AP/logistics values before pacing; T31 uses these pacing results to finalize those costs.
**Sources:** [Monsters §5.3](gdd_monsters.md#53-monster-progression-the-18-steps); [Overworld §2.4](gdd_overworld.md#24-cultivation-loop).
- Check the initial 18-step XP curve, pill XP, win XP, Training/Cultivate and idle XP; determine player values separately if necessary.
- Check the target of 3–6 focused days per sub-tier against farm/purchase/staff income; do not treat old prototype numbers as confirmation.
- **Done when:** the XP curve, pill XP, win XP and idle XP are checked with documented calculations/tests, not prototype numbers, and the 3–6 day pacing target is confirmed or revised.

### [ ] T30 · Complete Breakthrough Trials and Rituals (D/V)
**Status:** Open — blocked by T20, T25, T27, T29; trial draft contains confirmed conflicts.
**Prerequisites:** Battle gate before meta trial/ritual design. First-access/logistics use T25's first-Pillar and T16 acquisition interfaces without waiting for all T29 pacing. Full trial tuning uses T20 combat results, T25/T27/T29 outputs; trial encounters must obey accepted Battle contracts.
**Sources:** [Overworld §6.3.1](gdd_overworld.md#631-breakthrough-trials); [Monsters §5.2](gdd_monsters.md#52-rarity-ascension).
- Review the first trial draft against current game flow; prototype quantities are historical inputs, not validation. Confirm material quantities and pill effect, including which trial penalties exist beyond the listed guardian battle.
- “Player starts at half HP”/“player on the winning team” conflicts with the non-combatant tamer role: which monster/team is meant?
- Define player/monster trials, repetition, failure costs and trial access; synchronize rarity-ascension ingredients/site/acquisition with T16. The proposal requires **next-tier materials before breakthrough**, while ordinary dungeons/monster access are Stage-gated: specify how those materials and guardian/new-stage trial encounters are reached without silently removing caps.
- **Done when:** trial requirements, player-versus-monster wording, repetition/failure costs, first-Trial-Pillar and next-tier-material/encounter access, rarity-ascension ingredients/site and relevant test results are explicit in Overworld §6.3.1 and Monsters §5.2; prototype quantities do not substitute for tests.

### [ ] T31 · Finalize Day-AP and Action Costs (D/V)
**Status:** Open — blocked by T22, T25, T28–T30; day-AP curve is a proposal only.
**Prerequisites:** T22, T25, T28–T30.
**Sources:** Overworld [§2.3](gdd_overworld.md#23-day-loop), [§2.6](gdd_overworld.md#26-action-catalog).
- Review proposed 3/4/4/5/5/6 AP per Stage and Arena price per tournament round.
- Balance expeditions, cultivation, story and work against each other; account for staff reducing the workload.
- Keep free decisions/queuing/rearranging consistent with paid execution. Decide whether AP reaching 0 immediately ends the day (§2.3) or still permits free healing/harvesting/queueing/planning before night; do not assume one from UI convenience. Include dependency-aware night resolution (production inputs, hatching capacity, recovery and idle XP), not an undefined simultaneous write order.
- **Done when:** day-end/free-action boundary and dependency-aware night resolution are explicit, and the day-AP curve/every action cost in [Overworld §2.6](gdd_overworld.md#26-action-catalog) are compared with documented current-design economy/pacing tests. No arithmetic-only balance closure.

## Battle Late-Game Content and Cross-Project Completion

### [ ] T32 · Design Signature Skills (D)
**Reshape 2026-11-13:** Major Surges are gone with Surges; this task now covers Signature skills only, on the skill card ([Skills §1](gdd_skills.md#1-the-kit)). The earlier Ancient-only Major access question is void.
**Status:** Open — part of Battle completion, not postponed until after Overworld economy; content/access/slot treatment unresolved.
**Prerequisites:** Relevant T02/T05/T09 contracts and T12 roster/access decisions; use initial T13 core results for calibration, then test this content in the full-scope T13 pass. No T29–T31 or complete T13 prerequisite before drafting.
**Sources:** Monsters [§3.1](gdd_monsters.md#31-kin-table), [§5.3](gdd_monsters.md#53-monster-progression-the-18-steps); Skills [§1](gdd_skills.md#1-the-kit) (access), [§2](gdd_skills.md#2-the-skill-card), [§3](gdd_skills.md#3-what-a-skill-does-itself), [§6](gdd_skills.md#6-slot-levels-development-and-replacement); [Battle §5.1](gdd_battle.md#51-monster-skills-central-specification) (integration only).
- Determine concrete shapes, area, range and Signature slot treatment; retain existing Major 2-AP/once-per-battle working baseline until explicitly revised, and review the half-board draft. Major access is Ancient at Sovereign in Skills §1, not an automatic grant to every Legendary.
- Resolve legacy Ancient-versus-Legendary access wording explicitly; do not treat the older task phrase “Ancient AND Legendary” as an approved Major grant. Distinguish an Ancient's Major at Sovereign from Legendary Signatures of other Kins, including their unresolved slot treatment.
- **Done when:** Signature skills and their access are decided and written on skill cards, and the wording agrees in Skills §1, Monsters §5.3 and Overworld §6.3.

### [ ] T35 · Update GDD Synchronization and Implementation Plan (K)
**Status:** Open — the battle GDDs (Battle, Skills, Monsters §1–§4) were rewritten to the reshape on 2026-11-13; the overworld GDD only at its battle interfaces. Whole-project synchronization closes last.
**Prerequisites:** affected decisions; overall completion after the other tasks.
**Sources:** [Battle §7](gdd_battle.md#7-technical--prototype), [Monsters §5.3](gdd_monsters.md#53-monster-progression-the-18-steps), [Overworld §6.3](gdd_overworld.md#63-stage-unlock-table), [§8](gdd_overworld.md#8-technical-notes-overworld--development-phases).
- **Left over after the rewrite:**
  - [Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups)/[§2.3](gdd_monsters.md#23-stat-ceilings-per-stage): prices, frames and ceilings predate the reshape (HP base 4, Qi HP ceiling 4); the build's stats lie outside them.
  - Overworld §6.3 “Monster unlock” column against Monsters §5.3 (second artifact slot at Epic+, the “Dual-aspect unlock removed” note); §5.2/§6.6 still call Life Thread and Second Wind proposals; the §8 result line lacks the Draw (T19).
  - Overworld §6.4/§6.8: Spirit Shield and two arrays are marked open (T18/T20).
  - Monsters §6 pointer “T07–T09” includes the completed T08.
- Keep change history in Git, not in the GDDs or this task list; update the development phases once the battle stands.
- **Done when:** all other tasks are closed or consciously deferred, tables and references are synchronized and prototype comparisons are limited to what distinguishes implementation from design.

### [ ] T37 · Editorial Deduplication Pass (K)
**Status:** Open — the duplicates listed earlier lay in the Skills sections that the reshape replaced (the old §2–§5, §10, §11); the rewritten Battle and Skills GDDs were not yet read for new overlaps.
**Prerequisites:** none; contradictions go to the owning D task.
**Sources:** [Battle §4](gdd_battle.md#4-battlefield)/[§6](gdd_battle.md#6-damage--displacement), [Skills §2–§4](gdd_skills.md#2-the-skill-card); [Overworld §2.6](gdd_overworld.md#26-action-catalog), [§6.3.2](gdd_overworld.md#632-permanent-skill-slot-development-confirmed).
- **To check:** Battle §2.4, §4.3 and §4.7 each state the moments of ground; Battle §4.6 and Skills §4 both speak of the direction of a push zone (the rule is in Battle, Skills links); “highest hit 2” in Battle §1.2/§6.1 and Skills §11; slot development in Skills §6 and Overworld §2.6/§4.3/§6.3.2; stage gains in Monsters §5.3 and Overworld §6.3.
- **Done when:** each candidate is merged into one owning section with links elsewhere, or consciously kept, and the link check passes.

## Completed Tasks (IDs Retained for References)

IDs stay valid for references in the GDDs and this file. Removal decisions were verified against the current four GDDs; residual editorial wording is tracked under T35/T37, not mistaken for undone gameplay decisions or completed balance tests.

### [x] T38 · Raise the Impact of Surges (D/V) — superseded: Surges and traps removed

- **Outcome (user, 2026-11-13):** after the trap direction (2026-11-12), timer variants and `fairsurge` (S002–S017), the user removed Surges and traps altogether with the reshape: damage at range comes from ground, immediate damage only from a Strike. What stays from this task as build rules: every Strike pushes, the board edge deals 1 to a pushed monster, spiky props deal 2, movement skills may push on landing, ground laid in battle lasts 2 rounds ([Battle §4.5](gdd_battle.md#45-lifecycles), [§6.3](gdd_battle.md#63-collision), [§6.4](gdd_battle.md#64-displacement)).

### [x] T01 · Confirm the Aspect System (D/V)
**Status:** Decided removal, incorporated; no balance validation implied.
**Prerequisites:** none.
**Sources:** [Monsters §5.3](gdd_monsters.md#53-monster-progression-the-18-steps); Battle [§3.2](gdd_battle.md#32-monster-identity--skill-access), [§4.8](gdd_battle.md#48-removed-square-mechanics).
- **Decided:** remove the triangle and fixed monster aspects; no fixed replacement elements. Monsters receive free descriptive themes; deliberately designed species learnlists determine their allowed abilities.
- Remove Attunement. Concrete skills, ground types and Surge behaviour remain available in the construction kit, without fixed aspect binding or mandatory sets of three variants.
- Incorporated across the current four GDDs. New ground interactions are addressed under T07; concrete learnlists and roster under T10–T12. This does not validate the balance of the remaining mechanics.

### [x] T36 · Define Physical Evolution (D) — decided: removed
**Status:** Decided by the user (2026-11-08): physical evolution does not exist. It was a relic of the former per-skill evolutions. EP as a spendable currency is removed; slot development is granted only at advancement steps ([Monsters §5.3](gdd_monsters.md#53-monster-progression-the-18-steps)) as an option to develop one skill slot. Removal is reflected across the four GDDs; the Evolution Pillar's remaining role and same-skill reversal/respec logistics are open under T05/T25. The old “take back physical evolutions” action is gone, not a still-existing action to price.
**Prerequisites:** none.
**Sources:** [Skills §6](gdd_skills.md#6-slot-levels-development-and-replacement), [§5.1](gdd_monsters.md#51-monster-rarity), [§5.3](gdd_monsters.md#53-monster-progression-the-18-steps); Overworld [§2.6](gdd_overworld.md#26-action-catalog), [§6.3.2](gdd_overworld.md#632-permanent-skill-slot-development-confirmed).
- Removed: “physical evolution”, the shared EP pool, “Paths offered per evolution”, “physical Size path”, the “Take back physical evolutions” action. Historical prototype mentions remain only as prototype notes in Overworld §8.
- Rarity now sets development steps per advancement (1 for Normal/Rare, 2 for Epic/Legendary; legacy working values) next to slots and maximum stage.

### [x] T08 · Define Water and Swim (D) — decided: removed
**Status:** Decided by the user (2026-11-10): Water ground and the Swim movement mode are removed from the current design. Reason: protected Water that skills can influence would need a second parallel ground set (hazard/blessed variants), which contradicts "few uniform rules"; Rubble and Mountain already cover movement-cost terrain. Applied in Battle §4.7 and Skills §3/§5/§8.2/§10. Re-introduction is only tracked under [Potential Extensions](#potential-extensions-and-improvements).
**Prerequisites:** none.
**Sources:** Battle [§4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed); Skills [§3](gdd_skills.md#3-what-a-skill-does-itself), [§8.2](gdd_skills.md#82-movement-kinds).
- Not affected: Overworld building adjacency tags ("water" for Qi Spring/Spirit Pond, Immortal-city layout) are a separate meta concept and still need an explicit decision if Water is dropped from the whole game (see Potential Extensions).

### [x] T33 · Legendary Aspect Change Removed (D)
**Status:** Replaced by T01's confirmed removal; no replacement system approved.
**Prerequisites:** T01 (decided); T11/T30 are no longer gates for a removed mechanic.
**Sources:** [Monsters §5.1](gdd_monsters.md#51-monster-rarity).
- Removed by T01: without fixed aspects, there is no aspect change. No replacement feature approved; other Legendary development remains part of existing progression tasks.

### [x] T34 · Dual-Aspect System Removed (D)
**Status:** Replaced by T01's confirmed removal; residual active-table history is T35.
**Prerequisites:** T01 (decided); T09/T13 are no longer gates for a removed mechanic.
**Sources:** [Monsters §5.3](gdd_monsters.md#53-monster-progression-the-18-steps); [Overworld §6.3](gdd_overworld.md#63-stage-unlock-table).
- Removed by T01: no dual aspects or corresponding Immortal unlock. Multiple free themes require no separate unlock or special mechanic.

## Potential Extensions and Improvements

Parked ideas that are **not** part of the current design and not approved; they carry no prerequisites for any task. Add an idea here instead of keeping it in a GDD.

| Idea | Origin | Notes for a later revisit |
|------|--------|---------------------------|
| Board shapes other than 7×7: a set number of squares in a drawn shape, with simple limits against degenerate forms | Reshape discussion (user, 2026-11-13: 7×7 stays for now) | One more variable while the rules are open and harder to learn positions from; revisit when the battle stands. Wellspring count and placement depend on it. |
| Squares that act once and then vanish (the earlier trap), as a prop, an “array” laid on a square, or another kind of thing | Reshape, second step (user, 2026-11-13: still likes the idea, does not yet know how to build it in; to be thought about later) | Surges and traps were removed and ground acts as long as it lies. Candidates named by the user: props (they already act when destroyed) or arrays. Needs its own life rule next to ground (2 rounds) and props (HP); keep “no damage at range without a turn since the cast” in mind. |
| Water ground and Swim movement | T08 (removed 2026-11-10) | Last draft: neutral ground, move cost 2, generator origin plus skill creation; Water protected from residue/hazard/blessed ground (user leaning); Swim = walk preset, Water cost 1, otherwise Run (draft 7 CP, unapproved), Kin access via Skills §8.2. Open problem: skills that influence Water would need a second ground set parallel to hazard/blessed ground. Possible lighter variant: generator-only static Water without skill interaction. |
| Additional monster Cleanse sources (Plain reset / zone removal) | T04 (not adopted 2026-11-10) | Former placeholder prices 3×C / 4×C removed from Skills §5. Revisit if T13 shows permanent hazard ground lacks counters (see T07). |
| Status effects on monsters (e.g. poison: damage over several rounds) | T38 discussion (parked by the user 2026-11-12) | Deterministic, but a new unit-bound state system with its own bookkeeping at HP 1–10; revisit only if the displacement and trap direction of T38 leaves too little damage. |
| Props or ground that damage neighbouring squares (on touch, or every N turns/rounds without being destroyed) | T38 discussion (parked by the user 2026-11-12) | Would be damage nobody cast with its own clock; touches “zones never deal damage” and the fixed, previewed prop aftermath. A larger hazard ground or a spiky prop (T38) covers most of the intent. |
| Ground that displaces (Ice: a monster pushed or pulled onto it slides 1 square further in the same direction if that square is free) | Surge discussion (parked by the user 2026-11-12) | Not now: the build just gained many displacement sources (every Strike, zones at cast and at turn end, movement with landing displacement, pushing Surges and traps, Gong, Vortex Urn, Storm Drum) and nobody has played them; landings must stay easy to foresee; ground is permanent and has two clear roles so far (hazard, blessed). Ice is the smallest candidate because it only extends an existing displacement and needs no direction per square. Revisit if play shows that displacement falls one square short too often. Not recommended: Current ground (pushes at turn end; overlaps the push zones, needs a direction per square) and spring ground (throws whoever enters it; makes voluntary paths hard to plan). |
| Overworld "water" tags | T08 follow-up | Qi Spring ("counts as water"), Spirit Pond ("water for adjacency") and the Immortal-city "mountains and water" layout in [Overworld](gdd_overworld.md) are meta-world tags independent of battle ground; keep unless the user decides to remove water from the whole game. |

## Dependency Overview

```mermaid
flowchart TD
    A[T40 T39 reshape played and tuned] --> B[T04 T06 T07 T09 rules and values]
    B --> D[T10 T11 skill list learn lists and kits]
    D --> C[T02 T03 T05 prices and development]
    D --> E[T12 roster]
    D --> F[T13 core tests with T03 T06 T07 validation]
    B --> G[T17 T18 T19 T20 combat equipment effects and loadout]
    D --> G
    B --> H[T21 board inputs and T22 T23 combat restrictions]
    E --> I[T32 Signature content]
    F --> I
    C --> J[T13 full-scope tests including T20 and T32]
    E --> J
    I --> J
    G --> J
    H --> J
    J --> K[T35 T37 combat acceptance and synchronization]
    K --> L[Battle completion gate]
    L --> M[T14 T15 T16 and remaining meta acquisition and logistics]
    L --> N[T22 T23 T24 T25 expeditions recovery collection housing]
    M --> O[T26 T27 T28 staff favor and economy]
    N --> O
    M --> P[T30 first trial access and ritual logistics]
    N --> P
    O --> Q[T29 pacing and T30 final trial tuning]
    P --> Q
    Q --> R[T31 day-AP and cross-loop validation]
    R --> S[T35 T37 final project synchronization]
```

Arrows summarize scoped deliverables and the selected **Battle → Overworld** schedule, not blanket whole-task dependencies. T03/T06/T07/T20 V is executed within T13; its core pass informs T32, and its full-scope pass tests the resulting content. Battle-facing T05/T17–T23 outputs do not require final meta prices/recipes/XP/world systems. Combat T35/T37 corrections can start alongside the first contracts; their gate review is shown after tests. All unresolved meta parts remain open after the Battle gate; final project synchronization is separate.

# Implementation

Open points of the Godot battle implementation (`godot/battle`, rebuilt 2026-11-11 on `main`; layout, extension points and commands: [godot/README.md](../godot/README.md)). This section tracks what the code still lacks or had to assume; **it decides no rule.** A rule question is decided in its owning GDD section under the named task; the code and its test in `godot/tests/battle` follow. IDs (`I..`) are stable and never reused; a point is removed once the code, its test and the owner section agree.

## Readings to Confirm

**Status:** Open — each row is the literal or existing-tool reading the code follows today, kept in one place; none is a decision.
**Done when:** every row is confirmed or corrected in the owner section and the matching test is adjusted.

| ID | Reading in the code | Owner / task | Where |
|----|---------------------|--------------|-------|
| I01 | Walking (Step, Run) and free paths (Glide) step orthogonally; a line (Leap, Headbutt, Fire Trail) uses the eight directions. The GDDs fix the distance measure, not whether walking may step diagonally | Skills §8.2 · T04 | `BattleMoves` |
| I02 | A Strike is legal only if its whole shape lies on the board, so symmetric shapes cannot be used next to the edge | Skills §8.1 · T06 | `Battle.strike_error` |
| I03 | A placed shape is legal only if all its squares lie on the board | Skills §2 · T04 | `BattleCasting.error` |
| I04 | Scaled Tail Sweep on a multi-cell shape pushes every struck monster in the one chosen cardinal direction | Skills §8.1 · T06 | `BattlePayload._phase_displacement` |
| I08 | What a destroyed prop leaves is laid before the ground the same skill creates | Battle §6.2 step 4 · T04 | `BattlePayload._phase_board` |
| I09 | A prop reduced to 0 HP by a collision of the Gong push is removed in a further removal step with its own aftermath | Battle §4.10/§6.2 · T04 | `BattlePayload._phase_board` (removal loop) |
| I10 | Late-round pressure converts squares without a monster and without a prop; zones of a converted square stay | Battle §4.2 · T04 | `BattleTurn._late_pressure` |
| I11 | "Total initiative" of the first tie = sum of the effective initiative of each side's living monsters; extra-turn entries are not counted | Battle §2.2 · T04 | `BattleQueue.build` |
| I13 | Beast Swap cannot swap out the monster whose turn is running | Battle §5.2 · T20 | `BattleTamer.error` |
| I14 | Mixed levels of one zone cast under a 2×2: the highest covered level applies | Battle §4.3 · T09 | `BattleStats.zones_under` |
| I15 | Late-round pressure starts in round 7 on 2v2 and round 10 on 5v5 (drafts; the GDD gives 1v1 and 3v3 only) | Battle §4.2 · T13 | `BattleBoards.MODES` |
| I16 | A monster that falls during its own turn ends that turn at once, without end-of-turn effects | Battle §2.4 · T04 | `Battle.apply` |
| I17 | The player picks a movement destination; the route is chosen automatically (least net harm from entering and leaving, then cheapest) | Skills §3 · T04 | `BattleMoves._walk` |
| I51 | A leaving effect fires before the monster moves, an entry effect after; a blocked push fires neither | Battle §6.3 · T04 | `BattleMoves.execute`, `BattleDisplace.shove` |
| I52 | A Dragon Vein is also touched by a monster standing on it at the end of the round; the last tie of its target is roster order | Battle §4.2 · T39 | `BattleTurn._positional` |
| I53 | A movement leaves its ground or zone on its start square and the squares it passed, never on the landing square or under another monster | Skills §4 · T10 | `Battle._use_skill` |

*Void since the reshape of 2026-11-13 (their object is gone): I05 (Mountain under a Slam), I06 (`mend` order), I07 (prop layers), I12 (retreat onto a Surge square), I18 (Surge recipients).*

## Waiting for Rules or Content

**Status:** Blocked by the named tasks — nothing here is implemented beyond the last column; no default stands in for a missing rule.
**Done when:** the owning task supplies the contract or content and the row is implemented with tests.

| ID | Not implemented | Blocked by | Already in place |
|----|-----------------|------------|------------------|
| I19 | Signature skills | T32 | the `once_per_battle` use limit |
| I20 | Tamer skills Spatial Pull and Qi Suppression; a new Spirit Shield | T20 | one resolver per effect in `BattleTamer` (Spirit Shield still nullifies Surge damage, which no longer occurs) |
| I21 | Tamer skills Double Bind and Seal Mastery | T24 (catching) | — |
| I22 | Medicines and arrays in the battle loadout | T18/T19 | the request carries tamer skills, bench, start squares and a board seed only |
| I23 | Artifacts (extra passive or +1 stat) | T17 | passives are ordinary kit skills; the unit sheet has no artifact slot |
| I24 | Slot development and upgrade choices on battle sheets | T05 | nothing: every individual fights with its species kit |
| I25 | Learn lists, Kin access and approved kits and passives | T06/T10/T11/T12 | nine draft kits inside the monster files; the skill builder writes kit slots; one passive (Immovable) |
| I26 | Event-driven passives beyond one event | T04/T11 | the reaction order of Battle §2.4 with one event type (prop destroyed within Reach → heal) |
| I28 | Board generator contract; start-square choice of the enemy side | T21 | fixed test layouts (seed 0) and a seeded draft generator under the symmetry rules; enemy starts are the mirrored default squares |
| I29 | Draw consequences and the final result schema (kill attribution, used-up items) | T19/T23 | `BattleResult.draw`, HP and alive per monster, used tamer skills |
| I30 | Content for 2×2 bodies | T09/T12 | rules and tests; no kit fields a 2×2 |
| I54 | The owner's choice at a Dragon Vein tie; an owner mark and a “who is hit next” hint in the view; Dragon Veins for 1v1, 2v2 and 5v5 | T39 | roster order; the square is coloured |
| I55 | Squares that act once and vanish | Potential Extensions | — |

## Overworld Follow-ups

**Status:** Queued after the Battle gate (meta integration); the overworld code is unchanged and still runs the pre-revision monster model. The battle maps its data strictly to the GDD (user decision 2026-11-11).
**Done when:** the overworld adopts the current monster/skill model and the adapter rule of the row can be deleted.

| ID | Gap | Current battle behaviour | Owner / task |
|----|-----|--------------------------|--------------|
| I32 | The monster model has no AP stat | every rolled individual fights with AP 2, the GDD base value (`UnitSheets.BASE_AP`); reference individuals use the Monsters §4.1 sheet stored in their monster file | Monsters §2 · T03 |
| I33 | Reach 1–3 and the stage ceilings in `shared/stage.gd` / `stat_shape.gd` are pre-revision | Reach below 2 is raised to 2; other stats are taken as they are | Monsters §2.3 · T03 |
| I34 | No slot development: the legacy evolution system was deleted with the legacy skill model (2026-11-12) | the Evolution Pillar is a structure without function; old saves lose their evolution picks | Skills §6 · T05 |
| I35 | The dungeon screen still announces an ambush bonus | `BattleRequest.ambush_side` is ignored; `Battle.AMBUSH_BONUS` exists only for that text | Overworld §2.2 · T35 |
| I36 | A Draw has no overworld meaning | reported as a fact; the overworld treats it like any non-win | T19/T23 |
| I37 | Aspects remain in species data, materials and structures | ignored by the rules; the 3D view uses the aspect colour as a look hint only | T01 (removed) · T35 |
| I39 | The overworld never fills the loadout, bench, start-square or board-seed fields of the request | only the draft sandbox does (test loadout) | T19/T21 |

## Verification and Code Follow-ups

**Status:** Open — no design decision needed.
**Done when:** each point is done or consciously dropped.

| ID | Point |
|----|-------|
| I40 | No human has played the build in the editor window; every check so far was headless (rule tests, `tools/smoke_ui.gd`, opening the overview and the skill builder, one dungeon → battle → dungeon round trip) |
| I42 | The game's AI (`AiBrain`) is a one-step evaluator: it uses no tamer skills and makes no placement choice. The tools bot `tactic` plans a whole turn and beats it in 93 % of battles (S016) but is far too slow for the game (about 1 s per turn) and assumes a `greedy` opponent. A game opponent between the two is open |
| I43 | 5v5 is not offered in the draft sandbox (nine species cannot fill both sides); board and setup exist and are tested |
| I44 | `UnitSheet.problems()` is checked in tests but `BattleSetup` does not refuse an illegal sheet |
| I45 | `BattleContent.VERSION` is bumped by hand (not bumped for the reshape); only `fingerprint()` is derived from the definitions |
| I46 | Two tests outside the battle fail and were not investigated: `test_reference_individuals_keep_their_fixed_stats` and `test_a_roamer_wanders_and_never_leaves_free_ground` |
| I48 | No T13 scenario has been played on the build; bot runs: [simulation_log.md](simulation_log.md) |
| I56 | **Dead code of the removed mechanics** (T40): height and Mountains (`BoardCell.height`, climbing, fall, collapse, Raise Ground, Mountain destruction), the air layer (`Board.AIR`, flyers, air props), Surges and traps (`PendingSurge`, timers, `spring_traps`, the Surge fields of `BattleSkillDef`), the shield, `mend` and `expose` effects, and their texts, view parts and AI terms. Nothing of the game reaches them; the tests that build them by hand still pass and go with them |
| I57 | Test switches of `BattleExperiment` that belong to removed mechanics (`surge_fair`, `surge_at_caster`, `surge_wall`, `surge_ground`, `trap_cap`, `trap_rounds`, `no_shield_zones`) and the matching `sim.gd` variants: remove with I56. Still meaningful: `wells`, `vein_touch`, `flank`, `tpr_from_round`, `ground_rounds`, `delay_*`, `damage_from_round`, `push_steps`, `start_back`, `pressure_mode` |
| I58 | The skill builder cannot build passives other than Immovable, cannot edit an existing skill's fields from its file and has no “remove from kit”; it overwrites a file of the same id after a warning in the preview only |
| I59 | A push zone left by a skill that also creates something else gets its direction from the rotation; a line shape therefore cannot push sideways in that case (a zone-only skill can) |

# AI Prompts

## Godot-Battle anhand der aktuellen GDDs implementieren

```text
Du sollst das Battle-System dieses Godot-Projekts auf den Stand der aktuellen Game Design Documents bringen. Arbeite direkt im Repository und setze die erforderlichen Änderungen vollständig um.

Umfang und maßgebliche Quellen:
- Dieser Prompt beschreibt einen späteren Implementierungsauftrag. Vor dem Start müssen der Arbeitsbranch und der Schreibbereich für Godot-Code ausdrücklich freigegeben sein, falls die dann geltenden Repository-Anweisungen weiterhin nur Dokumentationsarbeit erlauben. Der gespeicherte Prompt allein hebt diese Beschränkungen nicht auf.
- Beschränke deine Arbeit auf das Battle-System und dessen notwendige Anbindung. Die Overworld soll funktional unverändert bleiben.
- Lies zuerst die Repository-Anweisungen, docs/temp_todo.md (Context Handoff, offene Battle-Aufgaben und Battle Completion Gate), die aktuellen GDDs und den bestehenden Battle-Code. Maßgeblich sind docs/gdd_battle.md, docs/gdd_monsters.md und docs/gdd_skills.md sowie die Battle-Schnittstellen in docs/gdd_overworld.md. Bestehender Code kann veraltet sein.
- Unterscheide bestätigte Regeln, gekennzeichnete Entwürfe und offene Entscheidungen. Ein GDD-Entwurf ist keine automatische Freigabe. Wenn zentrale Regeln widersprüchlich oder ungeklärt sind, frage gezielt nach und arbeite an unabhängigen Teilen weiter, statt eine Spielregel zu erfinden.
- Du darfst den Battle-Code umfassend refactoren oder ersetzen. Bewahre vorhandene Implementierungen dort, wo sie zur neuen Spezifikation und Architektur passen. Erhalte unbeteiligte Nutzeränderungen.
- Implementiere keine zusätzlichen Spielmechaniken außerhalb der GDDs. Keine Commits oder sonstigen eingreifenden Git-Aktionen ohne ausdrücklichen Auftrag.

Architektur und Erweiterbarkeit:
- Das Battle soll deterministisch, gut nachvollziehbar und leicht erweiterbar sein. Verwende klare Verantwortlichkeiten, geeignete Klassen und explizite Verträge für Monster, Skills, Props, Ground und ihre Interaktionen. Nutze zu Godot und der verwendeten Sprache passende Mittel, etwa Resources, Komposition und gemeinsame Basistypen.
- Trenne Definitionen (Daten zu Monstern, Skills, Props, Ground und Effekten), Battle-Zustand (veränderliche Daten einer Begegnung), Regelauswertung (Validierung und deterministische Auflösung) sowie Darstellung und Eingabe (Szenen, Animationen, UI, Audio und Steuerung).
- Die Regelauswertung darf nicht von Animationen, Framerate, Szenenbaum-Timing oder UI-Zuständen abhängen. Die Darstellung bildet die Ergebnisse der Simulation ab.
- Modelliere gemeinsame Mechaniken über wiederverwendbare Regeln, Effekte und Fähigkeiten. Vermeide verstreute Abfragen nach konkreten Monster-, Skill-, Prop- oder Ground-IDs. Kapsle tatsächlich einzigartige Mechaniken hinter klaren Erweiterungspunkten.
- Baue keine unnötig abstrakte Universal-Engine oder eigene Regelsprache. Wähle die einfachste Architektur, die die aktuellen GDDs sauber abbildet und absehbare Inhaltserweiterungen ermöglicht. Neue Inhalte mit bestehenden Mechaniken sollen meist nur Daten brauchen; neue Mechaniken dürfen neuen Code brauchen.

Konkretes Erweiterungsziel:
- Ein zusätzlicher Ground-Typ soll sich über eine neue Definition und gegebenenfalls wiederverwendbare Verhaltenselemente ergänzen lassen, ohne Änderungen in zahlreichen unabhängigen Systemen zu benötigen.
- Wasser ist dafür nur ein hypothetisches Architekturbeispiel, kein Implementierungsauftrag und keine Wiederaufnahme der entfernten Water/Swim-Mechanik. Eigenschaften und Interaktionen bestimmen ausschließlich die aktuellen bestätigten Regeln.
- Dasselbe Prinzip gilt für Monster, Skills und Props: Bestehende Mechaniken sollen durch neue Daten kombinierbar sein. Neue Mechaniken sollen einen klaren, möglichst lokalen Erweiterungspunkt haben.

Determinismus:
- Gleicher initialer Battle-Zustand, gleiche versionierte Inhaltsdefinitionen, gleicher Seed und gleiche geordnete Aktionen müssen zum gleichen Ergebnis führen.
- Verwende ausschließlich kontrollierte Zufallsquellen innerhalb der Simulation, soweit die GDDs überhaupt Zufall vorsehen.
- Definiere eine stabile Reihenfolge für Aktionen, Effekte, Trigger und Gleichstände entsprechend den GDDs.
- Vermeide Abhängigkeiten von unbestimmter Iterationsreihenfolge, Echtzeit oder Darstellungsabläufen.
- Stelle Battle-Ergebnisse und relevante Zustandsänderungen so bereit, dass sie unabhängig von der Darstellung geprüft und nachvollzogen werden können.

Arbeitsweise:
1. Prüfe GDDs und Implementierung. Erstelle eine knappe Bestandsaufnahme mit Abweichungen, offenen Regelfragen und betroffenen Battle-Systemen.
2. Leite daraus einen konkreten Implementierungsplan und eine passende Zielarchitektur ab. Verknüpfe wesentliche Anforderungen mit ihren GDD-Quellen. Offene Designentscheidungen bleiben sichtbar und werden nicht durch technische Standardwerte entschieden.
3. Setze den Plan um. Bleibe nicht bei Analyse oder Architekturvorschlägen stehen. Frage nur nach, wenn eine ungeklärte Entscheidung die korrekte Umsetzung tatsächlich blockiert; bearbeite unabhängige Teile weiter.
4. Prüfe die Umsetzung mit geeigneten automatisierten Tests für Battle-Regeln, Effektinteraktionen, stabile Auflösungsreihenfolgen und Determinismus. Nutze nach Möglichkeit Tests ohne grafische Oberfläche und überprüfe konkrete erwartete Ergebnisse, nicht nur die Wiederholbarkeit.
5. Prüfe zusätzlich die spielbare Battle-Anbindung in Godot sowie die bestehenden Übergänge zur Overworld. Fehlende Meta-Systeme dürfen nicht durch erfundene Erwerbs-, Wirtschafts- oder Fortschrittsregeln ersetzt werden; nötige Battle-Testdaten klar als Testdaten kennzeichnen.
6. Dokumentiere kurz, wo neue Monster, Skills, Props und Ground-Typen ergänzt werden und wann neue Verhaltenslogik nötig ist.

Abnahmekriterien:
- Die Battle-Regeln entsprechen den aktuellen bestätigten GDDs; verbleibende Lücken und noch nicht freigegebene Inhalte werden konkret benannt. Keine stillschweigende Verkleinerung des vereinbarten Battle-Umfangs.
- Battle-Simulation und Darstellung sind voneinander getrennt.
- Determinismus ist durch reproduzierbare Tests belegt.
- Gemeinsames Verhalten wird wiederverwendet; inhaltsspezifische Sonderfälle sind lokal gekapselt.
- Neue Inhalte mit bestehenden Mechaniken lassen sich ohne Änderungen an der zentralen Battle-Auflösung hinzufügen.
- Das Battle ist in Godot spielbar und korrekt angebunden.
- Die Overworld bleibt funktional unverändert.
- Behaupte keinen vollständigen Battle-Abschluss, solange erforderliche Regeln, Inhalte oder tatsächlich ausgeführte Prüfungen fehlen. Das aktuelle Battle Completion Gate bleibt maßgeblich.

Berichte abschließend knapp, was umgesetzt wurde, welche Prüfungen tatsächlich bestanden haben und welche konkreten Punkte gegebenenfalls noch offen sind.
```

Reusable German chat prompts and subsection titles are an explicit exception to the English documentation rule. These are instructions, not design rules or an execution log. Copy the relevant prompt into a new agent session; the agent must read current files rather than assume the prompt embeds the latest state.

## Alle GDDs prüfen und Aufgabenliste aktualisieren

```text
Analysiere alle GDDs von Road of the Beasts und aktualisiere docs/temp_todo.md passend zum aktuellen Projektstand. Verlasse dich nicht auf frühere Chatverläufe.

Sicherheit und Umfang:
- Lies CLAUDE.md. Prüfe zuerst Branch und Git-Status: nur auf main arbeiten; andernfalls anhalten und nachfragen, nicht selbst wechseln.
- Erhalte Nutzeränderungen. Bearbeite für diese Prüfung ausschließlich docs/temp_todo.md; keine Spielimplementierung und keine GDD-Änderungen. Keine Commits, Branchwechsel, Pulls, Pushes, Resets oder automatische Synchronisierung.
- Chat Deutsch, Dokumentation Englisch. Ausnahme: wiederverwendbare Chat-Prompts samt Unterüberschriften unter AI Prompts bleiben Deutsch. Nutze kompakte thematische Stichpunkte und hilfreiche Übersichtstabellen; bewahre Bedingungen, Ausnahmen, Negationen, Einheiten und Entscheidungsstatus. Kein Changelog.

Projektfokus und Reihenfolge — Battle als Kern des Spiels:
- Battle zuerst abschließen; danach die Overworld auf den ausgearbeiteten und getesteten Kampf ausrichten. Prüfe trotzdem alle vier GDDs vollständig und erhalte offene Meta-Aufgaben; Battle-first begrenzt die Arbeitsreihenfolge, nicht den Analyseumfang.
- Battle umfasst mehr als gdd_battle.md: auch Monster-Stats und zulässige Entwicklungsstände, Skills, Passives, Upgrade-Pfade, Slotentwicklung, Roster und Major-/Signature-Inhalte sowie direkte Kampfeinflüsse aus dem Overworld-GDD (Tamer-Skills, Artefakte, Medicines/Arrays, Loadout, Board-Eingaben und HP-/Niederlagen-Schnittstellen).
- Trenne bei gemischten Aufgaben die Battle-Ergebnisse von der späteren Meta-Integration. Kampfauswirkungen, Entwicklungsumfang und legale Test-Sheets/Loadouts zuerst definieren und prüfen; Erwerb, XP-Tempo, Rezepte, Preise, Ritualorte, Gebäude, Wirtschaft und Tages-AP danach darauf abstimmen. Fehlende Meta-Details sind weder kostenlose/sofortige Standardannahmen noch pauschale Blocker für Battle. Bereits beschlossene Mechanikentfernungen nicht durch die neue Priorität rückgängig machen.
- Erhalte die Battle-first-Reihenfolge in Recommended Work Order, Aufgaben-Voraussetzungen, Dependency Overview und Context Handoff. Unabhängige Battle-Arbeit darf parallel laufen; reine Overworld-Themen bleiben bis zum Battle-Abschluss zurückgestellt, sofern der Nutzer die Priorität nicht ausdrücklich ändert. Keine Zyklen erzeugen: notwendige Definitionen vor ihren Tests, nicht abgeschlossene Validierung als Voraussetzung ihrer eigenen Testeingaben.
- Gleiche den Battle-Abschluss mit dem aktuellen Battle Completion Gate ab: vollständige Regeln/Inhalte/Schnittstellen im ausdrücklich vereinbarten Umfang und tatsächlich durchgeführte geeignete Tests mit dokumentierten Ergebnissen. Ein Regelentwurf, Budget-Fit, Rechenprüfer oder historischer Prototyp reicht nicht. Keine stillschweigende Verkleinerung des Rosters oder Auslassung von Items, Air/2×2 oder Late-Game-Inhalten; dafür wäre eine ausdrückliche Nutzerentscheidung nötig. Gemischte Aufgaben bleiben für ihre offenen Meta-Anteile offen.

Lesen und analysieren:
1. Lies die gesamte aktuelle temp_todo.md, besonders Context Handoff, danach alle aktuellen GDDs vollständig: docs/gdd_battle.md, docs/gdd_monsters.md, docs/gdd_overworld.md und die zentrale Skill-Spezifikation docs/gdd_skills.md. Große Dateien abschnittsweise lesen; eine Gliederungsübersicht allein ist keine vollständige Prüfung.
2. Gleiche jede vorhandene Aufgabe mit den zuständigen GDD-Abschnitten ab: noch offen, teilweise bearbeitet, nachweislich abgeschlossen, ersetzt, doppelt oder blockiert. Bestehende Aufgabenformulierungen und Arbeitswerte sind nicht automatisch Beschlüsse; GDD-Texte sind nicht automatisch validiert.
3. Prüfe fehlende Regeln, Widersprüche, offene Alternativen, Zuständigkeiten, doppelte Definitionen, veraltete Verweise, Sprache/Lesbarkeit, quellenspezifische Ausnahmen und den Status als Entwurf/Beschluss/Historie. Prüfe gegebenenfalls Rechensummen; Rechenproben und Prototypergebnisse sind keine Gameplay-/Balancevalidierung.
4. Entscheide keine offenen Gameplayvarianten, erfinde keine Standardannahmen und öffne bestätigte Prinzipien nicht ohne neuen Anlass. Der Endzustand nach einem Höhenbruch ist entschieden (Battle §4.7; vom Nutzer am 2026-11-12 bestätigt) und wird nicht ohne neuen Anlass geöffnet. Unklarheiten benennen, nicht stillschweigend eine Variante bestätigen.

Aufgabenliste aktualisieren:
- Überarbeite oder erstelle temp_todo.md erst neu, nachdem du ihren Bestand mit allen vier aktuellen GDDs abgeglichen hast. Erhalte alle weiterhin relevanten Entscheidungen, Einschränkungen, ausschließlich in der Übergabe enthaltenen Informationen und offenen Fragen. Nicht aus dem Gedächtnis ersetzen oder Punkte nur deshalb streichen, weil sie im GDD fehlen.
- Erhalte Context Handoff und AI Prompts als Hauptabschnitte, einschließlich dieser wiederverwendbaren Prompts. Vorhandene Aufgaben-IDs und gültige Abhängigkeiten möglichst bewahren; bei Zusammenlegung/Ersatz Nachvollziehbarkeit erhalten und alle betroffenen Verweise/Diagrammkanten innerhalb dieser Datei aktualisieren. IDs nie für sachfremde Themen wiederverwenden.
- Eindeutig ersetzte oder abgeschlossene Arbeit erst nach Prüfung ihrer restlichen Informationen und Abschlussbedingungen aus dem aktiven Backlog entfernen. Validierungsaufgaben brauchen tatsächlich durchgeführte geeignete Tests mit dokumentierten Ergebnissen; andernfalls offen lassen.
- Jede bearbeitbare Aufgabe erhält Status, zuständige Quellenlinks, konkrete Lücke/Entscheidung, Voraussetzungen und Abschlussbedingungen. Zusammengehöriges bündeln und eine Battle-first-Reihenfolge mit getrennten Battle-/Meta-Ergebnissen festlegen; unabhängige Battle-Arbeit darf parallel bleiben. Neue Lücken ohne doppelte Aufgaben ergänzen.
- Regeln, Preise und vollständige Referenzrechnungen bleiben in den zuständigen GDDs: verlinken statt kopieren. Vorgeschlagene GDD-Korrekturen als Aufgaben erfassen, nicht als unbestätigte neue Regeln.
- Veraltete Übergabe durch einen knappen aktuellen Stand ersetzen: Fokus, Beschlüsse gegenüber Entwürfen, Blocker, nächste konkrete Aktion/Fragen, betroffene Quellen, beobachteter Git-Stand und tatsächlich erfolgte Prüfungen. Zum Sessionende aktualisieren.

Prüfung und Antwort:
- Fokussierten Diff auf Informationsverlust und unbeabsichtigte Entscheidungsänderungen prüfen; relative Links, Aufgabenverweise, Abhängigkeiten und durchgeführte Rechnungen kontrollieren. git diff --check ausführen.
- Auf Deutsch berichten: tatsächlich geprüfter Umfang, wichtigste Befunde, Aufgabenänderungen, offene Entscheidungen, erfolgte Prüfungen und empfohlene nächste Battle-Besprechung. Benenne Battle-Blocker und später folgende Meta-Aufgaben getrennt. Bei unvollständiger Analyse genau benennen, was fehlt; keine vollständige Prüfung behaupten.
```

## Mit anderem Agent oder Rechner weiterarbeiten

```text
Setze die Dokumentationsarbeit an Road of the Beasts fort, ohne frühere Chatverläufe vorauszusetzen. Lies CLAUDE.md, prüfe Branch/Git-Status und halte an, falls nicht main aktiv ist. Keine eigenständigen Branchwechsel oder automatische Synchronisierung; lokale Nutzeränderungen erhalten.

Lies in docs/temp_todo.md Usage, Context Handoff und die betroffenen offenen Aufgaben; danach die zuständigen GDD-Abschnitte und verlinkten Schnittstellen. Aktueller ausdrücklicher Nutzerauftrag hat Vorrang vor älteren Übergabeanweisungen. Chat Deutsch, Dokumentation Englisch; wiederverwendbare Chat-Prompts samt Unterüberschriften unter AI Prompts bleiben Deutsch. Nur in docs/ arbeiten; keine Implementierung oder unaufgeforderten Git-Eingriffe.

Fasse Fokus und nächsten Schritt kurz zusammen. Belegte redaktionelle Korrekturen direkt bearbeiten; grundlegende Gameplayentscheidungen vorher klären. Entwürfe, Budget-Fit oder historisches Prototypverhalten nicht als bestätigte Regeln behandeln. Zum Abschluss Context Handoff mit tatsächlichem Ergebnis, Blockern, nächstem Schritt, beobachtetem Git-Stand und Validierung aktualisieren; veralteten Text ersetzen statt Historie anzuhängen.
```

## Session abschließen und Kontextübergabe aktualisieren

```text
Aktualisiere ausschließlich docs/temp_todo.md für die Übergabe dieser Dokumentationssession. Lies CLAUDE.md, prüfe Branch/Git-Status (main) und erhalte Nutzeränderungen. Nutze die aktuellen Dateien und ausdrücklichen Entscheidungen dieser Session; Empfehlungen sind keine Freigaben.

Aktualisiere Context Handoff: Fokus, Beschlüsse gegenüber Vorschlägen, offene Fragen/Blocker, genaue nächste Schritte/Quellenlinks, beobachteter Git-/Commit-Stand und tatsächlich erfolgte oder noch fehlende Prüfungen. Aufgabenstatus nur bei erfüllten Abschlussbedingungen ändern. AI Prompts und unbeteiligte Aufgaben erhalten. Keine Regel-/Preiskopien oder laufende Historie; veralteten Kontext ersetzen. Dokumentation Englisch, Antwort Deutsch; wiederverwendbare Chat-Prompts samt Unterüberschriften unter AI Prompts bleiben Deutsch. git diff --check ausführen; ohne ausdrücklichen Auftrag weder committen noch synchronisieren.
```

## GDDs redaktionell refactoren (Duplikate und Fließtext)

```text
Refactore die GDDs von Road of the Beasts redaktionell gemäß CLAUDE.md. Verlasse dich nicht auf frühere Chatverläufe.

Sicherheit und Umfang:
- Lies CLAUDE.md. Prüfe zuerst Branch und Git-Status: nur auf main arbeiten; andernfalls anhalten und nachfragen, nicht selbst wechseln.
- Erhalte Nutzeränderungen. Schreibe nur in docs/ (docs/gdd_battle.md, docs/gdd_monsters.md, docs/gdd_overworld.md, docs/gdd_skills.md; docs/temp_todo.md nur für Verweise und Übergabe). Keine Spielimplementierung, keine Commits, Branchwechsel, Pulls, Pushes oder Resets ohne ausdrücklichen Auftrag.
- Chat Deutsch; alle Dokumentation unter docs/ bleibt Englisch (Ausnahme: Chat-Prompts samt Unterüberschriften unter AI Prompts). Deutsche Bestandsabschnitte ins Englische übersetzen, ohne Regeln oder Entscheidungsstatus zu ändern.

Analyse zuerst:
1. Lies docs/temp_todo.md (Context Handoff, offene Aufgaben) und danach alle vier aktuellen GDDs (Battle, Monsters, Overworld, Skills) vollständig, abschnittsweise. Eine Gliederungsübersicht allein genügt nicht.
2. Erstelle vor dem Bearbeiten eine Befundliste: (a) Spielmechaniken, Regeln, Formeln, Preislisten oder Datenstrukturen, die an mehreren Stellen definiert oder fast wortgleich wiederholt werden; (b) lange Fließtext-Absätze und überlange Tabellenzellen; (c) deutsche Reste; (d) Verweise, die nach Umbauten brechen würden. Lege die Liste dem Nutzer kurz vor, wenn du mehr als nur eindeutige Duplikate zusammenführen willst.

Refactoring-Ziele (in dieser Priorität):
1. Keine doppelten oder mehrfachen Definitionen: Jede Regel, Formel, Preisliste und Datenstruktur hat genau einen zuständigen Abschnitt (Zuständigkeiten laut CLAUDE.md, Tabelle „Dokumentzuständigkeiten“). Alle anderen Stellen verlinken per relativem Markdown-Link und beschreiben nur ihre eigene Schnittstelle, keine Regelkopien. Beispiele und Referenzrechnungen folgen den zentralen Regeln und bilden keine zweite Regelversion. Allgemeine Regeln beschreiben Effekt-/Skillklassen statt Namenslisten; Skill-Ausnahmen nie auf ganze Klassen übertragen.
2. Keine Fließtext-Absätze: Längeren Fließtext in thematische Stichpunktlisten umwandeln, zusammengehörige Aussagen bündeln (nicht jeden Satz einzeln aufzählen), Unterlisten nur für echte Unterstruktur, Abläufe nummerieren, Vergleiche und Referenzwerte in kompakten Tabellen. Kurze Überblicks- und Begründungssätze dürfen bleiben.
3. Sprache: Englisch, einheitliche GDD-Terminologie und Bezeichner.

Harte Grenzen:
- Reines Refactoring: keine Regel, Zahl, Bedingung, Ausnahme, Negation, Einheit und kein Entscheidungsstatus (beschlossen / Arbeitsentwurf / nicht validiert) darf sich ändern. Keine neuen Mechaniken, keine Standardannahmen, offene Alternativen nicht entscheiden. Widersprüche nicht still auflösen, sondern als Aufgabe in docs/temp_todo.md erfassen.
- Informationserhalt prüfen: tatsächlichen Zeichenumfang vergleichen, mehr Zeilen sind keine Kürzung. Beim Zusammenführen von Duplikaten die vollständigste Fassung behalten und nur wirklich redundante Teile entfernen; Bedingungen nur in einer Quelle nicht verlieren.
- Überschriften stabil halten; nach Verschiebungen oder Umbenennungen alle Links, Abschnittsnummern und Anker in allen GDDs und in temp_todo.md aktualisieren. Aufgaben-IDs in temp_todo.md bleiben erhalten.
- Arbeite in kleinen, thematisch geschlossenen Schritten (ein Kapitel oder eine Mechanik pro Schritt) und prüfe jeden Schritt, bevor du fortfährst.

Prüfung und Antwort:
- Prüfe Diff auf Informationsverlust und unbeabsichtigte Entscheidungsänderungen, alle relativen Links und Anker (per Skript), Rechensummen, verbliebene doppelte Definitionen (gezielte Suche nach Schlüsselbegriffen) und `git diff --check`.
- Aktualisiere Context Handoff in docs/temp_todo.md auf den tatsächlichen Stand (Fokus, Blocker, nächster Schritt, Git-Stand, erfolgte Prüfungen).
- Berichte auf Deutsch: geprüfter Umfang, zusammengeführte Duplikate (mit zuständigem Abschnitt), umgewandelte Fließtexte, gefundene Widersprüche und neue Aufgaben, durchgeführte Prüfungen, offene Punkte. Keine vollständige Prüfung behaupten, wenn etwas fehlt.
```

# anschauen

Nicht angefasst: docs/gdd_battle.md §4.4 enthält einen jsonc-Codeblock, der den Brettzustand illustriert. Das ist GDD-Inhalt und keine Werkzeugdatei; sag Bescheid, wenn er auch weg soll.
