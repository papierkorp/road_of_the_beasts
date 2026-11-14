# Simulation Log — Road of the Beasts

Dated record of Godot battle bot, progression and discovery measurements (`godot/tools/sim.gd`, `progression.gd`, `discovery.gd`), kept as a series so that later states can be compared with earlier ones. Design rules live in the GDDs, open questions in [temp_todo.md](temp_todo.md); this file holds measurements only.

## Usage

- **Indications, not validation:** runs use the labelled bot policies on working content; some plan ahead, but none establishes human fun, agency or fairness. No entry approves a rule, price, kit or balance value; a change needs a decision under the task named in the entry.
- **Append only:** newest entry first; an existing entry is never edited except to fix a transcription error. A rerun on a newer state is a new entry.
- **One entry = one session on one code state.** It may hold several run blocks (modes, seeds). IDs `S001`, `S002`, … are never reused.
- **Reproducibility:** retain engine/code state, content, command/options, bot, schedule and seed. `dirty` marks uncommitted changes: the base commit alone does not identify the measured state. Harness/resource hashes and completion guards strengthen provenance without proving a full source identity; they do not authorize an automatic commit.
- **Kit sets:** sim runs name regular content by fingerprint under [Kit Sets](#kit-sets); progression/discovery reports also print their source roster or substitution schedule. Simulation-only resources are outside the regular fingerprint and need their separate hashes. Paired cases, side swaps and exact reruns are correlated; do not pool reruns as new evidence.

## Entry Format

```text
## S000 · YYYY-MM-DD · short title
State:        <commit> [dirty] · content version · kit set fingerprint
Runs:         one block per run, pasted unchanged from the tool
Observations: 3–6 bullets, worded as indications; say what is noise
Follow-up:    task ids the observations concern; never a rule change here
```

Command for a `sim.gd` block (keep progression/discovery's own printed command and complete report unchanged; CLI and measurement limits: [tools/README.md](../godot/tools/README.md)):

```sh
godot --headless --path godot -s res://tools/sim.gd -- <battles> <mode> <seed> "$(git rev-parse --short HEAD) [dirty]" [kits]
```

| Value in a run block | Meaning |
|---|---|
| Side 0 / side 1 | side 0 holds the player's start area; consult the labelled team draw/fixed teams and side-swap schedule, not a presumed equal-strength matchup |
| Draw / timeout | both sides fell in one resolution / no result after the tool's guard (normally 600 bot turns); progression/discovery exclude timeouts from score and list them separately |
| Damage share, per battle | damage dealt to monsters by source: `strike`, `surge`, `ground` (hazard ground and Voidscar), `collision`, `fall`, `collapse` (Mountain), `aftermath` (props), `arena` (late-round collapse), `well` (Dragon Veins), `flank` (surrounding); older blocks can omit columns still included in their total |
| Surge damage per Surge | Legacy-column damage ÷ declared Surges; Surges are not active in the reshaped game |
| Strike damage per Strike | Strike damage ÷ Strikes used (nominal 2 per struck monster) |
| Props placed | pre-placed props per battle by type (seeded draft boards) |
| Skill uses per battle | activations per battle by skill id, both sides together |

## Kit Sets

**Kit set `c0610a49270f`** (content `2026-11-11.1`; HP/Init/Move/TPR/Reach/AP: slots)

- thorn_mites 3/6/2/2/3/2: burrow, strike_jab, bramble_tide, thornbed
- forge_golem 8/4/1/1/3/3: strike_jab, crucible, raise_ground, immovable
- dusk_moth 2/9/3/2/2/2: glide, strike_jab, eclipse, shade_veil
- ember_hawk 2/9/3/2/2/2: glide, strike_jab, cinder_dive, shockwave
- grove_wisp 4/8/4/1/2/3: phase, strike_jab, spring_burst, gale
- hollow_serpent 7/4/2/1/3/3: burrow, strike_jab, coiling_rift, void_pull
- gloom_wolf 5/6/2/1/3/3: run, strike_jab, gloom_rift, mire
- moss_turtle 8/3/2/1/3/3: run, strike_jab, tidal_shell, bark_veil
- blaze_tiger 5/7/4/1/2/3: leap, strike_jab, magma_pounce, lava_field

**Kit set `6b9b5b7805d5`** (content `2026-11-11.1`): the same nine kits and definitions as `c0610a49270f`, not a content change. The fingerprint was made independent of the order in which definitions are loaded on 2026-11-11 ([temp_todo.md](temp_todo.md) I45); before that the same content could print different values from different tools. Runs after that change print this value.

**Kit set `a0dae446ce2a`** (content `2026-11-11.1`): the nine default kits of `6b9b5b7805d5` unchanged; the fingerprint differs because four experiment skills were added to the content (headbutt, quake_leap, shove, ambush_rift). The eleven simulation-only skills moved out of the price records are not part of the fingerprint.

**Kit set `a71108227eb4`** (content `2026-11-12.1`; HP/Init/Move/TPR/Reach/AP: slots): the kits live in the monster files (`godot/data/monsters`) since 2026-11-12.

- blaze_tiger 5/7/4/1/2/3: headbutt, strike_jab, magma_pounce, lava_field
- dusk_moth 2/9/3/2/2/2: glide, strike_jab, eclipse, shade_veil
- ember_hawk 2/9/3/2/2/2: glide, strike_jab, cinder_dive, shockwave
- forge_golem 8/4/1/1/3/3: strike_jab, shove, crucible, immovable
- gloom_wolf 5/6/2/1/3/3: run, strike_jab, gloom_rift, shove
- grove_wisp 4/8/4/1/2/3: quake_leap, strike_jab, spring_burst, gale
- hollow_serpent 7/4/2/1/3/3: burrow, strike_jab, coiling_rift, ambush_rift
- moss_turtle 8/3/2/1/3/3: run, strike_jab, tidal_shell, bark_veil
- thorn_mites 3/6/2/2/3/2: burrow, strike_jab, bramble_tide, thornbed

**Kit set `736eb4e604a6`** (content `2026-11-12.2`; HP/Init/Move/TPR/Reach/AP: slots): stats as in `a71108227eb4`; the trap is a skill kind of its own, two kits carry a prop-placing skill instead of Shove, and the props Vortex Urn and Storm Drum joined the seeded boards.

- blaze_tiger: headbutt, strike_jab, magma_pounce, lava_field
- dusk_moth: glide, strike_jab, eclipse, shade_veil
- ember_hawk: glide, strike_jab, cinder_dive, shockwave
- forge_golem: strike_jab, set_gong, crucible, immovable
- gloom_wolf: run, strike_jab, gloom_rift, plant_bamboo
- grove_wisp: quake_leap, strike_jab, spring_burst, gale
- hollow_serpent: burrow, strike_jab, coiling_rift, ambush_rift
- moss_turtle: run, strike_jab, tidal_shell, bark_veil
- thorn_mites: burrow, strike_jab, bramble_tide, thornbed

Kinds: strike_jab = strike · magma_pounce, cinder_dive, eclipse, gloom_rift, coiling_rift, tidal_shell = surge · crucible, ambush_rift, spring_burst, bramble_tide = trap · shade_veil, shockwave, gale, bark_veil = zone · lava_field, thornbed, set_gong, plant_bamboo = board · immovable = passive · the rest = move.

**Kit set `164984ea835f`** (content `2026-11-12.3`): as `736eb4e604a6` with two slots changed after the user decision of 2026-11-12 (no shield zone in a kit): moss_turtle carries `mire` (zone) instead of `bark_veil`, dusk_moth `blink` (move) instead of `shade_veil`. First used in S012.

**Kit set `230e32c911cc`** (content `2026-11-13.1`): the reshaped build without Surges and traps: 26 skills on the skill card, the nine kits of [gdd_skills.md §10](gdd_skills.md#10-kits-of-the-nine-monsters), spread test stats (S019). The fingerprint of the S018 runs (reshape with Surges still in the kits) was not noted.

**Kit set `6e152c78b752`** (content `2026-11-13.1`): stats and kits of `f4086ae48783`; the movement skills other than Run cover the full Movement stat and cost 2 AP (Glide, Burrow, Blink, Leap, Phase, Quake Leap, Headbutt; S016 Part D).

**Kit set `f4086ae48783`** (content `2026-11-13.1`; HP/Init/Move/TPR/Reach/AP: slots): the kits of `164984ea835f` with the stats of the draft prices of 2026-11-13 (S015 set C).

- blaze_tiger 7/7/5/1/2/3 · dusk_moth 5/7/3/1/4/3 · ember_hawk 5/9/5/2/2/3 · forge_golem 8/5/1/1/3/3 · gloom_wolf 6/9/3/1/3/3 · grove_wisp 5/9/5/1/3/3 · hollow_serpent 7/5/3/1/3/3 · moss_turtle 8/3/2/1/3/3 · thorn_mites 6/3/3/2/3/3

**Kit set `a30a9be42850`** (content `2026-11-13.1`; S020): current ten-monster pool (the nine named monsters plus the user experiment `asdf`), with more displacement in the kits and stat zones as extras. Includes the user skills `asdf`, `asdf_2`, `asdf_3` and Blaze Tiger slot 1 `new_skill`, deliberately preserved. The fingerprint identifies this content, not the earlier nine-kit set or a content approval.

# Entries

## S024 · 2026-11-14 · One Dragon Vein count control

State: `2828adf` dirty, inheriting prior work; regular fingerprint `a30a9be42850` and simulation resources unchanged; Godot 4.7.2. User: “was ist wenn wir die dragon veins auf 1 reduzieren?” `discovery.gd` scenario `single_vein` generates the existing three-vein board first, then before begin changes only the outer two WELL cells to Plain; centre (3,3) remains. Exact props, starts, occupants, teams, setup RNG state, authored stats and full HP retained. No new skills used; no skill/content/resource/core/default-game changes for this experiment.

**Scope:** 208 battle plays = 96 + 96 + 16. Each greedy cost condition uses the same 24 matched draws (seeds 601/602/603/604, six pairs each), side-swapped to 48 games/scenario. Stronger tactic uses four draws (601/603, two pairs each), eight games/scenario, the same greedy subset. Draws, swaps and conditions are correlated, not independent n. Normal `current-ap=1` and working `current-ap=2` set bilateral ZONE PUSH/PULL costs including Bog, not monster AP 2. The raw cost-1 boilerplate “NOT normal defaults” is misleading for the normal current costs.

| Bot / cost | Games/map | Control exact mean | Single exact mean | >5 control → single | Max control → single |
|---|---:|---:|---:|---:|---:|
| greedy / normal 1 AP | 48 | 117/48 = 2.4375 | 143/48 = 2.9791667 | 0 → 1 | 4 → 6 |
| greedy / working 2 AP | 48 | 145/48 = 3.0208333 | 185/48 = 3.8541667 | 0 → 4 | 5 → 8 |
| tactic / working 2 AP | 8 | 26/8 = 3.25 | 41/8 = 5.125 | 0 → 3 | 5 → 8 |

**Observations:**

- Means increase but tails widen. Normal-cost round-1 endings increase 1 → 3; pre-first-own-turn defeats remain 3 → 3. Both 2-AP blocks have 0 → 0 early defeats. One vein does not fix early bursts; tactic n=8 is limited.
- Vein HP damage falls 219 → 74, 295 → 117, 54 → 29 in table order. Less passive objective damage is evident; tactical benefit is not established.
- Collision/total HP damage: 645/1182 → 706/1203, 490/1245 → 562/1206, 74/203 → 71/198. No universal increase in collisions or concentration; spatial concentration was not isolated.
- No-own-turn defeats: 78 → 80, 76 → 67, 11 → 6. Definition: defeat after first positive damage without a subsequent own `turn_started`, regardless of prior turns. Descriptive, not fairness validation. Initiative, movement and holding fairness were not isolated.
- Single-vein blocks have no draws/timeouts; greedy controls have three draws each, tactic none. Do not generalize. Parent class `unilateral` is WRONG for this map-only intervention; the raw diagnostic footnote correctly says both teams receive it. A win rates are not map-quality scores.

**Checks/provenance:** discovery self-test 6930 passed / 0 failed, including 20 map-invariant seeds preserving props/RNG/occupants and a real central-vein round-damage fixture. No core change; the previous 158-case battle suite was NOT rerun this session. Three reports completed sequentially with one Idle-priority Godot 4.7.2 process, affinity `0xC` (2/32 CPUs); session execution record reports no active measurement processes at handoff. Raw reports retain own/parent harness and candidate hashes, schedule/map hashes and matching startup/final guards, not a full dirty-source identity. Prior docs/core/tests/tools/import metadata and simulation resources are inherited. All three raw reports were checked against the transcription below and match exactly after header removal; histogram means were recomputed. Final scoped diff check passed. Temporary reports, self-test and stderr were removed after verification.

**Follow-up:** T13/T39/T40: one central vein remains a candidate for focused human play against unchanged three-vein control, distinguishing reduced passive damage from tactical benefit. No rule/default adoption, price approval or task closure. Do not resume entry proxies/pricing as immediate focus. Human fun, agency, fairness and balance remain unvalidated.

### Complete raw reports

Copied full and unchanged except the Godot engine header and separator blank line. Generic unused candidate descriptions remain raw provenance.

#### vein_cost1.txt

```text
# Authored discovery experiment
AP/TPR/HP/Init/Movement/Reach are authored, full HP, no entry proxy. current-ap=1 is an explicit bilateral ZONE PUSH/PULL candidate (including Bog), NOT normal defaults. All skills use duplicate_deep ALL. Subject A is scored after both side swaps. No prices/budgets asserted.
Harness own SHA256=bb13dc7732c53df4421c237b92ab7a7e0439967ad266f08d3162440a2e09088f; parent SHA256=b40a5b2079d1012659f90c2a159c1a911dcbe4e3efc4b6c015b73858215fd38c; content=a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2; new resource hashes=cloudstep_token:97a751e9ce198fb1a6a41fae7b99428ea2e13abfafba861a20852d2867161e1e, mist_step:652b415efe17683a0e2e9f509e28a57ca27e3cf260ea1ad45fa1da9189af51eb, raise_reed_screen:9211eea71bc9671524d8541ffdbed88b28256aa73bbb94bfbb235e90021f1f84, receding_blow:b5daf6cb86c6da57a45d4800912150d6ecc35ee6d09b703f71db8c52858c50b1, reed_screen:a6f4b626ff57693209e07c1e3be292af26596920cfba07d892e42bb4c3adaba0; Godot=4.7.2-stable (official)
Maps: base uses canonical RUNNER seeded board. open removes every preplaced prop without aftermath, retains grounds/veins. screens replaces props with exactly two point-mirrored reed_screen pairs. split first relocates veins (1,3),(3,3),(5,3) -> (1,2),(3,3),(5,4), then uses the same screen generator. split_mist/cloud also replace subject movement. Props block movement only; NO ranged cover. No starter grass is added. Map RNG is local, seeded with setup seed; play/setup RNG is untouched by edits.
single_vein: remove only the two outer Dragon Veins after canonical setup, retaining the centre (3,3), all props, starts and RNG state. No candidate skills or stats change; maps affect both teams. The standard generator still runs first so prop availability cannot confound the count comparison.
Eligibility: first MOVE for mist/cloud; first positive-damage Jab with no board ops for receding, preserving kin_effect. Winged already retreats: retreat flag does not stack. Screen: first pure CREATE_PROP placement, else first GROUND, else last slot; no extra slots. Only subject changes except both_*. Both teams receive map edits. Schedule: same draw-A/draw-B-excluding-A/setup-seed progression scheme; fresh setup RNG each scenario/swap, divergent play may consume different RNG draws.
Ablation metadata: mist_control [no trail] / split_mist_control [no trail] replace the same first subject MOVE with a local deep copy of mist_step, clearing ONLY board_ops. Same 2 AP walk/profile; no trail or zone effect. split_mist_control uses identical split geometry. Candidate ID remains mist_step: usage/fielded-slot and round counts in these scenarios count the no-trail CONTROL, not zone-producing Mist Step.

| Seed | Pair | Subject A | Opponent B | Setup seed |
|---|---|---|---|---|
| 601 | 1 | dusk_moth,forge_golem,moss_turtle | hollow_serpent,grove_wisp,asdf | 518928252 |
| 601 | 2 | asdf,dusk_moth,forge_golem | thorn_mites,hollow_serpent,gloom_wolf | 1014583974 |
| 601 | 3 | blaze_tiger,forge_golem,grove_wisp | ember_hawk,moss_turtle,thorn_mites | 355343478 |
| 601 | 4 | hollow_serpent,gloom_wolf,ember_hawk | forge_golem,dusk_moth,grove_wisp | 158319496 |
| 601 | 5 | dusk_moth,gloom_wolf,hollow_serpent | forge_golem,blaze_tiger,thorn_mites | 385446219 |
| 601 | 6 | asdf,ember_hawk,moss_turtle | gloom_wolf,hollow_serpent,blaze_tiger | 230903882 |
| 602 | 1 | blaze_tiger,asdf,forge_golem | gloom_wolf,ember_hawk,hollow_serpent | 151641272 |
| 602 | 2 | dusk_moth,moss_turtle,thorn_mites | gloom_wolf,blaze_tiger,asdf | 878776238 |
| 602 | 3 | grove_wisp,hollow_serpent,thorn_mites | dusk_moth,moss_turtle,forge_golem | 6309918 |
| 602 | 4 | blaze_tiger,dusk_moth,ember_hawk | moss_turtle,grove_wisp,hollow_serpent | 318827221 |
| 602 | 5 | moss_turtle,blaze_tiger,gloom_wolf | grove_wisp,asdf,forge_golem | 509683254 |
| 602 | 6 | moss_turtle,blaze_tiger,forge_golem | ember_hawk,asdf,dusk_moth | 581836585 |
| 603 | 1 | forge_golem,hollow_serpent,grove_wisp | thorn_mites,ember_hawk,gloom_wolf | 541050160 |
| 603 | 2 | hollow_serpent,dusk_moth,gloom_wolf | grove_wisp,ember_hawk,blaze_tiger | 723901636 |
| 603 | 3 | grove_wisp,ember_hawk,thorn_mites | gloom_wolf,forge_golem,asdf | 229359199 |
| 603 | 4 | gloom_wolf,ember_hawk,moss_turtle | thorn_mites,blaze_tiger,forge_golem | 236011681 |
| 603 | 5 | hollow_serpent,blaze_tiger,ember_hawk | grove_wisp,forge_golem,gloom_wolf | 313660701 |
| 603 | 6 | ember_hawk,blaze_tiger,grove_wisp | moss_turtle,thorn_mites,gloom_wolf | 530664296 |
| 604 | 1 | ember_hawk,forge_golem,asdf | dusk_moth,moss_turtle,thorn_mites | 815298013 |
| 604 | 2 | hollow_serpent,moss_turtle,ember_hawk | asdf,forge_golem,gloom_wolf | 787929172 |
| 604 | 3 | grove_wisp,asdf,hollow_serpent | moss_turtle,forge_golem,thorn_mites | 783642416 |
| 604 | 4 | grove_wisp,hollow_serpent,moss_turtle | gloom_wolf,asdf,forge_golem | 313471704 |
| 604 | 5 | ember_hawk,blaze_tiger,moss_turtle | forge_golem,grove_wisp,gloom_wolf | 712043216 |
| 604 | 6 | blaze_tiger,asdf,moss_turtle | ember_hawk,grove_wisp,forge_golem | 827265812 |
Schedule SHA256=4d7843ceecf0972b2c50a659894dd739c7218ed7446d8d071ac8447cb83229fe

## Aggregate

Score=(wins+0.5×true draws)/(games−timeouts); timeouts separate. Rounds include timeout partial rounds; histograms allow exact weighted means. Defeat/damage/activation metrics cover BOTH teams; first-defeat turns count turn_started events through the first defeat, omitting games with none. Collision is collision HP damage (not collision events). Repeat=second/later activation of same actor+skill within one turn, including slotted movement, excluding Step; event fallback matches sim.gd, not distinct slot identity.

| Scenario | Class | Games | A W/L/D/timeout | Score | Mean rounds | <2/>5/max | Pre-first-turn defeats/games | Turns to first defeat (n) | Collision/total damage | Repeats/activations | Round histogram |
|---|---|---|---|---|---|---|---|---|---|---|---|
| base | control | 48 | 21/24/3/0 | 0.47 | 2.44 | 1/0/4 | 3/3 | 4.67 (48) | 645/1182 | 332/1141 (0.29) | 1:1, 2:28, 3:16, 4:3 |
| single_vein | unilateral | 48 | 25/23/0/0 | 0.52 | 2.98 | 3/1/6 | 3/3 | 4.50 (48) | 706/1203 | 339/1226 (0.28) | 1:3, 2:13, 3:19, 4:9, 5:3, 6:1 |

## Start affordability and actual interventions

Both teams pooled, repeated per game. Affordability only: cost≤sheet AP, NOT target legality; no assumption that a low-stage kit should be fully affordable. Move/attack counts units with an affordable slotted MOVE/damaging STRIKE (not universal Step). Stat deltas: attempted/applied sum/changed count/cap-blocked count, per upgraded member. strike_ground: eligible damaging STRIKE attempts/applied/not_applied (existing ground); proposed content variant, not an approved slot choice. No rounding of exact counts.

| Scenario | Affordable/active slots | No affordable active/units | Has move/attack | Unaffordable ID:slot count | Stat delta attempted/sum/changed/blocked | strike_ground counts |
|---|---|---|---|---|---|---|
| base | 1152/1152 | 0/288 | 250/236 | — | — | — |
| single_vein | 1152/1152 | 0/288 | 250/236 | — | — | — |

## Active skill usage

All equipped active IDs, not just top skills; activations/start slots pooled over both teams and games (not success rates).

| Scenario | ID:activations/start slots |
|---|---|
| base | cinder_dive:1/32, snare:1/20, asdf:6/26, thornbed:39/106, set_gong:2/38, new_skill:4/28, gale:208/100, asdf_3:89/26, bog:80/32, thorn_lash:11/32, asdf_2:53/26, plant_bamboo:10/32, fire_trail:42/28, shove:3/64, void_pull:95/74, quake_leap:31/30, strike_thrust:4/38, strike_jab:84/178, run:220/112, lava_field:44/28, glide:60/54, gloom_rift:46/20, coiling_rift:8/28 |
| single_vein | cinder_dive:1/32, snare:0/20, asdf:11/26, thornbed:44/106, set_gong:3/38, new_skill:9/28, gale:236/100, asdf_3:84/26, bog:105/32, thorn_lash:15/32, asdf_2:44/26, plant_bamboo:12/32, fire_trail:38/28, shove:6/64, void_pull:127/74, quake_leap:33/30, strike_thrust:11/38, strike_jab:79/178, run:224/112, lava_field:30/28, glide:56/54, gloom_rift:36/20, coiling_rift:22/28 |

Limitations: small, bot- and roster-dependent teamwide interventions; paired draws are not independent per swap. Not human agency/fun/fairness validation, single-monster causal odds, equal-price comparisons, approved progression or balance/price evidence.

## Discovery diagnostics (both teams pooled)
No-own-turn = defeat after FIRST positive damage without a subsequent turn_started for that victim; prior turns do not count. Descriptive response-window metric, NOT an unfairness verdict. Candidate counts are activations/actual fielded slots, not successful effects. Round counts use event round_started. Map fingerprints cover pre-begin grounds/props, excluding units. Parent unilateral class label does not apply to map-only scenarios: maps affect both teams.
| Scenario | Eligible/unchanged units | Applied slots | Species old→new ledger | No-own-turn defeats/battles | Candidate uses/fielded slots | Candidate activations by round | Battles using candidate | Well/flank HP damage | Map SHA256s |
|---|---|---|---|---|---|---|---|---|---|
| base | 0/288 | 0 | — | 78/47 | — | — | 0/48 | 219/20 | 004ff4b1db650cadf84a9ab70c497415d9922417d0ff4e45b8150a368b21cd99:true, 096dab1b3f0aa5619362c4ad815bdd707d98980f7939d00019eddfbf25a092c9:true, 144252b11a4aa19fce0d57b2f2561b9308ff2d8d5b2594151901bf9c86b8e3df:true, 2a932891dc3f801d7675024c0a57d04d6ddbbcdb7fc9a2993d7076e55bfeb9f2:true, 3d10633f477903dda16cd6b5a2b495017612f6721b045d015432f487a7b5cd73:true, 3f0697fd9bb2dd8ab2d5d09c99c047b6c198745801c151c60713199f0da703ce:true, 46b3bd8346b43757a5bf1d9191a94087c95fd6f69800d94ebcff53207fe76706:true, 57207e38d4e4835b3ef0e4587d7aa6401c4025e9fc41364b2773912889fa3229:true, 593ab7dc8867cbd48004291bdfb73c36c24e4f88e70241468adbc6ed916370c1:true, 6386555d029defdb2a91dea1b2bcc291470f4ba846622aaf0fafe0227bf8a8b4:true, 7975c5409bed571e09909c80e0aef54969f11b70dc17ad978e026de8d5fb3aaf:true, 826c6e15346f822fc0a3129a0fc8eb13e1c6efe752a8e010cb3b9f9c1c740917:true, 83272b53bafa517b64275b0de780e57d42a594e7399909f65e5338c273503541:true, 88b595c56ff5925f913bae612184a2c3fe4cb68a0309a07ea91e44d885e0f482:true, 895b408d0bf0b3d7483f0a574fcf79a80a8a7acb6f65c7e5cc9cee896a10a891:true, 92efa68d4db53b2fec5ea42c550e5f06c6eef364ea0ca30e3efd4ba69854175a:true, 9f420c29ea826b93b2c38c74f0a8f489eb26e7aa82b9971cb896cf1fe407814b:true, aa108d41dd83035d876c83e491d873a8427b0d20e2b8a70e4c9ccddb24ba8cae:true, c0fc06db236c9be3380f9670d7445cdc9d258a7b77ff13c27269e02bc204c7a6:true, d33d79293d03cda5a32111e199ae813e636bd00e4ba60b5ecf888dbb3eeb7364:true, d60729d6f1c201e23975c6f533abfdfb6f65dd4cae870eeea15a1dc09c9145e8:true, de4bb75251655946b4ecf991a74cbc8e1fa548c64671e6ea3d59481514e17bbd:true, ee62aea141f527bcd739280518ec1f8e02fece14383192ad63534bfa4d008ee9:true, fd8840c64f2399550d0918ec3b1fafa45c0fba50f16d4ef3b0e834ef4868878f:true |
| single_vein | 0/288 | 0 | — | 80/48 | — | — | 0/48 | 74/13 | 0117daac010b767f916aa4f15838d7403f7dc63d2b2c1b9f4c2a401055c1f3c4:true, 06ca38f7f6ce8738464175e878812974c1c7a21390bf0ea255713f674e4f7da6:true, 11ae349528ae8649f51914652fa1a716f3b137444e3ac6f6a9475607432f6b8f:true, 2ed6e35421bc16bb088bf8210d2b4508475c3a734f9afdf21aaa1db0ec4c8dd4:true, 4b985b391661843dd14ab077d6a8f9038ee4842c34081955e2d894cd06d095b3:true, 525e54da4e3f6df82bbacab284e031f1ef3fda252084ccff5945cbb53fd65b92:true, 57585e5d013f28f1081f31607ebe8f5dd82032fe7034aa04e605fe7654fbca6d:true, 6c8775f4c0be35cd053acaf72f558f0579c4001728b863e5caa7c8013f6316a7:true, 6d1c262541b6f59e50c3f954398d341ce859978edba229734503609df663e5a7:true, 72676663ace996ec63ad50ade34dd8defbdb9c644cb3ac7c09c8e33090304b39:true, 72f84eb9a5001c8cc058acecf75ab18710a81d0ccadb51c7a40962c6a505e2c3:true, 79ed9a9d593f99759d2b5accdabf9cdbcde0b5e4187c16c59b79e759d99ebe4e:true, 7e021c71b851997bd35d197d9eb44b68b568457451daa6b51c3a7c061fa56650:true, 94d96eccfe002f9cc93576637c99a7bfb2bae69f41b2928b69d0571c072d3dd0:true, 99f1549acce7b4f9c15aaa4021479ebea04498080a9ea2a77bb0ef2e200cf3a4:true, 9eeee7fd98c4755689028b62843cb55a94e85cf714563af072244ba091a47407:true, a180c93375f39a4caf38ffb3c67773834cc8c50fb0c4295496e1b11a920a6408:true, a72fbf435510758c82d910f3fd36dd53498df7766940ff93eff9683738f7c891:true, aa5c92a1924de77934bd33b2f065ef3f965aa0dc59b30ca770d2ea79892d0008:true, bab4a28fcd3e95e40033d3b4a7b0e31019d9f924a2ef80846249c0d4117f847f:true, c7d5ee513f5588b340c1216d65c6209db752d1ea5a5bd7a1b24553fd341ca362:true, dcbb60d3694af3a88e8d310e82313dd0c4b9b87d4dc11bdc1b7a7736cf2a1b31:true, e983b77207eee494af6b883142e802467467df472569b0a19a66f8b412c36ec0:true, e9ea4c67bb74a11219ac32e940a50fc0906efe596cf5e132bc1780d7c2f48b06:true |
DISCOVERY_MEASUREMENT_COMPLETED: final guard matches startup content=a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2 resources=cloudstep_token:97a751e9ce198fb1a6a41fae7b99428ea2e13abfafba861a20852d2867161e1e, mist_step:652b415efe17683a0e2e9f509e28a57ca27e3cf260ea1ad45fa1da9189af51eb, raise_reed_screen:9211eea71bc9671524d8541ffdbed88b28256aa73bbb94bfbb235e90021f1f84, receding_blow:b5daf6cb86c6da57a45d4800912150d6ecc35ee6d09b703f71db8c52858c50b1, reed_screen:a6f4b626ff57693209e07c1e3be292af26596920cfba07d892e42bb4c3adaba0
```

#### vein_cost2.txt

```text
# Authored discovery experiment
AP/TPR/HP/Init/Movement/Reach are authored, full HP, no entry proxy. current-ap=2 is an explicit bilateral ZONE PUSH/PULL candidate (including Bog), NOT normal defaults. All skills use duplicate_deep ALL. Subject A is scored after both side swaps. No prices/budgets asserted.
Harness own SHA256=bb13dc7732c53df4421c237b92ab7a7e0439967ad266f08d3162440a2e09088f; parent SHA256=b40a5b2079d1012659f90c2a159c1a911dcbe4e3efc4b6c015b73858215fd38c; content=a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2; new resource hashes=cloudstep_token:97a751e9ce198fb1a6a41fae7b99428ea2e13abfafba861a20852d2867161e1e, mist_step:652b415efe17683a0e2e9f509e28a57ca27e3cf260ea1ad45fa1da9189af51eb, raise_reed_screen:9211eea71bc9671524d8541ffdbed88b28256aa73bbb94bfbb235e90021f1f84, receding_blow:b5daf6cb86c6da57a45d4800912150d6ecc35ee6d09b703f71db8c52858c50b1, reed_screen:a6f4b626ff57693209e07c1e3be292af26596920cfba07d892e42bb4c3adaba0; Godot=4.7.2-stable (official)
Maps: base uses canonical RUNNER seeded board. open removes every preplaced prop without aftermath, retains grounds/veins. screens replaces props with exactly two point-mirrored reed_screen pairs. split first relocates veins (1,3),(3,3),(5,3) -> (1,2),(3,3),(5,4), then uses the same screen generator. split_mist/cloud also replace subject movement. Props block movement only; NO ranged cover. No starter grass is added. Map RNG is local, seeded with setup seed; play/setup RNG is untouched by edits.
single_vein: remove only the two outer Dragon Veins after canonical setup, retaining the centre (3,3), all props, starts and RNG state. No candidate skills or stats change; maps affect both teams. The standard generator still runs first so prop availability cannot confound the count comparison.
Eligibility: first MOVE for mist/cloud; first positive-damage Jab with no board ops for receding, preserving kin_effect. Winged already retreats: retreat flag does not stack. Screen: first pure CREATE_PROP placement, else first GROUND, else last slot; no extra slots. Only subject changes except both_*. Both teams receive map edits. Schedule: same draw-A/draw-B-excluding-A/setup-seed progression scheme; fresh setup RNG each scenario/swap, divergent play may consume different RNG draws.
Ablation metadata: mist_control [no trail] / split_mist_control [no trail] replace the same first subject MOVE with a local deep copy of mist_step, clearing ONLY board_ops. Same 2 AP walk/profile; no trail or zone effect. split_mist_control uses identical split geometry. Candidate ID remains mist_step: usage/fielded-slot and round counts in these scenarios count the no-trail CONTROL, not zone-producing Mist Step.

| Seed | Pair | Subject A | Opponent B | Setup seed |
|---|---|---|---|---|
| 601 | 1 | dusk_moth,forge_golem,moss_turtle | hollow_serpent,grove_wisp,asdf | 518928252 |
| 601 | 2 | asdf,dusk_moth,forge_golem | thorn_mites,hollow_serpent,gloom_wolf | 1014583974 |
| 601 | 3 | blaze_tiger,forge_golem,grove_wisp | ember_hawk,moss_turtle,thorn_mites | 355343478 |
| 601 | 4 | hollow_serpent,gloom_wolf,ember_hawk | forge_golem,dusk_moth,grove_wisp | 158319496 |
| 601 | 5 | dusk_moth,gloom_wolf,hollow_serpent | forge_golem,blaze_tiger,thorn_mites | 385446219 |
| 601 | 6 | asdf,ember_hawk,moss_turtle | gloom_wolf,hollow_serpent,blaze_tiger | 230903882 |
| 602 | 1 | blaze_tiger,asdf,forge_golem | gloom_wolf,ember_hawk,hollow_serpent | 151641272 |
| 602 | 2 | dusk_moth,moss_turtle,thorn_mites | gloom_wolf,blaze_tiger,asdf | 878776238 |
| 602 | 3 | grove_wisp,hollow_serpent,thorn_mites | dusk_moth,moss_turtle,forge_golem | 6309918 |
| 602 | 4 | blaze_tiger,dusk_moth,ember_hawk | moss_turtle,grove_wisp,hollow_serpent | 318827221 |
| 602 | 5 | moss_turtle,blaze_tiger,gloom_wolf | grove_wisp,asdf,forge_golem | 509683254 |
| 602 | 6 | moss_turtle,blaze_tiger,forge_golem | ember_hawk,asdf,dusk_moth | 581836585 |
| 603 | 1 | forge_golem,hollow_serpent,grove_wisp | thorn_mites,ember_hawk,gloom_wolf | 541050160 |
| 603 | 2 | hollow_serpent,dusk_moth,gloom_wolf | grove_wisp,ember_hawk,blaze_tiger | 723901636 |
| 603 | 3 | grove_wisp,ember_hawk,thorn_mites | gloom_wolf,forge_golem,asdf | 229359199 |
| 603 | 4 | gloom_wolf,ember_hawk,moss_turtle | thorn_mites,blaze_tiger,forge_golem | 236011681 |
| 603 | 5 | hollow_serpent,blaze_tiger,ember_hawk | grove_wisp,forge_golem,gloom_wolf | 313660701 |
| 603 | 6 | ember_hawk,blaze_tiger,grove_wisp | moss_turtle,thorn_mites,gloom_wolf | 530664296 |
| 604 | 1 | ember_hawk,forge_golem,asdf | dusk_moth,moss_turtle,thorn_mites | 815298013 |
| 604 | 2 | hollow_serpent,moss_turtle,ember_hawk | asdf,forge_golem,gloom_wolf | 787929172 |
| 604 | 3 | grove_wisp,asdf,hollow_serpent | moss_turtle,forge_golem,thorn_mites | 783642416 |
| 604 | 4 | grove_wisp,hollow_serpent,moss_turtle | gloom_wolf,asdf,forge_golem | 313471704 |
| 604 | 5 | ember_hawk,blaze_tiger,moss_turtle | forge_golem,grove_wisp,gloom_wolf | 712043216 |
| 604 | 6 | blaze_tiger,asdf,moss_turtle | ember_hawk,grove_wisp,forge_golem | 827265812 |
Schedule SHA256=4d7843ceecf0972b2c50a659894dd739c7218ed7446d8d071ac8447cb83229fe

## Aggregate

Score=(wins+0.5×true draws)/(games−timeouts); timeouts separate. Rounds include timeout partial rounds; histograms allow exact weighted means. Defeat/damage/activation metrics cover BOTH teams; first-defeat turns count turn_started events through the first defeat, omitting games with none. Collision is collision HP damage (not collision events). Repeat=second/later activation of same actor+skill within one turn, including slotted movement, excluding Step; event fallback matches sim.gd, not distinct slot identity.

| Scenario | Class | Games | A W/L/D/timeout | Score | Mean rounds | <2/>5/max | Pre-first-turn defeats/games | Turns to first defeat (n) | Collision/total damage | Repeats/activations | Round histogram |
|---|---|---|---|---|---|---|---|---|---|---|---|
| base | control | 48 | 24/21/3/0 | 0.53 | 3.02 | 0/0/5 | 0/0 | 5.75 (48) | 490/1245 | 128/1105 (0.12) | 2:11, 3:27, 4:8, 5:2 |
| single_vein | unilateral | 48 | 23/25/0/0 | 0.48 | 3.85 | 0/4/8 | 0/0 | 6.21 (48) | 562/1206 | 135/1268 (0.11) | 2:4, 3:20, 4:10, 5:10, 6:2, 7:1, 8:1 |

## Start affordability and actual interventions

Both teams pooled, repeated per game. Affordability only: cost≤sheet AP, NOT target legality; no assumption that a low-stage kit should be fully affordable. Move/attack counts units with an affordable slotted MOVE/damaging STRIKE (not universal Step). Stat deltas: attempted/applied sum/changed count/cap-blocked count, per upgraded member. strike_ground: eligible damaging STRIKE attempts/applied/not_applied (existing ground); proposed content variant, not an approved slot choice. No rounding of exact counts.

| Scenario | Affordable/active slots | No affordable active/units | Has move/attack | Unaffordable ID:slot count | Stat delta attempted/sum/changed/blocked | strike_ground counts |
|---|---|---|---|---|---|---|
| base | 1152/1152 | 0/288 | 250/236 | — | — | — |
| single_vein | 1152/1152 | 0/288 | 250/236 | — | — | — |

## Active skill usage

All equipped active IDs, not just top skills; activations/start slots pooled over both teams and games (not success rates).

| Scenario | ID:activations/start slots |
|---|---|
| base | cinder_dive:0/32, snare:1/20, asdf:9/26, thornbed:72/106, set_gong:17/38, new_skill:11/28, gale:99/100, asdf_3:38/26, bog:40/32, thorn_lash:29/32, asdf_2:64/26, plant_bamboo:11/32, fire_trail:43/28, shove:7/64, void_pull:68/74, quake_leap:32/30, strike_thrust:14/38, strike_jab:91/178, run:269/112, lava_field:46/28, glide:77/54, gloom_rift:45/20, coiling_rift:22/28 |
| single_vein | cinder_dive:0/32, snare:0/20, asdf:10/26, thornbed:95/106, set_gong:24/38, new_skill:10/28, gale:155/100, asdf_3:49/26, bog:45/32, thorn_lash:32/32, asdf_2:53/26, plant_bamboo:18/32, fire_trail:41/28, shove:2/64, void_pull:111/74, quake_leap:33/30, strike_thrust:9/38, strike_jab:99/178, run:269/112, lava_field:51/28, glide:80/54, gloom_rift:55/20, coiling_rift:27/28 |

Limitations: small, bot- and roster-dependent teamwide interventions; paired draws are not independent per swap. Not human agency/fun/fairness validation, single-monster causal odds, equal-price comparisons, approved progression or balance/price evidence.

## Discovery diagnostics (both teams pooled)
No-own-turn = defeat after FIRST positive damage without a subsequent turn_started for that victim; prior turns do not count. Descriptive response-window metric, NOT an unfairness verdict. Candidate counts are activations/actual fielded slots, not successful effects. Round counts use event round_started. Map fingerprints cover pre-begin grounds/props, excluding units. Parent unilateral class label does not apply to map-only scenarios: maps affect both teams.
| Scenario | Eligible/unchanged units | Applied slots | Species old→new ledger | No-own-turn defeats/battles | Candidate uses/fielded slots | Candidate activations by round | Battles using candidate | Well/flank HP damage | Map SHA256s |
|---|---|---|---|---|---|---|---|---|---|
| base | 0/288 | 0 | — | 76/41 | — | — | 0/48 | 295/36 | 004ff4b1db650cadf84a9ab70c497415d9922417d0ff4e45b8150a368b21cd99:true, 096dab1b3f0aa5619362c4ad815bdd707d98980f7939d00019eddfbf25a092c9:true, 144252b11a4aa19fce0d57b2f2561b9308ff2d8d5b2594151901bf9c86b8e3df:true, 2a932891dc3f801d7675024c0a57d04d6ddbbcdb7fc9a2993d7076e55bfeb9f2:true, 3d10633f477903dda16cd6b5a2b495017612f6721b045d015432f487a7b5cd73:true, 3f0697fd9bb2dd8ab2d5d09c99c047b6c198745801c151c60713199f0da703ce:true, 46b3bd8346b43757a5bf1d9191a94087c95fd6f69800d94ebcff53207fe76706:true, 57207e38d4e4835b3ef0e4587d7aa6401c4025e9fc41364b2773912889fa3229:true, 593ab7dc8867cbd48004291bdfb73c36c24e4f88e70241468adbc6ed916370c1:true, 6386555d029defdb2a91dea1b2bcc291470f4ba846622aaf0fafe0227bf8a8b4:true, 7975c5409bed571e09909c80e0aef54969f11b70dc17ad978e026de8d5fb3aaf:true, 826c6e15346f822fc0a3129a0fc8eb13e1c6efe752a8e010cb3b9f9c1c740917:true, 83272b53bafa517b64275b0de780e57d42a594e7399909f65e5338c273503541:true, 88b595c56ff5925f913bae612184a2c3fe4cb68a0309a07ea91e44d885e0f482:true, 895b408d0bf0b3d7483f0a574fcf79a80a8a7acb6f65c7e5cc9cee896a10a891:true, 92efa68d4db53b2fec5ea42c550e5f06c6eef364ea0ca30e3efd4ba69854175a:true, 9f420c29ea826b93b2c38c74f0a8f489eb26e7aa82b9971cb896cf1fe407814b:true, aa108d41dd83035d876c83e491d873a8427b0d20e2b8a70e4c9ccddb24ba8cae:true, c0fc06db236c9be3380f9670d7445cdc9d258a7b77ff13c27269e02bc204c7a6:true, d33d79293d03cda5a32111e199ae813e636bd00e4ba60b5ecf888dbb3eeb7364:true, d60729d6f1c201e23975c6f533abfdfb6f65dd4cae870eeea15a1dc09c9145e8:true, de4bb75251655946b4ecf991a74cbc8e1fa548c64671e6ea3d59481514e17bbd:true, ee62aea141f527bcd739280518ec1f8e02fece14383192ad63534bfa4d008ee9:true, fd8840c64f2399550d0918ec3b1fafa45c0fba50f16d4ef3b0e834ef4868878f:true |
| single_vein | 0/288 | 0 | — | 67/39 | — | — | 0/48 | 117/30 | 0117daac010b767f916aa4f15838d7403f7dc63d2b2c1b9f4c2a401055c1f3c4:true, 06ca38f7f6ce8738464175e878812974c1c7a21390bf0ea255713f674e4f7da6:true, 11ae349528ae8649f51914652fa1a716f3b137444e3ac6f6a9475607432f6b8f:true, 2ed6e35421bc16bb088bf8210d2b4508475c3a734f9afdf21aaa1db0ec4c8dd4:true, 4b985b391661843dd14ab077d6a8f9038ee4842c34081955e2d894cd06d095b3:true, 525e54da4e3f6df82bbacab284e031f1ef3fda252084ccff5945cbb53fd65b92:true, 57585e5d013f28f1081f31607ebe8f5dd82032fe7034aa04e605fe7654fbca6d:true, 6c8775f4c0be35cd053acaf72f558f0579c4001728b863e5caa7c8013f6316a7:true, 6d1c262541b6f59e50c3f954398d341ce859978edba229734503609df663e5a7:true, 72676663ace996ec63ad50ade34dd8defbdb9c644cb3ac7c09c8e33090304b39:true, 72f84eb9a5001c8cc058acecf75ab18710a81d0ccadb51c7a40962c6a505e2c3:true, 79ed9a9d593f99759d2b5accdabf9cdbcde0b5e4187c16c59b79e759d99ebe4e:true, 7e021c71b851997bd35d197d9eb44b68b568457451daa6b51c3a7c061fa56650:true, 94d96eccfe002f9cc93576637c99a7bfb2bae69f41b2928b69d0571c072d3dd0:true, 99f1549acce7b4f9c15aaa4021479ebea04498080a9ea2a77bb0ef2e200cf3a4:true, 9eeee7fd98c4755689028b62843cb55a94e85cf714563af072244ba091a47407:true, a180c93375f39a4caf38ffb3c67773834cc8c50fb0c4295496e1b11a920a6408:true, a72fbf435510758c82d910f3fd36dd53498df7766940ff93eff9683738f7c891:true, aa5c92a1924de77934bd33b2f065ef3f965aa0dc59b30ca770d2ea79892d0008:true, bab4a28fcd3e95e40033d3b4a7b0e31019d9f924a2ef80846249c0d4117f847f:true, c7d5ee513f5588b340c1216d65c6209db752d1ea5a5bd7a1b24553fd341ca362:true, dcbb60d3694af3a88e8d310e82313dd0c4b9b87d4dc11bdc1b7a7736cf2a1b31:true, e983b77207eee494af6b883142e802467467df472569b0a19a66f8b412c36ec0:true, e9ea4c67bb74a11219ac32e940a50fc0906efe596cf5e132bc1780d7c2f48b06:true |
DISCOVERY_MEASUREMENT_COMPLETED: final guard matches startup content=a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2 resources=cloudstep_token:97a751e9ce198fb1a6a41fae7b99428ea2e13abfafba861a20852d2867161e1e, mist_step:652b415efe17683a0e2e9f509e28a57ca27e3cf260ea1ad45fa1da9189af51eb, raise_reed_screen:9211eea71bc9671524d8541ffdbed88b28256aa73bbb94bfbb235e90021f1f84, receding_blow:b5daf6cb86c6da57a45d4800912150d6ecc35ee6d09b703f71db8c52858c50b1, reed_screen:a6f4b626ff57693209e07c1e3be292af26596920cfba07d892e42bb4c3adaba0
```

#### vein_tactic.txt

```text
# Authored discovery experiment
AP/TPR/HP/Init/Movement/Reach are authored, full HP, no entry proxy. current-ap=2 is an explicit bilateral ZONE PUSH/PULL candidate (including Bog), NOT normal defaults. All skills use duplicate_deep ALL. Subject A is scored after both side swaps. No prices/budgets asserted.
Harness own SHA256=bb13dc7732c53df4421c237b92ab7a7e0439967ad266f08d3162440a2e09088f; parent SHA256=b40a5b2079d1012659f90c2a159c1a911dcbe4e3efc4b6c015b73858215fd38c; content=a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2; new resource hashes=cloudstep_token:97a751e9ce198fb1a6a41fae7b99428ea2e13abfafba861a20852d2867161e1e, mist_step:652b415efe17683a0e2e9f509e28a57ca27e3cf260ea1ad45fa1da9189af51eb, raise_reed_screen:9211eea71bc9671524d8541ffdbed88b28256aa73bbb94bfbb235e90021f1f84, receding_blow:b5daf6cb86c6da57a45d4800912150d6ecc35ee6d09b703f71db8c52858c50b1, reed_screen:a6f4b626ff57693209e07c1e3be292af26596920cfba07d892e42bb4c3adaba0; Godot=4.7.2-stable (official)
Maps: base uses canonical RUNNER seeded board. open removes every preplaced prop without aftermath, retains grounds/veins. screens replaces props with exactly two point-mirrored reed_screen pairs. split first relocates veins (1,3),(3,3),(5,3) -> (1,2),(3,3),(5,4), then uses the same screen generator. split_mist/cloud also replace subject movement. Props block movement only; NO ranged cover. No starter grass is added. Map RNG is local, seeded with setup seed; play/setup RNG is untouched by edits.
single_vein: remove only the two outer Dragon Veins after canonical setup, retaining the centre (3,3), all props, starts and RNG state. No candidate skills or stats change; maps affect both teams. The standard generator still runs first so prop availability cannot confound the count comparison.
Eligibility: first MOVE for mist/cloud; first positive-damage Jab with no board ops for receding, preserving kin_effect. Winged already retreats: retreat flag does not stack. Screen: first pure CREATE_PROP placement, else first GROUND, else last slot; no extra slots. Only subject changes except both_*. Both teams receive map edits. Schedule: same draw-A/draw-B-excluding-A/setup-seed progression scheme; fresh setup RNG each scenario/swap, divergent play may consume different RNG draws.
Ablation metadata: mist_control [no trail] / split_mist_control [no trail] replace the same first subject MOVE with a local deep copy of mist_step, clearing ONLY board_ops. Same 2 AP walk/profile; no trail or zone effect. split_mist_control uses identical split geometry. Candidate ID remains mist_step: usage/fielded-slot and round counts in these scenarios count the no-trail CONTROL, not zone-producing Mist Step.

| Seed | Pair | Subject A | Opponent B | Setup seed |
|---|---|---|---|---|
| 601 | 1 | dusk_moth,forge_golem,moss_turtle | hollow_serpent,grove_wisp,asdf | 518928252 |
| 601 | 2 | asdf,dusk_moth,forge_golem | thorn_mites,hollow_serpent,gloom_wolf | 1014583974 |
| 603 | 1 | forge_golem,hollow_serpent,grove_wisp | thorn_mites,ember_hawk,gloom_wolf | 541050160 |
| 603 | 2 | hollow_serpent,dusk_moth,gloom_wolf | grove_wisp,ember_hawk,blaze_tiger | 723901636 |
Schedule SHA256=3d7be2fd3685fbbcb20e31dad76b8394e15bed85e8a15f2e8d4cb41211c3a63b

## Aggregate

Score=(wins+0.5×true draws)/(games−timeouts); timeouts separate. Rounds include timeout partial rounds; histograms allow exact weighted means. Defeat/damage/activation metrics cover BOTH teams; first-defeat turns count turn_started events through the first defeat, omitting games with none. Collision is collision HP damage (not collision events). Repeat=second/later activation of same actor+skill within one turn, including slotted movement, excluding Step; event fallback matches sim.gd, not distinct slot identity.

| Scenario | Class | Games | A W/L/D/timeout | Score | Mean rounds | <2/>5/max | Pre-first-turn defeats/games | Turns to first defeat (n) | Collision/total damage | Repeats/activations | Round histogram |
|---|---|---|---|---|---|---|---|---|---|---|---|
| base | control | 8 | 7/1/0/0 | 0.88 | 3.25 | 0/0/5 | 0/0 | 7.50 (8) | 74/203 | 31/190 (0.16) | 2:1, 3:5, 4:1, 5:1 |
| single_vein | unilateral | 8 | 7/1/0/0 | 0.88 | 5.13 | 0/3/8 | 0/0 | 9.88 (8) | 71/198 | 37/262 (0.14) | 3:2, 4:1, 5:2, 6:1, 7:1, 8:1 |

## Start affordability and actual interventions

Both teams pooled, repeated per game. Affordability only: cost≤sheet AP, NOT target legality; no assumption that a low-stage kit should be fully affordable. Move/attack counts units with an affordable slotted MOVE/damaging STRIKE (not universal Step). Stat deltas: attempted/applied sum/changed count/cap-blocked count, per upgraded member. strike_ground: eligible damaging STRIKE attempts/applied/not_applied (existing ground); proposed content variant, not an approved slot choice. No rounding of exact counts.

| Scenario | Affordable/active slots | No affordable active/units | Has move/attack | Unaffordable ID:slot count | Stat delta attempted/sum/changed/blocked | strike_ground counts |
|---|---|---|---|---|---|---|
| base | 192/192 | 0/48 | 42/40 | — | — | — |
| single_vein | 192/192 | 0/48 | 42/40 | — | — | — |

## Active skill usage

All equipped active IDs, not just top skills; activations/start slots pooled over both teams and games (not success rates).

| Scenario | ID:activations/start slots |
|---|---|
| base | cinder_dive:0/4, snare:0/6, asdf:0/4, thornbed:21/22, set_gong:2/6, new_skill:0/2, gale:15/16, asdf_3:5/4, bog:6/2, thorn_lash:5/6, asdf_2:10/4, plant_bamboo:2/6, fire_trail:2/2, shove:0/8, void_pull:14/12, quake_leap:5/6, strike_thrust:0/6, strike_jab:19/30, run:54/22, lava_field:3/2, glide:19/8, gloom_rift:7/6, coiling_rift:1/8 |
| single_vein | cinder_dive:1/4, snare:0/6, asdf:0/4, thornbed:39/22, set_gong:8/6, new_skill:0/2, gale:23/16, asdf_3:7/4, bog:5/2, thorn_lash:6/6, asdf_2:11/4, plant_bamboo:5/6, fire_trail:2/2, shove:0/8, void_pull:28/12, quake_leap:7/6, strike_thrust:1/6, strike_jab:16/30, run:54/22, lava_field:6/2, glide:18/8, gloom_rift:20/6, coiling_rift:5/8 |

Limitations: small, bot- and roster-dependent teamwide interventions; paired draws are not independent per swap. Not human agency/fun/fairness validation, single-monster causal odds, equal-price comparisons, approved progression or balance/price evidence.

## Discovery diagnostics (both teams pooled)
No-own-turn = defeat after FIRST positive damage without a subsequent turn_started for that victim; prior turns do not count. Descriptive response-window metric, NOT an unfairness verdict. Candidate counts are activations/actual fielded slots, not successful effects. Round counts use event round_started. Map fingerprints cover pre-begin grounds/props, excluding units. Parent unilateral class label does not apply to map-only scenarios: maps affect both teams.
| Scenario | Eligible/unchanged units | Applied slots | Species old→new ledger | No-own-turn defeats/battles | Candidate uses/fielded slots | Candidate activations by round | Battles using candidate | Well/flank HP damage | Map SHA256s |
|---|---|---|---|---|---|---|---|---|---|
| base | 0/48 | 0 | — | 11/7 | — | — | 0/8 | 54/1 | 2a932891dc3f801d7675024c0a57d04d6ddbbcdb7fc9a2993d7076e55bfeb9f2:true, 9f420c29ea826b93b2c38c74f0a8f489eb26e7aa82b9971cb896cf1fe407814b:true, d33d79293d03cda5a32111e199ae813e636bd00e4ba60b5ecf888dbb3eeb7364:true, d60729d6f1c201e23975c6f533abfdfb6f65dd4cae870eeea15a1dc09c9145e8:true |
| single_vein | 0/48 | 0 | — | 6/5 | — | — | 0/8 | 29/4 | 57585e5d013f28f1081f31607ebe8f5dd82032fe7034aa04e605fe7654fbca6d:true, 6d1c262541b6f59e50c3f954398d341ce859978edba229734503609df663e5a7:true, a72fbf435510758c82d910f3fd36dd53498df7766940ff93eff9683738f7c891:true, bab4a28fcd3e95e40033d3b4a7b0e31019d9f924a2ef80846249c0d4117f847f:true |
DISCOVERY_MEASUREMENT_COMPLETED: final guard matches startup content=a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2 resources=cloudstep_token:97a751e9ce198fb1a6a41fae7b99428ea2e13abfafba861a20852d2867161e1e, mist_step:652b415efe17683a0e2e9f509e28a57ca27e3cf260ea1ad45fa1da9189af51eb, raise_reed_screen:9211eea71bc9671524d8541ffdbed88b28256aa73bbb94bfbb235e90021f1f84, receding_blow:b5daf6cb86c6da57a45d4800912150d6ecc35ee6d09b703f71db8c52858c50b1, reed_screen:a6f4b626ff57693209e07c1e3be292af26596920cfba07d892e42bb4c3adaba0
```

## S023 · 2026-11-14 · Authored gameplay discovery and Mist Step ablation

State: `2828adf` dirty · regular content `a30a9be42850` unchanged · Godot 4.7.2. User “probier dich mal aus” explicitly shifts the focus to new gameplay, not entry proxies or price calculation. Authored HP/Initiative/Movement/Reach/AP/TPR and full HP are retained. `current-ap=2` changes only both teams’ ZONE PUSH/PULL skill costs (including Bog); it is not an AP-2 entry frame. Five new canonical resources (four skills and Reed Screen) have `content_status=simulation`, are separately hashed in each report and excluded from the regular fingerprint; no existing kits, stats or user `asdf` content were changed. These are working values, not approved content, rules or prices.

**Scope and counting:** six completed reports: 160 + 208 + 80 + 16 + 128 + 4 = **596 battle plays**. The ablation repeats the earlier 32 `mist_step` and 32 `split_mist` 2-AP cases exactly: **64 reruns, 532 distinct scenario/setup/side plays**, not 596 new observations. Do not pool repeats as new n. Team draws and their side swaps are correlated, not independent samples. Main greedy blocks have 32 plays/scenario across seeds 501–504; tactic has four per scenario. Unilateral candidates replace the first MOVE, eligible positive-damage Jab without board operations, or screen replacement slot (first pure CREATE_PROP placement, else first GROUND, else last slot); the reports preserve the species/old→new ledger. These are neither free additions nor equal-price comparisons. `both_*` changes both teams: A scores there do not measure a new skill’s value.

**Candidate and map definitions (resource-backed working experiments):**

| Candidate | Actual intervention |
|---|---|
| Mist Step | 2 AP, walk up to effective Movement; Slowing for 2 rounds on vacated path cells, including origin, excluding landing. |
| Receding Blow | 2 AP, Jab for 2 damage, normal push/Kin effect, then retreat 1; Winged does not retreat twice. |
| Cloudstep Token | 1 AP, once per battle, free-path effective Movement +2, legal landing; no AP bonus. Occupies a kit slot, not a slot-free item. |
| Raise Reed Screen | 1 AP, once per round, one legal cell within Reach; inert 1-HP prop, blocks ordinary movement, no line-of-sight cover, aura or aftermath. |

`open` removes preplaced props without aftermath and retains grounds/veins. `screens` uses exactly two point-mirrored light Reed Screen pairs, avoiding starts, veins and their cardinal neighbours. `split` relocates the three veins to (1,2), (3,3), (5,4), then uses the same screen generator; changed legal prop positions mean this is **not a pure vein-placement ablation**. Both teams receive map edits; raw map rows inherit a misleading unilateral label. A win rates are not map-quality scores.

**Observations (paired bot indications only):**

- Direct 2-AP greedy Mist Step: mean **3.4375** versus base **2.90625**, 109 activations/88 fielded slots. Crucially, exact no-trail control clears only `board_ops` on the same 2-AP walking profile: mean **3.40625** versus **3.4375**, A score 17/32 = **0.53125** versus (18+1)/32 = **0.59375**. Small, no significance established: the length difference from base cannot be attributed to the Slow trail. Control usage still carries ID `mist_step` but is not zone-producing Mist Step.
- Split + Mist mean **3.4375**, two >5 outliers (6 and 7); no-trail split **3.34375**, one >5 (6). No automatic combination benefit. Main map means (32 each): screens **3.125**, open **3.1875**, split **3.125**; no map winner established.
- Main two-block Cloudstep: **88 uses/88 slots, 81 in round 1**. Near-automatic opening, not evidence of a situational emergency tool; team scores vary from **46.875% to 81.25%** by seed block. The no-own-turn response count is often higher, not evidence of fairness or unfairness.
- Screen is sparse (**20 uses/96 slots**); favourable outcomes do not demonstrate screen utility because replacements sacrifice other kit actions. Receding Blow: **16 uses/44 slots**; Winged already has retreat. Usage counts activations, not successful effects or independent skill opportunities.
- Tactic (four each): base **2.75**, Mist **3.0**, Screen **3.0**, split+Mist **3.25**; separate Cloudstep **2.75**, n=4. Existing 1-AP-current reference (first 16 matched plays): base **2.375**, Mist **2.5625**, split+Mist **3.25**. Neither these nor the 2-AP blocks establish that all candidates are balanced or meet all goals.
- “No-own-turn” means defeat after first positive damage without a subsequent own `turn_started`, regardless of earlier turns. It is a descriptive response-window metric, **not a new gameplay goal or fairness verdict**. Human agency, fun, situational choices and full battle validation remain open.

**Core correction and executed checks:** real-action fixtures first found two failures: `BattleTurn._positional()` iterated generator `well_squares`, so relocated outer veins could be captured but dealt no damage. Resolution now iterates over actual board WELL cells, guarded by `wells > 0`; normal-map positions/order stay unchanged. Both fixtures then passed, before measurements; no invalid-map measurements are counted. `test_battle_experiment.gd` now covers off-row damage and disabled veins; content tests cover catalog count 20 and simulation-only Reed Screen. Whole battle folder: **158 cases, 0 errors, 0 failures**; focused run **32 cases, 0 errors, 0 failures**. Discovery self-test **6868 passed / 0 failed**, including **37 real-action checks** (not 37 extra). This validates fixtures/regressions, not gameplay or new rules. Existing stats/kits and user content remain preserved.

**Execution/provenance:** all six runs completed sequentially using one Idle-priority Godot 4.7.2 process, affinity `0xC` (2/32 CPUs). Reports retain startup/final content/resource guards, schedule/map hashes and own/parent script hashes, not a full-engine identity. Current fixed `godot/battle/core/battle_turn.gd` SHA256: `32fee4e244c46232cefcb4229d7ca39d87852269f5e0873c9543b161c1643790`. All six completed reports were checked against the raw outputs below before temporary-output cleanup; `git diff --check` passed. No full-project suite, manual UI inspection or human play was performed.

**Follow-up:** T10/T11/T13/T40: targeted human review of new skills and finer price/profile controls, especially Mist trail versus identical walk and Cloudstep opening versus situational use. T02/T03/T05 remain open; do not return to entry proxies as the current focus. Candidates stay simulation-only until the user selects them for later play; no GDD adoption.

### Complete raw reports

The following six outputs are copied unchanged except for removing the Godot engine header and its separator blank line. Rerun rows are retained for provenance, not counted again as new evidence.

#### discovery_first.txt

```text
# Authored discovery experiment
AP/TPR/HP/Init/Movement/Reach are authored, full HP, no entry proxy. current-ap=2 is an explicit bilateral ZONE PUSH/PULL candidate (including Bog), NOT normal defaults. All skills use duplicate_deep ALL. Subject A is scored after both side swaps. No prices/budgets asserted.
Harness own SHA256=747b3a6b9d6b5b2a1d9a25aff545e81dc3faed46692a3291a4d69ababbf22f45; parent SHA256=b40a5b2079d1012659f90c2a159c1a911dcbe4e3efc4b6c015b73858215fd38c; content=a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2; new resource hashes=cloudstep_token:97a751e9ce198fb1a6a41fae7b99428ea2e13abfafba861a20852d2867161e1e, mist_step:652b415efe17683a0e2e9f509e28a57ca27e3cf260ea1ad45fa1da9189af51eb, raise_reed_screen:9211eea71bc9671524d8541ffdbed88b28256aa73bbb94bfbb235e90021f1f84, receding_blow:b5daf6cb86c6da57a45d4800912150d6ecc35ee6d09b703f71db8c52858c50b1, reed_screen:a6f4b626ff57693209e07c1e3be292af26596920cfba07d892e42bb4c3adaba0; Godot=4.7.2-stable (official)
Maps: base uses canonical RUNNER seeded board. open removes every preplaced prop without aftermath, retains grounds/veins. screens replaces props with exactly two point-mirrored reed_screen pairs. split first relocates veins (1,3),(3,3),(5,3) -> (1,2),(3,3),(5,4), then uses the same screen generator. split_mist/cloud also replace subject movement. Props block movement only; NO ranged cover. No starter grass is added. Map RNG is local, seeded with setup seed; play/setup RNG is untouched by edits.
Eligibility: first MOVE for mist/cloud; first positive-damage Jab with no board ops for receding, preserving kin_effect. Winged already retreats: retreat flag does not stack. Screen: first pure CREATE_PROP placement, else first GROUND, else last slot; no extra slots. Only subject changes except both_*. Both teams receive map edits. Schedule: same draw-A/draw-B-excluding-A/setup-seed progression scheme; fresh setup RNG each scenario/swap, divergent play may consume different RNG draws.

| Seed | Pair | Subject A | Opponent B | Setup seed |
|---|---|---|---|---|
| 501 | 1 | ember_hawk,thorn_mites,blaze_tiger | hollow_serpent,dusk_moth,grove_wisp | 570115152 |
| 501 | 2 | dusk_moth,moss_turtle,gloom_wolf | ember_hawk,hollow_serpent,asdf | 1013980655 |
| 501 | 3 | asdf,hollow_serpent,dusk_moth | forge_golem,ember_hawk,gloom_wolf | 1070734350 |
| 501 | 4 | gloom_wolf,ember_hawk,hollow_serpent | grove_wisp,forge_golem,asdf | 30231281 |
| 502 | 1 | gloom_wolf,dusk_moth,moss_turtle | hollow_serpent,asdf,thorn_mites | 222702981 |
| 502 | 2 | forge_golem,hollow_serpent,dusk_moth | asdf,ember_hawk,blaze_tiger | 842894528 |
| 502 | 3 | gloom_wolf,moss_turtle,asdf | blaze_tiger,thorn_mites,hollow_serpent | 945091684 |
| 502 | 4 | gloom_wolf,forge_golem,blaze_tiger | grove_wisp,hollow_serpent,dusk_moth | 28144822 |
Schedule SHA256=5acde110792dc92afe490d5511dc11144270cba4728e37b35fe4b9ccba5a7764

## Aggregate

Score=(wins+0.5×true draws)/(games−timeouts); timeouts separate. Rounds include timeout partial rounds; histograms allow exact weighted means. Defeat/damage/activation metrics cover BOTH teams; first-defeat turns count turn_started events through the first defeat, omitting games with none. Collision is collision HP damage (not collision events). Repeat=second/later activation of same actor+skill within one turn, including slotted movement, excluding Step; event fallback matches sim.gd, not distinct slot identity.

| Scenario | Class | Games | A W/L/D/timeout | Score | Mean rounds | <2/>5/max | Pre-first-turn defeats/games | Turns to first defeat (n) | Collision/total damage | Repeats/activations | Round histogram |
|---|---|---|---|---|---|---|---|---|---|---|---|
| base | control | 16 | 8/7/1/0 | 0.53 | 3.19 | 0/0/5 | 0/0 | 5.81 (16) | 121/413 | 51/390 (0.13) | 2:2, 3:10, 4:3, 5:1 |
| mist_step | unilateral | 16 | 9/7/0/0 | 0.56 | 3.25 | 0/0/4 | 0/0 | 6.63 (16) | 131/401 | 34/380 (0.09) | 2:1, 3:10, 4:5 |
| receding_blow | unilateral | 16 | 10/6/0/0 | 0.63 | 3.19 | 0/0/5 | 0/0 | 5.94 (16) | 138/421 | 50/387 (0.13) | 2:3, 3:8, 4:4, 5:1 |
| cloudstep_token | unilateral | 16 | 7/8/1/0 | 0.47 | 2.75 | 0/0/5 | 0/0 | 6.44 (16) | 148/396 | 31/342 (0.09) | 2:7, 3:7, 4:1, 5:1 |
| raise_reed_screen | unilateral | 16 | 9/7/0/0 | 0.56 | 2.75 | 0/0/4 | 0/0 | 4.94 (16) | 143/393 | 39/356 (0.11) | 2:5, 3:10, 4:1 |
| open | unilateral | 16 | 8/8/0/0 | 0.50 | 3.25 | 0/0/4 | 0/0 | 7.75 (16) | 112/424 | 70/438 (0.16) | 2:1, 3:10, 4:5 |
| screens | unilateral | 16 | 8/8/0/0 | 0.50 | 3.06 | 0/0/4 | 0/0 | 7.19 (16) | 122/403 | 49/398 (0.12) | 2:1, 3:13, 4:2 |
| split | unilateral | 16 | 9/7/0/0 | 0.56 | 3.38 | 0/0/5 | 0/0 | 8.25 (16) | 153/401 | 54/413 (0.13) | 2:2, 3:7, 4:6, 5:1 |
| split_mist | unilateral | 16 | 9/7/0/0 | 0.56 | 3.69 | 0/1/7 | 0/0 | 7.56 (16) | 137/395 | 18/400 (0.04) | 3:9, 4:5, 5:1, 7:1 |
| split_cloud | unilateral | 16 | 6/9/1/0 | 0.41 | 3.81 | 0/0/5 | 0/0 | 6.06 (16) | 149/396 | 31/412 (0.08) | 2:1, 3:5, 4:6, 5:4 |

## Start affordability and actual interventions

Both teams pooled, repeated per game. Affordability only: cost≤sheet AP, NOT target legality; no assumption that a low-stage kit should be fully affordable. Move/attack counts units with an affordable slotted MOVE/damaging STRIKE (not universal Step). Stat deltas: attempted/applied sum/changed count/cap-blocked count, per upgraded member. strike_ground: eligible damaging STRIKE attempts/applied/not_applied (existing ground); proposed content variant, not an approved slot choice. No rounding of exact counts.

| Scenario | Affordable/active slots | No affordable active/units | Has move/attack | Unaffordable ID:slot count | Stat delta attempted/sum/changed/blocked | strike_ground counts |
|---|---|---|---|---|---|---|
| base | 384/384 | 0/96 | 88/78 | — | — | — |
| mist_step | 384/384 | 0/96 | 88/78 | — | — | — |
| receding_blow | 384/384 | 0/96 | 88/78 | — | — | — |
| cloudstep_token | 384/384 | 0/96 | 88/78 | — | — | — |
| raise_reed_screen | 384/384 | 0/96 | 88/78 | — | — | — |
| open | 384/384 | 0/96 | 88/78 | — | — | — |
| screens | 384/384 | 0/96 | 88/78 | — | — | — |
| split | 384/384 | 0/96 | 88/78 | — | — | — |
| split_mist | 384/384 | 0/96 | 88/78 | — | — | — |
| split_cloud | 384/384 | 0/96 | 88/78 | — | — | — |

## Active skill usage

All equipped active IDs, not just top skills; activations/start slots pooled over both teams and games (not success rates).

| Scenario | ID:activations/start slots |
|---|---|
| base | cinder_dive:0/10, asdf_3:12/12, strike_jab:28/54, thornbed:39/40, set_gong:2/8, gale:28/24, bog:14/6, plant_bamboo:6/12, asdf_2:28/12, asdf:7/12, lava_field:8/8, new_skill:6/8, thorn_lash:9/12, snare:0/12, shove:0/18, strike_thrust:2/8, quake_leap:6/6, gloom_rift:23/12, fire_trail:11/8, glide:19/16, coiling_rift:17/16, run:102/46, void_pull:23/24 |
| mist_step | cinder_dive:2/10, mist_step:59/44, asdf_3:17/12, strike_jab:32/54, thornbed:34/40, set_gong:1/8, gale:31/24, bog:4/6, plant_bamboo:8/12, asdf_2:18/8, asdf:7/12, lava_field:12/8, new_skill:2/8, thorn_lash:3/12, snare:0/12, shove:0/18, strike_thrust:0/8, quake_leap:8/6, gloom_rift:38/12, fire_trail:7/4, glide:10/10, coiling_rift:13/16, run:43/16, void_pull:31/24 |
| receding_blow | cinder_dive:0/10, asdf_3:12/12, strike_jab:17/34, thornbed:36/40, set_gong:2/8, gale:31/24, bog:14/6, plant_bamboo:7/12, asdf_2:28/12, asdf:6/12, lava_field:7/8, new_skill:7/8, thorn_lash:9/12, snare:0/12, shove:0/18, strike_thrust:4/8, receding_blow:7/20, quake_leap:4/6, gloom_rift:22/12, fire_trail:11/8, glide:24/16, coiling_rift:17/16, run:97/46, void_pull:25/24 |
| cloudstep_token | cinder_dive:0/10, asdf_3:20/12, strike_jab:27/54, thornbed:36/40, set_gong:1/8, gale:21/24, bog:5/6, plant_bamboo:11/12, asdf_2:13/8, asdf:2/12, lava_field:10/8, new_skill:2/8, thorn_lash:9/12, snare:0/12, shove:0/18, strike_thrust:4/8, quake_leap:8/6, gloom_rift:31/12, fire_trail:7/4, glide:6/10, coiling_rift:9/16, cloudstep_token:44/44, run:34/16, void_pull:42/24 |
| raise_reed_screen | cinder_dive:2/6, asdf_3:16/12, strike_jab:25/54, thornbed:33/34, set_gong:1/4, gale:23/24, bog:11/6, plant_bamboo:2/2, asdf_2:23/12, raise_reed_screen:12/48, asdf:7/12, lava_field:2/4, new_skill:7/8, thorn_lash:7/12, snare:2/12, shove:0/12, strike_thrust:2/8, quake_leap:7/6, gloom_rift:7/4, fire_trail:9/8, glide:22/16, coiling_rift:8/10, run:97/46, void_pull:31/24 |
| open | cinder_dive:0/10, asdf_3:18/12, strike_jab:34/54, thornbed:35/40, set_gong:3/8, gale:29/24, bog:7/6, plant_bamboo:0/12, asdf_2:23/12, asdf:6/12, lava_field:13/8, new_skill:7/8, thorn_lash:8/12, snare:0/12, shove:1/18, strike_thrust:2/8, quake_leap:7/6, gloom_rift:30/12, fire_trail:11/8, glide:34/16, coiling_rift:14/16, run:127/46, void_pull:29/24 |
| screens | cinder_dive:0/10, asdf_3:22/12, strike_jab:33/54, thornbed:28/40, set_gong:3/8, gale:26/24, bog:8/6, plant_bamboo:0/12, asdf_2:25/12, asdf:6/12, lava_field:12/8, new_skill:2/8, thorn_lash:7/12, snare:1/12, shove:0/18, strike_thrust:1/8, quake_leap:10/6, gloom_rift:27/12, fire_trail:17/8, glide:33/16, coiling_rift:11/16, run:101/46, void_pull:25/24 |
| split | cinder_dive:0/10, asdf_3:20/12, strike_jab:32/54, thornbed:29/40, set_gong:3/8, gale:29/24, bog:10/6, plant_bamboo:13/12, asdf_2:24/12, asdf:4/12, lava_field:8/8, new_skill:5/8, thorn_lash:5/12, snare:0/12, shove:0/18, strike_thrust:3/8, quake_leap:10/6, gloom_rift:28/12, fire_trail:9/8, glide:16/16, coiling_rift:19/16, run:107/46, void_pull:39/24 |
| split_mist | cinder_dive:0/10, mist_step:51/44, asdf_3:24/12, strike_jab:29/54, thornbed:43/40, set_gong:5/8, gale:35/24, bog:7/6, plant_bamboo:5/12, asdf_2:15/8, asdf:4/12, lava_field:8/8, new_skill:8/8, thorn_lash:2/12, snare:0/12, shove:0/18, strike_thrust:2/8, quake_leap:9/6, gloom_rift:33/12, fire_trail:4/4, glide:11/10, coiling_rift:23/16, run:41/16, void_pull:41/24 |
| split_cloud | cinder_dive:2/10, asdf_3:27/12, strike_jab:35/54, thornbed:42/40, set_gong:2/8, gale:43/24, bog:11/6, plant_bamboo:7/12, asdf_2:15/8, asdf:4/12, lava_field:23/8, new_skill:3/8, thorn_lash:4/12, snare:0/12, shove:4/18, strike_thrust:4/8, quake_leap:6/6, gloom_rift:25/12, fire_trail:6/4, glide:10/10, coiling_rift:18/16, cloudstep_token:44/44, run:34/16, void_pull:43/24 |

Limitations: small, bot- and roster-dependent teamwide interventions; paired draws are not independent per swap. Not human agency/fun/fairness validation, single-monster causal odds, equal-price comparisons, approved progression or balance/price evidence.

## Discovery diagnostics (both teams pooled)
No-own-turn = defeat after FIRST positive damage without a subsequent turn_started for that victim; prior turns do not count. Descriptive response-window metric, NOT an unfairness verdict. Candidate counts are activations/actual fielded slots, not successful effects. Round counts use event round_started. Map fingerprints cover pre-begin grounds/props, excluding units. Parent unilateral class label does not apply to map-only scenarios: maps affect both teams.
| Scenario | Eligible/unchanged units | Applied slots | Species old→new ledger | No-own-turn defeats/battles | Candidate uses/fielded slots | Candidate activations by round | Battles using candidate | Well/flank HP damage | Map SHA256s |
|---|---|---|---|---|---|---|---|---|---|
| base | 0/96 | 0 | — | 20/14 | — | — | 0/16 | 109/11 | 1dadfcae8617d12bfab200dbaae0bdc88a5f6a779ab56469f601eedf46f0edac:true, 390cdb5c2f65671232dc99d621a5fb6416cdd6a195d42199f91cc8fc66f5104f:true, 7225665215211341d8cb239247d47fb68197164f5565a7b123b39720aeafb0e9:true, 83272b53bafa517b64275b0de780e57d42a594e7399909f65e5338c273503541:true, 895b408d0bf0b3d7483f0a574fcf79a80a8a7acb6f65c7e5cc9cee896a10a891:true, 9a161cee72c97978dff557e47ccfe61a2884a6b47c270d3eae80e67a03198f5c:true, ed3a312b3b70b0ab6f5309f698e76cc8c03073bc4acd028feababdd37a2f8ce6:true, ed95f62a0ccbca30e0ac4476b8c68101b4370c92cd8cd8d5f0dbf5c6cc3b2268:true |
| mist_step | 44/52 | 44 | asdf asdf_2→mist_step:4, blaze_tiger fire_trail→mist_step:4, dusk_moth run→mist_step:8, ember_hawk glide→mist_step:4, gloom_wolf run→mist_step:10, hollow_serpent run→mist_step:6, moss_turtle run→mist_step:6, thorn_mites glide→mist_step:2 | 15/12 | mist_step:[59, 44] | mist_step/r1:29, mist_step/r2:18, mist_step/r3:11, mist_step/r4:1 | 16/16 | 110/10 | 1dadfcae8617d12bfab200dbaae0bdc88a5f6a779ab56469f601eedf46f0edac:true, 390cdb5c2f65671232dc99d621a5fb6416cdd6a195d42199f91cc8fc66f5104f:true, 7225665215211341d8cb239247d47fb68197164f5565a7b123b39720aeafb0e9:true, 83272b53bafa517b64275b0de780e57d42a594e7399909f65e5338c273503541:true, 895b408d0bf0b3d7483f0a574fcf79a80a8a7acb6f65c7e5cc9cee896a10a891:true, 9a161cee72c97978dff557e47ccfe61a2884a6b47c270d3eae80e67a03198f5c:true, ed3a312b3b70b0ab6f5309f698e76cc8c03073bc4acd028feababdd37a2f8ce6:true, ed95f62a0ccbca30e0ac4476b8c68101b4370c92cd8cd8d5f0dbf5c6cc3b2268:true |
| receding_blow | 20/76 | 20 | blaze_tiger strike_jab→receding_blow:4, ember_hawk strike_jab→receding_blow:4, forge_golem strike_jab→receding_blow:4, hollow_serpent strike_jab→receding_blow:6, thorn_mites strike_jab→receding_blow:2 | 21/14 | receding_blow:[7, 20] | receding_blow/r1:4, receding_blow/r2:2, receding_blow/r3:1 | 7/16 | 112/11 | 1dadfcae8617d12bfab200dbaae0bdc88a5f6a779ab56469f601eedf46f0edac:true, 390cdb5c2f65671232dc99d621a5fb6416cdd6a195d42199f91cc8fc66f5104f:true, 7225665215211341d8cb239247d47fb68197164f5565a7b123b39720aeafb0e9:true, 83272b53bafa517b64275b0de780e57d42a594e7399909f65e5338c273503541:true, 895b408d0bf0b3d7483f0a574fcf79a80a8a7acb6f65c7e5cc9cee896a10a891:true, 9a161cee72c97978dff557e47ccfe61a2884a6b47c270d3eae80e67a03198f5c:true, ed3a312b3b70b0ab6f5309f698e76cc8c03073bc4acd028feababdd37a2f8ce6:true, ed95f62a0ccbca30e0ac4476b8c68101b4370c92cd8cd8d5f0dbf5c6cc3b2268:true |
| cloudstep_token | 44/52 | 44 | asdf asdf_2→cloudstep_token:4, blaze_tiger fire_trail→cloudstep_token:4, dusk_moth run→cloudstep_token:8, ember_hawk glide→cloudstep_token:4, gloom_wolf run→cloudstep_token:10, hollow_serpent run→cloudstep_token:6, moss_turtle run→cloudstep_token:6, thorn_mites glide→cloudstep_token:2 | 20/14 | cloudstep_token:[44, 44] | cloudstep_token/r1:39, cloudstep_token/r2:5 | 16/16 | 96/8 | 1dadfcae8617d12bfab200dbaae0bdc88a5f6a779ab56469f601eedf46f0edac:true, 390cdb5c2f65671232dc99d621a5fb6416cdd6a195d42199f91cc8fc66f5104f:true, 7225665215211341d8cb239247d47fb68197164f5565a7b123b39720aeafb0e9:true, 83272b53bafa517b64275b0de780e57d42a594e7399909f65e5338c273503541:true, 895b408d0bf0b3d7483f0a574fcf79a80a8a7acb6f65c7e5cc9cee896a10a891:true, 9a161cee72c97978dff557e47ccfe61a2884a6b47c270d3eae80e67a03198f5c:true, ed3a312b3b70b0ab6f5309f698e76cc8c03073bc4acd028feababdd37a2f8ce6:true, ed95f62a0ccbca30e0ac4476b8c68101b4370c92cd8cd8d5f0dbf5c6cc3b2268:true |
| raise_reed_screen | 48/48 | 48 | asdf thornbed→raise_reed_screen:4, blaze_tiger lava_field→raise_reed_screen:4, dusk_moth gloom_rift→raise_reed_screen:8, ember_hawk cinder_dive→raise_reed_screen:4, forge_golem set_gong→raise_reed_screen:4, gloom_wolf plant_bamboo→raise_reed_screen:10, hollow_serpent coiling_rift→raise_reed_screen:6, moss_turtle shove→raise_reed_screen:6, thorn_mites thornbed→raise_reed_screen:2 | 22/14 | raise_reed_screen:[12, 48] | raise_reed_screen/r1:8, raise_reed_screen/r2:3, raise_reed_screen/r3:1 | 10/16 | 87/10 | 1dadfcae8617d12bfab200dbaae0bdc88a5f6a779ab56469f601eedf46f0edac:true, 390cdb5c2f65671232dc99d621a5fb6416cdd6a195d42199f91cc8fc66f5104f:true, 7225665215211341d8cb239247d47fb68197164f5565a7b123b39720aeafb0e9:true, 83272b53bafa517b64275b0de780e57d42a594e7399909f65e5338c273503541:true, 895b408d0bf0b3d7483f0a574fcf79a80a8a7acb6f65c7e5cc9cee896a10a891:true, 9a161cee72c97978dff557e47ccfe61a2884a6b47c270d3eae80e67a03198f5c:true, ed3a312b3b70b0ab6f5309f698e76cc8c03073bc4acd028feababdd37a2f8ce6:true, ed95f62a0ccbca30e0ac4476b8c68101b4370c92cd8cd8d5f0dbf5c6cc3b2268:true |
| open | 0/96 | 0 | — | 14/11 | — | — | 0/16 | 127/12 | 20b3dc1c5dffcd8c1c5577acdcbcc6e980f40316d0d6fe6020c9ee6ea4fce3a9:true |
| screens | 0/96 | 0 | — | 22/13 | — | — | 0/16 | 117/15 | 13fa5c5b7f98b9e2afab941be6987fc1b8f9307e4ac9c1b284cbe756d781c7c5:true, 39ee842182eaa941ca66dc6c380ef7e9b466159d0f235eec49f547fc5f486640:true, 564e5039d965301802f7e266d2621d26363649c803dae8d9410f6b6ba8cc45db:true, 6cb6c5b0761a9f0f4c6f8f66da110416c054d178ee08f05b988febe270e51dbf:true, 8f99fa93198b32e7873ff9b4601fa44e7371ae4f385899a8096bbe9d537b5678:true |
| split | 0/96 | 0 | — | 18/12 | — | — | 0/16 | 68/16 | c0734b6bfde173096c39f516765f3cd49642ca9a88df67b606e4400fad225090:true, d932bd623d54f91d82768737de70c0f3dda6acff94cd0a0ad1486b44bc343ac7:true |
| split_mist | 44/52 | 44 | asdf asdf_2→mist_step:4, blaze_tiger fire_trail→mist_step:4, dusk_moth run→mist_step:8, ember_hawk glide→mist_step:4, gloom_wolf run→mist_step:10, hollow_serpent run→mist_step:6, moss_turtle run→mist_step:6, thorn_mites glide→mist_step:2 | 12/9 | mist_step:[51, 44] | mist_step/r1:18, mist_step/r2:14, mist_step/r3:12, mist_step/r4:6, mist_step/r5:1 | 16/16 | 77/7 | c0734b6bfde173096c39f516765f3cd49642ca9a88df67b606e4400fad225090:true, d932bd623d54f91d82768737de70c0f3dda6acff94cd0a0ad1486b44bc343ac7:true |
| split_cloud | 44/52 | 44 | asdf asdf_2→cloudstep_token:4, blaze_tiger fire_trail→cloudstep_token:4, dusk_moth run→cloudstep_token:8, ember_hawk glide→cloudstep_token:4, gloom_wolf run→cloudstep_token:10, hollow_serpent run→cloudstep_token:6, moss_turtle run→cloudstep_token:6, thorn_mites glide→cloudstep_token:2 | 17/13 | cloudstep_token:[44, 44] | cloudstep_token/r1:42, cloudstep_token/r2:2 | 16/16 | 69/4 | c0734b6bfde173096c39f516765f3cd49642ca9a88df67b606e4400fad225090:true, d932bd623d54f91d82768737de70c0f3dda6acff94cd0a0ad1486b44bc343ac7:true |
DISCOVERY_MEASUREMENT_COMPLETED: final guard matches startup content=a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2 resources=cloudstep_token:97a751e9ce198fb1a6a41fae7b99428ea2e13abfafba861a20852d2867161e1e, mist_step:652b415efe17683a0e2e9f509e28a57ca27e3cf260ea1ad45fa1da9189af51eb, raise_reed_screen:9211eea71bc9671524d8541ffdbed88b28256aa73bbb94bfbb235e90021f1f84, receding_blow:b5daf6cb86c6da57a45d4800912150d6ecc35ee6d09b703f71db8c52858c50b1, reed_screen:a6f4b626ff57693209e07c1e3be292af26596920cfba07d892e42bb4c3adaba0
```

#### discovery_second.txt

```text
# Authored discovery experiment
AP/TPR/HP/Init/Movement/Reach are authored, full HP, no entry proxy. current-ap=2 is an explicit bilateral ZONE PUSH/PULL candidate (including Bog), NOT normal defaults. All skills use duplicate_deep ALL. Subject A is scored after both side swaps. No prices/budgets asserted.
Harness own SHA256=747b3a6b9d6b5b2a1d9a25aff545e81dc3faed46692a3291a4d69ababbf22f45; parent SHA256=b40a5b2079d1012659f90c2a159c1a911dcbe4e3efc4b6c015b73858215fd38c; content=a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2; new resource hashes=cloudstep_token:97a751e9ce198fb1a6a41fae7b99428ea2e13abfafba861a20852d2867161e1e, mist_step:652b415efe17683a0e2e9f509e28a57ca27e3cf260ea1ad45fa1da9189af51eb, raise_reed_screen:9211eea71bc9671524d8541ffdbed88b28256aa73bbb94bfbb235e90021f1f84, receding_blow:b5daf6cb86c6da57a45d4800912150d6ecc35ee6d09b703f71db8c52858c50b1, reed_screen:a6f4b626ff57693209e07c1e3be292af26596920cfba07d892e42bb4c3adaba0; Godot=4.7.2-stable (official)
Maps: base uses canonical RUNNER seeded board. open removes every preplaced prop without aftermath, retains grounds/veins. screens replaces props with exactly two point-mirrored reed_screen pairs. split first relocates veins (1,3),(3,3),(5,3) -> (1,2),(3,3),(5,4), then uses the same screen generator. split_mist/cloud also replace subject movement. Props block movement only; NO ranged cover. No starter grass is added. Map RNG is local, seeded with setup seed; play/setup RNG is untouched by edits.
Eligibility: first MOVE for mist/cloud; first positive-damage Jab with no board ops for receding, preserving kin_effect. Winged already retreats: retreat flag does not stack. Screen: first pure CREATE_PROP placement, else first GROUND, else last slot; no extra slots. Only subject changes except both_*. Both teams receive map edits. Schedule: same draw-A/draw-B-excluding-A/setup-seed progression scheme; fresh setup RNG each scenario/swap, divergent play may consume different RNG draws.

| Seed | Pair | Subject A | Opponent B | Setup seed |
|---|---|---|---|---|
| 503 | 1 | moss_turtle,blaze_tiger,hollow_serpent | grove_wisp,ember_hawk,gloom_wolf | 774216799 |
| 503 | 2 | asdf,dusk_moth,blaze_tiger | ember_hawk,forge_golem,moss_turtle | 134545299 |
| 503 | 3 | dusk_moth,thorn_mites,blaze_tiger | gloom_wolf,forge_golem,moss_turtle | 640594562 |
| 503 | 4 | gloom_wolf,thorn_mites,moss_turtle | dusk_moth,ember_hawk,asdf | 101931872 |
| 504 | 1 | thorn_mites,gloom_wolf,asdf | hollow_serpent,blaze_tiger,dusk_moth | 53539138 |
| 504 | 2 | gloom_wolf,forge_golem,hollow_serpent | thorn_mites,moss_turtle,ember_hawk | 421547237 |
| 504 | 3 | gloom_wolf,moss_turtle,thorn_mites | forge_golem,grove_wisp,dusk_moth | 83694405 |
| 504 | 4 | thorn_mites,asdf,forge_golem | hollow_serpent,dusk_moth,ember_hawk | 829263182 |
Schedule SHA256=e596b61a4c3081ea0a250a19479b2104b6f0d517fa20d24d8dd025070c520bec

## Aggregate

Score=(wins+0.5×true draws)/(games−timeouts); timeouts separate. Rounds include timeout partial rounds; histograms allow exact weighted means. Defeat/damage/activation metrics cover BOTH teams; first-defeat turns count turn_started events through the first defeat, omitting games with none. Collision is collision HP damage (not collision events). Repeat=second/later activation of same actor+skill within one turn, including slotted movement, excluding Step; event fallback matches sim.gd, not distinct slot identity.

| Scenario | Class | Games | A W/L/D/timeout | Score | Mean rounds | <2/>5/max | Pre-first-turn defeats/games | Turns to first defeat (n) | Collision/total damage | Repeats/activations | Round histogram |
|---|---|---|---|---|---|---|---|---|---|---|---|
| base | control | 16 | 8/8/0/0 | 0.50 | 2.63 | 0/0/4 | 2/2 | 6.56 (16) | 182/408 | 32/337 (0.09) | 2:7, 3:8, 4:1 |
| mist_step | unilateral | 16 | 9/5/2/0 | 0.63 | 3.63 | 0/0/5 | 0/0 | 6.50 (16) | 149/446 | 35/388 (0.09) | 2:1, 3:5, 4:9, 5:1 |
| receding_blow | unilateral | 16 | 8/8/0/0 | 0.50 | 2.69 | 0/0/4 | 2/2 | 6.56 (16) | 180/412 | 32/342 (0.09) | 2:7, 3:7, 4:2 |
| cloudstep_token | unilateral | 16 | 13/3/0/0 | 0.81 | 2.75 | 1/0/5 | 0/0 | 5.81 (16) | 189/404 | 28/313 (0.09) | 1:1, 2:7, 3:4, 4:3, 5:1 |
| raise_reed_screen | unilateral | 16 | 11/4/1/0 | 0.72 | 2.75 | 0/0/4 | 2/2 | 5.50 (16) | 169/407 | 35/342 (0.10) | 2:7, 3:6, 4:3 |
| open | unilateral | 16 | 11/5/0/0 | 0.69 | 3.13 | 0/0/5 | 2/2 | 6.38 (16) | 162/408 | 41/382 (0.11) | 2:5, 3:5, 4:5, 5:1 |
| screens | unilateral | 16 | 10/6/0/0 | 0.63 | 3.19 | 0/0/5 | 2/2 | 7.63 (16) | 134/406 | 41/391 (0.10) | 2:4, 3:7, 4:3, 5:2 |
| split | unilateral | 16 | 13/2/1/0 | 0.84 | 2.88 | 0/0/5 | 2/2 | 5.81 (16) | 171/397 | 20/347 (0.06) | 2:5, 3:9, 4:1, 5:1 |
| split_mist | unilateral | 16 | 9/6/1/0 | 0.59 | 3.19 | 0/1/6 | 0/0 | 6.75 (16) | 179/425 | 20/360 (0.06) | 2:4, 3:7, 4:4, 6:1 |
| split_cloud | unilateral | 16 | 13/3/0/0 | 0.81 | 3.19 | 0/0/5 | 0/0 | 6.25 (16) | 196/403 | 34/367 (0.09) | 2:6, 3:3, 4:5, 5:2 |
| both_mist | bilateral | 16 | 14/2/0/0 | 0.88 | 3.50 | 0/2/6 | 0/0 | 7.06 (16) | 135/417 | 13/358 (0.04) | 2:2, 3:9, 4:2, 5:1, 6:2 |
| both_cloud | bilateral | 16 | 10/5/1/0 | 0.66 | 2.75 | 0/0/4 | 0/0 | 5.63 (16) | 178/429 | 17/323 (0.05) | 2:7, 3:6, 4:3 |
| both_screen | bilateral | 16 | 11/4/1/0 | 0.72 | 2.63 | 0/0/4 | 2/2 | 5.25 (16) | 172/420 | 33/329 (0.10) | 2:8, 3:6, 4:2 |

## Start affordability and actual interventions

Both teams pooled, repeated per game. Affordability only: cost≤sheet AP, NOT target legality; no assumption that a low-stage kit should be fully affordable. Move/attack counts units with an affordable slotted MOVE/damaging STRIKE (not universal Step). Stat deltas: attempted/applied sum/changed count/cap-blocked count, per upgraded member. strike_ground: eligible damaging STRIKE attempts/applied/not_applied (existing ground); proposed content variant, not an approved slot choice. No rounding of exact counts.

| Scenario | Affordable/active slots | No affordable active/units | Has move/attack | Unaffordable ID:slot count | Stat delta attempted/sum/changed/blocked | strike_ground counts |
|---|---|---|---|---|---|---|
| base | 384/384 | 0/96 | 86/72 | — | — | — |
| mist_step | 384/384 | 0/96 | 86/72 | — | — | — |
| receding_blow | 384/384 | 0/96 | 86/72 | — | — | — |
| cloudstep_token | 384/384 | 0/96 | 86/72 | — | — | — |
| raise_reed_screen | 384/384 | 0/96 | 86/72 | — | — | — |
| open | 384/384 | 0/96 | 86/72 | — | — | — |
| screens | 384/384 | 0/96 | 86/72 | — | — | — |
| split | 384/384 | 0/96 | 86/72 | — | — | — |
| split_mist | 384/384 | 0/96 | 86/72 | — | — | — |
| split_cloud | 384/384 | 0/96 | 86/72 | — | — | — |
| both_mist | 384/384 | 0/96 | 86/72 | — | — | — |
| both_cloud | 384/384 | 0/96 | 86/72 | — | — | — |
| both_screen | 384/384 | 0/96 | 86/72 | — | — | — |

## Active skill usage

All equipped active IDs, not just top skills; activations/start slots pooled over both teams and games (not success rates).

| Scenario | ID:activations/start slots |
|---|---|
| base | cinder_dive:0/10, asdf_3:11/8, strike_jab:26/52, thornbed:18/32, set_gong:5/10, gale:27/24, bog:12/12, plant_bamboo:6/12, asdf_2:18/8, asdf:0/8, lava_field:11/8, new_skill:2/8, thorn_lash:11/12, snare:0/12, shove:2/24, strike_thrust:1/10, quake_leap:4/4, gloom_rift:15/12, fire_trail:15/8, glide:32/22, coiling_rift:2/8, run:82/44, void_pull:37/36 |
| mist_step | cinder_dive:0/10, mist_step:50/44, asdf_3:11/8, strike_jab:34/52, thornbed:29/32, set_gong:4/10, gale:31/24, bog:16/12, plant_bamboo:13/12, asdf_2:7/2, asdf:5/8, lava_field:9/8, new_skill:2/8, thorn_lash:3/12, snare:0/12, shove:2/24, strike_thrust:3/10, quake_leap:4/4, gloom_rift:42/12, fire_trail:4/2, glide:17/12, coiling_rift:4/8, run:44/22, void_pull:54/36 |
| receding_blow | cinder_dive:0/10, asdf_3:11/8, strike_jab:18/28, thornbed:18/32, set_gong:4/10, gale:28/24, bog:12/12, plant_bamboo:6/12, asdf_2:18/8, asdf:0/8, lava_field:11/8, new_skill:2/8, thorn_lash:11/12, snare:0/12, shove:2/24, strike_thrust:1/10, receding_blow:9/24, quake_leap:4/4, gloom_rift:15/12, fire_trail:15/8, glide:34/22, coiling_rift:2/8, run:83/44, void_pull:38/36 |
| cloudstep_token | cinder_dive:0/10, asdf_3:9/8, strike_jab:28/52, thornbed:13/32, set_gong:5/10, gale:34/24, bog:13/12, plant_bamboo:9/12, asdf_2:6/2, asdf:0/8, lava_field:24/8, new_skill:2/8, thorn_lash:5/12, snare:0/12, shove:1/24, strike_thrust:3/10, quake_leap:2/4, gloom_rift:22/12, fire_trail:2/2, glide:13/12, coiling_rift:2/8, cloudstep_token:44/44, run:33/22, void_pull:43/36 |
| raise_reed_screen | cinder_dive:2/10, asdf_3:14/8, strike_jab:20/52, thornbed:22/16, set_gong:3/6, gale:22/24, bog:17/12, plant_bamboo:4/4, asdf_2:20/8, raise_reed_screen:8/48, asdf:0/8, lava_field:2/2, new_skill:7/8, thorn_lash:12/12, snare:0/12, shove:0/18, strike_thrust:3/10, quake_leap:4/4, gloom_rift:6/8, fire_trail:10/8, glide:29/22, coiling_rift:0/4, run:91/44, void_pull:46/36 |
| open | cinder_dive:0/10, asdf_3:15/8, strike_jab:24/52, thornbed:36/32, set_gong:3/10, gale:33/24, bog:11/12, plant_bamboo:5/12, asdf_2:17/8, asdf:1/8, lava_field:11/8, new_skill:2/8, thorn_lash:10/12, snare:0/12, shove:3/24, strike_thrust:2/10, quake_leap:3/4, gloom_rift:22/12, fire_trail:14/8, glide:27/22, coiling_rift:4/8, run:94/44, void_pull:45/36 |
| screens | cinder_dive:0/10, asdf_3:15/8, strike_jab:23/52, thornbed:43/32, set_gong:4/10, gale:31/24, bog:18/12, plant_bamboo:4/12, asdf_2:15/8, asdf:2/8, lava_field:7/8, new_skill:1/8, thorn_lash:9/12, snare:0/12, shove:2/24, strike_thrust:5/10, quake_leap:5/4, gloom_rift:31/12, fire_trail:14/8, glide:32/22, coiling_rift:6/8, run:80/44, void_pull:44/36 |
| split | cinder_dive:0/10, asdf_3:13/8, strike_jab:27/52, thornbed:16/32, set_gong:4/10, gale:29/24, bog:18/12, plant_bamboo:6/12, asdf_2:14/8, asdf:3/8, lava_field:15/8, new_skill:2/8, thorn_lash:11/12, snare:0/12, shove:4/24, strike_thrust:0/10, quake_leap:6/4, gloom_rift:9/12, fire_trail:17/8, glide:22/22, coiling_rift:6/8, run:80/44, void_pull:45/36 |
| split_mist | cinder_dive:0/10, mist_step:51/44, asdf_3:5/8, strike_jab:22/52, thornbed:24/32, set_gong:5/10, gale:37/24, bog:17/12, plant_bamboo:7/12, asdf_2:5/2, asdf:3/8, lava_field:14/8, new_skill:2/8, thorn_lash:6/12, snare:0/12, shove:3/24, strike_thrust:2/10, quake_leap:6/4, gloom_rift:27/12, fire_trail:3/2, glide:13/12, coiling_rift:3/8, run:44/22, void_pull:61/36 |
| split_cloud | cinder_dive:0/10, asdf_3:15/8, strike_jab:32/52, thornbed:27/32, set_gong:3/10, gale:38/24, bog:20/12, plant_bamboo:15/12, asdf_2:4/2, asdf:0/8, lava_field:29/8, new_skill:3/8, thorn_lash:5/12, snare:0/12, shove:1/24, strike_thrust:1/10, quake_leap:4/4, gloom_rift:18/12, fire_trail:2/2, glide:13/12, coiling_rift:6/8, cloudstep_token:43/44, run:38/22, void_pull:50/36 |
| both_mist | cinder_dive:0/10, mist_step:97/86, asdf_3:12/8, strike_jab:31/52, thornbed:30/32, set_gong:7/10, gale:27/24, bog:15/12, plant_bamboo:13/12, asdf:4/8, lava_field:14/8, new_skill:2/8, thorn_lash:6/12, snare:0/12, shove:1/24, strike_thrust:1/10, gloom_rift:38/12, coiling_rift:4/8, void_pull:56/36 |
| both_cloud | cinder_dive:8/10, asdf_3:10/8, strike_jab:30/52, thornbed:19/32, set_gong:5/10, gale:35/24, bog:19/12, plant_bamboo:9/12, asdf:2/8, lava_field:22/8, new_skill:2/8, thorn_lash:6/12, snare:0/12, shove:2/24, strike_thrust:4/10, gloom_rift:18/12, coiling_rift:4/8, cloudstep_token:84/86, void_pull:44/36 |
| both_screen | asdf_3:14/8, strike_jab:21/52, thornbed:12/8, gale:22/24, bog:13/12, asdf_2:13/8, raise_reed_screen:22/96, asdf:2/8, new_skill:7/8, thorn_lash:12/12, snare:1/12, shove:0/12, strike_thrust:4/10, quake_leap:4/4, fire_trail:10/8, glide:30/22, run:97/44, void_pull:45/36 |

Limitations: small, bot- and roster-dependent teamwide interventions; paired draws are not independent per swap. Not human agency/fun/fairness validation, single-monster causal odds, equal-price comparisons, approved progression or balance/price evidence.

## Discovery diagnostics (both teams pooled)
No-own-turn = defeat after FIRST positive damage without a subsequent turn_started for that victim; prior turns do not count. Descriptive response-window metric, NOT an unfairness verdict. Candidate counts are activations/actual fielded slots, not successful effects. Round counts use event round_started. Map fingerprints cover pre-begin grounds/props, excluding units. Parent unilateral class label does not apply to map-only scenarios: maps affect both teams.
| Scenario | Eligible/unchanged units | Applied slots | Species old→new ledger | No-own-turn defeats/battles | Candidate uses/fielded slots | Candidate activations by round | Battles using candidate | Well/flank HP damage | Map SHA256s |
|---|---|---|---|---|---|---|---|---|---|
| base | 0/96 | 0 | — | 19/14 | — | — | 0/16 | 85/17 | 1f8706826281ca3d1306e1a5a44c2540cf334e1d0eed45339165654c271d45cb:true, 297d450aa8d17484ff95fea627cd35bea3f144847e55f6db17ead2ef4e25b18b:true, 72768ad398542d0f2b55e9780bee8e2bb4c63c1c13ce2725dc5f9ba4379a7da7:true, 774c781d1a4541b76de2518b761f67d34839987f91c8ed33425f5b2bdc56b038:true, 7ce3d0196436868382983272a4f465fd20c55ce7298df9b97294943ec2db737e:true, 839f09ec8735be48f6df3d635df527f57b3f7028c88c4d9e62626d01f297026f:true, c888401816af608500a32bcc47b9baa17f3defc0f6940a1022b3dd3102a84410:true |
| mist_step | 44/52 | 44 | asdf asdf_2→mist_step:6, blaze_tiger fire_trail→mist_step:6, dusk_moth run→mist_step:4, gloom_wolf run→mist_step:8, hollow_serpent run→mist_step:4, moss_turtle run→mist_step:6, thorn_mites glide→mist_step:10 | 16/13 | mist_step:[50, 44] | mist_step/r1:22, mist_step/r2:15, mist_step/r3:9, mist_step/r4:4 | 16/16 | 116/12 | 1f8706826281ca3d1306e1a5a44c2540cf334e1d0eed45339165654c271d45cb:true, 297d450aa8d17484ff95fea627cd35bea3f144847e55f6db17ead2ef4e25b18b:true, 72768ad398542d0f2b55e9780bee8e2bb4c63c1c13ce2725dc5f9ba4379a7da7:true, 774c781d1a4541b76de2518b761f67d34839987f91c8ed33425f5b2bdc56b038:true, 7ce3d0196436868382983272a4f465fd20c55ce7298df9b97294943ec2db737e:true, 839f09ec8735be48f6df3d635df527f57b3f7028c88c4d9e62626d01f297026f:true, c888401816af608500a32bcc47b9baa17f3defc0f6940a1022b3dd3102a84410:true |
| receding_blow | 24/72 | 24 | blaze_tiger strike_jab→receding_blow:6, forge_golem strike_jab→receding_blow:4, hollow_serpent strike_jab→receding_blow:4, thorn_mites strike_jab→receding_blow:10 | 19/14 | receding_blow:[9, 24] | receding_blow/r1:3, receding_blow/r2:2, receding_blow/r3:4 | 6/16 | 91/17 | 1f8706826281ca3d1306e1a5a44c2540cf334e1d0eed45339165654c271d45cb:true, 297d450aa8d17484ff95fea627cd35bea3f144847e55f6db17ead2ef4e25b18b:true, 72768ad398542d0f2b55e9780bee8e2bb4c63c1c13ce2725dc5f9ba4379a7da7:true, 774c781d1a4541b76de2518b761f67d34839987f91c8ed33425f5b2bdc56b038:true, 7ce3d0196436868382983272a4f465fd20c55ce7298df9b97294943ec2db737e:true, 839f09ec8735be48f6df3d635df527f57b3f7028c88c4d9e62626d01f297026f:true, c888401816af608500a32bcc47b9baa17f3defc0f6940a1022b3dd3102a84410:true |
| cloudstep_token | 44/52 | 44 | asdf asdf_2→cloudstep_token:6, blaze_tiger fire_trail→cloudstep_token:6, dusk_moth run→cloudstep_token:4, gloom_wolf run→cloudstep_token:8, hollow_serpent run→cloudstep_token:4, moss_turtle run→cloudstep_token:6, thorn_mites glide→cloudstep_token:10 | 29/16 | cloudstep_token:[44, 44] | cloudstep_token/r1:42, cloudstep_token/r2:2 | 16/16 | 92/13 | 1f8706826281ca3d1306e1a5a44c2540cf334e1d0eed45339165654c271d45cb:true, 297d450aa8d17484ff95fea627cd35bea3f144847e55f6db17ead2ef4e25b18b:true, 72768ad398542d0f2b55e9780bee8e2bb4c63c1c13ce2725dc5f9ba4379a7da7:true, 774c781d1a4541b76de2518b761f67d34839987f91c8ed33425f5b2bdc56b038:true, 7ce3d0196436868382983272a4f465fd20c55ce7298df9b97294943ec2db737e:true, 839f09ec8735be48f6df3d635df527f57b3f7028c88c4d9e62626d01f297026f:true, c888401816af608500a32bcc47b9baa17f3defc0f6940a1022b3dd3102a84410:true |
| raise_reed_screen | 48/48 | 48 | asdf thornbed→raise_reed_screen:6, blaze_tiger lava_field→raise_reed_screen:6, dusk_moth gloom_rift→raise_reed_screen:4, forge_golem set_gong→raise_reed_screen:4, gloom_wolf plant_bamboo→raise_reed_screen:8, hollow_serpent coiling_rift→raise_reed_screen:4, moss_turtle shove→raise_reed_screen:6, thorn_mites thornbed→raise_reed_screen:10 | 16/13 | raise_reed_screen:[8, 48] | raise_reed_screen/r1:5, raise_reed_screen/r2:2, raise_reed_screen/r4:1 | 8/16 | 94/23 | 1f8706826281ca3d1306e1a5a44c2540cf334e1d0eed45339165654c271d45cb:true, 297d450aa8d17484ff95fea627cd35bea3f144847e55f6db17ead2ef4e25b18b:true, 72768ad398542d0f2b55e9780bee8e2bb4c63c1c13ce2725dc5f9ba4379a7da7:true, 774c781d1a4541b76de2518b761f67d34839987f91c8ed33425f5b2bdc56b038:true, 7ce3d0196436868382983272a4f465fd20c55ce7298df9b97294943ec2db737e:true, 839f09ec8735be48f6df3d635df527f57b3f7028c88c4d9e62626d01f297026f:true, c888401816af608500a32bcc47b9baa17f3defc0f6940a1022b3dd3102a84410:true |
| open | 0/96 | 0 | — | 14/11 | — | — | 0/16 | 101/10 | 20b3dc1c5dffcd8c1c5577acdcbcc6e980f40316d0d6fe6020c9ee6ea4fce3a9:true |
| screens | 0/96 | 0 | — | 11/8 | — | — | 0/16 | 118/13 | 13fa5c5b7f98b9e2afab941be6987fc1b8f9307e4ac9c1b284cbe756d781c7c5:true, 39ee842182eaa941ca66dc6c380ef7e9b466159d0f235eec49f547fc5f486640:true, 564e5039d965301802f7e266d2621d26363649c803dae8d9410f6b6ba8cc45db:true, 6cb6c5b0761a9f0f4c6f8f66da110416c054d178ee08f05b988febe270e51dbf:true, 8f99fa93198b32e7873ff9b4601fa44e7371ae4f385899a8096bbe9d537b5678:true, fedc3faba70658c1e1c33c2e99fc0f245cfbfda5dc6f10238a81b217ad8bf5b8:true |
| split | 0/96 | 0 | — | 22/16 | — | — | 0/16 | 70/24 | c0734b6bfde173096c39f516765f3cd49642ca9a88df67b606e4400fad225090:true, d932bd623d54f91d82768737de70c0f3dda6acff94cd0a0ad1486b44bc343ac7:true |
| split_mist | 44/52 | 44 | asdf asdf_2→mist_step:6, blaze_tiger fire_trail→mist_step:6, dusk_moth run→mist_step:4, gloom_wolf run→mist_step:8, hollow_serpent run→mist_step:4, moss_turtle run→mist_step:6, thorn_mites glide→mist_step:10 | 29/15 | mist_step:[51, 44] | mist_step/r1:25, mist_step/r2:16, mist_step/r3:5, mist_step/r4:4, mist_step/r5:1 | 16/16 | 95/13 | c0734b6bfde173096c39f516765f3cd49642ca9a88df67b606e4400fad225090:true, d932bd623d54f91d82768737de70c0f3dda6acff94cd0a0ad1486b44bc343ac7:true |
| split_cloud | 44/52 | 44 | asdf asdf_2→cloudstep_token:6, blaze_tiger fire_trail→cloudstep_token:6, dusk_moth run→cloudstep_token:4, gloom_wolf run→cloudstep_token:8, hollow_serpent run→cloudstep_token:4, moss_turtle run→cloudstep_token:6, thorn_mites glide→cloudstep_token:10 | 25/15 | cloudstep_token:[43, 44] | cloudstep_token/r1:41, cloudstep_token/r2:1, cloudstep_token/r3:1 | 16/16 | 61/19 | c0734b6bfde173096c39f516765f3cd49642ca9a88df67b606e4400fad225090:true, d932bd623d54f91d82768737de70c0f3dda6acff94cd0a0ad1486b44bc343ac7:true |
| both_mist | 86/10 | 86 | asdf asdf_2→mist_step:8, blaze_tiger fire_trail→mist_step:8, dusk_moth run→mist_step:12, ember_hawk glide→mist_step:10, gloom_wolf run→mist_step:12, grove_wisp quake_leap→mist_step:4, hollow_serpent run→mist_step:8, moss_turtle run→mist_step:12, thorn_mites glide→mist_step:12 | 14/12 | mist_step:[97, 86] | mist_step/r1:45, mist_step/r2:31, mist_step/r3:17, mist_step/r4:3, mist_step/r5:1 | 16/16 | 113/12 | 1f8706826281ca3d1306e1a5a44c2540cf334e1d0eed45339165654c271d45cb:true, 297d450aa8d17484ff95fea627cd35bea3f144847e55f6db17ead2ef4e25b18b:true, 72768ad398542d0f2b55e9780bee8e2bb4c63c1c13ce2725dc5f9ba4379a7da7:true, 774c781d1a4541b76de2518b761f67d34839987f91c8ed33425f5b2bdc56b038:true, 7ce3d0196436868382983272a4f465fd20c55ce7298df9b97294943ec2db737e:true, 839f09ec8735be48f6df3d635df527f57b3f7028c88c4d9e62626d01f297026f:true, c888401816af608500a32bcc47b9baa17f3defc0f6940a1022b3dd3102a84410:true |
| both_cloud | 86/10 | 86 | asdf asdf_2→cloudstep_token:8, blaze_tiger fire_trail→cloudstep_token:8, dusk_moth run→cloudstep_token:12, ember_hawk glide→cloudstep_token:10, gloom_wolf run→cloudstep_token:12, grove_wisp quake_leap→cloudstep_token:4, hollow_serpent run→cloudstep_token:8, moss_turtle run→cloudstep_token:12, thorn_mites glide→cloudstep_token:12 | 21/13 | cloudstep_token:[84, 86] | cloudstep_token/r1:78, cloudstep_token/r2:6 | 16/16 | 104/17 | 1f8706826281ca3d1306e1a5a44c2540cf334e1d0eed45339165654c271d45cb:true, 297d450aa8d17484ff95fea627cd35bea3f144847e55f6db17ead2ef4e25b18b:true, 72768ad398542d0f2b55e9780bee8e2bb4c63c1c13ce2725dc5f9ba4379a7da7:true, 774c781d1a4541b76de2518b761f67d34839987f91c8ed33425f5b2bdc56b038:true, 7ce3d0196436868382983272a4f465fd20c55ce7298df9b97294943ec2db737e:true, 839f09ec8735be48f6df3d635df527f57b3f7028c88c4d9e62626d01f297026f:true, c888401816af608500a32bcc47b9baa17f3defc0f6940a1022b3dd3102a84410:true |
| both_screen | 96/0 | 96 | asdf thornbed→raise_reed_screen:8, blaze_tiger lava_field→raise_reed_screen:8, dusk_moth gloom_rift→raise_reed_screen:12, ember_hawk cinder_dive→raise_reed_screen:10, forge_golem set_gong→raise_reed_screen:10, gloom_wolf plant_bamboo→raise_reed_screen:12, grove_wisp thornbed→raise_reed_screen:4, hollow_serpent coiling_rift→raise_reed_screen:8, moss_turtle shove→raise_reed_screen:12, thorn_mites thornbed→raise_reed_screen:12 | 17/13 | raise_reed_screen:[22, 96] | raise_reed_screen/r1:10, raise_reed_screen/r2:11, raise_reed_screen/r4:1 | 13/16 | 100/21 | 1f8706826281ca3d1306e1a5a44c2540cf334e1d0eed45339165654c271d45cb:true, 297d450aa8d17484ff95fea627cd35bea3f144847e55f6db17ead2ef4e25b18b:true, 72768ad398542d0f2b55e9780bee8e2bb4c63c1c13ce2725dc5f9ba4379a7da7:true, 774c781d1a4541b76de2518b761f67d34839987f91c8ed33425f5b2bdc56b038:true, 7ce3d0196436868382983272a4f465fd20c55ce7298df9b97294943ec2db737e:true, 839f09ec8735be48f6df3d635df527f57b3f7028c88c4d9e62626d01f297026f:true, c888401816af608500a32bcc47b9baa17f3defc0f6940a1022b3dd3102a84410:true |
DISCOVERY_MEASUREMENT_COMPLETED: final guard matches startup content=a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2 resources=cloudstep_token:97a751e9ce198fb1a6a41fae7b99428ea2e13abfafba861a20852d2867161e1e, mist_step:652b415efe17683a0e2e9f509e28a57ca27e3cf260ea1ad45fa1da9189af51eb, raise_reed_screen:9211eea71bc9671524d8541ffdbed88b28256aa73bbb94bfbb235e90021f1f84, receding_blow:b5daf6cb86c6da57a45d4800912150d6ecc35ee6d09b703f71db8c52858c50b1, reed_screen:a6f4b626ff57693209e07c1e3be292af26596920cfba07d892e42bb4c3adaba0
```

#### discovery_cost1.txt

```text
# Authored discovery experiment
AP/TPR/HP/Init/Movement/Reach are authored, full HP, no entry proxy. current-ap=1 is an explicit bilateral ZONE PUSH/PULL candidate (including Bog), NOT normal defaults. All skills use duplicate_deep ALL. Subject A is scored after both side swaps. No prices/budgets asserted.
Harness own SHA256=747b3a6b9d6b5b2a1d9a25aff545e81dc3faed46692a3291a4d69ababbf22f45; parent SHA256=b40a5b2079d1012659f90c2a159c1a911dcbe4e3efc4b6c015b73858215fd38c; content=a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2; new resource hashes=cloudstep_token:97a751e9ce198fb1a6a41fae7b99428ea2e13abfafba861a20852d2867161e1e, mist_step:652b415efe17683a0e2e9f509e28a57ca27e3cf260ea1ad45fa1da9189af51eb, raise_reed_screen:9211eea71bc9671524d8541ffdbed88b28256aa73bbb94bfbb235e90021f1f84, receding_blow:b5daf6cb86c6da57a45d4800912150d6ecc35ee6d09b703f71db8c52858c50b1, reed_screen:a6f4b626ff57693209e07c1e3be292af26596920cfba07d892e42bb4c3adaba0; Godot=4.7.2-stable (official)
Maps: base uses canonical RUNNER seeded board. open removes every preplaced prop without aftermath, retains grounds/veins. screens replaces props with exactly two point-mirrored reed_screen pairs. split first relocates veins (1,3),(3,3),(5,3) -> (1,2),(3,3),(5,4), then uses the same screen generator. split_mist/cloud also replace subject movement. Props block movement only; NO ranged cover. No starter grass is added. Map RNG is local, seeded with setup seed; play/setup RNG is untouched by edits.
Eligibility: first MOVE for mist/cloud; first positive-damage Jab with no board ops for receding, preserving kin_effect. Winged already retreats: retreat flag does not stack. Screen: first pure CREATE_PROP placement, else first GROUND, else last slot; no extra slots. Only subject changes except both_*. Both teams receive map edits. Schedule: same draw-A/draw-B-excluding-A/setup-seed progression scheme; fresh setup RNG each scenario/swap, divergent play may consume different RNG draws.

| Seed | Pair | Subject A | Opponent B | Setup seed |
|---|---|---|---|---|
| 501 | 1 | ember_hawk,thorn_mites,blaze_tiger | hollow_serpent,dusk_moth,grove_wisp | 570115152 |
| 501 | 2 | dusk_moth,moss_turtle,gloom_wolf | ember_hawk,hollow_serpent,asdf | 1013980655 |
| 501 | 3 | asdf,hollow_serpent,dusk_moth | forge_golem,ember_hawk,gloom_wolf | 1070734350 |
| 501 | 4 | gloom_wolf,ember_hawk,hollow_serpent | grove_wisp,forge_golem,asdf | 30231281 |
| 502 | 1 | gloom_wolf,dusk_moth,moss_turtle | hollow_serpent,asdf,thorn_mites | 222702981 |
| 502 | 2 | forge_golem,hollow_serpent,dusk_moth | asdf,ember_hawk,blaze_tiger | 842894528 |
| 502 | 3 | gloom_wolf,moss_turtle,asdf | blaze_tiger,thorn_mites,hollow_serpent | 945091684 |
| 502 | 4 | gloom_wolf,forge_golem,blaze_tiger | grove_wisp,hollow_serpent,dusk_moth | 28144822 |
Schedule SHA256=5acde110792dc92afe490d5511dc11144270cba4728e37b35fe4b9ccba5a7764

## Aggregate

Score=(wins+0.5×true draws)/(games−timeouts); timeouts separate. Rounds include timeout partial rounds; histograms allow exact weighted means. Defeat/damage/activation metrics cover BOTH teams; first-defeat turns count turn_started events through the first defeat, omitting games with none. Collision is collision HP damage (not collision events). Repeat=second/later activation of same actor+skill within one turn, including slotted movement, excluding Step; event fallback matches sim.gd, not distinct slot identity.

| Scenario | Class | Games | A W/L/D/timeout | Score | Mean rounds | <2/>5/max | Pre-first-turn defeats/games | Turns to first defeat (n) | Collision/total damage | Repeats/activations | Round histogram |
|---|---|---|---|---|---|---|---|---|---|---|---|
| base | control | 16 | 9/7/0/0 | 0.56 | 2.38 | 1/0/3 | 0/0 | 4.25 (16) | 162/391 | 108/390 (0.28) | 1:1, 2:8, 3:7 |
| mist_step | unilateral | 16 | 8/8/0/0 | 0.50 | 2.56 | 0/0/3 | 0/0 | 6.56 (16) | 165/400 | 91/405 (0.22) | 2:7, 3:9 |
| cloudstep_token | unilateral | 16 | 11/4/1/0 | 0.72 | 2.56 | 0/0/3 | 0/0 | 4.75 (16) | 189/407 | 87/377 (0.23) | 2:7, 3:9 |
| screens | unilateral | 16 | 11/5/0/0 | 0.69 | 2.31 | 0/0/3 | 0/0 | 6.75 (16) | 168/407 | 112/391 (0.29) | 2:11, 3:5 |
| split_mist | unilateral | 16 | 8/8/0/0 | 0.50 | 3.25 | 0/0/5 | 0/0 | 6.13 (16) | 177/403 | 112/432 (0.26) | 2:2, 3:9, 4:4, 5:1 |

## Start affordability and actual interventions

Both teams pooled, repeated per game. Affordability only: cost≤sheet AP, NOT target legality; no assumption that a low-stage kit should be fully affordable. Move/attack counts units with an affordable slotted MOVE/damaging STRIKE (not universal Step). Stat deltas: attempted/applied sum/changed count/cap-blocked count, per upgraded member. strike_ground: eligible damaging STRIKE attempts/applied/not_applied (existing ground); proposed content variant, not an approved slot choice. No rounding of exact counts.

| Scenario | Affordable/active slots | No affordable active/units | Has move/attack | Unaffordable ID:slot count | Stat delta attempted/sum/changed/blocked | strike_ground counts |
|---|---|---|---|---|---|---|
| base | 384/384 | 0/96 | 88/78 | — | — | — |
| mist_step | 384/384 | 0/96 | 88/78 | — | — | — |
| cloudstep_token | 384/384 | 0/96 | 88/78 | — | — | — |
| screens | 384/384 | 0/96 | 88/78 | — | — | — |
| split_mist | 384/384 | 0/96 | 88/78 | — | — | — |

## Active skill usage

All equipped active IDs, not just top skills; activations/start slots pooled over both teams and games (not success rates).

| Scenario | ID:activations/start slots |
|---|---|
| base | cinder_dive:0/10, asdf_3:31/12, strike_jab:21/54, thornbed:16/40, set_gong:1/8, gale:53/24, bog:20/6, plant_bamboo:4/12, asdf_2:21/12, asdf:4/12, lava_field:8/8, new_skill:4/8, thorn_lash:7/12, snare:0/12, shove:0/18, strike_thrust:0/8, quake_leap:4/6, gloom_rift:17/12, fire_trail:10/8, glide:19/16, coiling_rift:13/16, run:98/46, void_pull:39/24 |
| mist_step | cinder_dive:3/10, mist_step:52/44, asdf_3:30/12, strike_jab:22/54, thornbed:26/40, set_gong:2/8, gale:61/24, bog:21/6, plant_bamboo:9/12, asdf_2:17/8, asdf:3/12, lava_field:12/8, new_skill:3/8, thorn_lash:3/12, snare:0/12, shove:0/18, strike_thrust:2/8, quake_leap:8/6, gloom_rift:22/12, fire_trail:9/4, glide:13/10, coiling_rift:11/16, run:38/16, void_pull:38/24 |
| cloudstep_token | cinder_dive:0/10, asdf_3:35/12, strike_jab:24/54, thornbed:26/40, set_gong:0/8, gale:50/24, bog:20/6, plant_bamboo:4/12, asdf_2:17/8, asdf:4/12, lava_field:10/8, new_skill:1/8, thorn_lash:3/12, snare:1/12, shove:2/18, strike_thrust:3/8, quake_leap:6/6, gloom_rift:23/12, fire_trail:8/4, glide:10/10, coiling_rift:14/16, cloudstep_token:43/44, run:25/16, void_pull:48/24 |
| screens | cinder_dive:0/10, asdf_3:34/12, strike_jab:22/54, thornbed:13/40, set_gong:1/8, gale:48/24, bog:17/6, plant_bamboo:6/12, asdf_2:18/12, asdf:5/12, lava_field:10/8, new_skill:4/8, thorn_lash:8/12, snare:1/12, shove:2/18, strike_thrust:6/8, quake_leap:10/6, gloom_rift:25/12, fire_trail:10/8, glide:23/16, coiling_rift:4/16, run:96/46, void_pull:28/24 |
| split_mist | cinder_dive:0/10, mist_step:50/44, asdf_3:24/12, strike_jab:33/54, thornbed:31/40, set_gong:0/8, gale:83/24, bog:18/6, plant_bamboo:3/12, asdf_2:13/8, asdf:3/12, lava_field:8/8, new_skill:3/8, thorn_lash:4/12, snare:0/12, shove:2/18, strike_thrust:0/8, quake_leap:6/6, gloom_rift:24/12, fire_trail:5/4, glide:9/10, coiling_rift:9/16, run:35/16, void_pull:69/24 |

Limitations: small, bot- and roster-dependent teamwide interventions; paired draws are not independent per swap. Not human agency/fun/fairness validation, single-monster causal odds, equal-price comparisons, approved progression or balance/price evidence.

## Discovery diagnostics (both teams pooled)
No-own-turn = defeat after FIRST positive damage without a subsequent turn_started for that victim; prior turns do not count. Descriptive response-window metric, NOT an unfairness verdict. Candidate counts are activations/actual fielded slots, not successful effects. Round counts use event round_started. Map fingerprints cover pre-begin grounds/props, excluding units. Parent unilateral class label does not apply to map-only scenarios: maps affect both teams.
| Scenario | Eligible/unchanged units | Applied slots | Species old→new ledger | No-own-turn defeats/battles | Candidate uses/fielded slots | Candidate activations by round | Battles using candidate | Well/flank HP damage | Map SHA256s |
|---|---|---|---|---|---|---|---|---|---|
| base | 0/96 | 0 | — | 26/15 | — | — | 0/16 | 76/9 | 1dadfcae8617d12bfab200dbaae0bdc88a5f6a779ab56469f601eedf46f0edac:true, 390cdb5c2f65671232dc99d621a5fb6416cdd6a195d42199f91cc8fc66f5104f:true, 7225665215211341d8cb239247d47fb68197164f5565a7b123b39720aeafb0e9:true, 83272b53bafa517b64275b0de780e57d42a594e7399909f65e5338c273503541:true, 895b408d0bf0b3d7483f0a574fcf79a80a8a7acb6f65c7e5cc9cee896a10a891:true, 9a161cee72c97978dff557e47ccfe61a2884a6b47c270d3eae80e67a03198f5c:true, ed3a312b3b70b0ab6f5309f698e76cc8c03073bc4acd028feababdd37a2f8ce6:true, ed95f62a0ccbca30e0ac4476b8c68101b4370c92cd8cd8d5f0dbf5c6cc3b2268:true |
| mist_step | 44/52 | 44 | asdf asdf_2→mist_step:4, blaze_tiger fire_trail→mist_step:4, dusk_moth run→mist_step:8, ember_hawk glide→mist_step:4, gloom_wolf run→mist_step:10, hollow_serpent run→mist_step:6, moss_turtle run→mist_step:6, thorn_mites glide→mist_step:2 | 21/14 | mist_step:[52, 44] | mist_step/r1:28, mist_step/r2:18, mist_step/r3:6 | 16/16 | 84/12 | 1dadfcae8617d12bfab200dbaae0bdc88a5f6a779ab56469f601eedf46f0edac:true, 390cdb5c2f65671232dc99d621a5fb6416cdd6a195d42199f91cc8fc66f5104f:true, 7225665215211341d8cb239247d47fb68197164f5565a7b123b39720aeafb0e9:true, 83272b53bafa517b64275b0de780e57d42a594e7399909f65e5338c273503541:true, 895b408d0bf0b3d7483f0a574fcf79a80a8a7acb6f65c7e5cc9cee896a10a891:true, 9a161cee72c97978dff557e47ccfe61a2884a6b47c270d3eae80e67a03198f5c:true, ed3a312b3b70b0ab6f5309f698e76cc8c03073bc4acd028feababdd37a2f8ce6:true, ed95f62a0ccbca30e0ac4476b8c68101b4370c92cd8cd8d5f0dbf5c6cc3b2268:true |
| cloudstep_token | 44/52 | 44 | asdf asdf_2→cloudstep_token:4, blaze_tiger fire_trail→cloudstep_token:4, dusk_moth run→cloudstep_token:8, ember_hawk glide→cloudstep_token:4, gloom_wolf run→cloudstep_token:10, hollow_serpent run→cloudstep_token:6, moss_turtle run→cloudstep_token:6, thorn_mites glide→cloudstep_token:2 | 30/16 | cloudstep_token:[43, 44] | cloudstep_token/r1:40, cloudstep_token/r2:3 | 16/16 | 89/5 | 1dadfcae8617d12bfab200dbaae0bdc88a5f6a779ab56469f601eedf46f0edac:true, 390cdb5c2f65671232dc99d621a5fb6416cdd6a195d42199f91cc8fc66f5104f:true, 7225665215211341d8cb239247d47fb68197164f5565a7b123b39720aeafb0e9:true, 83272b53bafa517b64275b0de780e57d42a594e7399909f65e5338c273503541:true, 895b408d0bf0b3d7483f0a574fcf79a80a8a7acb6f65c7e5cc9cee896a10a891:true, 9a161cee72c97978dff557e47ccfe61a2884a6b47c270d3eae80e67a03198f5c:true, ed3a312b3b70b0ab6f5309f698e76cc8c03073bc4acd028feababdd37a2f8ce6:true, ed95f62a0ccbca30e0ac4476b8c68101b4370c92cd8cd8d5f0dbf5c6cc3b2268:true |
| screens | 0/96 | 0 | — | 25/14 | — | — | 0/16 | 82/18 | 13fa5c5b7f98b9e2afab941be6987fc1b8f9307e4ac9c1b284cbe756d781c7c5:true, 39ee842182eaa941ca66dc6c380ef7e9b466159d0f235eec49f547fc5f486640:true, 564e5039d965301802f7e266d2621d26363649c803dae8d9410f6b6ba8cc45db:true, 6cb6c5b0761a9f0f4c6f8f66da110416c054d178ee08f05b988febe270e51dbf:true, 8f99fa93198b32e7873ff9b4601fa44e7371ae4f385899a8096bbe9d537b5678:true |
| split_mist | 44/52 | 44 | asdf asdf_2→mist_step:4, blaze_tiger fire_trail→mist_step:4, dusk_moth run→mist_step:8, ember_hawk glide→mist_step:4, gloom_wolf run→mist_step:10, hollow_serpent run→mist_step:6, moss_turtle run→mist_step:6, thorn_mites glide→mist_step:2 | 25/15 | mist_step:[50, 44] | mist_step/r1:19, mist_step/r2:20, mist_step/r3:9, mist_step/r4:1, mist_step/r5:1 | 16/16 | 67/13 | c0734b6bfde173096c39f516765f3cd49642ca9a88df67b606e4400fad225090:true, d932bd623d54f91d82768737de70c0f3dda6acff94cd0a0ad1486b44bc343ac7:true |
DISCOVERY_MEASUREMENT_COMPLETED: final guard matches startup content=a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2 resources=cloudstep_token:97a751e9ce198fb1a6a41fae7b99428ea2e13abfafba861a20852d2867161e1e, mist_step:652b415efe17683a0e2e9f509e28a57ca27e3cf260ea1ad45fa1da9189af51eb, raise_reed_screen:9211eea71bc9671524d8541ffdbed88b28256aa73bbb94bfbb235e90021f1f84, receding_blow:b5daf6cb86c6da57a45d4800912150d6ecc35ee6d09b703f71db8c52858c50b1, reed_screen:a6f4b626ff57693209e07c1e3be292af26596920cfba07d892e42bb4c3adaba0
```

#### discovery_tactic.txt

```text
# Authored discovery experiment
AP/TPR/HP/Init/Movement/Reach are authored, full HP, no entry proxy. current-ap=2 is an explicit bilateral ZONE PUSH/PULL candidate (including Bog), NOT normal defaults. All skills use duplicate_deep ALL. Subject A is scored after both side swaps. No prices/budgets asserted.
Harness own SHA256=747b3a6b9d6b5b2a1d9a25aff545e81dc3faed46692a3291a4d69ababbf22f45; parent SHA256=b40a5b2079d1012659f90c2a159c1a911dcbe4e3efc4b6c015b73858215fd38c; content=a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2; new resource hashes=cloudstep_token:97a751e9ce198fb1a6a41fae7b99428ea2e13abfafba861a20852d2867161e1e, mist_step:652b415efe17683a0e2e9f509e28a57ca27e3cf260ea1ad45fa1da9189af51eb, raise_reed_screen:9211eea71bc9671524d8541ffdbed88b28256aa73bbb94bfbb235e90021f1f84, receding_blow:b5daf6cb86c6da57a45d4800912150d6ecc35ee6d09b703f71db8c52858c50b1, reed_screen:a6f4b626ff57693209e07c1e3be292af26596920cfba07d892e42bb4c3adaba0; Godot=4.7.2-stable (official)
Maps: base uses canonical RUNNER seeded board. open removes every preplaced prop without aftermath, retains grounds/veins. screens replaces props with exactly two point-mirrored reed_screen pairs. split first relocates veins (1,3),(3,3),(5,3) -> (1,2),(3,3),(5,4), then uses the same screen generator. split_mist/cloud also replace subject movement. Props block movement only; NO ranged cover. No starter grass is added. Map RNG is local, seeded with setup seed; play/setup RNG is untouched by edits.
Eligibility: first MOVE for mist/cloud; first positive-damage Jab with no board ops for receding, preserving kin_effect. Winged already retreats: retreat flag does not stack. Screen: first pure CREATE_PROP placement, else first GROUND, else last slot; no extra slots. Only subject changes except both_*. Both teams receive map edits. Schedule: same draw-A/draw-B-excluding-A/setup-seed progression scheme; fresh setup RNG each scenario/swap, divergent play may consume different RNG draws.

| Seed | Pair | Subject A | Opponent B | Setup seed |
|---|---|---|---|---|
| 501 | 1 | ember_hawk,thorn_mites,blaze_tiger | hollow_serpent,dusk_moth,grove_wisp | 570115152 |
| 503 | 1 | moss_turtle,blaze_tiger,hollow_serpent | grove_wisp,ember_hawk,gloom_wolf | 774216799 |
Schedule SHA256=0c465629bff4815471e32181b99c49d7ceea394e75632501cd3876c4122b9450

## Aggregate

Score=(wins+0.5×true draws)/(games−timeouts); timeouts separate. Rounds include timeout partial rounds; histograms allow exact weighted means. Defeat/damage/activation metrics cover BOTH teams; first-defeat turns count turn_started events through the first defeat, omitting games with none. Collision is collision HP damage (not collision events). Repeat=second/later activation of same actor+skill within one turn, including slotted movement, excluding Step; event fallback matches sim.gd, not distinct slot identity.

| Scenario | Class | Games | A W/L/D/timeout | Score | Mean rounds | <2/>5/max | Pre-first-turn defeats/games | Turns to first defeat (n) | Collision/total damage | Repeats/activations | Round histogram |
|---|---|---|---|---|---|---|---|---|---|---|---|
| base | control | 4 | 2/2/0/0 | 0.50 | 2.75 | 0/0/3 | 0/0 | 6.25 (4) | 34/97 | 17/91 (0.19) | 2:1, 3:3 |
| mist_step | unilateral | 4 | 1/3/0/0 | 0.25 | 3.00 | 0/0/3 | 0/0 | 6.00 (4) | 34/107 | 13/82 (0.16) | 3:4 |
| raise_reed_screen | unilateral | 4 | 2/2/0/0 | 0.50 | 3.00 | 0/0/4 | 0/0 | 7.00 (4) | 21/80 | 11/84 (0.13) | 2:2, 4:2 |
| split_mist | unilateral | 4 | 3/1/0/0 | 0.75 | 3.25 | 0/0/4 | 0/0 | 6.75 (4) | 41/101 | 11/88 (0.13) | 2:1, 3:1, 4:2 |

## Start affordability and actual interventions

Both teams pooled, repeated per game. Affordability only: cost≤sheet AP, NOT target legality; no assumption that a low-stage kit should be fully affordable. Move/attack counts units with an affordable slotted MOVE/damaging STRIKE (not universal Step). Stat deltas: attempted/applied sum/changed count/cap-blocked count, per upgraded member. strike_ground: eligible damaging STRIKE attempts/applied/not_applied (existing ground); proposed content variant, not an approved slot choice. No rounding of exact counts.

| Scenario | Affordable/active slots | No affordable active/units | Has move/attack | Unaffordable ID:slot count | Stat delta attempted/sum/changed/blocked | strike_ground counts |
|---|---|---|---|---|---|---|
| base | 96/96 | 0/24 | 24/20 | — | — | — |
| mist_step | 96/96 | 0/24 | 24/20 | — | — | — |
| raise_reed_screen | 96/96 | 0/24 | 24/20 | — | — | — |
| split_mist | 96/96 | 0/24 | 24/20 | — | — | — |

## Active skill usage

All equipped active IDs, not just top skills; activations/start slots pooled over both teams and games (not success rates).

| Scenario | ID:activations/start slots |
|---|---|
| base | cinder_dive:0/4, strike_jab:8/18, thornbed:11/10, gale:7/8, bog:2/2, plant_bamboo:1/2, lava_field:6/4, new_skill:0/4, thorn_lash:2/2, snare:0/2, shove:0/4, quake_leap:4/4, gloom_rift:5/2, fire_trail:6/4, glide:3/6, coiling_rift:0/4, run:32/10, void_pull:4/6 |
| mist_step | cinder_dive:0/4, mist_step:8/12, strike_jab:7/18, thornbed:12/10, gale:6/8, bog:1/2, plant_bamboo:0/2, lava_field:2/4, new_skill:1/4, thorn_lash:3/2, snare:0/2, shove:0/4, quake_leap:5/4, gloom_rift:3/2, glide:2/2, coiling_rift:1/4, run:23/6, void_pull:8/6 |
| raise_reed_screen | cinder_dive:0/2, strike_jab:14/18, thornbed:8/8, gale:3/8, bog:2/2, plant_bamboo:2/2, raise_reed_screen:7/12, new_skill:0/4, thorn_lash:1/2, snare:0/2, shove:0/2, quake_leap:4/4, gloom_rift:2/2, fire_trail:4/4, glide:8/6, coiling_rift:0/2, run:26/10, void_pull:3/6 |
| split_mist | cinder_dive:0/4, mist_step:12/12, strike_jab:8/18, thornbed:14/10, gale:6/8, bog:3/2, plant_bamboo:1/2, lava_field:3/4, new_skill:1/4, thorn_lash:2/2, snare:0/2, shove:0/4, quake_leap:4/4, gloom_rift:7/2, glide:3/2, coiling_rift:2/4, run:17/6, void_pull:5/6 |

Limitations: small, bot- and roster-dependent teamwide interventions; paired draws are not independent per swap. Not human agency/fun/fairness validation, single-monster causal odds, equal-price comparisons, approved progression or balance/price evidence.

## Discovery diagnostics (both teams pooled)
No-own-turn = defeat after FIRST positive damage without a subsequent turn_started for that victim; prior turns do not count. Descriptive response-window metric, NOT an unfairness verdict. Candidate counts are activations/actual fielded slots, not successful effects. Round counts use event round_started. Map fingerprints cover pre-begin grounds/props, excluding units. Parent unilateral class label does not apply to map-only scenarios: maps affect both teams.
| Scenario | Eligible/unchanged units | Applied slots | Species old→new ledger | No-own-turn defeats/battles | Candidate uses/fielded slots | Candidate activations by round | Battles using candidate | Well/flank HP damage | Map SHA256s |
|---|---|---|---|---|---|---|---|---|---|
| base | 0/24 | 0 | — | 5/4 | — | — | 0/4 | 33/2 | 390cdb5c2f65671232dc99d621a5fb6416cdd6a195d42199f91cc8fc66f5104f:true, 774c781d1a4541b76de2518b761f67d34839987f91c8ed33425f5b2bdc56b038:true |
| mist_step | 12/12 | 12 | blaze_tiger fire_trail→mist_step:4, ember_hawk glide→mist_step:2, hollow_serpent run→mist_step:2, moss_turtle run→mist_step:2, thorn_mites glide→mist_step:2 | 5/4 | mist_step:[8, 12] | mist_step/r1:3, mist_step/r2:4, mist_step/r3:1 | 4/4 | 29/2 | 390cdb5c2f65671232dc99d621a5fb6416cdd6a195d42199f91cc8fc66f5104f:true, 774c781d1a4541b76de2518b761f67d34839987f91c8ed33425f5b2bdc56b038:true |
| raise_reed_screen | 12/12 | 12 | blaze_tiger lava_field→raise_reed_screen:4, ember_hawk cinder_dive→raise_reed_screen:2, hollow_serpent coiling_rift→raise_reed_screen:2, moss_turtle shove→raise_reed_screen:2, thorn_mites thornbed→raise_reed_screen:2 | 8/4 | raise_reed_screen:[7, 12] | raise_reed_screen/r1:5, raise_reed_screen/r2:2 | 3/4 | 19/3 | 390cdb5c2f65671232dc99d621a5fb6416cdd6a195d42199f91cc8fc66f5104f:true, 774c781d1a4541b76de2518b761f67d34839987f91c8ed33425f5b2bdc56b038:true |
| split_mist | 12/12 | 12 | blaze_tiger fire_trail→mist_step:4, ember_hawk glide→mist_step:2, hollow_serpent run→mist_step:2, moss_turtle run→mist_step:2, thorn_mites glide→mist_step:2 | 4/2 | mist_step:[12, 12] | mist_step/r1:6, mist_step/r2:3, mist_step/r3:1, mist_step/r4:2 | 4/4 | 20/2 | d932bd623d54f91d82768737de70c0f3dda6acff94cd0a0ad1486b44bc343ac7:true |
DISCOVERY_MEASUREMENT_COMPLETED: final guard matches startup content=a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2 resources=cloudstep_token:97a751e9ce198fb1a6a41fae7b99428ea2e13abfafba861a20852d2867161e1e, mist_step:652b415efe17683a0e2e9f509e28a57ca27e3cf260ea1ad45fa1da9189af51eb, raise_reed_screen:9211eea71bc9671524d8541ffdbed88b28256aa73bbb94bfbb235e90021f1f84, receding_blow:b5daf6cb86c6da57a45d4800912150d6ecc35ee6d09b703f71db8c52858c50b1, reed_screen:a6f4b626ff57693209e07c1e3be292af26596920cfba07d892e42bb4c3adaba0
```

#### discovery_ablation.txt

```text
# Authored discovery experiment
AP/TPR/HP/Init/Movement/Reach are authored, full HP, no entry proxy. current-ap=2 is an explicit bilateral ZONE PUSH/PULL candidate (including Bog), NOT normal defaults. All skills use duplicate_deep ALL. Subject A is scored after both side swaps. No prices/budgets asserted.
Harness own SHA256=94970f7a44f98bde96bf7ecd635a6b1d386367fa16f3f586c76dbabecaba94d6; parent SHA256=b40a5b2079d1012659f90c2a159c1a911dcbe4e3efc4b6c015b73858215fd38c; content=a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2; new resource hashes=cloudstep_token:97a751e9ce198fb1a6a41fae7b99428ea2e13abfafba861a20852d2867161e1e, mist_step:652b415efe17683a0e2e9f509e28a57ca27e3cf260ea1ad45fa1da9189af51eb, raise_reed_screen:9211eea71bc9671524d8541ffdbed88b28256aa73bbb94bfbb235e90021f1f84, receding_blow:b5daf6cb86c6da57a45d4800912150d6ecc35ee6d09b703f71db8c52858c50b1, reed_screen:a6f4b626ff57693209e07c1e3be292af26596920cfba07d892e42bb4c3adaba0; Godot=4.7.2-stable (official)
Maps: base uses canonical RUNNER seeded board. open removes every preplaced prop without aftermath, retains grounds/veins. screens replaces props with exactly two point-mirrored reed_screen pairs. split first relocates veins (1,3),(3,3),(5,3) -> (1,2),(3,3),(5,4), then uses the same screen generator. split_mist/cloud also replace subject movement. Props block movement only; NO ranged cover. No starter grass is added. Map RNG is local, seeded with setup seed; play/setup RNG is untouched by edits.
Eligibility: first MOVE for mist/cloud; first positive-damage Jab with no board ops for receding, preserving kin_effect. Winged already retreats: retreat flag does not stack. Screen: first pure CREATE_PROP placement, else first GROUND, else last slot; no extra slots. Only subject changes except both_*. Both teams receive map edits. Schedule: same draw-A/draw-B-excluding-A/setup-seed progression scheme; fresh setup RNG each scenario/swap, divergent play may consume different RNG draws.
Ablation metadata: mist_control [no trail] / split_mist_control [no trail] replace the same first subject MOVE with a local deep copy of mist_step, clearing ONLY board_ops. Same 2 AP walk/profile; no trail or zone effect. split_mist_control uses identical split geometry. Candidate ID remains mist_step: usage/fielded-slot and round counts in these scenarios count the no-trail CONTROL, not zone-producing Mist Step.

| Seed | Pair | Subject A | Opponent B | Setup seed |
|---|---|---|---|---|
| 501 | 1 | ember_hawk,thorn_mites,blaze_tiger | hollow_serpent,dusk_moth,grove_wisp | 570115152 |
| 501 | 2 | dusk_moth,moss_turtle,gloom_wolf | ember_hawk,hollow_serpent,asdf | 1013980655 |
| 501 | 3 | asdf,hollow_serpent,dusk_moth | forge_golem,ember_hawk,gloom_wolf | 1070734350 |
| 501 | 4 | gloom_wolf,ember_hawk,hollow_serpent | grove_wisp,forge_golem,asdf | 30231281 |
| 502 | 1 | gloom_wolf,dusk_moth,moss_turtle | hollow_serpent,asdf,thorn_mites | 222702981 |
| 502 | 2 | forge_golem,hollow_serpent,dusk_moth | asdf,ember_hawk,blaze_tiger | 842894528 |
| 502 | 3 | gloom_wolf,moss_turtle,asdf | blaze_tiger,thorn_mites,hollow_serpent | 945091684 |
| 502 | 4 | gloom_wolf,forge_golem,blaze_tiger | grove_wisp,hollow_serpent,dusk_moth | 28144822 |
| 503 | 1 | moss_turtle,blaze_tiger,hollow_serpent | grove_wisp,ember_hawk,gloom_wolf | 774216799 |
| 503 | 2 | asdf,dusk_moth,blaze_tiger | ember_hawk,forge_golem,moss_turtle | 134545299 |
| 503 | 3 | dusk_moth,thorn_mites,blaze_tiger | gloom_wolf,forge_golem,moss_turtle | 640594562 |
| 503 | 4 | gloom_wolf,thorn_mites,moss_turtle | dusk_moth,ember_hawk,asdf | 101931872 |
| 504 | 1 | thorn_mites,gloom_wolf,asdf | hollow_serpent,blaze_tiger,dusk_moth | 53539138 |
| 504 | 2 | gloom_wolf,forge_golem,hollow_serpent | thorn_mites,moss_turtle,ember_hawk | 421547237 |
| 504 | 3 | gloom_wolf,moss_turtle,thorn_mites | forge_golem,grove_wisp,dusk_moth | 83694405 |
| 504 | 4 | thorn_mites,asdf,forge_golem | hollow_serpent,dusk_moth,ember_hawk | 829263182 |
Schedule SHA256=a85ba3f71782d39bf826807c8760f9f50bf9d54302e47b0b18f01959cd0c7d44

## Aggregate

Score=(wins+0.5×true draws)/(games−timeouts); timeouts separate. Rounds include timeout partial rounds; histograms allow exact weighted means. Defeat/damage/activation metrics cover BOTH teams; first-defeat turns count turn_started events through the first defeat, omitting games with none. Collision is collision HP damage (not collision events). Repeat=second/later activation of same actor+skill within one turn, including slotted movement, excluding Step; event fallback matches sim.gd, not distinct slot identity.

| Scenario | Class | Games | A W/L/D/timeout | Score | Mean rounds | <2/>5/max | Pre-first-turn defeats/games | Turns to first defeat (n) | Collision/total damage | Repeats/activations | Round histogram |
|---|---|---|---|---|---|---|---|---|---|---|---|
| mist_step | unilateral | 32 | 18/12/2/0 | 0.59 | 3.44 | 0/0/5 | 0/0 | 6.56 (32) | 280/847 | 69/768 (0.09) | 2:2, 3:15, 4:14, 5:1 |
| mist_control | unilateral | 32 | 17/15/0/0 | 0.53 | 3.41 | 0/0/5 | 0/0 | 6.66 (32) | 274/828 | 63/757 (0.08) | 2:3, 3:15, 4:12, 5:2 |
| split_mist | unilateral | 32 | 18/13/1/0 | 0.58 | 3.44 | 0/2/7 | 0/0 | 7.16 (32) | 316/820 | 38/760 (0.05) | 2:4, 3:16, 4:9, 5:1, 6:1, 7:1 |
| split_mist_control | unilateral | 32 | 17/14/1/0 | 0.55 | 3.34 | 0/1/6 | 0/0 | 7.19 (32) | 298/805 | 42/764 (0.05) | 2:5, 3:16, 4:7, 5:3, 6:1 |

## Start affordability and actual interventions

Both teams pooled, repeated per game. Affordability only: cost≤sheet AP, NOT target legality; no assumption that a low-stage kit should be fully affordable. Move/attack counts units with an affordable slotted MOVE/damaging STRIKE (not universal Step). Stat deltas: attempted/applied sum/changed count/cap-blocked count, per upgraded member. strike_ground: eligible damaging STRIKE attempts/applied/not_applied (existing ground); proposed content variant, not an approved slot choice. No rounding of exact counts.

| Scenario | Affordable/active slots | No affordable active/units | Has move/attack | Unaffordable ID:slot count | Stat delta attempted/sum/changed/blocked | strike_ground counts |
|---|---|---|---|---|---|---|
| mist_step | 768/768 | 0/192 | 174/150 | — | — | — |
| mist_control | 768/768 | 0/192 | 174/150 | — | — | — |
| split_mist | 768/768 | 0/192 | 174/150 | — | — | — |
| split_mist_control | 768/768 | 0/192 | 174/150 | — | — | — |

## Active skill usage

All equipped active IDs, not just top skills; activations/start slots pooled over both teams and games (not success rates).

| Scenario | ID:activations/start slots |
|---|---|
| mist_step | cinder_dive:2/20, snare:0/24, asdf:12/20, thornbed:63/72, set_gong:5/18, mist_step:109/88, new_skill:4/16, gale:62/48, asdf_3:28/20, bog:20/18, thorn_lash:6/24, asdf_2:25/10, plant_bamboo:21/24, fire_trail:11/6, shove:2/42, void_pull:85/60, quake_leap:12/10, strike_thrust:3/18, strike_jab:66/106, run:87/38, lava_field:21/16, glide:27/22, gloom_rift:80/24, coiling_rift:17/24 |
| mist_control | cinder_dive:2/20, snare:0/24, asdf:13/20, thornbed:79/72, set_gong:4/18, mist_step:111/88, new_skill:5/16, gale:63/48, asdf_3:28/20, bog:17/18, thorn_lash:8/24, asdf_2:27/10, plant_bamboo:20/24, fire_trail:10/6, shove:2/42, void_pull:84/60, quake_leap:12/10, strike_thrust:5/18, strike_jab:59/106, run:79/38, lava_field:20/16, glide:27/22, gloom_rift:64/24, coiling_rift:18/24 |
| split_mist | cinder_dive:0/20, snare:0/24, asdf:7/20, thornbed:67/72, set_gong:10/18, mist_step:102/88, new_skill:10/16, gale:72/48, asdf_3:29/20, bog:24/18, thorn_lash:8/24, asdf_2:20/10, plant_bamboo:12/24, fire_trail:7/6, shove:3/42, void_pull:102/60, quake_leap:15/10, strike_thrust:4/18, strike_jab:51/106, run:85/38, lava_field:22/16, glide:24/22, gloom_rift:60/24, coiling_rift:26/24 |
| split_mist_control | cinder_dive:0/20, snare:0/24, asdf:8/20, thornbed:67/72, set_gong:10/18, mist_step:98/88, new_skill:10/16, gale:79/48, asdf_3:27/20, bog:25/18, thorn_lash:6/24, asdf_2:17/10, plant_bamboo:16/24, fire_trail:7/6, shove:3/42, void_pull:99/60, quake_leap:15/10, strike_thrust:4/18, strike_jab:59/106, run:87/38, lava_field:23/16, glide:28/22, gloom_rift:57/24, coiling_rift:19/24 |

Limitations: small, bot- and roster-dependent teamwide interventions; paired draws are not independent per swap. Not human agency/fun/fairness validation, single-monster causal odds, equal-price comparisons, approved progression or balance/price evidence.

## Discovery diagnostics (both teams pooled)
No-own-turn = defeat after FIRST positive damage without a subsequent turn_started for that victim; prior turns do not count. Descriptive response-window metric, NOT an unfairness verdict. Candidate counts are activations/actual fielded slots, not successful effects. Round counts use event round_started. Map fingerprints cover pre-begin grounds/props, excluding units. Parent unilateral class label does not apply to map-only scenarios: maps affect both teams.
| Scenario | Eligible/unchanged units | Applied slots | Species old→new ledger | No-own-turn defeats/battles | Candidate uses/fielded slots | Candidate activations by round | Battles using candidate | Well/flank HP damage | Map SHA256s |
|---|---|---|---|---|---|---|---|---|---|
| mist_step | 88/104 | 88 | asdf asdf_2→mist_step:10, blaze_tiger fire_trail→mist_step:10, dusk_moth run→mist_step:12, ember_hawk glide→mist_step:4, gloom_wolf run→mist_step:18, hollow_serpent run→mist_step:10, moss_turtle run→mist_step:12, thorn_mites glide→mist_step:12 | 31/25 | mist_step:[109, 88] | mist_step/r1:51, mist_step/r2:33, mist_step/r3:20, mist_step/r4:5 | 32/32 | 226/22 | 1dadfcae8617d12bfab200dbaae0bdc88a5f6a779ab56469f601eedf46f0edac:true, 1f8706826281ca3d1306e1a5a44c2540cf334e1d0eed45339165654c271d45cb:true, 297d450aa8d17484ff95fea627cd35bea3f144847e55f6db17ead2ef4e25b18b:true, 390cdb5c2f65671232dc99d621a5fb6416cdd6a195d42199f91cc8fc66f5104f:true, 7225665215211341d8cb239247d47fb68197164f5565a7b123b39720aeafb0e9:true, 72768ad398542d0f2b55e9780bee8e2bb4c63c1c13ce2725dc5f9ba4379a7da7:true, 774c781d1a4541b76de2518b761f67d34839987f91c8ed33425f5b2bdc56b038:true, 7ce3d0196436868382983272a4f465fd20c55ce7298df9b97294943ec2db737e:true, 83272b53bafa517b64275b0de780e57d42a594e7399909f65e5338c273503541:true, 839f09ec8735be48f6df3d635df527f57b3f7028c88c4d9e62626d01f297026f:true, 895b408d0bf0b3d7483f0a574fcf79a80a8a7acb6f65c7e5cc9cee896a10a891:true, 9a161cee72c97978dff557e47ccfe61a2884a6b47c270d3eae80e67a03198f5c:true, c888401816af608500a32bcc47b9baa17f3defc0f6940a1022b3dd3102a84410:true, ed3a312b3b70b0ab6f5309f698e76cc8c03073bc4acd028feababdd37a2f8ce6:true, ed95f62a0ccbca30e0ac4476b8c68101b4370c92cd8cd8d5f0dbf5c6cc3b2268:true |
| mist_control | 88/104 | 88 | asdf asdf_2→mist_step [no trail]:10, blaze_tiger fire_trail→mist_step [no trail]:10, dusk_moth run→mist_step [no trail]:12, ember_hawk glide→mist_step [no trail]:4, gloom_wolf run→mist_step [no trail]:18, hollow_serpent run→mist_step [no trail]:10, moss_turtle run→mist_step [no trail]:12, thorn_mites glide→mist_step [no trail]:12 | 33/25 | mist_step:[111, 88] | mist_step/r1:51, mist_step/r2:32, mist_step/r3:21, mist_step/r4:6, mist_step/r5:1 | 32/32 | 216/24 | 1dadfcae8617d12bfab200dbaae0bdc88a5f6a779ab56469f601eedf46f0edac:true, 1f8706826281ca3d1306e1a5a44c2540cf334e1d0eed45339165654c271d45cb:true, 297d450aa8d17484ff95fea627cd35bea3f144847e55f6db17ead2ef4e25b18b:true, 390cdb5c2f65671232dc99d621a5fb6416cdd6a195d42199f91cc8fc66f5104f:true, 7225665215211341d8cb239247d47fb68197164f5565a7b123b39720aeafb0e9:true, 72768ad398542d0f2b55e9780bee8e2bb4c63c1c13ce2725dc5f9ba4379a7da7:true, 774c781d1a4541b76de2518b761f67d34839987f91c8ed33425f5b2bdc56b038:true, 7ce3d0196436868382983272a4f465fd20c55ce7298df9b97294943ec2db737e:true, 83272b53bafa517b64275b0de780e57d42a594e7399909f65e5338c273503541:true, 839f09ec8735be48f6df3d635df527f57b3f7028c88c4d9e62626d01f297026f:true, 895b408d0bf0b3d7483f0a574fcf79a80a8a7acb6f65c7e5cc9cee896a10a891:true, 9a161cee72c97978dff557e47ccfe61a2884a6b47c270d3eae80e67a03198f5c:true, c888401816af608500a32bcc47b9baa17f3defc0f6940a1022b3dd3102a84410:true, ed3a312b3b70b0ab6f5309f698e76cc8c03073bc4acd028feababdd37a2f8ce6:true, ed95f62a0ccbca30e0ac4476b8c68101b4370c92cd8cd8d5f0dbf5c6cc3b2268:true |
| split_mist | 88/104 | 88 | asdf asdf_2→mist_step:10, blaze_tiger fire_trail→mist_step:10, dusk_moth run→mist_step:12, ember_hawk glide→mist_step:4, gloom_wolf run→mist_step:18, hollow_serpent run→mist_step:10, moss_turtle run→mist_step:12, thorn_mites glide→mist_step:12 | 41/24 | mist_step:[102, 88] | mist_step/r1:43, mist_step/r2:30, mist_step/r3:17, mist_step/r4:10, mist_step/r5:2 | 32/32 | 172/20 | c0734b6bfde173096c39f516765f3cd49642ca9a88df67b606e4400fad225090:true, d932bd623d54f91d82768737de70c0f3dda6acff94cd0a0ad1486b44bc343ac7:true |
| split_mist_control | 88/104 | 88 | asdf asdf_2→mist_step [no trail]:10, blaze_tiger fire_trail→mist_step [no trail]:10, dusk_moth run→mist_step [no trail]:12, ember_hawk glide→mist_step [no trail]:4, gloom_wolf run→mist_step [no trail]:18, hollow_serpent run→mist_step [no trail]:10, moss_turtle run→mist_step [no trail]:12, thorn_mites glide→mist_step [no trail]:12 | 35/24 | mist_step:[98, 88] | mist_step/r1:44, mist_step/r2:30, mist_step/r3:19, mist_step/r4:4, mist_step/r5:1 | 32/32 | 169/17 | c0734b6bfde173096c39f516765f3cd49642ca9a88df67b606e4400fad225090:true, d932bd623d54f91d82768737de70c0f3dda6acff94cd0a0ad1486b44bc343ac7:true |
DISCOVERY_MEASUREMENT_COMPLETED: final guard matches startup content=a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2 resources=cloudstep_token:97a751e9ce198fb1a6a41fae7b99428ea2e13abfafba861a20852d2867161e1e, mist_step:652b415efe17683a0e2e9f509e28a57ca27e3cf260ea1ad45fa1da9189af51eb, raise_reed_screen:9211eea71bc9671524d8541ffdbed88b28256aa73bbb94bfbb235e90021f1f84, receding_blow:b5daf6cb86c6da57a45d4800912150d6ecc35ee6d09b703f71db8c52858c50b1, reed_screen:a6f4b626ff57693209e07c1e3be292af26596920cfba07d892e42bb4c3adaba0
```

#### discovery_cloudtactic.txt

```text
# Authored discovery experiment
AP/TPR/HP/Init/Movement/Reach are authored, full HP, no entry proxy. current-ap=2 is an explicit bilateral ZONE PUSH/PULL candidate (including Bog), NOT normal defaults. All skills use duplicate_deep ALL. Subject A is scored after both side swaps. No prices/budgets asserted.
Harness own SHA256=94970f7a44f98bde96bf7ecd635a6b1d386367fa16f3f586c76dbabecaba94d6; parent SHA256=b40a5b2079d1012659f90c2a159c1a911dcbe4e3efc4b6c015b73858215fd38c; content=a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2; new resource hashes=cloudstep_token:97a751e9ce198fb1a6a41fae7b99428ea2e13abfafba861a20852d2867161e1e, mist_step:652b415efe17683a0e2e9f509e28a57ca27e3cf260ea1ad45fa1da9189af51eb, raise_reed_screen:9211eea71bc9671524d8541ffdbed88b28256aa73bbb94bfbb235e90021f1f84, receding_blow:b5daf6cb86c6da57a45d4800912150d6ecc35ee6d09b703f71db8c52858c50b1, reed_screen:a6f4b626ff57693209e07c1e3be292af26596920cfba07d892e42bb4c3adaba0; Godot=4.7.2-stable (official)
Maps: base uses canonical RUNNER seeded board. open removes every preplaced prop without aftermath, retains grounds/veins. screens replaces props with exactly two point-mirrored reed_screen pairs. split first relocates veins (1,3),(3,3),(5,3) -> (1,2),(3,3),(5,4), then uses the same screen generator. split_mist/cloud also replace subject movement. Props block movement only; NO ranged cover. No starter grass is added. Map RNG is local, seeded with setup seed; play/setup RNG is untouched by edits.
Eligibility: first MOVE for mist/cloud; first positive-damage Jab with no board ops for receding, preserving kin_effect. Winged already retreats: retreat flag does not stack. Screen: first pure CREATE_PROP placement, else first GROUND, else last slot; no extra slots. Only subject changes except both_*. Both teams receive map edits. Schedule: same draw-A/draw-B-excluding-A/setup-seed progression scheme; fresh setup RNG each scenario/swap, divergent play may consume different RNG draws.
Ablation metadata: mist_control [no trail] / split_mist_control [no trail] replace the same first subject MOVE with a local deep copy of mist_step, clearing ONLY board_ops. Same 2 AP walk/profile; no trail or zone effect. split_mist_control uses identical split geometry. Candidate ID remains mist_step: usage/fielded-slot and round counts in these scenarios count the no-trail CONTROL, not zone-producing Mist Step.

| Seed | Pair | Subject A | Opponent B | Setup seed |
|---|---|---|---|---|
| 501 | 1 | ember_hawk,thorn_mites,blaze_tiger | hollow_serpent,dusk_moth,grove_wisp | 570115152 |
| 503 | 1 | moss_turtle,blaze_tiger,hollow_serpent | grove_wisp,ember_hawk,gloom_wolf | 774216799 |
Schedule SHA256=0c465629bff4815471e32181b99c49d7ceea394e75632501cd3876c4122b9450

## Aggregate

Score=(wins+0.5×true draws)/(games−timeouts); timeouts separate. Rounds include timeout partial rounds; histograms allow exact weighted means. Defeat/damage/activation metrics cover BOTH teams; first-defeat turns count turn_started events through the first defeat, omitting games with none. Collision is collision HP damage (not collision events). Repeat=second/later activation of same actor+skill within one turn, including slotted movement, excluding Step; event fallback matches sim.gd, not distinct slot identity.

| Scenario | Class | Games | A W/L/D/timeout | Score | Mean rounds | <2/>5/max | Pre-first-turn defeats/games | Turns to first defeat (n) | Collision/total damage | Repeats/activations | Round histogram |
|---|---|---|---|---|---|---|---|---|---|---|---|
| cloudstep_token | unilateral | 4 | 3/1/0/0 | 0.75 | 2.75 | 0/0/4 | 0/0 | 5.25 (4) | 35/84 | 16/81 (0.20) | 2:2, 3:1, 4:1 |

## Start affordability and actual interventions

Both teams pooled, repeated per game. Affordability only: cost≤sheet AP, NOT target legality; no assumption that a low-stage kit should be fully affordable. Move/attack counts units with an affordable slotted MOVE/damaging STRIKE (not universal Step). Stat deltas: attempted/applied sum/changed count/cap-blocked count, per upgraded member. strike_ground: eligible damaging STRIKE attempts/applied/not_applied (existing ground); proposed content variant, not an approved slot choice. No rounding of exact counts.

| Scenario | Affordable/active slots | No affordable active/units | Has move/attack | Unaffordable ID:slot count | Stat delta attempted/sum/changed/blocked | strike_ground counts |
|---|---|---|---|---|---|---|
| cloudstep_token | 96/96 | 0/24 | 24/20 | — | — | — |

## Active skill usage

All equipped active IDs, not just top skills; activations/start slots pooled over both teams and games (not success rates).

| Scenario | ID:activations/start slots |
|---|---|
| cloudstep_token | cloudstep_token:11/12, cinder_dive:0/4, snare:0/2, thornbed:14/10, new_skill:0/4, gale:7/8, bog:3/2, thorn_lash:1/2, plant_bamboo:1/2, shove:0/4, void_pull:4/6, quake_leap:4/4, strike_jab:9/18, run:15/6, lava_field:5/4, glide:2/2, gloom_rift:5/2, coiling_rift:0/4 |

Limitations: small, bot- and roster-dependent teamwide interventions; paired draws are not independent per swap. Not human agency/fun/fairness validation, single-monster causal odds, equal-price comparisons, approved progression or balance/price evidence.

## Discovery diagnostics (both teams pooled)
No-own-turn = defeat after FIRST positive damage without a subsequent turn_started for that victim; prior turns do not count. Descriptive response-window metric, NOT an unfairness verdict. Candidate counts are activations/actual fielded slots, not successful effects. Round counts use event round_started. Map fingerprints cover pre-begin grounds/props, excluding units. Parent unilateral class label does not apply to map-only scenarios: maps affect both teams.
| Scenario | Eligible/unchanged units | Applied slots | Species old→new ledger | No-own-turn defeats/battles | Candidate uses/fielded slots | Candidate activations by round | Battles using candidate | Well/flank HP damage | Map SHA256s |
|---|---|---|---|---|---|---|---|---|---|
| cloudstep_token | 12/12 | 12 | blaze_tiger fire_trail→cloudstep_token:4, ember_hawk glide→cloudstep_token:2, hollow_serpent run→cloudstep_token:2, moss_turtle run→cloudstep_token:2, thorn_mites glide→cloudstep_token:2 | 5/3 | cloudstep_token:[11, 12] | cloudstep_token/r1:8, cloudstep_token/r2:3 | 4/4 | 22/3 | 390cdb5c2f65671232dc99d621a5fb6416cdd6a195d42199f91cc8fc66f5104f:true, 774c781d1a4541b76de2518b761f67d34839987f91c8ed33425f5b2bdc56b038:true |
DISCOVERY_MEASUREMENT_COMPLETED: final guard matches startup content=a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2 resources=cloudstep_token:97a751e9ce198fb1a6a41fae7b99428ea2e13abfafba861a20852d2867161e1e, mist_step:652b415efe17683a0e2e9f509e28a57ca27e3cf260ea1ad45fa1da9189af51eb, raise_reed_screen:9211eea71bc9671524d8541ffdbed88b28256aa73bbb94bfbb235e90021f1f84, receding_blow:b5daf6cb86c6da57a45d4800912150d6ecc35ee6d09b703f71db8c52858c50b1, reed_screen:a6f4b626ff57693209e07c1e3be292af26596920cfba07d892e42bb4c3adaba0
```


## S022 · 2026-11-13 · side-swapped entry proxy and upgrade interventions

**State:** main, base `2828adf` dirty, final session changes uncommitted; source content `a30a9be42850` (`2026-11-13.1`), including user content `asdf`, untouched. New `godot/tools/progression.gd` is an in-memory, side-swapped upgrade harness; no resource/core changes. The SHA-256 in each output identifies the current harness only, not the full engine/source state. Godot 4.7.2; one Idle process, affinity `0xC` (two of 32 logical CPUs), sequential; no active measurement processes remain (session execution report).

**Authorization and scope:** the latest user “passt tu es” approves executing the progression test plan, not adopting prices or rules. The goal is a working start plus alternative upgrade paths; the owning Battle/Monsters/Skills GDD documentation is handled by the other agent. Calculator prices are not frozen; stat and skill ledgers stay separate, with joint action-threshold validation. This entry does not approve a start, frame, budget or stage.

**Counted runs:** **588 = 224 + 224 + 128 + 12 battles**, four POST-FIX blocks only. Greedy: eight canonical draws (seeds 401/402 × four pairs), two side placements each, 16 games per scenario; tactic: two draws from that schedule, four games per scenario. These are paired comparisons, NOT independent observations per swap/scenario. Fresh setup RNG is reset per scenario/swap; divergent play can consume different random draws.

**Proxy and interventions:** entry AP 2 / TPR 1, keeping authored HP, Initiative, Movement, Reach and kits. `current-ap` changes the current in-game ZONE PUSH/PULL family on both sides, including additional Slow effects such as Bog, just as S021; not every skill. Unilateral +1 stats affect EACH of the three subject-A members, capped, not one monster or equal-cost allocations. Movement is cap-blocked in 18/48 attempts, Reach in 4/48; other listed single-stat increments apply in 48/48. AP 3 also unlocks authored cost-3 skills: affordability effects must be split from action-budget effects; source budget fit was not checked. Ground variants append Thornbed only to damaging STRIKE slots without an existing ground BoardOp, keeping AP, damage cap and other fields unchanged; proposed content variant, not an approved slot upgrade. Lower AP is NOT an upgrade option (Skills §6). `both_*` changes all six monsters: use rounds to inspect escalation, not its A score as upgrade value.

**Execution qualification:** a six-battle pilot and 448 initial pre-guard diagnostic battles are excluded. Self-test exposed that Godot `duplicate(true)` did not clone external zones; fixed with `duplicate_deep` in ALL mode, without mutating resource files. The recorded self-test is **1179 passed, 0 failed**, no battles played. All four measurements were rerun post-fix: numeric tables unchanged, usage-ID print order differs; each completion sentinel confirms the source content fingerprint unchanged. Only the four post-fix outputs below are retained here, not a mass diagnostic history.

### Exact observations and limits

- AP-2 current-family greedy entry mean **3.75** rounds (16 games). All units have at least one affordable active, but authored cost-3 `new_skill`, `asdf`, `strike_thrust` are unaffordable at proxy AP 2 (28/384 active-slot instances). This does NOT establish a viable entry kit or complete starter affordability.
- Bilateral greedy means: AP only **2.75**, TPR only **2.75**, AP+TPR **2.25**, HP+AP **3.1875**, HP+TPR **2.625**, HP+AP+TPR **2.5625**. HP only **4.25** still has three >5-round outliers, maximum **7**; unilateral HP also **4.25**, three >5, maximum **6**. More HP is not an automatic solution or approved price change.
- Unilateral ground has the same outcomes and rounds as control, not proof of no value. Bilateral ground **3.625** is near control **3.75**. Context, bot usage and alternative upgrades remain to test.
- Tactic subset: base **5.0**, including one six-round battle; bilateral AP+TPR **3.25**, HP+AP+TPR **3.5**, only **n=4 each**. This exposes bot/sample limits; the greedy **2.25** is not a general battle-length claim.
- AP-2 current-family unilateral team scores: baseline **7W/8L/1D = 46.875%**, HP **59.375%**, Initiative **37.5%**, Movement/Reach **56.25%** each, AP **50%**, TPR **62.5%**, HP+AP/HP+TPR **75%** each. These are small paired teamwide samples, not equal-price comparisons, precise stat values or single-monster odds.

**Follow-up:** T02/T03/T05/T13 remain open. Next stage: starter-kit affordability, alternative upgrade paths and whether growth preserves the 3–5-round goal with stronger bots and human play; inspect outliers, response windows and meaningful decisions. No automatic HP/AP/TPR prices or rule changes; not all goals met. Main agent validates transcription and cleans temporary logs after confirming preservation; this documentation-only edit does not remove other files.

### Full post-fix outputs

#### progression_cost1.txt

```text

# Progression intervention experiment

Command: `godot --headless --path godot -s res://tools/progression.gd -- --seeds 401,402 --pairs 4 --bot greedy --current-ap 1 --scenarios base,hp,initiative,movement,reach,ap,tpr,strike_ground,hp_ap,hp_tpr,ap_tpr,ap_tpr_ground,both_ap_tpr,both_ap_tpr_ground`

Harness SHA-256 (current progression.gd only; not a full engine/source fingerprint): `b40a5b2079d1012659f90c2a159c1a911dcbe4e3efc4b6c015b73858215fd38c`; content `a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2`; Godot `4.7.2-stable (official)`.

**Entry action-economy proxy, not approved starting monster/frame/budget/stage.** Every fresh reference sheet: AP=2, TPR=1, authored HP/Initiative/Movement/Reach/kit, full HP. GameData's in-game pool includes user content (including asdf if in-game); no curated exclusions. Prices remain working values; no stat-price or budget assertions.
Uniform teamwide interventions, not single-monster odds or equal-cost allocations. Unilateral scenarios upgrade all three subject A members; both_* upgrades all six and is bilateral escalation, NOT unilateral value. Stat increments +1 capped at HP/Init 10, Movement/AP 5, Reach 4, TPR 3; never lower an already over-cap authored value. strike_ground: proposed content variant, NOT an approved slot choice; append existing Thornbed only to damaging STRIKE slots with NO ground BoardOp, preserving existing ground, AP, damage, shape and all other fields. current-ap matches sim.gd currentap: any in-game ZONE with PUSH or PULL, including mixed-effect zones such as Bog, on both teams using local deep copies.

3v3 seeded boards, mirrored placement, two full-team side swaps per seed/pair, same bot both sides. Each seed owns a draw RNG: draw A, then B excluding A, then setup seed; reset a fresh run RNG to that setup seed for EVERY scenario/swap. Play RNG continues after identical setup draws; divergent actions need not consume identical random draws. Guard: 600 bot turns.

## Source roster (authored stats; before proxy)

| ID | HP/Init/Move/Reach/AP/TPR | Kit ID:effective cost |
|---|---|---|
| blaze_tiger | 5/7.0/5/2/3/1 | new_skill:3, strike_jab:2, fire_trail:2, lava_field:1 |
| ember_hawk | 3/9.0/5/3/2/2 | glide:2, strike_jab:2, cinder_dive:1, gale:1 |
| forge_golem | 8/1.0/1/3/3/1 | strike_jab:2, strike_thrust:3, set_gong:1, gale:1 |
| asdf | 5/5.0/3/3/3/1 | asdf:3, asdf_2:1, asdf_3:1, thornbed:1 |
| grove_wisp | 3/9.0/5/3/3/1 | quake_leap:2, strike_jab:2, gale:1, thornbed:1 |
| moss_turtle | 7/3.0/2/3/3/1 | run:1, bog:1, void_pull:1, shove:2 |
| thorn_mites | 6/3.0/3/3/2/2 | glide:2, strike_jab:2, thornbed:1, void_pull:1 |
| dusk_moth | 3/7.0/3/4/3/1 | run:1, gloom_rift:1, void_pull:1, snare:2 |
| gloom_wolf | 4/9.0/3/3/3/1 | run:1, thorn_lash:2, shove:2, plant_bamboo:1 |
| hollow_serpent | 6/5.0/2/3/3/1 | run:1, strike_jab:2, coiling_rift:2, thornbed:1 |

## Canonical draw schedule

| Seed | Pair | Subject A | Opponent B | Setup seed |
|---|---|---|---|---|
| 401 | 1 | hollow_serpent,gloom_wolf,grove_wisp | blaze_tiger,thorn_mites,forge_golem | 526642205 |
| 401 | 2 | ember_hawk,gloom_wolf,blaze_tiger | grove_wisp,dusk_moth,asdf | 847685958 |
| 401 | 3 | hollow_serpent,ember_hawk,gloom_wolf | dusk_moth,asdf,moss_turtle | 65110119 |
| 401 | 4 | ember_hawk,asdf,thorn_mites | moss_turtle,gloom_wolf,hollow_serpent | 877779835 |
| 402 | 1 | asdf,blaze_tiger,thorn_mites | dusk_moth,gloom_wolf,moss_turtle | 754957460 |
| 402 | 2 | asdf,blaze_tiger,hollow_serpent | ember_hawk,dusk_moth,grove_wisp | 366673621 |
| 402 | 3 | gloom_wolf,dusk_moth,moss_turtle | forge_golem,ember_hawk,hollow_serpent | 533397458 |
| 402 | 4 | blaze_tiger,grove_wisp,dusk_moth | asdf,forge_golem,hollow_serpent | 560403399 |

## Aggregate

Score=(wins+0.5×true draws)/(games−timeouts); timeouts separate. Rounds include timeout partial rounds; histograms allow exact weighted means. Defeat/damage/activation metrics cover BOTH teams; first-defeat turns count turn_started events through the first defeat, omitting games with none. Collision is collision HP damage (not collision events). Repeat=second/later activation of same actor+skill within one turn, including slotted movement, excluding Step; event fallback matches sim.gd, not distinct slot identity.

| Scenario | Class | Games | A W/L/D/timeout | Score | Mean rounds | <2/>5/max | Pre-first-turn defeats/games | Turns to first defeat (n) | Collision/total damage | Repeats/activations | Round histogram |
|---|---|---|---|---|---|---|---|---|---|---|---|
| base | control | 16 | 6/10/0/0 | 0.38 | 2.69 | 0/0/4 | 0/0 | 5.38 (16) | 224/369 | 63/309 (0.20) | 2:7, 3:7, 4:2 |
| hp | unilateral | 16 | 6/10/0/0 | 0.38 | 3.00 | 0/0/4 | 0/0 | 5.88 (16) | 234/413 | 70/331 (0.21) | 2:5, 3:6, 4:5 |
| initiative | unilateral | 16 | 6/9/1/0 | 0.41 | 3.00 | 1/0/5 | 0/0 | 5.25 (16) | 205/381 | 79/333 (0.24) | 1:1, 2:4, 3:8, 5:3 |
| movement | unilateral | 16 | 8/8/0/0 | 0.50 | 2.69 | 0/0/4 | 0/0 | 5.50 (16) | 209/372 | 70/297 (0.24) | 2:8, 3:5, 4:3 |
| reach | unilateral | 16 | 6/9/1/0 | 0.41 | 2.81 | 0/0/4 | 0/0 | 5.75 (16) | 229/383 | 75/326 (0.23) | 2:7, 3:5, 4:4 |
| ap | unilateral | 16 | 8/8/0/0 | 0.50 | 2.88 | 0/0/4 | 0/0 | 4.75 (16) | 235/402 | 87/368 (0.24) | 2:5, 3:8, 4:3 |
| tpr | unilateral | 16 | 7/9/0/0 | 0.44 | 2.31 | 0/0/3 | 0/0 | 5.38 (16) | 205/357 | 73/333 (0.22) | 2:11, 3:5 |
| strike_ground | unilateral | 16 | 6/10/0/0 | 0.38 | 2.69 | 0/0/4 | 0/0 | 5.38 (16) | 219/368 | 61/313 (0.19) | 2:7, 3:7, 4:2 |
| hp_ap | unilateral | 16 | 10/6/0/0 | 0.63 | 2.94 | 0/0/5 | 0/0 | 5.13 (16) | 243/425 | 87/376 (0.23) | 2:6, 3:6, 4:3, 5:1 |
| hp_tpr | unilateral | 16 | 10/6/0/0 | 0.63 | 2.88 | 0/0/5 | 0/0 | 5.88 (16) | 243/419 | 88/389 (0.23) | 2:8, 3:4, 4:2, 5:2 |
| ap_tpr | unilateral | 16 | 11/4/1/0 | 0.72 | 2.50 | 0/0/4 | 0/0 | 4.75 (16) | 222/399 | 86/381 (0.23) | 2:10, 3:4, 4:2 |
| ap_tpr_ground | unilateral | 16 | 9/6/1/0 | 0.59 | 2.31 | 0/0/4 | 0/0 | 4.63 (16) | 227/401 | 80/374 (0.21) | 2:12, 3:3, 4:1 |
| both_ap_tpr | bilateral | 16 | 4/12/0/0 | 0.25 | 2.13 | 1/0/4 | 2/2 | 4.06 (16) | 238/396 | 107/422 (0.25) | 1:1, 2:13, 3:1, 4:1 |
| both_ap_tpr_ground | bilateral | 16 | 3/13/0/0 | 0.19 | 2.06 | 1/0/3 | 2/2 | 3.81 (16) | 228/395 | 96/410 (0.23) | 1:1, 2:13, 3:2 |

## Start affordability and actual interventions

Both teams pooled, repeated per game. Affordability only: cost≤sheet AP, NOT target legality; no assumption that a low-stage kit should be fully affordable. Move/attack counts units with an affordable slotted MOVE/damaging STRIKE (not universal Step). Stat deltas: attempted/applied sum/changed count/cap-blocked count, per upgraded member. strike_ground: eligible damaging STRIKE attempts/applied/not_applied (existing ground); proposed content variant, not an approved slot choice. No rounding of exact counts.

| Scenario | Affordable/active slots | No affordable active/units | Has move/attack | Unaffordable ID:slot count | Stat delta attempted/sum/changed/blocked | strike_ground counts |
|---|---|---|---|---|---|---|
| base | 356/384 | 0/96 | 90/64 | asdf:12, new_skill:10, strike_thrust:6 | — | — |
| hp | 356/384 | 0/96 | 90/64 | asdf:12, new_skill:10, strike_thrust:6 | hp:[48, 48.0, 48, 0] | — |
| initiative | 356/384 | 0/96 | 90/64 | asdf:12, new_skill:10, strike_thrust:6 | initiative:[48, 48.0, 48, 0] | — |
| movement | 356/384 | 0/96 | 90/64 | asdf:12, new_skill:10, strike_thrust:6 | movement:[48, 30.0, 30, 18] | — |
| reach | 356/384 | 0/96 | 90/64 | asdf:12, new_skill:10, strike_thrust:6 | reach:[48, 44.0, 44, 4] | — |
| ap | 370/384 | 0/96 | 90/70 | asdf:6, new_skill:2, strike_thrust:6 | ap:[48, 48.0, 48, 0] | — |
| tpr | 356/384 | 0/96 | 90/64 | asdf:12, new_skill:10, strike_thrust:6 | tpr:[48, 48.0, 48, 0] | — |
| strike_ground | 356/384 | 0/96 | 90/64 | asdf:12, new_skill:10, strike_thrust:6 | — | applied:42, attempted:50, not_applied:8 |
| hp_ap | 370/384 | 0/96 | 90/70 | asdf:6, new_skill:2, strike_thrust:6 | ap:[48, 48.0, 48, 0], hp:[48, 48.0, 48, 0] | — |
| hp_tpr | 356/384 | 0/96 | 90/64 | asdf:12, new_skill:10, strike_thrust:6 | hp:[48, 48.0, 48, 0], tpr:[48, 48.0, 48, 0] | — |
| ap_tpr | 370/384 | 0/96 | 90/70 | asdf:6, new_skill:2, strike_thrust:6 | ap:[48, 48.0, 48, 0], tpr:[48, 48.0, 48, 0] | — |
| ap_tpr_ground | 370/384 | 0/96 | 90/70 | asdf:6, new_skill:2, strike_thrust:6 | ap:[48, 48.0, 48, 0], tpr:[48, 48.0, 48, 0] | applied:42, attempted:50, not_applied:8 |
| both_ap_tpr | 384/384 | 0/96 | 90/76 | — | ap:[96, 96.0, 96, 0], tpr:[96, 96.0, 96, 0] | — |
| both_ap_tpr_ground | 384/384 | 0/96 | 90/76 | — | ap:[96, 96.0, 96, 0], tpr:[96, 96.0, 96, 0] | applied:80, attempted:92, not_applied:12 |

## Active skill usage

All equipped active IDs, not just top skills; activations/start slots pooled over both teams and games (not success rates).

| Scenario | ID:activations/start slots |
|---|---|
| base | void_pull:39/26, cinder_dive:0/10, snare:0/12, asdf:0/12, asdf_3:32/12, strike_jab:25/52, new_skill:0/10, thornbed:11/38, run:70/44, plant_bamboo:7/12, gale:31/24, bog:10/8, quake_leap:8/8, set_gong:0/6, thorn_lash:2/12, strike_thrust:0/6, fire_trail:16/10, shove:2/20, lava_field:3/10, glide:16/16, gloom_rift:11/12, coiling_rift:6/12, asdf_2:20/12 |
| hp | void_pull:41/26, cinder_dive:0/10, snare:0/12, asdf:0/12, asdf_3:32/12, strike_jab:27/52, new_skill:0/10, thornbed:9/38, run:76/44, plant_bamboo:6/12, gale:39/24, bog:11/8, quake_leap:8/8, set_gong:0/6, thorn_lash:5/12, strike_thrust:0/6, fire_trail:19/10, shove:2/20, lava_field:0/10, glide:18/16, gloom_rift:9/12, coiling_rift:11/12, asdf_2:18/12 |
| initiative | void_pull:44/26, cinder_dive:0/10, snare:0/12, asdf:0/12, asdf_3:29/12, strike_jab:27/52, new_skill:0/10, thornbed:14/38, run:76/44, plant_bamboo:2/12, gale:33/24, bog:14/8, quake_leap:8/8, set_gong:0/6, thorn_lash:0/12, strike_thrust:0/6, fire_trail:14/10, shove:3/20, lava_field:4/10, glide:15/16, gloom_rift:19/12, coiling_rift:7/12, asdf_2:24/12 |
| movement | void_pull:48/26, cinder_dive:0/10, snare:0/12, asdf:0/12, asdf_3:15/12, strike_jab:18/52, new_skill:0/10, thornbed:6/38, run:75/44, plant_bamboo:5/12, gale:28/24, bog:14/8, quake_leap:8/8, set_gong:0/6, thorn_lash:10/12, strike_thrust:0/6, fire_trail:13/10, shove:0/20, lava_field:6/10, glide:17/16, gloom_rift:5/12, coiling_rift:4/12, asdf_2:25/12 |
| reach | void_pull:42/26, cinder_dive:0/10, snare:0/12, asdf:0/12, asdf_3:34/12, strike_jab:22/52, new_skill:0/10, thornbed:15/38, run:72/44, plant_bamboo:6/12, gale:36/24, bog:16/8, quake_leap:8/8, set_gong:0/6, thorn_lash:3/12, strike_thrust:0/6, fire_trail:15/10, shove:2/20, lava_field:3/10, glide:15/16, gloom_rift:11/12, coiling_rift:8/12, asdf_2:18/12 |
| ap | void_pull:46/26, cinder_dive:0/10, snare:0/12, asdf:1/12, asdf_3:33/12, strike_jab:12/52, new_skill:3/10, thornbed:12/38, run:82/44, plant_bamboo:10/12, gale:37/24, bog:18/8, quake_leap:8/8, set_gong:0/6, thorn_lash:9/12, strike_thrust:0/6, fire_trail:18/10, shove:3/20, lava_field:16/10, glide:18/16, gloom_rift:15/12, coiling_rift:8/12, asdf_2:19/12 |
| tpr | void_pull:40/26, cinder_dive:0/10, snare:0/12, asdf:0/12, asdf_3:28/12, strike_jab:22/52, new_skill:0/10, thornbed:20/38, run:71/44, plant_bamboo:8/12, gale:36/24, bog:9/8, quake_leap:8/8, set_gong:0/6, thorn_lash:9/12, strike_thrust:0/6, fire_trail:17/10, shove:2/20, lava_field:4/10, glide:15/16, gloom_rift:16/12, coiling_rift:6/12, asdf_2:22/12 |
| strike_ground | void_pull:39/26, cinder_dive:0/10, snare:0/12, asdf:0/12, asdf_3:32/12, strike_jab:25/52, new_skill:0/10, thornbed:11/38, run:70/44, plant_bamboo:7/12, gale:31/24, bog:10/8, quake_leap:8/8, set_gong:2/6, thorn_lash:2/12, strike_thrust:0/6, fire_trail:16/10, shove:2/20, lava_field:3/10, glide:18/16, gloom_rift:11/12, coiling_rift:6/12, asdf_2:20/12 |
| hp_ap | void_pull:50/26, cinder_dive:1/10, snare:0/12, asdf:0/12, asdf_3:35/12, strike_jab:15/52, new_skill:3/10, thornbed:9/38, run:82/44, plant_bamboo:10/12, gale:39/24, bog:16/8, quake_leap:8/8, set_gong:0/6, thorn_lash:10/12, strike_thrust:0/6, fire_trail:15/10, shove:4/20, lava_field:16/10, glide:19/16, gloom_rift:15/12, coiling_rift:7/12, asdf_2:22/12 |
| hp_tpr | void_pull:49/26, cinder_dive:0/10, snare:0/12, asdf:0/12, asdf_3:30/12, strike_jab:31/52, new_skill:0/10, thornbed:18/38, run:85/44, plant_bamboo:12/12, gale:42/24, bog:17/8, quake_leap:8/8, set_gong:0/6, thorn_lash:6/12, strike_thrust:0/6, fire_trail:24/10, shove:4/20, lava_field:5/10, glide:17/16, gloom_rift:15/12, coiling_rift:10/12, asdf_2:16/12 |
| ap_tpr | void_pull:48/26, cinder_dive:1/10, snare:0/12, asdf:0/12, asdf_3:37/12, strike_jab:21/52, new_skill:3/10, thornbed:17/38, run:87/44, plant_bamboo:11/12, gale:25/24, bog:13/8, quake_leap:8/8, set_gong:0/6, thorn_lash:10/12, strike_thrust:0/6, fire_trail:18/10, shove:6/20, lava_field:19/10, glide:20/16, gloom_rift:14/12, coiling_rift:7/12, asdf_2:16/12 |
| ap_tpr_ground | void_pull:52/26, cinder_dive:1/10, snare:0/12, asdf:0/12, asdf_3:40/12, strike_jab:20/52, new_skill:3/10, thornbed:14/38, run:83/44, plant_bamboo:11/12, gale:21/24, bog:13/8, quake_leap:8/8, set_gong:0/6, thorn_lash:9/12, strike_thrust:0/6, fire_trail:19/10, shove:6/20, lava_field:20/10, glide:20/16, gloom_rift:12/12, coiling_rift:6/12, asdf_2:16/12 |
| both_ap_tpr | void_pull:42/26, cinder_dive:0/10, snare:0/12, asdf:6/12, asdf_3:31/12, strike_jab:19/52, new_skill:2/10, thornbed:15/38, run:91/44, plant_bamboo:13/12, gale:59/24, bog:23/8, quake_leap:8/8, set_gong:0/6, thorn_lash:9/12, strike_thrust:1/6, fire_trail:12/10, shove:5/20, lava_field:8/10, glide:20/16, gloom_rift:29/12, coiling_rift:9/12, asdf_2:20/12 |
| both_ap_tpr_ground | void_pull:48/26, cinder_dive:0/10, snare:1/12, asdf:4/12, asdf_3:31/12, strike_jab:18/52, new_skill:2/10, thornbed:18/38, run:83/44, plant_bamboo:13/12, gale:53/24, bog:21/8, quake_leap:8/8, set_gong:0/6, thorn_lash:9/12, strike_thrust:0/6, fire_trail:12/10, shove:4/20, lava_field:9/10, glide:21/16, gloom_rift:23/12, coiling_rift:9/12, asdf_2:23/12 |

Limitations: small, bot- and roster-dependent teamwide interventions; paired draws are not independent per swap. Not human agency/fun/fairness validation, single-monster causal odds, equal-price comparisons, approved progression or balance/price evidence.

PROGRESSION_MEASUREMENT_COMPLETED: final content fingerprint `a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2` matches startup `a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2`.

```

#### progression_cost2.txt

```text

# Progression intervention experiment

Command: `godot --headless --path godot -s res://tools/progression.gd -- --seeds 401,402 --pairs 4 --bot greedy --current-ap 2 --scenarios base,hp,initiative,movement,reach,ap,tpr,strike_ground,hp_ap,hp_tpr,ap_tpr,ap_tpr_ground,both_ap_tpr,both_ap_tpr_ground`

Harness SHA-256 (current progression.gd only; not a full engine/source fingerprint): `b40a5b2079d1012659f90c2a159c1a911dcbe4e3efc4b6c015b73858215fd38c`; content `a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2`; Godot `4.7.2-stable (official)`.

**Entry action-economy proxy, not approved starting monster/frame/budget/stage.** Every fresh reference sheet: AP=2, TPR=1, authored HP/Initiative/Movement/Reach/kit, full HP. GameData's in-game pool includes user content (including asdf if in-game); no curated exclusions. Prices remain working values; no stat-price or budget assertions.
Uniform teamwide interventions, not single-monster odds or equal-cost allocations. Unilateral scenarios upgrade all three subject A members; both_* upgrades all six and is bilateral escalation, NOT unilateral value. Stat increments +1 capped at HP/Init 10, Movement/AP 5, Reach 4, TPR 3; never lower an already over-cap authored value. strike_ground: proposed content variant, NOT an approved slot choice; append existing Thornbed only to damaging STRIKE slots with NO ground BoardOp, preserving existing ground, AP, damage, shape and all other fields. current-ap matches sim.gd currentap: any in-game ZONE with PUSH or PULL, including mixed-effect zones such as Bog, on both teams using local deep copies.

3v3 seeded boards, mirrored placement, two full-team side swaps per seed/pair, same bot both sides. Each seed owns a draw RNG: draw A, then B excluding A, then setup seed; reset a fresh run RNG to that setup seed for EVERY scenario/swap. Play RNG continues after identical setup draws; divergent actions need not consume identical random draws. Guard: 600 bot turns.

## Source roster (authored stats; before proxy)

| ID | HP/Init/Move/Reach/AP/TPR | Kit ID:effective cost |
|---|---|---|
| blaze_tiger | 5/7.0/5/2/3/1 | new_skill:3, strike_jab:2, fire_trail:2, lava_field:1 |
| ember_hawk | 3/9.0/5/3/2/2 | glide:2, strike_jab:2, cinder_dive:1, gale:1 |
| forge_golem | 8/1.0/1/3/3/1 | strike_jab:2, strike_thrust:3, set_gong:1, gale:1 |
| asdf | 5/5.0/3/3/3/1 | asdf:3, asdf_2:1, asdf_3:1, thornbed:1 |
| grove_wisp | 3/9.0/5/3/3/1 | quake_leap:2, strike_jab:2, gale:1, thornbed:1 |
| moss_turtle | 7/3.0/2/3/3/1 | run:1, bog:1, void_pull:1, shove:2 |
| thorn_mites | 6/3.0/3/3/2/2 | glide:2, strike_jab:2, thornbed:1, void_pull:1 |
| dusk_moth | 3/7.0/3/4/3/1 | run:1, gloom_rift:1, void_pull:1, snare:2 |
| gloom_wolf | 4/9.0/3/3/3/1 | run:1, thorn_lash:2, shove:2, plant_bamboo:1 |
| hollow_serpent | 6/5.0/2/3/3/1 | run:1, strike_jab:2, coiling_rift:2, thornbed:1 |

## Canonical draw schedule

| Seed | Pair | Subject A | Opponent B | Setup seed |
|---|---|---|---|---|
| 401 | 1 | hollow_serpent,gloom_wolf,grove_wisp | blaze_tiger,thorn_mites,forge_golem | 526642205 |
| 401 | 2 | ember_hawk,gloom_wolf,blaze_tiger | grove_wisp,dusk_moth,asdf | 847685958 |
| 401 | 3 | hollow_serpent,ember_hawk,gloom_wolf | dusk_moth,asdf,moss_turtle | 65110119 |
| 401 | 4 | ember_hawk,asdf,thorn_mites | moss_turtle,gloom_wolf,hollow_serpent | 877779835 |
| 402 | 1 | asdf,blaze_tiger,thorn_mites | dusk_moth,gloom_wolf,moss_turtle | 754957460 |
| 402 | 2 | asdf,blaze_tiger,hollow_serpent | ember_hawk,dusk_moth,grove_wisp | 366673621 |
| 402 | 3 | gloom_wolf,dusk_moth,moss_turtle | forge_golem,ember_hawk,hollow_serpent | 533397458 |
| 402 | 4 | blaze_tiger,grove_wisp,dusk_moth | asdf,forge_golem,hollow_serpent | 560403399 |

## Aggregate

Score=(wins+0.5×true draws)/(games−timeouts); timeouts separate. Rounds include timeout partial rounds; histograms allow exact weighted means. Defeat/damage/activation metrics cover BOTH teams; first-defeat turns count turn_started events through the first defeat, omitting games with none. Collision is collision HP damage (not collision events). Repeat=second/later activation of same actor+skill within one turn, including slotted movement, excluding Step; event fallback matches sim.gd, not distinct slot identity.

| Scenario | Class | Games | A W/L/D/timeout | Score | Mean rounds | <2/>5/max | Pre-first-turn defeats/games | Turns to first defeat (n) | Collision/total damage | Repeats/activations | Round histogram |
|---|---|---|---|---|---|---|---|---|---|---|---|
| base | control | 16 | 7/8/1/0 | 0.47 | 3.75 | 0/0/5 | 0/0 | 6.88 (16) | 150/383 | 49/323 (0.15) | 3:5, 4:10, 5:1 |
| hp | unilateral | 16 | 9/6/1/0 | 0.59 | 4.25 | 0/3/6 | 0/0 | 7.06 (16) | 160/441 | 54/357 (0.15) | 3:4, 4:7, 5:2, 6:3 |
| initiative | unilateral | 16 | 6/10/0/0 | 0.38 | 3.75 | 0/0/5 | 0/0 | 7.75 (16) | 169/419 | 54/325 (0.17) | 2:1, 3:3, 4:11, 5:1 |
| movement | unilateral | 16 | 9/7/0/0 | 0.56 | 3.13 | 0/0/4 | 0/0 | 6.50 (16) | 182/404 | 43/286 (0.15) | 2:3, 3:8, 4:5 |
| reach | unilateral | 16 | 9/7/0/0 | 0.56 | 3.94 | 0/0/5 | 0/0 | 6.88 (16) | 148/385 | 43/316 (0.14) | 3:4, 4:9, 5:3 |
| ap | unilateral | 16 | 8/8/0/0 | 0.50 | 3.19 | 0/0/4 | 0/0 | 6.38 (16) | 172/394 | 45/350 (0.13) | 2:2, 3:9, 4:5 |
| tpr | unilateral | 16 | 10/6/0/0 | 0.63 | 3.56 | 0/0/5 | 0/0 | 6.94 (16) | 172/423 | 52/376 (0.14) | 2:1, 3:8, 4:4, 5:3 |
| strike_ground | unilateral | 16 | 7/8/1/0 | 0.47 | 3.75 | 0/0/5 | 0/0 | 6.88 (16) | 150/383 | 49/323 (0.15) | 3:5, 4:10, 5:1 |
| hp_ap | unilateral | 16 | 12/4/0/0 | 0.75 | 3.44 | 0/0/5 | 0/0 | 6.63 (16) | 167/414 | 39/365 (0.11) | 2:2, 3:7, 4:5, 5:2 |
| hp_tpr | unilateral | 16 | 12/4/0/0 | 0.75 | 3.25 | 0/0/5 | 0/0 | 7.06 (16) | 171/436 | 53/353 (0.15) | 2:1, 3:12, 4:1, 5:2 |
| ap_tpr | unilateral | 16 | 10/6/0/0 | 0.63 | 2.88 | 0/0/4 | 0/0 | 6.38 (16) | 170/399 | 54/396 (0.14) | 2:5, 3:8, 4:3 |
| ap_tpr_ground | unilateral | 16 | 10/6/0/0 | 0.63 | 2.88 | 0/0/4 | 0/0 | 6.38 (16) | 169/399 | 51/387 (0.13) | 2:5, 3:8, 4:3 |
| both_ap_tpr | bilateral | 16 | 6/10/0/0 | 0.38 | 2.25 | 0/0/3 | 0/0 | 5.56 (16) | 147/364 | 42/390 (0.11) | 2:12, 3:4 |
| both_ap_tpr_ground | bilateral | 16 | 6/10/0/0 | 0.38 | 2.13 | 0/0/3 | 0/0 | 5.56 (16) | 152/363 | 38/394 (0.10) | 2:14, 3:2 |

## Start affordability and actual interventions

Both teams pooled, repeated per game. Affordability only: cost≤sheet AP, NOT target legality; no assumption that a low-stage kit should be fully affordable. Move/attack counts units with an affordable slotted MOVE/damaging STRIKE (not universal Step). Stat deltas: attempted/applied sum/changed count/cap-blocked count, per upgraded member. strike_ground: eligible damaging STRIKE attempts/applied/not_applied (existing ground); proposed content variant, not an approved slot choice. No rounding of exact counts.

| Scenario | Affordable/active slots | No affordable active/units | Has move/attack | Unaffordable ID:slot count | Stat delta attempted/sum/changed/blocked | strike_ground counts |
|---|---|---|---|---|---|---|
| base | 356/384 | 0/96 | 90/64 | asdf:12, new_skill:10, strike_thrust:6 | — | — |
| hp | 356/384 | 0/96 | 90/64 | asdf:12, new_skill:10, strike_thrust:6 | hp:[48, 48.0, 48, 0] | — |
| initiative | 356/384 | 0/96 | 90/64 | asdf:12, new_skill:10, strike_thrust:6 | initiative:[48, 48.0, 48, 0] | — |
| movement | 356/384 | 0/96 | 90/64 | asdf:12, new_skill:10, strike_thrust:6 | movement:[48, 30.0, 30, 18] | — |
| reach | 356/384 | 0/96 | 90/64 | asdf:12, new_skill:10, strike_thrust:6 | reach:[48, 44.0, 44, 4] | — |
| ap | 370/384 | 0/96 | 90/70 | asdf:6, new_skill:2, strike_thrust:6 | ap:[48, 48.0, 48, 0] | — |
| tpr | 356/384 | 0/96 | 90/64 | asdf:12, new_skill:10, strike_thrust:6 | tpr:[48, 48.0, 48, 0] | — |
| strike_ground | 356/384 | 0/96 | 90/64 | asdf:12, new_skill:10, strike_thrust:6 | — | applied:42, attempted:50, not_applied:8 |
| hp_ap | 370/384 | 0/96 | 90/70 | asdf:6, new_skill:2, strike_thrust:6 | ap:[48, 48.0, 48, 0], hp:[48, 48.0, 48, 0] | — |
| hp_tpr | 356/384 | 0/96 | 90/64 | asdf:12, new_skill:10, strike_thrust:6 | hp:[48, 48.0, 48, 0], tpr:[48, 48.0, 48, 0] | — |
| ap_tpr | 370/384 | 0/96 | 90/70 | asdf:6, new_skill:2, strike_thrust:6 | ap:[48, 48.0, 48, 0], tpr:[48, 48.0, 48, 0] | — |
| ap_tpr_ground | 370/384 | 0/96 | 90/70 | asdf:6, new_skill:2, strike_thrust:6 | ap:[48, 48.0, 48, 0], tpr:[48, 48.0, 48, 0] | applied:42, attempted:50, not_applied:8 |
| both_ap_tpr | 384/384 | 0/96 | 90/76 | — | ap:[96, 96.0, 96, 0], tpr:[96, 96.0, 96, 0] | — |
| both_ap_tpr_ground | 384/384 | 0/96 | 90/76 | — | ap:[96, 96.0, 96, 0], tpr:[96, 96.0, 96, 0] | applied:80, attempted:92, not_applied:12 |

## Active skill usage

All equipped active IDs, not just top skills; activations/start slots pooled over both teams and games (not success rates).

| Scenario | ID:activations/start slots |
|---|---|
| base | void_pull:19/26, cinder_dive:0/10, snare:0/12, asdf:0/12, asdf_3:19/12, strike_jab:31/52, new_skill:0/10, thornbed:17/38, run:82/44, plant_bamboo:8/12, gale:25/24, bog:12/8, quake_leap:11/8, set_gong:0/6, thorn_lash:4/12, strike_thrust:0/6, fire_trail:19/10, shove:6/20, lava_field:1/10, glide:21/16, gloom_rift:19/12, coiling_rift:12/12, asdf_2:17/12 |
| hp | void_pull:23/26, cinder_dive:0/10, snare:0/12, asdf:0/12, asdf_3:19/12, strike_jab:34/52, new_skill:0/10, thornbed:25/38, run:89/44, plant_bamboo:9/12, gale:27/24, bog:14/8, quake_leap:10/8, set_gong:0/6, thorn_lash:4/12, strike_thrust:0/6, fire_trail:20/10, shove:8/20, lava_field:3/10, glide:25/16, gloom_rift:22/12, coiling_rift:8/12, asdf_2:17/12 |
| initiative | void_pull:28/26, cinder_dive:0/10, snare:0/12, asdf:0/12, asdf_3:15/12, strike_jab:30/52, new_skill:0/10, thornbed:20/38, run:83/44, plant_bamboo:0/12, gale:23/24, bog:7/8, quake_leap:11/8, set_gong:0/6, thorn_lash:7/12, strike_thrust:0/6, fire_trail:18/10, shove:5/20, lava_field:7/10, glide:21/16, gloom_rift:14/12, coiling_rift:12/12, asdf_2:24/12 |
| movement | void_pull:30/26, cinder_dive:0/10, snare:0/12, asdf:0/12, asdf_3:14/12, strike_jab:23/52, new_skill:0/10, thornbed:7/38, run:80/44, plant_bamboo:6/12, gale:24/24, bog:3/8, quake_leap:8/8, set_gong:0/6, thorn_lash:13/12, strike_thrust:0/6, fire_trail:17/10, shove:4/20, lava_field:4/10, glide:19/16, gloom_rift:8/12, coiling_rift:3/12, asdf_2:23/12 |
| reach | void_pull:23/26, cinder_dive:0/10, snare:0/12, asdf:0/12, asdf_3:19/12, strike_jab:32/52, new_skill:0/10, thornbed:20/38, run:75/44, plant_bamboo:7/12, gale:25/24, bog:10/8, quake_leap:8/8, set_gong:0/6, thorn_lash:6/12, strike_thrust:0/6, fire_trail:18/10, shove:8/20, lava_field:1/10, glide:24/16, gloom_rift:19/12, coiling_rift:12/12, asdf_2:9/12 |
| ap | void_pull:29/26, cinder_dive:5/10, snare:0/12, asdf:2/12, asdf_3:17/12, strike_jab:24/52, new_skill:3/10, thornbed:30/38, run:90/44, plant_bamboo:13/12, gale:14/24, bog:15/8, quake_leap:10/8, set_gong:1/6, thorn_lash:4/12, strike_thrust:0/6, fire_trail:17/10, shove:5/20, lava_field:14/10, glide:22/16, gloom_rift:14/12, coiling_rift:8/12, asdf_2:13/12 |
| tpr | void_pull:28/26, cinder_dive:0/10, snare:0/12, asdf:0/12, asdf_3:18/12, strike_jab:33/52, new_skill:0/10, thornbed:26/38, run:83/44, plant_bamboo:8/12, gale:33/24, bog:10/8, quake_leap:8/8, set_gong:0/6, thorn_lash:10/12, strike_thrust:0/6, fire_trail:27/10, shove:10/20, lava_field:14/10, glide:21/16, gloom_rift:21/12, coiling_rift:15/12, asdf_2:11/12 |
| strike_ground | void_pull:19/26, cinder_dive:0/10, snare:0/12, asdf:0/12, asdf_3:19/12, strike_jab:31/52, new_skill:0/10, thornbed:17/38, run:82/44, plant_bamboo:8/12, gale:25/24, bog:12/8, quake_leap:11/8, set_gong:0/6, thorn_lash:4/12, strike_thrust:0/6, fire_trail:19/10, shove:6/20, lava_field:1/10, glide:21/16, gloom_rift:19/12, coiling_rift:12/12, asdf_2:17/12 |
| hp_ap | void_pull:31/26, cinder_dive:7/10, snare:0/12, asdf:4/12, asdf_3:18/12, strike_jab:25/52, new_skill:4/10, thornbed:28/38, run:80/44, plant_bamboo:13/12, gale:20/24, bog:10/8, quake_leap:9/8, set_gong:1/6, thorn_lash:7/12, strike_thrust:0/6, fire_trail:20/10, shove:5/20, lava_field:18/10, glide:22/16, gloom_rift:19/12, coiling_rift:8/12, asdf_2:16/12 |
| hp_tpr | void_pull:19/26, cinder_dive:0/10, snare:0/12, asdf:0/12, asdf_3:21/12, strike_jab:37/52, new_skill:0/10, thornbed:23/38, run:88/44, plant_bamboo:11/12, gale:25/24, bog:11/8, quake_leap:8/8, set_gong:0/6, thorn_lash:11/12, strike_thrust:0/6, fire_trail:20/10, shove:7/20, lava_field:7/10, glide:18/16, gloom_rift:24/12, coiling_rift:10/12, asdf_2:13/12 |
| ap_tpr | void_pull:32/26, cinder_dive:6/10, snare:0/12, asdf:2/12, asdf_3:16/12, strike_jab:28/52, new_skill:5/10, thornbed:30/38, run:104/44, plant_bamboo:14/12, gale:18/24, bog:13/8, quake_leap:9/8, set_gong:1/6, thorn_lash:8/12, strike_thrust:0/6, fire_trail:19/10, shove:5/20, lava_field:20/10, glide:20/16, gloom_rift:22/12, coiling_rift:8/12, asdf_2:16/12 |
| ap_tpr_ground | void_pull:33/26, cinder_dive:6/10, snare:0/12, asdf:2/12, asdf_3:16/12, strike_jab:27/52, new_skill:5/10, thornbed:29/38, run:102/44, plant_bamboo:14/12, gale:18/24, bog:13/8, quake_leap:9/8, set_gong:1/6, thorn_lash:8/12, strike_thrust:0/6, fire_trail:18/10, shove:5/20, lava_field:17/10, glide:20/16, gloom_rift:20/12, coiling_rift:8/12, asdf_2:16/12 |
| both_ap_tpr | void_pull:21/26, cinder_dive:4/10, snare:0/12, asdf:4/12, asdf_3:18/12, strike_jab:28/52, new_skill:6/10, thornbed:35/38, run:97/44, plant_bamboo:13/12, gale:18/24, bog:8/8, quake_leap:8/8, set_gong:2/6, thorn_lash:15/12, strike_thrust:0/6, fire_trail:15/10, shove:5/20, lava_field:12/10, glide:22/16, gloom_rift:22/12, coiling_rift:17/12, asdf_2:20/12 |
| both_ap_tpr_ground | void_pull:22/26, cinder_dive:7/10, snare:0/12, asdf:2/12, asdf_3:20/12, strike_jab:23/52, new_skill:4/10, thornbed:37/38, run:93/44, plant_bamboo:13/12, gale:17/24, bog:8/8, quake_leap:8/8, set_gong:4/6, thorn_lash:17/12, strike_thrust:0/6, fire_trail:16/10, shove:3/20, lava_field:16/10, glide:22/16, gloom_rift:25/12, coiling_rift:18/12, asdf_2:19/12 |

Limitations: small, bot- and roster-dependent teamwide interventions; paired draws are not independent per swap. Not human agency/fun/fairness validation, single-monster causal odds, equal-price comparisons, approved progression or balance/price evidence.

PROGRESSION_MEASUREMENT_COMPLETED: final content fingerprint `a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2` matches startup `a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2`.

```

#### progression_bilateral.txt

```text

# Progression intervention experiment

Command: `godot --headless --path godot -s res://tools/progression.gd -- --seeds 401,402 --pairs 4 --bot greedy --current-ap 2 --scenarios both_hp,both_ap,both_tpr,both_strike_ground,both_hp_ap,both_hp_tpr,both_hp_ap_tpr,both_hp_ap_tpr_ground`

Harness SHA-256 (current progression.gd only; not a full engine/source fingerprint): `b40a5b2079d1012659f90c2a159c1a911dcbe4e3efc4b6c015b73858215fd38c`; content `a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2`; Godot `4.7.2-stable (official)`.

**Entry action-economy proxy, not approved starting monster/frame/budget/stage.** Every fresh reference sheet: AP=2, TPR=1, authored HP/Initiative/Movement/Reach/kit, full HP. GameData's in-game pool includes user content (including asdf if in-game); no curated exclusions. Prices remain working values; no stat-price or budget assertions.
Uniform teamwide interventions, not single-monster odds or equal-cost allocations. Unilateral scenarios upgrade all three subject A members; both_* upgrades all six and is bilateral escalation, NOT unilateral value. Stat increments +1 capped at HP/Init 10, Movement/AP 5, Reach 4, TPR 3; never lower an already over-cap authored value. strike_ground: proposed content variant, NOT an approved slot choice; append existing Thornbed only to damaging STRIKE slots with NO ground BoardOp, preserving existing ground, AP, damage, shape and all other fields. current-ap matches sim.gd currentap: any in-game ZONE with PUSH or PULL, including mixed-effect zones such as Bog, on both teams using local deep copies.

3v3 seeded boards, mirrored placement, two full-team side swaps per seed/pair, same bot both sides. Each seed owns a draw RNG: draw A, then B excluding A, then setup seed; reset a fresh run RNG to that setup seed for EVERY scenario/swap. Play RNG continues after identical setup draws; divergent actions need not consume identical random draws. Guard: 600 bot turns.

## Source roster (authored stats; before proxy)

| ID | HP/Init/Move/Reach/AP/TPR | Kit ID:effective cost |
|---|---|---|
| blaze_tiger | 5/7.0/5/2/3/1 | new_skill:3, strike_jab:2, fire_trail:2, lava_field:1 |
| ember_hawk | 3/9.0/5/3/2/2 | glide:2, strike_jab:2, cinder_dive:1, gale:1 |
| forge_golem | 8/1.0/1/3/3/1 | strike_jab:2, strike_thrust:3, set_gong:1, gale:1 |
| asdf | 5/5.0/3/3/3/1 | asdf:3, asdf_2:1, asdf_3:1, thornbed:1 |
| grove_wisp | 3/9.0/5/3/3/1 | quake_leap:2, strike_jab:2, gale:1, thornbed:1 |
| moss_turtle | 7/3.0/2/3/3/1 | run:1, bog:1, void_pull:1, shove:2 |
| thorn_mites | 6/3.0/3/3/2/2 | glide:2, strike_jab:2, thornbed:1, void_pull:1 |
| dusk_moth | 3/7.0/3/4/3/1 | run:1, gloom_rift:1, void_pull:1, snare:2 |
| gloom_wolf | 4/9.0/3/3/3/1 | run:1, thorn_lash:2, shove:2, plant_bamboo:1 |
| hollow_serpent | 6/5.0/2/3/3/1 | run:1, strike_jab:2, coiling_rift:2, thornbed:1 |

## Canonical draw schedule

| Seed | Pair | Subject A | Opponent B | Setup seed |
|---|---|---|---|---|
| 401 | 1 | hollow_serpent,gloom_wolf,grove_wisp | blaze_tiger,thorn_mites,forge_golem | 526642205 |
| 401 | 2 | ember_hawk,gloom_wolf,blaze_tiger | grove_wisp,dusk_moth,asdf | 847685958 |
| 401 | 3 | hollow_serpent,ember_hawk,gloom_wolf | dusk_moth,asdf,moss_turtle | 65110119 |
| 401 | 4 | ember_hawk,asdf,thorn_mites | moss_turtle,gloom_wolf,hollow_serpent | 877779835 |
| 402 | 1 | asdf,blaze_tiger,thorn_mites | dusk_moth,gloom_wolf,moss_turtle | 754957460 |
| 402 | 2 | asdf,blaze_tiger,hollow_serpent | ember_hawk,dusk_moth,grove_wisp | 366673621 |
| 402 | 3 | gloom_wolf,dusk_moth,moss_turtle | forge_golem,ember_hawk,hollow_serpent | 533397458 |
| 402 | 4 | blaze_tiger,grove_wisp,dusk_moth | asdf,forge_golem,hollow_serpent | 560403399 |

## Aggregate

Score=(wins+0.5×true draws)/(games−timeouts); timeouts separate. Rounds include timeout partial rounds; histograms allow exact weighted means. Defeat/damage/activation metrics cover BOTH teams; first-defeat turns count turn_started events through the first defeat, omitting games with none. Collision is collision HP damage (not collision events). Repeat=second/later activation of same actor+skill within one turn, including slotted movement, excluding Step; event fallback matches sim.gd, not distinct slot identity.

| Scenario | Class | Games | A W/L/D/timeout | Score | Mean rounds | <2/>5/max | Pre-first-turn defeats/games | Turns to first defeat (n) | Collision/total damage | Repeats/activations | Round histogram |
|---|---|---|---|---|---|---|---|---|---|---|---|
| both_hp | bilateral | 16 | 9/6/1/0 | 0.59 | 4.25 | 0/3/7 | 0/0 | 7.88 (16) | 193/492 | 47/354 (0.13) | 2:2, 3:3, 4:5, 5:3, 6:1, 7:2 |
| both_ap | bilateral | 16 | 6/10/0/0 | 0.38 | 2.75 | 0/0/4 | 0/0 | 5.56 (16) | 116/370 | 40/365 (0.11) | 2:6, 3:8, 4:2 |
| both_tpr | bilateral | 16 | 7/9/0/0 | 0.44 | 2.75 | 0/0/4 | 0/0 | 7.00 (16) | 206/424 | 42/349 (0.12) | 2:5, 3:10, 4:1 |
| both_strike_ground | bilateral | 16 | 8/8/0/0 | 0.50 | 3.63 | 0/0/5 | 0/0 | 6.88 (16) | 145/369 | 42/302 (0.14) | 2:1, 3:5, 4:9, 5:1 |
| both_hp_ap | bilateral | 16 | 5/11/0/0 | 0.31 | 3.19 | 0/0/4 | 0/0 | 6.75 (16) | 169/474 | 28/409 (0.07) | 2:3, 3:7, 4:6 |
| both_hp_tpr | bilateral | 16 | 8/8/0/0 | 0.50 | 2.63 | 0/0/3 | 0/0 | 8.06 (16) | 229/460 | 47/346 (0.14) | 2:6, 3:10 |
| both_hp_ap_tpr | bilateral | 16 | 5/10/1/0 | 0.34 | 2.56 | 0/0/3 | 0/0 | 6.63 (16) | 182/488 | 38/469 (0.08) | 2:7, 3:9 |
| both_hp_ap_tpr_ground | bilateral | 16 | 5/11/0/0 | 0.31 | 2.63 | 0/0/4 | 0/0 | 6.63 (16) | 174/483 | 41/487 (0.08) | 2:7, 3:8, 4:1 |

## Start affordability and actual interventions

Both teams pooled, repeated per game. Affordability only: cost≤sheet AP, NOT target legality; no assumption that a low-stage kit should be fully affordable. Move/attack counts units with an affordable slotted MOVE/damaging STRIKE (not universal Step). Stat deltas: attempted/applied sum/changed count/cap-blocked count, per upgraded member. strike_ground: eligible damaging STRIKE attempts/applied/not_applied (existing ground); proposed content variant, not an approved slot choice. No rounding of exact counts.

| Scenario | Affordable/active slots | No affordable active/units | Has move/attack | Unaffordable ID:slot count | Stat delta attempted/sum/changed/blocked | strike_ground counts |
|---|---|---|---|---|---|---|
| both_hp | 356/384 | 0/96 | 90/64 | asdf:12, new_skill:10, strike_thrust:6 | hp:[96, 96.0, 96, 0] | — |
| both_ap | 384/384 | 0/96 | 90/76 | — | ap:[96, 96.0, 96, 0] | — |
| both_tpr | 356/384 | 0/96 | 90/64 | asdf:12, new_skill:10, strike_thrust:6 | tpr:[96, 96.0, 96, 0] | — |
| both_strike_ground | 356/384 | 0/96 | 90/64 | asdf:12, new_skill:10, strike_thrust:6 | — | applied:80, attempted:92, not_applied:12 |
| both_hp_ap | 384/384 | 0/96 | 90/76 | — | ap:[96, 96.0, 96, 0], hp:[96, 96.0, 96, 0] | — |
| both_hp_tpr | 356/384 | 0/96 | 90/64 | asdf:12, new_skill:10, strike_thrust:6 | hp:[96, 96.0, 96, 0], tpr:[96, 96.0, 96, 0] | — |
| both_hp_ap_tpr | 384/384 | 0/96 | 90/76 | — | ap:[96, 96.0, 96, 0], hp:[96, 96.0, 96, 0], tpr:[96, 96.0, 96, 0] | — |
| both_hp_ap_tpr_ground | 384/384 | 0/96 | 90/76 | — | ap:[96, 96.0, 96, 0], hp:[96, 96.0, 96, 0], tpr:[96, 96.0, 96, 0] | applied:80, attempted:92, not_applied:12 |

## Active skill usage

All equipped active IDs, not just top skills; activations/start slots pooled over both teams and games (not success rates).

| Scenario | ID:activations/start slots |
|---|---|
| both_hp | void_pull:25/26, cinder_dive:0/10, snare:0/12, asdf:0/12, asdf_3:17/12, strike_jab:31/52, new_skill:0/10, thornbed:20/38, run:79/44, plant_bamboo:9/12, gale:35/24, bog:18/8, quake_leap:11/8, set_gong:0/6, thorn_lash:6/12, strike_thrust:0/6, fire_trail:17/10, shove:5/20, lava_field:3/10, glide:23/16, gloom_rift:28/12, coiling_rift:13/12, asdf_2:14/12 |
| both_ap | void_pull:27/26, cinder_dive:3/10, snare:0/12, asdf:8/12, asdf_3:17/12, strike_jab:21/52, new_skill:6/10, thornbed:40/38, run:88/44, plant_bamboo:12/12, gale:15/24, bog:7/8, quake_leap:8/8, set_gong:5/6, thorn_lash:13/12, strike_thrust:0/6, fire_trail:11/10, shove:2/20, lava_field:11/10, glide:18/16, gloom_rift:20/12, coiling_rift:15/12, asdf_2:18/12 |
| both_tpr | void_pull:27/26, cinder_dive:0/10, snare:0/12, asdf:0/12, asdf_3:17/12, strike_jab:37/52, new_skill:0/10, thornbed:19/38, run:77/44, plant_bamboo:9/12, gale:32/24, bog:15/8, quake_leap:9/8, set_gong:0/6, thorn_lash:8/12, strike_thrust:0/6, fire_trail:21/10, shove:10/20, lava_field:0/10, glide:24/16, gloom_rift:16/12, coiling_rift:12/12, asdf_2:16/12 |
| both_strike_ground | void_pull:18/26, cinder_dive:0/10, snare:0/12, asdf:0/12, asdf_3:17/12, strike_jab:29/52, new_skill:0/10, thornbed:14/38, run:73/44, plant_bamboo:10/12, gale:24/24, bog:11/8, quake_leap:8/8, set_gong:0/6, thorn_lash:4/12, strike_thrust:0/6, fire_trail:17/10, shove:6/20, lava_field:1/10, glide:22/16, gloom_rift:19/12, coiling_rift:14/12, asdf_2:15/12 |
| both_hp_ap | void_pull:31/26, cinder_dive:5/10, snare:0/12, asdf:9/12, asdf_3:16/12, strike_jab:28/52, new_skill:1/10, thornbed:36/38, run:86/44, plant_bamboo:11/12, gale:16/24, bog:15/8, quake_leap:9/8, set_gong:6/6, thorn_lash:15/12, strike_thrust:0/6, fire_trail:18/10, shove:4/20, lava_field:17/10, glide:24/16, gloom_rift:27/12, coiling_rift:20/12, asdf_2:15/12 |
| both_hp_tpr | void_pull:26/26, cinder_dive:0/10, snare:0/12, asdf:0/12, asdf_3:21/12, strike_jab:35/52, new_skill:0/10, thornbed:15/38, run:80/44, plant_bamboo:10/12, gale:31/24, bog:10/8, quake_leap:10/8, set_gong:0/6, thorn_lash:10/12, strike_thrust:0/6, fire_trail:21/10, shove:4/20, lava_field:4/10, glide:23/16, gloom_rift:17/12, coiling_rift:12/12, asdf_2:17/12 |
| both_hp_ap_tpr | void_pull:35/26, cinder_dive:5/10, snare:0/12, asdf:7/12, asdf_3:20/12, strike_jab:38/52, new_skill:4/10, thornbed:52/38, run:90/44, plant_bamboo:11/12, gale:14/24, bog:13/8, quake_leap:9/8, set_gong:3/6, thorn_lash:15/12, strike_thrust:3/6, fire_trail:22/10, shove:7/20, lava_field:19/10, glide:24/16, gloom_rift:37/12, coiling_rift:20/12, asdf_2:21/12 |
| both_hp_ap_tpr_ground | void_pull:39/26, cinder_dive:4/10, snare:0/12, asdf:9/12, asdf_3:22/12, strike_jab:39/52, new_skill:1/10, thornbed:52/38, run:97/44, plant_bamboo:11/12, gale:18/24, bog:12/8, quake_leap:9/8, set_gong:6/6, thorn_lash:16/12, strike_thrust:2/6, fire_trail:21/10, shove:7/20, lava_field:22/10, glide:26/16, gloom_rift:41/12, coiling_rift:15/12, asdf_2:18/12 |

Limitations: small, bot- and roster-dependent teamwide interventions; paired draws are not independent per swap. Not human agency/fun/fairness validation, single-monster causal odds, equal-price comparisons, approved progression or balance/price evidence.

PROGRESSION_MEASUREMENT_COMPLETED: final content fingerprint `a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2` matches startup `a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2`.

```

#### progression_tactic.txt

```text

# Progression intervention experiment

Command: `godot --headless --path godot -s res://tools/progression.gd -- --seeds 401,402 --pairs 1 --bot tactic --current-ap 2 --scenarios base,both_ap_tpr,both_hp_ap_tpr`

Harness SHA-256 (current progression.gd only; not a full engine/source fingerprint): `b40a5b2079d1012659f90c2a159c1a911dcbe4e3efc4b6c015b73858215fd38c`; content `a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2`; Godot `4.7.2-stable (official)`.

**Entry action-economy proxy, not approved starting monster/frame/budget/stage.** Every fresh reference sheet: AP=2, TPR=1, authored HP/Initiative/Movement/Reach/kit, full HP. GameData's in-game pool includes user content (including asdf if in-game); no curated exclusions. Prices remain working values; no stat-price or budget assertions.
Uniform teamwide interventions, not single-monster odds or equal-cost allocations. Unilateral scenarios upgrade all three subject A members; both_* upgrades all six and is bilateral escalation, NOT unilateral value. Stat increments +1 capped at HP/Init 10, Movement/AP 5, Reach 4, TPR 3; never lower an already over-cap authored value. strike_ground: proposed content variant, NOT an approved slot choice; append existing Thornbed only to damaging STRIKE slots with NO ground BoardOp, preserving existing ground, AP, damage, shape and all other fields. current-ap matches sim.gd currentap: any in-game ZONE with PUSH or PULL, including mixed-effect zones such as Bog, on both teams using local deep copies.

3v3 seeded boards, mirrored placement, two full-team side swaps per seed/pair, same bot both sides. Each seed owns a draw RNG: draw A, then B excluding A, then setup seed; reset a fresh run RNG to that setup seed for EVERY scenario/swap. Play RNG continues after identical setup draws; divergent actions need not consume identical random draws. Guard: 600 bot turns.

## Source roster (authored stats; before proxy)

| ID | HP/Init/Move/Reach/AP/TPR | Kit ID:effective cost |
|---|---|---|
| blaze_tiger | 5/7.0/5/2/3/1 | new_skill:3, strike_jab:2, fire_trail:2, lava_field:1 |
| ember_hawk | 3/9.0/5/3/2/2 | glide:2, strike_jab:2, cinder_dive:1, gale:1 |
| forge_golem | 8/1.0/1/3/3/1 | strike_jab:2, strike_thrust:3, set_gong:1, gale:1 |
| asdf | 5/5.0/3/3/3/1 | asdf:3, asdf_2:1, asdf_3:1, thornbed:1 |
| grove_wisp | 3/9.0/5/3/3/1 | quake_leap:2, strike_jab:2, gale:1, thornbed:1 |
| moss_turtle | 7/3.0/2/3/3/1 | run:1, bog:1, void_pull:1, shove:2 |
| thorn_mites | 6/3.0/3/3/2/2 | glide:2, strike_jab:2, thornbed:1, void_pull:1 |
| dusk_moth | 3/7.0/3/4/3/1 | run:1, gloom_rift:1, void_pull:1, snare:2 |
| gloom_wolf | 4/9.0/3/3/3/1 | run:1, thorn_lash:2, shove:2, plant_bamboo:1 |
| hollow_serpent | 6/5.0/2/3/3/1 | run:1, strike_jab:2, coiling_rift:2, thornbed:1 |

## Canonical draw schedule

| Seed | Pair | Subject A | Opponent B | Setup seed |
|---|---|---|---|---|
| 401 | 1 | hollow_serpent,gloom_wolf,grove_wisp | blaze_tiger,thorn_mites,forge_golem | 526642205 |
| 402 | 1 | asdf,blaze_tiger,thorn_mites | dusk_moth,gloom_wolf,moss_turtle | 754957460 |

## Aggregate

Score=(wins+0.5×true draws)/(games−timeouts); timeouts separate. Rounds include timeout partial rounds; histograms allow exact weighted means. Defeat/damage/activation metrics cover BOTH teams; first-defeat turns count turn_started events through the first defeat, omitting games with none. Collision is collision HP damage (not collision events). Repeat=second/later activation of same actor+skill within one turn, including slotted movement, excluding Step; event fallback matches sim.gd, not distinct slot identity.

| Scenario | Class | Games | A W/L/D/timeout | Score | Mean rounds | <2/>5/max | Pre-first-turn defeats/games | Turns to first defeat (n) | Collision/total damage | Repeats/activations | Round histogram |
|---|---|---|---|---|---|---|---|---|---|---|---|
| base | control | 4 | 1/3/0/0 | 0.25 | 5.00 | 0/1/6 | 0/0 | 13.00 (4) | 47/117 | 14/96 (0.15) | 4:1, 5:2, 6:1 |
| both_ap_tpr | bilateral | 4 | 3/1/0/0 | 0.75 | 3.25 | 0/0/5 | 0/0 | 7.00 (4) | 36/111 | 22/113 (0.19) | 2:1, 3:2, 5:1 |
| both_hp_ap_tpr | bilateral | 4 | 3/1/0/0 | 0.75 | 3.50 | 0/0/4 | 0/0 | 9.75 (4) | 55/142 | 27/152 (0.18) | 3:2, 4:2 |

## Start affordability and actual interventions

Both teams pooled, repeated per game. Affordability only: cost≤sheet AP, NOT target legality; no assumption that a low-stage kit should be fully affordable. Move/attack counts units with an affordable slotted MOVE/damaging STRIKE (not universal Step). Stat deltas: attempted/applied sum/changed count/cap-blocked count, per upgraded member. strike_ground: eligible damaging STRIKE attempts/applied/not_applied (existing ground); proposed content variant, not an approved slot choice. No rounding of exact counts.

| Scenario | Affordable/active slots | No affordable active/units | Has move/attack | Unaffordable ID:slot count | Stat delta attempted/sum/changed/blocked | strike_ground counts |
|---|---|---|---|---|---|---|
| base | 88/96 | 0/24 | 22/18 | asdf:2, new_skill:4, strike_thrust:2 | — | — |
| both_ap_tpr | 96/96 | 0/24 | 22/20 | — | ap:[24, 24.0, 24, 0], tpr:[24, 24.0, 24, 0] | — |
| both_hp_ap_tpr | 96/96 | 0/24 | 22/20 | — | ap:[24, 24.0, 24, 0], hp:[24, 24.0, 24, 0], tpr:[24, 24.0, 24, 0] | — |

## Active skill usage

All equipped active IDs, not just top skills; activations/start slots pooled over both teams and games (not success rates).

| Scenario | ID:activations/start slots |
|---|---|
| base | void_pull:9/8, snare:0/2, asdf:0/2, asdf_3:1/2, strike_jab:6/14, new_skill:0/4, thornbed:7/10, run:31/10, plant_bamboo:5/4, gale:5/4, bog:0/2, quake_leap:2/2, set_gong:0/2, thorn_lash:1/4, strike_thrust:0/2, fire_trail:6/4, shove:0/6, lava_field:10/4, glide:7/4, gloom_rift:2/2, coiling_rift:0/2, asdf_2:4/2 |
| both_ap_tpr | void_pull:7/8, snare:0/2, asdf:0/2, asdf_3:3/2, strike_jab:9/14, new_skill:0/4, thornbed:22/10, run:25/10, plant_bamboo:4/4, gale:4/4, bog:3/2, quake_leap:1/2, set_gong:2/2, thorn_lash:5/4, strike_thrust:0/2, fire_trail:7/4, shove:0/6, lava_field:5/4, glide:5/4, gloom_rift:5/2, coiling_rift:0/2, asdf_2:6/2 |
| both_hp_ap_tpr | void_pull:7/8, snare:0/2, asdf:0/2, asdf_3:3/2, strike_jab:13/14, new_skill:0/4, thornbed:17/10, run:41/10, plant_bamboo:6/4, gale:6/4, bog:7/2, quake_leap:2/2, set_gong:2/2, thorn_lash:8/4, strike_thrust:0/2, fire_trail:8/4, shove:0/6, lava_field:7/4, glide:6/4, gloom_rift:9/2, coiling_rift:2/2, asdf_2:8/2 |

Limitations: small, bot- and roster-dependent teamwide interventions; paired draws are not independent per swap. Not human agency/fun/fairness validation, single-monster causal odds, equal-price comparisons, approved progression or balance/price evidence.

PROGRESSION_MEASUREMENT_COMPLETED: final content fingerprint `a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2` matches startup `a30a9be42850a77e38cd8507ff27ca739e6a555d7946b7616e47422797042ac2`.

```

## S021 · 2026-11-13 · matched displacement and survival experiments

**State:** main, base `2828adf` dirty, inherited S020 docs/tools; content `2026-11-13.1`, source fingerprint `a30a9be42850` reused. No resource/core changes. Godot 4.7.2, one Idle process, affinity `0xC` (two of 32 logical CPUs), sequential. User experiments preserved.

**Runs:** 14 series, **508 battles plus one diagnostic replay**, not 509 independent battles: eight current-stat greedy series × 32 = 256; three mixstats greedy × 80 = 240; three tactic × 4 = 12. Paired seeds share boards/teams/stats and unchanged RNG draws before play, **not side-swapped**. Once/map only seed 202; current-stat control/AP/thread seeds 202+303; mixstats/tactic seed 303.

**Variants, in-memory sim.gd only:** `currentonce`: all in-game ZONE PUSH/PULL skills once per round; `currentap=2`: same current skill family costs 2 AP, not all skills or monster AP. Fingerprints `33abaee565d5`/`10212ec4dd2d` differ only in memory through repetition/cost; no second resource set. `openmap`: remove preplaced props, preserve RNG/start/veins; created props still possible. `lifethread`: existing `BattleUnit.life_thread` on everyone, once survive at 1 HP; broad stress test, **not an item/loadout implementation**. Map/thread retain the source fingerprint.

### Exact histogram-weighted summary

Means derive from exact histogram sums, not rounded one-decimal rows. Fractions are exact; decimals rounded to six places.

| Sample / variant | Battles | Round sum / battles = mean | Ended <2 / >5 |
|---|---|---|---|
| Current greedy control | 64 | 145/64 = 2.265625 | 3 / 0 |
| Current greedy AP 2 | 64 | 184/64 = 2.875000 | 0 / 0 |
| Current greedy Life Thread | 64 | 185/64 = 2.890625 | 0 / 0 |
| Current greedy once, seed 202 | 32 | 77/32 = 2.406250 | 2 / 0 |
| Current greedy open, seed 202 | 32 | 79/32 = 2.468750 | 0 / 0 |
| Mixstats greedy control | 80 | 200/80 = 2.500000 | 1 / 0 |
| Mixstats greedy AP 2 | 80 | 244/80 = 3.050000 | 0 / 1 |
| Mixstats greedy Life Thread | 80 | 238/80 = 2.975000 | 0 / 0 |
| Tactic control | 4 | 11/4 = 2.750000 | 0 / 0 |
| Tactic AP 2 | 4 | 11/4 = 2.750000 | 0 / 0 |
| Tactic Life Thread | 4 | 12/4 = 3.000000 | 0 / 0 |

**Observations (indications only):**
- Current-stat AP 2 lengthens greedy battles but remains below the mean 3–5 target. Tactic control/AP 2 both 2.75, Life Thread 3.0 (4 each): **no AP mean improvement demonstrated with the stronger bot**. Mixstats AP 2 reaches 3.05 with one 6-round outlier, battle 58 seed `303000966`, Moss/Wisp/Moth versus Wolf/asdf/Serpent, side 1 wins.
- Once has two round-1 endings versus one matched seed-202 control; open map still has 42 % collision damage, insufficient evidence to eliminate props. Both tests have only 32 battles. AP 2 collision shares 38/35 % versus control 50/49 %; Life Thread 51/47 %. Repeated activations decrease under restrictive interventions, but not all goals are met. Activation counts exclude later zone ticks.
- Current-stat early defeats: control 6 units in 6/64 battles, AP 2 zero, Life Thread 1/64. Mixstats AP 2 still has 1/80, tactic Life Thread 1/4. AP/HP/TPR sampling rows are conditional team outcomes, not causal stat values or additive prices. Shared teams are not independent samples; matching does not remove bot limitations or side/tie bias.

### Descriptive stat contrasts (post-hoc grouping)

The three mixstats runs use identical drawn stats; each row below is the **team win rate conditional on a fielded monster's stat**, calculated from exact wins/appearances. Low/high groups were chosen after the runs for description, not as a preregistered significance test. Team members share outcomes; these are not independent duels or causal marginal stat prices.

| Contrast | Control | Current AP 2 | Life Thread |
|---|---|---|---|
| HP 3–4 / 7–8 (134 / 163 appearances) | 42.5 / 58.3 % | 39.6 / 57.1 % | 41.0 / 60.7 % |
| Initiative 1–3 / 7–9 (161 / 166) | 51.6 / 47.0 % | 52.2 / 48.2 % | 53.4 / 51.2 % |
| Movement 1–2 / 4–5 (208 / 173) | 45.7 / 54.3 % | 46.2 / 51.4 % | 49.0 / 51.4 % |
| Reach 2 / 4 (157 / 167) | 43.9 / 47.9 % | 49.0 / 52.1 % | 46.5 / 50.3 % |
| AP 2 / 3 (236 / 244) | 46.2 / 52.5 % | 45.3 / 53.3 % | 44.5 / 55.3 % |
| TPR 1 / 2 (235 / 245) | 42.6 / 55.9 % | 46.8 / 51.8 % | 43.8 / 55.9 % |

### Diagnostic replay — S020 seed 202 battle 43

Nonpaired seed `202000648` reproduces Moss/asdf/Golem versus Moth/Wolf/Hawk. Three `asdf_3` casts deal 6 collision HP between stationary Wolf/Moth, then Void Pull plus Bog twice finishes. Total 10 damage, 100 % collision; all victims had acted already, no before-first-turn deaths. First-turn survival is insufficient to infer fairness or meaningful response windows. This duplicates S020, not an independent battle. Full trace and the unchanged raw block appear once below.

```text
-- round 1  e1_gloom_wolf  AP 3
...b...
.c...a.
...o...
o?.?.?o
...o...
.A...C.
...B...
   A 7/7  B 5/5  C 8/8  a 3/3  b 4/4  c 3/3
-- round 1  e2_ember_hawk  AP 2
.......
.c...a.
...o...
o?.b.?o
...o...
.A...C.
...B...
   A 7/7  B 5/5  C 8/8  a 3/3  b 4/4  c 3/3
-- round 1  e0_dusk_moth  AP 3
.......
.....a.
...o...
oc.b.?o
...o...
.A...C.
...B...
   A 7/7  B 5/5  C 8/8  a 3/3  b 4/4  c 3/3
-- round 1  p1_asdf  AP 3
.......
.......
...o...
oc.ba?o
...o.%.
.A..%C%
...B...
   A 7/7  B 5/5  C 8/8  a 3/3  b 4/4  c 3/3
-- round 1  p0_moss_turtle  AP 3
.......
.......
...o...
oc.b.?o
...o.%.
.A..%C%
...B...
   A 7/7  B 5/5  C 8/8  b 1/4  c 3/3
Event timeline after battle (round · event dictionary):
round 1 · { "round": 1, "queue": [&"e1_gloom_wolf", &"e2_ember_hawk", &"e0_dusk_moth", &"p1_asdf", &"p0_moss_turtle", &"p2_forge_golem"], "type": &"round_started" }
round 1 · { "who": &"e1_gloom_wolf", "ap": 3, "extra": 0, "type": &"turn_started" }
round 1 · { "who": &"e1_gloom_wolf", "from": (3, 0), "to": (4, 2), "path": [(4, 0), (4, 1), (4, 2)], "skill": "Run", "type": &"moved" }
round 1 · { "who": &"e1_gloom_wolf", "from": (4, 2), "to": (5, 4), "path": [(5, 2), (5, 3), (5, 4)], "skill": "Run", "type": &"moved" }
round 1 · { "who": &"e1_gloom_wolf", "from": (5, 4), "to": (3, 3), "path": [(5, 3), (4, 3), (3, 3)], "skill": "Run", "type": &"moved" }
round 1 · { "who": &"e2_ember_hawk", "ap": 2, "extra": 0, "type": &"turn_started" }
round 1 · { "who": &"e2_ember_hawk", "from": (1, 1), "to": (1, 3), "path": [(1, 3)], "skill": "Glide", "type": &"moved" }
round 1 · { "who": &"e0_dusk_moth", "ap": 3, "extra": 0, "type": &"turn_started" }
round 1 · { "who": &"e0_dusk_moth", "skill": &"gloom_rift", "cells": [(5, 3), (5, 4), (5, 5)], "type": &"cast" }
round 1 · { "who": &"e0_dusk_moth", "skill": &"gloom_rift", "cells": [(6, 5), (5, 5), (4, 5)], "type": &"cast" }
round 1 · { "who": &"e0_dusk_moth", "from": (5, 1), "to": (4, 3), "path": [(5, 2), (5, 3), (4, 3)], "skill": "Run", "type": &"moved" }
round 1 · { "who": &"p1_asdf", "ap": 3, "extra": 0, "type": &"turn_started" }
round 1 · { "who": &"p1_asdf", "skill": &"asdf_3", "cells": [(3, 4), (4, 4), (2, 4), (3, 5), (3, 3)], "type": &"cast" }
round 1 · { "who": &"e1_gloom_wolf", "units": [&"e0_dusk_moth"], "props": [], "cause": "asdf3", "type": &"collision" }
round 1 · { "target": &"e1_gloom_wolf", "amount": 1, "base": 1, "kind": "collision", "source": "Collision", "by": &"", "trap": false, "type": &"damage" }
round 1 · { "target": &"e0_dusk_moth", "amount": 1, "base": 1, "kind": "collision", "source": "Collision", "by": &"", "trap": false, "type": &"damage" }
round 1 · { "who": &"p1_asdf", "skill": &"asdf_3", "cells": [(4, 4), (5, 4), (3, 4), (4, 5), (4, 3)], "type": &"cast" }
round 1 · { "who": &"e0_dusk_moth", "units": [&"e1_gloom_wolf"], "props": [], "cause": "asdf3", "type": &"collision" }
round 1 · { "target": &"e0_dusk_moth", "amount": 1, "base": 1, "kind": "collision", "source": "Collision", "by": &"", "trap": false, "type": &"damage" }
round 1 · { "target": &"e1_gloom_wolf", "amount": 1, "base": 1, "kind": "collision", "source": "Collision", "by": &"", "trap": false, "type": &"damage" }
round 1 · { "who": &"p1_asdf", "skill": &"asdf_3", "cells": [(3, 4), (4, 4), (2, 4), (3, 5), (3, 3)], "type": &"cast" }
round 1 · { "who": &"e1_gloom_wolf", "units": [&"e0_dusk_moth"], "props": [], "cause": "asdf3", "type": &"collision" }
round 1 · { "target": &"e1_gloom_wolf", "amount": 1, "base": 1, "kind": "collision", "source": "Collision", "by": &"", "trap": false, "type": &"damage" }
round 1 · { "target": &"e0_dusk_moth", "amount": 1, "base": 1, "kind": "collision", "source": "Collision", "by": &"", "trap": false, "type": &"damage" }
round 1 · { "who": &"e0_dusk_moth", "type": &"defeated" }
round 1 · { "who": &"p0_moss_turtle", "ap": 3, "extra": 0, "type": &"turn_started" }
round 1 · { "who": &"p0_moss_turtle", "skill": &"void_pull", "cells": [(1, 3), (2, 4), (2, 3), (3, 3)], "type": &"cast" }
round 1 · { "who": &"e1_gloom_wolf", "from": (3, 3), "to": (2, 3), "cause": "Void Pull", "type": &"displaced" }
round 1 · { "who": &"e2_ember_hawk", "units": [&"e1_gloom_wolf"], "props": [], "cause": "Void Pull", "type": &"collision" }
round 1 · { "target": &"e2_ember_hawk", "amount": 1, "base": 1, "kind": "collision", "source": "Collision", "by": &"", "trap": false, "type": &"damage" }
round 1 · { "target": &"e1_gloom_wolf", "amount": 1, "base": 1, "kind": "collision", "source": "Collision", "by": &"", "trap": false, "type": &"damage" }
round 1 · { "who": &"e1_gloom_wolf", "type": &"defeated" }
round 1 · { "who": &"p0_moss_turtle", "skill": &"bog", "cells": [(0, 3), (0, 2), (1, 3)], "type": &"cast" }
round 1 · { "who": &"e2_ember_hawk", "units": [], "props": [1], "cause": "Bog", "type": &"collision" }
round 1 · { "target": &"e2_ember_hawk", "amount": 1, "base": 1, "kind": "collision", "source": "Collision", "by": &"", "trap": false, "type": &"damage" }
round 1 · { "who": &"p0_moss_turtle", "skill": &"bog", "cells": [(0, 3), (0, 2), (1, 3)], "type": &"cast" }
round 1 · { "who": &"e2_ember_hawk", "units": [], "props": [1], "cause": "Bog", "type": &"collision" }
round 1 · { "target": &"e2_ember_hawk", "amount": 1, "base": 1, "kind": "collision", "source": "Collision", "by": &"", "trap": false, "type": &"damage" }
round 1 · { "who": &"e2_ember_hawk", "type": &"defeated" }
```

#### Run · 3v3 · seed 202000648 · 1 battles

| Field | Value |
|---|---|
| State | 2828adf+S021-tools · content `2026-11-13.1` · kit set `a30a9be42850` |
| Command | `sim.gd -- 1 3v3 202000648 --trace` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `a30a9be42850` |
| Props placed | storm_drum 2.00, wardstone 2.00 (per battle) |
| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 1 | 1 / 0 / 0 / 0 | 1.0 | 3.00 | 1.00 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | well | flank | total |
|---|---|---|---|---|---|---|---|---|---|---|---|
| share | 0 % | 0 % | 0 % | 100 % | 0 % | 0 % | 0 % | 0 % | 0 % | 0 % | 100 % |
| per battle | 0.00 | 0.00 | 0.00 | 10.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 10.00 |

Damage by raw event kind and source (collision rows are collision damage only; no fall reclassification):
| Damage kind | Source | Damage sum | Positive instances |
|---|---|---|---|
| collision | Collision | 10 | 10 |

Skill activations (not later zone ticks; repeats count second and later actor + skill activations within the same turn):
| Skill | Activations | Repeated activations in same turn |
|---|---|---|
| asdf_3 | 3 | 2 |
| bog | 2 | 1 |
| glide | 1 | 0 |
| gloom_rift | 2 | 1 |
| run | 4 | 2 |
| void_pull | 1 | 0 |
Defeats before own first turn: 0 exact; battles with at least one: 0 / 1

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 0 | — | 8 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| asdf | 1 | 100 % |
| forge_golem | 1 | 100 % |
| moss_turtle | 1 | 100 % |
| dusk_moth | 1 | 0 % |
| ember_hawk | 1 | 0 % |
| gloom_wolf | 1 | 0 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| run | 4 | 3 | 1.33 |
| asdf_3 | 3 | 1 | 3.00 |
| bog | 2 | 1 | 2.00 |
| gloom_rift | 2 | 1 | 2.00 |
| glide | 1 | 1 | 1.00 |
| void_pull | 1 | 2 | 0.50 |
| asdf | 0 | 1 | 0.00 |
| asdf_2 | 0 | 1 | 0.00 |
| cinder_dive | 0 | 1 | 0.00 |
| gale | 0 | 2 | 0.00 |
| plant_bamboo | 0 | 1 | 0.00 |
| set_gong | 0 | 1 | 0.00 |
| shove | 0 | 2 | 0.00 |
| snare | 0 | 1 | 0.00 |
| strike_jab | 0 | 2 | 0.00 |
| strike_thrust | 0 | 1 | 0.00 |
| thorn_lash | 0 | 1 | 0.00 |
| thornbed | 0 | 1 | 0.00 |
Step uses (not a kit slot): 0

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 100 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 1; first defeat in round 1.0 (mean); monsters defeated before their own first turn: 0.00 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 100 %, after round 5 in 0 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 1 | 1 | 100.00 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
| 1 | 202000648 | 6264608642343643130 | moss_turtle, asdf, forge_golem | dusk_moth, gloom_wolf, ember_hawk | side 0 | 1 |

**Follow-up:** T13/T40: human play of AP 2 for the current skill family against a one-shot option, or a targeted stat-role intervention. Further experiments including new skills/items/one-shot boosts/maps are explicitly authorized, **no mechanics adopted**. Open review leads only: pull sorting and possible initial push/code payload despite zone cancellation (`CREATE_ZONE` asymmetry), not confirmed bugs. T02/T03: no price approval.

### Raw full blocks — 14 series

Only the Godot startup header is removed.

<!-- Source: godot/tools/control202.txt -->

#### Run · 3v3 · seed 202 · 32 battles

| Field | Value |
|---|---|
| State | 2828adf+S021-tools · content `2026-11-13.1` · kit set `a30a9be42850` |
| Command | `sim.gd -- 32 3v3 202 --paired` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `a30a9be42850` |
| Props placed | banner 0.50, bronze_gong 0.44, clay_urn 0.38, ancestor_tablet 0.31, peach_tree 0.31, totem 0.31, shrine 0.25, storm_drum 0.25, vortex_urn 0.25, stone_lion 0.19, bamboo_stand 0.13, pagoda_column 0.13, paper_lantern 0.13, wardstone 0.13 (per battle) |
| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 32 | 16 / 15 / 1 / 0 | 2.3 | 4.28 | 1.53 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | well | flank | total |
|---|---|---|---|---|---|---|---|---|---|---|---|
| share | 19 % | 0 % | 10 % | 50 % | 0 % | 0 % | 2 % | 0 % | 18 % | 1 % | 100 % |
| per battle | 4.69 | 0.00 | 2.38 | 12.19 | 0.00 | 0.00 | 0.41 | 0.00 | 4.50 | 0.19 | 24.34 |

Damage by raw event kind and source (collision rows are collision damage only; no fall reclassification):
| Damage kind | Source | Damage sum | Positive instances |
|---|---|---|---|
| aftermath | Bamboo Stand | 4 | 4 |
| aftermath | Clay Urn | 9 | 9 |
| collision | Board edge | 63 | 63 |
| collision | Collision | 327 | 311 |
| flank | Surrounded | 6 | 6 |
| ground | Blight | 16 | 16 |
| ground | Lava | 10 | 9 |
| ground | Thornbed | 50 | 42 |
| strike | Jab | 86 | 43 |
| strike | New Skill | 10 | 5 |
| strike | Thorn Lash | 30 | 15 |
| strike | Thrust | 2 | 1 |
| strike | asdf | 22 | 11 |
| well | Dragon Vein | 144 | 144 |

Skill activations (not later zone ticks; repeats count second and later actor + skill activations within the same turn):
| Skill | Activations | Repeated activations in same turn |
|---|---|---|
| asdf | 10 | 0 |
| asdf_2 | 29 | 10 |
| asdf_3 | 40 | 16 |
| bog | 44 | 19 |
| coiling_rift | 19 | 0 |
| fire_trail | 24 | 0 |
| gale | 110 | 45 |
| glide | 30 | 0 |
| gloom_rift | 35 | 14 |
| lava_field | 23 | 3 |
| new_skill | 4 | 0 |
| plant_bamboo | 4 | 0 |
| quake_leap | 25 | 0 |
| run | 121 | 21 |
| set_gong | 1 | 0 |
| shove | 6 | 0 |
| strike_jab | 44 | 0 |
| strike_thrust | 1 | 0 |
| thorn_lash | 15 | 0 |
| thornbed | 29 | 5 |
| void_pull | 97 | 32 |
Defeats before own first turn: 4 exact; battles with at least one: 4 / 32

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 80 | 1.88 | 402 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| gloom_wolf | 16 | 75 % |
| moss_turtle | 19 | 74 % |
| forge_golem | 17 | 71 % |
| asdf | 18 | 56 % |
| thorn_mites | 22 | 50 % |
| grove_wisp | 22 | 45 % |
| dusk_moth | 25 | 36 % |
| blaze_tiger | 18 | 33 % |
| hollow_serpent | 21 | 33 % |
| ember_hawk | 14 | 14 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| run | 121 | 81 | 1.49 |
| gale | 110 | 53 | 2.08 |
| void_pull | 97 | 66 | 1.47 |
| bog | 44 | 19 | 2.32 |
| strike_jab | 44 | 114 | 0.39 |
| asdf_3 | 40 | 18 | 2.22 |
| gloom_rift | 35 | 25 | 1.40 |
| glide | 30 | 36 | 0.83 |
| asdf_2 | 29 | 18 | 1.61 |
| thornbed | 29 | 83 | 0.35 |
| quake_leap | 25 | 22 | 1.14 |
| fire_trail | 24 | 18 | 1.33 |
| lava_field | 23 | 18 | 1.28 |
| coiling_rift | 19 | 21 | 0.90 |
| thorn_lash | 15 | 16 | 0.94 |
| asdf | 10 | 18 | 0.56 |
| shove | 6 | 35 | 0.17 |
| new_skill | 4 | 18 | 0.22 |
| plant_bamboo | 4 | 16 | 0.25 |
| set_gong | 1 | 17 | 0.06 |
| strike_thrust | 1 | 17 | 0.06 |
| cinder_dive | 0 | 14 | 0.00 |
| snare | 0 | 25 | 0.00 |
Step uses (not a kit slot): 25

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 75 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 4; first defeat in round 1.1 (mean); monsters defeated before their own first turn: 0.13 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 3 %, after round 5 in 0 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 1 | 1 | 3.13 % |
| 2 | 23 | 71.88 % |
| 3 | 7 | 21.88 % |
| 4 | 1 | 3.13 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
| 32 | 202000637 | -8400657598842425077 | dusk_moth, gloom_wolf, moss_turtle | thorn_mites, blaze_tiger, grove_wisp | side 0 | 1 |

<!-- Source: godot/tools/once202.txt -->

#### Run · 3v3 · seed 202 · 32 battles

| Field | Value |
|---|---|
| State | 2828adf+S021-tools · content `2026-11-13.1` · kit set `33abaee565d5` |
| Command | `sim.gd -- 32 3v3 202 --variant currentonce --paired` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `33abaee565d5` |
| Props placed | banner 0.50, bronze_gong 0.44, clay_urn 0.38, ancestor_tablet 0.31, peach_tree 0.31, totem 0.31, shrine 0.25, storm_drum 0.25, vortex_urn 0.25, stone_lion 0.19, bamboo_stand 0.13, pagoda_column 0.13, paper_lantern 0.13, wardstone 0.13 (per battle) |
| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |
| Experiment | currentonce (in-memory simulation variants / battle experiment switches) |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 32 | 16 / 16 / 0 / 0 | 2.4 | 4.28 | 1.13 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | well | flank | total |
|---|---|---|---|---|---|---|---|---|---|---|---|
| share | 25 % | 0 % | 11 % | 41 % | 0 % | 0 % | 1 % | 0 % | 20 % | 2 % | 100 % |
| per battle | 6.00 | 0.00 | 2.72 | 10.06 | 0.00 | 0.00 | 0.22 | 0.00 | 4.97 | 0.38 | 24.34 |

Damage by raw event kind and source (collision rows are collision damage only; no fall reclassification):
| Damage kind | Source | Damage sum | Positive instances |
|---|---|---|---|
| aftermath | Bamboo Stand | 2 | 2 |
| aftermath | Clay Urn | 5 | 5 |
| collision | Board edge | 50 | 50 |
| collision | Collision | 272 | 259 |
| flank | Surrounded | 12 | 12 |
| ground | Blight | 15 | 15 |
| ground | Lava | 16 | 13 |
| ground | Thornbed | 56 | 44 |
| strike | Jab | 124 | 62 |
| strike | New Skill | 8 | 4 |
| strike | Thorn Lash | 36 | 18 |
| strike | Thrust | 6 | 3 |
| strike | asdf | 18 | 9 |
| well | Dragon Vein | 159 | 159 |

Skill activations (not later zone ticks; repeats count second and later actor + skill activations within the same turn):
| Skill | Activations | Repeated activations in same turn |
|---|---|---|
| asdf | 9 | 0 |
| asdf_2 | 34 | 13 |
| asdf_3 | 25 | 0 |
| bog | 34 | 0 |
| cinder_dive | 1 | 0 |
| coiling_rift | 14 | 0 |
| fire_trail | 23 | 0 |
| gale | 74 | 0 |
| glide | 40 | 0 |
| gloom_rift | 45 | 17 |
| lava_field | 27 | 6 |
| new_skill | 4 | 0 |
| plant_bamboo | 5 | 0 |
| quake_leap | 28 | 0 |
| run | 126 | 20 |
| set_gong | 2 | 1 |
| shove | 8 | 0 |
| strike_jab | 64 | 0 |
| strike_thrust | 3 | 0 |
| thorn_lash | 18 | 0 |
| thornbed | 45 | 9 |
| void_pull | 61 | 0 |
Defeats before own first turn: 4 exact; battles with at least one: 4 / 32

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 106 | 1.81 | 333 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| gloom_wolf | 16 | 69 % |
| moss_turtle | 19 | 68 % |
| forge_golem | 17 | 65 % |
| thorn_mites | 22 | 64 % |
| asdf | 18 | 61 % |
| grove_wisp | 22 | 50 % |
| dusk_moth | 25 | 36 % |
| blaze_tiger | 18 | 33 % |
| hollow_serpent | 21 | 33 % |
| ember_hawk | 14 | 21 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| run | 126 | 81 | 1.56 |
| gale | 74 | 53 | 1.40 |
| strike_jab | 64 | 114 | 0.56 |
| void_pull | 61 | 66 | 0.92 |
| gloom_rift | 45 | 25 | 1.80 |
| thornbed | 45 | 83 | 0.54 |
| glide | 40 | 36 | 1.11 |
| asdf_2 | 34 | 18 | 1.89 |
| bog | 34 | 19 | 1.79 |
| quake_leap | 28 | 22 | 1.27 |
| lava_field | 27 | 18 | 1.50 |
| asdf_3 | 25 | 18 | 1.39 |
| fire_trail | 23 | 18 | 1.28 |
| thorn_lash | 18 | 16 | 1.13 |
| coiling_rift | 14 | 21 | 0.67 |
| asdf | 9 | 18 | 0.50 |
| shove | 8 | 35 | 0.23 |
| plant_bamboo | 5 | 16 | 0.31 |
| new_skill | 4 | 18 | 0.22 |
| strike_thrust | 3 | 17 | 0.18 |
| set_gong | 2 | 17 | 0.12 |
| cinder_dive | 1 | 14 | 0.07 |
| snare | 0 | 25 | 0.00 |
Step uses (not a kit slot): 75

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 56 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 4; first defeat in round 1.2 (mean); monsters defeated before their own first turn: 0.13 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 6 %, after round 5 in 0 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 1 | 2 | 6.25 % |
| 2 | 16 | 50.00 % |
| 3 | 13 | 40.63 % |
| 4 | 1 | 3.13 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
| 1 | 202000606 | -2774695727287940456 | asdf, dusk_moth, forge_golem | thorn_mites, ember_hawk, grove_wisp | side 0 | 1 |
| 22 | 202000627 | 1744956457527851337 | asdf, ember_hawk, hollow_serpent | grove_wisp, blaze_tiger, dusk_moth | side 0 | 1 |

<!-- Source: godot/tools/ap202.txt -->

#### Run · 3v3 · seed 202 · 32 battles

| Field | Value |
|---|---|
| State | 2828adf+S021-tools · content `2026-11-13.1` · kit set `10212ec4dd2d` |
| Command | `sim.gd -- 32 3v3 202 --variant currentap=2 --paired` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `10212ec4dd2d` |
| Props placed | banner 0.50, bronze_gong 0.44, clay_urn 0.38, ancestor_tablet 0.31, peach_tree 0.31, totem 0.31, shrine 0.25, storm_drum 0.25, vortex_urn 0.25, stone_lion 0.19, bamboo_stand 0.13, pagoda_column 0.13, paper_lantern 0.13, wardstone 0.13 (per battle) |
| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |
| Experiment | currentap=2 (in-memory simulation variants / battle experiment switches) |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 32 | 14 / 17 / 1 / 0 | 2.9 | 4.31 | 1.25 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | well | flank | total |
|---|---|---|---|---|---|---|---|---|---|---|---|
| share | 21 % | 0 % | 11 % | 38 % | 0 % | 0 % | 1 % | 0 % | 25 % | 3 % | 100 % |
| per battle | 5.44 | 0.00 | 2.81 | 9.66 | 0.00 | 0.00 | 0.34 | 0.00 | 6.31 | 0.78 | 25.34 |

Damage by raw event kind and source (collision rows are collision damage only; no fall reclassification):
| Damage kind | Source | Damage sum | Positive instances |
|---|---|---|---|
| aftermath | Bamboo Stand | 1 | 1 |
| aftermath | Clay Urn | 10 | 10 |
| collision | Board edge | 20 | 20 |
| collision | Collision | 289 | 278 |
| flank | Surrounded | 25 | 25 |
| ground | Blight | 28 | 23 |
| ground | Lava | 8 | 8 |
| ground | Thornbed | 54 | 43 |
| strike | Jab | 86 | 43 |
| strike | New Skill | 12 | 6 |
| strike | Thorn Lash | 42 | 21 |
| strike | Thrust | 18 | 9 |
| strike | asdf | 16 | 8 |
| well | Dragon Vein | 202 | 202 |

Skill activations (not later zone ticks; repeats count second and later actor + skill activations within the same turn):
| Skill | Activations | Repeated activations in same turn |
|---|---|---|
| asdf | 7 | 0 |
| asdf_2 | 32 | 4 |
| asdf_3 | 29 | 0 |
| bog | 31 | 0 |
| coiling_rift | 19 | 0 |
| fire_trail | 36 | 0 |
| gale | 53 | 0 |
| glide | 50 | 0 |
| gloom_rift | 53 | 20 |
| lava_field | 33 | 3 |
| new_skill | 6 | 0 |
| plant_bamboo | 3 | 0 |
| quake_leap | 23 | 0 |
| run | 145 | 21 |
| set_gong | 6 | 0 |
| shove | 2 | 0 |
| strike_jab | 44 | 0 |
| strike_thrust | 9 | 0 |
| thorn_lash | 21 | 0 |
| thornbed | 71 | 11 |
| void_pull | 65 | 0 |
Defeats before own first turn: 0 exact; battles with at least one: 0 / 32

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 89 | 1.96 | 363 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| forge_golem | 17 | 82 % |
| thorn_mites | 22 | 68 % |
| blaze_tiger | 18 | 50 % |
| hollow_serpent | 21 | 48 % |
| moss_turtle | 19 | 47 % |
| asdf | 18 | 44 % |
| dusk_moth | 25 | 40 % |
| gloom_wolf | 16 | 38 % |
| ember_hawk | 14 | 36 % |
| grove_wisp | 22 | 32 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| run | 145 | 81 | 1.79 |
| thornbed | 71 | 83 | 0.86 |
| void_pull | 65 | 66 | 0.98 |
| gale | 53 | 53 | 1.00 |
| gloom_rift | 53 | 25 | 2.12 |
| glide | 50 | 36 | 1.39 |
| strike_jab | 44 | 114 | 0.39 |
| fire_trail | 36 | 18 | 2.00 |
| lava_field | 33 | 18 | 1.83 |
| asdf_2 | 32 | 18 | 1.78 |
| bog | 31 | 19 | 1.63 |
| asdf_3 | 29 | 18 | 1.61 |
| quake_leap | 23 | 22 | 1.05 |
| thorn_lash | 21 | 16 | 1.31 |
| coiling_rift | 19 | 21 | 0.90 |
| strike_thrust | 9 | 17 | 0.53 |
| asdf | 7 | 18 | 0.39 |
| new_skill | 6 | 18 | 0.33 |
| set_gong | 6 | 17 | 0.35 |
| plant_bamboo | 3 | 16 | 0.19 |
| shove | 2 | 35 | 0.06 |
| cinder_dive | 0 | 14 | 0.00 |
| snare | 0 | 25 | 0.00 |
Step uses (not a kit slot): 59

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 22 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 4; first defeat in round 1.3 (mean); monsters defeated before their own first turn: 0.00 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 0 %, after round 5 in 0 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 2 | 7 | 21.88 % |
| 3 | 22 | 68.75 % |
| 4 | 3 | 9.38 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
none

<!-- Source: godot/tools/open202.txt -->

#### Run · 3v3 · seed 202 · 32 battles

| Field | Value |
|---|---|
| State | 2828adf+S021-tools · content `2026-11-13.1` · kit set `a30a9be42850` |
| Command | `sim.gd -- 32 3v3 202 --variant openmap --paired` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `a30a9be42850` |
| Props placed | none |
| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |
| Experiment | openmap (in-memory simulation variants / battle experiment switches) |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 32 | 13 / 18 / 1 / 0 | 2.5 | 4.16 | 0.09 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | well | flank | total |
|---|---|---|---|---|---|---|---|---|---|---|---|
| share | 22 % | 0 % | 12 % | 42 % | 0 % | 0 % | 0 % | 0 % | 21 % | 3 % | 100 % |
| per battle | 5.19 | 0.00 | 2.97 | 10.16 | 0.00 | 0.00 | 0.03 | 0.00 | 5.03 | 0.63 | 24.00 |

Damage by raw event kind and source (collision rows are collision damage only; no fall reclassification):
| Damage kind | Source | Damage sum | Positive instances |
|---|---|---|---|
| aftermath | Bamboo Stand | 1 | 1 |
| collision | Board edge | 62 | 62 |
| collision | Collision | 263 | 256 |
| flank | Surrounded | 20 | 20 |
| ground | Blight | 27 | 24 |
| ground | Lava | 6 | 6 |
| ground | Thornbed | 62 | 51 |
| strike | Jab | 92 | 46 |
| strike | New Skill | 10 | 5 |
| strike | Thorn Lash | 40 | 20 |
| strike | Thrust | 8 | 4 |
| strike | asdf | 16 | 8 |
| well | Dragon Vein | 161 | 161 |

Skill activations (not later zone ticks; repeats count second and later actor + skill activations within the same turn):
| Skill | Activations | Repeated activations in same turn |
|---|---|---|
| asdf | 7 | 0 |
| asdf_2 | 28 | 10 |
| asdf_3 | 38 | 13 |
| bog | 43 | 11 |
| cinder_dive | 1 | 0 |
| coiling_rift | 16 | 0 |
| fire_trail | 24 | 0 |
| gale | 103 | 40 |
| glide | 41 | 0 |
| gloom_rift | 50 | 21 |
| lava_field | 18 | 1 |
| new_skill | 3 | 0 |
| plant_bamboo | 8 | 0 |
| quake_leap | 25 | 0 |
| run | 145 | 27 |
| set_gong | 1 | 0 |
| shove | 3 | 0 |
| strike_jab | 46 | 0 |
| strike_thrust | 4 | 0 |
| thorn_lash | 20 | 0 |
| thornbed | 44 | 9 |
| void_pull | 92 | 20 |
Defeats before own first turn: 3 exact; battles with at least one: 3 / 32

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 83 | 2.00 | 414 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| moss_turtle | 19 | 79 % |
| forge_golem | 17 | 76 % |
| gloom_wolf | 16 | 56 % |
| asdf | 18 | 56 % |
| thorn_mites | 22 | 50 % |
| grove_wisp | 22 | 45 % |
| dusk_moth | 25 | 40 % |
| hollow_serpent | 21 | 38 % |
| blaze_tiger | 18 | 22 % |
| ember_hawk | 14 | 21 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| run | 145 | 81 | 1.79 |
| gale | 103 | 53 | 1.94 |
| void_pull | 92 | 66 | 1.39 |
| gloom_rift | 50 | 25 | 2.00 |
| strike_jab | 46 | 114 | 0.40 |
| thornbed | 44 | 83 | 0.53 |
| bog | 43 | 19 | 2.26 |
| glide | 41 | 36 | 1.14 |
| asdf_3 | 38 | 18 | 2.11 |
| asdf_2 | 28 | 18 | 1.56 |
| quake_leap | 25 | 22 | 1.14 |
| fire_trail | 24 | 18 | 1.33 |
| thorn_lash | 20 | 16 | 1.25 |
| lava_field | 18 | 18 | 1.00 |
| coiling_rift | 16 | 21 | 0.76 |
| plant_bamboo | 8 | 16 | 0.50 |
| asdf | 7 | 18 | 0.39 |
| strike_thrust | 4 | 17 | 0.24 |
| new_skill | 3 | 18 | 0.17 |
| shove | 3 | 35 | 0.09 |
| cinder_dive | 1 | 14 | 0.07 |
| set_gong | 1 | 17 | 0.06 |
| snare | 0 | 25 | 0.00 |
Step uses (not a kit slot): 31

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 59 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 5; first defeat in round 1.2 (mean); monsters defeated before their own first turn: 0.09 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 0 %, after round 5 in 0 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 2 | 19 | 59.38 % |
| 3 | 12 | 37.50 % |
| 5 | 1 | 3.13 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
none

<!-- Source: godot/tools/thread202.txt -->

#### Run · 3v3 · seed 202 · 32 battles

| Field | Value |
|---|---|
| State | 2828adf+S021-tools · content `2026-11-13.1` · kit set `a30a9be42850` |
| Command | `sim.gd -- 32 3v3 202 --variant lifethread --paired` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `a30a9be42850` |
| Props placed | banner 0.50, bronze_gong 0.44, clay_urn 0.38, ancestor_tablet 0.31, peach_tree 0.31, totem 0.31, shrine 0.25, storm_drum 0.25, vortex_urn 0.25, stone_lion 0.19, bamboo_stand 0.13, pagoda_column 0.13, paper_lantern 0.13, wardstone 0.13 (per battle) |
| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |
| Experiment | lifethread (in-memory simulation variants / battle experiment switches) |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 32 | 15 / 16 / 1 / 0 | 3.0 | 4.38 | 1.88 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | well | flank | total |
|---|---|---|---|---|---|---|---|---|---|---|---|
| share | 18 % | 0 % | 9 % | 51 % | 0 % | 0 % | 2 % | 0 % | 18 % | 3 % | 100 % |
| per battle | 5.75 | 0.00 | 3.00 | 16.41 | 0.00 | 0.00 | 0.53 | 0.00 | 5.75 | 0.88 | 32.31 |

Damage by raw event kind and source (collision rows are collision damage only; no fall reclassification):
| Damage kind | Source | Damage sum | Positive instances |
|---|---|---|---|
| aftermath | Bamboo Stand | 6 | 6 |
| aftermath | Clay Urn | 11 | 11 |
| collision | Board edge | 70 | 70 |
| collision | Collision | 455 | 437 |
| flank | Surrounded | 28 | 28 |
| ground | Blight | 30 | 25 |
| ground | Lava | 17 | 17 |
| ground | Thornbed | 49 | 43 |
| strike | Jab | 102 | 51 |
| strike | New Skill | 18 | 9 |
| strike | Thorn Lash | 42 | 21 |
| strike | Thrust | 8 | 4 |
| strike | asdf | 14 | 7 |
| well | Dragon Vein | 184 | 184 |

Skill activations (not later zone ticks; repeats count second and later actor + skill activations within the same turn):
| Skill | Activations | Repeated activations in same turn |
|---|---|---|
| asdf | 6 | 0 |
| asdf_2 | 39 | 14 |
| asdf_3 | 49 | 16 |
| bog | 59 | 20 |
| cinder_dive | 1 | 0 |
| coiling_rift | 19 | 0 |
| fire_trail | 22 | 0 |
| gale | 132 | 53 |
| glide | 47 | 0 |
| gloom_rift | 64 | 26 |
| lava_field | 24 | 2 |
| new_skill | 8 | 0 |
| plant_bamboo | 5 | 1 |
| quake_leap | 29 | 0 |
| run | 155 | 29 |
| set_gong | 4 | 1 |
| shove | 3 | 0 |
| strike_jab | 51 | 0 |
| strike_thrust | 3 | 0 |
| thorn_lash | 21 | 0 |
| thornbed | 41 | 13 |
| void_pull | 107 | 30 |
Defeats before own first turn: 0 exact; battles with at least one: 0 / 32

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 92 | 2.00 | 505 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| forge_golem | 17 | 82 % |
| moss_turtle | 19 | 68 % |
| gloom_wolf | 16 | 63 % |
| thorn_mites | 22 | 55 % |
| grove_wisp | 22 | 45 % |
| dusk_moth | 25 | 40 % |
| asdf | 18 | 39 % |
| hollow_serpent | 21 | 38 % |
| ember_hawk | 14 | 29 % |
| blaze_tiger | 18 | 28 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| run | 155 | 81 | 1.91 |
| gale | 132 | 53 | 2.49 |
| void_pull | 107 | 66 | 1.62 |
| gloom_rift | 64 | 25 | 2.56 |
| bog | 59 | 19 | 3.11 |
| strike_jab | 51 | 114 | 0.45 |
| asdf_3 | 49 | 18 | 2.72 |
| glide | 47 | 36 | 1.31 |
| thornbed | 41 | 83 | 0.49 |
| asdf_2 | 39 | 18 | 2.17 |
| quake_leap | 29 | 22 | 1.32 |
| lava_field | 24 | 18 | 1.33 |
| fire_trail | 22 | 18 | 1.22 |
| thorn_lash | 21 | 16 | 1.31 |
| coiling_rift | 19 | 21 | 0.90 |
| new_skill | 8 | 18 | 0.44 |
| asdf | 6 | 18 | 0.33 |
| plant_bamboo | 5 | 16 | 0.31 |
| set_gong | 4 | 17 | 0.24 |
| shove | 3 | 35 | 0.09 |
| strike_thrust | 3 | 17 | 0.18 |
| cinder_dive | 1 | 14 | 0.07 |
| snare | 0 | 25 | 0.00 |
Step uses (not a kit slot): 42

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 25 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 5; first defeat in round 1.4 (mean); monsters defeated before their own first turn: 0.00 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 0 %, after round 5 in 0 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 2 | 8 | 25.00 % |
| 3 | 18 | 56.25 % |
| 4 | 5 | 15.63 % |
| 5 | 1 | 3.13 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
none

<!-- Source: godot/tools/control303.txt -->

#### Run · 3v3 · seed 303 · 32 battles

| Field | Value |
|---|---|
| State | 2828adf+S021-tools · content `2026-11-13.1` · kit set `a30a9be42850` |
| Command | `sim.gd -- 32 3v3 303 --paired` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `a30a9be42850` |
| Props placed | bamboo_stand 0.50, ancestor_tablet 0.44, banner 0.38, paper_lantern 0.38, shrine 0.31, pagoda_column 0.25, wardstone 0.25, bronze_gong 0.19, peach_tree 0.19, totem 0.19, vortex_urn 0.19, clay_urn 0.13, stone_lion 0.13, storm_drum 0.13 (per battle) |
| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 32 | 9 / 22 / 1 / 0 | 2.3 | 4.19 | 1.47 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | well | flank | total |
|---|---|---|---|---|---|---|---|---|---|---|---|
| share | 19 % | 0 % | 11 % | 49 % | 0 % | 0 % | 1 % | 0 % | 18 % | 1 % | 100 % |
| per battle | 4.75 | 0.00 | 2.88 | 12.34 | 0.00 | 0.00 | 0.34 | 0.00 | 4.56 | 0.28 | 25.16 |

Damage by raw event kind and source (collision rows are collision damage only; no fall reclassification):
| Damage kind | Source | Damage sum | Positive instances |
|---|---|---|---|
| aftermath | Bamboo Stand | 9 | 9 |
| aftermath | Clay Urn | 2 | 2 |
| collision | Board edge | 53 | 53 |
| collision | Collision | 342 | 308 |
| flank | Surrounded | 9 | 9 |
| ground | Blight | 18 | 16 |
| ground | Lava | 10 | 10 |
| ground | Thornbed | 64 | 48 |
| strike | Jab | 70 | 35 |
| strike | New Skill | 6 | 3 |
| strike | Thorn Lash | 44 | 22 |
| strike | Thrust | 26 | 13 |
| strike | asdf | 6 | 3 |
| well | Dragon Vein | 146 | 146 |

Skill activations (not later zone ticks; repeats count second and later actor + skill activations within the same turn):
| Skill | Activations | Repeated activations in same turn |
|---|---|---|
| asdf | 3 | 0 |
| asdf_2 | 32 | 13 |
| asdf_3 | 30 | 11 |
| bog | 49 | 21 |
| coiling_rift | 10 | 0 |
| fire_trail | 27 | 0 |
| gale | 93 | 41 |
| glide | 38 | 0 |
| gloom_rift | 31 | 13 |
| lava_field | 25 | 1 |
| new_skill | 3 | 0 |
| plant_bamboo | 6 | 0 |
| quake_leap | 19 | 0 |
| run | 137 | 30 |
| shove | 1 | 0 |
| strike_jab | 37 | 0 |
| strike_thrust | 13 | 0 |
| thorn_lash | 22 | 0 |
| thornbed | 37 | 9 |
| void_pull | 99 | 37 |
Defeats before own first turn: 2 exact; battles with at least one: 2 / 32

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 79 | 1.92 | 380 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| gloom_wolf | 22 | 73 % |
| forge_golem | 20 | 70 % |
| thorn_mites | 17 | 65 % |
| moss_turtle | 18 | 61 % |
| hollow_serpent | 22 | 59 % |
| dusk_moth | 20 | 40 % |
| grove_wisp | 18 | 33 % |
| asdf | 17 | 29 % |
| ember_hawk | 19 | 26 % |
| blaze_tiger | 19 | 21 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| run | 137 | 82 | 1.67 |
| void_pull | 99 | 55 | 1.80 |
| gale | 93 | 57 | 1.63 |
| bog | 49 | 18 | 2.72 |
| glide | 38 | 36 | 1.06 |
| strike_jab | 37 | 115 | 0.32 |
| thornbed | 37 | 74 | 0.50 |
| asdf_2 | 32 | 17 | 1.88 |
| gloom_rift | 31 | 20 | 1.55 |
| asdf_3 | 30 | 17 | 1.76 |
| fire_trail | 27 | 19 | 1.42 |
| lava_field | 25 | 19 | 1.32 |
| thorn_lash | 22 | 22 | 1.00 |
| quake_leap | 19 | 18 | 1.06 |
| strike_thrust | 13 | 20 | 0.65 |
| coiling_rift | 10 | 22 | 0.45 |
| plant_bamboo | 6 | 22 | 0.27 |
| asdf | 3 | 17 | 0.18 |
| new_skill | 3 | 19 | 0.16 |
| shove | 1 | 40 | 0.03 |
| cinder_dive | 0 | 19 | 0.00 |
| set_gong | 0 | 20 | 0.00 |
| snare | 0 | 20 | 0.00 |
Step uses (not a kit slot): 25

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 66 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 3; first defeat in round 1.1 (mean); monsters defeated before their own first turn: 0.06 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 6 %, after round 5 in 0 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 1 | 2 | 6.25 % |
| 2 | 19 | 59.38 % |
| 3 | 11 | 34.38 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
| 10 | 303000918 | -7283128913171301456 | gloom_wolf, dusk_moth, ember_hawk | asdf, hollow_serpent, blaze_tiger | side 1 | 1 |
| 22 | 303000930 | -4700470521847991860 | asdf, grove_wisp, ember_hawk | dusk_moth, moss_turtle, gloom_wolf | side 1 | 1 |

<!-- Source: godot/tools/ap303.txt -->

#### Run · 3v3 · seed 303 · 32 battles

| Field | Value |
|---|---|
| State | 2828adf+S021-tools · content `2026-11-13.1` · kit set `10212ec4dd2d` |
| Command | `sim.gd -- 32 3v3 303 --variant currentap=2 --paired` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `10212ec4dd2d` |
| Props placed | bamboo_stand 0.50, ancestor_tablet 0.44, banner 0.38, paper_lantern 0.38, shrine 0.31, pagoda_column 0.25, wardstone 0.25, bronze_gong 0.19, peach_tree 0.19, totem 0.19, vortex_urn 0.19, clay_urn 0.13, stone_lion 0.13, storm_drum 0.13 (per battle) |
| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |
| Experiment | currentap=2 (in-memory simulation variants / battle experiment switches) |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 32 | 14 / 17 / 1 / 0 | 2.9 | 4.25 | 1.22 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | well | flank | total |
|---|---|---|---|---|---|---|---|---|---|---|---|
| share | 25 % | 0 % | 12 % | 35 % | 0 % | 0 % | 1 % | 0 % | 25 % | 2 % | 100 % |
| per battle | 6.31 | 0.00 | 2.94 | 8.94 | 0.00 | 0.00 | 0.38 | 0.00 | 6.19 | 0.47 | 25.22 |

Damage by raw event kind and source (collision rows are collision damage only; no fall reclassification):
| Damage kind | Source | Damage sum | Positive instances |
|---|---|---|---|
| aftermath | Bamboo Stand | 9 | 9 |
| aftermath | Clay Urn | 3 | 3 |
| collision | Board edge | 26 | 26 |
| collision | Collision | 260 | 228 |
| flank | Surrounded | 15 | 15 |
| ground | Blight | 34 | 29 |
| ground | Lava | 17 | 13 |
| ground | Thornbed | 43 | 42 |
| strike | Jab | 104 | 52 |
| strike | New Skill | 18 | 9 |
| strike | Thorn Lash | 50 | 25 |
| strike | Thrust | 20 | 10 |
| strike | asdf | 10 | 5 |
| well | Dragon Vein | 198 | 198 |

Skill activations (not later zone ticks; repeats count second and later actor + skill activations within the same turn):
| Skill | Activations | Repeated activations in same turn |
|---|---|---|
| asdf | 5 | 0 |
| asdf_2 | 36 | 13 |
| asdf_3 | 22 | 0 |
| bog | 23 | 0 |
| coiling_rift | 23 | 0 |
| fire_trail | 28 | 0 |
| gale | 58 | 0 |
| glide | 46 | 0 |
| gloom_rift | 53 | 21 |
| lava_field | 31 | 3 |
| new_skill | 8 | 0 |
| plant_bamboo | 10 | 0 |
| quake_leap | 20 | 0 |
| run | 157 | 28 |
| set_gong | 7 | 0 |
| shove | 3 | 0 |
| strike_jab | 55 | 0 |
| strike_thrust | 10 | 0 |
| thorn_lash | 27 | 0 |
| thornbed | 54 | 6 |
| void_pull | 58 | 0 |
Defeats before own first turn: 0 exact; battles with at least one: 0 / 32

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 108 | 1.87 | 339 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| forge_golem | 20 | 70 % |
| thorn_mites | 17 | 65 % |
| moss_turtle | 18 | 56 % |
| hollow_serpent | 22 | 55 % |
| gloom_wolf | 22 | 50 % |
| blaze_tiger | 19 | 47 % |
| asdf | 17 | 47 % |
| grove_wisp | 18 | 44 % |
| dusk_moth | 20 | 30 % |
| ember_hawk | 19 | 21 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| run | 157 | 82 | 1.91 |
| gale | 58 | 57 | 1.02 |
| void_pull | 58 | 55 | 1.05 |
| strike_jab | 55 | 115 | 0.48 |
| thornbed | 54 | 74 | 0.73 |
| gloom_rift | 53 | 20 | 2.65 |
| glide | 46 | 36 | 1.28 |
| asdf_2 | 36 | 17 | 2.12 |
| lava_field | 31 | 19 | 1.63 |
| fire_trail | 28 | 19 | 1.47 |
| thorn_lash | 27 | 22 | 1.23 |
| bog | 23 | 18 | 1.28 |
| coiling_rift | 23 | 22 | 1.05 |
| asdf_3 | 22 | 17 | 1.29 |
| quake_leap | 20 | 18 | 1.11 |
| plant_bamboo | 10 | 22 | 0.45 |
| strike_thrust | 10 | 20 | 0.50 |
| new_skill | 8 | 19 | 0.42 |
| set_gong | 7 | 20 | 0.35 |
| asdf | 5 | 17 | 0.29 |
| shove | 3 | 40 | 0.07 |
| cinder_dive | 0 | 19 | 0.00 |
| snare | 0 | 20 | 0.00 |
Step uses (not a kit slot): 70

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 28 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 4; first defeat in round 1.3 (mean); monsters defeated before their own first turn: 0.00 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 0 %, after round 5 in 0 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 2 | 9 | 28.13 % |
| 3 | 18 | 56.25 % |
| 4 | 5 | 15.63 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
none

<!-- Source: godot/tools/thread303.txt -->

#### Run · 3v3 · seed 303 · 32 battles

| Field | Value |
|---|---|
| State | 2828adf+S021-tools · content `2026-11-13.1` · kit set `a30a9be42850` |
| Command | `sim.gd -- 32 3v3 303 --variant lifethread --paired` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `a30a9be42850` |
| Props placed | bamboo_stand 0.50, ancestor_tablet 0.44, banner 0.38, paper_lantern 0.38, shrine 0.31, pagoda_column 0.25, wardstone 0.25, bronze_gong 0.19, peach_tree 0.19, totem 0.19, vortex_urn 0.19, clay_urn 0.13, stone_lion 0.13, storm_drum 0.13 (per battle) |
| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |
| Experiment | lifethread (in-memory simulation variants / battle experiment switches) |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 32 | 14 / 18 / 0 / 0 | 2.8 | 4.31 | 1.63 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | well | flank | total |
|---|---|---|---|---|---|---|---|---|---|---|---|
| share | 20 % | 0 % | 12 % | 47 % | 0 % | 0 % | 3 % | 0 % | 17 % | 2 % | 100 % |
| per battle | 6.31 | 0.00 | 3.91 | 15.09 | 0.00 | 0.00 | 0.84 | 0.00 | 5.47 | 0.66 | 32.28 |

Damage by raw event kind and source (collision rows are collision damage only; no fall reclassification):
| Damage kind | Source | Damage sum | Positive instances |
|---|---|---|---|
| aftermath | Bamboo Stand | 24 | 24 |
| aftermath | Clay Urn | 3 | 3 |
| collision | Board edge | 58 | 58 |
| collision | Collision | 425 | 379 |
| flank | Surrounded | 21 | 21 |
| ground | Blight | 36 | 32 |
| ground | Lava | 12 | 12 |
| ground | Thornbed | 77 | 70 |
| strike | Jab | 106 | 53 |
| strike | New Skill | 14 | 7 |
| strike | Thorn Lash | 56 | 28 |
| strike | Thrust | 20 | 10 |
| strike | asdf | 6 | 3 |
| well | Dragon Vein | 175 | 175 |

Skill activations (not later zone ticks; repeats count second and later actor + skill activations within the same turn):
| Skill | Activations | Repeated activations in same turn |
|---|---|---|
| asdf | 3 | 0 |
| asdf_2 | 41 | 13 |
| asdf_3 | 42 | 14 |
| bog | 49 | 21 |
| coiling_rift | 15 | 0 |
| fire_trail | 26 | 0 |
| gale | 141 | 64 |
| glide | 48 | 0 |
| gloom_rift | 44 | 15 |
| lava_field | 30 | 4 |
| new_skill | 6 | 0 |
| plant_bamboo | 12 | 0 |
| quake_leap | 22 | 0 |
| run | 157 | 36 |
| set_gong | 1 | 0 |
| shove | 2 | 0 |
| strike_jab | 54 | 0 |
| strike_thrust | 10 | 0 |
| thorn_lash | 29 | 0 |
| thornbed | 48 | 10 |
| void_pull | 113 | 40 |
Defeats before own first turn: 1 exact; battles with at least one: 1 / 32

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 104 | 1.94 | 495 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| forge_golem | 20 | 65 % |
| thorn_mites | 17 | 65 % |
| gloom_wolf | 22 | 59 % |
| grove_wisp | 18 | 56 % |
| asdf | 17 | 53 % |
| moss_turtle | 18 | 50 % |
| blaze_tiger | 19 | 47 % |
| hollow_serpent | 22 | 41 % |
| dusk_moth | 20 | 40 % |
| ember_hawk | 19 | 26 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| run | 157 | 82 | 1.91 |
| gale | 141 | 57 | 2.47 |
| void_pull | 113 | 55 | 2.05 |
| strike_jab | 54 | 115 | 0.47 |
| bog | 49 | 18 | 2.72 |
| glide | 48 | 36 | 1.33 |
| thornbed | 48 | 74 | 0.65 |
| gloom_rift | 44 | 20 | 2.20 |
| asdf_3 | 42 | 17 | 2.47 |
| asdf_2 | 41 | 17 | 2.41 |
| lava_field | 30 | 19 | 1.58 |
| thorn_lash | 29 | 22 | 1.32 |
| fire_trail | 26 | 19 | 1.37 |
| quake_leap | 22 | 18 | 1.22 |
| coiling_rift | 15 | 22 | 0.68 |
| plant_bamboo | 12 | 22 | 0.55 |
| strike_thrust | 10 | 20 | 0.50 |
| new_skill | 6 | 19 | 0.32 |
| asdf | 3 | 17 | 0.18 |
| shove | 2 | 40 | 0.05 |
| set_gong | 1 | 20 | 0.05 |
| cinder_dive | 0 | 19 | 0.00 |
| snare | 0 | 20 | 0.00 |
Step uses (not a kit slot): 35

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 31 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 4; first defeat in round 1.3 (mean); monsters defeated before their own first turn: 0.03 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 0 %, after round 5 in 0 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 2 | 10 | 31.25 % |
| 3 | 18 | 56.25 % |
| 4 | 4 | 12.50 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
none

<!-- Source: godot/tools/mixcontrol303.txt -->

#### Run · 3v3 · seed 303 · 80 battles

| Field | Value |
|---|---|
| State | 2828adf+S021-tools · content `2026-11-13.1` · kit set `a30a9be42850` |
| Command | `sim.gd -- 80 3v3 303 --variant mixstats --paired` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `a30a9be42850` |
| Props placed | bamboo_stand 0.38, ancestor_tablet 0.33, banner 0.33, shrine 0.33, pagoda_column 0.30, vortex_urn 0.28, wardstone 0.28, peach_tree 0.25, storm_drum 0.25, paper_lantern 0.23, totem 0.23, bronze_gong 0.20, clay_urn 0.15, stone_lion 0.15 (per battle) |
| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |
| Experiment | mixstats (in-memory simulation variants / battle experiment switches) |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 80 | 37 / 42 / 1 / 0 | 2.5 | 4.21 | 2.08 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | well | flank | total |
|---|---|---|---|---|---|---|---|---|---|---|---|
| share | 18 % | 0 % | 11 % | 49 % | 0 % | 0 % | 2 % | 0 % | 18 % | 2 % | 100 % |
| per battle | 5.28 | 0.00 | 3.21 | 14.01 | 0.00 | 0.00 | 0.45 | 0.00 | 5.22 | 0.69 | 28.86 |

Damage by raw event kind and source (collision rows are collision damage only; no fall reclassification):
| Damage kind | Source | Damage sum | Positive instances |
|---|---|---|---|
| aftermath | Bamboo Stand | 28 | 28 |
| aftermath | Clay Urn | 8 | 8 |
| collision | Board edge | 103 | 103 |
| collision | Collision | 1018 | 934 |
| flank | Surrounded | 55 | 55 |
| ground | Blight | 58 | 43 |
| ground | Lava | 53 | 46 |
| ground | Thornbed | 146 | 127 |
| strike | Jab | 294 | 147 |
| strike | New Skill | 14 | 7 |
| strike | Thorn Lash | 88 | 44 |
| strike | Thrust | 16 | 8 |
| strike | asdf | 10 | 5 |
| well | Dragon Vein | 418 | 418 |

Skill activations (not later zone ticks; repeats count second and later actor + skill activations within the same turn):
| Skill | Activations | Repeated activations in same turn |
|---|---|---|
| asdf | 5 | 0 |
| asdf_2 | 75 | 18 |
| asdf_3 | 168 | 71 |
| bog | 77 | 26 |
| cinder_dive | 11 | 3 |
| coiling_rift | 18 | 0 |
| fire_trail | 68 | 0 |
| gale | 386 | 169 |
| glide | 71 | 0 |
| gloom_rift | 100 | 31 |
| lava_field | 78 | 23 |
| new_skill | 7 | 0 |
| plant_bamboo | 36 | 3 |
| quake_leap | 60 | 0 |
| run | 335 | 79 |
| set_gong | 10 | 0 |
| shove | 8 | 0 |
| snare | 1 | 0 |
| strike_jab | 149 | 0 |
| strike_thrust | 8 | 0 |
| thorn_lash | 45 | 0 |
| thornbed | 93 | 11 |
| void_pull | 263 | 78 |
Defeats before own first turn: 1 exact; battles with at least one: 1 / 80

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 222 | 1.90 | 1241 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| asdf | 46 | 61 % |
| thorn_mites | 43 | 58 % |
| gloom_wolf | 51 | 57 % |
| dusk_moth | 51 | 53 % |
| moss_turtle | 45 | 51 % |
| forge_golem | 42 | 50 % |
| hollow_serpent | 54 | 48 % |
| ember_hawk | 48 | 46 % |
| grove_wisp | 51 | 43 % |
| blaze_tiger | 49 | 29 % |

| Random draw (mixkits / mixskills / mixstats) | Played | Won | Win rate |
|---|---|---|---|
| stat:ap=2 | 236 | 109 | 46.19 % |
| stat:ap=3 | 244 | 128 | 52.46 % |
| stat:hp=3 | 63 | 32 | 50.79 % |
| stat:hp=4 | 71 | 25 | 35.21 % |
| stat:hp=5 | 93 | 41 | 44.09 % |
| stat:hp=6 | 90 | 44 | 48.89 % |
| stat:hp=7 | 88 | 53 | 60.23 % |
| stat:hp=8 | 75 | 42 | 56.00 % |
| stat:init=1 | 52 | 29 | 55.77 % |
| stat:init=2 | 56 | 26 | 46.43 % |
| stat:init=3 | 53 | 28 | 52.83 % |
| stat:init=4 | 50 | 25 | 50.00 % |
| stat:init=5 | 48 | 27 | 56.25 % |
| stat:init=6 | 55 | 24 | 43.64 % |
| stat:init=7 | 61 | 26 | 42.62 % |
| stat:init=8 | 58 | 26 | 44.83 % |
| stat:init=9 | 47 | 26 | 55.32 % |
| stat:move=1 | 103 | 47 | 45.63 % |
| stat:move=2 | 105 | 48 | 45.71 % |
| stat:move=3 | 99 | 48 | 48.48 % |
| stat:move=4 | 105 | 60 | 57.14 % |
| stat:move=5 | 68 | 34 | 50.00 % |
| stat:reach=2 | 157 | 69 | 43.95 % |
| stat:reach=3 | 156 | 88 | 56.41 % |
| stat:reach=4 | 167 | 80 | 47.90 % |
| stat:tpr=1 | 235 | 100 | 42.55 % |
| stat:tpr=2 | 245 | 137 | 55.92 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| gale | 386 | 141 | 2.74 |
| run | 335 | 201 | 1.67 |
| void_pull | 263 | 139 | 1.89 |
| asdf_3 | 168 | 46 | 3.65 |
| strike_jab | 149 | 287 | 0.52 |
| gloom_rift | 100 | 51 | 1.96 |
| thornbed | 93 | 194 | 0.48 |
| lava_field | 78 | 49 | 1.59 |
| bog | 77 | 45 | 1.71 |
| asdf_2 | 75 | 46 | 1.63 |
| glide | 71 | 91 | 0.78 |
| fire_trail | 68 | 49 | 1.39 |
| quake_leap | 60 | 51 | 1.18 |
| thorn_lash | 45 | 51 | 0.88 |
| plant_bamboo | 36 | 51 | 0.71 |
| coiling_rift | 18 | 54 | 0.33 |
| cinder_dive | 11 | 48 | 0.23 |
| set_gong | 10 | 42 | 0.24 |
| shove | 8 | 96 | 0.08 |
| strike_thrust | 8 | 42 | 0.19 |
| new_skill | 7 | 49 | 0.14 |
| asdf | 5 | 46 | 0.11 |
| snare | 1 | 51 | 0.02 |
Step uses (not a kit slot): 119

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 55 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 5; first defeat in round 1.5 (mean); monsters defeated before their own first turn: 0.01 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 1 %, after round 5 in 0 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 1 | 1 | 1.25 % |
| 2 | 43 | 53.75 % |
| 3 | 32 | 40.00 % |
| 4 | 3 | 3.75 % |
| 5 | 1 | 1.25 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
| 3 | 303000911 | 3508149741029802357 | grove_wisp, ember_hawk, moss_turtle | forge_golem, dusk_moth, thorn_mites | side 1 | 1 |

<!-- Source: godot/tools/mixap303.txt -->

#### Run · 3v3 · seed 303 · 80 battles

| Field | Value |
|---|---|
| State | 2828adf+S021-tools · content `2026-11-13.1` · kit set `10212ec4dd2d` |
| Command | `sim.gd -- 80 3v3 303 --variant currentap=2,mixstats --paired` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `10212ec4dd2d` |
| Props placed | bamboo_stand 0.38, ancestor_tablet 0.33, banner 0.33, shrine 0.33, pagoda_column 0.30, vortex_urn 0.28, wardstone 0.28, peach_tree 0.25, storm_drum 0.25, paper_lantern 0.23, totem 0.23, bronze_gong 0.20, clay_urn 0.15, stone_lion 0.15 (per battle) |
| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |
| Experiment | currentap=2,mixstats (in-memory simulation variants / battle experiment switches) |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 80 | 48 / 31 / 1 / 0 | 3.0 | 4.22 | 1.38 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | well | flank | total |
|---|---|---|---|---|---|---|---|---|---|---|---|
| share | 25 % | 0 % | 14 % | 34 % | 0 % | 0 % | 1 % | 0 % | 23 % | 2 % | 100 % |
| per battle | 7.22 | 0.00 | 4.09 | 9.94 | 0.00 | 0.00 | 0.36 | 0.00 | 6.71 | 0.68 | 29.00 |

Damage by raw event kind and source (collision rows are collision damage only; no fall reclassification):
| Damage kind | Source | Damage sum | Positive instances |
|---|---|---|---|
| aftermath | Bamboo Stand | 20 | 20 |
| aftermath | Clay Urn | 9 | 9 |
| collision | Board edge | 70 | 70 |
| collision | Collision | 725 | 654 |
| flank | Surrounded | 54 | 54 |
| ground | Blight | 93 | 69 |
| ground | Lava | 58 | 50 |
| ground | Thornbed | 176 | 146 |
| strike | Jab | 402 | 201 |
| strike | New Skill | 30 | 15 |
| strike | Thorn Lash | 108 | 54 |
| strike | Thrust | 14 | 7 |
| strike | asdf | 24 | 12 |
| well | Dragon Vein | 537 | 537 |

Skill activations (not later zone ticks; repeats count second and later actor + skill activations within the same turn):
| Skill | Activations | Repeated activations in same turn |
|---|---|---|
| asdf | 12 | 0 |
| asdf_2 | 84 | 24 |
| asdf_3 | 82 | 0 |
| bog | 60 | 0 |
| cinder_dive | 22 | 1 |
| coiling_rift | 32 | 0 |
| fire_trail | 72 | 0 |
| gale | 237 | 0 |
| glide | 75 | 0 |
| gloom_rift | 139 | 40 |
| lava_field | 74 | 22 |
| new_skill | 14 | 0 |
| plant_bamboo | 56 | 8 |
| quake_leap | 63 | 0 |
| run | 386 | 85 |
| set_gong | 22 | 0 |
| shove | 10 | 0 |
| snare | 2 | 0 |
| strike_jab | 206 | 0 |
| strike_thrust | 6 | 0 |
| thorn_lash | 54 | 0 |
| thornbed | 183 | 15 |
| void_pull | 163 | 0 |
Defeats before own first turn: 1 exact; battles with at least one: 1 / 80

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 302 | 1.91 | 1072 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| gloom_wolf | 51 | 59 % |
| forge_golem | 42 | 57 % |
| hollow_serpent | 54 | 56 % |
| blaze_tiger | 49 | 55 % |
| thorn_mites | 43 | 51 % |
| ember_hawk | 48 | 48 % |
| asdf | 46 | 48 % |
| moss_turtle | 45 | 44 % |
| dusk_moth | 51 | 39 % |
| grove_wisp | 51 | 37 % |

| Random draw (mixkits / mixskills / mixstats) | Played | Won | Win rate |
|---|---|---|---|
| stat:ap=2 | 236 | 107 | 45.34 % |
| stat:ap=3 | 244 | 130 | 53.28 % |
| stat:hp=3 | 63 | 22 | 34.92 % |
| stat:hp=4 | 71 | 31 | 43.66 % |
| stat:hp=5 | 93 | 39 | 41.94 % |
| stat:hp=6 | 90 | 52 | 57.78 % |
| stat:hp=7 | 88 | 54 | 61.36 % |
| stat:hp=8 | 75 | 39 | 52.00 % |
| stat:init=1 | 52 | 32 | 61.54 % |
| stat:init=2 | 56 | 26 | 46.43 % |
| stat:init=3 | 53 | 26 | 49.06 % |
| stat:init=4 | 50 | 22 | 44.00 % |
| stat:init=5 | 48 | 26 | 54.17 % |
| stat:init=6 | 55 | 25 | 45.45 % |
| stat:init=7 | 61 | 28 | 45.90 % |
| stat:init=8 | 58 | 29 | 50.00 % |
| stat:init=9 | 47 | 23 | 48.94 % |
| stat:move=1 | 103 | 44 | 42.72 % |
| stat:move=2 | 105 | 52 | 49.52 % |
| stat:move=3 | 99 | 52 | 52.53 % |
| stat:move=4 | 105 | 59 | 56.19 % |
| stat:move=5 | 68 | 30 | 44.12 % |
| stat:reach=2 | 157 | 77 | 49.04 % |
| stat:reach=3 | 156 | 73 | 46.79 % |
| stat:reach=4 | 167 | 87 | 52.10 % |
| stat:tpr=1 | 235 | 110 | 46.81 % |
| stat:tpr=2 | 245 | 127 | 51.84 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| run | 386 | 201 | 1.92 |
| gale | 237 | 141 | 1.68 |
| strike_jab | 206 | 287 | 0.72 |
| thornbed | 183 | 194 | 0.94 |
| void_pull | 163 | 139 | 1.17 |
| gloom_rift | 139 | 51 | 2.73 |
| asdf_2 | 84 | 46 | 1.83 |
| asdf_3 | 82 | 46 | 1.78 |
| glide | 75 | 91 | 0.82 |
| lava_field | 74 | 49 | 1.51 |
| fire_trail | 72 | 49 | 1.47 |
| quake_leap | 63 | 51 | 1.24 |
| bog | 60 | 45 | 1.33 |
| plant_bamboo | 56 | 51 | 1.10 |
| thorn_lash | 54 | 51 | 1.06 |
| coiling_rift | 32 | 54 | 0.59 |
| cinder_dive | 22 | 48 | 0.46 |
| set_gong | 22 | 42 | 0.52 |
| new_skill | 14 | 49 | 0.29 |
| asdf | 12 | 46 | 0.26 |
| shove | 10 | 96 | 0.10 |
| strike_thrust | 6 | 42 | 0.14 |
| snare | 2 | 51 | 0.04 |
Step uses (not a kit slot): 228

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 19 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 6; first defeat in round 1.8 (mean); monsters defeated before their own first turn: 0.01 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 0 %, after round 5 in 1 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 2 | 15 | 18.75 % |
| 3 | 50 | 62.50 % |
| 4 | 12 | 15.00 % |
| 5 | 2 | 2.50 % |
| 6 | 1 | 1.25 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
| 58 | 303000966 | 3047504652121936928 | moss_turtle, grove_wisp, dusk_moth | gloom_wolf, asdf, hollow_serpent | side 1 | 6 |

<!-- Source: godot/tools/mixthread303.txt -->

#### Run · 3v3 · seed 303 · 80 battles

| Field | Value |
|---|---|
| State | 2828adf+S021-tools · content `2026-11-13.1` · kit set `a30a9be42850` |
| Command | `sim.gd -- 80 3v3 303 --variant lifethread,mixstats --paired` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `a30a9be42850` |
| Props placed | bamboo_stand 0.38, ancestor_tablet 0.33, banner 0.33, shrine 0.33, pagoda_column 0.30, vortex_urn 0.28, wardstone 0.28, peach_tree 0.25, storm_drum 0.25, paper_lantern 0.23, totem 0.23, bronze_gong 0.20, clay_urn 0.15, stone_lion 0.15 (per battle) |
| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |
| Experiment | lifethread,mixstats (in-memory simulation variants / battle experiment switches) |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 80 | 47 / 33 / 0 / 0 | 3.0 | 4.17 | 2.09 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | well | flank | total |
|---|---|---|---|---|---|---|---|---|---|---|---|
| share | 17 % | 0 % | 12 % | 49 % | 0 % | 0 % | 2 % | 0 % | 17 % | 3 % | 100 % |
| per battle | 6.38 | 0.00 | 4.28 | 18.04 | 0.00 | 0.00 | 0.75 | 0.00 | 6.09 | 1.10 | 36.63 |

Damage by raw event kind and source (collision rows are collision damage only; no fall reclassification):
| Damage kind | Source | Damage sum | Positive instances |
|---|---|---|---|
| aftermath | Bamboo Stand | 51 | 51 |
| aftermath | Clay Urn | 9 | 9 |
| collision | Board edge | 144 | 144 |
| collision | Collision | 1299 | 1201 |
| flank | Surrounded | 88 | 88 |
| ground | Blight | 96 | 71 |
| ground | Lava | 82 | 69 |
| ground | Thornbed | 164 | 144 |
| strike | Jab | 350 | 175 |
| strike | New Skill | 28 | 14 |
| strike | Thorn Lash | 108 | 54 |
| strike | Thrust | 8 | 4 |
| strike | asdf | 16 | 8 |
| well | Dragon Vein | 487 | 487 |

Skill activations (not later zone ticks; repeats count second and later actor + skill activations within the same turn):
| Skill | Activations | Repeated activations in same turn |
|---|---|---|
| asdf | 8 | 0 |
| asdf_2 | 78 | 20 |
| asdf_3 | 174 | 74 |
| bog | 107 | 35 |
| cinder_dive | 14 | 2 |
| coiling_rift | 28 | 0 |
| fire_trail | 60 | 0 |
| gale | 506 | 220 |
| glide | 89 | 0 |
| gloom_rift | 145 | 47 |
| lava_field | 81 | 26 |
| new_skill | 13 | 0 |
| plant_bamboo | 57 | 10 |
| quake_leap | 75 | 0 |
| run | 374 | 84 |
| set_gong | 11 | 0 |
| shove | 12 | 0 |
| snare | 2 | 0 |
| strike_jab | 176 | 0 |
| strike_thrust | 4 | 0 |
| thorn_lash | 57 | 0 |
| thornbed | 96 | 6 |
| void_pull | 290 | 78 |
Defeats before own first turn: 0 exact; battles with at least one: 0 / 80

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 270 | 1.89 | 1511 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| gloom_wolf | 51 | 67 % |
| thorn_mites | 43 | 60 % |
| forge_golem | 42 | 60 % |
| moss_turtle | 45 | 53 % |
| dusk_moth | 51 | 51 % |
| asdf | 46 | 50 % |
| hollow_serpent | 54 | 46 % |
| grove_wisp | 51 | 43 % |
| ember_hawk | 48 | 40 % |
| blaze_tiger | 49 | 33 % |

| Random draw (mixkits / mixskills / mixstats) | Played | Won | Win rate |
|---|---|---|---|
| stat:ap=2 | 236 | 105 | 44.49 % |
| stat:ap=3 | 244 | 135 | 55.33 % |
| stat:hp=3 | 63 | 25 | 39.68 % |
| stat:hp=4 | 71 | 30 | 42.25 % |
| stat:hp=5 | 93 | 40 | 43.01 % |
| stat:hp=6 | 90 | 46 | 51.11 % |
| stat:hp=7 | 88 | 59 | 67.05 % |
| stat:hp=8 | 75 | 40 | 53.33 % |
| stat:init=1 | 52 | 28 | 53.85 % |
| stat:init=2 | 56 | 26 | 46.43 % |
| stat:init=3 | 53 | 32 | 60.38 % |
| stat:init=4 | 50 | 18 | 36.00 % |
| stat:init=5 | 48 | 26 | 54.17 % |
| stat:init=6 | 55 | 25 | 45.45 % |
| stat:init=7 | 61 | 30 | 49.18 % |
| stat:init=8 | 58 | 29 | 50.00 % |
| stat:init=9 | 47 | 26 | 55.32 % |
| stat:move=1 | 103 | 56 | 54.37 % |
| stat:move=2 | 105 | 46 | 43.81 % |
| stat:move=3 | 99 | 49 | 49.49 % |
| stat:move=4 | 105 | 57 | 54.29 % |
| stat:move=5 | 68 | 32 | 47.06 % |
| stat:reach=2 | 157 | 73 | 46.50 % |
| stat:reach=3 | 156 | 83 | 53.21 % |
| stat:reach=4 | 167 | 84 | 50.30 % |
| stat:tpr=1 | 235 | 103 | 43.83 % |
| stat:tpr=2 | 245 | 137 | 55.92 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| gale | 506 | 141 | 3.59 |
| run | 374 | 201 | 1.86 |
| void_pull | 290 | 139 | 2.09 |
| strike_jab | 176 | 287 | 0.61 |
| asdf_3 | 174 | 46 | 3.78 |
| gloom_rift | 145 | 51 | 2.84 |
| bog | 107 | 45 | 2.38 |
| thornbed | 96 | 194 | 0.49 |
| glide | 89 | 91 | 0.98 |
| lava_field | 81 | 49 | 1.65 |
| asdf_2 | 78 | 46 | 1.70 |
| quake_leap | 75 | 51 | 1.47 |
| fire_trail | 60 | 49 | 1.22 |
| plant_bamboo | 57 | 51 | 1.12 |
| thorn_lash | 57 | 51 | 1.12 |
| coiling_rift | 28 | 54 | 0.52 |
| cinder_dive | 14 | 48 | 0.29 |
| new_skill | 13 | 49 | 0.27 |
| shove | 12 | 96 | 0.13 |
| set_gong | 11 | 42 | 0.26 |
| asdf | 8 | 46 | 0.17 |
| strike_thrust | 4 | 42 | 0.10 |
| snare | 2 | 51 | 0.04 |
Step uses (not a kit slot): 145

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 19 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 5; first defeat in round 1.8 (mean); monsters defeated before their own first turn: 0.00 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 0 %, after round 5 in 0 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 2 | 15 | 18.75 % |
| 3 | 53 | 66.25 % |
| 4 | 11 | 13.75 % |
| 5 | 1 | 1.25 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
none

<!-- Source: godot/tools/tacticcontrol303.txt -->

#### Run · 3v3 · seed 303 · 4 battles

| Field | Value |
|---|---|
| State | 2828adf+S021-tools · content `2026-11-13.1` · kit set `a30a9be42850` |
| Command | `sim.gd -- 4 3v3 303 --bot-a tactic --bot-b tactic --paired` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `a30a9be42850` |
| Props placed | bronze_gong 1.00, bamboo_stand 0.50, paper_lantern 0.50, shrine 0.50, storm_drum 0.50, vortex_urn 0.50, wardstone 0.50 (per battle) |
| Loadout / AI | no tamer skills · bots `tactic` (side 0) and `tactic` (side 1), tools/lib/sim_bots.gd |
| Experiment | bots tactic (in-memory simulation variants / battle experiment switches) |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 4 | 2 / 2 / 0 / 0 | 2.8 | 4.50 | 1.25 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | well | flank | total |
|---|---|---|---|---|---|---|---|---|---|---|---|
| share | 16 % | 0 % | 5 % | 55 % | 0 % | 0 % | 1 % | 0 % | 21 % | 3 % | 100 % |
| per battle | 4.50 | 0.00 | 1.25 | 15.25 | 0.00 | 0.00 | 0.25 | 0.00 | 5.75 | 0.75 | 27.75 |

Damage by raw event kind and source (collision rows are collision damage only; no fall reclassification):
| Damage kind | Source | Damage sum | Positive instances |
|---|---|---|---|
| aftermath | Bamboo Stand | 1 | 1 |
| collision | Board edge | 4 | 4 |
| collision | Collision | 57 | 53 |
| flank | Surrounded | 3 | 3 |
| ground | Lava | 1 | 1 |
| ground | Thornbed | 4 | 4 |
| strike | Jab | 16 | 8 |
| strike | Thorn Lash | 2 | 1 |
| well | Dragon Vein | 23 | 23 |

Skill activations (not later zone ticks; repeats count second and later actor + skill activations within the same turn):
| Skill | Activations | Repeated activations in same turn |
|---|---|---|
| asdf_2 | 5 | 1 |
| asdf_3 | 9 | 4 |
| bog | 5 | 2 |
| fire_trail | 4 | 0 |
| gale | 15 | 3 |
| glide | 5 | 0 |
| gloom_rift | 1 | 0 |
| lava_field | 5 | 1 |
| quake_leap | 3 | 0 |
| run | 16 | 4 |
| set_gong | 1 | 0 |
| strike_jab | 8 | 0 |
| thorn_lash | 1 | 0 |
| thornbed | 2 | 0 |
| void_pull | 8 | 1 |
Defeats before own first turn: 0 exact; battles with at least one: 0 / 4

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 9 | 2.00 | 46 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| forge_golem | 2 | 100 % |
| asdf | 3 | 67 % |
| thorn_mites | 3 | 67 % |
| blaze_tiger | 2 | 50 % |
| dusk_moth | 2 | 50 % |
| moss_turtle | 2 | 50 % |
| ember_hawk | 3 | 33 % |
| grove_wisp | 3 | 33 % |
| hollow_serpent | 3 | 33 % |
| gloom_wolf | 1 | 0 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| run | 16 | 8 | 2.00 |
| gale | 15 | 8 | 1.88 |
| asdf_3 | 9 | 3 | 3.00 |
| strike_jab | 8 | 16 | 0.50 |
| void_pull | 8 | 7 | 1.14 |
| asdf_2 | 5 | 3 | 1.67 |
| bog | 5 | 2 | 2.50 |
| glide | 5 | 6 | 0.83 |
| lava_field | 5 | 2 | 2.50 |
| fire_trail | 4 | 2 | 2.00 |
| quake_leap | 3 | 3 | 1.00 |
| thornbed | 2 | 12 | 0.17 |
| gloom_rift | 1 | 2 | 0.50 |
| set_gong | 1 | 2 | 0.50 |
| thorn_lash | 1 | 1 | 1.00 |
| asdf | 0 | 3 | 0.00 |
| cinder_dive | 0 | 3 | 0.00 |
| coiling_rift | 0 | 3 | 0.00 |
| new_skill | 0 | 2 | 0.00 |
| plant_bamboo | 0 | 1 | 0.00 |
| shove | 0 | 3 | 0.00 |
| snare | 0 | 2 | 0.00 |
| strike_thrust | 0 | 2 | 0.00 |
Step uses (not a kit slot): 13

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 50 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 4; first defeat in round 1.0 (mean); monsters defeated before their own first turn: 0.00 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 0 %, after round 5 in 0 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 2 | 2 | 50.00 % |
| 3 | 1 | 25.00 % |
| 4 | 1 | 25.00 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
none

<!-- Source: godot/tools/tacticap303.txt -->

#### Run · 3v3 · seed 303 · 4 battles

| Field | Value |
|---|---|
| State | 2828adf+S021-tools · content `2026-11-13.1` · kit set `10212ec4dd2d` |
| Command | `sim.gd -- 4 3v3 303 --bot-a tactic --bot-b tactic --variant currentap=2 --paired` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `10212ec4dd2d` |
| Props placed | bronze_gong 1.00, bamboo_stand 0.50, paper_lantern 0.50, shrine 0.50, storm_drum 0.50, vortex_urn 0.50, wardstone 0.50 (per battle) |
| Loadout / AI | no tamer skills · bots `tactic` (side 0) and `tactic` (side 1), tools/lib/sim_bots.gd |
| Experiment | currentap=2 + bots tactic (in-memory simulation variants / battle experiment switches) |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 4 | 0 / 4 / 0 / 0 | 2.8 | 4.50 | 1.75 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | well | flank | total |
|---|---|---|---|---|---|---|---|---|---|---|---|
| share | 17 % | 0 % | 11 % | 41 % | 0 % | 0 % | 2 % | 0 % | 24 % | 5 % | 100 % |
| per battle | 4.50 | 0.00 | 3.00 | 10.75 | 0.00 | 0.00 | 0.50 | 0.00 | 6.25 | 1.25 | 26.25 |

Damage by raw event kind and source (collision rows are collision damage only; no fall reclassification):
| Damage kind | Source | Damage sum | Positive instances |
|---|---|---|---|
| aftermath | Bamboo Stand | 2 | 2 |
| collision | Collision | 43 | 38 |
| flank | Surrounded | 5 | 5 |
| ground | Blight | 1 | 1 |
| ground | Lava | 1 | 1 |
| ground | Thornbed | 10 | 7 |
| strike | Jab | 18 | 9 |
| well | Dragon Vein | 25 | 25 |

Skill activations (not later zone ticks; repeats count second and later actor + skill activations within the same turn):
| Skill | Activations | Repeated activations in same turn |
|---|---|---|
| asdf_2 | 10 | 5 |
| asdf_3 | 2 | 0 |
| bog | 2 | 0 |
| cinder_dive | 2 | 1 |
| coiling_rift | 1 | 0 |
| fire_trail | 2 | 0 |
| gale | 6 | 0 |
| glide | 7 | 0 |
| gloom_rift | 4 | 1 |
| lava_field | 3 | 0 |
| plant_bamboo | 2 | 1 |
| quake_leap | 2 | 0 |
| run | 14 | 3 |
| set_gong | 1 | 0 |
| strike_jab | 11 | 0 |
| thornbed | 11 | 1 |
| void_pull | 9 | 0 |
Defeats before own first turn: 0 exact; battles with at least one: 0 / 4

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 11 | 1.64 | 43 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| dusk_moth | 2 | 100 % |
| gloom_wolf | 1 | 100 % |
| thorn_mites | 3 | 100 % |
| asdf | 3 | 67 % |
| blaze_tiger | 2 | 50 % |
| forge_golem | 2 | 50 % |
| moss_turtle | 2 | 50 % |
| hollow_serpent | 3 | 33 % |
| ember_hawk | 3 | 0 % |
| grove_wisp | 3 | 0 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| run | 14 | 8 | 1.75 |
| strike_jab | 11 | 16 | 0.69 |
| thornbed | 11 | 12 | 0.92 |
| asdf_2 | 10 | 3 | 3.33 |
| void_pull | 9 | 7 | 1.29 |
| glide | 7 | 6 | 1.17 |
| gale | 6 | 8 | 0.75 |
| gloom_rift | 4 | 2 | 2.00 |
| lava_field | 3 | 2 | 1.50 |
| asdf_3 | 2 | 3 | 0.67 |
| bog | 2 | 2 | 1.00 |
| cinder_dive | 2 | 3 | 0.67 |
| fire_trail | 2 | 2 | 1.00 |
| plant_bamboo | 2 | 1 | 2.00 |
| quake_leap | 2 | 3 | 0.67 |
| coiling_rift | 1 | 3 | 0.33 |
| set_gong | 1 | 2 | 0.50 |
| asdf | 0 | 3 | 0.00 |
| new_skill | 0 | 2 | 0.00 |
| shove | 0 | 3 | 0.00 |
| snare | 0 | 2 | 0.00 |
| strike_thrust | 0 | 2 | 0.00 |
| thorn_lash | 0 | 1 | 0.00 |
Step uses (not a kit slot): 13

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 25 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 3; first defeat in round 1.8 (mean); monsters defeated before their own first turn: 0.00 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 0 %, after round 5 in 0 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 2 | 1 | 25.00 % |
| 3 | 3 | 75.00 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
none

<!-- Source: godot/tools/tacticthread303.txt -->

#### Run · 3v3 · seed 303 · 4 battles

| Field | Value |
|---|---|
| State | 2828adf+S021-tools · content `2026-11-13.1` · kit set `a30a9be42850` |
| Command | `sim.gd -- 4 3v3 303 --bot-a tactic --bot-b tactic --variant lifethread --paired` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `a30a9be42850` |
| Props placed | bronze_gong 1.00, bamboo_stand 0.50, paper_lantern 0.50, shrine 0.50, storm_drum 0.50, vortex_urn 0.50, wardstone 0.50 (per battle) |
| Loadout / AI | no tamer skills · bots `tactic` (side 0) and `tactic` (side 1), tools/lib/sim_bots.gd |
| Experiment | lifethread + bots tactic (in-memory simulation variants / battle experiment switches) |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 4 | 1 / 3 / 0 / 0 | 3.0 | 4.25 | 1.50 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | well | flank | total |
|---|---|---|---|---|---|---|---|---|---|---|---|
| share | 13 % | 0 % | 11 % | 56 % | 0 % | 0 % | 2 % | 0 % | 18 % | 1 % | 100 % |
| per battle | 4.00 | 0.00 | 3.50 | 17.25 | 0.00 | 0.00 | 0.50 | 0.00 | 5.50 | 0.25 | 31.00 |

Damage by raw event kind and source (collision rows are collision damage only; no fall reclassification):
| Damage kind | Source | Damage sum | Positive instances |
|---|---|---|---|
| aftermath | Bamboo Stand | 2 | 2 |
| collision | Board edge | 13 | 13 |
| collision | Collision | 56 | 52 |
| flank | Surrounded | 1 | 1 |
| ground | Blight | 1 | 1 |
| ground | Thornbed | 13 | 10 |
| strike | Jab | 14 | 7 |
| strike | asdf | 2 | 1 |
| well | Dragon Vein | 22 | 22 |

Skill activations (not later zone ticks; repeats count second and later actor + skill activations within the same turn):
| Skill | Activations | Repeated activations in same turn |
|---|---|---|
| asdf | 1 | 0 |
| asdf_2 | 6 | 2 |
| asdf_3 | 13 | 7 |
| bog | 4 | 1 |
| fire_trail | 1 | 0 |
| gale | 27 | 11 |
| glide | 6 | 0 |
| gloom_rift | 1 | 0 |
| lava_field | 1 | 0 |
| plant_bamboo | 1 | 0 |
| quake_leap | 3 | 0 |
| run | 12 | 3 |
| strike_jab | 7 | 0 |
| thornbed | 9 | 3 |
| void_pull | 9 | 2 |
Defeats before own first turn: 1 exact; battles with at least one: 1 / 4

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 8 | 2.00 | 65 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| asdf | 3 | 100 % |
| blaze_tiger | 2 | 100 % |
| thorn_mites | 3 | 100 % |
| dusk_moth | 2 | 50 % |
| forge_golem | 2 | 50 % |
| moss_turtle | 2 | 50 % |
| ember_hawk | 3 | 33 % |
| gloom_wolf | 1 | 0 % |
| grove_wisp | 3 | 0 % |
| hollow_serpent | 3 | 0 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| gale | 27 | 8 | 3.38 |
| asdf_3 | 13 | 3 | 4.33 |
| run | 12 | 8 | 1.50 |
| thornbed | 9 | 12 | 0.75 |
| void_pull | 9 | 7 | 1.29 |
| strike_jab | 7 | 16 | 0.44 |
| asdf_2 | 6 | 3 | 2.00 |
| glide | 6 | 6 | 1.00 |
| bog | 4 | 2 | 2.00 |
| quake_leap | 3 | 3 | 1.00 |
| asdf | 1 | 3 | 0.33 |
| fire_trail | 1 | 2 | 0.50 |
| gloom_rift | 1 | 2 | 0.50 |
| lava_field | 1 | 2 | 0.50 |
| plant_bamboo | 1 | 1 | 1.00 |
| cinder_dive | 0 | 3 | 0.00 |
| coiling_rift | 0 | 3 | 0.00 |
| new_skill | 0 | 2 | 0.00 |
| set_gong | 0 | 2 | 0.00 |
| shove | 0 | 3 | 0.00 |
| snare | 0 | 2 | 0.00 |
| strike_thrust | 0 | 2 | 0.00 |
| thorn_lash | 0 | 1 | 0.00 |
Step uses (not a kit slot): 17

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 0 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 3; first defeat in round 1.3 (mean); monsters defeated before their own first turn: 0.25 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 0 %, after round 5 in 0 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 3 | 4 | 100.00 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
none

## S020 · 2026-11-13 · current kits and random stats: six completed paired runs

**State:** `2828adf` dirty (measurement tools only for these runs; no rule or content changes) · content `2026-11-13.1` · kit set `a30a9be42850`. The current content includes the user experiments listed under Kit Sets, intentionally unchanged. Godot 4.7.2; one process at Idle priority, affinity `0xC` (CPU 2/3 of 32). Existing import metadata changes are not gameplay changes.

**Runs:** six completed 3v3 blocks, `--paired`, 464 battles total: 136 with current stats (120 greedy, 16 tactic), 328 with `mixstats` (320 greedy, 8 tactic). The 40-battle tactic attempt stopped after 600 s without a completed block is excluded. No further simulations were started for this entry.

**Observations (indications only):**
- The user target is a **mean of 3–5 rounds**, inspecting outliers **<2 and >5** separately. All six printed means, 2.3–2.5 rounds, fall below that target. No completed battle lasted more than 5 rounds; 8 ended in round 1 (6/120 current-stat greedy, 2/240 mixstats greedy). All other runs have no length outliers. There are 2 Draws and no timeouts in the completed blocks.
- Current-stat greedy favours Turtle (74 %, 69 appearances) and Golem (70 %, 81), while Hawk is at 25 % (67). These are team outcomes with those monsters fielded, not isolated monster strength; the 8-battle tactic samples are too small for rankings.
- In greedy mixstats, HP 3/8 shows 34/64 % in seed 101 and 43/55 % in seed 202; TPR 1/2 shows 47/52 % and 47/53 %. AP 2/3 reverses between seeds (51/47 % versus 47/53 %). Initiative, Movement and Reach show no stable monotonic signal here. The raw stat rates are rounded **team win rates conditional on a fielded monster stat**, not individual win rates, independent observations or causal additive prices. Do not reconstruct exact wins from these percentages or treat this as a price calculation.
- Collision is the largest displayed damage source (51–65 %). **Known reporting gap:** `wells` (Dragon Veins) and `surrounding` are included in total damage but missing as columns. The displayed source shares therefore do not sum to 100 %; rounding is an additional limitation. The raw blocks below are deliberately not repaired; the user will correct the tool separately.
- Greedy is a strongly limited one-step bot; prior tactic comparisons show that its play quality can dominate apparent stat values. Tactic has only 24 completed battles here, 8 with mixstats. These results neither validate balance nor prove that a stat has no tactical value. No human play is covered by these bot blocks; the user has already played and supplied feedback separately (T40).

**Follow-up:** T13 (review the recorded short battles and early defeats, then plan targeted human/tactic checks), T40 (length and stat roles), T03/T02 (no stat or skill price approval). No rule/content change follows from this entry.

### Raw full run blocks

#### Run · 3v3 · seed 101 · 8 battles

| Field | Value |
|---|---|
| State | 2828adf+metrics · content `2026-11-13.1` · kit set `a30a9be42850` |
| Command | `sim.gd -- 8 3v3 101 --bot-a tactic --bot-b tactic --paired` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `a30a9be42850` |
| Props placed | wardstone 0.75, banner 0.50, bronze_gong 0.50, storm_drum 0.50, totem 0.50, ancestor_tablet 0.25, clay_urn 0.25, pagoda_column 0.25, stone_lion 0.25, vortex_urn 0.25 (per battle) |
| Loadout / AI | no tamer skills · bots `tactic` (side 0) and `tactic` (side 1), tools/lib/sim_bots.gd |
| Experiment | bots tactic (test switches of battle/core/battle_experiment.gd) |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 8 | 2 / 6 / 0 / 0 | 2.3 | 4.13 | 0.75 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | total |
|---|---|---|---|---|---|---|---|---|---|
| share | 13 % | 0 % | 13 % | 54 % | 0 % | 0 % | 2 % | 0 % | 100 % |
| per battle | 3.00 | 0.00 | 3.00 | 12.88 | 0.00 | 0.00 | 0.38 | 0.00 | 23.63 |

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 12 | 2.00 | 102 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| blaze_tiger | 4 | 75 % |
| moss_turtle | 4 | 75 % |
| asdf | 6 | 67 % |
| forge_golem | 3 | 67 % |
| grove_wisp | 6 | 67 % |
| gloom_wolf | 4 | 50 % |
| ember_hawk | 5 | 40 % |
| hollow_serpent | 5 | 40 % |
| thorn_mites | 5 | 20 % |
| dusk_moth | 6 | 17 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| gale | 34 | 14 | 2.43 |
| run | 27 | 19 | 1.42 |
| void_pull | 20 | 15 | 1.33 |
| asdf_3 | 13 | 6 | 2.17 |
| bog | 9 | 4 | 2.25 |
| thornbed | 9 | 22 | 0.41 |
| gloom_rift | 8 | 6 | 1.33 |
| strike_jab | 8 | 28 | 0.29 |
| asdf_2 | 6 | 6 | 1.00 |
| quake_leap | 6 | 6 | 1.00 |
| lava_field | 5 | 4 | 1.25 |
| fire_trail | 4 | 4 | 1.00 |
| glide | 4 | 10 | 0.40 |
| thorn_lash | 4 | 4 | 1.00 |
| cinder_dive | 1 | 5 | 0.20 |
| coiling_rift | 1 | 5 | 0.20 |
| plant_bamboo | 1 | 4 | 0.25 |
| snare | 1 | 6 | 0.17 |
| asdf | 0 | 6 | 0.00 |
| new_skill | 0 | 4 | 0.00 |
| set_gong | 0 | 3 | 0.00 |
| shove | 0 | 8 | 0.00 |
| strike_thrust | 0 | 3 | 0.00 |
Step uses (not a kit slot): 17

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 75 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 3; first defeat in round 1.3 (mean); monsters defeated before their own first turn: 0.25 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 0 %, after round 5 in 0 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 2 | 6 | 75.00 % |
| 3 | 2 | 25.00 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
none


#### Run · 3v3 · seed 202 · 120 battles

| Field | Value |
|---|---|
| State | 2828adf+metrics · content `2026-11-13.1` · kit set `a30a9be42850` |
| Command | `sim.gd -- 120 3v3 202 --paired` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `a30a9be42850` |
| Props placed | banner 0.38, wardstone 0.37, peach_tree 0.28, clay_urn 0.27, shrine 0.27, totem 0.27, pagoda_column 0.25, storm_drum 0.25, ancestor_tablet 0.23, paper_lantern 0.23, stone_lion 0.23, vortex_urn 0.23, bronze_gong 0.22, bamboo_stand 0.15 (per battle) |
| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 120 | 55 / 64 / 1 / 0 | 2.4 | 4.30 | 1.75 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | total |
|---|---|---|---|---|---|---|---|---|---|
| share | 18 % | 0 % | 9 % | 52 % | 0 % | 0 % | 1 % | 0 % | 100 % |
| per battle | 4.38 | 0.00 | 2.27 | 12.78 | 0.00 | 0.00 | 0.33 | 0.00 | 24.74 |

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 280 | 1.88 | 1552 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| moss_turtle | 69 | 74 % |
| forge_golem | 81 | 70 % |
| asdf | 78 | 58 % |
| gloom_wolf | 63 | 56 % |
| thorn_mites | 73 | 53 % |
| dusk_moth | 77 | 42 % |
| grove_wisp | 82 | 39 % |
| blaze_tiger | 68 | 38 % |
| hollow_serpent | 62 | 37 % |
| ember_hawk | 67 | 25 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| gale | 461 | 230 | 2.00 |
| run | 425 | 271 | 1.57 |
| void_pull | 334 | 219 | 1.53 |
| asdf_3 | 179 | 78 | 2.29 |
| bog | 159 | 69 | 2.30 |
| glide | 143 | 140 | 1.02 |
| strike_jab | 134 | 433 | 0.31 |
| asdf_2 | 131 | 78 | 1.68 |
| gloom_rift | 130 | 77 | 1.69 |
| thornbed | 119 | 295 | 0.40 |
| fire_trail | 91 | 68 | 1.34 |
| lava_field | 86 | 68 | 1.26 |
| quake_leap | 82 | 82 | 1.00 |
| thorn_lash | 56 | 63 | 0.89 |
| coiling_rift | 47 | 62 | 0.76 |
| plant_bamboo | 32 | 63 | 0.51 |
| asdf | 27 | 78 | 0.35 |
| strike_thrust | 26 | 81 | 0.32 |
| new_skill | 19 | 68 | 0.28 |
| shove | 18 | 132 | 0.14 |
| set_gong | 4 | 81 | 0.05 |
| snare | 1 | 77 | 0.01 |
| cinder_dive | 0 | 67 | 0.00 |
Step uses (not a kit slot): 102

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 62 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 4; first defeat in round 1.1 (mean); monsters defeated before their own first turn: 0.10 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 5 %, after round 5 in 0 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 1 | 6 | 5.00 % |
| 2 | 68 | 56.67 % |
| 3 | 40 | 33.33 % |
| 4 | 6 | 5.00 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
| 32 | 202000637 | -8400657598842425077 | dusk_moth, gloom_wolf, moss_turtle | thorn_mites, blaze_tiger, grove_wisp | side 0 | 1 |
| 43 | 202000648 | 6264608642343643130 | moss_turtle, asdf, forge_golem | dusk_moth, gloom_wolf, ember_hawk | side 0 | 1 |
| 57 | 202000662 | 3128795407650987120 | forge_golem, moss_turtle, ember_hawk | blaze_tiger, asdf, grove_wisp | side 0 | 1 |
| 75 | 202000680 | 7002782994635951514 | thorn_mites, forge_golem, moss_turtle | dusk_moth, blaze_tiger, grove_wisp | side 0 | 1 |
| 89 | 202000694 | 3866969759943295504 | blaze_tiger, grove_wisp, ember_hawk | dusk_moth, thorn_mites, asdf | side 1 | 1 |
| 105 | 202000710 | -4987315100765326112 | gloom_wolf, blaze_tiger, ember_hawk | moss_turtle, thorn_mites, dusk_moth | side 1 | 1 |


#### Run · 3v3 · seed 101 · 80 battles

| Field | Value |
|---|---|
| State | 2828adf+metrics · content `2026-11-13.1` · kit set `a30a9be42850` |
| Command | `sim.gd -- 80 3v3 101 --variant mixstats --paired` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `a30a9be42850` |
| Props placed | ancestor_tablet 0.42, bamboo_stand 0.35, pagoda_column 0.33, storm_drum 0.30, wardstone 0.30, totem 0.28, bronze_gong 0.25, peach_tree 0.25, stone_lion 0.25, paper_lantern 0.23, shrine 0.23, vortex_urn 0.23, clay_urn 0.20, banner 0.13 (per battle) |
| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |
| Experiment | mixstats (test switches of battle/core/battle_experiment.gd) |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 80 | 40 / 39 / 1 / 0 | 2.5 | 4.21 | 1.66 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | total |
|---|---|---|---|---|---|---|---|---|---|
| share | 18 % | 0 % | 10 % | 52 % | 0 % | 0 % | 1 % | 0 % | 100 % |
| per battle | 4.97 | 0.00 | 2.81 | 14.54 | 0.00 | 0.00 | 0.38 | 0.00 | 28.16 |

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 205 | 1.94 | 1221 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| asdf | 48 | 65 % |
| thorn_mites | 52 | 63 % |
| gloom_wolf | 41 | 56 % |
| grove_wisp | 62 | 52 % |
| moss_turtle | 47 | 51 % |
| forge_golem | 47 | 49 % |
| dusk_moth | 43 | 44 % |
| hollow_serpent | 43 | 42 % |
| ember_hawk | 50 | 40 % |
| blaze_tiger | 47 | 30 % |

| Random draw (mixkits / mixskills / mixstats) | Played | Win rate |
|---|---|---|
| stat:ap=2 | 250 | 51 % |
| stat:ap=3 | 230 | 47 % |
| stat:hp=3 | 79 | 34 % |
| stat:hp=4 | 88 | 42 % |
| stat:hp=5 | 86 | 47 % |
| stat:hp=6 | 67 | 51 % |
| stat:hp=7 | 84 | 60 % |
| stat:hp=8 | 76 | 64 % |
| stat:init=1 | 52 | 42 % |
| stat:init=2 | 59 | 51 % |
| stat:init=3 | 44 | 57 % |
| stat:init=4 | 41 | 39 % |
| stat:init=5 | 62 | 50 % |
| stat:init=6 | 64 | 48 % |
| stat:init=7 | 53 | 49 % |
| stat:init=8 | 57 | 61 % |
| stat:init=9 | 48 | 44 % |
| stat:move=1 | 119 | 54 % |
| stat:move=2 | 81 | 48 % |
| stat:move=3 | 86 | 52 % |
| stat:move=4 | 99 | 48 % |
| stat:move=5 | 95 | 43 % |
| stat:reach=2 | 152 | 51 % |
| stat:reach=3 | 168 | 46 % |
| stat:reach=4 | 160 | 52 % |
| stat:tpr=1 | 243 | 47 % |
| stat:tpr=2 | 237 | 52 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| gale | 449 | 159 | 2.82 |
| run | 282 | 174 | 1.62 |
| void_pull | 233 | 142 | 1.64 |
| asdf_3 | 141 | 48 | 2.94 |
| strike_jab | 138 | 301 | 0.46 |
| gloom_rift | 94 | 43 | 2.19 |
| thornbed | 91 | 205 | 0.44 |
| bog | 90 | 47 | 1.91 |
| glide | 77 | 102 | 0.75 |
| quake_leap | 73 | 62 | 1.18 |
| lava_field | 67 | 47 | 1.43 |
| fire_trail | 55 | 47 | 1.17 |
| asdf_2 | 40 | 48 | 0.83 |
| thorn_lash | 29 | 41 | 0.71 |
| coiling_rift | 22 | 43 | 0.51 |
| plant_bamboo | 22 | 41 | 0.54 |
| strike_thrust | 12 | 47 | 0.26 |
| asdf | 9 | 48 | 0.19 |
| shove | 9 | 88 | 0.10 |
| new_skill | 8 | 47 | 0.17 |
| cinder_dive | 7 | 50 | 0.14 |
| set_gong | 4 | 47 | 0.09 |
| snare | 1 | 43 | 0.02 |
Step uses (not a kit slot): 129

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 58 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 5; first defeat in round 1.5 (mean); monsters defeated before their own first turn: 0.00 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 0 %, after round 5 in 0 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 2 | 46 | 57.50 % |
| 3 | 29 | 36.25 % |
| 4 | 4 | 5.00 % |
| 5 | 1 | 1.25 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
none


#### Run · 3v3 · seed 202 · 240 battles

| Field | Value |
|---|---|
| State | 2828adf+metrics · content `2026-11-13.1` · kit set `a30a9be42850` |
| Command | `sim.gd -- 240 3v3 202 --variant mixstats --paired` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `a30a9be42850` |
| Props placed | wardstone 0.35, banner 0.34, pagoda_column 0.32, ancestor_tablet 0.28, vortex_urn 0.27, paper_lantern 0.26, shrine 0.26, stone_lion 0.26, peach_tree 0.24, storm_drum 0.24, bronze_gong 0.23, totem 0.23, bamboo_stand 0.22, clay_urn 0.22 (per battle) |
| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |
| Experiment | mixstats (test switches of battle/core/battle_experiment.gd) |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 240 | 129 / 111 / 0 / 0 | 2.5 | 4.22 | 1.84 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | total |
|---|---|---|---|---|---|---|---|---|---|
| share | 17 % | 0 % | 10 % | 51 % | 0 % | 0 % | 2 % | 0 % | 100 % |
| per battle | 4.81 | 0.00 | 2.85 | 14.17 | 0.00 | 0.00 | 0.53 | 0.00 | 28.02 |

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 599 | 1.93 | 3591 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| forge_golem | 149 | 54 % |
| dusk_moth | 150 | 54 % |
| moss_turtle | 132 | 54 % |
| asdf | 151 | 54 % |
| ember_hawk | 135 | 52 % |
| thorn_mites | 140 | 51 % |
| grove_wisp | 167 | 48 % |
| hollow_serpent | 131 | 47 % |
| gloom_wolf | 144 | 45 % |
| blaze_tiger | 141 | 40 % |

| Random draw (mixkits / mixskills / mixstats) | Played | Win rate |
|---|---|---|
| stat:ap=2 | 724 | 47 % |
| stat:ap=3 | 716 | 53 % |
| stat:hp=3 | 246 | 43 % |
| stat:hp=4 | 254 | 42 % |
| stat:hp=5 | 227 | 49 % |
| stat:hp=6 | 232 | 53 % |
| stat:hp=7 | 252 | 58 % |
| stat:hp=8 | 229 | 55 % |
| stat:init=1 | 175 | 52 % |
| stat:init=2 | 170 | 50 % |
| stat:init=3 | 145 | 54 % |
| stat:init=4 | 154 | 44 % |
| stat:init=5 | 136 | 51 % |
| stat:init=6 | 177 | 50 % |
| stat:init=7 | 142 | 49 % |
| stat:init=8 | 168 | 49 % |
| stat:init=9 | 173 | 50 % |
| stat:move=1 | 302 | 48 % |
| stat:move=2 | 272 | 47 % |
| stat:move=3 | 300 | 50 % |
| stat:move=4 | 294 | 53 % |
| stat:move=5 | 272 | 51 % |
| stat:reach=2 | 492 | 48 % |
| stat:reach=3 | 495 | 52 % |
| stat:reach=4 | 453 | 49 % |
| stat:tpr=1 | 715 | 47 % |
| stat:tpr=2 | 725 | 53 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| gale | 1268 | 451 | 2.81 |
| run | 874 | 557 | 1.57 |
| void_pull | 688 | 422 | 1.63 |
| asdf_3 | 451 | 151 | 2.99 |
| strike_jab | 380 | 863 | 0.44 |
| gloom_rift | 292 | 150 | 1.95 |
| thornbed | 274 | 589 | 0.47 |
| glide | 272 | 275 | 0.99 |
| bog | 271 | 132 | 2.05 |
| quake_leap | 194 | 167 | 1.16 |
| asdf_2 | 189 | 151 | 1.25 |
| fire_trail | 172 | 141 | 1.22 |
| lava_field | 146 | 141 | 1.04 |
| thorn_lash | 130 | 144 | 0.90 |
| plant_bamboo | 90 | 144 | 0.63 |
| coiling_rift | 56 | 131 | 0.43 |
| cinder_dive | 28 | 135 | 0.21 |
| asdf | 25 | 151 | 0.17 |
| strike_thrust | 25 | 149 | 0.17 |
| set_gong | 24 | 149 | 0.16 |
| new_skill | 20 | 141 | 0.14 |
| shove | 19 | 276 | 0.07 |
| snare | 3 | 150 | 0.02 |
Step uses (not a kit slot): 307

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 54 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 5; first defeat in round 1.4 (mean); monsters defeated before their own first turn: 0.03 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 1 %, after round 5 in 0 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 1 | 2 | 0.83 % |
| 2 | 128 | 53.33 % |
| 3 | 95 | 39.58 % |
| 4 | 12 | 5.00 % |
| 5 | 3 | 1.25 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
| 174 | 202000779 | -8583773424365847551 | grove_wisp, ember_hawk, asdf | forge_golem, moss_turtle, gloom_wolf | side 1 | 1 |
| 186 | 202000791 | -6001115033042537955 | dusk_moth, moss_turtle, thorn_mites | asdf, forge_golem, hollow_serpent | side 0 | 1 |


#### Run · 3v3 · seed 202 · 8 battles

| Field | Value |
|---|---|
| State | 2828adf+metrics · content `2026-11-13.1` · kit set `a30a9be42850` |
| Command | `sim.gd -- 8 3v3 202 --bot-a tactic --bot-b tactic --paired` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `a30a9be42850` |
| Props placed | bronze_gong 1.25, ancestor_tablet 0.50, banner 0.50, storm_drum 0.50, pagoda_column 0.25, peach_tree 0.25, wardstone 0.25 (per battle) |
| Loadout / AI | no tamer skills · bots `tactic` (side 0) and `tactic` (side 1), tools/lib/sim_bots.gd |
| Experiment | bots tactic (test switches of battle/core/battle_experiment.gd) |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 8 | 4 / 4 / 0 / 0 | 2.4 | 4.50 | 1.63 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | total |
|---|---|---|---|---|---|---|---|---|---|
| share | 10 % | 0 % | 15 % | 52 % | 0 % | 0 % | 0 % | 0 % | 100 % |
| per battle | 2.50 | 0.00 | 3.75 | 13.13 | 0.00 | 0.00 | 0.00 | 0.00 | 25.25 |

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 12 | 1.67 | 110 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| asdf | 5 | 80 % |
| grove_wisp | 8 | 75 % |
| moss_turtle | 3 | 67 % |
| forge_golem | 5 | 60 % |
| ember_hawk | 2 | 50 % |
| gloom_wolf | 5 | 40 % |
| hollow_serpent | 5 | 40 % |
| thorn_mites | 5 | 40 % |
| dusk_moth | 6 | 33 % |
| blaze_tiger | 4 | 0 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| gale | 36 | 15 | 2.40 |
| run | 32 | 19 | 1.68 |
| void_pull | 19 | 14 | 1.36 |
| asdf_3 | 16 | 5 | 3.20 |
| thornbed | 15 | 23 | 0.65 |
| bog | 11 | 3 | 3.67 |
| quake_leap | 10 | 8 | 1.25 |
| asdf_2 | 9 | 5 | 1.80 |
| strike_jab | 9 | 29 | 0.31 |
| gloom_rift | 5 | 6 | 0.83 |
| glide | 4 | 7 | 0.57 |
| lava_field | 4 | 4 | 1.00 |
| fire_trail | 3 | 4 | 0.75 |
| set_gong | 3 | 5 | 0.60 |
| thorn_lash | 3 | 5 | 0.60 |
| plant_bamboo | 1 | 5 | 0.20 |
| asdf | 0 | 5 | 0.00 |
| cinder_dive | 0 | 2 | 0.00 |
| coiling_rift | 0 | 5 | 0.00 |
| new_skill | 0 | 4 | 0.00 |
| shove | 0 | 8 | 0.00 |
| snare | 0 | 6 | 0.00 |
| strike_thrust | 0 | 5 | 0.00 |
Step uses (not a kit slot): 17

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 63 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 3; first defeat in round 1.3 (mean); monsters defeated before their own first turn: 0.13 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 0 %, after round 5 in 0 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 2 | 5 | 62.50 % |
| 3 | 3 | 37.50 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
none


#### Run · 3v3 · seed 202 · 8 battles

| Field | Value |
|---|---|
| State | 2828adf+metrics · content `2026-11-13.1` · kit set `a30a9be42850` |
| Command | `sim.gd -- 8 3v3 202 --bot-a tactic --bot-b tactic --variant mixstats --paired` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `a30a9be42850` |
| Props placed | bronze_gong 1.25, ancestor_tablet 0.50, banner 0.50, storm_drum 0.50, pagoda_column 0.25, peach_tree 0.25, wardstone 0.25 (per battle) |
| Loadout / AI | no tamer skills · bots `tactic` (side 0) and `tactic` (side 1), tools/lib/sim_bots.gd |
| Experiment | mixstats + bots tactic (test switches of battle/core/battle_experiment.gd) |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 8 | 6 / 2 / 0 / 0 | 2.4 | 4.63 | 1.88 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | total |
|---|---|---|---|---|---|---|---|---|---|
| share | 4 % | 0 % | 12 % | 65 % | 0 % | 0 % | 2 % | 0 % | 100 % |
| per battle | 1.25 | 0.00 | 3.50 | 18.63 | 0.00 | 0.00 | 0.50 | 0.00 | 28.63 |

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 0 | — | 6 | 1.67 | 127 |

| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |
|---|---|---|---|---|
| 100 % | — / — | — | — | 0.00 |

| Monster | Played | Win rate |
|---|---|---|
| forge_golem | 5 | 100 % |
| gloom_wolf | 5 | 100 % |
| asdf | 5 | 80 % |
| dusk_moth | 6 | 50 % |
| hollow_serpent | 5 | 40 % |
| thorn_mites | 5 | 40 % |
| blaze_tiger | 4 | 25 % |
| grove_wisp | 8 | 25 % |
| ember_hawk | 2 | 0 % |
| moss_turtle | 3 | 0 % |

| Random draw (mixkits / mixskills / mixstats) | Played | Win rate |
|---|---|---|
| stat:ap=2 | 24 | 50 % |
| stat:ap=3 | 24 | 50 % |
| stat:hp=3 | 10 | 50 % |
| stat:hp=4 | 6 | 50 % |
| stat:hp=5 | 9 | 22 % |
| stat:hp=6 | 5 | 40 % |
| stat:hp=7 | 10 | 70 % |
| stat:hp=8 | 8 | 63 % |
| stat:init=1 | 5 | 80 % |
| stat:init=2 | 2 | 100 % |
| stat:init=3 | 6 | 33 % |
| stat:init=4 | 7 | 71 % |
| stat:init=5 | 4 | 75 % |
| stat:init=6 | 7 | 29 % |
| stat:init=7 | 7 | 43 % |
| stat:init=8 | 6 | 33 % |
| stat:init=9 | 4 | 25 % |
| stat:move=1 | 7 | 43 % |
| stat:move=2 | 11 | 36 % |
| stat:move=3 | 12 | 58 % |
| stat:move=4 | 8 | 63 % |
| stat:move=5 | 10 | 50 % |
| stat:reach=2 | 14 | 43 % |
| stat:reach=3 | 19 | 47 % |
| stat:reach=4 | 15 | 60 % |
| stat:tpr=1 | 23 | 43 % |
| stat:tpr=2 | 25 | 56 % |

| Fielded skill | Uses | Fielded slots | Uses/slot |
|---|---|---|---|
| gale | 50 | 15 | 3.33 |
| void_pull | 25 | 14 | 1.79 |
| run | 18 | 19 | 0.95 |
| asdf_3 | 15 | 5 | 3.00 |
| thornbed | 12 | 23 | 0.52 |
| asdf_2 | 10 | 5 | 2.00 |
| fire_trail | 7 | 4 | 1.75 |
| gloom_rift | 7 | 6 | 1.17 |
| lava_field | 6 | 4 | 1.50 |
| quake_leap | 6 | 8 | 0.75 |
| plant_bamboo | 5 | 5 | 1.00 |
| bog | 4 | 3 | 1.33 |
| glide | 3 | 7 | 0.43 |
| strike_jab | 3 | 29 | 0.10 |
| asdf | 2 | 5 | 0.40 |
| cinder_dive | 1 | 2 | 0.50 |
| coiling_rift | 1 | 5 | 0.20 |
| set_gong | 1 | 5 | 0.20 |
| thorn_lash | 1 | 5 | 0.20 |
| new_skill | 0 | 4 | 0.00 |
| shove | 0 | 8 | 0.00 |
| snare | 0 | 6 | 0.00 |
| strike_thrust | 0 | 5 | 0.00 |
Step uses (not a kit slot): 36

Reached late-round pressure: HP leader won 0, lost 0, HP level 0, no winner 0
Rounds: under 3 in 63 %, over 7 in 0 %, over 10 in 0 % of the battles, longest 3; first defeat in round 1.5 (mean); monsters defeated before their own first turn: 0.00 per battle
Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in 0 %, after round 5 in 0 % of the battles

| Exact round count | Battles | Share |
|---|---|---|
| 2 | 5 | 62.50 % |
| 3 | 3 | 37.50 % |

Outliers (<2 or >5 rounds), including Draws and timeouts:
| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |
|---|---|---|---|---|---|---|
none


## S019 · 2026-11-13 · without Surges and traps: a skill only delivers; stats, skills and skill parts again

**State:** `eed1ade` dirty (uncommitted reshape, temp_todo T40) · content `2026-11-13.1` · kit set `230e32c911cc`. Godot 4.7.2. 3v3, random teams on seeded boards, `--paired`, bots `tactic` on both sides, 20 battles per seed (8 seeds = 160 battles, 16 seeds = 320). **Build rules since S018** (user decision 2026-11-13): no Surge and no trap is in the game; a skill strikes, moves its user, acts on its user or creates ground, a zone or a prop; Gloom Rift, Cinder Dive and Coiling Rift create ground (Coiling Rift also a Void Pull zone); kits of Wisp, Serpent and Turtle changed. The runs were made before two later changes of the same day (ground may be laid under a prop; a push zone left by a combined skill takes its direction from the rotation).

**Question (user):** how much do the stats, the skills and the parts of a skill matter on this state.

### Part A · the build

| Variant | Battles | Side 0 / 1 / Draw | Mean rounds | Under 3 / over 7 | First defeat (round, mean) | Hawk / Wisp / Moth | Tiger / Wolf / Serpent | Golem / Turtle / Mites |
|---|---|---|---|---|---|---|---|---|
| build without Surges and traps | 160 | 75 / 80 / 5 | 3.1 | 24 / 0 % | 1.3 | 35 / 32 / 22 % | 49 / 47 / 59 % | 62 / 68 / 63 % |

Seeds 1 and 2: damage by Strike 24–27 %, ground 7 %, collision 34–36 %, the rest Dragon Veins, surrounding and aftermath; no Surge damage.

### Part B · random stats with random skills or generated skills

| Row | Battles | Side 0 / 1 / Draw | Mean rounds | Under 3 / over 7 | First defeat (round, mean) |
|---|---|---|---|---|---|
| `mixskills,mixstats` (the 26 skills of the game) | 320 | 161 / 155 / 4 | 3.5 | 13 / 0 % | 1.9 |
| `genskills=48,mixstats` | 320 | 152 / 163 / 5 | 3.6 | 10 / 0 % | 2.0 |

In `mixskills` the first slot is a Strike with damage, so Jab, Thrust and Thorn Lash are held about three times as often as the others.

| Stat value | real skills | 48 generated |
|---|---|---|
| hp=3 | 39% (320) | 38% (307) |
| hp=4 | 43% (316) | 44% (345) |
| hp=5 | 50% (310) | 46% (315) |
| hp=6 | 49% (346) | 58% (322) |
| hp=7 | 54% (317) | 57% (312) |
| hp=8 | 61% (311) | 54% (319) |
| init=1 | 54% (206) | 55% (212) |
| init=2 | 47% (234) | 48% (212) |
| init=3 | 50% (215) | 49% (236) |
| init=4 | 49% (232) | 45% (226) |
| init=5 | 46% (210) | 50% (207) |
| init=6 | 49% (203) | 51% (201) |
| init=7 | 52% (191) | 48% (184) |
| init=8 | 45% (230) | 50% (229) |
| init=9 | 53% (199) | 48% (213) |
| move=1 | 49% (416) | 49% (382) |
| move=2 | 52% (373) | 50% (359) |
| move=3 | 49% (381) | 49% (404) |
| move=4 | 49% (391) | 49% (388) |
| move=5 | 48% (359) | 50% (387) |
| reach=2 | 49% (657) | 48% (621) |
| reach=3 | 48% (666) | 51% (658) |
| reach=4 | 52% (597) | 48% (641) |
| tpr=1 | 46% (966) | 48% (921) |
| tpr=2 | 53% (954) | 51% (999) |
| ap=2 | 41% (958) | 42% (949) |
| ap=3 | 58% (962) | 56% (971) |

| Skill | Win rate (plays) |
|---|---|
| gale | 62% (255) |
| void_pull | 61% (234) |
| time_split | 55% (240) |
| bog | 54% (254) |
| immovable | 54% (228) |
| run | 54% (239) |
| thornbed | 52% (221) |
| glide | 51% (252) |
| gloom_rift | 51% (238) |
| plant_bamboo | 50% (247) |
| strike_jab | 50% (817) |
| battle_trance | 49% (233) |
| fire_trail | 49% (267) |
| tailwind | 49% (235) |
| leap | 48% (257) |
| strike_thrust | 48% (792) |
| mire | 46% (249) |
| snare | 46% (227) |
| thorn_lash | 46% (802) |
| headbutt | 45% (236) |
| lava_field | 45% (222) |
| set_gong | 45% (239) |
| shove | 45% (235) |
| cinder_dive | 44% (206) |
| coiling_rift | 42% (255) |

| Part | Win rate (plays) |
|---|---|
| ap=1 | 51% (2217) |
| ap=2 | 49% (4085) |
| ap=3 | 46% (1378) |
| damage=0 | 49% (636) |
| damage=2 | 49% (2608) |
| impact=none | 48% (1512) |
| kind=ground | 49% (1481) |
| kind=move | 48% (1512) |
| kind=strike | 49% (3244) |
| kind=zone | 51% (1443) |
| path=free | 49% (501) |
| path=line | 48% (372) |
| path=walk | 48% (639) |
| shape=angle | 51% (257) |
| shape=block | 52% (591) |
| shape=cross | 49% (356) |
| shape=line2 | 52% (629) |
| shape=line3 | 45% (340) |
| shape=one | 50% (751) |
| stays=ground:blight | 50% (623) |
| stays=ground:lava | 47% (621) |
| stays=ground:mossbed | 49% (103) |
| stays=ground:thornbed | 49% (878) |
| stays=none | 49% (3297) |
| stays=prop:bamboo_stand | 48% (395) |
| stays=prop:bronze_gong | 48% (320) |
| stays=zone:gale | 67% (116) |
| stays=zone:mire | 48% (349) |
| stays=zone:slowing | 48% (343) |
| stays=zone:tailwind | 45% (121) |
| stays=zone:void_pull | 54% (514) |
| strike=arc | 46% (656) |
| strike=jab | 51% (1866) |
| strike=thrust | 45% (722) |

**Observations** (indications; bots only; ±7 points for a monster in the 160-battle row, about ±5 for an HP value, ±7 for an initiative value or a skill):

- *Removing Surges and traps changes little for the bots:* 3.1 rounds and 24 % under 3 (S018: 3.1 and 27 %); the fragile monsters stay last (Moth 22 %, Wisp 32 %, Hawk 35 %), the sturdy ones first (Turtle 68 %, Mites 63 %, Golem 62 %). A third of the damage is still collisions.
- *With random skills battles last 3.5–3.6 rounds, 10–13 % under 3 and none over 7:* shorter than with Surges in the pool (S018: 3.8–4.7), because ground deals 1 where a Surge dealt 2 and Strikes and pushes decide.
- *Stats as before:* HP from 38–39 % at 3 to 54–61 % at 8; AP 3 against 2 now 14–17 points (more than in S018: without 1-AP Surges a monster with 2 AP can do one thing per turn); a second turn 3–7; **initiative, Movement and Reach flat.**
- *Skills:* Gale and Void Pull lead (61–62 %), Coiling Rift (Blight and a pull for 2 AP) is last (42 %); the experiment Time Split reads 55 %, Battle Trance 49 %.
- *Parts:* flat again (45–54 %) except a Gale zone left behind (67 %, few plays).

**Follow-up:** T40 (a job for initiative and Movement; short battles through the kits; the fragile bodies), T03 (AP 3 is worth more than any other single step), T10/T11 (kits). No rule was changed by this entry.

About 800 battles in 40 runs.

## S018 · 2026-11-13 · the reshaped build: no height, Dragon Veins by last touch, fair Surges, new skill list and kits; what stats, skills and skill parts are worth

**State:** `eed1ade` dirty (uncommitted reshape, temp_todo T40) · content `2026-11-13.1`. Godot 4.7.2. 3v3, random teams on seeded boards, `--paired`, bots `tactic` on both sides, 20 battles per seed (seeds 1–8 = 160 battles, 16 seeds = 320). **Build rules since S017:** no Mountains and no flying; a Dragon Vein (the earlier Wellspring) belongs to the side that touched it last; a due Surge waits until every monster on it has had a turn; highest single hit 2 (every Surge and trap); ground acts on entering, on leaving, at the end of a turn or of a round; 28 skills in the sentence form and new kits; spread test stats (S016 set “wide”).

**Questions (user):** does the reshaped build hold; how much do the stats, the skills and the single parts of a skill matter.

**Variants:** `calm=1`, `veinhold`, `mixstats`, `mixskills` (four random skills of the game's 28 active ones and the passive, the first one dealing damage), `genskills=N` (four random skills out of N drawn by `SkillGen.draw`, seed 4711; a part's win rate is that of the monsters holding a skill with it), `mixkits`.

### Part A · the reshaped build

| Variant | Battles | Side 0 / 1 / Draw | Mean rounds | Under 3 / over 7 | First defeat (round, mean) | Hawk / Wisp / Moth | Tiger / Wolf / Serpent | Golem / Turtle / Mites |
|---|---|---|---|---|---|---|---|---|
| reshaped build | 160 | 87 / 71 / 2 | 3.1 | 27 / 0 % | 1.4 | 34 / 32 / 29 % | 49 / 44 / 57 % | 66 / 76 / 60 % |
| `calm=1` | 160 | 74 / 81 / 5 | 3.6 | 9 / 0 % | 2.0 | 37 / 44 / 27 % | 36 / 50 / 56 % | 53 / 70 / 67 % |
| `veinhold` (a Dragon Vein only works while held) | 160 | 81 / 78 / 1 | 4.1 | 17 / 3 % | 1.4 | 40 / 38 / 26 % | 47 / 46 / 55 % | 63 / 73 / 62 % |

Seed 1 of the first row: damage by strike 24 %, Surge 6 %, ground 5 %, collision 34 %, the rest Dragon Veins, surrounding and aftermath; most used after Step and Run: Jab, Void Pull, Bog.

### Part B · random stats with random skills, generated skills or random kits

| Row | Battles | Side 0 / 1 / Draw | Mean rounds | Under 3 / over 7 | First defeat (round, mean) |
|---|---|---|---|---|---|
| `mixskills,mixstats` (the 28 skills of the game) | 320 | 147 / 163 / 10 | 3.8 | 11 / 0 % | 2.0 |
| `genskills=36,mixstats` | 320 | 149 / 164 / 7 | 4.5 | 2 / 2 % | 2.5 |
| `genskills=60,mixstats` (seeds 17–32) | 320 | 152 / 163 / 5 | 4.7 | 2 / 5 % | 2.6 |
| `mixkits,mixstats` (the nine new kits) | 320 | 147 / 167 / 6 | 3.3 | 18 / 0 % | 1.9 |

Win rate of the monsters holding the value (about 950 plays per AP and TPR value, 630 per Reach value, 380 per Movement value, 320 per HP value, 210 per initiative value in each row):

| Stat value | real skills | 36 generated | 60 generated | kits | mean |
|---|---|---|---|---|---|
| hp=3 | 40% | 39% | 37% | 37% | 38 % |
| hp=4 | 42% | 45% | 45% | 46% | 44 % |
| hp=5 | 50% | 46% | 48% | 47% | 48 % |
| hp=6 | 51% | 53% | 54% | 51% | 52 % |
| hp=7 | 50% | 49% | 54% | 58% | 53 % |
| hp=8 | 57% | 61% | 56% | 57% | 58 % |
| init=1 | 50% | 48% | 50% | 52% | 50 % |
| init=2 | 48% | 46% | 54% | 50% | 50 % |
| init=3 | 47% | 53% | 45% | 51% | 49 % |
| init=4 | 50% | 47% | 50% | 50% | 49 % |
| init=5 | 49% | 48% | 47% | 45% | 47 % |
| init=6 | 51% | 48% | 49% | 51% | 50 % |
| init=7 | 50% | 48% | 51% | 50% | 50 % |
| init=8 | 44% | 46% | 46% | 48% | 46 % |
| init=9 | 47% | 56% | 51% | 44% | 50 % |
| move=1 | 46% | 44% | 50% | 48% | 47 % |
| move=2 | 50% | 50% | 48% | 51% | 50 % |
| move=3 | 48% | 45% | 50% | 46% | 47 % |
| move=4 | 54% | 52% | 49% | 53% | 52 % |
| move=5 | 44% | 52% | 49% | 48% | 48 % |
| reach=2 | 46% | 49% | 48% | 48% | 48 % |
| reach=3 | 49% | 48% | 49% | 47% | 48 % |
| reach=4 | 50% | 50% | 50% | 52% | 50 % |
| tpr=1 | 45% | 43% | 45% | 44% | 44 % |
| tpr=2 | 52% | 55% | 54% | 54% | 54 % |
| ap=2 | 43% | 43% | 44% | 43% | 43 % |
| ap=3 | 54% | 54% | 55% | 55% | 54 % |

| Skill | Win rate (plays) |
|---|---|
| bog | 60% (230) |
| gale | 58% (194) |
| lava_field | 55% (205) |
| set_gong | 54% (203) |
| immovable | 53% (220) |
| void_pull | 52% (227) |
| run | 51% (203) |
| gloom_rift | 50% (410) |
| leap | 50% (234) |
| strike_jab | 50% (415) |
| fire_trail | 48% (208) |
| mire | 48% (222) |
| spring_burst | 48% (410) |
| thorn_lash | 48% (389) |
| thornbed | 48% (217) |
| tidal_shell | 48% (422) |
| time_split | 48% (213) |
| glide | 47% (206) |
| shove | 47% (215) |
| ambush_rift | 46% (388) |
| battle_trance | 46% (215) |
| cinder_dive | 46% (408) |
| strike_thrust | 46% (384) |
| tailwind | 46% (204) |
| headbutt | 44% (190) |
| plant_bamboo | 44% (217) |
| coiling_rift | 43% (406) |
| snare | 42% (225) |

| Kit of | Win rate (plays) |
|---|---|
| ember_hawk | 59% (228) |
| hollow_serpent | 55% (211) |
| moss_turtle | 54% (221) |
| thorn_mites | 53% (211) |
| gloom_wolf | 51% (193) |
| grove_wisp | 47% (212) |
| forge_golem | 44% (226) |
| blaze_tiger | 40% (198) |
| dusk_moth | 37% (220) |

| Part | 36 generated: win rate (plays) | 60 generated: win rate (plays) |
|---|---|---|
| ap=1 | 46% (1861) | 48% (2100) |
| ap=2 | 50% (5001) | 50% (4582) |
| ap=3 | 47% (818) | 49% (998) |
| damage=0 | 55% (165) | 49% (208) |
| damage=2 | 50% (1361) | 51% (1291) |
| impact=none | 49% (867) | 49% (856) |
| impact=ring | 60% (178) | 64% (99) |
| kind=ground | 46% (1000) | 48% (980) |
| kind=move | 51% (1045) | 50% (955) |
| kind=strike | 51% (1526) | 50% (1499) |
| kind=surge | 48% (1536) | 48% (1665) |
| kind=trap | 47% (1618) | 48% (1571) |
| kind=zone | 52% (955) | 51% (1010) |
| move_target=none | 46% (1614) | 46% (1431) |
| move_target=pull | 48% (782) | 50% (655) |
| move_target=push | 49% (758) | 49% (1150) |
| path=free | 55% (186) | 53% (280) |
| path=line | 50% (692) | 51% (410) |
| path=walk | 52% (167) | 47% (265) |
| shape=angle | 46% (677) | 52% (756) |
| shape=block | — | 48% (426) |
| shape=cross | 47% (531) | 46% (675) |
| shape=line2 | 47% (1040) | 51% (720) |
| shape=line3 | 47% (765) | 48% (1012) |
| shape=one | 50% (2096) | 47% (1637) |
| stays=ground:blight | 49% (437) | 50% (602) |
| stays=ground:lava | 50% (1081) | 50% (800) |
| stays=ground:mossbed | 46% (431) | 49% (953) |
| stays=ground:snare | 51% (574) | 49% (594) |
| stays=ground:thornbed | 48% (196) | 47% (521) |
| stays=none | 49% (2733) | 50% (2257) |
| stays=prop:bamboo_stand | — | 49% (107) |
| stays=zone:bog | 49% (646) | 46% (556) |
| stays=zone:gale | 53% (596) | 55% (349) |
| stays=zone:mire | 44% (564) | 47% (490) |
| stays=zone:slowing | 45% (162) | 52% (103) |
| stays=zone:tailwind | — | 45% (92) |
| stays=zone:void_pull | 48% (260) | 53% (256) |
| strike=arc | 49% (549) | 49% (492) |
| strike=jab | 55% (708) | 54% (501) |
| strike=thrust | 43% (269) | 48% (506) |

**Observations** (indications; bots only; ±7 points for a monster in a 160-battle row, about ±5 for an HP value, ±7 for an initiative value or a skill in one row):

- *The reshaped build is too fast with the hand-made kits:* 3.1 rounds and 27 % of battles under 3. Dragon Veins by touch take a round off (4.1 rounds and 17 % with `veinhold`); a calm first round gives 9 % under 3 and the first defeat in round 2.0. A third of the damage is collisions.
- *The fragile monsters are weaker than before* (Moth 29 %, Wisp 32 %, Hawk 34 %; Turtle 76 %, Golem 66 %): a vein hits the nearest enemy every round and 3 HP go quickly.
- *With random or generated skills the same rules give 3.8–4.7 rounds, 2–11 % under 3 and the first defeat in round 2.0–2.6:* the short battles come from the kits (pulls and collisions), not from the rules alone.
- *Stats, four rows in agreement:* HP rises from 37–40 % at 3 to 56–61 % at 8, about 4 points per HP; AP 3 against 2 is worth 11 points, a second turn 7–12; **initiative shows no trend in any row, Movement and Reach none beyond noise.** The reshape has not given initiative or Movement a job the bots use.
- *Skills:* the displacing zones lead again (Bog 60 %, Gale 58 %), then Lava Field and Set Gong; every Surge, trap and Strike lies at 43–50 %; Snare is last (42 %). The two experiment skills are unremarkable (46–48 %).
- *Skill parts:* almost flat. Kind, shape, AP cost, damage and what stays all lie within 46–55 %; only “pushes all neighbours on landing” stands out (60–64 %, few plays) and a Gale zone left behind (53–55 %). A skill that moves its target is a little better than one that does not (48–50 % against 46 %).
- *Kits over random bodies:* Hawk's kit 59 %, Serpent's 55 %, Turtle's 54 %; Tiger's 40 % and the Moth's 37 %.
- *Limits:* `tactic` plans against a `greedy` opponent and may not use initiative or Binding Vines as a person would; a part's win rate is diluted by the three other skills of the monster.

**Follow-up:** T40 (kits too deadly; Dragon Vein damage from round 1; initiative and Movement still without measurable value; the Moth's and Tiger's kits), T03 (stat prices: HP, AP and a second turn carry the value), T13.

About 1 800 battles in 136 runs.

## S017 · 2026-11-13 · postponing in two forms, a calm first round, Surge wall; kits and stats drawn at random

**State:** `1b84358` dirty (uncommitted) · content `2026-11-13.1` · kit set `6e152c78b752` (movement skills on full Movement, all but Run 2 AP). Godot 4.7.2. 3v3, random teams on seeded boards, `--paired`, bots `tactic` on both sides, 20 battles per seed: seeds 1–8 (160 battles) or 1–16 (320). Rows are sums over the blocks of a row, as in S016. Stat set “wide”: S016.

**Questions (user):** does postponing a turn reward initiative (general form with the waiting monsters in reverse order; user idea: round 1 only, for monsters with two turns and the first of the queue); does a first round without damage or a charging Surge that blocks movement help; **are the fragile monsters weak because their kit does not fit** (every test so far used one fixed kit per monster)?

**New switches** (`sim.gd --variant`; all off by default): `delay=reverse`, `delay=first`, `calm=N` (no damage in the first N rounds), `surgewall` (no movement may enter the squares of a charging timed Surge), `surgeground` (a timed Surge without ground of its own leaves Thornbed; **without effect here: all five timed Surges of the kits already leave ground**, the rows equal those without it and are not listed), `mixkits` (every monster plays a random kit: the nine of the game, in Part C also ten simulation-only kits `kit_*`), `mixskills` (four random skills out of the 31 that some kit holds, the first one dealing damage), `mixstats` (HP 3–8, initiative 1–9, Movement 1–5, Reach 2–4, TPR 1–2, AP 2–3, each drawn alone, no budget).

### Part A · switches on the stat set “wide”

| Variant | Battles | Side 0 / 1 / Draw | Mean rounds | Under 3 / over 7 | First defeat (round, mean) | Hawk / Wisp / Moth | Tiger / Wolf / Serpent | Golem / Turtle / Mites |
|---|---|---|---|---|---|---|---|---|
| wide | 160 | 79 / 78 / 3 | 3.8 | 17 / 2 % | 1.1 | 28 / 36 / 53 % | 57 / 49 / 63 % | 53 / 62 / 43 % |
| wide · `delay=reverse` | 160 | 81 / 77 / 2 | 4.0 | 20 / 5 % | 1.1 | 32 / 46 / 51 % | 48 / 47 / 65 % | 52 / 69 / 39 % |
| wide · `delay=first` | 160 | 81 / 78 / 1 | 3.9 | 19 / 2 % | 1.1 | 28 / 35 / 51 % | 53 / 52 / 64 % | 57 / 67 / 43 % |
| wide · `calm=1` | 160 | 66 / 94 / 0 | 4.3 | 11 / 7 % | 2.0 | 44 / 55 / 30 % | 47 / 60 / 60 % | 53 / 72 / 32 % |
| wide · `fairsurge` (S016 Part D row) | 160 | 66 / 89 / 5 | 4.7 | 9 / 9 % | 1.7 | 46 / 48 / 22 % | 45 / 52 / 60 % | 62 / 58 / 44 % |
| wide · `fairsurge,delay=reverse` | 160 | 70 / 88 / 2 | 4.2 | 7 / 5 % | 1.6 | 41 / 53 / 32 % | 40 / 54 / 55 % | 67 / 55 / 48 % |
| wide · `fairsurge,delay=first` | 160 | 72 / 86 / 2 | 4.5 | 11 / 8 % | 1.6 | 45 / 45 / 23 % | 46 / 57 / 54 % | 63 / 62 / 51 % |
| wide · `fairsurge,calm=1` | 160 | 85 / 73 / 2 | 5.0 | 6 / 10 % | 2.1 | 40 / 50 / 35 % | 48 / 42 / 61 % | 67 / 59 / 46 % |
| wide · `fairsurge,surgewall` | 160 | 83 / 74 / 3 | 4.9 | 5 / 9 % | 1.6 | 38 / 46 / 36 % | 48 / 44 / 59 % | 61 / 54 / 58 % |
| wide · `fairsurge,surgedmg=-1` | 160 | 73 / 84 / 3 | 4.3 | 8 / 5 % | 1.6 | 35 / 49 / 35 % | 39 / 53 / 53 % | 64 / 62 / 54 % |
| wide, Hawk and Mites AP 3 · `fairsurge` | 160 | 76 / 82 / 2 | 4.2 | 19 / 6 % | 1.6 | 37 / 60 / 38 % | 32 / 50 / 55 % | 58 / 55 / 62 % |

### Part B · every monster with a random kit of the nine (`mixkits`): body and kit apart

| Variant | Battles | Side 0 / 1 / Draw | Mean rounds | Under 3 / over 7 | First defeat (round, mean) | Body: Hawk / Wisp / Moth | Tiger / Wolf / Serpent | Golem / Turtle / Mites |
|---|---|---|---|---|---|---|---|---|
| wide · `fairsurge,mixkits` (nine kits) | 320 | 158 / 157 / 5 | 4.1 | 15 / 4 % | 1.6 | 36 / 40 / 39 % | 45 / 42 / 57 % | 73 / 59 / 57 % |
| kit set stats · `fairsurge,mixkits` (nine kits) | 160 | 77 / 81 / 2 | 4.3 | 6 / 4 % | 1.9 | 53 / 35 / 44 % | 44 / 39 / 57 % | 55 / 54 / 64 % |

| Kit of | wide: win rate (plays) | kit set stats: win rate (plays) |
|---|---|---|
| grove_wisp | 61% (212) | 64% (92) |
| ember_hawk | 55% (228) | 56% (113) |
| forge_golem | 55% (226) | 55% (109) |
| moss_turtle | 48% (221) | 50% (116) |
| gloom_wolf | 47% (193) | 41% (104) |
| blaze_tiger | 46% (198) | 54% (95) |
| hollow_serpent | 46% (211) | 43% (111) |
| dusk_moth | 43% (220) | 43% (104) |
| thorn_mites | 42% (211) | 41% (116) |

Body class against kit, stat set “wide” (plays in brackets; 40–110 per cell, so ±10–15 points):

| Kit of | fragile bodies (Hawk, Wisp, Moth, Wolf) | middle (Tiger, Mites) | sturdy (Golem, Turtle, Serpent) |
|---|---|---|---|
| blaze_tiger | 33 % (84) | 54 % (46) | 57 % (68) |
| dusk_moth | 34 % (109) | 43 % (51) | 58 % (60) |
| ember_hawk | 41 % (88) | 52 % (58) | 72 % (82) |
| forge_golem | 46 % (104) | 65 % (43) | 60 % (79) |
| gloom_wolf | 35 % (97) | 48 % (40) | 68 % (56) |
| grove_wisp | 49 % (94) | 62 % (47) | 75 % (71) |
| hollow_serpent | 41 % (100) | 50 % (48) | 52 % (63) |
| moss_turtle | 40 % (102) | 39 % (56) | 68 % (63) |
| thorn_mites | 32 % (100) | 48 % (50) | 52 % (61) |

### Part C · stats and skills or kits drawn at random (320 battles per row; win rate of the monsters holding the value, plays in brackets)

`mixskills,mixstats,fairsurge`: 320 battles, sides 152 / 168 / 0 draws, 4.6 rounds, under 3 / over 7 8 / 8 %, first defeat round 1.9. `mixskills,mixstats`: 320 battles, sides 155 / 163 / 2 draws, 3.6 rounds, under 3 / over 7 26 / 4 %, first defeat round 1.5. `mixkits,mixstats,fairsurge`: 320 battles, sides 151 / 165 / 4 draws, 4.2 rounds, under 3 / over 7 9 / 4 %, first defeat round 1.9.

| Stat value | `mixskills,mixstats,fairsurge` | `mixskills,mixstats` | `mixkits,mixstats,fairsurge` (19 kits) |
|---|---|---|---|
| hp=3 | 36% (312) | 37% (312) | 43% (335) |
| hp=4 | 49% (321) | 49% (321) | 46% (325) |
| hp=5 | 50% (319) | 47% (319) | 47% (321) |
| hp=6 | 51% (304) | 53% (304) | 51% (317) |
| hp=7 | 55% (336) | 57% (336) | 53% (299) |
| hp=8 | 59% (328) | 55% (328) | 56% (323) |
| init=1 | 48% (216) | 44% (216) | 49% (234) |
| init=2 | 55% (210) | 50% (210) | 51% (221) |
| init=3 | 54% (205) | 47% (205) | 49% (196) |
| init=4 | 50% (223) | 52% (223) | 42% (200) |
| init=5 | 53% (216) | 53% (216) | 50% (185) |
| init=6 | 48% (226) | 48% (226) | 50% (223) |
| init=7 | 48% (207) | 54% (207) | 53% (214) |
| init=8 | 46% (205) | 48% (205) | 54% (204) |
| init=9 | 49% (212) | 51% (212) | 46% (243) |
| move=1 | 46% (404) | 51% (404) | 47% (403) |
| move=2 | 51% (380) | 49% (380) | 49% (381) |
| move=3 | 53% (376) | 51% (376) | 50% (403) |
| move=4 | 50% (373) | 51% (373) | 50% (384) |
| move=5 | 51% (387) | 47% (387) | 51% (349) |
| reach=2 | 47% (666) | 48% (666) | 51% (631) |
| reach=3 | 49% (631) | 49% (631) | 47% (659) |
| reach=4 | 54% (623) | 53% (623) | 50% (630) |
| tpr=1 | 46% (948) | 45% (948) | 46% (975) |
| tpr=2 | 54% (972) | 55% (972) | 53% (945) |
| ap=2 | 48% (985) | 47% (985) | 44% (972) |
| ap=3 | 52% (935) | 52% (935) | 55% (948) |

| Skill | with `fairsurge` | without |
|---|---|---|
| shockwave | 66% (187) | 59% (187) |
| gale | 64% (188) | 57% (188) |
| void_pull | 59% (183) | 59% (183) |
| bog | 56% (174) | 56% (174) |
| run | 55% (209) | 54% (209) |
| immovable | 53% (203) | 47% (203) |
| quake_leap | 53% (198) | 47% (198) |
| cinder_dive | 52% (353) | 51% (353) |
| plant_bamboo | 52% (188) | 51% (188) |
| shove | 52% (178) | 53% (178) |
| ambush_rift | 51% (357) | 49% (357) |
| glide | 51% (197) | 55% (197) |
| coiling_rift | 50% (336) | 51% (336) |
| mire | 50% (200) | 46% (200) |
| gloom_rift | 49% (377) | 51% (377) |
| strike_thrust | 49% (332) | 48% (332) |
| tidal_shell | 49% (326) | 50% (326) |
| bramble_tide | 48% (328) | 47% (328) |
| eclipse | 48% (340) | 51% (340) |
| headbutt | 48% (205) | 43% (205) |
| lava_field | 48% (185) | 43% (185) |
| set_gong | 48% (180) | 41% (180) |
| strike_jab | 48% (308) | 51% (308) |
| blink | 47% (213) | 45% (213) |
| leap | 47% (174) | 51% (174) |
| spring_burst | 47% (322) | 51% (322) |
| crucible | 46% (328) | 47% (328) |
| magma_pounce | 46% (353) | 48% (353) |
| raise_ground | 46% (198) | 43% (198) |
| thornbed | 45% (174) | 49% (174) |
| burrow | 43% (186) | 47% (186) |

| Kit | Win rate (plays) |
|---|---|
| grove_wisp | 71% (95) |
| ember_hawk | 66% (91) |
| kit_pusher | 58% (89) |
| kit_lancer | 57% (112) |
| kit_controller | 56% (91) |
| kit_harrier | 54% (93) |
| kit_denier | 53% (89) |
| moss_turtle | 49% (101) |
| thorn_mites | 49% (114) |
| kit_builder | 48% (108) |
| hollow_serpent | 46% (95) |
| kit_skirmisher | 46% (119) |
| kit_sniper | 45% (111) |
| forge_golem | 44% (111) |
| gloom_wolf | 44% (87) |
| kit_trapper | 43% (101) |
| blaze_tiger | 40% (103) |
| dusk_moth | 39% (105) |
| kit_battery | 37% (105) |

**Observations** (indications; bots only; about ±7 points for a monster in a 160-battle row, ±6 for a stat value or skill in Part C):

- *Postponing does not lift the fast monsters in either form:* Hawk and Wisp stay where they were, battle length hardly moves; the user's round-1 rule and the general reverse-order rule give the same picture.
- *A first round without damage moves the first defeat to round 2.0–2.1;* with `fairsurge` 6 % of battles end under 3 rounds and 10 % last longer than 7.
- *A charging Surge that blocks movement, with `fairsurge`, gives the fewest short battles (5 %).*
- *With kits mixed the bodies sort by HP:* Golem 73 %, Turtle 59 %, Serpent and Mites 57 %; Tiger 45 %, Wolf 42 %, Wisp 40 %, Moth 39 %, Hawk 36 %. The fragile bodies reach 49 % at best with any of the nine kits. The Hawk's kit is the second best; its body is what loses.
- *Kits differ by about 20 points averaged over bodies* (Wisp's kit 61–71 %, Mites' and Moth's about 40 %); four Surges (`kit_battery`) and the Moth's kit are last with `fairsurge`.
- *Stat values, each drawn alone:* **initiative shows no trend at all** over its nine values in any row, **Movement almost none** (only Movement 1 trails in two rows); HP 3 is a cliff (36–43 %), HP 4–6 flat (46–53 %), HP 7–8 at 53–59 %; a second turn is worth 7–10 points, AP 3 against AP 2 4–11, Reach 4 against 2 nothing to 7.
- *Skills:* the displacing zones lead (Shockwave, Gale, Void Pull, Bog 56–66 %), Run 54–55 %, every Surge and trap 46–52 %, Jab 48–51 %, the movement skills for 2 AP 43–55 %.
- *Limits:* `tactic` assumes a `greedy` opponent; no budget in Part C, so a value is measured across every other stat; combinations (a fragile body with one fitting skill) need far more battles.

**Follow-up:** T40 (reshape of square and skills: initiative and Movement have no job on the board; no single hit may take a monster from full HP to zero), T03 (stat prices: HP 3 against 4, AP, second turn), T39 (postponing; calm first round), T38 (Surge wall), T13. No rule was changed by this entry.

About 3 400 battles in 216 runs.

## S016 · 2026-11-13 · a bot that plans the whole turn (`tactic`); wide stats, postponing, `fairsurge`; movement skills on full Movement for 2 AP

**State:** `1b84358` dirty (uncommitted) · content `2026-11-13.1` · kit set `f4086ae48783` for Parts A–C, `6e152c78b752` for Part D (movement skills changed). Godot 4.7.2. 3v3, random teams on seeded boards, `--paired`, seeds 1–8 with 20 battles each (160 battles per row; Part A 80 per seating). The tool printed full blocks; the rows below are sums over the eight blocks of a row (wins, mean rounds, shares weighted by battles; a monster's win rate weighted by its battles).

**Questions (user):** did the fragile, fast monsters lose because of the AI; do stats that differ more (HP from 3, AP 2 and 3) hold up; what does postponing a turn do with a bot that can use it; what do movement skills on full Movement cost.

**Bot `tactic`** (`tools/lib/sim_bots.gd`): searches every order of actions the AP allow (beam over `AiBrain.evaluate`, 4 lines by plain score and 3 by the threat-aware score per action count), plays the best 3 + 2 end positions, “do nothing” and (with `delay`) the postponed turn on with `greedy` for both sides until its monster is up again, and takes the line with the best position there. About 23 s per 3v3 battle on one core.

**Stat set “wide”** (`stat=` for the run only; HP / Init / Move / Reach / TPR / AP): Forge Golem 8 / 1 / 1 / 3 / 1 / 3 · Moss Turtle 7 / 3 / 2 / 3 / 1 / 3 · Hollow Serpent 6 / 5 / 2 / 3 / 1 / 3 · Thorn Mites 6 / 3 / 3 / 3 / 2 / 2 · Blaze Tiger 5 / 7 / 5 / 2 / 1 / 3 · Gloom Wolf 4 / 9 / 3 / 3 / 1 / 3 · Grove Wisp 3 / 9 / 5 / 3 / 1 / 3 · Ember Hawk 3 / 9 / 5 / 3 / 2 / 2 · Dusk Moth 3 / 7 / 3 / 4 / 1 / 3. Trial prices behind it (not a rule): HP 1.5 per point above 2, initiative 0.5, Movement 1, Reach 3, second turn 4, AP 3 4; every sheet 15.5–16.5.

### Part A · `tactic` against `greedy` (build rules, kit set stats)

| Seating | Battles | `tactic` wins | Mean rounds | Under 3 rounds |
|---|---|---|---|---|
| `tactic` side 0 | 80 | 72 | 3.4 | 39 % |
| `tactic` side 1 | 80 | 77 | 2.7 | 44 % |

### Part B · kit set stats (HP 5–8, every monster AP 3)

| Bots · variant | Side 0 / 1 / Draw | Mean rounds | Under 3 / over 7 | First defeat (round, mean) | Hawk / Wisp / Moth | Tiger / Wolf / Serpent | Golem / Turtle / Mites |
|---|---|---|---|---|---|---|---|
| `greedy` | 80 / 77 / 3 | 3.6 | 18 / 2 % | 1.3 | 44 / 51 / 49 % | 57 / 56 / 61 % | 41 / 47 / 39 % |
| `tactic` | 66 / 93 / 1 | 3.7 | 20 / 2 % | 1.3 | 54 / 57 / 55 % | 63 / 52 / 53 % | 36 / 40 / 36 % |
| `tactic` · `delay` | 68 / 92 / 0 | 3.3 | 29 / 2 % | 1.2 | 56 / 60 / 56 % | 54 / 51 / 56 % | 40 / 40 / 36 % |
| `tactic` · `delay,fairsurge` | 74 / 86 / 0 | 4.1 | 9 / 2 % | 1.6 | 59 / 63 / 43 % | 55 / 54 / 44 % | 43 / 46 / 44 % |

### Part C · stat set “wide” (HP 3–8, two monsters with AP 2)

| Bots · variant | Side 0 / 1 / Draw | Mean rounds | Under 3 / over 7 | First defeat (round, mean) | Hawk / Wisp / Moth | Tiger / Wolf / Serpent | Golem / Turtle / Mites |
|---|---|---|---|---|---|---|---|
| `greedy` | 83 / 77 / 0 | 4.1 | 22 / 9 % | 1.1 | 27 / 53 / 52 % | 51 / 44 / 67 % | 52 / 58 / 50 % |
| `tactic` | 87 / 72 / 1 | 3.6 | 25 / 1 % | 1.1 | 35 / 46 / 53 % | 54 / 55 / 64 % | 47 / 54 / 42 % |
| `tactic` · `delay` | 81 / 77 / 2 | 3.6 | 26 / 2 % | 1.1 | 34 / 58 / 46 % | 61 / 60 / 59 % | 41 / 52 / 35 % |
| `tactic` · `fairsurge` | 79 / 81 / 0 | 4.3 | 12 / 7 % | 1.4 | 40 / 54 / 38 % | 60 / 41 / 64 % | 57 / 54 / 46 % |
| `tactic` · `delay,fairsurge` | 86 / 73 / 1 | 4.0 | 13 / 2 % | 1.4 | 45 / 58 / 35 % | 49 / 51 / 52 % | 63 / 54 / 42 % |

### Part D · movement skills other than Run on full Movement for 2 AP (build test; kit set `6e152c78b752`), bots `tactic`

| Stats · variant | Side 0 / 1 / Draw | Mean rounds | Under 3 / over 7 | First defeat (round, mean) | Hawk / Wisp / Moth | Tiger / Wolf / Serpent | Golem / Turtle / Mites |
|---|---|---|---|---|---|---|---|
| kit set | 63 / 97 / 0 | 3.7 | 18 / 1 % | 1.5 | 53 / 57 / 55 % | 48 / 65 / 49 % | 38 / 48 / 37 % |
| kit set · `fairsurge` | 74 / 84 / 2 | 4.6 | 6 / 2 % | 1.9 | 63 / 61 / 37 % | 41 / 50 / 35 % | 50 / 59 / 48 % |
| wide · `fairsurge` | 66 / 89 / 5 | 4.7 | 9 / 9 % | 1.7 | 46 / 48 / 22 % | 45 / 52 / 60 % | 62 / 58 / 44 % |
| wide · `fairsurge,freeap=1,freemod=1` (1 AP, Movement − 1) | 86 / 73 / 1 | 4.3 | 10 / 7 % | 1.4 | 39 / 56 / 40 % | 50 / 52 / 55 % | 63 / 49 / 44 % |

**Observations** (indications; bots only; a monster plays in about 50 battles of a row, so a difference under about 7 points between two win rates is noise):

- *Play quality outweighs everything measured so far:* `tactic` wins 149 of 160 battles against `greedy`. It models its opponent as `greedy`, which is exactly what it meets there; the rows of `tactic` against itself are the fairer reading.
- *With the kit set stats better play lifts the fast monsters and lowers the sturdy ones:* Hawk 44 → 54 %, Wisp 51 → 57 %, Golem 41 → 36 %, Turtle 47 → 40 %. The stat prices of S014/S015 were derived from `greedy` and so rated HP too high against initiative.
- *A 3-HP monster with AP 3 holds (Wisp 46–58 % in the wide rows); the two AP-2 monsters are weak in every wide row* (Hawk 27–46 %, Mites 35–46 %, the Mites with 6 HP).
- *`fairsurge` halves the share of battles under 3 rounds* (20–29 % → 9–13 %; with the new movement rule 6–9 %) and moves the first defeat from round 1.1–1.3 to 1.4–1.9. It lowers the Dusk Moth (two Surge-dependent slots) to 22–43 %.
- *Postponing in its present form does little:* no gain for the fast monsters beyond noise, and with the kit set stats more battles under 3 rounds (29 %). If everyone postpones, the slowest monster still acts last.
- *First defeats stay in round 1–2 in every row.*
- *Movement for 2 AP:* Glide, Burrow, Headbutt and Quake Leap are used more often than before in spite of the price (seed 1: Burrow 1.5 → 2.75, Glide 1.55 → 2.4 per battle); win rates move within noise except the Wolf (+13) and Tiger (−15) in the first row.
- *Unexplained:* with the kit set stats and `tactic` on both sides, side 1 wins about 58 % in all five rows (66/93, 68/92, 74/86, 63/97, 74/84); with `greedy` and with the wide set there is no such lean.

**Follow-up:** T03 (prices from `greedy` runs overrate HP; AP 2 against AP 3; HP floor), T39 (postponing with waiting monsters in reverse initiative order; round-1 defeats; side lean), T38 (`fairsurge` plus a board effect for Surges; the Moth's kit), T13 (bot quality: `tactic` as reference; a game opponent on its level). No rule or stat was changed by this entry; the movement skill change of Part D is a build test (godot/README.md).

About 2 100 battles in 136 runs.

## S015 · 2026-11-13 · Wellspring rules as build rules; new stat prices and frames; the Surge timer tested again

**State:** `c35396a` dirty (uncommitted) · content `2026-11-13.1` · kit set `f4086ae48783` for Parts B (last row) and C; Part A and the other rows of Part B ran on kit set `164984ea835f` with stats set by `stat=`. **Build rules since S014** (user decision 2026-11-13): three Wellsprings on the centre row of the 7×7 board, Wellspring and surround damage at the end of a round, TPR counts from round 2, late-round pressure only in rounds in which nobody holds a Wellspring. The one-time bonus squares of S013 Parts G/H are removed from the build. 3v3, `--paired`, bot `greedy`.

**Questions (user):** adopt the Wellspring draft, set the stat prices anew and adapt the frames; then test the Surge again.

### Part A · the default after the change

The first row of the new default (seed 1, 40 battles, old stats) equals the row of `wells=3,flank,tpr2,latepressure=idle` in S013 column by column.

### Part B · four stat sets for the nine monsters (HP / Init / Move / TPR / Reach / AP), each spending 16 points by its prices

| Set · prices | Golem | Turtle | Serpent | Wolf | Tiger | Wisp | Hawk | Moth | Mites |
|---|---|---|---|---|---|---|---|---|---|
| old · HP 1 from base 1, Init 1, second turn 5 | 8/4/1/1/3/3 | 8/3/2/1/3/3 | 7/4/2/1/3/3 | 5/6/2/1/3/3 | 5/7/4/1/2/3 | 4/8/4/1/2/3 | 2/9/3/2/2/2 | 2/9/3/2/2/2 | 3/6/2/2/3/2 |
| A · HP 3 from base 3, Init 0.5, second turn 5 | 6/3/1/1/3/3 | 7/1/2/1/2/3 | 6/1.5/2/1/3/3 | 5/7/2/1/3/3 | 5/9/4/1/2/3 | 4/7/5/1/3/3 | 4/9/5/2/2/2 | 4/7/2/1/4/3 | 4/7/3/2/3/2 |
| B · HP 2 from base 3, Init 0.5, second turn 5 | 7/5/1/1/3/3 | 8/5/2/1/2/3 | 7/3/2/1/3/3 | 6/7/2/1/3/3 | 6/9/4/1/2/3 | 5/5/5/1/3/3 | 5/9/4/2/2/2 | 5/5/2/1/4/3 | 5/5/3/2/3/2 |
| D · as B, second turn 3 | 7/5/1/1/3/3 | 8/5/2/1/2/3 | 7/3/2/1/3/3 | 6/7/2/1/3/3 | 6/9/4/1/2/3 | 5/5/5/1/3/3 | 6/9/4/2/2/2 | 5/5/2/1/4/3 | 6/5/3/2/3/2 |
| **C · HP 2 from base 4, Init 0.5, second turn 3** (adopted) | 8/5/1/1/3/3 | 8/3/2/1/3/3 | 7/5/3/1/3/3 | 6/9/3/1/3/3 | 7/7/5/1/2/3 | 5/9/5/1/3/3 | 5/9/5/2/2/3 | 5/7/3/1/4/3 | 6/3/3/2/3/3 |

Movement 1, Reach 3, AP 3 for 3 in every set. In A–D the Dusk Moth is the new Caster shape (Reach 4, one turn).

Win rates in random teams (seeds 1–6, 60 battles each; a monster plays in about 240 of the 360):

| Set | Hawk | Moth | Mites | Wisp | Tiger | Wolf | Golem | Turtle | Serpent | Lowest–highest | Mean rounds | Under 3 / over 10 · longest |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| old | 30 % | 31 % | 34 % | 54 % | 61 % | 51 % | 62 % | 62 % | 69 % | 30–69 % | 3.7 | 23 / 1 % · 18 |
| A | 46 % | 53 % | 35 % | 65 % | 50 % | 62 % | 41 % | 45 % | 47 % | 35–65 % | 3.2 | 31 / 0 % · 10 |
| B | 51 % | 46 % | 32 % | 71 % | 44 % | 51 % | 48 % | 58 % | 42 % | 32–71 % | 3.5 | 21 / 0 % · 12 |
| D | 55 % | 50 % | 39 % | 66 % | 44 % | 50 % | 43 % | 57 % | 38 % | 38–66 % | 3.6 | 20 / 0 % · 11 |
| **C** | 53 % | 45 % | 41 % | 57 % | 56 % | 50 % | 41 % | 46 % | 57 % | 41–57 % | 3.5 | 25 / 0 % · 10 |

Team types (T = Golem, Turtle, Serpent; M = Tiger, Wolf, Wisp; F = Moth, Hawk, Mites; reading as in S012 Part B; seed 1, 40 battles per cell):

| Set | T beats F | T beats M | M beats F | T mirror | M mirror | F mirror | random |
|---|---|---|---|---|---|---|---|
| old | 77 / 80 | 45 / 80 | 78 / 80 | 7.0 · 0 % · 8 % | 2.6 · 53 % · 0 % | 2.3 · 75 % · 0 % | 3.8 · 25 % · 2 % |
| A | 32 / 80 | 31 / 80 | 58 / 80 | 6.3 · 0 % · 5 % | 2.4 · 63 % · 0 % | 2.2 · 70 % · 0 % | 3.1 · 36 % · 0 % |
| B | 29 / 80 | 23 / 80 | 64 / 80 | 7.2 · 0 % · 13 % | 3.0 · 15 % · 0 % | 2.6 · 55 % · 0 % | 3.8 · 24 % · 2 % |
| D | 23 / 80 | 23 / 80 | 58 / 80 | 7.2 · 0 % · 13 % | 3.0 · 15 % · 0 % | 2.6 · 48 % · 0 % | 3.5 · 24 % · 2 % |
| **C** | 54 / 80 | 22 / 80 | 56 / 80 | 5.5 · 5 % · 5 % | 2.8 · 43 % · 0 % | 2.5 · 63 % · 0 % | 3.5 · 29 % · 0 % |

### Part C · the Surge timer on the new standard (stats C; four seeds, 160 battles per row)

`castersurge`: a timed Surge fires at its caster's next turn. `fairsurge`: a Surge that is due waits until every monster standing on its squares has finished a turn since the cast. `turns=N`: finished turns of any monster until it fires (build: 2). `alltraps`: every marker skill is a trap. `delay`: a monster may postpone its turn once per round.

| Variant | Mean rounds | Under 3 / over 7 / over 10 · longest | Side 0 / 1 / draw | First defeat in round | Surge share of damage | Surge and trap damage per cast on enemies |
|---|---|---|---|---|---|---|
| build rules (2 turns of any monster) | 3.5 | 23 / 2 / 0 % · 8 | 80 / 77 / 3 | 1.4 | 34 % | 1.20 |
| `turns=1` | 3.0 | 36 / 0 / 0 % · 7 | 60 / 98 / 2 | 1.2 | 46 % | 1.81 |
| `turns=3` | 3.9 | 13 / 2 / 0 % · 10 | 79 / 81 / 0 | 1.4 | 24 % | 0.88 |
| `castersurge` | 4.0 | 13 / 3 / 0 % · 10 | 69 / 88 / 3 | 1.7 | 16 % | 0.53 |
| `fairsurge` | 4.0 | 8 / 4 / 1 % · 11 | 75 / 83 / 2 | 1.7 | 13 % | 0.43 |
| `alltraps` | 4.1 | 12 / 6 / 1 % · 13 | 85 / 74 / 1 | 1.6 | 0 % (traps 16 %) | 0.57 |
| `delay` | 3.6 | 17 / 1 / 0 % · 8 | 80 / 79 / 1 | 1.3 | 32 % | 1.10 |
| `castersurge,delay` | 3.9 | 11 / 1 / 0 % · 9 | 68 / 88 / 4 | 1.7 | 15 % | 0.54 |
| `fairsurge,delay` | 4.0 | 9 / 2 / 0 % · 9 | 76 / 81 / 3 | 1.8 | 13 % | 0.44 |
| build rules, bots `careful` | 4.8 | 5 / 10 / 2 % · 14 | 63 / 97 / 0 | 1.7 | — | — |
| `fairsurge`, bots `careful` | 6.2 | 1 / 26 / 8 % · 18 | 65 / 95 / 0 | 2.2 | — | — |

Team types (seed 1, 40 battles per cell):

| Variant | T beats F | T beats M | M beats F | T mirror | M mirror | F mirror | random |
|---|---|---|---|---|---|---|---|
| build rules | 54 / 80 | 22 / 80 | 56 / 80 | 5.5 · 5 % · 5 % | 2.8 · 43 % · 0 % | 2.5 · 63 % · 0 % | 3.5 · 29 % · 0 % |
| `castersurge` | 33 / 80 | 31 / 80 | 44 / 80 | 7.1 · 0 % · 10 % | 3.5 · 3 % · 0 % | 2.6 · 48 % · 0 % | 3.8 · 14 % · 0 % |
| `fairsurge` | 42 / 80 | 43 / 80 | 40 / 80 | 7.3 · 0 % · 10 % | 3.5 · 8 % · 0 % | 2.8 · 48 % · 0 % | 4.0 · 8 % · 2 % |

**Observations** (indications; bots only; a difference under about 6 points between two win rates or 8 of 80 wins is noise):

- *Stats:* every set with dearer HP pulls the nine win rates together; set C has the narrowest spread (41–57 % against 30–69 %) and no monster outside 40–60 %. Its weak spot is the pairing sturdy against middle (22 of 80). All sets leave the battles short (20–31 % under 3 rounds); none has a battle over 12 rounds.
- *The Surge timer decides the short end:* with a Surge that can always be left (`fairsurge`) 8 % of battles end before round 3, with `castersurge` or three turns 13 %, with the build rule 23 %, with one turn 36 %. The same order holds for the strength of the Surge: 0.43, 0.53, 0.88, 1.20 and 1.81 damage per cast.
- *`fairsurge` also levels the team types* (42, 43 and 40 of 80) but makes the sturdy mirror longer (7.3 rounds, 10 % over 10) and, with careful bots on both sides, the battles long (6.2 rounds, 8 % over 10).
- *Three turns instead of two* is the smallest change: a number, no new rule; it halves the short end and keeps a quarter of the damage with Surges.
- *Postponing a turn* adds little by itself (23 to 17 %) and nothing on top of the two Surge rules.
- *Side balance* drifts with `castersurge` (69 : 88) and with careful bots (63 : 97); not followed up.

**Follow-up:** T39 (adopted rules in play; which Surge timer), T38 (Surge strength against avoidability), T03 (prices and frames in play, frames of the other stages, AP 3 bought by everyone, sturdy against middle), T13 (share under 3 rounds).

About 7 080 battles in 162 runs.

## S014 · 2026-11-13 · what a stat point is worth; a threat-aware AI

**State:** `c35396a` dirty (uncommitted) · content `2026-11-12.3` · kit set `164984ea835f`. Build rules as in S012; “draft” = `wells=3,flank,tpr2,latepressure=idle` (T39). 3v3, random teams on seeded boards, `--paired`, seeds 1–6 with 60 battles each (360 battles per row; the changed monster plays in 234–255 of them).

**Questions (user):** what are initiative, TPR, Movement, Reach, AP and HP worth, each changed alone on one monster; could 1 HP cost 2 or 3 points; do the fragile monsters lose because the AI plays them badly.

### Part A · one stat changed on one monster (`stat=monster.field:value`): win rate of that monster

Points = price of the change under [Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups) (HP, initiative, Movement 1 per point; Reach 3; AP 2→3 3, 3→4 5; second turn 5). Reference stats HP / Init / Move / TPR / Reach / AP: Ember Hawk 2 / 9 / 3 / 2 / 2 / 2, Gloom Wolf 5 / 6 / 2 / 1 / 3 / 3, Forge Golem 8 / 4 / 1 / 1 / 3 / 3.

| Monster · change (points) | Build rules: win rate · difference | Draft: win rate · difference |
|---|---|---|
| Ember Hawk, unchanged | 37.6 % | 29.7 % |
| HP 2 → 5 (+3) | 50.3 % · +12.7 | 46.8 % · +17.1 |
| HP 2 → 7 (+5) | 66.3 % · +28.7 | 55.6 % · +25.9 |
| Initiative 9 → 6 (−3) | 42.1 % · +4.5 | 40.9 % · +11.2 |
| Movement 3 → 6 (+3) | 43.4 % · +5.8 | 33.0 % · +3.3 |
| Reach 2 → 3 (+3) | 48.4 % · +10.8 | 30.7 % · +1.0 |
| AP 2 → 3 (+3) | 48.4 % · +10.8 | 32.9 % · +3.2 |
| TPR 2 → 1 (−5) | 27.5 % · −10.1 | 30.0 % · +0.3 |
| Gloom Wolf, unchanged | 51.3 % | 50.9 % |
| HP 5 → 8 (+3) | 66.8 % · +15.5 | 64.9 % · +14.0 |
| HP 5 → 10 (+5) | 73.7 % · +22.4 | 72.7 % · +21.8 |
| Initiative 6 → 9 (+3) | 53.9 % · +2.6 | 55.1 % · +4.2 |
| Movement 2 → 5 (+3) | 54.7 % · +3.4 | 53.4 % · +2.5 |
| Reach 3 → 4 (+3) | 55.4 % · +4.1 | 59.6 % · +8.7 |
| AP 3 → 4 (+5) | 62.3 % · +11.0 | 62.4 % · +11.5 |
| TPR 1 → 2 (+5) | 77.5 % · +26.2 | 63.2 % · +12.3 |
| Forge Golem, unchanged | 56.1 % | 61.7 % |
| HP 8 → 5 (−3) | 46.0 % · −10.1 | 46.5 % · −15.2 |
| Initiative 4 → 7 (+3) | 58.1 % · +2.0 | 62.7 % · +1.0 |
| Initiative 4 → 9 (+5) | 62.0 % · +5.9 | 60.7 % · −1.0 |
| Movement 1 → 4 (+3) | 56.1 % · 0.0 | 61.7 % · 0.0 |
| Reach 3 → 4 (+3) | 58.3 % · +2.2 | 58.8 % · −2.9 |
| AP 3 → 4 (+5) | 67.5 % · +11.4 | 64.2 % · +2.5 |
| TPR 1 → 2 (+5) | 84.2 % · +28.1 | 66.7 % · +5.0 |

The Golem's kit has no movement skill, so its Movement stat changes nothing (Step always moves 1 square).

### Part B · the AI with a threat count (`--bot-a careful --bot-b careful`; switch `ai_careful`)

The bot adds to `AiBrain`'s evaluation the Strike damage that enemies can bring to each of its monsters within one round (walk up, then strike with the AP left; no Surges, pushes, blocked paths or turn borders). A square where that is lethal costs 60 % of the monster's value, other threat 3.5 score points per point of damage.

| Rules · bots | Mean rounds | Under 3 / over 10 · longest | First defeat in round | Win rate Ember Hawk / Dusk Moth / Thorn Mites | Wisp / Tiger / Wolf | Golem / Turtle / Serpent |
|---|---|---|---|---|---|---|
| build rules · `greedy` | 5.1 | 14 / 7 % · 17 | 1.1 | 38 / 42 / 38 % | 53 / 41 / 51 % | 56 / 60 / 72 % |
| build rules · `careful` | 7.7 | 3 / 22 % · 22 | 1.4 | 38 / 48 / 37 % | 54 / 48 / 50 % | 43 / 59 / 74 % |
| draft · `greedy` | 3.8 | 22 / 2 % · 18 | 1.1 | 30 / 31 / 34 % | 54 / 61 / 51 % | 62 / 62 / 69 % |
| draft · `careful` | 4.8 | 13 / 6 % · 17 | 1.2 | 29 / 33 / 34 % | 62 / 56 / 58 % | 52 / 65 / 64 % |

Rounds and length shares from seeds 1–4 with 40 battles (160), win rates from seeds 1–6 with 60 (360). `careful` against `greedy`, both seatings, 720 battles each: the careful side wins 322 of 717 decided battles under the build rules (45 %) and 307 of 715 with the draft (43 %).

**Observations** (indications; bots only; a difference under about 6 points between two win rates is noise):

- *HP is worth four to six win-rate points per price point on all three monsters and under both rule sets;* initiative and Movement about one, Reach and AP between nothing and three and a half.
- *A second turn is worth as much as the body that takes it:* +26 and +28 points on Wolf and Golem under the build rules, 10 points on the 2-HP Hawk; with the draft (TPR from round 2, Wellsprings) +12 and +5, and nothing on the Hawk.
- *High initiative does not help the Hawk:* with 6 instead of 9 it wins more (4 and 11 points).
- *Careful play is not what the fragile monsters lack:* their win rates stay the same with the threat count, and the careful side loses to the uncareful one (43–45 %). Careful bots on both sides make battles longer (7.7 rounds and 22 % over 10 under the build rules; 4.8 rounds and 13 % under 3 with the draft).
- *Limits:* one monster per shape, one kit each; the threat count is rough and the bot still has no hit-and-run.

**Follow-up:** T03 (stat prices: HP against the rest; the price of a second turn depends on the body), T39 (with careful bots the draft gives 4.8 rounds and 13 % under 3), T13 (AI quality, I42).

About 18 300 battles in 308 runs (first careful runs with a script error discarded and repeated).

## S013 · 2026-11-13 · Wellspring draft: held centre squares that damage, surrounding, TPR from round 2, late-round pressure in three forms

**State:** `c35396a` dirty (uncommitted) · content `2026-11-12.3` · kit set `164984ea835f`. Build rules as in S012; the draft runs behind test switches that are off by default (the build-rules row is unchanged by the code). 3v3 on 7×7, `--paired`, bot `greedy` (the game AI, walks up) unless named.

**Draft (user, 2026-11-13; T39):** `wells=3`: three Wellspring squares on the centre row (x = 1, 3, 5); at the end of a round every Wellspring a monster stands on deals 1 damage to the nearest enemy (ties: more HP, more initiative, then roster order as a stand-in for the holder's choice). `flank`: a monster with two or more enemies on its eight neighbour squares takes 1 damage at the end of the round. `tpr2`: in round 1 every monster has one turn. `latepressure=none`: no late-round pressure; `idle`: pressure only at the end of a round in which nobody holds a Wellspring; without the key: pressure as in the rules (from round 8). The AI values a held Wellspring (9 score points, damage counts 10) and a surrounded monster (7), and walks toward a free Wellspring like toward an enemy.

**Questions (user):** does the draft end battles by fighting within 3–7 rounds, and what should happen to late-round pressure.

### Part A · random teams on seeded boards, four seeds (160 battles per row)

| Variant | Mean rounds | Under 3 / over 7 / over 10 · longest | Side 0 / 1 / draw / timeout | First defeat in round · defeated before own first turn | Wellsprings: last defeat / damage | Surrounded: last defeat / damage | Wellsprings held per round end, side 0 / 1 |
|---|---|---|---|---|---|---|---|
| build rules | 5.1 | 14 / 18 / 7 % · 17 | 76 / 83 / 1 / 0 | 1.1 · 0.14 | — | — | — |
| build rules, `latepressure=none` | 6.9 | 14 / 18 / 7 % · 298 | 75 / 83 / 1 / 1 | 1.1 · 0.14 | — | — | — |
| `wells=3,flank,tpr2,latepressure=none` | 3.8 | 22 / 6 / 2 % · 18 | 84 / 76 / 0 / 0 | 1.1 · 0.06 | 27 % / 14 % | 0 % / 0 % | 0.66 / 0.49 |
| the same, `latepressure=idle` | 3.8 | 22 / 6 / 2 % · 18 | 84 / 76 / 0 / 0 | 1.1 · 0.06 | 27 % / 14 % | 0 % / 0 % | 0.66 / 0.49 |
| the same, pressure as in the rules | 3.7 | 22 / 6 / 2 % · 16 | 84 / 76 / 0 / 0 | 1.1 · 0.06 | 27 % / 14 % | 0 % / 0 % | 0.66 / 0.49 |
| `wells=3,latepressure=none` | 5.9 | 21 / 6 / 3 % · 298 | 76 / 81 / 2 / 1 | 1.1 · 0.14 | 35 % / 14 % | — | 0.48 / 0.40 |
| `wells=3,latepressure=idle` | 4.0 | 21 / 6 / 3 % · 16 | 77 / 80 / 3 / 0 | 1.1 · 0.14 | 34 % / 14 % | — | 0.57 / 0.47 |
| `flank,latepressure=none` | 6.8 | 13 / 14 / 6 % · 298 | 77 / 82 / 0 / 1 | 1.1 · 0.14 | — | 1 % / 1 % | — |
| `tpr2,latepressure=none` | 7.9 | 13 / 15 / 8 % · 298 | 73 / 85 / 0 / 2 | 1.2 · 0.04 | — | — | — |
| `wells=3,flank,latepressure=none` | 5.6 | 24 / 5 / 2 % · 298 | 78 / 79 / 2 / 1 | 1.1 · 0.14 | 34 % / 14 % | 1 % / 0 % | 0.47 / 0.41 |
| `wells=3,tpr2,latepressure=none` | 3.8 | 20 / 5 / 1 % · 12 | 79 / 79 / 2 / 0 | 1.1 · 0.06 | 28 % / 14 % | — | 0.65 / 0.49 |
| `wells=1,flank,tpr2,latepressure=none` | 4.5 | 18 / 10 / 5 % · 17 | 77 / 83 / 0 / 0 | 1.2 · 0.04 | 8 % / 6 % | 0 % / 1 % | 0.21 / 0.20 |
| `wells=2,…` (x = 1, 5) | 5.7 | 25 / 7 / 2 % · 299 | 81 / 75 / 3 / 1 | 1.1 · 0.08 | 34 % / 14 % | 0 % / 0 % | 0.47 / 0.40 |
| `wells=5,…` | 3.5 | 30 / 3 / 0 % · 9 | 86 / 74 / 0 / 0 | 1.2 · 0.04 | 32 % / 18 % | 1 % / 1 % | 0.81 / 0.69 |

A mean that contains a timeout (longest 298 or 299) is pulled up by that single battle of 300 rounds.

### Part B · other bots and attacking against waiting (`wells=3,flank,tpr2`, 160 battles per row)

| Bots (side 0 / side 1) · pressure | Mean rounds | Under 3 / over 7 / over 10 · longest | Side 0 / 1 / draw / timeout | Wellsprings held per round end, side 0 / 1 |
|---|---|---|---|---|
| `chase` / `chase` · none | 4.1 | 19 / 7 / 2 % · 24 | 85 / 75 / 0 / 0 | 0.62 / 0.46 |
| `wait` / `wait` · none | 15.4 | 18 / 13 / 7 % · 298 | 77 / 75 / 0 / 8 | 0.27 / 0.18 |
| `wait` / `wait` · idle | 4.8 | 18 / 13 / 7 % · 17 | 82 / 76 / 2 / 0 | 0.53 / 0.41 |
| `greedy` / `wait` · none | 5.8 | 20 / 8 / 2 % · 294 | 90 / 69 / 0 / 1 | 0.58 / 0.33 |
| `wait` / `greedy` · none | 5.4 | 20 / 10 / 5 % · 198 | 77 / 81 / 1 / 1 | 0.43 / 0.48 |
| build rules: `greedy` / `wait` | 5.9 | 12 / 24 / 13 % · 20 | 67 / 91 / 2 / 0 | — |
| build rules: `wait` / `greedy` | 6.0 | 11 / 24 / 12 % · 19 | 77 / 83 / 0 / 0 | — |

The walking side wins 171 of 317 decided battles with the draft (54 %) and 150 of 318 under the build rules (47 %).

### Part C · the short end (`wells=3,flank,tpr2`, 160 battles per row)

| Variant | Mean rounds | Under 3 / over 7 / over 10 · longest | Side 0 / 1 / draw | First defeat in round · defeated before own first turn |
|---|---|---|---|---|
| `latepressure=none,startback` | 4.0 | 18 / 5 / 2 % · 18 | 79 / 79 / 2 | 1.2 · 0.02 |
| `latepressure=none,hpmin=3` | 3.9 | 18 / 4 / 2 % · 18 | 78 / 81 / 1 | 1.2 · 0.05 |
| `latepressure=none,startback,hpmin=3` | 4.0 | 15 / 4 / 2 % · 18 | 70 / 86 / 4 | 1.2 · 0.02 |
| `latepressure=idle,hpmin=4` | 4.0 | 20 / 5 / 2 % · 12 | 74 / 86 / 0 | 1.3 · 0.01 |
| `latepressure=idle,hp=1` (every monster +1 HP) | 4.1 | 16 / 7 / 2 % · 13 | 73 / 84 / 3 | 1.2 · 0.01 |
| `latepressure=idle,hp=2` | 4.4 | 9 / 8 / 2 % · 23 | 76 / 84 / 0 | 1.5 · 0.01 |
| `latepressure=idle,hp=1,startback` | 4.1 | 13 / 2 / 0 % · 10 | 77 / 83 / 0 | 1.3 · 0.00 |

### Part D · team types (teams and reading as in S012 Part B; one seed, 40 battles per cell)

| Variant | T beats F | T beats M | M beats F | T mirror | M mirror | F mirror | random |
|---|---|---|---|---|---|---|---|
| build rules (S012) | 75 / 80 | 63 / 80 | 73 / 80 | 9.0 · 0 % · 25 % | 3.3 · 25 % · 0 % | 2.0 · 75 % · 0 % | 5.2 · 9 % · 6 % |
| `wells=3,flank,tpr2,latepressure=none` | 77 / 80 | 45 / 80 | 78 / 80 | 7.0 · 0 % · 8 % | 2.6 · 53 % · 0 % | 2.3 · 75 % · 0 % | 3.8 · 25 % · 2 % |
| …`latepressure=idle,startback,hpmin=3` | 70 / 80 | 45 / 80 | 79 / 80 | 7.0 · 0 % · 8 % | 2.6 · 53 % · 0 % | 2.4 · 65 % · 0 % | 4.0 · 16 % · 2 % |
| …`latepressure=idle,hp=1` | 78 / 80 | 42 / 80 | 80 / 80 | 7.2 · 0 % · 8 % | 3.0 · 28 % · 0 % | 2.4 · 68 % · 0 % | 4.0 · 20 % · 2 % |
| …`latepressure=idle,hp=2` | 73 / 80 | 41 / 80 | 78 / 80 | 8.2 · 0 % · 20 % | 3.3 · 18 % · 0 % | 2.6 · 53 % · 0 % | 4.4 · 12 % · 2 % |
| …`latepressure=idle,hpmin=4` | 63 / 80 | 45 / 80 | 77 / 80 | 7.0 · 0 % · 8 % | 2.6 · 53 % · 0 % | 2.4 · 70 % · 0 % | 3.9 · 18 % · 2 % |

### Part E · who falls in round 1 and why (`wells=3,flank,tpr2,latepressure=idle`, seeds 1–4, 160 battles, `SIM_DEBUG`)

| Figure | Value |
|---|---|
| Battles with a defeat in round 1 | 143 of 160 |
| Defeats in round 1 / in all rounds | 227 / 664 |
| Round-1 victims by max HP | 2 HP: 158 (Ember Hawk 79, Dusk Moth 79) · 3 HP: 19 · 4 HP: 35 · 5 HP: 15 · 7–8 HP: 0 |
| Victim had already taken its turn of the round | 218 of 227 |
| Killed by a single damage instance | 125 of 227 |
| Killing hit | Surge 100 (Eclipse 29, Magma Pounce 27, Gloom Rift 20, Cinder Dive 17, Coiling Rift 7) · collision 51 (monster or prop 38, board edge 13) · Jab 48 · Wellspring 9 · surrounded 9 · prop aftermath 8 · trap 2 |
| Side of the victim | side 0: 111 · side 1: 116 |

- *Reading:* the monsters with the highest initiative act first, walk toward the Wellsprings and the enemy, and have no turn left in the round; every slower monster then acts with them in reach. With 2 HP a Jab (2) or a Surge (3) is one hit. A Surge counts two finished turns of any monster, so on a monster that has already acted it cannot be left: with one turn per monster in round 1 (`tpr2`) the fast monsters have lost their second turn as a way out. The Wellsprings and the surround rule cause 18 of the 227 defeats.

### Part F · postponing a turn and Surges that fire at their caster's next turn (`wells=3,flank,tpr2,latepressure=idle` plus the named switches; 160 battles per row)

`delay`: before it has acted, a monster may move its queue entry to the end of the round's queue, once per round. The AI does so when its best first action gains less than 3 score points and an enemy still acts later. `castersurge`: a timed Surge detonates at the start of its caster's next turn (the rule before 2026-11-12) instead of after two finished turns of any monster; traps are unchanged.

| Variant | Mean rounds | Under 3 / over 7 / over 10 · longest | Side 0 / 1 | First defeat in round · defeated before own first turn | Surge share of damage · damage per cast on enemies |
|---|---|---|---|---|---|
| draft without both | 3.8 | 22 / 6 / 2 % · 18 | 84 / 76 | 1.1 · 0.06 | 38 % · 0.98 |
| + `delay` | 3.9 | 22 / 7 / 1 % · 14 | 78 / 82 | 1.1 · 0.02 | — |
| + `castersurge` | 3.9 | 14 / 2 / 0 % · 9 | 87 / 73 | 1.3 · 0.02 | — |
| + `delay,castersurge` | 4.0 | 11 / 6 / 1 % · 13 | 84 / 76 | 1.3 · 0.01 | 19 % · 0.49 |
| + both, TPR from round 1 | 4.1 | 21 / 5 / 3 % · 18 | 82 / 78 | 1.1 · 0.07 | — |
| build rules + both (no Wellsprings) | 5.5 | 14 / 22 / 8 % · 19 | 74 / 86 | 1.2 · 0.04 | — |

| Round 1 with `delay,castersurge` (seeds 1–4, `SIM_DEBUG`) | Value (without both: Part E) |
|---|---|
| Battles with a defeat in round 1 | 115 of 160 (143) |
| Defeats in round 1 | 135 (227) |
| Victims with 2 HP | 108 (158) |
| Killing hit | collision 61 · Jab 57 · surrounded 7 · Wellspring 4 · trap 3 · aftermath 3 · Surge 0 (Surge 100) |

Team types with `delay,castersurge` (reading as in Part D): T beats F 77 / 80, T beats M 35 / 80, M beats F 80 / 80; T mirror 8.7 rounds · 0 % under 3 · 25 % over 10; M mirror 2.9 · 40 % · 0 %; F mirror 2.5 · 60 % · 0 %; random 4.0 · 13 % · 0 %. Walking against waiting bots: the walking side wins 169 of 319 (53 %).

- *Reading:* the Surge rule is what moves the short end (22 % to 14 % under 3 rounds, no Surge kill in round 1 any more); postponing alone changes nothing measurable with this bot rule and adds a little on top (11 %). The price: Surges deal half as much (0.49 instead of 0.98 damage per cast, 19 % instead of 38 % of all damage), and the sturdy mirror, which lives on Surges, is long again (8.7 rounds, 25 % over 10). Round 1 still costs a 2-HP monster in most battles, now by a Jab or a push.

### Part G · one-time bonus squares: shield, one more turn, both (`boon=`; 160 battles per row)

Four squares on the centre row between and beside the Wellsprings (x = 0, 2, 4, 6). The first monster standing on one takes it and the square turns Plain. `shield`: the monster ignores its next damage instance of at least 1. `turn`: one more turn at the end of the current round. `both`: shield on x = 2 and 4, turn on x = 0 and 6. No prop or Mountain on them. The AI counts 7 score points per square taken (a held Wellspring: 9) and walks toward an untaken square. Base I = `wells=3,flank,tpr2,latepressure=idle`; base II = base I + `delay,castersurge`.

| Base · bonus | Mean rounds | Under 3 / over 7 / over 10 · longest | Side 0 / 1 | Defeats in round 1 (of them 2-HP monsters) · battles with one | Bonus squares taken per battle, side 0 / 1 | Win rate Ember Hawk / Dusk Moth / Thorn Mites |
|---|---|---|---|---|---|---|
| I · none | 3.8 | 22 / 6 / 2 % · 18 | 84 / 76 | 227 (158) · 143 | — | 29 / 29 / 35 % |
| I · shield | 3.9 | 20 / 5 / 1 % · 14 | 81 / 79 | 203 (143) · 142 | 1.30 / 1.08 | 35 / 30 / 31 % |
| I · turn | 3.4 | 39 / 4 / 0 % · 8 | 85 / 73 | 269 (166) · 150 | 1.23 / 1.13 | 30 / 26 / 29 % |
| I · both | 3.5 | 30 / 3 / 1 % · 11 | 86 / 74 | 234 (153) · 146 | 1.29 / 1.10 | 33 / 23 / 36 % |
| II · none | 4.0 | 11 / 6 / 1 % · 13 | 84 / 76 | 135 (108) · 115 | — | 42 / 29 / 22 % |
| II · shield | 4.2 | 7 / 8 / 1 % · 11 | 77 / 81 | 115 (90) · 102 | 1.47 / 1.31 | 41 / 30 / 36 % |
| II · turn | 3.5 | 27 / 4 / 1 % · 12 | 86 / 74 | 219 (122) · 137 | 1.41 / 1.31 | 38 / 29 / 31 % |
| II · both | 3.9 | 17 / 4 / 2 % · 13 | 87 / 72 | 147 (97) · 116 | 1.46 / 1.44 | 43 / 33 / 32 % |

Who took the 356 squares of “I · both”: Gloom Wolf 71, Blaze Tiger 66, Forge Golem 53, Grove Wisp 48, Moss Turtle 48, Dusk Moth 33, Hollow Serpent 33, Ember Hawk 18, Thorn Mites 13; 147 of them in round 1, 167 in round 2.

- *Reading:* the shield helps a little at the short end (22 to 20 %, on base II 11 to 7 % under 3 rounds; 20–24 fewer defeats in round 1 over 160 battles). The extra turn makes the opening harsher (39 and 27 % under 3 rounds, more defeats in round 1): one more turn in round 1 is one more attack. Both together lie in between. The fragile monsters do not win more with any of them (differences within the noise of about ±8 points), and they are not the ones who take the squares: the monsters that act first take a Wellspring (the AI values it higher and it lies on the same row), the next ones the bonus squares. Whether a player would send a fast monster for the shield first is not something these bots show.

### Part H · shield squares nearer to the start rows (`boon=<layout>`; the extra-turn square was removed after Part G; 160 battles per row)

Layouts on 7×7, given for side 0 and mirrored for side 1 (start squares (1,5), (3,6), (5,5); Wellsprings (1,3), (3,3), (5,3)): `centre` = Part G “shield” (four on the centre row) · `near` (2,4) (4,4) · `path` (1,4) (5,4), in front of the outer Wellsprings · `each` (1,4) (3,4) (5,4) · `one` (3,4). Base I and II as in Part G.

| Base · layout | Mean rounds | Under 3 / over 7 / over 10 · longest | Side 0 / 1 / draw |
|---|---|---|---|
| I · none | 3.8 | 22 / 6 / 2 % · 18 | 84 / 76 / 0 |
| I · centre | 3.9 | 20 / 5 / 1 % · 14 | 81 / 79 / 0 |
| I · near | 4.0 | 20 / 7 / 3 % · 13 | 82 / 73 / 5 |
| I · path | 3.8 | 22 / 3 / 1 % · 13 | 82 / 77 / 1 |
| I · each | 3.8 | 25 / 5 / 1 % · 11 | 65 / 95 / 0 |
| I · one | 3.6 | 24 / 3 / 2 % · 12 | 89 / 71 / 0 |
| II · none | 4.0 | 11 / 6 / 1 % · 13 | 84 / 76 / 0 |
| II · centre | 4.2 | 7 / 8 / 1 % · 11 | 77 / 81 / 2 |
| II · near | 4.2 | 11 / 4 / 1 % · 11 | 81 / 78 / 1 |
| II · path | 4.2 | 13 / 4 / 3 % · 16 | 74 / 85 / 1 |
| II · each | 4.1 | 12 / 4 / 0 % · 10 | 76 / 81 / 3 |
| II · one | 4.0 | 11 / 2 / 1 % · 15 | 86 / 74 / 0 |

| Base II · layout | Defeats in round 1 (2-HP monsters) · battles with one | Squares taken · by Hawk, Moth, Mites · in round 1 | Win rate Ember Hawk / Dusk Moth / Thorn Mites |
|---|---|---|---|
| none | 135 (108) · 115 | — | 42 / 29 / 22 % |
| centre | 115 (90) · 102 | 443 · 103 · 111 | 41 / 30 / 36 % |
| near | 126 (103) · 106 | 482 · 130 · 255 | 52 / 35 / 23 % |
| path | 122 (106) · 102 | 506 · 116 · 352 | 41 / 32 / 29 % |
| each | 119 (97) · 97 | 754 · 209 · 473 | 34 / 28 / 29 % |
| one | 116 (89) · 95 | 278 · 102 · 216 | 44 / 34 / 23 % |

- *Reading:* nearer squares are taken earlier (255–473 in round 1 instead of 111) but change neither the short end (11–13 % under 3 rounds on base II, as without squares) nor the defeats of 2-HP monsters in round 1 (89–106 against 108) nor the win rates of the fragile monsters (within noise). The three fragile species take about their share of the squares (a quarter to a third), not more. The 7 % of the centre layout is the lowest value, but 160 battles separate it from 11 % only weakly. A shield takes one hit; a 2-HP monster in reach of two enemies falls to the second.

**Observations** (indications; bots only; 160 battles per row in Parts A–C, 40 per cell in Part D):

- *The Wellsprings mostly end battles without late-round pressure:* 3.8 rounds, 2 % over 10 rounds, longest 18, no timeout in 160 battles with the full draft (single timeouts in the rows without `tpr2` or with two Wellsprings); with pressure as in the rules or in the idle form the figures are the same, because pressure is not reached. Under the build rules without pressure one battle in 160 does not end.
- *A brake is still needed when nobody takes a Wellspring:* waiting bots hold 0.45 Wellsprings per round end together and 8 of 160 battles do not end; with pressure only in rounds without a held Wellspring none does (4.8 rounds).
- *Walking up beats waiting:* 54 % against 47 % under the build rules.
- *The battles get short rather than long:* 22 % under 3 rounds (build rules 14 %); the first defeat still falls in round 1. One turn per monster in round 1 lowers the defeats before a monster's first turn from 0.14 to 0.06 per battle; it does not move the first defeat. One more HP for everyone with back-row starts gives 13 % under 3 rounds, none over 10 and 4.1 rounds; two more HP 9 % and 4.4 rounds.
- *Surrounding does not show in bot play:* 0–1 % of the damage with or without the AI term; the bots do not set it up. The runs say nothing about this rule.
- *Wellspring count:* one gives 4.5 rounds and 6 % of the damage, three 3.8 and 14 %, five 3.5 and 18 % with 30 % of battles under 3 rounds. With two (x = 1, 5) one battle in 160 does not end without pressure, as with three Wellsprings and TPR from round 1.
- *Team types:* the sturdy trio no longer beats the middle one (45 of 80, build rules 63) and its mirror is shorter (7.0 rounds, 8 % over 10). The fragile trio still loses nearly every battle against both, at any HP level tried; the middle mirror gets very short (2.6 rounds, 53 % under 3).

**Follow-up:** T39 (the draft: user play, the last tie-break, the pressure form, the short end), T03/T12 (fragile shapes at fixed damage), T13 (share under 3 rounds as the main open metric).

About 6 960 battles in 174 runs.

## S012 · 2026-11-12 · new build rules (ground clock, one trap per skill, no shield zones in kits, AI walks up); why sturdy teams win and last long

**State:** `c35396a` dirty (uncommitted) · content `2026-11-12.3` · kit set `164984ea835f`. **Build rules since S011** (user decision 2026-11-12): ground laid during a battle lasts 2 rounds, a monster holds one trap per trap skill, Moss Turtle carries Mire instead of Bark Veil and Dusk Moth Blink instead of Shade Veil, and `AiBrain` walks toward the nearest enemy instead of ending a turn with AP left. The bot `greedy` is this AI now (`hunt` is the same bot); `wait` is the AI as it was. 3v3 on 7×7, late-round pressure from round 8, `--paired`.

**Questions (user):** why do three slow, sturdy monsters need so long against each other and beat three fragile ones almost always, and what would change it.

**Teams.** T = Forge Golem, Moss Turtle, Hollow Serpent (HP 8 / 8 / 7, Movement 1 / 2 / 2, TPR 1, AP 3). M = Blaze Tiger, Gloom Wolf, Grove Wisp (HP 5 / 5 / 4, Movement 4 / 2 / 4, TPR 1, AP 3). F = Dusk Moth, Ember Hawk, Thorn Mites (HP 2 / 2 / 3, Movement 3 / 3 / 2, TPR 2, AP 2). Fixed teams play on an empty board with mirrored start squares; each pairing is played in both seatings (2 × 40 battles), mirrors once (40). “random” = random teams on seeded boards, two seeds (80 battles). Per row about 440 battles; one seed unless the row says “seed 2”. Round figures: mean · share under 3 · share over 10.

### Part A · the new build rules, random teams, four seeds (160 battles per row)

| Bots (both sides) | Mean rounds | Ended before pressure | Last defeat by collapse | Under 3 / over 7 / over 10 · longest | Side 0 : side 1 |
|---|---|---|---|---|---|
| `greedy` (walks up, the game AI) | 5.1 | 87 % | 1 % | 14 / 18 / 7 % · 17 | 76 : 83 |
| `chase` | 5.8 | 81 % | 3 % | 14 / 24 / 12 % · 20 | 80 : 80 |
| `wait` (AI up to S011) | 7.5 | 72 % | 20 % | 8 / 37 / 23 % · 24 | 74 : 82 |

For comparison, candidate R of S011 (trap clock instead of the trap limit, veil slots dead instead of replaced) over eight seeds: 4.6 / 5.2 / 6.9 rounds.

### Part B · team types against each other and single changes (`--variant`, this run only)

| Variant | T beats F | T beats M | M beats F | T mirror | M mirror | F mirror | random |
|---|---|---|---|---|---|---|---|
| build rules | 75 / 80 | 63 / 80 | 73 / 80 | 9.0 · 0 % · 25 % | 3.3 · 25 % · 0 % | 2.0 · 75 % · 0 % | 5.2 · 9 % · 6 % |
| build rules, seed 2 | 75 / 80 | 68 / 80 | 75 / 80 | 8.6 · 0 % · 20 % | 2.9 · 45 % · 0 % | 1.7 · 90 % · 0 % | 5.3 · 16 % · 8 % |
| `hpmin=3,hpmax=6` | 53 / 80 | 47 / 80 | 68 / 80 | 7.2 · 0 % · 8 % | 3.3 · 25 % · 0 % | 2.0 · 83 % · 0 % | 4.8 · 12 % · 6 % |
| `hpmin=4,hpmax=6` | 36 / 80 | 47 / 80 | 56 / 80 | 7.2 · 0 % · 8 % | 3.3 · 25 % · 0 % | 2.3 · 70 % · 0 % | 4.8 · 10 % · 6 % |
| `hpmin=4,hpmax=6`, seed 2 | 48 / 80 | 49 / 80 | 68 / 80 | 8.6 · 0 % · 33 % | 2.9 · 45 % · 0 % | 2.2 · 78 % · 0 % | 4.0 · 20 % · 0 % |
| `hpmin=3,hpmax=5` | 39 / 80 | 30 / 80 | 68 / 80 | 8.1 · 0 % · 20 % | 3.3 · 25 % · 0 % | 2.0 · 83 % · 0 % | 4.2 · 22 % · 2 % |
| `apmin=3` (F with 3 AP per turn) | 55 / 80 | 63 / 80 | 68 / 80 | 9.0 · 0 % · 25 % | 3.3 · 25 % · 0 % | 1.4 · 100 % · 0 % | 4.7 · 16 % · 6 % |
| `strikedmg=3` | 72 / 80 | 69 / 80 | 72 / 80 | 9.9 · 0 % · 30 % | 3.1 · 23 % · 0 % | 1.9 · 83 % · 0 % | 4.5 · 13 % · 2 % |
| `turns=1` (Surges fire after 1 turn) | 69 / 80 | 68 / 80 | 73 / 80 | 6.4 · 0 % · 3 % | 2.9 · 33 % · 0 % | 1.9 · 88 % · 0 % | 3.9 · 25 % · 2 % |
| `alltimed` (every trap a Surge) | 68 / 80 | 62 / 80 | 69 / 80 | 6.9 · 0 % · 0 % | 3.1 · 30 % · 0 % | 2.0 · 68 % · 0 % | 4.8 · 14 % · 5 % |
| `step=2` | 75 / 80 | 40 / 80 | 75 / 80 | 9.2 · 0 % · 30 % | 3.4 · 23 % · 0 % | 2.0 · 80 % · 0 % | 5.6 · 6 % · 4 % |
| T +1 Movement (`stat=`: Golem 2, Turtle 3, Serpent 3) | 75 / 80 | 67 / 80 | 73 / 80 | 5.9 · 0 % · 5 % | 3.3 · 25 % · 0 % | 2.0 · 75 % · 0 % | 4.3 · 14 % · 2 % |
| T +1 Movement, seed 2 | 74 / 80 | 70 / 80 | 75 / 80 | 6.3 · 0 % · 8 % | 2.9 · 45 % · 0 % | 1.7 · 90 % · 0 % | 4.3 · 23 % · 3 % |

### Part C · HP band and Movement together

| Variant | T beats F | T beats M | M beats F | T mirror | M mirror | F mirror | random |
|---|---|---|---|---|---|---|---|
| `hpmin=4,hpmax=6` + T +1 Movement | 44 / 80 | 50 / 80 | 56 / 80 | 5.3 · 0 % · 0 % | 3.3 · 25 % · 0 % | 2.3 · 70 % · 0 % | 4.0 · 16 % · 2 % |
| the same, seed 2 | 48 / 80 | 44 / 80 | 68 / 80 | 5.6 · 0 % · 0 % | 2.9 · 45 % · 0 % | 2.2 · 78 % · 0 % | 3.6 · 24 % · 0 % |
| `hpmin=4,hpmax=6` + only Golem Movement 2 | 36 / 80 | 47 / 80 | 56 / 80 | 7.2 · 0 % · 8 % | 3.3 · 25 % · 0 % | 2.3 · 70 % · 0 % | 4.0 · 25 % · 3 % |
| `hpmin=3,hpmax=6` + T +1 Movement | 54 / 80 | 50 / 80 | 68 / 80 | 5.3 · 0 % · 0 % | 3.3 · 25 % · 0 % | 2.0 · 83 % · 0 % | 3.8 · 26 % · 0 % |
| the same, seed 2 | 55 / 80 | 44 / 80 | 68 / 80 | 5.6 · 0 % · 0 % | 2.9 · 45 % · 0 % | 1.9 · 88 % · 0 % | 3.8 · 32 % · 4 % |
| `hpmin=4,hpmax=7` + T +1 Movement | 61 / 80 | 62 / 80 | 56 / 80 | 5.9 · 0 % · 3 % | 3.3 · 25 % · 0 % | 2.3 · 70 % · 0 % | 3.9 · 16 % · 2 % |
| `hpmin=4,hpmax=6` + T +1 Movement + `startback` | 44 / 80 | 50 / 80 | 56 / 80 | 5.3 · 0 % · 0 % | 3.3 · 25 % · 0 % | 2.3 · 70 % · 0 % | 4.1 · 26 % · 0 % |
| `hpmin=4,hpmax=6` + T +1 Movement + `tprmax=1,apmin=3` | 50 / 80 | 50 / 80 | 66 / 80 | 5.3 · 0 % · 0 % | 3.3 · 25 % · 0 % | 2.6 · 53 % · 0 % | 4.3 · 23 % · 4 % |
| `hpmin=4,hpmax=6` + T +1 Movement + `tprmax=1` | 77 / 80 | 50 / 80 | 79 / 80 | 5.3 · 0 % · 0 % | 3.3 · 25 % · 0 % | 3.8 · 20 % · 0 % | 4.4 · 8 % · 4 % |

### Part D · inside the T mirror (full blocks, seed 1, 40 battles)

| Variant | Mean rounds | Damage per battle | Step / Jab uses per battle | Surges and traps declared · damage per marker |
|---|---|---|---|---|
| build rules | 9.0 | 40.4 | 22.9 / 4.9 | 968 · 0.98 |
| `hpmin=4,hpmax=6` + T +1 Movement | 5.3 | 32.4 | 11.7 / 5.0 | 519 · 1.28 |

**Observations** (indications; bots only; 40 battles per cell, so differences under about 8 of 80 wins or 1 round are noise):

- *The new build rules behave like candidate R:* 5.1 rounds with the game AI, 87 % ended before pressure, 7 % over 10 rounds. The waiting AI is still slower (7.5 rounds, 23 % over 10).
- *The order T > M > F follows the HP sum (23 / 14 / 7):* with every monster between 4 and 6 HP the three team types are close to level (T beats F 36–48 of 80, T beats M 47–49, M beats F 56–68). More AP for F, more Strike damage, faster Surges or a dearer Step do not change the order.
- *The length of the T mirror follows Movement, not HP:* one more Movement for the three brings it from 9.0 to 5.9 rounds (seed 2: 8.6 to 6.3); the HP band alone 7.2 and 8.6. Under the build rules the three take 23 Steps per battle and land 5 Jabs, and a marker deals 0.98 of its 2–3 damage.
- *Both together:* T mirror 5.3–5.6 rounds, none over 10 in 80 battles; random teams 3.6–4.0 rounds, with 16–24 % under 3 rounds (build rules 9–16 %).
- *The F mirror is the opposite problem and no HP value changes it:* 1.7–2.3 rounds, 70–90 % under 3 rounds, one monster per battle defeated before its first turn. With TPR 1 for everyone it lasts 3.8 rounds (20 % under 3), but then F loses to T and M again (77 and 79 of 80).
- *Noise:* the HP band rows of the T mirror differ between seeds (7.2 and 8.6 rounds); `hpmin=3,hpmax=5` gives a longer T mirror than `hpmin=3,hpmax=6` on one seed.

**Follow-up:** T03 (HP against TPR and initiative in the stat prices: a second turn costs as much as 5 HP and is worth far less here), T12 (reference individuals: HP band, Movement of the slow shapes), T13 (team-type matrix as a standing check; the F mirror and the share under 3 rounds), T38 (the build rules of this entry in play).

About 10 960 battles in 276 runs.

## S011 · 2026-11-12 · why waiting pays: board fill; ground and traps with a clock, no shield zones; value of each skill kind

**State:** `c35396a` dirty (uncommitted: new test switches, bots and `sim.gd` options; the rules of the build are unchanged with all switches off: the build-rules row of S010 is reproduced bit for bit) · content `2026-11-12.2` · kit set `736eb4e604a6` (`swap` variants change the kits for the run only). 3v3 on seeded draft boards unless a row names another mode. About 57 680 battles in 1 460 runs; the tables hold the ones the observations rest on.

**Questions (user, 2026-11-12):** which combination of changes makes 3v3 battles end by fighting within 3–7 rounds (over 10 rounds counts as a failure), deterministic and with few uniform rules; are all skill kinds viable or does one decide alone. S010 showed that the bot that walks up loses to the bot that waits, so the first question here is what makes waiting pay.

**How to read the tables.** Rows are means over the named runs, computed from the compact rows of the tool (40 battles per run, 20 with the planning bot); only parts D and F paste tool rows unchanged. Every run is reproducible: `sim.gd -- 40 3v3 <seed> "c35396a dirty" --paired --compact --variant <variant> --bot-a <bot> --bot-b <bot> [--pressure 200] [--no-kind-a|b <kind>]`. *Wins of `hunt` against the waiting `AiBrain`:* `hunt` on side 0 and on side 1, seeds 1 and 2 (160 battles) in parts A and B, seeds 1–4 (320 battles) in part C; a share under 50 % means that walking up loses to waiting. One share of 160 battles has a standard error of about 4 points, one of 320 about 3.

| Switch (`--variant`, new in this entry unless noted) | What it does |
|---|---|
| `groundfade=N` | ground laid during the battle (skill, Surge residue, prop aftermath) turns back into Plain at the end of the N-th round, counting the round it was laid or levelled in (N = 2: like a zone of duration 2). Ground of the starting board, Rubble of a destroyed Mountain and Voidscar stay |
| `trapfade=N` | a trap nobody sprang lapses at the end of the N-th round, counting the round it was set in |
| `trapcap=N` | a monster holds at most N traps per trap skill; one more removes its oldest trap of that skill |
| `noshield` (S007) | shield zone skills cannot be used; the slot stays in the kit. Now a switch of the battle (`no_shield_zones`) instead of an AP hack; rows are identical |
| `shield=N` | shield zones reduce Surge damage by N at every level (build: 2, up to 3) |
| `swap=old>new` | every kit holding skill `old` holds `new` instead for this run. “mire / blink” = `swap=bark_veil>mire,swap=shade_veil>blink` (Moss Turtle, Dusk Moth); “bog / void_pull” and the others likewise |
| `hp=±N`, `hpmin=N`, `hpmax=N`, `tprmax=N`, `apmin=N`, `surgedmg=±N`, `strikedmg=N` | reference HP of all monsters shifted or clamped; turns per round capped, AP raised to a minimum; damage of all Surges and traps shifted; Strike damage set |
| `zoneonce`, `castonce` | every zone skill, or every zone, Surge, trap and board skill, once per round |
| `startback` | every monster starts on the back row (3v3: 6 instead of 4 squares between the lines) |
| `softpressure`, `jab`, `step`, `move`, `turns`, `alltimed`, `alltraps`, `push`, `norotate`, `defap`, `shield-once` | as in S007–S010 |
| bot `hunt` (S010) | `AiBrain` that walks toward the nearest enemy instead of ending a turn with AP left |
| bot `chase` | `hunt`, but only while its side is not ahead in total HP: the side that would win by waiting for late-round pressure waits, the other has to come |
| `--no-kind-a` / `--no-kind-b <kind>` | the bot of that side never uses skills of the kind (strike, surge, trap, zone, ground = board skills, move); the Step stays |

### Part A · single switches on the build rules

| Variant | Wins of `hunt` against the waiting `AiBrain` (160 battles) | `hunt` on both sides: mean rounds | Ended before pressure | Collapse endings | Rounds under 3 / over 7 / over 10 (%) · longest |
|---|---|---|---|---|---|
| build rules | 44 % | 8.4 | 59 % | 8 % | 14 / 42 / 34 · 22 |
| `noshield` | 42 % | 5.6 | 83 % | 2 % | 15 / 19 / 13 · 19 |
| `jab=1` | 41 % | 6.4 | 78 % | 9 % | 22 / 28 / 22 · 21 |
| `softpressure=2` | 48 % | 6.6 | 60 % | 0 % | 14 / 42 / 19 · 16 |
| `shield-once` | 47 % | 7.8 | 66 % | 5 % | 12 / 38 / 28 · 22 |
| `defap=3` | 46 % | 7.0 | 69 % | 9 % | 14 / 34 / 28 · 20 |
| `alltimed` | 46 % | 6.7 | 73 % | 5 % | 14 / 30 / 22 · 20 |
| `alltraps` | 42 % | 10.8 | 45 % | 30 % | 8 / 64 / 46 · 21 |
| `turns=1` | 44 % | 6.7 | 70 % | 8 % | 20 / 33 / 26 · 21 |
| `turns=3` | 41 % | 8.5 | 60 % | 8 % | 8 / 43 / 35 · 21 |
| `step=2` | 46 % | 8.1 | 62 % | 9 % | 12 / 42 / 29 · 19 |
| `move=2` | 36 % | 8.4 | 64 % | 10 % | 4 / 40 / 32 · 20 |
| `push=2` | 42 % | 7.3 | 70 % | 8 % | 10 / 32 / 28 · 18 |
| `norotate` | 36 % | 8.9 | 56 % | 14 % | 12 / 44 / 39 · 21 |
| `strikedmg=1` | 44 % | 8.4 | 62 % | 16 % | 10 / 43 / 38 · 22 |
| `strikedmg=3` | 44 % | 7.8 | 66 % | 8 % | 9 / 34 / 29 · 20 |
| `surgedmg=-1` | 40 % | 7.3 | 70 % | 8 % | 10 / 34 / 25 · 20 |
| `surgedmg=1` | 44 % | 7.8 | 66 % | 14 % | 12 / 38 / 32 · 23 |
| `hp=-1` | 46 % | 6.8 | 73 % | 6 % | 10 / 34 / 22 · 19 |
| `hp=1` | 42 % | 8.1 | 63 % | 9 % | 10 / 43 / 33 · 22 |
| `hpmin=4,hpmax=6` | 38 % | 7.2 | 70 % | 3 % | 12 / 33 / 25 · 20 |
| `startback` | 41 % | 8.3 | 65 % | 10 % | 10 / 38 / 32 · 24 |
| `groundfade=2` | 50 % | 6.3 | 79 % | 2 % | 14 / 25 / 14 · 20 |
| `groundfade=3` | 49 % | 6.8 | 74 % | 3 % | 14 / 30 / 19 · 20 |
| `trapfade=2` | 39 % | 7.2 | 69 % | 4 % | 14 / 36 / 25 · 18 |
| `trapfade=3` | 41 % | 7.5 | 64 % | 6 % | 14 / 38 / 28 · 19 |
| `groundfade=2,trapfade=2` | 48 % | 5.5 | 88 % | 2 % | 14 / 20 / 6 · 16 |
| `groundfade=3,trapfade=3` | 52 % | 6.6 | 74 % | 2 % | 14 / 32 / 18 · 19 |
| `groundfade=2,noshield` | 50 % | 4.5 | 92 % | 0 % | 15 / 12 / 2 · 13 |
| `groundfade=2,trapfade=2,noshield` | 51 % | 4.5 | 92 % | 0 % | 15 / 12 / 2 · 13 |

### Part B · replacement skills and further switches on the candidates

G = `groundfade=2`; C = `groundfade=2,trapfade=2` with mire / blink; R = `groundfade=2,trapfade=2,noshield`. “a / b” replaces Bark Veil by a and Shade Veil by b.

| Variant | Wins of `hunt` against the waiting `AiBrain` (160 battles) | `hunt` on both sides: mean rounds | Ended before pressure | Collapse endings | Rounds under 3 / over 7 / over 10 (%) · longest |
|---|---|---|---|---|---|
| G + mire / blink | 49 % | 5.4 | 84 % | 2 % | 10 / 19 / 8 · 17 |
| G + bog / void_pull | 46 % | 4.2 | 95 % | 0 % | 23 / 9 / 4 · 19 |
| G + strike_arc / void_pull | 50 % | 5.0 | 90 % | 2 % | 18 / 12 / 6 · 17 |
| G + raise_ground / void_pull | 48 % | 5.1 | 89 % | 0 % | 16 / 14 / 8 · 22 |
| G + void_pull / mire | 43 % | 4.2 | 96 % | 0 % | 18 / 9 / 3 · 17 |
| G + strike_arc / strike_thrust | 49 % | 4.7 | 89 % | 2 % | 16 / 14 / 4 · 17 |
| mire / blink without G | 44 % | 6.8 | 72 % | 2 % | 10 / 32 / 23 · 19 |
| `groundfade=1` + mire / blink | 45 % | 5.6 | 86 % | 0 % | 9 / 19 / 9 · 18 |
| `groundfade=3` + mire / blink | 42 % | 6.2 | 78 % | 2 % | 10 / 29 / 14 · 19 |
| G + mire / blink + `trapfade=2` (= C) | 49 % | 5.3 | 82 % | 0 % | 10 / 20 / 6 · 13 |
| C + `hpmin=3` | 51 % | 5.3 | 88 % | 0 % | 13 / 15 / 6 · 20 |
| C + `hpmin=4` | 49 % | 5.4 | 86 % | 2 % | 12 / 20 / 10 · 15 |
| C + `hpmin=3,hpmax=6` | 46 % | 4.6 | 93 % | 0 % | 12 / 9 / 3 · 11 |
| C + `startback` | 48 % | 5.7 | 85 % | 2 % | 15 / 22 / 8 · 17 |
| C + `hpmin=3,startback` | 48 % | 5.7 | 84 % | 2 % | 9 / 25 / 8 · 16 |
| C + `hpmin=4,startback` | 45 % | 6.0 | 86 % | 2 % | 6 / 26 / 9 · 17 |
| C + `turns=3` | 50 % | 5.7 | 86 % | 0 % | 6 / 22 / 8 · 14 |
| C + `hpmin=3,turns=3` | 45 % | 5.3 | 88 % | 2 % | 10 / 16 / 8 · 19 |
| C + `surgedmg=-1` | 46 % | 5.6 | 86 % | 0 % | 8 / 19 / 6 · 14 |
| R = `groundfade=2,trapfade=2,noshield` | 51 % | 4.5 | 92 % | 0 % | 15 / 12 / 2 · 13 |
| R + `jab=1` | 47 % | 4.3 | 94 % | 0 % | 24 / 12 / 2 · 11 |
| R + `softpressure=2` | 48 % | 4.5 | 92 % | 0 % | 15 / 12 / 0 · 10 |
| R + `turns=1` | 46 % | 3.8 | 96 % | 0 % | 29 / 6 / 4 · 13 |
| R + `hp=-1` | 54 % | 4.7 | 90 % | 0 % | 20 / 16 / 4 · 13 |

### Part C · finalists over four seeds and six bot pairings

Seeds 1–4 with 40 battles each (160 per row); planning bot: seeds 1 and 2 with 20 battles (40); pressure out of reach: seeds 1 and 2 with 40 battles (80). `AiBrain + aggro` is the variant with `,aggro` added.

| Variant | Bots (both sides) | Battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Rounds under 3 / over 7 / over 10 (%) · longest | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | Uses per slot and battle: strike / surge / trap / zone / board / move | Defeated before own first turn (per battle) | Wins of `hunt` against the waiting `AiBrain` |
|---|---|---|---|---|---|---|---|---|---|---|
| build rules | hunt | 160 | 75 / 83 / 2 / 0 | 7.7 | 66 % | 15 / 35 / 28 · 22 | 26 / 21 / 1 / 21 / 12 / 10 / 8 | 0.55 / 1.87 / 1.54 / 2.45 / 1.27 / 3.12 | 0.12 | 127 of 320 (40 %) |
|  | chase | 160 | 77 / 82 / 1 / 0 | 8.4 | 60 % | 14 / 43 / 37 · 21 | 22 / 15 / 0 / 24 / 14 / 9 / 17 | 0.49 / 1.68 / 1.37 / 2.57 / 1.14 / 2.52 | 0.12 |  |
|  | AiBrain | 160 | 79 / 73 / 8 / 0 | 10.9 | 40 % | 10 / 62 / 61 · 21 | 12 / 9 / 2 / 9 / 9 / 0 / 59 | 0.42 / 1.36 / 1.10 / 3.54 / 1.03 / 1.50 | 0.12 |  |
|  | AiBrain + aggro | 160 | 80 / 78 / 2 / 0 | 8.6 | 56 % | 18 / 44 / 44 · 21 | 18 / 16 / 2 / 12 / 10 / 0 / 42 | 0.51 / 1.42 / 0.92 / 1.95 / 0.94 / 1.69 | 0.15 |  |
|  | plan | 40 | 19 / 21 / 0 / 0 | 8.1 | 58 % | 20 / 45 / 42 · 20 | 20 / 20 / 8 / 12 / 2 / 12 / 22 | 0.53 / 1.66 / 1.64 / 2.35 / 1.65 / 1.58 | 0.25 |  |
|  | hunt, pressure +200 | 80 | 36 / 37 / 0 / 7 | 41.0 | 82 % | 14 / 42 / 34 · 220 | 24 / 22 / 3 / 32 / 15 / 2 / 2 | 0.55 / 1.96 / 2.08 / 10.09 / 1.81 / 4.24 | 0.09 |  |
|  | chase, pressure +200 | 80 | 30 / 32 / 0 / 18 | 71.7 | 64 % | 12 / 50 / 43 · 221 | 10 / 14 / 0 / 36 / 21 / 10 / 8 | 0.48 / 2.07 / 1.68 / 15.47 / 1.43 / 6.30 | 0.09 |  |
| mire / blink for the two veils | hunt | 160 | 86 / 74 / 0 / 0 | 6.7 | 72 % | 13 / 33 / 22 · 21 | 27 / 23 / 3 / 25 / 10 / 8 / 3 | 0.53 / 1.81 / 1.44 / 2.27 / 1.25 / 2.59 | 0.14 | 144 of 320 (45 %) |
|  | chase | 160 | 80 / 79 / 1 / 0 | 7.6 | 66 % | 12 / 37 / 32 · 20 | 24 / 17 / 2 / 24 / 8 / 9 / 13 | 0.49 / 1.62 / 1.32 / 1.98 / 1.10 / 2.20 | 0.14 |  |
|  | AiBrain | 160 | 74 / 80 / 6 / 0 | 10.7 | 41 % | 6 / 61 / 59 · 21 | 12 / 10 / 1 / 9 / 10 / 1 / 57 | 0.42 / 1.40 / 1.11 / 1.73 / 0.97 / 1.46 | 0.14 |  |
|  | AiBrain + aggro | 160 | 80 / 72 / 8 / 0 | 9.1 | 52 % | 18 / 48 / 48 · 21 | 18 / 10 / 0 / 12 / 14 / 0 / 46 | 0.52 / 1.36 / 0.84 / 1.37 / 0.90 / 1.54 | 0.15 |  |
|  | plan | 40 | 23 / 17 / 0 / 0 | 6.6 | 72 % | 22 / 28 / 25 · 20 | 20 / 12 / 8 / 15 / 22 / 8 / 10 | 0.58 / 1.67 / 1.21 / 2.33 / 1.30 / 1.66 | 0.25 |  |
|  | hunt, pressure +200 | 80 | 45 / 31 / 0 / 4 | 38.4 | 84 % | 10 / 32 / 23 · 218 | 29 / 17 / 4 / 24 / 16 / 6 / 2 | 0.54 / 1.83 / 2.98 / 2.15 / 3.07 / 4.71 | 0.11 |  |
|  | chase, pressure +200 | 80 | 33 / 32 / 0 / 15 | 69.8 | 66 % | 12 / 43 / 40 · 218 | 20 / 17 / 4 / 26 / 11 / 4 / 11 | 0.45 / 1.87 / 1.50 / 2.75 / 1.34 / 5.00 | 0.10 |  |
| `trapfade=2,noshield` | hunt | 160 | 83 / 77 / 0 / 0 | 5.4 | 84 % | 19 / 18 / 12 · 20 | 32 / 22 / 4 / 24 / 16 / 2 / 1 | 0.57 / 1.78 / 1.63 / 0.70 / 1.23 / 2.67 | 0.15 | 136 of 320 (42 %) |
|  | chase | 160 | 77 / 83 / 0 / 0 | 6.6 | 75 % | 19 / 30 / 24 · 21 | 33 / 17 / 2 / 24 / 14 / 4 / 8 | 0.55 / 1.68 / 1.56 / 0.69 / 1.11 / 2.46 | 0.15 |  |
|  | AiBrain | 160 | 80 / 75 / 5 / 0 | 9.4 | 51 % | 13 / 50 / 48 · 21 | 18 / 15 / 2 / 14 / 7 / 0 / 46 | 0.44 / 1.52 / 1.38 / 0.71 / 1.06 / 1.72 | 0.15 |  |
|  | AiBrain + aggro | 160 | 78 / 79 / 3 / 0 | 8.5 | 57 % | 18 / 44 / 43 · 21 | 18 / 16 / 1 / 12 / 12 / 0 / 42 | 0.52 / 1.42 / 0.97 / 0.56 / 0.87 / 1.74 | 0.15 |  |
|  | plan | 40 | 23 / 17 / 0 / 0 | 5.8 | 78 % | 22 / 25 / 22 · 18 | 20 / 15 / 15 / 15 / 12 / 5 / 18 | 0.61 / 1.62 / 2.31 / 0.82 / 1.81 / 1.75 | 0.25 |  |
|  | hunt, pressure +200 | 80 | 43 / 35 / 0 / 2 | 11.6 | 96 % | 15 / 18 / 13 · 216 | 30 / 16 / 4 / 24 / 24 / 2 / 0 | 0.57 / 2.22 / 2.13 / 0.66 / 1.19 / 2.73 | 0.11 |  |
|  | chase, pressure +200 | 80 | 37 / 32 / 0 / 11 | 39.7 | 82 % | 18 / 30 / 26 · 221 | 30 / 18 / 2 / 28 / 17 / 3 / 2 | 0.52 / 1.71 / 4.03 / 0.66 / 1.75 / 6.93 | 0.11 |  |
| `groundfade=2` | hunt | 160 | 77 / 83 / 0 / 0 | 6.0 | 82 % | 15 / 23 / 13 · 21 | 38 / 24 / 3 / 13 / 16 / 2 / 2 | 0.65 / 1.97 / 1.62 / 1.92 / 1.26 / 2.68 | 0.12 | 149 of 320 (47 %) |
|  | chase | 160 | 80 / 80 / 0 / 0 | 7.1 | 71 % | 14 / 34 / 20 · 22 | 32 / 21 / 2 / 14 / 16 / 4 / 10 | 0.59 / 1.98 / 1.62 / 2.16 / 1.19 / 2.52 | 0.12 |  |
|  | AiBrain | 160 | 87 / 66 / 7 / 0 | 9.3 | 54 % | 10 / 50 / 43 · 21 | 28 / 10 / 1 / 10 / 10 / 0 / 39 | 0.51 / 1.57 / 1.33 / 2.90 / 1.15 / 1.76 | 0.12 |  |
|  | AiBrain + aggro | 160 | 83 / 77 / 0 / 0 | 6.3 | 76 % | 18 / 28 / 20 · 20 | 40 / 16 / 5 / 8 / 11 / 0 / 19 | 0.61 / 1.67 / 1.08 / 1.28 / 0.93 / 1.93 | 0.15 |  |
|  | plan | 40 | 24 / 16 / 0 / 0 | 5.8 | 80 % | 20 / 28 / 18 · 16 | 30 / 25 / 5 / 20 / 10 / 2 / 5 | 0.61 / 1.83 / 1.82 / 1.61 / 1.58 / 1.74 | 0.25 |  |
|  | hunt, pressure +200 | 80 | 38 / 42 / 0 / 0 | 7.8 | 100 % | 14 / 25 / 14 · 112 | 38 / 22 / 5 / 16 / 15 / 0 / 0 | 0.68 / 2.08 / 1.56 / 2.33 / 1.17 / 3.49 | 0.09 |  |
|  | chase, pressure +200 | 80 | 38 / 39 / 0 / 3 | 19.5 | 94 % | 12 / 38 / 22 · 220 | 32 / 24 / 2 / 18 / 18 / 2 / 2 | 0.61 / 2.21 / 1.77 / 3.97 / 1.20 / 6.46 | 0.09 |  |
| `groundfade=2,shield=1` | hunt | 160 | 78 / 81 / 1 / 0 | 5.4 | 86 % | 16 / 22 / 7 · 20 | 40 / 28 / 4 / 11 / 14 / 2 / 0 | 0.65 / 1.89 / 1.73 / 1.41 / 1.34 / 2.62 | 0.15 | 149 of 320 (47 %) |
|  | chase | 160 | 78 / 81 / 1 / 0 | 6.4 | 77 % | 16 / 28 / 16 · 20 | 35 / 20 / 5 / 10 / 18 / 3 / 6 | 0.60 / 1.80 / 1.56 / 1.52 / 1.35 / 2.41 | 0.15 |  |
|  | AiBrain | 160 | 85 / 70 / 5 / 0 | 8.7 | 58 % | 11 / 45 / 40 · 21 | 24 / 16 / 1 / 8 / 12 / 0 / 37 | 0.51 / 1.55 / 1.23 / 1.95 / 1.07 / 1.84 | 0.15 |  |
|  | AiBrain + aggro | 160 | 80 / 79 / 1 / 0 | 6.3 | 76 % | 18 / 28 / 19 · 20 | 40 / 17 / 2 / 8 / 14 / 1 / 18 | 0.62 / 1.69 / 1.03 / 1.03 / 0.90 / 1.96 | 0.15 |  |
|  | plan | 40 | 26 / 14 / 0 / 0 | 5.1 | 88 % | 20 / 20 / 12 · 16 | 35 / 18 / 10 / 15 / 18 / 2 / 2 | 0.61 / 1.68 / 1.62 / 1.13 / 1.68 / 1.84 | 0.28 |  |
|  | hunt, pressure +200 | 80 | 37 / 41 / 1 / 1 | 7.9 | 99 % | 14 / 20 / 8 · 198 | 36 / 32 / 4 / 10 / 17 / 0 / 0 | 0.66 / 1.96 / 3.22 / 1.35 / 3.07 / 3.11 | 0.10 |  |
|  | chase, pressure +200 | 80 | 37 / 39 / 1 / 3 | 15.9 | 95 % | 18 / 32 / 15 · 216 | 32 / 21 / 8 / 12 / 20 / 2 / 0 | 0.60 / 1.96 / 1.46 / 1.87 / 1.34 / 5.68 | 0.10 |  |
| `groundfade=2,trapfade=2` | hunt | 160 | 78 / 82 / 0 / 0 | 5.4 | 89 % | 15 / 18 / 8 · 18 | 38 / 28 / 4 / 11 / 16 / 2 / 1 | 0.66 / 1.96 / 1.73 / 1.75 / 1.14 / 2.46 | 0.12 | 148 of 320 (46 %) |
|  | chase | 160 | 81 / 78 / 1 / 0 | 6.2 | 77 % | 14 / 29 / 12 · 19 | 35 / 22 / 2 / 14 / 18 / 2 / 5 | 0.61 / 1.93 / 1.92 / 1.94 / 1.19 / 2.29 | 0.12 |  |
|  | AiBrain | 160 | 88 / 68 / 4 / 0 | 8.7 | 56 % | 10 / 47 / 38 · 21 | 31 / 14 / 2 / 10 / 11 / 2 / 29 | 0.54 / 1.73 / 1.89 / 2.74 / 1.31 / 1.89 | 0.12 |  |
|  | AiBrain + aggro | 160 | 80 / 80 / 0 / 0 | 6.2 | 80 % | 18 / 27 / 18 · 21 | 48 / 16 / 4 / 6 / 13 / 0 / 12 | 0.68 / 1.82 / 1.25 / 1.10 / 0.93 / 2.06 | 0.15 |  |
|  | plan | 40 | 26 / 14 / 0 / 0 | 5.2 | 82 % | 20 / 22 / 10 · 12 | 38 / 25 / 8 / 18 / 5 / 2 / 2 | 0.67 / 1.86 / 1.72 / 1.44 / 1.54 / 1.73 | 0.25 |  |
|  | hunt, pressure +200 | 80 | 38 / 42 / 0 / 0 | 5.7 | 100 % | 14 / 20 / 6 · 31 | 34 / 28 / 4 / 12 / 16 / 0 / 0 | 0.69 / 1.98 / 1.46 / 1.76 / 1.06 / 2.51 | 0.09 |  |
|  | chase, pressure +200 | 80 | 40 / 37 / 1 / 2 | 10.7 | 98 % | 12 / 35 / 12 · 199 | 34 / 26 / 0 / 17 / 20 / 0 / 0 | 0.62 / 2.40 / 2.94 / 3.08 / 1.18 / 3.12 | 0.09 |  |
| `groundfade=2,noshield` | hunt | 160 | 77 / 83 / 0 / 0 | 4.8 | 90 % | 19 / 14 / 5 · 19 | 36 / 24 / 4 / 16 / 17 / 1 / 2 | 0.63 / 1.78 / 1.47 / 0.70 / 1.18 / 2.60 | 0.15 | 159 of 320 (50 %) |
|  | chase | 160 | 74 / 86 / 0 / 0 | 5.5 | 86 % | 19 / 23 / 11 · 19 | 36 / 24 / 5 / 10 / 18 / 3 / 4 | 0.61 / 1.79 / 1.38 / 0.70 / 1.11 / 2.36 | 0.15 |  |
|  | AiBrain | 160 | 79 / 76 / 5 / 0 | 7.9 | 64 % | 13 / 38 / 35 · 20 | 29 / 18 / 2 / 10 / 10 / 1 / 32 | 0.51 / 1.63 / 1.20 / 0.74 / 1.13 / 1.91 | 0.15 |  |
|  | AiBrain + aggro | 160 | 85 / 75 / 0 / 0 | 6.2 | 77 % | 18 / 26 / 18 · 20 | 36 / 22 / 2 / 8 / 14 / 0 / 17 | 0.63 / 1.68 / 0.98 / 0.57 / 0.89 / 1.99 | 0.15 |  |
|  | plan | 40 | 25 / 15 / 0 / 0 | 5.3 | 85 % | 22 / 20 / 15 · 16 | 28 / 20 / 10 / 10 / 20 / 5 / 8 | 0.62 / 1.65 / 1.90 / 0.81 / 1.78 / 1.87 | 0.25 |  |
|  | hunt, pressure +200 | 80 | 38 / 41 / 0 / 1 | 6.8 | 99 % | 15 / 12 / 2 · 198 | 36 / 20 / 4 / 16 / 22 / 0 / 0 | 0.61 / 1.75 / 3.00 / 0.66 / 2.95 / 2.83 | 0.11 |  |
|  | chase, pressure +200 | 80 | 35 / 44 / 0 / 1 | 18.0 | 94 % | 18 / 25 / 10 · 219 | 42 / 19 / 4 / 6 / 22 / 2 / 4 | 0.62 / 1.93 / 1.28 / 0.66 / 1.10 / 4.82 | 0.11 |  |
| `groundfade=2,noshield,trapcap=1` | hunt | 160 | 72 / 86 / 2 / 0 | 4.5 | 95 % | 20 / 10 / 4 · 17 | 38 / 23 / 4 / 13 / 20 / 1 / 1 | 0.65 / 1.77 / 1.02 / 0.69 / 1.11 / 2.42 | 0.15 | 160 of 320 (50 %) |
|  | chase | 160 | 76 / 84 / 0 / 0 | 5.4 | 86 % | 21 / 24 / 8 · 18 | 39 / 23 / 4 / 10 / 20 / 1 / 3 | 0.65 / 1.86 / 1.13 / 0.71 / 1.12 / 2.24 | 0.15 |  |
|  | AiBrain | 160 | 78 / 77 / 5 / 0 | 7.2 | 70 % | 14 / 34 / 26 · 20 | 26 / 24 / 4 / 10 / 14 / 1 / 24 | 0.55 / 1.72 / 0.96 / 0.76 / 1.09 / 2.00 | 0.15 |  |
|  | AiBrain + aggro | 160 | 82 / 78 / 0 / 0 | 5.6 | 84 % | 18 / 19 / 14 · 21 | 43 / 20 / 1 / 10 / 12 / 0 / 12 | 0.67 / 1.65 / 0.78 / 0.55 / 0.89 / 1.97 | 0.15 |  |
|  | plan | 40 | 24 / 16 / 0 / 0 | 4.0 | 95 % | 22 / 8 / 2 · 12 | 30 / 15 / 10 / 8 / 35 / 0 / 0 | 0.68 / 1.63 / 1.19 / 0.81 / 1.10 / 1.85 | 0.25 |  |
|  | hunt, pressure +200 | 80 | 34 / 45 / 1 / 0 | 4.7 | 100 % | 13 / 10 / 6 · 15 | 36 / 19 / 3 / 13 / 26 / 0 / 0 | 0.66 / 1.81 / 0.94 / 0.63 / 1.14 / 2.44 | 0.11 |  |
|  | chase, pressure +200 | 80 | 38 / 40 / 0 / 2 | 9.6 | 98 % | 18 / 26 / 9 · 199 | 41 / 24 / 4 / 8 / 22 / 0 / 0 | 0.66 / 1.95 / 1.40 / 0.67 / 1.47 / 3.29 | 0.11 |  |
| **R** = `groundfade=2,trapfade=2,noshield` | hunt | 160 | 79 / 81 / 0 / 0 | 4.5 | 94 % | 19 / 11 / 3 · 13 | 38 / 25 / 5 / 13 / 16 / 0 / 0 | 0.65 / 1.77 / 1.47 / 0.70 / 1.10 / 2.44 | 0.15 | 155 of 320 (48 %) |
|  | chase | 160 | 78 / 82 / 0 / 0 | 5.2 | 87 % | 19 / 20 / 8 · 17 | 41 / 23 / 2 / 13 / 17 / 2 / 2 | 0.63 / 1.82 / 1.62 / 0.70 / 1.14 / 2.23 | 0.15 |  |
|  | AiBrain | 160 | 79 / 79 / 2 / 0 | 6.8 | 73 % | 13 / 29 / 22 · 20 | 34 / 24 / 2 / 11 / 11 / 1 / 17 | 0.56 / 1.79 / 1.57 / 0.74 / 1.18 / 2.06 | 0.15 |  |
|  | AiBrain + aggro | 160 | 86 / 73 / 1 / 0 | 5.8 | 81 % | 18 / 22 / 16 · 20 | 44 / 20 / 2 / 8 / 14 / 1 / 11 | 0.68 / 1.73 / 1.11 / 0.57 / 0.91 / 2.03 | 0.15 |  |
|  | plan | 40 | 22 / 18 / 0 / 0 | 4.4 | 90 % | 22 / 10 / 10 · 14 | 25 / 18 / 20 / 10 / 22 / 2 / 2 | 0.64 / 1.62 / 1.75 / 0.81 / 1.45 / 1.78 | 0.25 |  |
|  | hunt, pressure +200 | 80 | 39 / 41 / 0 / 0 | 4.5 | 100 % | 15 / 12 / 2 · 13 | 39 / 22 / 6 / 14 / 18 / 0 / 0 | 0.64 / 1.81 / 1.33 / 0.65 / 1.12 / 2.44 | 0.11 |  |
|  | chase, pressure +200 | 80 | 38 / 41 / 0 / 1 | 7.6 | 99 % | 18 / 23 / 10 · 199 | 44 / 20 / 2 / 12 / 22 / 0 / 0 | 0.65 / 2.21 / 2.56 / 0.67 / 1.14 / 2.99 | 0.11 |  |
| `groundfade=2,trapfade=2` + mire / blink | hunt | 160 | 81 / 79 / 0 / 0 | 5.3 | 83 % | 13 / 21 / 8 · 19 | 44 / 24 / 5 / 10 / 14 / 1 / 1 | 0.65 / 1.86 / 1.77 / 2.22 / 1.20 / 2.27 | 0.14 | 157 of 320 (49 %) |
|  | chase | 160 | 82 / 78 / 0 / 0 | 5.9 | 80 % | 12 / 24 / 11 · 19 | 45 / 17 / 2 / 14 / 17 / 2 / 2 | 0.63 / 1.88 / 1.77 / 2.21 / 1.17 / 2.17 | 0.14 |  |
|  | AiBrain | 160 | 73 / 84 / 3 / 0 | 7.7 | 68 % | 6 / 36 / 26 · 21 | 34 / 20 / 3 / 12 / 10 / 1 / 20 | 0.56 / 1.86 / 1.67 / 2.07 / 1.09 / 1.87 | 0.14 |  |
|  | AiBrain + aggro | 160 | 86 / 73 / 1 / 0 | 6.4 | 74 % | 18 / 32 / 21 · 21 | 40 / 20 / 2 / 13 / 12 / 1 / 12 | 0.66 / 1.69 / 1.18 / 1.85 / 0.89 / 1.82 | 0.15 |  |
|  | plan | 40 | 21 / 19 / 0 / 0 | 5.2 | 85 % | 22 / 25 / 12 · 14 | 38 / 20 / 8 / 12 / 15 / 2 / 2 | 0.71 / 1.74 / 1.59 / 2.25 / 1.47 / 1.77 | 0.25 |  |
|  | hunt, pressure +200 | 80 | 41 / 39 / 0 / 0 | 5.3 | 100 % | 10 / 20 / 6 · 13 | 50 / 18 / 3 / 8 / 18 / 0 / 0 | 0.66 / 1.88 / 1.54 / 2.12 / 1.21 / 2.22 | 0.11 |  |
|  | chase, pressure +200 | 80 | 42 / 37 / 0 / 1 | 9.0 | 99 % | 12 / 29 / 13 · 199 | 46 / 18 / 2 / 14 / 18 / 0 / 0 | 0.65 / 2.40 / 2.83 / 2.35 / 1.18 / 2.97 | 0.10 |  |
| `groundfade=2,trapcap=1` + mire / blink | hunt | 160 | 76 / 83 / 1 / 0 | 5.1 | 87 % | 14 / 18 / 7 · 17 | 42 / 24 / 5 / 10 / 18 / 1 / 1 | 0.65 / 1.77 / 1.07 / 1.99 / 1.14 / 2.12 | 0.14 | 150 of 320 (47 %) |
|  | chase | 160 | 80 / 80 / 0 / 0 | 5.8 | 81 % | 14 / 24 / 12 · 20 | 41 / 22 / 4 / 13 / 15 / 3 / 3 | 0.62 / 1.84 / 1.09 / 2.15 / 1.11 / 2.03 | 0.14 |  |
|  | AiBrain | 160 | 74 / 82 / 4 / 0 | 7.5 | 72 % | 8 / 37 / 23 · 24 | 33 / 22 / 2 / 9 / 15 / 1 / 20 | 0.58 / 1.76 / 0.99 / 2.07 / 1.06 / 1.81 | 0.14 |  |
|  | AiBrain + aggro | 160 | 86 / 73 / 1 / 0 | 6.5 | 77 % | 18 / 32 / 19 · 21 | 42 / 18 / 1 / 11 / 13 / 1 / 14 | 0.66 / 1.72 / 0.86 / 1.87 / 0.95 / 1.81 | 0.15 |  |
|  | plan | 40 | 22 / 17 / 1 / 0 | 4.8 | 85 % | 22 / 20 / 8 · 18 | 40 / 10 / 10 / 12 / 22 / 0 / 2 | 0.65 / 1.72 / 1.22 / 2.32 / 1.17 / 1.69 | 0.25 |  |
|  | hunt, pressure +200 | 80 | 37 / 43 / 0 / 0 | 5.2 | 100 % | 9 / 19 / 6 · 15 | 46 / 19 / 4 / 10 / 20 / 0 / 0 | 0.66 / 1.80 / 0.96 / 1.96 / 1.16 / 2.18 | 0.11 |  |
|  | chase, pressure +200 | 80 | 38 / 39 / 0 / 3 | 15.1 | 95 % | 10 / 28 / 12 · 218 | 42 / 20 / 4 / 16 / 16 / 0 / 0 | 0.61 / 1.99 / 1.46 / 2.18 / 1.42 / 4.25 | 0.10 |  |
| `groundfade=2` + bog / void_pull | hunt | 160 | 80 / 79 / 1 / 0 | 4.2 | 94 % | 25 / 8 / 3 · 19 | 29 / 23 / 9 / 14 / 23 / 1 / 0 | 0.53 / 1.53 / 1.22 / 1.83 / 1.08 / 2.03 | 0.16 | 156 of 320 (49 %) |
|  | chase | 160 | 76 / 84 / 0 / 0 | 5.2 | 85 % | 24 / 20 / 13 · 19 | 34 / 14 / 8 / 17 / 20 / 4 / 4 | 0.52 / 1.56 / 1.37 / 1.93 / 1.13 / 1.93 | 0.15 |  |
|  | AiBrain | 160 | 78 / 75 / 7 / 0 | 7.8 | 66 % | 16 / 38 / 32 · 20 | 24 / 12 / 5 / 10 / 15 / 1 / 30 | 0.47 / 1.47 / 1.18 / 1.83 / 1.03 / 1.65 | 0.14 |  |
|  | AiBrain + aggro | 160 | 79 / 81 / 0 / 0 | 5.6 | 82 % | 25 / 24 / 16 · 19 | 31 / 15 / 4 / 15 / 18 / 2 / 13 | 0.57 / 1.42 / 1.07 / 1.57 / 0.92 / 1.69 | 0.17 |  |
|  | plan | 40 | 25 / 15 / 0 / 0 | 5.6 | 82 % | 15 / 20 / 12 · 16 | 38 / 15 / 15 / 2 / 20 / 2 / 8 | 0.59 / 1.52 / 1.67 / 1.93 / 1.73 / 1.58 | 0.28 |  |
|  | hunt, pressure +200 | 80 | 42 / 37 / 1 / 0 | 4.5 | 100 % | 23 / 9 / 4 · 23 | 30 / 16 / 14 / 10 / 28 / 0 / 0 | 0.53 / 1.52 / 1.25 / 1.85 / 1.16 / 2.05 | 0.12 |  |
|  | chase, pressure +200 | 80 | 38 / 39 / 0 / 3 | 19.5 | 92 % | 22 / 26 / 18 · 216 | 34 / 17 / 8 / 16 / 20 / 2 / 2 | 0.53 / 1.61 / 3.21 / 1.87 / 2.97 / 5.06 | 0.11 |  |

### Part D · build rules against R over eight seeds

R = `groundfade=2,trapfade=2,noshield`. Seeds 1–8 (planning bot: seeds 1–4, 20 battles each). The rows after R compare it with the same set without a trap clock, with a trap limit instead, and with back-row starts and an HP floor of 3 added.

| Variant | Bots (both sides) | Battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Collapse endings | Rounds under 3 / over 7 / over 10 (%) · longest |
|---|---|---|---|---|---|---|---|
| build rules | hunt | 320 | 154 / 164 / 2 / 0 | 7.6 | 68 % | 6 % | 15 / 35 / 28 · 22 |
| build rules | chase | 320 | 145 / 174 / 1 / 0 | 8.3 | 61 % | 15 % | 12 / 43 / 36 · 21 |
| build rules | AiBrain | 320 | 136 / 162 / 22 / 0 | 11.2 | 38 % | 60 % | 10 / 64 / 62 · 22 |
| build rules | plan | 80 | 39 / 41 / 0 / 0 | 7.7 | 62 % | 26 % | 15 / 39 / 36 · 23 |
| R | hunt | 320 | 161 / 159 / 0 / 0 | 4.6 | 94 % | 0 % | 18 / 11 / 3 · 14 |
| R | chase | 320 | 154 / 166 / 0 / 0 | 5.2 | 86 % | 1 % | 16 / 20 / 8 · 17 |
| R | AiBrain | 320 | 144 / 172 / 4 / 0 | 6.9 | 73 % | 16 % | 11 / 31 / 22 · 20 |
| R | plan | 80 | 38 / 42 / 0 / 0 | 4.5 | 89 % | 4 % | 24 / 12 / 9 · 16 |
| R without the trap clock (`groundfade=2,noshield`) | hunt | 320 | 158 / 162 / 0 / 0 | 4.9 | 90 % | 1 % | 18 / 14 / 6 · 19 |
| R without the trap clock (`groundfade=2,noshield`) | chase | 320 | 147 / 173 / 0 / 0 | 5.6 | 84 % | 3 % | 16 / 24 / 12 · 19 |
| R without the trap clock (`groundfade=2,noshield`) | AiBrain | 320 | 141 / 169 / 10 / 0 | 7.9 | 65 % | 29 % | 11 / 38 / 33 · 21 |
| R without the trap clock (`groundfade=2,noshield`) | plan | 80 | 40 / 40 / 0 / 0 | 4.9 | 86 % | 5 % | 24 / 21 / 10 · 17 |
| R with a trap limit instead (`groundfade=2,noshield,trapcap=1`) | hunt | 320 | 154 / 164 / 2 / 0 | 4.5 | 93 % | 1 % | 18 / 11 / 4 · 17 |
| R with a trap limit instead (`groundfade=2,noshield,trapcap=1`) | chase | 320 | 154 / 166 / 0 / 0 | 5.3 | 86 % | 2 % | 18 / 21 / 8 · 18 |
| R with a trap limit instead (`groundfade=2,noshield,trapcap=1`) | AiBrain | 320 | 144 / 167 / 9 / 0 | 7.2 | 71 % | 22 % | 12 / 34 / 26 · 20 |
| R with a trap limit instead (`groundfade=2,noshield,trapcap=1`) | plan | 80 | 42 / 38 / 0 / 0 | 4.0 | 96 % | 0 % | 25 / 9 / 1 · 12 |
| R + `startback,hpmin=3` | hunt | 320 | 151 / 168 / 1 / 0 | 4.9 | 89 % | 1 % | 12 / 15 / 4 · 15 |
| R + `startback,hpmin=3` | chase | 320 | 154 / 165 / 1 / 0 | 5.4 | 86 % | 1 % | 11 / 21 / 6 · 21 |
| R + `startback,hpmin=3` | AiBrain | 320 | 144 / 168 / 8 / 0 | 7.0 | 73 % | 17 % | 6 / 32 / 22 · 25 |
| R + `startback,hpmin=3` | plan | 80 | 41 / 38 / 1 / 0 | 4.7 | 94 % | 2 % | 11 / 10 / 2 · 14 |

Tool rows of seeds 1–4 (`hunt`, then `AiBrain`, then the planning bot), build rules first:

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used | Reached pressure: HP leader won / lost / HP level / no winner | Rounds under 3 / over 7 / over 10 (%) · longest | First defeat in round (mean) | Defeated before own first turn (per battle) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| bots hunt | 3v3 · 1 · 40 | 20 / 20 / 0 / 0 | 8.3 | 58 % | 20 / 15 / 0 / 30 / 15 / 8 / 8 | 24 / 29 / 3 / 17 / 17 / 2 / 3 | 25 / 32 / 2 / 14 / 20 / 3 / 3 | 11.82 | 3.38 / 5.17 / 3.27 | 0.67 / 0.07 | 26.10 | 3.5 / 8.1 / 3.8 / 7.1 / 2.8 / 16.6 / 12.6 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.58 / 2.02 / 1.42 / 2.54 / 1.09 / 3.12 | Step 23 % | none | 15 / 1 / 1 / 0 | 15 / 43 / 35 · 20 | 1.1 | 0.03 |
| bots hunt | 3v3 · 2 · 40 | 18 / 21 / 1 / 0 | 8.5 | 60 % | 20 / 25 / 3 / 15 / 13 / 15 / 8 | 25 / 25 / 6 / 14 / 21 / 3 / 3 | 24 / 32 / 3 / 13 / 20 / 3 / 2 | 11.50 | 3.42 / 4.67 / 3.40 | 0.71 / 0.08 | 25.57 | 3.2 / 7.5 / 4.0 / 7.7 / 3.0 / 16.4 / 12.9 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.54 / 1.89 / 1.47 / 2.71 / 1.21 / 3.04 | Step 24 % | none | 12 / 2 / 1 / 1 | 13 / 40 / 33 · 22 | 1.1 | 0.15 |
| bots hunt | 3v3 · 3 · 40 | 14 / 25 / 1 / 0 | 7.0 | 70 % | 30 / 15 / 0 / 23 / 13 / 10 / 5 | 26 / 21 / 3 / 15 / 28 / 3 / 2 | 24 / 30 / 3 / 14 / 23 / 3 / 2 | 10.97 | 3.02 / 4.42 / 3.52 | 0.69 / 0.05 | 25.00 | 3.1 / 6.9 / 4.0 / 6.2 / 3.4 / 17.6 / 11.8 | 6.0 / 4.2 / 2.4 / 2.9 / 2.5 / 5.5 / 0.5 | 0.52 / 1.64 / 1.72 / 2.14 / 1.33 / 3.21 | Step 22 % | none | 8 / 1 / 1 / 1 | 20 / 30 / 23 · 20 | 1.0 | 0.12 |
| bots hunt | 3v3 · 4 · 40 | 23 / 17 / 0 / 0 | 7.1 | 78 % | 33 / 28 / 0 / 15 / 8 / 8 / 10 | 26 / 31 / 1 / 15 / 18 / 3 / 5 | 24 / 34 / 1 / 14 / 18 / 4 / 3 | 11.85 | 3.45 / 4.62 / 3.77 | 0.69 / 0.04 | 25.10 | 3.4 / 7.5 / 4.3 / 6.0 / 4.1 / 16.4 / 14.2 | 6.0 / 3.9 / 2.8 / 2.5 / 2.8 / 5.2 / 0.8 | 0.56 / 1.94 / 1.54 / 2.39 / 1.46 / 3.12 | Step 25 % | none | 7 / 1 / 1 / 0 | 13 / 28 / 23 · 21 | 1.1 | 0.20 |
| build rules | 3v3 · 1 · 40 | 22 / 15 / 3 / 0 | 11.9 | 30 % | 13 / 3 / 3 / 3 / 10 / 0 / 68 | 19 / 26 / 3 / 5 / 17 / 1 / 26 | 18 / 28 / 2 / 5 / 21 / 0 / 25 | 8.95 | 3.25 / 3.62 / 2.08 | 0.78 / 0.09 | 26.57 | 2.5 / 5.7 / 3.2 / 11.6 / 3.2 / 7.9 / 4.0 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.41 / 1.43 / 1.23 / 4.14 / 1.25 / 1.49 | bark_veil 15 % | none | 19 / 5 / 3 / 1 | 13 / 73 / 70 · 21 | 1.1 | 0.03 |
| build rules | 3v3 · 2 · 40 | 21 / 17 / 2 / 0 | 12.6 | 25 % | 5 / 5 / 0 / 5 / 8 / 0 / 75 | 17 / 18 / 4 / 10 / 21 / 0 / 28 | 18 / 25 / 2 / 7 / 19 / 0 / 28 | 7.62 | 2.65 / 2.75 / 2.23 | 0.85 / 0.09 | 26.52 | 2.5 / 5.2 / 2.5 / 9.9 / 2.1 / 9.2 / 4.0 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.41 / 1.31 / 0.89 / 3.50 / 0.86 / 1.70 | bark_veil 15 % | none | 21 / 6 / 1 / 2 | 5 / 75 / 75 · 21 | 1.1 | 0.15 |
| build rules | 3v3 · 3 · 40 | 16 / 23 / 1 / 0 | 8.5 | 60 % | 20 / 13 / 3 / 13 / 13 / 0 / 38 | 18 / 21 / 3 / 13 / 26 / 0 / 17 | 19 / 30 / 2 / 9 / 24 / 0 / 14 | 8.38 | 2.90 / 3.08 / 2.40 | 0.86 / 0.07 | 24.60 | 2.4 / 5.5 / 2.9 / 9.5 / 2.6 / 7.7 / 3.9 | 6.0 / 4.2 / 2.4 / 2.9 / 2.5 / 5.5 / 0.5 | 0.40 / 1.29 / 1.24 / 3.30 / 1.04 / 1.40 | bark_veil 12 % | none | 14 / 1 / 1 / 0 | 13 / 43 / 40 · 18 | 1.0 | 0.12 |
| build rules | 3v3 · 4 · 40 | 20 / 18 / 2 / 0 | 10.5 | 43 % | 10 / 15 / 0 / 15 / 5 / 0 / 55 | 20 / 17 / 2 / 14 / 19 / 0 / 25 | 19 / 28 / 2 / 10 / 17 / 0 / 23 | 8.38 | 2.90 / 3.20 / 2.27 | 0.86 / 0.06 | 26.27 | 2.8 / 5.5 / 2.9 / 8.1 / 2.7 / 7.3 / 4.6 | 6.0 / 3.9 / 2.8 / 2.5 / 2.8 / 5.2 / 0.8 | 0.47 / 1.40 / 1.04 / 3.23 / 0.96 / 1.40 | Step 14 % | none | 18 / 0 / 3 / 2 | 10 / 58 / 58 · 20 | 1.1 | 0.20 |
| bots plan | 3v3 · 1 · 20 | 11 / 9 / 0 / 0 | 9.9 | 40 % | 25 / 15 / 5 / 5 / 0 / 10 / 40 | 19 / 21 / 5 / 8 / 25 / 2 / 17 | 20 / 29 / 5 / 7 / 22 / 2 / 11 | 11.40 | 3.75 / 5.25 / 2.40 | 0.75 / 0.04 | 25.95 | 3.1 / 6.5 / 5.0 / 8.8 / 5.1 / 8.1 / 6.3 | 6.0 / 3.8 / 2.8 / 2.8 / 2.7 / 5.2 / 0.8 | 0.53 / 1.70 / 1.80 / 3.18 / 1.89 / 1.53 | Step 15 % | none | 11 / 1 / 0 / 0 | 15 / 60 / 60 · 20 | 1.1 | 0.15 |
| bots plan | 3v3 · 2 · 20 | 8 / 12 / 0 / 0 | 6.2 | 75 % | 15 / 25 / 10 / 20 / 5 / 15 / 5 | 20 / 21 / 10 / 11 / 25 / 3 / 2 | 24 / 32 / 7 / 9 / 22 / 1 / 2 | 10.40 | 3.60 / 4.20 / 2.60 | 0.89 / 0.04 | 25.30 | 3.2 / 6.2 / 4.2 / 4.0 / 3.8 / 8.8 / 5.6 | 6.0 / 3.8 / 2.9 / 2.6 / 2.6 / 5.3 / 0.7 | 0.53 / 1.62 / 1.47 / 1.53 / 1.42 / 1.64 | Step 16 % | none | 2 / 2 / 1 / 0 | 25 / 30 / 25 · 18 | 1.1 | 0.35 |
| groundfade=2,trapfade=2,noshield + bots hunt | 3v3 · 1 · 40 | 19 / 21 / 0 / 0 | 5.0 | 90 % | 43 / 25 / 3 / 13 / 15 / 0 / 0 | 28 / 37 / 2 / 10 / 19 / 0 / 0 | 28 / 39 / 1 / 8 / 21 / 0 / 0 | 12.55 | 3.45 / 5.28 / 3.83 | 0.74 / 0.09 | 26.07 | 3.9 / 8.2 / 4.3 / 1.9 / 3.3 / 14.1 / 8.9 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.65 / 2.06 / 1.63 / 0.70 / 1.29 / 2.66 | Step 20 % | bark_veil, crucible, shade_veil | 3 / 1 / 0 / 0 | 15 / 20 / 5 · 13 | 1.0 | 0.07 |
| groundfade=2,trapfade=2,noshield + bots hunt | 3v3 · 2 · 40 | 20 / 20 / 0 / 0 | 4.0 | 95 % | 35 / 18 / 8 / 15 / 20 / 0 / 0 | 30 / 28 / 5 / 9 / 26 / 0 / 0 | 30 / 35 / 4 / 7 / 23 / 0 / 0 | 9.00 | 3.10 / 2.73 / 3.17 | 0.93 / 0.09 | 23.75 | 3.7 / 6.2 / 2.8 / 1.7 / 2.4 / 12.0 / 6.8 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.62 / 1.56 / 1.03 / 0.60 / 0.95 / 2.22 | Step 19 % | bark_veil, shade_veil | 2 / 0 / 0 / 0 | 15 / 5 / 0 · 10 | 1.1 | 0.15 |
| groundfade=2,trapfade=2,noshield + bots hunt | 3v3 · 3 · 40 | 14 / 26 / 0 / 0 | 4.1 | 98 % | 38 / 30 / 5 / 10 / 13 / 0 / 0 | 28 / 27 / 3 / 13 / 25 / 0 / 0 | 28 / 35 / 3 / 8 / 23 / 0 / 0 | 10.12 | 3.23 / 3.48 / 3.42 | 0.86 / 0.08 | 24.88 | 3.7 / 6.6 / 3.5 / 2.4 / 2.5 / 12.2 / 7.0 | 6.0 / 4.2 / 2.4 / 2.9 / 2.5 / 5.5 / 0.5 | 0.62 / 1.56 / 1.50 / 0.82 / 0.96 / 2.22 | Step 18 % | bark_veil, shade_veil | 0 / 0 / 1 / 0 | 25 / 5 / 3 · 11 | 1.0 | 0.17 |
| groundfade=2,trapfade=2,noshield + bots hunt | 3v3 · 4 · 40 | 26 / 14 / 0 / 0 | 4.8 | 95 % | 35 / 28 / 5 / 15 / 18 / 0 / 0 | 33 / 29 / 4 / 11 / 22 / 0 / 0 | 31 / 36 / 2 / 10 / 19 / 0 / 0 | 12.20 | 3.15 / 4.45 / 4.60 | 0.71 / 0.06 | 24.68 | 4.1 / 7.4 / 4.8 / 1.7 / 3.4 / 13.8 / 9.1 | 6.0 / 3.9 / 2.8 / 2.5 / 2.8 / 5.2 / 0.8 | 0.69 / 1.89 / 1.72 / 0.67 / 1.21 / 2.64 | Step 20 % | bark_veil, shade_veil | 1 / 0 / 1 / 0 | 20 / 15 / 3 · 11 | 1.1 | 0.23 |
| groundfade=2,trapfade=2,noshield | 3v3 · 1 · 40 | 19 / 21 / 0 / 0 | 7.2 | 68 % | 30 / 23 / 0 / 10 / 15 / 0 / 20 | 24 / 37 / 2 / 10 / 18 / 1 / 5 | 22 / 42 / 1 / 6 / 21 / 0 / 5 | 11.80 | 3.65 / 4.40 / 3.75 | 0.87 / 0.08 | 26.23 | 3.1 / 7.7 / 4.1 / 2.1 / 3.0 / 11.1 / 6.0 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.52 / 1.92 / 1.56 / 0.74 / 1.18 / 2.09 | Step 16 % | bark_veil, crucible, shade_veil | 9 / 2 / 2 / 0 | 13 / 33 / 25 · 20 | 1.1 | 0.05 |
| groundfade=2,trapfade=2,noshield | 3v3 · 2 · 40 | 21 / 18 / 1 / 0 | 7.3 | 73 % | 33 / 20 / 5 / 10 / 10 / 5 / 15 | 30 / 27 / 5 / 10 / 21 / 1 / 5 | 28 / 34 / 2 / 7 / 21 / 0 / 6 | 10.55 | 3.15 / 4.20 / 3.20 | 0.79 / 0.06 | 24.82 | 3.6 / 7.1 / 3.5 / 1.6 / 3.1 / 12.8 / 5.7 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.61 / 1.79 / 1.26 / 0.58 / 1.24 / 2.38 | Step 15 % | bark_veil, shade_veil | 8 / 2 / 1 / 0 | 8 / 33 / 23 · 19 | 1.1 | 0.15 |
| groundfade=2,trapfade=2,noshield | 3v3 · 3 · 40 | 16 / 24 / 0 / 0 | 6.3 | 73 % | 45 / 25 / 0 / 10 / 8 / 0 / 13 | 28 / 30 / 2 / 13 / 21 / 0 / 4 | 26 / 37 / 2 / 9 / 22 / 0 / 2 | 11.62 | 3.35 / 4.28 / 4.00 | 0.78 / 0.07 | 25.52 | 3.5 / 7.5 / 4.1 / 2.6 / 2.9 / 10.8 / 5.4 | 6.0 / 4.2 / 2.4 / 2.9 / 2.5 / 5.5 / 0.5 | 0.58 / 1.78 / 1.74 / 0.91 / 1.14 / 1.97 | Step 15 % | bark_veil, shade_veil | 8 / 3 / 0 / 0 | 13 / 28 / 18 · 17 | 1.0 | 0.17 |
| groundfade=2,trapfade=2,noshield | 3v3 · 4 · 40 | 23 / 16 / 1 / 0 | 6.4 | 78 % | 28 / 28 / 3 / 13 / 10 / 0 / 20 | 27 / 26 / 2 / 10 / 23 / 0 / 8 | 24 / 36 / 1 / 8 / 20 / 1 / 8 | 11.30 | 3.00 / 4.12 / 4.17 | 0.76 / 0.05 | 24.35 | 3.1 / 6.5 / 4.8 / 1.9 / 3.3 / 9.4 / 6.2 | 6.0 / 3.9 / 2.8 / 2.5 / 2.8 / 5.2 / 0.8 | 0.52 / 1.66 / 1.72 / 0.75 / 1.18 / 1.79 | Step 18 % | bark_veil, shade_veil | 4 / 2 / 2 / 1 | 18 / 23 / 20 · 19 | 1.1 | 0.23 |
| groundfade=2,trapfade=2,noshield + bots plan | 3v3 · 1 · 20 | 11 / 9 / 0 / 0 | 4.1 | 95 % | 25 / 15 / 20 / 10 / 30 / 0 / 0 | 26 / 25 / 11 / 10 / 27 / 0 / 0 | 27 / 32 / 8 / 9 / 23 / 0 / 0 | 10.90 | 3.30 / 3.85 / 3.75 | 0.86 / 0.03 | 24.25 | 4.0 / 6.8 / 4.2 / 2.5 / 2.8 / 9.7 / 6.5 | 6.0 / 3.8 / 2.8 / 2.8 / 2.7 / 5.2 / 0.8 | 0.66 / 1.78 / 1.51 / 0.93 / 1.04 / 1.84 | Step 18 % | bark_veil, shade_veil | 1 / 0 / 0 / 0 | 20 / 5 / 5 · 11 | 1.1 | 0.15 |
| groundfade=2,trapfade=2,noshield + bots plan | 3v3 · 2 · 20 | 11 / 9 / 0 / 0 | 4.8 | 85 % | 25 / 20 / 20 / 10 / 15 / 5 / 5 | 22 / 20 / 16 / 10 / 27 / 1 / 1 | 26 / 28 / 11 / 8 / 24 / 0 / 0 | 11.35 | 3.20 / 5.00 / 3.15 | 0.76 / 0.05 | 23.75 | 3.8 / 5.5 / 5.8 / 1.9 / 4.9 / 9.2 / 5.5 | 6.0 / 3.8 / 2.9 / 2.6 / 2.6 / 5.3 / 0.7 | 0.62 / 1.46 / 2.00 / 0.70 / 1.85 / 1.72 | Step 15 % | bark_veil, shade_veil | 3 / 0 / 0 / 0 | 25 / 15 / 15 · 14 | 1.1 | 0.35 |

### Part E · what a skill kind is worth to the side that keeps it

Both sides play the same bot; one side never uses the kind. Share of the 160 battles (seeds 1 and 2, both seatings) won by the side that keeps it; 50 % = the kind can be replaced by the other actions without loss.

| Variant · bot | strike | surge | trap | zone | board | move |
|---|---|---|---|---|---|---|
| build rules · `hunt` | 70 % | 69 % | 54 % | 51 % | 47 % | 54 % |
| R · `hunt` | 81 % | 70 % | 54 % | 50 % | 50 % | 56 % |
| C (`groundfade=2,trapfade=2` + mire / blink) · `hunt` | 77 % | 71 % | 52 % | 50 % | 49 % | 58 % |
| C · `plan` | — | — | 52 % | 58 % | 52 % | — |

### Part F · cross-check in 2v2 and 1v1 (one run each; not tuned, user focus is 3v3)

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used | Reached pressure: HP leader won / lost / HP level / no winner | Rounds under 3 / over 7 / over 10 (%) · longest | First defeat in round (mean) | Defeated before own first turn (per battle) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| build rules | 2v2 · 1 · 60 | 25 / 32 / 3 / 0 | 6.9 | 65 % | 20 / 15 / 3 / 10 / 18 / 0 / 33 | 28 / 19 / 4 / 8 / 21 / 0 / 19 | 29 / 17 / 1 / 7 / 25 / 0 / 20 | 4.40 | 1.02 / 1.90 / 1.48 | 0.52 / 0.11 | 15.40 | 2.3 / 2.8 / 1.6 / 4.4 / 1.2 / 5.4 / 3.2 | 4.0 / 2.7 / 1.6 / 1.8 / 1.9 / 3.6 / 0.4 | 0.58 / 1.06 / 0.95 / 2.38 / 0.63 / 1.51 | Step 15 % | crucible | 16 / 0 / 5 / 0 | 28 / 35 / 33 · 18 | 1.4 | 0.20 |
| groundfade=2,trapfade=2,noshield | 2v2 · 1 · 60 | 23 / 34 / 3 / 0 | 5.1 | 75 % | 42 / 22 / 2 / 3 / 22 / 0 / 8 | 39 / 21 / 2 / 5 / 26 / 0 / 5 | 42 / 19 / 1 / 5 / 29 / 0 / 3 | 5.70 | 1.03 / 2.52 / 2.15 | 0.45 / 0.09 | 15.07 | 3.3 / 3.7 / 2.0 / 1.7 / 1.5 / 6.7 / 4.3 | 4.0 / 2.7 / 1.6 / 1.8 / 1.9 / 3.6 / 0.4 | 0.83 / 1.38 / 1.23 / 0.95 / 0.81 / 1.86 | Step 18 % | bark_veil, crucible, shade_veil | 9 / 2 / 4 / 0 | 30 / 25 / 13 · 13 | 1.2 | 0.20 |
| bots hunt | 2v2 · 1 · 60 | 22 / 38 / 0 / 0 | 4.1 | 90 % | 33 / 20 / 2 / 17 / 22 / 2 / 3 | 37 / 20 / 4 / 11 / 25 / 1 / 1 | 39 / 19 / 1 / 11 / 27 / 0 / 1 | 5.68 | 1.22 / 2.40 / 2.07 | 0.45 / 0.09 | 15.37 | 3.1 / 3.8 / 1.9 / 3.3 / 1.6 / 7.6 / 5.5 | 4.0 / 2.7 / 1.6 / 1.8 / 1.9 / 3.6 / 0.4 | 0.78 / 1.43 / 1.14 / 1.80 / 0.86 / 2.12 | Step 21 % | none | 5 / 1 / 0 / 0 | 30 / 10 / 5 · 15 | 1.3 | 0.20 |
| groundfade=2,trapfade=2,noshield + bots hunt | 2v2 · 1 · 60 | 24 / 35 / 1 / 0 | 3.8 | 93 % | 30 / 22 / 3 / 10 / 35 / 0 / 0 | 35 / 21 / 5 / 7 / 31 / 0 / 0 | 41 / 21 / 2 / 7 / 29 / 0 / 0 | 5.92 | 1.23 / 2.28 / 2.40 | 0.49 / 0.11 | 15.48 | 3.3 / 3.8 / 2.1 / 1.9 / 1.4 / 8.0 / 5.2 | 4.0 / 2.7 / 1.6 / 1.8 / 1.9 / 3.6 / 0.4 | 0.82 / 1.43 / 1.28 / 1.02 / 0.78 / 2.24 | Step 20 % | bark_veil, shade_veil | 3 / 0 / 1 / 0 | 28 / 7 / 0 · 9 | 1.2 | 0.20 |
| build rules | 1v1 · 1 · 100 | 45 / 54 / 1 / 0 | 4.2 | 77 % | 38 / 3 / 2 / 2 / 33 / 0 / 22 | 38 / 3 / 2 / 2 / 33 / 0 / 23 | 50 / 2 / 1 / 3 / 24 / 0 / 20 | 1.31 | 0.10 / 0.67 / 0.54 | 0.15 / 0.00 | 6.41 | 1.6 / 0.9 / 0.4 / 2.1 / 0.4 / 2.3 / 0.6 | 2.0 / 1.3 / 0.8 / 0.9 / 0.9 / 1.8 / 0.2 | 0.80 / 0.65 / 0.52 / 2.31 / 0.45 / 1.29 | strike_jab 19 % | cinder_dive | 21 / 0 / 2 / 0 | 61 / 22 / 17 · 17 | 4.2 | 0.05 |
| groundfade=2,trapfade=2,noshield | 1v1 · 1 · 100 | 41 / 59 / 0 / 0 | 3.0 | 89 % | 50 / 4 / 3 / 1 / 32 / 0 / 10 | 50 / 4 / 3 / 1 / 32 / 0 / 10 | 60 / 3 / 1 / 2 / 24 / 1 / 9 | 1.48 | 0.10 / 0.63 / 0.75 | 0.17 / 0.01 | 6.03 | 1.8 / 1.0 / 0.5 / 0.3 / 0.5 / 2.6 / 0.7 | 2.0 / 1.3 / 0.8 / 0.9 / 0.9 / 1.8 / 0.2 | 0.90 / 0.72 / 0.61 / 0.38 / 0.58 / 1.43 | strike_jab 24 % | bark_veil, cinder_dive, crucible, shade_veil | 11 / 0 / 0 / 0 | 73 / 11 / 7 · 16 | 3.0 | 0.05 |
| bots hunt | 1v1 · 1 · 100 | 42 / 58 / 0 / 0 | 2.6 | 97 % | 52 / 7 / 1 / 3 / 35 / 0 / 1 | 52 / 7 / 1 / 3 / 35 / 0 / 1 | 64 / 5 / 1 / 3 / 25 / 0 / 1 | 1.92 | 0.18 / 0.72 / 1.02 | 0.18 / 0.02 | 6.37 | 2.1 / 1.2 / 0.7 / 1.0 / 0.4 / 3.3 / 1.9 | 2.0 / 1.3 / 0.8 / 0.9 / 0.9 / 1.8 / 0.2 | 1.03 / 0.92 / 0.82 / 1.10 / 0.40 / 1.80 | strike_jab 20 % | none | 3 / 0 / 0 / 0 | 68 / 3 / 2 · 13 | 2.6 | 0.05 |
| groundfade=2,trapfade=2,noshield + bots hunt | 1v1 · 1 · 100 | 41 / 59 / 0 / 0 | 2.2 | 98 % | 59 / 4 / 2 / 1 / 32 / 1 / 0 | 59 / 4 / 2 / 1 / 32 / 1 / 0 | 70 / 4 / 1 / 1 / 24 / 0 / 0 | 1.95 | 0.12 / 0.61 / 1.22 | 0.15 / 0.00 | 6.06 | 2.1 / 1.2 / 0.8 / 0.4 / 0.4 / 2.9 / 1.5 | 2.0 / 1.3 / 0.8 / 0.9 / 0.9 / 1.8 / 0.2 | 1.06 / 0.87 / 0.94 / 0.44 / 0.40 / 1.59 | strike_jab 23 % | bark_veil, shade_veil | 2 / 0 / 0 / 0 | 76 / 2 / 1 · 11 | 2.2 | 0.05 |

### Part G · the opening: battles under 3 rounds, first blood, fixed layout

Single switches on R (seeds 1 and 2, columns as in part A):

| Variant | Wins of `hunt` against the waiting `AiBrain` (160 battles) | `hunt` on both sides: mean rounds | Ended before pressure | Collapse endings | Rounds under 3 / over 7 / over 10 (%) · longest |
|---|---|---|---|---|---|
| R | 51 % | 4.5 | 92 % | 0 % | 15 / 12 / 2 · 13 |
| R + `turns=3` | 49 % | 5.2 | 85 % | 0 % | 15 / 18 / 8 · 13 |
| R + `move=2` | 46 % | 6.2 | 80 % | 0 % | 5 / 28 / 12 · 18 |
| R + `move=2,step=2` | 45 % | 6.9 | 70 % | 0 % | 9 / 35 / 14 · 23 |
| R + `startback,move=2` | 51 % | 5.9 | 86 % | 0 % | 6 / 18 / 10 · 17 |
| R + `startback,hpmin=3` | 52 % | 5.2 | 90 % | 2 % | 5 / 13 / 6 · 14 |
| R + `hpmin=3,move=2` | 42 % | 5.8 | 88 % | 0 % | 2 / 18 / 9 · 14 |
| R + `startback,hpmin=3,move=2` | 49 % | 6.0 | 86 % | 0 % | 4 / 19 / 9 · 19 |

Over four seeds (columns as in part C):

| Variant | Bots (both sides) | Battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Rounds under 3 / over 7 / over 10 (%) · longest | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | Uses per slot and battle: strike / surge / trap / zone / board / move | Defeated before own first turn (per battle) | Wins of `hunt` against the waiting `AiBrain` |
|---|---|---|---|---|---|---|---|---|---|---|
| R + `hpmin=3` | hunt | 160 | 80 / 79 / 1 / 0 | 4.8 | 89 % | 18 / 15 / 4 · 16 | 34 / 30 / 4 / 13 / 18 / 2 / 1 | 0.64 / 1.87 / 1.72 / 0.75 / 1.22 / 2.49 | 0.17 | 161 of 320 (50 %) |
|  | chase | 160 | 80 / 80 / 0 / 0 | 5.4 | 87 % | 15 / 16 / 9 · 20 | 42 / 24 / 1 / 12 / 16 / 2 / 1 | 0.65 / 1.85 / 1.78 / 0.78 / 1.40 / 2.28 | 0.17 |  |
|  | AiBrain | 160 | 70 / 86 / 4 / 0 | 6.8 | 72 % | 11 / 31 / 21 · 20 | 32 / 22 / 1 / 12 / 16 / 1 / 17 | 0.56 / 1.84 / 1.57 / 0.81 / 1.24 / 2.08 | 0.16 |  |
|  | AiBrain + aggro | 160 | 87 / 72 / 1 / 0 | 5.7 | 81 % | 16 / 22 / 15 · 20 | 45 / 20 / 2 / 10 / 11 / 1 / 10 | 0.69 / 1.78 / 1.13 / 0.55 / 1.06 / 2.01 | 0.16 |  |
|  | plan | 40 | 19 / 21 / 0 / 0 | 4.5 | 92 % | 18 / 8 / 8 · 13 | 28 / 20 / 10 / 12 / 22 / 0 / 5 | 0.66 / 1.57 / 1.85 / 0.95 / 1.45 / 1.82 | 0.25 |  |
|  | hunt, pressure +200 | 80 | 39 / 40 / 0 / 1 | 7.2 | 99 % | 14 / 16 / 3 · 197 | 36 / 20 / 6 / 16 / 22 / 0 / 0 | 0.64 / 1.91 / 3.20 / 0.70 / 3.00 / 2.47 | 0.11 |  |
|  | chase, pressure +200 | 80 | 39 / 39 / 0 / 2 | 10.4 | 98 % | 12 / 16 / 12 · 197 | 50 / 22 / 0 / 10 / 12 / 0 / 0 | 0.66 / 1.97 / 6.57 / 0.70 / 5.93 / 2.42 | 0.11 |  |
| R + `startback` | hunt | 160 | 74 / 86 / 0 / 0 | 5.3 | 89 % | 15 / 17 / 7 · 17 | 41 / 22 / 2 / 20 / 15 / 0 / 1 | 0.62 / 1.88 / 1.80 / 0.85 / 1.06 / 2.76 | 0.12 | 155 of 320 (48 %) |
|  | chase | 160 | 77 / 83 / 0 / 0 | 5.6 | 83 % | 14 / 24 / 10 · 21 | 46 / 21 / 3 / 12 / 18 / 0 / 1 | 0.63 / 1.88 / 1.67 / 0.90 / 1.04 / 2.56 | 0.12 |  |
|  | AiBrain | 160 | 74 / 85 / 1 / 0 | 7.2 | 68 % | 14 / 38 / 24 · 25 | 40 / 20 / 3 / 8 / 11 / 0 / 17 | 0.59 / 1.78 / 1.60 / 0.89 / 0.95 / 2.26 | 0.12 |  |
|  | AiBrain + aggro | 160 | 81 / 77 / 2 / 0 | 5.8 | 81 % | 12 / 23 / 13 · 19 | 46 / 20 / 2 / 11 / 12 / 0 / 10 | 0.68 / 1.65 / 1.21 / 0.80 / 0.90 / 2.19 | 0.14 |  |
|  | plan | 40 | 23 / 17 / 0 / 0 | 4.8 | 92 % | 8 / 8 / 2 · 20 | 30 / 30 / 8 / 10 / 20 / 0 / 2 | 0.66 / 1.62 / 1.37 / 0.79 / 1.38 / 2.15 | 0.28 |  |
|  | hunt, pressure +200 | 80 | 39 / 39 / 0 / 2 | 9.4 | 98 % | 15 / 18 / 8 · 198 | 40 / 20 / 2 / 20 / 18 / 0 / 0 | 0.62 / 2.37 / 4.70 / 0.79 / 2.44 / 3.45 | 0.11 |  |
|  | chase, pressure +200 | 80 | 40 / 40 / 0 / 0 | 5.5 | 100 % | 12 / 24 / 8 · 17 | 44 / 16 / 4 / 12 / 26 / 0 / 0 | 0.65 / 1.91 / 1.48 / 0.85 / 1.08 / 2.52 | 0.11 |  |
| R + `startback,hpmin=3` | hunt | 160 | 78 / 81 / 1 / 0 | 5.1 | 89 % | 10 / 16 / 6 · 15 | 39 / 24 / 1 / 14 / 20 / 0 / 2 | 0.67 / 1.94 / 1.56 / 0.96 / 1.08 / 2.77 | 0.13 | 157 of 320 (49 %) |
|  | chase | 160 | 86 / 74 / 0 / 0 | 5.7 | 84 % | 10 / 24 / 8 · 21 | 44 / 23 / 3 / 12 / 16 / 2 / 2 | 0.67 / 1.97 / 1.88 / 0.97 / 1.16 / 2.69 | 0.13 |  |
|  | AiBrain | 160 | 73 / 85 / 2 / 0 | 7.1 | 72 % | 6 / 33 / 23 · 25 | 36 / 18 / 2 / 13 / 14 / 2 / 16 | 0.65 / 1.84 / 1.56 / 0.94 / 1.08 / 2.26 | 0.13 |  |
|  | AiBrain + aggro | 160 | 81 / 78 / 1 / 0 | 6.3 | 76 % | 12 / 27 / 16 · 20 | 42 / 20 / 2 / 13 / 11 / 1 / 12 | 0.69 / 1.77 / 1.36 / 0.89 / 0.92 / 2.25 | 0.14 |  |
|  | plan | 40 | 22 / 17 / 1 / 0 | 4.8 | 95 % | 8 / 8 / 2 · 14 | 42 / 25 / 2 / 12 / 15 / 0 / 2 | 0.68 / 1.64 / 1.31 / 0.87 / 1.25 / 2.19 | 0.28 |  |
|  | hunt, pressure +200 | 80 | 37 / 42 / 0 / 1 | 7.5 | 99 % | 5 / 13 / 6 · 198 | 42 / 19 / 0 / 15 / 24 / 0 / 0 | 0.70 / 1.97 / 2.78 / 0.90 / 2.02 / 2.83 | 0.12 |  |
|  | chase, pressure +200 | 80 | 40 / 39 / 0 / 1 | 8.3 | 99 % | 5 / 26 / 9 · 198 | 42 / 24 / 3 / 12 / 20 / 0 / 0 | 0.66 / 2.12 / 3.74 / 0.93 / 2.86 / 3.06 | 0.12 |  |
| R + `hpmin=3,move=2` | hunt | 160 | 80 / 80 / 0 / 0 | 5.7 | 89 % | 5 / 16 / 8 · 18 | 34 / 27 / 3 / 18 / 14 / 0 / 1 | 0.50 / 2.32 / 1.63 / 1.09 / 1.12 / 1.86 | 0.08 | 141 of 320 (44 %) |
|  | chase | 160 | 79 / 80 / 1 / 0 | 6.1 | 83 % | 6 / 24 / 14 · 19 | 27 / 36 / 3 / 18 / 11 / 4 / 0 | 0.43 / 2.20 / 1.88 / 1.09 / 1.22 / 1.72 | 0.08 |  |
|  | AiBrain | 160 | 73 / 81 / 6 / 0 | 8.0 | 68 % | 4 / 39 / 27 · 22 | 31 / 20 / 1 / 19 / 8 / 2 / 18 | 0.43 / 2.24 / 1.87 / 1.09 / 1.21 / 1.72 | 0.08 |  |
|  | AiBrain + aggro | 160 | 90 / 70 / 0 / 0 | 6.7 | 74 % | 8 / 31 / 20 · 20 | 36 / 23 / 2 / 14 / 14 / 0 / 12 | 0.56 / 2.06 / 1.47 / 0.89 / 1.23 / 1.59 | 0.07 |  |
|  | plan | 40 | 19 / 21 / 0 / 0 | 5.0 | 90 % | 12 / 15 / 5 · 14 | 30 / 20 / 2 / 22 / 25 / 0 / 0 | 0.53 / 2.17 / 2.01 / 1.42 / 1.58 / 0.92 | 0.08 |  |
|  | hunt, pressure +200 | 80 | 45 / 35 / 0 / 0 | 5.8 | 100 % | 2 / 18 / 9 · 14 | 33 / 32 / 4 / 14 / 14 / 0 / 0 | 0.52 / 2.38 / 1.55 / 1.06 / 1.16 / 1.90 | 0.07 |  |
|  | chase, pressure +200 | 80 | 47 / 33 / 0 / 0 | 6.2 | 100 % | 2 / 24 / 16 · 19 | 30 / 39 / 3 / 15 / 12 / 0 / 0 | 0.48 / 2.26 / 1.75 / 1.08 / 1.21 / 1.70 | 0.07 |  |


Further single causes tried on R (seeds 1 and 2, columns as in part A): two turns per round and repeated casting.

| Variant | Wins of `hunt` against the waiting `AiBrain` (160 battles) | `hunt` on both sides: mean rounds | Ended before pressure | Collapse endings | Rounds under 3 / over 7 / over 10 (%) · longest |
|---|---|---|---|---|---|
| R + `tprmax=1` (every monster one turn per round) | 46 % | 4.8 | 90 % | 0 % | 14 / 16 / 2 · 11 |
| R + `tprmax=1,apmin=3` | 48 % | 5.3 | 88 % | 2 % | 14 / 16 / 9 · 17 |
| R + `tprmax=1,apmin=3,hpmin=3,startback` | 54 % | 5.0 | 96 % | 0 % | 8 / 12 / 4 · 18 |
| R + `zoneonce` (zone skills once per round) | 55 % | 4.6 | 92 % | 0 % | 16 / 16 / 4 · 12 |
| R + `castonce` (zone, Surge, trap and board skills once per round) | 45 % | 4.8 | 92 % | 0 % | 14 / 13 / 0 · 10 |
| R + `zoneonce,startback,hpmin=3` | 50 % | 5.6 | 88 % | 0 % | 2 / 20 / 6 · 16 |
| R + `castonce,startback,hpmin=3` | 51 % | 5.2 | 85 % | 0 % | 9 / 20 / 6 · 16 |
| `groundfade=2,trapfade=2,castonce` (shields kept) | 50 % | 5.9 | 79 % | 0 % | 13 / 26 / 12 · 16 |

How a defeat in round 1 comes about (events of traced battles under R): a fast monster goes in with Step and its movement skill, the other side answers with what costs 1 AP and needs no waiting: a push zone cast twice in one turn (each cast moves the monsters in it and deals 1 collision damage to both colliding monsters), the ring push of Quake Leap, a Jab; 2 HP are gone after two such hits.

First blood (full-block runs with `SIM_DEBUG`, seeds 1–4, 160 battles each): the side that defeats the first monster wins 99 of 158 decided battles under the build rules and 109 of 160 under R with `hunt` (63 % / 68 %), 104 of 159 and 102 of 160 with `chase` (65 % / 64 %); 95–96 % of all battles have a defeat in round 1.

Fixed test layout instead of seeded boards (`--board layout`), build rules then R, `AiBrain` then `hunt`:

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used | Reached pressure: HP leader won / lost / HP level / no winner | Rounds under 3 / over 7 / over 10 (%) · longest | First defeat in round (mean) | Defeated before own first turn (per battle) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| build rules | 3v3 · 1 · 40 | 21 / 18 / 1 / 0 | 12.6 | 25 % | 10 / 8 / 0 / 0 / 3 / 0 / 75 | 17 / 17 / 3 / 6 / 21 / 0 / 29 | 17 / 22 / 2 / 6 / 21 / 0 / 28 | 8.35 | 2.45 / 3.65 / 2.25 | 0.69 / 0.08 | 26.75 | 2.5 / 4.7 / 3.6 / 11.0 / 3.0 / 7.8 / 4.5 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.41 / 1.18 / 1.37 / 3.94 / 1.16 / 1.48 | bark_veil 14 % | none | 27 / 1 / 2 / 0 | 10 / 78 / 75 · 20 | 1.2 | 0.05 |
| build rules | 3v3 · 2 · 40 | 25 / 13 / 2 / 0 | 12.3 | 30 % | 0 / 8 / 0 / 8 / 13 / 3 / 68 | 13 / 21 / 2 / 9 / 18 / 1 / 30 | 13 / 27 / 1 / 5 / 20 / 0 / 30 | 7.35 | 2.60 / 2.67 / 2.08 | 0.92 / 0.07 | 25.57 | 1.8 / 4.5 / 2.9 / 11.1 / 2.1 / 7.0 / 3.6 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.29 / 1.14 / 1.04 / 3.91 / 0.85 / 1.30 | bark_veil 16 % | none | 17 / 6 / 5 / 0 | 13 / 70 / 70 · 22 | 1.1 | 0.25 |
| groundfade=2,trapfade=2,noshield | 3v3 · 1 · 40 | 20 / 19 / 1 / 0 | 8.9 | 60 % | 25 / 13 / 0 / 5 / 15 / 0 / 35 | 27 / 20 / 4 / 7 / 22 / 0 / 11 | 23 / 30 / 2 / 5 / 21 / 0 / 12 | 12.40 | 2.88 / 5.85 / 3.67 | 0.62 / 0.06 | 25.73 | 3.1 / 7.0 / 5.4 / 1.8 / 3.8 / 10.3 / 6.3 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.51 / 1.76 / 2.03 / 0.64 / 1.47 / 1.94 | Step 17 % | bark_veil, shade_veil | 12 / 3 / 1 / 0 | 13 / 45 / 35 · 20 | 1.1 | 0.07 |
| groundfade=2,trapfade=2,noshield | 3v3 · 2 · 40 | 20 / 18 / 2 / 0 | 7.7 | 68 % | 28 / 8 / 5 / 20 / 15 / 0 / 23 | 21 / 23 / 3 / 12 / 24 / 0 / 8 | 21 / 34 / 2 / 6 / 24 / 0 / 7 | 11.72 | 3.12 / 4.67 / 3.92 | 0.74 / 0.04 | 25.75 | 3.0 / 7.2 / 4.5 / 1.6 / 2.9 / 11.4 / 5.7 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.50 / 1.84 / 1.63 / 0.58 / 1.15 / 2.12 | Step 16 % | bark_veil, shade_veil | 8 / 2 / 2 / 1 | 10 / 35 / 28 · 18 | 1.1 | 0.25 |
| bots hunt | 3v3 · 1 · 40 | 20 / 20 / 0 / 0 | 7.4 | 70 % | 23 / 15 / 0 / 20 / 18 / 13 / 3 | 26 / 23 / 3 / 15 / 20 / 3 / 2 | 22 / 31 / 1 / 13 / 22 / 2 / 1 | 11.78 | 3.30 / 5.10 / 3.38 | 0.65 / 0.05 | 25.48 | 3.0 / 7.1 / 4.7 / 6.1 / 3.3 / 14.6 / 13.9 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.50 / 1.77 / 1.76 / 2.17 / 1.29 / 2.75 | Step 26 % | none | 10 / 2 / 0 / 0 | 15 / 38 / 28 · 19 | 1.1 | 0.05 |
| bots hunt | 3v3 · 2 · 40 | 17 / 23 / 0 / 0 | 9.3 | 58 % | 18 / 8 / 3 / 28 / 15 / 23 / 8 | 23 / 22 / 2 / 16 / 21 / 5 / 2 | 20 / 29 / 2 / 14 / 23 / 3 / 4 | 10.55 | 2.95 / 4.08 / 3.52 | 0.67 / 0.06 | 24.98 | 2.6 / 7.3 / 3.2 / 7.6 / 1.9 / 18.4 / 14.6 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.44 / 1.85 / 1.18 / 2.70 / 0.79 / 3.41 | Step 26 % | none | 12 / 3 / 2 / 0 | 18 / 48 / 40 · 22 | 1.1 | 0.23 |
| groundfade=2,trapfade=2,noshield + bots hunt | 3v3 · 1 · 40 | 23 / 17 / 0 / 0 | 5.0 | 88 % | 40 / 13 / 0 / 10 / 30 / 0 / 0 | 31 / 26 / 3 / 10 / 24 / 0 / 0 | 27 / 34 / 2 / 7 / 23 / 0 / 0 | 12.28 | 3.00 / 5.15 / 4.12 | 0.67 / 0.06 | 25.32 | 3.6 / 7.9 / 4.4 / 1.5 / 2.9 / 14.2 / 9.5 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.60 / 1.97 / 1.66 / 0.54 / 1.13 / 2.67 | Step 22 % | bark_veil, shade_veil | 3 / 2 / 0 / 0 | 13 / 18 / 5 · 12 | 1.1 | 0.07 |
| groundfade=2,trapfade=2,noshield + bots hunt | 3v3 · 2 · 40 | 20 / 20 / 0 / 0 | 4.6 | 93 % | 28 / 28 / 5 / 15 / 23 / 0 / 0 | 23 / 32 / 4 / 10 / 25 / 0 / 0 | 23 / 38 / 2 / 8 / 24 / 0 / 0 | 10.55 | 3.20 / 3.52 / 3.83 | 0.85 / 0.06 | 24.30 | 3.0 / 7.2 / 3.3 / 1.5 / 1.9 / 13.7 / 8.1 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.49 / 1.83 / 1.21 / 0.54 / 0.79 / 2.53 | Step 21 % | bark_veil, shade_veil | 2 / 1 / 0 / 0 | 18 / 10 / 3 · 13 | 1.1 | 0.23 |

### Part H · fixed teams: three slow, sturdy monsters on both sides, and against three fragile ones

Forge Golem, Moss Turtle and Hollow Serpent (23 HP, Movement 1–2) on both sides, seeded boards, `hunt` on both sides, seeds 1 and 2 (80 battles per row; `--team-a forge_golem,moss_turtle,hollow_serpent --board seeded`):

| Variant | Mean rounds | Ended before pressure | Collapse endings | Rounds under 3 / over 7 / over 10 (%) · longest |
|---|---|---|---|---|
| build rules | 16.1 | 4 % | 20 % | 0 / 96 / 88 · 25 |
| R | 8.8 | 59 % | 0 % | 0 / 54 / 26 · 20 |
| R + `hpmax=6` | 7.9 | 64 % | 0 % | 0 / 52 / 12 · 20 |
| R + `hpmax=5` | 7.8 | 68 % | 0 % | 2 / 48 / 15 · 20 |
| R + `hp=-1` | 7.8 | 72 % | 2 % | 0 / 46 / 15 · 18 |
| R + `hp=-2` | 7.2 | 74 % | 0 % | 0 / 40 / 10 · 16 |
| R + `jab=1` | 7.3 | 75 % | 0 % | 0 / 39 / 12 · 19 |
| R + `turns=1` | 7.2 | 74 % | 2 % | 0 / 39 / 8 · 19 |
| R + `strikedmg=3` | 8.2 | 65 % | 0 % | 0 / 52 / 20 · 21 |
| R + `surgedmg=1` | 8.7 | 59 % | 0 % | 0 / 55 / 24 · 21 |
| R + `push=2` | 8.2 | 62 % | 0 % | 0 / 54 / 20 · 17 |
| R + `softpressure=2` | 8.0 | 59 % | 0 % | 0 / 54 / 16 · 12 |
| `groundfade=2,trapfade=2` + strike_arc for Bark Veil | 8.6 | 62 % | 2 % | 0 / 53 / 30 · 21 |
| `groundfade=2,trapfade=2` + mire for Bark Veil | 10.1 | 34 % | 2 % | 0 / 83 / 42 · 20 |

The same team with `AiBrain` on both sides, and against Dusk Moth, Ember Hawk and Thorn Mites (`--team-b`, `hunt`), build rules then R:

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used | Reached pressure: HP leader won / lost / HP level / no winner | Rounds under 3 / over 7 / over 10 (%) · longest | First defeat in round (mean) | Defeated before own first turn (per battle) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| build rules | 3v3 · 1 · 40 | 5 / 5 / 30 / 0 | 20.4 | 0 % | 0 / 0 / 0 / 0 / 0 / 3 / 98 | 3 / 4 / 0 / 8 / 0 / 1 / 84 | 3 / 11 / 0 / 7 / 1 / 1 / 75 | 8.07 | 2.85 / 2.20 / 3.02 | 0.63 / 0.01 | 45.45 | 0.8 / 5.0 / 3.1 / 31.0 / 0.1 / 4.7 / 10.5 | 6.0 / 4.0 / 4.0 / 2.0 / 2.0 / 4.0 / 2.0 | 0.13 / 1.24 / 0.78 / 15.49 / 0.07 / 1.16 | bark_veil 56 % | none | 6 / 3 / 17 / 14 | 0 / 100 / 100 · 25 | 10.3 | 0.00 |
| build rules | 3v3 · 2 · 40 | 6 / 2 / 32 / 0 | 19.8 | 0 % | 0 / 0 / 0 / 0 / 0 / 0 / 100 | 3 / 7 / 1 / 7 / 0 / 0 / 81 | 5 / 13 / 1 / 7 / 1 / 0 / 73 | 8.20 | 3.35 / 2.00 / 2.85 | 0.77 / 0.02 | 46.17 | 1.2 / 5.2 / 3.0 / 30.1 / 0.5 / 4.0 / 8.4 | 6.0 / 4.0 / 4.0 / 2.0 / 2.0 / 4.0 / 2.0 | 0.20 / 1.31 / 0.74 / 15.03 / 0.25 / 0.99 | bark_veil 57 % | none | 6 / 2 / 18 / 14 | 0 / 100 / 100 · 23 | 8.3 | 0.00 |
| groundfade=2,trapfade=2,noshield | 3v3 · 1 · 40 | 20 / 10 / 10 / 0 | 15.1 | 8 % | 23 / 15 / 3 / 0 / 10 / 3 / 48 | 22 / 26 / 3 / 18 / 6 / 1 / 23 | 21 / 41 / 2 / 10 / 6 / 1 / 17 | 23.35 | 7.03 / 8.38 / 7.95 | 0.75 / 0.05 | 43.15 | 4.8 / 15.5 / 7.8 / 0.0 / 1.2 / 12.6 / 18.3 | 6.0 / 4.0 / 4.0 / 2.0 / 2.0 / 4.0 / 2.0 | 0.79 / 3.88 / 1.96 / 0.00 / 0.61 / 3.14 | Step 30 % | bark_veil | 21 / 6 / 6 / 4 | 0 / 95 / 80 · 22 | 4.1 | 0.00 |
| groundfade=2,trapfade=2,noshield | 3v3 · 2 · 40 | 23 / 12 / 5 / 0 | 13.9 | 23 % | 15 / 10 / 5 / 8 / 13 / 0 / 50 | 15 / 28 / 5 / 18 / 7 / 0 / 25 | 20 / 41 / 3 / 10 / 5 / 0 / 19 | 22.10 | 6.75 / 7.90 / 7.45 | 0.80 / 0.04 | 42.88 | 4.8 / 14.7 / 7.4 / 0.0 / 1.1 / 11.3 / 16.5 | 6.0 / 4.0 / 4.0 / 2.0 / 2.0 / 4.0 / 2.0 | 0.81 / 3.67 / 1.85 / 0.00 / 0.56 / 2.83 | Step 30 % | bark_veil | 22 / 2 / 6 / 0 | 0 / 85 / 68 · 22 | 4.6 | 0.00 |
| bots hunt | 3v3 · 1 · 40 | 38 / 2 / 0 / 0 | 6.8 | 75 % | 5 / 48 / 0 / 15 / 20 / 5 / 8 | 16 / 33 / 2 / 22 / 14 / 1 / 5 | 10 / 39 / 2 / 22 / 18 / 1 / 4 | 16.90 | 4.05 / 6.92 / 5.92 | 0.47 / 0.01 | 19.35 | 1.2 / 6.2 / 10.7 / 10.5 / 5.3 / 15.6 / 17.3 | 6.0 / 4.0 / 3.0 / 3.0 / 2.0 / 5.0 / 1.0 | 0.20 / 1.55 / 3.57 / 3.50 / 2.65 / 3.11 | Step 26 % | none | 10 / 0 / 0 / 0 | 5 / 33 / 18 · 18 | 1.3 | 0.05 |
| bots hunt | 3v3 · 2 · 40 | 40 / 0 / 0 / 0 | 8.2 | 60 % | 13 / 33 / 0 / 23 / 13 / 13 / 8 | 20 / 32 / 2 / 26 / 11 / 3 / 3 | 12 / 43 / 2 / 21 / 15 / 2 / 2 | 17.55 | 4.15 / 7.78 / 5.62 | 0.52 / 0.01 | 20.52 | 1.6 / 6.5 / 11.0 / 9.9 / 6.3 / 18.3 / 20.2 | 6.0 / 4.0 / 3.0 / 3.0 / 2.0 / 5.0 / 1.0 | 0.26 / 1.63 / 3.67 / 3.30 / 3.15 / 3.65 | Step 27 % | none | 16 / 0 / 0 / 0 | 5 / 45 / 30 · 23 | 1.2 | 0.05 |
| groundfade=2,trapfade=2,noshield + bots hunt | 3v3 · 1 · 40 | 38 / 2 / 0 / 0 | 5.1 | 88 % | 28 / 45 / 0 / 10 / 15 / 0 / 0 | 33 / 33 / 6 / 8 / 16 / 0 / 0 | 19 / 47 / 4 / 12 / 16 / 0 / 0 | 16.18 | 3.48 / 6.15 / 6.55 | 0.66 / 0.04 | 22.25 | 2.2 / 6.2 / 10.0 / 2.5 / 4.5 / 14.1 / 14.3 | 6.0 / 4.0 / 3.0 / 3.0 / 2.0 / 5.0 / 1.0 | 0.36 / 1.55 / 3.33 / 0.82 / 2.27 / 2.82 | Step 27 % | bark_veil, shade_veil | 5 / 0 / 0 / 0 | 8 / 15 / 5 · 20 | 1.0 | 0.07 |
| groundfade=2,trapfade=2,noshield + bots hunt | 3v3 · 2 · 40 | 37 / 3 / 0 / 0 | 5.0 | 90 % | 33 / 28 / 3 / 15 / 20 / 3 / 0 | 35 / 28 / 4 / 13 / 18 / 1 / 0 | 19 / 45 / 2 / 12 / 20 / 1 / 0 | 15.90 | 3.02 / 6.35 / 6.53 | 0.64 / 0.02 | 22.12 | 2.5 / 5.7 / 10.2 / 2.6 / 4.8 / 13.0 / 11.8 | 6.0 / 4.0 / 3.0 / 3.0 / 2.0 / 5.0 / 1.0 | 0.42 / 1.43 / 3.40 / 0.88 / 2.42 / 2.60 | Step 23 % | bark_veil, shade_veil | 4 / 0 / 0 / 0 | 20 / 13 / 10 · 16 | 1.0 | 0.23 |

**Observations** (indications; bots only; R = `groundfade=2,trapfade=2,noshield`):

- *What makes waiting pay is the board filling up.* In the long battles of the build rules the middle of the board is covered with hazard ground and markers after four or five rounds and nobody finds a square to advance to (traces of single battles). With ground that lasts 2 rounds the `hunt` bot wins 47–50 % against the waiting `AiBrain` instead of 40–44 %, and battles between two `hunt` bots fall from 7.7 to 6.0 rounds. No other single switch of part A does this: Jab for 1 AP, faster or all-timed Surges, more Strike or Surge damage, lower HP, dearer or once-per-round shields, a longer start distance and 2-square pushes all leave `hunt` at 36–48 % and the share of battles over 10 rounds at 19–46 % (`noshield` alone: 13 %).
- *Three changes carry the result; two are needed, the third helps* (parts C and D, removing one at a time from R, `hunt` unless named): without the ground clock 5.4 instead of 4.5 rounds, walking up loses again (42 %) and 11 of 80 control battles without pressure reach the turn limit (`chase`); without `noshield` 5.4 rounds and 38 % instead of 22 % of battles between waiting bots over 10 rounds; without the trap clock 4.9 instead of 4.6 rounds over eight seeds, and with waiting bots 7.9 instead of 6.9 rounds with 29 % instead of 16 % collapse endings. A trap limit of one per skill (`trapcap=1`) does about the same as the trap clock (4.5 rounds; 7.2 rounds and 22 % with waiting bots).
- *R against the build rules over eight seeds (part D):* mean length 4.6 instead of 7.6 rounds (`hunt`), 5.2 instead of 8.3 (`chase`), 4.5 instead of 7.7 (`plan`), 6.9 instead of 11.2 (waiting `AiBrain`); ended before pressure 94 % / 86 % / 89 % / 73 % instead of 68 % / 61 % / 62 % / 38 %; over 10 rounds 3 % / 8 % / 9 % / 22 % instead of 28 % / 36 % / 36 % / 62 %; collapse endings 0 % / 1 % / 4 % / 16 % instead of 6 % / 15 % / 26 % / 60 %. With pressure out of reach (`--pressure 200`, seeds 1–6, 240 battles per cell) all `hunt` battles end by fighting within 14 rounds (mean 4.6; build rules: 24 reach the turn limit) and 238 of 240 `chase` battles (mean 6.6; build rules: 53 at the turn limit). The sides stay level (161 : 159 with `hunt`).
- *The waiting bot stays the slow case.* Two `AiBrain` sides still need 6.9 rounds with 22 % over 10 under R, because neither walks up; with R walking up is close to level (303 of 640 battles over eight seeds, 47 %, against 256 of 640, 40 %, under the build rules), so this is mostly a matter of the opponent AI.
- *The short end is the open flank.* The first monster falls in round 1 in almost every battle under every variant (mean 1.0–1.1; 80 traced battles of one variant with back-row starts had 112 defeats in round 1, nearly all of them the 2–5 HP monsters with high initiative that go in first: Ember Hawk 37, Dusk Moth 26, Grove Wisp 23, Thorn Mites 13, Blaze Tiger 11), and 10–24 % of battles are over before round 3. Alone, a higher HP floor, a longer start distance and slower or weaker Surges change this by a few points at most. Back-row starts together with an HP floor of 3 (Dusk Moth and Ember Hawk 3 instead of 2) lower the share under 3 rounds over eight seeds (part D: 18 % → 12 % with `hunt`, 16 % → 11 % with `chase`, 24 % → 11 % with the planning bot) for 0.2–0.3 rounds more; one turn per round for every monster and once-per-round casting do not (part G); movement skills back at 2 AP bring it to 5 % but walking up loses again (44 %) and more battles pass 10 rounds. Monsters defeated before their own first turn under R: 0.11–0.15 per battle. The first defeat does not decide the battle: the side that scores it wins 63–68 %, under the build rules as under R. Whether people overextend like these bots is a question for play.
- *The user's other candidates on top of R (part B):* Jab for 1 AP, Surges after 1 turn and 1 HP less shorten nothing that matters (4.3 / 3.8 / 4.7 rounds against 4.5) and raise the share of battles under 3 rounds from 15 % to 20–29 %. Pressure without damage changes nothing measurable once battles end before it starts.
- *Replacement skills for the two veil slots (part B):* Mire and Blink keep the length distribution closest to the target (5.3–5.4 rounds, 10 % under 3, 6–8 % over 10); pull zones (Bog, Void Pull) make traps deal 9–12 % of the last blows instead of 4–5 % (`hunt`) but end 23–25 % of battles before round 3. A second Strike shape at 3 AP is hardly used (Thrust: never).
- *Skill kinds, how battles end (part C, R):* last blows by Strike 38 %, Surge 25 %, collision 16 %, hazard ground 13 %, trap 5 % (`hunt`); with the planning bot 25 / 18 / 22 / 10 and trap 20 %. Uses per slot and battle: Surge 1.8, trap 1.5, board 1.1, zone 0.7 (two of the fielded zone slots are the switched-off veils; 2.2 with Mire / Blink), Strike 0.65, movement 2.4. No kind stands at zero and no source ends more than 44 % of the battles; under the build rules the collapse ended 60 % with the waiting bot.
- *Skill kinds, what they are worth (part E):* a side without its Strikes wins 19–30 % and one without its Surges 29–31 %; without movement skills 42–46 %; without traps, zones or board skills 42–53 %, which is inside the noise around 50 % (zone with the planning bot: 42 %). In bot hands Strike and Surge decide, and the three board-shaping kinds can be replaced by the other actions. The Jab is the least used slot and the most needed one.
- *Team make-up sets the upper end (part H).* Three slow, sturdy monsters on both sides need 15.9–16.4 rounds under the build rules (with the waiting bot 30–32 of 40 battles are Draws by collapse) and 8.8 rounds under R, where 26 % still pass 10 rounds. No further switch brings this mirror under 7 rounds: 2 HP less, Jab for 1 AP and Surges after 1 turn reach 7.2–7.3, an HP ceiling of 5–6 gives 7.8–7.9, and Mire in the freed slot lengthens it to 10.1. Against three fragile, fast monsters the sturdy team wins 75–78 of 80 battles under both rule sets.
- *2v2 and 1v1 (part F, cross-check only):* 2v2 gets shorter (5.1 instead of 6.9 rounds with `AiBrain`, 3.8 instead of 4.1 with `hunt`); 1v1 was already short and gets shorter (3.0 instead of 4.2 and 2.2 instead of 2.6 rounds; 61–76 % of 1v1 battles end before round 3, and side 1 wins 54–59 %). The 1v1 figures are a gross break that exists under the build rules as well.
- *Limits:* all bots are crude; `hunt` and `chase` were written for this entry and their “walking up” is one way of attacking. Bots do not push into traps or props on purpose (the planning bot a little), so the low value of traps, zones and board skills is not a verdict on those kinds. Nothing here says whether the battles are fun, fair or readable.

**Follow-up:** T38 (ground and trap clock or trap limit, kit protection: user decisions; rule text for Battle §4.5 if adopted), T13 (length distribution, attacker's share and kind value as standing metrics; the early defeats; human play of the candidate in the draft sandbox), T11 (replacement skills for the veil slots; the Strike slot), I42 / opponent AI (an `AiBrain` that walks up), T02 (prices stay ignored by user decision).

## S010 · 2026-11-12 · rerun of the interrupted series in 3v3, length distribution, attacking against waiting bots

**State:** `c35396a` dirty (uncommitted tool and switch changes; the rules of the build are unchanged) · content `2026-11-12.2` · kit set `736eb4e604a6`. 3v3 only (user focus 2026-11-12); the 2v2 and 1v1 rows of the interrupted list were not run. 1 720 battles in 45 runs.

**Questions (user):** do battles end by fighting instead of by late-round pressure, and within 3–7 rounds (more than 10 rounds counts as a failure); what do the three open candidates do (no shield zones, pressure without damage, Jab for 1 AP); is the standstill a rule problem or a bot problem.

**New columns of `sim.gd`** (last three): share of battles under 3, over 7 and over 10 rounds and the longest battle · mean round of the first defeat · monsters defeated before their own first turn, per battle.

| Variant / bot | What it is |
|---|---|
| `noshield`, `jab=1`, `softpressure=N` | as in the handoff: shield zone skills unusable · Jab 1 AP · every N rounds the outer ring breaks away instead of damage |
| `aggro` | bot change: `AiBrain` values closing in more and its own support effects less |
| `pressure +200` | late-round pressure out of reach |
| bot `hunt` (new) | `AiBrain` with the switch `ai_hunt`: with AP left and no better action it walks toward the nearest enemy (walking distance) as long as the position gets no worse than about one point of hazard damage; never into a trap |
| bot `rush` | strikes whoever is in a shape, else casts, else walks toward the nearest enemy, without judging the position |

Command per row: `sim.gd -- <battles> 3v3 <seed> "c35396a dirty" --paired --compact [--variant …] [--pressure 200] [--bot-a … --bot-b …]`. Rows are pasted unchanged from the tool; the bots of a table are named above it.

### Part A · the interrupted series (`AiBrain` on both sides)

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used | Reached pressure: HP leader won / lost / HP level / no winner | Rounds under 3 / over 7 / over 10 (%) · longest | First defeat in round (mean) | Defeated before own first turn (per battle) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| build rules | 3v3 · 1 · 40 | 22 / 15 / 3 / 0 | 11.9 | 30 % | 13 / 3 / 3 / 3 / 10 / 0 / 68 | 19 / 26 / 3 / 5 / 17 / 1 / 26 | 18 / 28 / 2 / 5 / 21 / 0 / 25 | 8.95 | 3.25 / 3.62 / 2.08 | 0.78 / 0.09 | 26.57 | 2.5 / 5.7 / 3.2 / 11.6 / 3.2 / 7.9 / 4.0 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.41 / 1.43 / 1.23 / 4.14 / 1.25 / 1.49 | bark_veil 15 % | none | 19 / 5 / 3 / 1 | 13 / 73 / 70 · 21 | 1.1 | 0.03 |
| noshield | 3v3 · 1 · 40 | 20 / 18 / 2 / 0 | 10.6 | 38 % | 15 / 15 / 0 / 5 / 10 / 0 / 53 | 20 / 30 / 2 / 9 / 15 / 2 / 20 | 18 / 35 / 1 / 6 / 20 / 1 / 17 | 9.07 | 3.23 / 3.70 / 2.15 | 0.99 / 0.09 | 27.15 | 2.7 / 6.2 / 2.9 / 2.0 / 2.7 / 9.1 / 4.8 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.45 / 1.54 / 1.09 / 0.72 / 1.05 / 1.72 | Step 16 % | bark_veil, crucible, shade_veil | 19 / 3 / 2 / 1 | 13 / 63 / 60 · 19 | 1.1 | 0.05 |
| jab=1 | 3v3 · 1 · 40 | 23 / 15 / 2 / 0 | 12.3 | 28 % | 8 / 5 / 0 / 0 / 15 / 0 / 73 | 29 / 17 / 1 / 4 / 18 / 0 / 28 | 25 / 21 / 1 / 4 / 20 / 0 / 27 | 7.85 | 2.30 / 3.58 / 1.98 | 0.64 / 0.08 | 26.12 | 3.6 / 4.7 / 3.1 / 11.3 / 2.8 / 7.8 / 4.0 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.60 / 1.18 / 1.18 / 4.03 / 1.09 / 1.48 | bark_veil 13 % | none | 25 / 2 / 0 / 2 | 13 / 73 / 73 · 22 | 1.1 | 0.12 |
| softpressure=1 | 3v3 · 1 · 40 | 20 / 20 / 0 / 0 | 8.6 | 30 % | 20 / 15 / 10 / 25 / 25 / 0 / 0 | 22 / 29 / 5 / 16 / 23 / 0 / 0 | 22 / 33 / 5 / 13 / 25 / 0 / 0 | 10.57 | 3.88 / 4.03 / 2.67 | 0.80 / 0.12 | 25.98 | 3.0 / 6.8 / 3.7 / 8.8 / 3.5 / 8.4 / 4.3 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.50 / 1.71 / 1.41 / 3.15 / 1.39 / 1.59 | Step 11 % | none | 21 / 3 / 3 / 0 | 13 / 73 / 35 · 15 | 1.1 | 0.03 |
| softpressure=2 | 3v3 · 1 · 40 | 19 / 21 / 0 / 0 | 8.9 | 30 % | 25 / 20 / 13 / 20 / 20 / 0 / 0 | 23 / 31 / 6 / 15 / 21 / 0 / 0 | 21 / 33 / 6 / 14 / 23 / 0 / 0 | 10.80 | 4.05 / 4.25 / 2.50 | 0.82 / 0.12 | 25.90 | 2.9 / 7.0 / 3.9 / 9.1 / 3.6 / 8.6 / 4.6 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.47 / 1.74 / 1.45 / 3.23 / 1.40 / 1.62 | Step 12 % | none | 19 / 5 / 3 / 0 | 13 / 73 / 48 · 15 | 1.1 | 0.03 |
| noshield,jab=1 | 3v3 · 1 · 40 | 21 / 17 / 2 / 0 | 10.2 | 45 % | 15 / 13 / 0 / 10 / 8 / 0 / 55 | 30 / 21 / 1 / 9 / 11 / 0 / 25 | 27 / 25 / 0 / 6 / 18 / 0 / 23 | 7.62 | 2.17 / 3.65 / 1.80 | 0.82 / 0.05 | 26.10 | 3.9 / 4.9 / 2.7 / 1.9 / 2.6 / 8.9 / 4.1 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.65 / 1.23 / 1.02 / 0.68 / 1.01 / 1.68 | Step 14 % | bark_veil, shade_veil | 19 / 1 / 0 / 2 | 20 / 55 / 55 · 22 | 1.0 | 0.17 |
| noshield,jab=1,softpressure=2 | 3v3 · 1 · 40 | 19 / 21 / 0 / 0 | 7.5 | 45 % | 28 / 38 / 3 / 18 / 15 / 0 / 0 | 34 / 31 / 2 / 16 / 14 / 0 / 0 | 31 / 31 / 4 / 11 / 20 / 0 / 0 | 9.00 | 3.10 / 3.95 / 1.95 | 0.97 / 0.06 | 26.02 | 4.5 / 6.0 / 3.0 / 1.9 / 2.8 / 9.2 / 4.7 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.75 / 1.49 / 1.15 / 0.70 / 1.10 / 1.74 | Step 15 % | bark_veil, shade_veil | 16 / 6 / 0 / 0 | 20 / 55 / 38 · 14 | 1.0 | 0.17 |
| noshield,jab=1,softpressure=1 | 3v3 · 1 · 40 | 21 / 19 / 0 / 0 | 7.2 | 45 % | 25 / 30 / 3 / 18 / 25 / 0 / 0 | 34 / 28 / 3 / 16 / 17 / 0 / 0 | 31 / 31 / 4 / 11 / 20 / 0 / 0 | 8.93 | 2.98 / 3.80 / 2.15 | 0.95 / 0.07 | 25.65 | 4.5 / 5.9 / 3.0 / 1.9 / 2.8 / 9.2 / 4.7 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.74 / 1.48 / 1.14 / 0.70 / 1.09 / 1.73 | Step 15 % | bark_veil, shade_veil | 16 / 6 / 0 / 0 | 20 / 55 / 23 · 14 | 1.0 | 0.17 |
| aggro | 3v3 · 1 · 40 | 24 / 16 / 0 / 0 | 9.5 | 50 % | 23 / 8 / 3 / 13 / 10 / 0 / 45 | 29 / 23 / 3 / 10 / 18 / 0 / 14 | 24 / 31 / 1 / 8 / 20 / 0 / 14 | 7.97 | 2.80 / 3.25 / 1.93 | 0.94 / 0.11 | 25.85 | 3.2 / 6.0 / 2.0 / 5.4 / 1.9 / 9.6 / 4.5 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.54 / 1.49 / 0.75 / 1.92 / 0.76 / 1.80 | Step 14 % | spring_burst | 18 / 1 / 1 / 0 | 13 / 50 / 50 · 19 | 1.0 | 0.07 |
| aggro,noshield,jab=1,softpressure=2 | 3v3 · 1 · 40 | 20 / 19 / 1 / 0 | 7.0 | 50 % | 33 / 20 / 5 / 28 / 15 / 0 / 0 | 41 / 26 / 2 / 11 / 17 / 0 / 0 | 35 / 33 / 2 / 10 / 19 / 0 / 0 | 8.53 | 3.02 / 3.52 / 1.98 | 1.00 / 0.09 | 26.23 | 4.9 / 6.2 / 2.3 / 1.3 / 2.4 / 9.3 / 5.2 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.82 / 1.56 / 0.86 / 0.46 / 0.95 / 1.75 | Step 16 % | bark_veil, crucible, shade_veil, spring_burst | 11 / 6 / 2 / 1 | 25 / 50 / 30 · 16 | 1.0 | 0.15 |
| build rules | 3v3 · 2 · 40 | 21 / 17 / 2 / 0 | 12.6 | 25 % | 5 / 5 / 0 / 5 / 8 / 0 / 75 | 17 / 18 / 4 / 10 / 21 / 0 / 28 | 18 / 25 / 2 / 7 / 19 / 0 / 28 | 7.62 | 2.65 / 2.75 / 2.23 | 0.85 / 0.09 | 26.52 | 2.5 / 5.2 / 2.5 / 9.9 / 2.1 / 9.2 / 4.0 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.41 / 1.31 / 0.89 / 3.50 / 0.86 / 1.70 | bark_veil 15 % | none | 21 / 6 / 1 / 2 | 5 / 75 / 75 · 21 | 1.1 | 0.15 |
| noshield | 3v3 · 2 · 40 | 21 / 17 / 2 / 0 | 11.9 | 33 % | 10 / 3 / 3 / 5 / 10 / 0 / 68 | 18 / 20 / 4 / 9 / 19 / 0 / 27 | 16 / 28 / 2 / 6 / 18 / 0 / 28 | 7.28 | 2.70 / 2.60 / 1.98 | 0.98 / 0.09 | 25.80 | 2.2 / 5.0 / 2.2 / 1.5 / 2.1 / 9.8 / 3.9 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.37 / 1.27 / 0.82 / 0.54 / 0.85 / 1.82 | Step 15 % | bark_veil, shade_veil | 19 / 6 / 1 / 1 | 8 / 68 / 68 · 21 | 1.1 | 0.15 |
| jab=1 | 3v3 · 2 · 40 | 19 / 16 / 5 / 0 | 10.5 | 43 % | 15 / 13 / 3 / 0 / 13 / 0 / 58 | 20 / 17 / 4 / 6 / 24 / 0 / 28 | 24 / 24 / 2 / 5 / 18 / 0 / 25 | 7.62 | 2.45 / 2.92 / 2.25 | 0.80 / 0.06 | 25.27 | 3.2 / 4.6 / 3.0 / 8.8 / 2.2 / 8.4 / 3.7 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.53 / 1.16 / 1.10 / 3.10 / 0.90 / 1.56 | bark_veil 13 % | none | 15 / 3 / 1 / 4 | 18 / 58 / 58 · 22 | 1.1 | 0.17 |
| softpressure=1 | 3v3 · 2 · 40 | 15 / 24 / 1 / 0 | 8.8 | 25 % | 20 / 25 / 5 / 15 / 28 / 0 / 0 | 20 / 27 / 8 / 15 / 27 / 0 / 0 | 24 / 31 / 6 / 13 / 23 / 0 / 0 | 9.45 | 3.50 / 3.25 / 2.70 | 0.90 / 0.12 | 25.65 | 3.2 / 6.2 / 3.2 / 7.2 / 2.5 / 9.7 / 5.0 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.54 / 1.58 / 1.17 / 2.56 / 1.00 / 1.79 | Step 13 % | none | 22 / 4 / 1 / 1 | 5 / 75 / 30 · 13 | 1.1 | 0.15 |
| softpressure=2 | 3v3 · 2 · 40 | 15 / 24 / 1 / 0 | 9.2 | 25 % | 15 / 20 / 13 / 23 / 23 / 0 / 0 | 19 / 24 / 8 / 20 / 26 / 0 / 0 | 23 / 30 / 7 / 15 / 23 / 0 / 0 | 9.62 | 3.50 / 3.52 / 2.60 | 0.87 / 0.11 | 25.48 | 3.2 / 6.5 / 3.1 / 7.6 / 2.5 / 9.7 / 5.0 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.53 / 1.64 / 1.15 / 2.69 / 1.03 / 1.80 | Step 13 % | none | 22 / 4 / 1 / 1 | 5 / 75 / 53 · 14 | 1.1 | 0.15 |
| noshield,jab=1 | 3v3 · 2 · 40 | 20 / 16 / 4 / 0 | 10.8 | 40 % | 10 / 3 / 3 / 13 / 13 / 0 / 60 | 19 / 16 / 3 / 12 / 21 / 0 / 27 | 24 / 25 / 2 / 6 / 18 / 0 / 24 | 7.40 | 2.30 / 2.98 / 2.12 | 0.84 / 0.09 | 26.00 | 3.2 / 4.6 / 2.8 / 1.4 / 2.1 / 9.2 / 3.8 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.53 / 1.17 / 1.01 / 0.49 / 0.84 / 1.70 | Step 14 % | bark_veil, shade_veil | 14 / 4 / 2 / 4 | 15 / 63 / 60 · 21 | 1.0 | 0.25 |
| noshield,jab=1,softpressure=2 | 3v3 · 2 · 40 | 20 / 20 / 0 / 0 | 7.8 | 43 % | 33 / 15 / 13 / 20 / 20 / 0 / 0 | 26 / 21 / 7 / 16 / 27 / 0 / 0 | 31 / 30 / 5 / 12 / 21 / 0 / 0 | 8.95 | 2.92 / 3.52 / 2.50 | 0.83 / 0.13 | 24.85 | 4.0 / 5.7 / 3.2 / 1.4 / 2.2 / 10.0 / 4.5 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.66 / 1.44 / 1.18 / 0.50 / 0.89 / 1.86 | Step 15 % | bark_veil, shade_veil | 15 / 5 / 3 / 0 | 15 / 63 / 40 · 12 | 1.0 | 0.25 |
| noshield,jab=1,softpressure=1 | 3v3 · 2 · 40 | 17 / 23 / 0 / 0 | 7.4 | 43 % | 30 / 15 / 13 / 20 / 23 / 0 / 0 | 27 / 20 / 8 / 16 / 28 / 0 / 0 | 32 / 29 / 5 / 11 / 22 / 0 / 0 | 8.65 | 2.90 / 3.25 / 2.50 | 0.85 / 0.14 | 25.07 | 4.0 / 5.5 / 3.2 / 1.4 / 2.0 / 9.8 / 4.4 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.67 / 1.39 / 1.15 / 0.50 / 0.83 / 1.81 | Step 14 % | bark_veil, shade_veil | 18 / 2 / 3 / 0 | 15 / 63 / 23 · 13 | 1.0 | 0.25 |
| aggro | 3v3 · 2 · 40 | 14 / 24 / 2 / 0 | 9.0 | 55 % | 20 / 20 / 0 / 8 / 5 / 0 / 45 | 23 / 30 / 2 / 6 / 21 / 0 / 16 | 22 / 31 / 2 / 7 / 20 / 0 / 17 | 8.40 | 3.00 / 3.33 / 2.08 | 0.89 / 0.09 | 25.35 | 2.9 / 5.4 / 3.0 / 6.0 / 2.6 / 9.6 / 3.9 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.49 / 1.37 / 1.08 / 2.13 / 1.06 / 1.77 | bark_veil 12 % | none | 12 / 3 / 2 / 1 | 18 / 45 / 45 · 21 | 1.1 | 0.12 |
| aggro,noshield,jab=1,softpressure=2 | 3v3 · 2 · 40 | 17 / 22 / 1 / 0 | 7.3 | 45 % | 35 / 13 / 10 / 18 / 20 / 0 / 0 | 37 / 21 / 5 / 11 / 24 / 0 / 0 | 37 / 26 / 5 / 11 / 20 / 0 / 0 | 8.25 | 2.58 / 3.17 / 2.50 | 0.79 / 0.15 | 25.18 | 4.8 / 5.8 / 2.5 / 1.1 / 1.6 / 10.2 / 4.7 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.80 / 1.47 / 0.89 / 0.37 / 0.66 / 1.89 | strike_jab 16 % | bark_veil, shade_veil | 13 / 4 / 2 / 1 | 15 / 58 / 23 · 13 | 1.0 | 0.28 |

Planning bot (`--bot-a plan --bot-b plan`, 20 battles):

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used | Reached pressure: HP leader won / lost / HP level / no winner | Rounds under 3 / over 7 / over 10 (%) · longest | First defeat in round (mean) | Defeated before own first turn (per battle) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| build rules | 3v3 · 1 · 20 | 11 / 9 / 0 / 0 | 9.9 | 40 % | 25 / 15 / 5 / 5 / 0 / 10 / 40 | 19 / 21 / 5 / 8 / 25 / 2 / 17 | 20 / 29 / 5 / 7 / 22 / 2 / 11 | 11.40 | 3.75 / 5.25 / 2.40 | 0.75 / 0.04 | 25.95 | 3.1 / 6.5 / 5.0 / 8.8 / 5.1 / 8.1 / 6.3 | 6.0 / 3.8 / 2.8 / 2.8 / 2.7 / 5.2 / 0.8 | 0.53 / 1.70 / 1.80 / 3.18 / 1.89 / 1.53 | Step 15 % | none | 11 / 1 / 0 / 0 | 15 / 60 / 60 · 20 | 1.1 | 0.15 |
| noshield,jab=1,softpressure=2 | 3v3 · 1 · 20 | 12 / 8 / 0 / 0 | 6.0 | 65 % | 30 / 10 / 25 / 15 / 15 / 0 / 0 | 27 / 23 / 11 / 10 / 24 / 0 / 0 | 35 / 27 / 7 / 8 / 23 / 0 / 0 | 10.60 | 2.95 / 4.50 / 3.15 | 0.71 / 0.11 | 25.70 | 5.5 / 6.0 / 4.5 / 2.1 / 4.5 / 9.3 / 5.5 | 6.0 / 3.8 / 2.8 / 2.8 / 2.7 / 5.2 / 0.8 | 0.93 / 1.59 / 1.65 / 0.76 / 1.69 / 1.77 | strike_jab 15 % | bark_veil, shade_veil | 7 / 0 / 0 / 0 | 20 / 40 / 15 · 12 | 1.1 | 0.10 |

Pressure out of reach (`AiBrain`, 20 battles):

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used | Reached pressure: HP leader won / lost / HP level / no winner | Rounds under 3 / over 7 / over 10 (%) · longest | First defeat in round (mean) | Defeated before own first turn (per battle) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| pressure +200 | 3v3 · 1 · 20 | 7 / 4 / 0 / 9 | 114.5 | 35 % | 9 / 18 / 9 / 0 / 27 / 0 / 36 | 18 / 37 / 3 / 5 / 25 / 0 / 5 | 22 / 34 / 2 / 7 / 26 / 0 / 6 | 14.05 | 7.65 / 4.40 / 2.00 | 0.49 / 0.05 | 20.95 | 2.4 / 10.6 / 3.5 / 84.5 / 4.2 / 9.7 / 4.5 | 6.0 / 3.8 / 2.8 / 2.8 / 2.7 / 5.2 / 0.8 | 0.40 / 2.78 / 1.27 / 30.73 / 1.54 / 1.85 | bark_veil 38 % | crucible | 4 / 0 / 0 / 0 | 10 / 75 / 70 · 219 | 1.1 | 0.00 |
| aggro + pressure +200 | 3v3 · 1 · 20 | 8 / 8 / 0 / 4 | 106.1 | 50 % | 25 / 19 / 0 / 6 / 13 / 0 / 38 | 30 / 30 / 4 / 10 / 19 / 0 / 7 | 24 / 37 / 2 / 10 / 19 / 0 / 8 | 8.30 | 2.90 / 3.20 / 2.20 | 0.95 / 0.11 | 23.10 | 3.0 / 5.9 / 2.4 / 53.5 / 2.2 / 9.2 / 5.0 | 6.0 / 3.8 / 2.8 / 2.8 / 2.7 / 5.2 / 0.8 | 0.49 / 1.55 / 0.87 / 19.45 / 0.81 / 1.75 | bark_veil 64 % | crucible, spring_burst | 6 / 0 / 0 / 0 | 10 / 50 / 50 · 219 | 1.0 | 0.15 |

### Part B · attacking against waiting bots (build rules unless the row names a variant)

`hunt` on both sides:

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used | Reached pressure: HP leader won / lost / HP level / no winner | Rounds under 3 / over 7 / over 10 (%) · longest | First defeat in round (mean) | Defeated before own first turn (per battle) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| build rules | 3v3 · 1 · 40 | 20 / 20 / 0 / 0 | 8.3 | 58 % | 20 / 15 / 0 / 30 / 15 / 8 / 8 | 24 / 29 / 3 / 17 / 17 / 2 / 3 | 25 / 32 / 2 / 14 / 20 / 3 / 3 | 11.82 | 3.38 / 5.17 / 3.27 | 0.67 / 0.07 | 26.10 | 3.5 / 8.1 / 3.8 / 7.1 / 2.8 / 16.6 / 12.6 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.58 / 2.02 / 1.42 / 2.54 / 1.09 / 3.12 | Step 23 % | none | 15 / 1 / 1 / 0 | 15 / 43 / 35 · 20 | 1.1 | 0.03 |
| build rules | 3v3 · 2 · 40 | 18 / 21 / 1 / 0 | 8.5 | 60 % | 20 / 25 / 3 / 15 / 13 / 15 / 8 | 25 / 25 / 6 / 14 / 21 / 3 / 3 | 24 / 32 / 3 / 13 / 20 / 3 / 2 | 11.50 | 3.42 / 4.67 / 3.40 | 0.71 / 0.08 | 25.57 | 3.2 / 7.5 / 4.0 / 7.7 / 3.0 / 16.4 / 12.9 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.54 / 1.89 / 1.47 / 2.71 / 1.21 / 3.04 | Step 24 % | none | 12 / 2 / 1 / 1 | 13 / 40 / 33 · 22 | 1.1 | 0.15 |
| aggro | 3v3 · 1 · 40 | 22 / 18 / 0 / 0 | 5.1 | 85 % | 30 / 25 / 3 / 33 / 10 / 0 / 0 | 30 / 29 / 3 / 19 / 18 / 0 / 0 | 27 / 35 / 2 / 15 / 20 / 0 / 0 | 9.97 | 3.25 / 4.10 / 2.62 | 0.85 / 0.10 | 26.12 | 3.7 / 7.4 / 2.6 / 2.9 / 2.2 / 12.8 / 8.5 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.62 / 1.85 / 0.97 / 1.02 / 0.86 / 2.42 | Step 21 % | none | 3 / 3 / 0 / 0 | 15 / 15 / 10 · 18 | 1.0 | 0.07 |
| aggro | 3v3 · 2 · 40 | 16 / 24 / 0 / 0 | 6.0 | 73 % | 38 / 23 / 0 / 25 / 8 / 3 / 3 | 30 / 27 / 4 / 15 / 21 / 1 / 1 | 29 / 30 / 3 / 13 / 22 / 1 / 0 | 9.90 | 2.98 / 3.95 / 2.98 | 0.74 / 0.09 | 24.95 | 3.8 / 6.3 / 3.6 / 3.0 / 2.6 / 14.8 / 9.8 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.64 / 1.59 / 1.31 / 1.08 / 1.05 / 2.74 | Step 22 % | none | 7 / 3 / 1 / 0 | 18 / 30 / 13 · 18 | 1.1 | 0.12 |
| aggro | 3v3 · 3 · 40 | 16 / 22 / 2 / 0 | 5.1 | 85 % | 28 / 8 / 3 / 35 / 18 / 5 / 3 | 28 / 21 / 3 / 17 / 27 / 1 / 1 | 27 / 34 / 2 / 12 / 22 / 0 / 0 | 8.88 | 2.95 / 3.52 / 2.40 | 0.89 / 0.11 | 24.70 | 3.4 / 6.7 / 2.2 / 3.1 / 2.2 / 12.9 / 8.1 | 6.0 / 4.2 / 2.4 / 2.9 / 2.5 / 5.5 / 0.5 | 0.56 / 1.57 / 0.95 / 1.08 / 0.86 / 2.36 | Step 21 % | crucible | 6 / 0 / 0 / 0 | 25 / 23 / 13 · 16 | 1.0 | 0.20 |
| pressure +200 | 3v3 · 1 · 40 | 18 / 19 / 0 / 3 | 37.1 | 85 % | 22 / 19 / 3 / 38 / 16 / 0 / 0 | 25 / 31 / 3 / 19 / 17 / 0 / 0 | 25 / 33 / 2 / 16 / 20 / 1 / 0 | 15.10 | 3.45 / 8.40 / 3.25 | 0.52 / 0.06 | 25.10 | 3.4 / 8.0 / 7.2 / 24.2 / 6.2 / 21.0 / 16.9 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.57 / 1.99 / 2.70 / 8.65 / 2.41 / 3.97 | bark_veil 24 % | none | 1 / 1 / 1 / 0 | 15 / 43 / 35 · 215 | 1.1 | 0.03 |
| aggro + pressure +200 | 3v3 · 1 · 40 | 22 / 18 / 0 / 0 | 5.2 | 100 % | 25 / 28 / 3 / 35 / 10 / 0 / 0 | 29 / 30 / 3 / 19 / 18 / 0 / 0 | 26 / 35 / 2 / 15 / 20 / 0 / 0 | 9.93 | 3.27 / 4.08 / 2.58 | 0.86 / 0.10 | 26.07 | 3.6 / 7.3 / 2.6 / 3.0 / 2.2 / 12.8 / 8.4 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.61 / 1.84 / 0.97 / 1.05 / 0.86 / 2.42 | Step 21 % | none | 0 / 0 / 0 / 0 | 15 / 15 / 10 · 20 | 1.0 | 0.07 |
| aggro + pressure +200 | 3v3 · 2 · 40 | 16 / 23 / 0 / 1 | 20.4 | 93 % | 38 / 23 / 0 / 26 / 8 / 3 / 0 | 30 / 27 / 5 / 15 / 21 / 1 / 0 | 29 / 30 / 3 / 13 / 22 / 0 / 0 | 9.82 | 2.95 / 3.95 / 2.92 | 0.75 / 0.09 | 24.90 | 3.8 / 6.2 / 3.6 / 6.4 / 2.6 / 30.9 / 25.2 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.64 / 1.58 / 1.30 / 2.26 / 1.04 / 5.72 | Step 32 % | none | 1 / 0 / 1 / 0 | 18 / 30 / 13 · 214 | 1.1 | 0.12 |

`rush` on both sides:

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used | Reached pressure: HP leader won / lost / HP level / no winner | Rounds under 3 / over 7 / over 10 (%) · longest | First defeat in round (mean) | Defeated before own first turn (per battle) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| build rules | 3v3 · 1 · 40 | 24 / 16 / 0 / 0 | 4.0 | 98 % | 25 / 35 / 0 / 28 / 10 / 0 / 0 | 18 / 29 / 0 / 27 / 21 / 0 / 0 | 18 / 35 / 0 / 23 / 20 / 0 / 1 | 5.08 | 3.40 / 1.00 / 0.68 | 1.50 / 0.25 | 25.40 | 2.3 / 5.1 / 0.0 / 10.9 / 4.9 / 5.6 / 3.9 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.39 / 1.27 / 0.00 / 3.90 / 1.93 / 1.06 | Step 12 % | ambush_rift, bramble_tide, crucible, spring_burst | 1 / 0 / 0 / 0 | 5 / 3 / 3 · 15 | 1.4 | 0.00 |
| build rules | 3v3 · 2 · 40 | 23 / 17 / 0 / 0 | 3.4 | 100 % | 18 / 28 / 0 / 40 / 15 / 0 / 0 | 14 / 29 / 0 / 31 / 22 / 0 / 0 | 16 / 38 / 0 / 23 / 20 / 0 / 0 | 4.72 | 3.15 / 0.90 / 0.68 | 1.60 / 0.33 | 24.25 | 2.0 / 4.7 / 0.0 / 10.0 / 5.0 / 4.8 / 3.4 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.33 / 1.20 / 0.00 / 3.53 / 2.04 / 0.88 | Step 11 % | ambush_rift, bramble_tide, crucible, spring_burst | 0 / 0 / 0 / 0 | 13 / 0 / 0 · 6 | 1.4 | 0.00 |
| pressure +200 | 3v3 · 1 · 40 | 24 / 16 / 0 / 0 | 4.0 | 100 % | 25 / 35 / 0 / 28 / 10 / 0 / 0 | 18 / 29 / 0 / 27 / 21 / 0 / 0 | 19 / 35 / 0 / 23 / 21 / 0 / 0 | 5.10 | 3.40 / 1.00 / 0.70 | 1.50 / 0.25 | 25.45 | 2.4 / 5.1 / 0.0 / 10.9 / 4.9 / 5.6 / 3.9 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.40 / 1.27 / 0.00 / 3.90 / 1.93 / 1.06 | Step 12 % | ambush_rift, bramble_tide, crucible, spring_burst | 0 / 0 / 0 / 0 | 5 / 3 / 3 · 16 | 1.4 | 0.00 |

`hunt` (side 0) against `AiBrain` (side 1):

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used | Reached pressure: HP leader won / lost / HP level / no winner | Rounds under 3 / over 7 / over 10 (%) · longest | First defeat in round (mean) | Defeated before own first turn (per battle) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| build rules | 3v3 · 1 · 40 | 19 / 20 / 1 / 0 | 8.9 | 50 % | 23 / 13 / 3 / 13 / 13 / 8 / 28 | 24 / 28 / 4 / 10 / 19 / 3 / 7 | 24 / 32 / 3 / 10 / 21 / 3 / 5 | 10.00 | 3.42 / 4.15 / 2.42 | 0.81 / 0.08 | 25.50 | 3.2 / 6.8 / 3.2 / 8.8 / 2.8 / 12.1 / 8.7 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.54 / 1.69 / 1.23 / 3.13 / 1.11 / 2.27 | Step 19 % | none | 13 / 3 / 3 / 1 | 13 / 50 / 45 · 18 | 1.1 | 0.03 |
| build rules | 3v3 · 2 · 40 | 16 / 24 / 0 / 0 | 9.7 | 53 % | 25 / 13 / 0 / 23 / 8 / 13 / 18 | 24 / 23 / 6 / 14 / 19 / 3 / 8 | 23 / 29 / 3 / 12 / 20 / 4 / 8 | 9.40 | 2.90 / 3.90 / 2.60 | 0.76 / 0.10 | 24.95 | 3.0 / 6.5 / 2.9 / 7.5 / 2.5 / 13.5 / 10.2 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.51 / 1.64 / 1.06 / 2.67 / 0.99 / 2.50 | Step 22 % | none | 14 / 5 / 0 / 0 | 8 / 53 / 48 · 19 | 1.1 | 0.17 |
| aggro | 3v3 · 1 · 40 | 20 / 19 / 1 / 0 | 5.7 | 83 % | 28 / 15 / 5 / 33 / 13 / 3 / 3 | 30 / 25 / 3 / 18 / 20 / 1 / 1 | 27 / 34 / 2 / 12 / 21 / 1 / 1 | 9.60 | 3.15 / 4.05 / 2.40 | 0.87 / 0.08 | 25.45 | 3.6 / 7.2 / 2.4 / 3.2 / 2.1 / 11.7 / 7.5 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.60 / 1.81 / 0.89 / 1.14 / 0.83 / 2.21 | Step 20 % | none | 5 / 0 / 1 / 1 | 13 / 20 / 13 · 15 | 1.0 | 0.07 |

`AiBrain` (side 0) against `hunt` (side 1):

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used | Reached pressure: HP leader won / lost / HP level / no winner | Rounds under 3 / over 7 / over 10 (%) · longest | First defeat in round (mean) | Defeated before own first turn (per battle) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| build rules | 3v3 · 1 · 40 | 22 / 18 / 0 / 0 | 10.1 | 48 % | 23 / 10 / 0 / 23 / 18 / 10 / 15 | 22 / 28 / 4 / 11 / 18 / 3 / 7 | 22 / 32 / 2 / 12 / 19 / 3 / 7 | 11.57 | 4.08 / 4.47 / 3.02 | 0.70 / 0.09 | 26.35 | 3.1 / 7.7 / 3.9 / 9.3 / 3.3 / 15.5 / 11.9 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.52 / 1.91 / 1.48 / 3.33 / 1.30 / 2.92 | Step 22 % | none | 16 / 0 / 5 / 0 | 15 / 55 / 48 · 20 | 1.1 | 0.03 |
| build rules | 3v3 · 2 · 40 | 23 / 17 / 0 / 0 | 8.4 | 55 % | 15 / 20 / 0 / 35 / 5 / 10 / 13 | 24 / 23 / 3 / 21 / 20 / 3 / 5 | 22 / 32 / 2 / 14 / 21 / 3 / 4 | 9.95 | 3.05 / 3.80 / 3.10 | 0.75 / 0.08 | 24.20 | 2.8 / 6.8 / 3.1 / 7.3 / 2.2 / 13.9 / 10.2 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.46 / 1.73 / 1.13 / 2.58 / 0.91 / 2.57 | Step 22 % | none | 15 / 1 / 1 / 0 | 13 / 50 / 38 · 21 | 1.1 | 0.15 |
| aggro | 3v3 · 1 · 40 | 26 / 13 / 1 / 0 | 6.9 | 75 % | 33 / 15 / 3 / 25 / 10 / 0 / 15 | 31 / 27 / 4 / 16 / 16 / 0 / 4 | 28 / 32 / 2 / 12 / 20 / 1 / 3 | 9.82 | 3.05 / 4.03 / 2.75 | 0.79 / 0.12 | 26.25 | 3.8 / 7.2 / 2.6 / 3.6 / 2.2 / 13.0 / 9.1 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.64 / 1.80 / 0.99 / 1.29 / 0.85 / 2.46 | Step 22 % | spring_burst | 8 / 1 / 0 / 1 | 15 / 28 / 20 · 21 | 1.0 | 0.07 |

`rush` (side 0) against `AiBrain` (side 1), then the seats swapped:

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used | Reached pressure: HP leader won / lost / HP level / no winner | Rounds under 3 / over 7 / over 10 (%) · longest | First defeat in round (mean) | Defeated before own first turn (per battle) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| build rules | 3v3 · 1 · 40 | 6 / 34 / 0 / 0 | 4.6 | 95 % | 20 / 18 / 3 / 40 / 10 / 3 / 3 | 18 / 27 / 2 / 28 / 19 / 1 / 2 | 17 / 36 / 2 / 22 / 18 / 1 / 2 | 10.32 | 3.73 / 4.47 / 2.12 | 0.77 / 0.07 | 22.85 | 2.1 / 5.9 / 4.5 / 7.8 / 5.7 / 6.4 / 4.6 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.35 / 1.47 / 1.68 / 2.79 / 2.23 / 1.21 | Step 12 % | crucible | 1 / 0 / 1 / 0 | 13 / 8 / 5 · 16 | 1.2 | 0.03 |
| build rules | 3v3 · 1 · 40 | 35 / 5 / 0 / 0 | 4.3 | 95 % | 20 / 33 / 5 / 28 / 13 / 0 / 3 | 15 / 33 / 3 / 24 / 21 / 0 / 1 | 15 / 39 / 2 / 19 / 22 / 0 / 1 | 7.05 | 3.58 / 2.38 / 1.10 | 1.18 / 0.17 | 23.23 | 1.9 / 5.5 / 1.5 / 7.4 / 3.7 / 6.2 / 4.5 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.32 / 1.39 / 0.57 / 2.65 / 1.45 / 1.17 | Step 15 % | crucible | 1 / 0 / 1 / 0 | 18 / 10 / 3 · 14 | 1.1 | 0.05 |

`hunt` (side 0) against `rush` (side 1), then the seats swapped (both with `aggro`):

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used | Reached pressure: HP leader won / lost / HP level / no winner | Rounds under 3 / over 7 / over 10 (%) · longest | First defeat in round (mean) | Defeated before own first turn (per battle) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| aggro | 3v3 · 1 · 40 | 36 / 4 / 0 / 0 | 3.2 | 100 % | 18 / 43 / 5 / 25 / 10 / 0 / 0 | 18 / 34 / 3 / 22 / 18 / 0 / 0 | 21 / 38 / 3 / 16 / 20 / 0 / 0 | 6.58 | 3.38 / 1.90 / 1.30 | 1.25 / 0.23 | 23.82 | 2.8 / 5.2 / 1.4 / 5.6 / 3.9 / 7.1 / 4.8 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.46 / 1.29 / 0.54 / 2.00 / 1.52 / 1.34 | Step 16 % | none | 0 / 0 / 0 / 0 | 25 / 0 / 0 · 5 | 1.1 | 0.12 |
| aggro | 3v3 · 1 · 40 | 6 / 34 / 0 / 0 | 4.2 | 95 % | 30 / 28 / 3 / 30 / 8 / 0 / 0 | 24 / 26 / 3 / 24 / 20 / 0 / 0 | 21 / 34 / 2 / 19 / 21 / 0 / 0 | 8.60 | 3.60 / 3.20 / 1.80 | 0.91 / 0.14 | 24.55 | 2.9 / 5.8 / 2.8 / 6.1 / 4.3 / 8.1 / 5.3 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.47 / 1.44 / 1.07 / 2.17 / 1.70 / 1.52 | Step 15 % | crucible | 0 / 1 / 1 / 0 | 18 / 8 / 5 · 12 | 1.1 | 0.12 |

**Observations** (indications; bots only; 40 battles per row, about ±8 points):

- *The partial result of the interrupted series is reproduced:* build rules end by collapse in 68 % / 75 % of battles after 11.9 / 12.6 rounds; `noshield` 53 % / 68 %; `jab=1` 73 % / 58 %; pressure without damage 8.6–9.2 rounds; the full combination 7.2–7.8 rounds (7.0–7.3 aggressive, 6.0 planning bot). With pressure out of reach 9 of 20 battles reach the turn limit (4 of 20 aggressive).
- *The length has two peaks.* In every variant the first monster falls in round 1 (mean 1.0–1.1; the victims are the 2–4 HP monsters with high initiative that fly in first), 5–20 % of battles are over before round 3, and 55–75 % last longer than 10 rounds: after the early losses the remaining monsters (7–8 HP, Movement 1–2) stand between hazard ground and markers and wait. The mean of 11–12 rounds describes neither group.
- *A bot that walks up to the enemy shortens the battles without any rule change:* `hunt` on both sides 8.3 / 8.5 rounds with 8 % collapse endings; with `aggro` 5.1–6.0 rounds, 73–85 % ended before pressure, 0–3 % collapse endings, and with pressure out of reach 79 of 80 battles still end (one timeout). `rush` on both sides: 3.4–4.0 rounds.
- *But walking up loses.* Against the waiting `AiBrain` the `hunt` bot wins 70 of 160 battles (44 %; 33 of 78 with `aggro`), and `rush` wins 11 of 80 (14 %). `hunt` in turn beats `rush` 70 to 10. Under the build rules the side that waits and reacts is ahead, so the standstill is not only a weakness of the bot.
- *Skill kinds (per fielded slot and battle, `AiBrain`):* zone 3.5–4.1, Surge 1.3–1.4, movement 1.5–1.7, trap 0.9–1.2, board 0.9–1.3, Strike 0.41; with `hunt` + `aggro` zone 1.0–1.1, Surge 1.6–1.9, movement 2.4–2.7, Strike 0.56–0.64. `rush` never sets a trap.
- *Limits:* `hunt` and `rush` are as crude as `AiBrain`; the 44 % say that this way of attacking loses to this way of waiting, not that every attack does.

**Follow-up:** T13 (length distribution and the attacker's share as metrics; a better opponent AI), T38 (what makes waiting pay: measured in S011), T02 (prices stay ignored by user decision).

## S009 · 2026-11-12 · five rule changes as build rules, rotation, Strike damage, prop skills, skill-kind usage

**State:** `9c1f1ed` dirty (uncommitted) · content `2026-11-12.2`. **Build rules since S008** (user decisions 2026-11-12): Step 1 AP, slotted movement skills 1 AP, shield / mend zone skills 2 AP, push and pull zones also move at cast, every Strike pushes each struck monster 1 square away, placed shapes may be rotated by everyone. Part A: 760 battles in 17 runs on the S008 kits with those rules (fingerprint not recorded). Part B: 380 battles in 8 runs plus two full-block runs on kit set `736eb4e604a6` (Set Gong, Plant Bamboo, Vortex Urn, Storm Drum added; Slam destroys the Mountain where the target was struck).

**Questions (user):** do Strikes need their damage; does rotation help; how do the new prop skills and props behave; which skill kinds are used in a battle compared with how many of each kind the kits hold (battle goals: short, tactical, no single-skill spam, every skill useful).

| Variant | What changes |
|---|---|
| build rules | as above |
| `norotate` | placed shapes cannot be rotated (the earlier rule) |
| `step=2,move=2` | Step and movement skills at the earlier 2 AP |
| `strikedmg=N` | Strike damage N instead of 2 (the push stays) |
| `aggro` | bot change, not a rule: the AI values closing in more and its own support effects less |
| `pressure +200` | late-round pressure out of reach (200 rounds later) |

Command per row: `sim.gd -- <battles> <mode> <seed> "9c1f1ed dirty" --paired --compact [--variant …] [--pressure 200]`, `AiBrain` on both sides; the two 3v3 rows with 20 battles use `--bot-a plan --bot-b plan`. Rows are pasted unchanged from the tool.

### Part A · rules on the S008 kits

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg |
|---|---|---|---|---|---|---|---|---|---|---|---|
| build rules | 3v3 · 1 · 40 | 22 / 16 / 2 / 0 | 12.3 | 25 % | 8 / 8 / 0 / 5 / 8 / 3 / 70 | 14 / 20 / 1 / 12 / 18 / 1 / 30 | 18 / 26 / 1 / 9 / 17 / 0 / 29 | 8.78 | 3.05 / 3.12 / 2.60 | 0.72 / 0.07 | 25.75 |
| build rules | 3v3 · 2 · 40 | 18 / 20 / 2 / 0 | 12.0 | 35 % | 8 / 10 / 0 / 15 / 3 / 0 / 65 | 14 / 22 / 2 / 13 / 18 / 0 / 30 | 12 / 27 / 2 / 8 / 18 / 0 / 32 | 8.12 | 2.98 / 2.45 / 2.70 | 0.87 / 0.05 | 25.82 |
| aggro | 3v3 · 1 · 40 | 20 / 16 / 4 / 0 | 9.4 | 53 % | 15 / 18 / 0 / 8 / 15 / 0 / 45 | 20 / 25 / 2 / 11 / 19 / 0 / 19 | 22 / 29 / 1 / 7 / 19 / 0 / 20 | 8.05 | 2.75 / 3.35 / 1.95 | 0.86 / 0.09 | 25.12 |
| aggro | 3v3 · 2 · 40 | 16 / 23 / 1 / 0 | 10.5 | 43 % | 5 / 5 / 3 / 18 / 10 / 3 / 55 | 19 / 18 / 4 / 14 / 20 / 1 / 21 | 18 / 27 / 3 / 7 / 17 / 0 / 25 | 7.75 | 2.83 / 3.10 / 1.82 | 0.95 / 0.05 | 25.38 |
| norotate | 3v3 · 1 · 40 | 19 / 21 / 0 / 0 | 13.3 | 23 % | 13 / 5 / 0 / 0 / 5 / 0 / 78 | 19 / 13 / 2 / 10 / 22 / 0 / 34 | 17 / 19 / 1 / 7 / 18 / 0 / 37 | 7.35 | 2.30 / 2.73 / 2.33 | 0.66 / 0.06 | 25.98 |
| step=2,move=2 | 3v3 · 1 · 40 | 21 / 15 / 4 / 0 | 12.1 | 33 % | 0 / 20 / 3 / 10 / 3 / 3 / 63 | 9 / 25 / 3 / 17 / 9 / 1 / 34 | 7 / 35 / 2 / 12 / 14 / 0 / 29 | 9.22 | 3.95 / 2.42 / 2.85 | 0.98 / 0.05 | 25.60 |
| strikedmg=1 | 3v3 · 1 · 40 | 24 / 13 / 3 / 0 | 13.6 | 20 % | 5 / 5 / 0 / 5 / 5 / 0 / 78 | 8 / 18 / 1 / 16 / 21 / 0 / 31 | 9 / 27 / 2 / 10 / 20 / 0 / 31 | 8.88 | 3.20 / 3.10 / 2.58 | 0.76 / 0.08 | 25.88 |
| strikedmg=0 | 3v3 · 1 · 40 | 24 / 13 / 3 / 0 | 12.8 | 25 % | 0 / 5 / 0 / 8 / 18 / 0 / 70 | 0 / 24 / 2 / 16 / 26 / 0 / 29 | 0 / 33 / 2 / 12 / 22 / 0 / 28 | 11.25 | 4.08 / 3.60 / 3.58 | 0.73 / 0.08 | 25.80 |
| aggro,strikedmg=1 | 3v3 · 1 · 40 | 23 / 16 / 1 / 0 | 9.7 | 50 % | 5 / 23 / 0 / 5 / 13 / 0 / 50 | 7 / 29 / 0 / 13 / 26 / 0 / 20 | 11 / 33 / 1 / 9 / 23 / 0 / 21 | 8.32 | 2.90 / 3.45 / 1.98 | 0.90 / 0.09 | 23.93 |
| aggro,strikedmg=0 | 3v3 · 1 · 40 | 20 / 18 / 2 / 0 | 11.1 | 43 % | 0 / 18 / 0 / 13 / 13 / 3 / 55 | 0 / 31 / 3 / 16 / 22 / 1 / 22 | 0 / 39 / 3 / 10 / 24 / 1 / 21 | 10.53 | 3.95 / 3.85 / 2.73 | 0.94 / 0.11 | 26.50 |
| build rules | 3v3 · 1 · 20 | 13 / 7 / 0 / 0 | 8.6 | 60 % | 35 / 0 / 0 / 25 / 5 / 0 / 35 | 23 / 18 / 5 / 14 / 24 / 0 / 14 | 22 / 27 / 7 / 9 / 16 / 1 / 16 | 11.10 | 3.60 / 3.70 / 3.80 | 0.69 / 0.09 | 25.35 |
| pressure +200 | 3v3 · 1 · 20 | 6 / 1 / 0 / 13 | 105.6 | 30 % | 29 / 0 / 0 / 43 / 14 / 0 / 14 | 15 / 26 / 3 / 20 / 30 / 0 / 2 | 20 / 37 / 1 / 14 / 23 / 0 / 2 | 9.10 | 3.20 / 3.20 / 2.70 | 0.71 / 0.07 | 18.15 |
| aggro + pressure +200 | 3v3 · 1 · 20 | 9 / 5 / 0 / 6 | 73.8 | 60 % | 0 / 29 / 0 / 21 / 36 / 0 / 14 | 17 / 29 / 4 / 17 / 29 / 0 / 3 | 24 / 35 / 2 / 9 / 24 / 0 / 4 | 9.25 | 2.90 / 4.20 / 2.15 | 0.72 / 0.09 | 20.20 |
| build rules | 2v2 · 1 · 60 | 22 / 38 / 0 / 0 | 7.9 | 53 % | 18 / 10 / 3 / 5 / 18 / 0 / 43 | 26 / 20 / 4 / 6 / 19 / 1 / 23 | 28 / 18 / 2 / 6 / 22 / 1 / 23 | 5.13 | 1.37 / 1.53 / 2.23 | 0.56 / 0.09 | 16.22 |
| aggro | 2v2 · 1 · 60 | 20 / 37 / 3 / 0 | 5.6 | 78 % | 28 / 12 / 7 / 13 / 20 / 0 / 20 | 34 / 18 / 5 / 8 / 19 / 0 / 13 | 34 / 19 / 3 / 6 / 22 / 0 / 14 | 4.43 | 1.25 / 1.77 / 1.42 | 0.62 / 0.14 | 15.60 |
| build rules | 1v1 · 1 · 100 | 40 / 58 / 2 / 0 | 4.8 | 71 % | 26 / 3 / 1 / 4 / 39 / 0 / 27 | 25 / 3 / 1 / 4 / 38 / 0 / 28 | 41 / 3 / 0 / 4 / 24 / 1 / 26 | 1.42 | 0.11 / 0.48 / 0.83 | 0.18 / 0.00 | 6.35 |
| aggro | 1v1 · 1 · 100 | 37 / 62 / 1 / 0 | 2.8 | 91 % | 41 / 9 / 3 / 6 / 32 / 0 / 9 | 41 / 9 / 3 / 6 / 32 / 0 / 10 | 54 / 8 / 1 / 4 / 22 / 0 / 11 | 1.28 | 0.20 / 0.25 / 0.83 | 0.38 / 0.02 | 5.96 |

### Part B · kit set `736eb4e604a6`, with skill-kind usage

The five added columns: activations per battle by skill kind (both sides, Step separately) · kit slots of that kind fielded per battle (both sides) · activations per fielded slot · the most used skill · skills of the fielded kits never used in the run. Slots are counted once per fielded monster, not by how long it lived.

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| build rules | 3v3 · 1 · 40 | 20 / 17 / 3 / 0 | 11.2 | 38 % | 15 / 5 / 0 / 8 / 10 / 0 / 60 | 15 / 21 / 1 / 12 / 20 / 0 / 28 | 14 / 27 / 0 / 9 / 20 / 0 / 27 | 10.38 | 3.30 / 4.28 / 2.80 | 0.60 / 0.05 | 24.70 | 1.8 / 6.6 / 3.8 / 11.3 / 2.1 / 7.9 / 3.9 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.30 / 1.66 / 1.42 / 4.03 / 0.83 / 1.50 | bark_veil 14 % | none |
| build rules | 3v3 · 2 · 40 | 20 / 18 / 2 / 0 | 12.1 | 30 % | 3 / 3 / 0 / 10 / 15 / 0 / 70 | 12 / 22 / 1 / 15 / 17 / 0 / 31 | 15 / 27 / 1 / 7 / 17 / 0 / 30 | 8.85 | 2.65 / 3.73 / 2.48 | 0.74 / 0.08 | 25.43 | 1.9 / 5.0 / 3.8 / 9.6 / 2.3 / 7.7 / 3.7 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.33 / 1.27 / 1.39 / 3.40 / 0.92 / 1.42 | bark_veil 15 % | none |
| aggro | 3v3 · 1 · 40 | 20 / 17 / 3 / 0 | 8.9 | 58 % | 15 / 23 / 3 / 13 / 8 / 0 / 40 | 20 / 26 / 2 / 13 / 20 / 0 / 17 | 19 / 31 / 1 / 8 / 20 / 0 / 18 | 8.62 | 2.83 / 3.75 / 2.05 | 0.81 / 0.12 | 25.02 | 2.7 / 6.0 / 2.6 / 6.6 / 1.8 / 8.3 / 4.2 | 6.0 / 4.0 / 2.6 / 2.8 / 2.5 / 5.3 / 0.7 | 0.45 / 1.51 / 0.97 / 2.37 / 0.69 / 1.57 | Step 13 % | none |
| aggro | 3v3 · 2 · 40 | 17 / 20 / 3 / 0 | 10.0 | 45 % | 15 / 13 / 0 / 8 / 8 / 0 / 55 | 21 / 25 / 3 / 11 / 18 / 0 / 20 | 21 / 30 / 3 / 8 / 17 / 0 / 19 | 8.28 | 2.88 / 3.77 / 1.62 | 0.92 / 0.09 | 25.32 | 2.6 / 5.6 / 2.7 / 5.4 / 2.2 / 9.4 / 4.1 | 6.0 / 4.0 / 2.8 / 2.8 / 2.5 / 5.4 / 0.6 | 0.44 / 1.42 / 0.97 / 1.90 / 0.91 / 1.75 | Step 13 % | none |
| build rules | 3v3 · 1 · 20 | 13 / 7 / 0 / 0 | 8.6 | 60 % | 20 / 0 / 10 / 15 / 15 / 0 / 40 | 21 / 18 / 7 / 9 / 27 / 0 / 14 | 17 / 28 / 7 / 8 / 21 / 0 / 16 | 12.55 | 3.65 / 4.70 / 4.20 | 0.62 / 0.02 | 23.55 | 2.6 / 6.2 / 6.4 / 7.6 / 4.2 / 8.1 / 5.8 | 6.0 / 3.8 / 2.8 / 2.8 / 2.7 / 5.2 / 0.8 | 0.43 / 1.62 / 2.33 / 2.76 / 1.57 / 1.54 | Step 14 % | none |
| build rules | 2v2 · 1 · 60 | 28 / 32 / 0 / 0 | 8.0 | 52 % | 13 / 10 / 2 / 10 / 22 / 5 / 38 | 23 / 17 / 2 / 11 / 25 / 2 / 19 | 27 / 16 / 2 / 7 / 26 / 1 / 20 | 5.62 | 1.17 / 2.77 / 1.68 | 0.44 / 0.06 | 15.78 | 2.2 / 3.3 / 2.3 / 5.9 / 1.8 / 5.6 / 3.4 | 4.0 / 2.7 / 1.6 / 1.8 / 1.9 / 3.6 / 0.4 | 0.55 / 1.24 / 1.40 / 3.20 / 0.96 / 1.57 | Step 14 % | none |
| aggro | 2v2 · 1 · 60 | 22 / 37 / 1 / 0 | 5.8 | 73 % | 33 / 13 / 2 / 13 / 15 / 0 / 23 | 37 / 20 / 2 / 10 / 18 / 0 / 12 | 35 / 20 / 1 / 8 / 23 / 0 / 12 | 4.87 | 1.27 / 2.22 / 1.38 | 0.58 / 0.11 | 15.78 | 2.8 / 3.6 / 1.3 / 2.7 / 0.8 / 6.4 / 3.2 | 4.0 / 2.7 / 1.6 / 1.8 / 1.9 / 3.6 / 0.4 | 0.71 / 1.35 / 0.77 / 1.49 / 0.45 / 1.79 | Step 15 % | none |
| build rules | 1v1 · 1 · 100 | 41 / 56 / 3 / 0 | 4.8 | 70 % | 24 / 6 / 2 / 6 / 36 / 1 / 25 | 23 / 6 / 2 / 6 / 35 / 1 / 27 | 39 / 5 / 1 / 4 / 24 / 1 / 26 | 1.54 | 0.16 / 0.65 / 0.73 | 0.24 / 0.00 | 6.45 | 1.2 / 0.9 / 0.7 / 2.3 / 0.6 / 2.4 / 0.5 | 2.0 / 1.3 / 0.8 / 0.9 / 0.9 / 1.8 / 0.2 | 0.62 / 0.64 / 0.81 / 2.58 / 0.59 / 1.33 | strike_jab 15 % | cinder_dive |

Per skill, 3v3 · seed 1 · 40 battles (full-block runs of the same setup):

- build rules: Skill uses per battle: bark_veil 5.35, Step 3.92, shade_veil 3.88, bramble_tide 2.70, Run 2.15, Glide 1.93, strike_jab 1.77, tidal_shell 1.75, Quake Leap 1.48, Headbutt 1.40, coiling_rift 1.35, eclipse 1.25, gloom_rift 1.23, shockwave 1.18, Burrow 0.97, ambush_rift 0.95, lava_field 0.90, gale 0.88, set_gong 0.80, magma_pounce 0.60, cinder_dive 0.45, thornbed 0.28, plant_bamboo 0.15, crucible 0.05, spring_burst 0.05
- `aggro`: Skill uses per battle: Step 4.20, bark_veil 3.60, strike_jab 2.70, Run 2.40, Glide 2.10, Quake Leap 1.60, bramble_tide 1.50, coiling_rift 1.38, Headbutt 1.27, eclipse 1.25, tidal_shell 1.25, shockwave 1.20, gloom_rift 1.12, shade_veil 1.05, ambush_rift 0.95, Burrow 0.93, lava_field 0.93, gale 0.78, magma_pounce 0.57, cinder_dive 0.47, thornbed 0.38, plant_bamboo 0.23, set_gong 0.23, crucible 0.10, spring_burst 0.03

**Observations** (indications; bots only; one or two seeds per row):

- *Collapse endings with the rules alone:* 65–70 % of 3v3 battles in part A and 60–70 % in part B (S008 build rules: 90–98 %); with the aggressive bot 45–55 % and 40–55 %, with the planning bot 35 % and 40 % (20 battles each). Mean length 11.2–12.3 rounds, 8.9–10.5 with the aggressive bot, 8.6 with the planning bot.
- *Strike damage hardly changes how battles end:* damage 1 gives 78 % collapse endings and damage 0 gives 70 % (build rules 70 % on that seed); with the aggressive bot 50 % and 55 % (45 %). Without Strike damage, Surges and collisions take over its share of the defeats.
- *Rotation:* without it 78 % collapse endings against 70 %, one seed. *Earlier prices* for Step and movement (2 AP) give 63 % on the same seed, so in this build the cheap movement is not what lowers the share.
- *Without late-round pressure* 13 of 20 battles reach the turn limit (6 of 20 with the aggressive bot): these bots still do not finish a 3v3 on their own.
- *Smaller modes:* 2v2 ends by collapse in 43 % / 38 % of battles (20 % / 23 % aggressive), 1v1 in 27 % / 25 % (9 %). Side 1 wins 56–62 % of 1v1 battles.
- *Kinds used against kinds available (part B, 3v3):* a zone slot is used 3.4–4.0 times per battle, a Surge slot 1.3–1.7, a movement slot 1.4–1.5, a trap slot 1.4, a board slot 0.8–0.9 and a Strike slot 0.30–0.33. Every kit carries the Jab (6 of 24 fielded slots), and it is the least used slot. With the aggressive bot zones fall to 1.9–2.4 and Strikes rise to 0.45; in 1v1 Strikes reach 0.62.
- *Single skills:* bark_veil alone is 14–15 % of all activations (5.35 per battle from one kit of nine), shade_veil 3.88. Hardly used: crucible 0.05, spring_burst 0.05, plant_bamboo 0.15, thornbed 0.28; set_gong 0.80 (0.23 aggressive). No fielded skill stays entirely unused in 3v3.
- *Limits:* the one-step bot casts what its evaluation rewards (its own support zones), does not plan a push into a prop, a trap or the edge, and so says little about prop skills and traps in human hands.

**Follow-up:** T13 (battle goals as metrics: length, endings, uses per slot; the unused Strike slot and the two dominant veil zones; human play), T38 (Strike damage and rotation stay as built; prop skills and traps need a planning bot or play), T02 (prices stay ignored by user decision).

## S008 · 2026-11-12 · Step and movement prices, dearer defence, displacement from zones and Strikes

**State:** `9c1f1ed` dirty (uncommitted) · content `2026-11-12.1` · game content as in S007, with the trap now a skill kind of its own (seven Surges, four traps) and the square rule “a Surge replaces a trap square by square, a trap is laid only on free squares”. 1000 battles in 24 runs.

**Questions (user):** try Step and movement skills at different prices; defence a little dearer than attack; much more displacement without a kit slot for it.

| Variant | What changes |
|---|---|
| build rules | Step 2 AP, movement skills 2 AP, shield / mend zones 1 AP, Jab 2 AP |
| `step=N` / `move=N` | AP of the Step / of every slotted movement skill |
| `defap=N` | AP of shield and mend zone skills |
| `jab=1` | the Jab Strike costs 1 AP |
| `zonepush` | a push or pull zone also moves the monsters standing in it at the moment it is cast (and still at their turn end) |
| `allpush` | every Strike pushes each struck monster 1 square away |
| `aggro` | bot change, not a rule: the AI values closing in more and its own support effects less |

Command per row: `sim.gd -- <battles> <mode> <seed> "9c1f1ed dirty" --paired --compact [--variant …]`, `AiBrain` on both sides. Rows are pasted unchanged from the tool.

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg |
|---|---|---|---|---|---|---|---|---|---|---|---|
| build rules | 3v3 · 1 · 40 | 16 / 18 / 6 / 0 | 15.9 | 8 % | 5 / 0 / 0 / 3 / 0 / 3 / 90 | 13 / 14 / 3 / 12 / 7 / 1 / 47 | 12 / 23 / 2 / 8 / 6 / 1 / 47 | 9.95 | 3.58 / 2.67 / 3.70 | 0.64 / 0.04 | 27.10 |
| build rules | 3v3 · 2 · 40 | 25 / 14 / 1 / 0 | 16.0 | 3 % | 0 / 3 / 0 / 0 / 0 / 0 / 98 | 11 / 17 / 5 / 17 / 4 / 1 / 44 | 9 / 26 / 3 / 9 / 5 / 0 / 45 | 9.07 | 3.50 / 2.10 / 3.48 | 0.79 / 0.08 | 27.48 |
| step=1 | 3v3 · 1 · 40 | 17 / 19 / 4 / 0 | 15.1 | 13 % | 8 / 3 / 3 / 0 / 0 / 3 / 83 | 18 / 13 / 3 / 11 / 7 / 1 / 42 | 17 / 21 / 2 / 8 / 6 / 0 / 43 | 9.90 | 3.38 / 2.95 / 3.58 | 0.60 / 0.03 | 27.10 |
| step=3 | 3v3 · 1 · 40 | 16 / 19 / 5 / 0 | 15.8 | 8 % | 3 / 3 / 0 / 3 / 3 / 3 / 88 | 16 / 15 / 1 / 12 / 6 / 1 / 47 | 13 / 23 / 2 / 9 / 6 / 1 / 45 | 9.60 | 3.17 / 2.92 / 3.50 | 0.64 / 0.05 | 26.77 |
| move=1 | 3v3 · 1 · 40 | 18 / 19 / 3 / 0 | 14.0 | 15 % | 5 / 5 / 0 / 8 / 3 / 0 / 80 | 20 / 14 / 3 / 6 / 13 / 1 / 39 | 19 / 20 / 2 / 8 / 11 / 0 / 37 | 8.03 | 2.73 / 2.67 / 2.62 | 0.65 / 0.06 | 26.23 |
| move=3 | 3v3 · 1 · 40 | 17 / 17 / 6 / 0 | 16.1 | 3 % | 0 / 5 / 0 / 5 / 0 / 0 / 90 | 10 / 20 / 2 / 12 / 5 / 0 / 48 | 11 / 25 / 1 / 11 / 5 / 0 / 45 | 9.78 | 3.62 / 2.50 / 3.65 | 0.69 / 0.05 | 27.57 |
| step=1,move=1 | 3v3 · 1 · 40 | 20 / 17 / 3 / 0 | 14.6 | 10 % | 5 / 0 / 0 / 5 / 3 / 3 / 83 | 20 / 13 / 3 / 7 / 13 / 1 / 41 | 21 / 17 / 3 / 7 / 11 / 0 / 38 | 8.72 | 2.70 / 3.02 / 3.00 | 0.53 / 0.07 | 26.48 |
| step=1,move=3 | 3v3 · 1 · 40 | 19 / 16 / 5 / 0 | 15.2 | 10 % | 0 / 5 / 0 / 10 / 0 / 0 / 85 | 13 / 15 / 2 / 14 / 5 / 1 / 46 | 11 / 23 / 2 / 9 / 4 / 0 / 46 | 10.53 | 3.67 / 3.25 / 3.60 | 0.57 / 0.05 | 26.62 |
| step=3,move=3 | 3v3 · 1 · 40 | 15 / 21 / 4 / 0 | 16.2 | 5 % | 0 / 5 / 0 / 3 / 0 / 0 / 93 | 12 / 18 / 0 / 10 / 2 / 0 / 55 | 10 / 25 / 0 / 9 / 4 / 0 / 49 | 7.90 | 3.38 / 1.75 / 2.77 | 0.83 / 0.04 | 27.00 |
| defap=2 | 3v3 · 1 · 40 | 14 / 20 / 6 / 0 | 15.6 | 13 % | 8 / 3 / 0 / 5 / 0 / 3 / 83 | 17 / 16 / 3 / 14 / 5 / 1 / 41 | 13 / 26 / 2 / 7 / 6 / 0 / 43 | 9.57 | 3.35 / 2.67 / 3.55 | 0.73 / 0.06 | 26.70 |
| defap=3 | 3v3 · 1 · 40 | 15 / 21 / 4 / 0 | 15.6 | 10 % | 8 / 3 / 0 / 3 / 0 / 3 / 85 | 18 / 19 / 4 / 12 / 2 / 1 / 40 | 14 / 30 / 2 / 6 / 4 / 1 / 42 | 9.57 | 3.20 / 2.95 / 3.42 | 0.81 / 0.10 | 27.62 |
| jab=1,defap=2 | 3v3 · 1 · 40 | 16 / 21 / 3 / 0 | 15.5 | 8 % | 5 / 3 / 0 / 3 / 0 / 3 / 88 | 25 / 9 / 3 / 11 / 6 / 1 / 42 | 19 / 21 / 3 / 6 / 6 / 0 / 42 | 9.45 | 3.08 / 2.88 / 3.50 | 0.63 / 0.03 | 26.05 |
| zonepush | 3v3 · 1 · 40 | 17 / 22 / 1 / 0 | 13.3 | 23 % | 0 / 3 / 0 / 15 / 5 / 0 / 78 | 14 / 14 / 1 / 19 / 15 / 0 / 34 | 11 / 25 / 2 / 12 / 13 / 0 / 33 | 9.22 | 3.27 / 3.12 / 2.83 | 0.66 / 0.10 | 25.70 |
| zonepush,allpush | 3v3 · 1 · 40 | 17 / 22 / 1 / 0 | 12.9 | 30 % | 0 / 8 / 0 / 15 / 8 / 0 / 70 | 11 / 17 / 2 / 17 / 16 / 1 / 33 | 9 / 27 / 2 / 11 / 14 / 0 / 33 | 8.80 | 3.35 / 2.67 / 2.77 | 0.72 / 0.12 | 25.48 |
| aggro | 3v3 · 1 · 40 | 12 / 23 / 5 / 0 | 14.5 | 18 % | 5 / 8 / 3 / 0 / 3 / 5 / 78 | 18 / 18 / 3 / 16 / 7 / 3 / 30 | 15 / 33 / 1 / 10 / 5 / 1 / 32 | 11.82 | 3.88 / 4.17 / 3.77 | 0.73 / 0.07 | 27.10 |
| aggro,step=1 | 3v3 · 1 · 40 | 17 / 19 / 4 / 0 | 13.1 | 30 % | 13 / 10 / 0 / 5 / 3 / 0 / 70 | 28 / 19 / 3 / 14 / 4 / 1 / 27 | 22 / 30 / 2 / 9 / 5 / 1 / 30 | 10.57 | 3.42 / 3.55 / 3.60 | 0.73 / 0.08 | 27.10 |
| aggro,move=1 | 3v3 · 1 · 40 | 19 / 20 / 1 / 0 | 11.7 | 38 % | 20 / 10 / 0 / 5 / 3 / 0 / 60 | 33 / 21 / 1 / 11 / 10 / 0 / 22 | 27 / 26 / 0 / 9 / 10 / 0 / 26 | 9.43 | 2.83 / 3.65 / 2.95 | 0.67 / 0.08 | 26.62 |
| aggro,step=1,move=1 | 3v3 · 1 · 40 | 17 / 21 / 2 / 0 | 11.6 | 33 % | 20 / 5 / 0 / 8 / 0 / 0 / 65 | 34 / 18 / 1 / 10 / 9 / 0 / 25 | 30 / 23 / 1 / 7 / 11 / 0 / 26 | 8.95 | 2.55 / 3.77 / 2.62 | 0.60 / 0.09 | 26.07 |
| aggro,defap=2 | 3v3 · 1 · 40 | 14 / 22 / 4 / 0 | 14.6 | 15 % | 5 / 8 / 0 / 5 / 3 / 0 / 80 | 18 / 19 / 2 / 18 / 7 / 0 / 32 | 15 / 33 / 1 / 10 / 5 / 0 / 34 | 10.82 | 3.48 / 3.48 / 3.88 | 0.80 / 0.06 | 27.52 |
| aggro,zonepush,allpush | 3v3 · 1 · 40 | 17 / 22 / 1 / 0 | 13.2 | 28 % | 8 / 5 / 0 / 13 / 3 / 3 / 70 | 11 / 22 / 3 / 16 / 17 / 1 / 28 | 10 / 28 / 2 / 10 / 15 / 0 / 32 | 9.95 | 3.02 / 3.55 / 3.38 | 0.74 / 0.05 | 26.48 |
| aggro,step=1,move=1,defap=2,zonepush,allpush | 3v3 · 1 · 40 | 17 / 22 / 1 / 0 | 8.8 | 53 % | 20 / 18 / 3 / 5 / 8 / 0 / 45 | 28 / 23 / 2 / 8 / 20 / 0 / 16 | 26 / 27 / 2 / 6 / 22 / 0 / 17 | 7.88 | 2.70 / 3.12 / 2.05 | 0.77 / 0.11 | 24.65 |
| aggro,step=1,move=1,defap=2,zonepush,allpush | 3v3 · 2 · 40 | 21 / 18 / 1 / 0 | 8.9 | 55 % | 18 / 10 / 8 / 8 / 13 / 0 / 45 | 28 / 18 / 4 / 9 / 26 / 1 / 14 | 29 / 23 / 2 / 7 / 22 / 0 / 16 | 8.22 | 2.27 / 3.12 / 2.83 | 0.61 / 0.11 | 24.52 |
| build rules | 2v2 · 1 · 60 | 19 / 36 / 5 / 0 | 10.8 | 37 % | 12 / 13 / 2 / 7 / 5 / 0 / 62 | 20 / 14 / 5 / 13 / 6 / 0 / 40 | 21 / 18 / 2 / 10 / 4 / 0 / 44 | 5.73 | 1.40 / 2.07 / 2.27 | 0.54 / 0.03 | 16.03 |
| aggro,step=1,move=1,defap=2,zonepush,allpush | 2v2 · 1 · 60 | 26 / 32 / 2 / 0 | 5.9 | 73 % | 38 / 10 / 0 / 5 / 23 / 0 / 23 | 40 / 16 / 2 / 3 / 24 / 0 / 13 | 40 / 16 / 1 / 3 / 24 / 0 / 16 | 3.38 | 0.98 / 1.17 / 1.23 | 0.56 / 0.22 | 15.45 |

**Observations** (indications; bots only; one seed for most rows):

- *The first setting in which most 3v3 bot battles end by fighting:* aggressive bot + Step 1 AP + movement 1 AP + defence zones 2 AP + zones that push at cast + pushing Strikes. The collapse ends 45 % of battles on both seeds (build rules: 90–98 %), 53–55 % end before pressure, battles last 8.8–8.9 rounds instead of 16, and collision damage is 22 % of all damage. In 2v2 the collapse share falls from 62 % to 23 % (73 % before pressure, 5.9 rounds).
- *Movement price matters more than the Step price:* movement skills at 1 AP give 80 % collapse endings alone and 60 % with the aggressive bot (38 % before pressure); the Step at 1 AP gives 83 % and 70 %. Raising either to 3 AP changes little (88–93 %).
- *Zones that push at cast are the strongest single displacement change:* 78 % collapse endings, collision defeats 15 %, collision damage 13 %; with pushing Strikes 70 % and 30 % of battles ended before pressure.
- *Dearer defence alone changes little:* 2 AP 83 %, 3 AP 85 %; with a 1-AP Jab 88 %.
- *No single change is enough:* every single rule change stays between 78 % and 93 %; the effect comes from the combination, and it needs the aggressive bot (the same package was not run without it).
- *Second side:* side 1 wins more in most rows (for example 22 to 17 in several rows), as in earlier entries.

**Follow-up:** T38 (which of these become build rules: cheap movement, defence at 2 AP, zones pushing at cast, pushing Strikes), T13 (run the package without the aggressive bot; human play). Prices are ignored by user decision until the gameplay is settled.

## S007 · 2026-11-12 · two Surge types, shield cost, cheaper attack, pushing Strikes, aggressive bot

**State:** `9c1f1ed` dirty (uncommitted) · content `2026-11-12.1` · kit set differs from `a71108227eb4` only by the Surge type of four skills (Crucible, Ambush Rift, Spring Burst, Bramble Tide are traps; every other Surge is timed with 2 turns). 1040 battles in 23 runs.

**Questions (user):** use both Surge types; is attack too expensive or defence too cheap; do shields matter; what does an instant displacement tool in every kit do? **Build rule since this entry (user decision 2026-11-12):** a Surge skill is either *timed* (cast on any squares, fires after 2 finished turns of any monster) or a *trap* (as in S005/S006); one marker per square. The “Surge” columns now count both types.

| Variant | What changes |
|---|---|
| build rules | both Surge types as authored |
| `alltraps` / `alltimed` | every Surge is a trap / is timed |
| `shieldap=2` / `noshield` | shield zone skills cost 2 AP / cannot be used |
| `step=1` / `jab=1` | Step / the Jab Strike costs 1 AP instead of 2 |
| `allpush` | every Strike pushes each struck monster 1 square away (Scaled keeps its chosen direction) |
| `aggro` | bot change, not a rule: the AI values closing in more (1.5 instead of 0.6 per square) and its own support effects less |
| `pressure +200` | late-round pressure out of reach; a battle stops as a timeout after 600 turns |

Command per row: `sim.gd -- <battles> <mode> <seed> "9c1f1ed dirty" --paired --compact [--variant …] [--pressure 200]`, `AiBrain` on both sides. Rows are pasted unchanged from the tool (its header still says “trap” in three column names).

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges cast | sprung or fired on a monster / without one / left at the end | Surge dmg per cast: enemies / own side | total dmg |
|---|---|---|---|---|---|---|---|---|---|---|---|
| build rules | 3v3 · 1 · 40 | 19 / 16 / 5 / 0 | 16.5 | 5 % | 3 / 3 / 0 / 3 / 3 / 90 | 13 / 15 / 11 / 7 / 1 / 48 | 12 / 22 / 7 / 6 / 0 / 51 | 7.47 | 2.80 / 1.68 / 3.00 | 0.73 / 0.05 | 27.20 |
| build rules | 3v3 · 2 · 40 | 24 / 13 / 3 / 0 | 16.3 | 0 % | 0 / 0 / 0 / 0 / 0 / 100 | 13 / 20 / 12 / 3 / 1 / 49 | 11 / 25 / 9 / 4 / 0 / 49 | 7.58 | 2.88 / 2.02 / 2.67 | 0.80 / 0.10 | 27.48 |
| alltraps | 3v3 · 1 · 40 | 23 / 14 / 3 / 0 | 17.1 | 8 % | 8 / 3 / 0 / 0 / 3 / 88 | 25 / 7 / 5 / 5 / 1 / 54 | 19 / 9 / 5 / 7 / 0 / 57 | 7.05 | 1.45 / 0.40 / 5.20 | 0.24 / 0.11 | 27.27 |
| alltimed | 3v3 · 1 · 40 | 18 / 20 / 2 / 0 | 12.2 | 35 % | 10 / 20 / 8 / 0 / 0 / 63 | 16 / 25 / 16 / 8 / 0 / 30 | 15 / 38 / 9 / 7 / 0 / 28 | 8.68 | 4.83 / 3.62 / 0.23 | 1.07 / 0.03 | 25.30 |
| shieldap=2 | 3v3 · 1 · 40 | 17 / 16 / 7 / 0 | 15.9 | 13 % | 5 / 5 / 5 / 0 / 0 / 85 | 17 / 14 / 11 / 8 / 0 / 46 | 12 / 22 / 8 / 6 / 0 / 49 | 7.38 | 2.70 / 1.95 / 2.73 | 0.74 / 0.08 | 27.15 |
| noshield | 3v3 · 1 · 40 | 18 / 18 / 4 / 0 | 15.9 | 8 % | 5 / 5 / 0 / 0 / 0 / 90 | 16 / 23 / 10 / 4 / 0 / 44 | 13 / 28 / 6 / 4 / 0 / 48 | 7.60 | 2.67 / 1.95 / 2.98 | 0.85 / 0.15 | 27.80 |
| step=1 | 3v3 · 1 · 40 | 16 / 20 / 4 / 0 | 15.4 | 13 % | 5 / 3 / 8 / 0 / 3 / 83 | 19 / 15 / 8 / 9 / 1 / 43 | 17 / 19 / 7 / 7 / 1 / 48 | 7.45 | 2.62 / 2.15 / 2.67 | 0.59 / 0.09 | 26.77 |
| jab=1 | 3v3 · 1 · 40 | 20 / 15 / 5 / 0 | 16.0 | 8 % | 5 / 3 / 0 / 0 / 3 / 90 | 23 / 10 / 8 / 8 / 1 / 45 | 20 / 17 / 5 / 7 / 0 / 49 | 6.83 | 2.30 / 1.93 / 2.60 | 0.60 / 0.06 | 26.65 |
| jab=1,step=1 | 3v3 · 1 · 40 | 17 / 19 / 4 / 0 | 15.0 | 20 % | 13 / 3 / 3 / 3 / 3 / 78 | 27 / 11 / 7 / 6 / 2 / 43 | 21 / 16 / 6 / 7 / 1 / 47 | 7.45 | 2.33 / 2.35 / 2.77 | 0.54 / 0.06 | 26.90 |
| allpush | 3v3 · 1 · 40 | 19 / 17 / 4 / 0 | 16.5 | 5 % | 0 / 0 / 5 / 0 / 0 / 93 | 13 / 12 / 12 / 7 / 1 / 49 | 11 / 20 / 7 / 8 / 0 / 52 | 7.47 | 2.50 / 2.10 / 2.88 | 0.70 / 0.03 | 27.12 |
| aggro | 3v3 · 1 · 40 | 15 / 19 / 6 / 0 | 15.1 | 15 % | 8 / 5 / 5 / 0 / 5 / 78 | 18 / 17 / 17 / 6 / 1 / 35 | 17 / 27 / 9 / 5 / 1 / 38 | 9.28 | 3.02 / 3.45 / 2.80 | 0.69 / 0.10 | 27.43 |
| aggro,noshield | 3v3 · 1 · 40 | 19 / 17 / 4 / 0 | 15.1 | 13 % | 0 / 5 / 8 / 3 / 0 / 83 | 19 / 19 / 16 / 8 / 0 / 34 | 17 / 29 / 9 / 5 / 0 / 38 | 8.55 | 2.83 / 2.90 / 2.83 | 0.83 / 0.09 | 27.80 |
| aggro,jab=1 | 3v3 · 1 · 40 | 18 / 18 / 4 / 0 | 14.7 | 18 % | 10 / 0 / 5 / 3 / 0 / 83 | 29 / 13 / 11 / 5 / 0 / 38 | 24 / 21 / 6 / 5 / 0 / 41 | 7.22 | 2.25 / 2.27 / 2.70 | 0.71 / 0.06 | 26.82 |
| aggro,step=1 | 3v3 · 1 · 40 | 24 / 12 / 4 / 0 | 13.1 | 30 % | 8 / 8 / 10 / 5 / 0 / 70 | 29 / 19 / 10 / 7 / 0 / 30 | 23 / 28 / 7 / 6 / 0 / 32 | 8.97 | 3.12 / 3.30 / 2.55 | 0.78 / 0.07 | 26.80 |
| aggro,allpush | 3v3 · 1 · 40 | 19 / 17 / 4 / 0 | 14.1 | 20 % | 3 / 15 / 13 / 0 / 0 / 70 | 15 / 23 / 19 / 6 / 0 / 32 | 15 / 32 / 10 / 7 / 0 / 33 | 9.72 | 3.33 / 3.77 / 2.62 | 0.79 / 0.08 | 26.85 |
| aggro,jab=1,step=1,noshield,allpush | 3v3 · 1 · 40 | 24 / 14 / 2 / 0 | 14.9 | 15 % | 10 / 5 / 0 / 3 / 0 / 83 | 25 / 15 / 6 / 10 / 0 / 39 | 25 / 21 / 4 / 7 / 0 / 40 | 8.18 | 2.20 / 3.48 / 2.50 | 0.69 / 0.02 | 27.10 |
| pressure +200 | 3v3 · 1 · 20 | 3 / 1 / 0 / 16 | 114.7 | 10 % | 25 / 0 / 0 / 25 / 0 / 50 | 28 / 20 / 26 / 12 / 0 / 4 | 24 / 37 / 16 / 12 / 0 / 6 | 7.35 | 2.55 / 2.05 / 2.75 | 0.69 / 0.02 | 13.90 |
| aggro + pressure +200 | 3v3 · 1 · 20 | 3 / 3 / 0 / 14 | 136.2 | 15 % | 33 / 17 / 0 / 0 / 0 / 50 | 25 / 28 / 23 / 9 / 0 / 5 | 27 / 43 / 12 / 7 / 0 / 6 | 16.15 | 3.30 / 9.80 / 3.05 | 0.43 / 0.05 | 17.95 |
| aggro,jab=1 + pressure +200 | 3v3 · 1 · 20 | 3 / 3 / 0 / 14 | 124.2 | 20 % | 50 / 0 / 17 / 0 / 0 / 33 | 50 / 19 / 21 / 3 / 0 / 3 | 39 / 37 / 9 / 6 / 0 / 5 | 7.60 | 2.70 / 2.15 / 2.75 | 0.78 / 0.03 | 16.55 |
| build rules | 2v2 · 1 · 60 | 20 / 33 / 7 / 0 | 10.9 | 37 % | 10 / 13 / 12 / 5 / 0 / 60 | 25 / 14 / 14 / 7 / 0 / 41 | 24 / 14 / 9 / 5 / 0 / 46 | 4.62 | 1.13 / 1.67 / 1.82 | 0.45 / 0.04 | 15.73 |
| aggro,jab=1 | 2v2 · 1 · 60 | 25 / 34 / 1 / 0 | 8.3 | 48 % | 32 / 10 / 8 / 3 / 3 / 42 | 47 / 13 / 9 / 6 / 1 / 23 | 48 / 15 / 7 / 5 / 1 / 24 | 4.62 | 0.93 / 2.10 / 1.58 | 0.40 / 0.06 | 14.68 |
| build rules | 1v1 · 1 · 100 | 45 / 52 / 3 / 0 | 5.1 | 73 % | 44 / 26 / 1 / 4 / 1 / 24 | 43 / 25 / 1 / 4 / 1 / 26 | 51 / 14 / 4 / 6 / 0 / 26 | 1.25 | 0.32 / 0.42 / 0.51 | 0.54 / 0.17 | 6.54 |
| aggro,jab=1 | 1v1 · 1 · 100 | 52 / 47 / 1 / 0 | 3.5 | 88 % | 68 / 7 / 4 / 9 / 0 / 12 | 67 / 7 / 4 / 9 / 0 / 13 | 75 / 5 / 2 / 7 / 0 / 11 | 1.09 | 0.16 / 0.48 / 0.45 | 0.28 / 0.00 | 6.31 |

**Observations** (indications; bots only; one seed for most rows, differences of a few points are noise):

- *The timed Surge is again the strongest lever:* with every Surge timed, the collapse ends 63 % of 3v3 battles instead of 88 % (all traps) or 90–100 % (mixed), 35 % end before pressure, battles last 12.2 instead of 16–17 rounds, and Surges deal 38 % of all damage. The mixed build sits in between in damage (22–25 %) but not in endings.
- *Shields matter little:* 2 AP for shield zones or none at all leaves the collapse share at 85–90 %.
- *Cheaper attack helps a little, mostly the Step:* `step=1` 83 %, `jab=1` 90 %, both 78 % with 20 % of battles ended before pressure.
- *Pushing Strikes alone change nothing* (93 %); with the aggressive bot they move defeats toward Surges (15 % of last defeats).
- *An aggressive bot helps about as much as any single rule change:* 78 %; with `step=1` 70 % and 30 % ended before pressure (13.1 rounds); with pushing Strikes 70 %. All changes at once are not better than the best pairs (83 %).
- *Without pressure the bots still stand still:* 14–16 of 20 3v3 battles reach the turn limit, also with the aggressive bot and the 1-AP Jab.
- *Smaller modes are far less affected:* 2v2 goes from 60 % to 42 % collapse endings with `aggro,jab=1` (48 % before pressure), 1v1 from 24 % to 12 % (88 % before pressure).
- *Reading:* in 3v3 no tested change makes bot battles end by fighting in most cases. The Surge type has the largest effect, the bot's willingness to attack the second largest, attack cost a small one, shield cost and pushing Strikes almost none.

**Follow-up:** T38 (share of timed Surges and traps; the one-marker rule), T13 (why bots stand still without pressure; human play), T02 later (prices are ignored for now by user decision). No GDD price was changed.

## S006 · 2026-11-12 · what ends the battles: trap build without a trap cap, faster bots

**State:** `9c1f1ed` dirty (uncommitted: trap build, merged data, bot speed-ups) · content `2026-11-12.1` · kit set `a71108227eb4`. 620 battles in 12 runs.

**Questions (user):** how did traps change play, and do most battles still end through late-round pressure? **Changes since S005:** the same trap may be set repeatedly (no cap per skill); the bots were made about twice as fast and now consider fewer placements (zones only on a monster, traps only next to an enemy), so rows are not comparable with S005 one by one; new columns. No rule changed otherwise.

Command per row: `sim.gd -- <battles> <mode> <seed> "9c1f1ed dirty" --paired --compact [--pressure N] [--bot-a plan --bot-b plan] [--variant kinpush,push=2]`. Rows 6 and 7 use the `plan` bot, all others `AiBrain`. `--pressure 200` moves late-round pressure out of reach for most battles (a battle stops as a timeout after 600 turns). Rows are pasted unchanged from the tool.

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Traps set | sprung on a monster / sprung empty / left at the end | Trap dmg per trap: enemies / own side | total dmg |
|---|---|---|---|---|---|---|---|---|---|---|---|
| build rules | 3v3 · 1 · 40 | 23 / 14 / 3 / 0 | 17.1 | 8 % | 8 / 3 / 0 / 0 / 3 / 88 | 25 / 7 / 5 / 5 / 1 / 54 | 19 / 9 / 5 / 7 / 0 / 57 | 7.05 | 1.45 / 0.40 / 5.20 | 0.24 / 0.11 | 27.27 |
| build rules | 3v3 · 2 · 40 | 21 / 16 / 3 / 0 | 15.3 | 10 % | 5 / 3 / 0 / 3 / 3 / 85 | 33 / 5 / 11 / 7 / 1 / 41 | 27 / 6 / 9 / 9 / 1 / 47 | 6.17 | 1.00 / 0.30 / 4.88 | 0.14 / 0.12 | 25.85 |
| pressure +4 | 3v3 · 1 · 40 | 22 / 15 / 3 / 0 | 20.8 | 8 % | 8 / 3 / 0 / 0 / 3 / 88 | 25 / 7 / 5 / 5 / 1 / 55 | 19 / 9 / 5 / 7 / 0 / 58 | 7.08 | 1.40 / 0.45 / 5.22 | 0.23 / 0.10 | 27.25 |
| pressure +8 | 3v3 · 1 · 40 | 23 / 14 / 3 / 0 | 24.4 | 8 % | 8 / 3 / 0 / 0 / 3 / 88 | 25 / 7 / 5 / 6 / 1 / 53 | 19 / 9 / 5 / 8 / 0 / 57 | 7.17 | 1.48 / 0.50 / 5.20 | 0.24 / 0.11 | 27.27 |
| pressure +200 | 3v3 · 1 · 40 | 4 / 2 / 0 / 34 | 115.4 | 8 % | 50 / 0 / 0 / 0 / 0 / 50 | 56 / 11 / 12 / 11 / 0 / 3 | 45 / 17 / 13 / 17 / 0 / 6 | 7.47 | 1.30 / 1.12 / 5.05 | 0.21 / 0.07 | 12.00 |
| build rules | 3v3 · 1 · 20 | 8 / 9 / 3 / 0 | 16.6 | 5 % | 0 / 0 / 5 / 0 / 0 / 95 | 23 / 8 / 10 / 9 / 0 / 47 | 21 / 8 / 6 / 10 / 0 / 54 | 6.85 | 1.10 / 0.50 / 5.25 | 0.21 / 0.09 | 26.45 |
| pressure +200 | 3v3 · 1 · 20 | 1 / 1 / 0 / 18 | 121.4 | 10 % | 0 / 0 / 100 / 0 / 0 / 0 | 43 / 14 / 22 / 18 / 0 / 0 | 45 / 15 / 16 / 21 / 0 / 0 | 6.80 | 1.00 / 0.60 / 5.20 | 0.20 / 0.07 | 12.15 |
| kinpush,push=2 | 3v3 · 1 · 40 | 19 / 13 / 8 / 0 | 16.9 | 13 % | 3 / 5 / 0 / 5 / 3 / 85 | 18 / 6 / 5 / 16 / 1 / 56 | 18 / 5 / 5 / 12 / 0 / 59 | 5.80 | 0.88 / 0.25 / 4.67 | 0.07 / 0.17 | 27.30 |
| build rules | 2v2 · 1 · 60 | 24 / 32 / 4 / 0 | 11.2 | 32 % | 13 / 5 / 12 / 2 / 0 / 67 | 33 / 8 / 7 / 6 / 1 / 45 | 32 / 6 / 7 / 5 / 0 / 49 | 3.85 | 0.52 / 0.13 / 3.20 | 0.21 / 0.02 | 15.53 |
| pressure +200 | 2v2 · 1 · 60 | 11 / 17 / 0 / 32 | 109.8 | 33 % | 29 / 11 / 25 / 4 / 0 / 29 | 57 / 12 / 12 / 9 / 0 / 8 | 57 / 9 / 12 / 9 / 0 / 12 | 3.85 | 0.50 / 0.13 / 3.22 | 0.21 / 0.01 | 8.87 |
| build rules | 1v1 · 1 · 100 | 45 / 50 / 5 / 0 | 6.9 | 54 % | 41 / 14 / 0 / 2 / 0 / 43 | 39 / 13 / 0 / 2 / 0 / 46 | 38 / 6 / 2 / 5 / 0 / 48 | 1.29 | 0.17 / 0.05 / 1.07 | 0.23 / 0.09 | 6.52 |
| pressure +200 | 1v1 · 1 · 100 | 35 / 32 / 5 / 28 | 88.8 | 57 % | 58 / 19 / 0 / 1 / 0 / 21 | 55 / 18 / 0 / 1 / 0 / 26 | 50 / 8 / 2 / 7 / 0 / 34 | 1.29 | 0.16 / 0.05 / 1.08 | 0.22 / 0.09 | 5.19 |

| Column | Meaning |
|---|---|
| Last defeat by … | kind of the last damage taken by the monster whose defeat ended the battle, in % of finished battles; “Voidscar” is damage from Voidscar squares, “arena” the collapse damage once no free square is left |
| All defeats / Damage by the same kinds | the same split over every defeat and over all damage; hazard ground excludes Voidscar, collision includes fall and board-edge damage |
| Traps: sprung on a monster / sprung empty / left at the end | per battle; “empty” = sprung by a prop or Mountain with no monster on it |

**Observations** (indications; bots only):

- *Late-round pressure ends almost every 3v3:* the last defeat comes from the arena collapse in 85–88 % of battles (95 % with the `plan` bot), in 67 % of 2v2 and 43 % of 1v1 battles. Voidscar squares themselves do little (0–1 % of damage); it is the collapse after the board has filled.
- *Starting pressure later only lengthens battles:* +4 and +8 rounds give the same winners and the same shares at 20.8 and 24.4 instead of 17.1 mean rounds.
- *Without pressure the bots stop fighting:* 34 of 40 3v3 battles (18 of 20 with `plan`) and 32 of 60 2v2 battles reach the 600-turn limit at about 110–120 rounds with only 12 and 9 damage dealt in total. The bots reach a standstill; nothing in their evaluation makes them attack into it.
- *Traps mostly lie unused:* about 6–7 are set per 3v3 battle, 1.0–1.5 are sprung on a monster, 0.3–0.5 are sprung empty and about 5 lie until the end. A trap deals 0.14–0.24 damage to enemies and about 0.1 to its owner's side; traps cause 5–9 % of all damage and 3–8 % of the defeats. The board is not flooded even without a cap.
- *Strikes are the main real damage source:* 19–27 % of damage and 25–33 % of defeats in 3v3; with pressure out of reach 45 % and 56 %.
- *Displacement switches:* 2-square pushes plus Beast/Spirit displacement raise collision damage from 7 % to 12 % and collision defeats from 5 % to 16 %, but trap damage shifts to the owner's side (0.07 enemies / 0.17 own).
- *Reading:* the build has no force other than late-round pressure that makes the bots engage. Whether that is the rules (attacking costs more than defending, traps threaten nobody who stays away) or the bots (they never attack into a standstill) cannot be told from these rows.

**Follow-up:** T38 (a Surge profile that threatens occupied squares again; cheaper attack; displacement in every kit), T13 (bot that attacks; human play). No rule or kit was changed.

## S005 · 2026-11-12 · new baseline: trap Surges, board-edge damage and spiky props as build rules

**State:** `9c1f1ed` dirty (uncommitted: the build rules below, the merged data folder, the removal of the legacy skill model) · content `2026-11-12.1` · kit set `a71108227eb4`. 280 battles in 6 runs.

**What changed since S004 (user decisions 2026-11-12, [temp_todo.md](temp_todo.md) T38; the GDDs are unchanged):** every Surge is a trap (monster-free squares at cast, springs when a ground monster stands on it or a prop or Mountain appears there, never lapses, one per skill slot); the board edge deals 1 to a monster pushed against it; Bamboo Stand and Stone Lion deal 2 collision damage; five monsters carry the trap kits of S004. These are now the rules of the build, so the tool printed them as “confirmed rules” in the rows below (it prints “build rules” from now on). Rows before S005 are not comparable row by row.

Command per row: `sim.gd -- <battles> <mode> <seed> "9c1f1ed dirty" --paired --compact [--bot-a plan --bot-b plan] [--variant kinpush,push=2]`. Rows 1, 2, 5 and 6 use `AiBrain` on both sides, rows 3 and 4 the `plan` bot. “Surges declared” counts traps set; “Leaving moves” no longer applies (a trap is set on free squares). Rows are pasted unchanged from the tool.

| Variant | Mode · seed · battles | Side 0 / 1 / Draw | Mean rounds | Ended before pressure | Defeats | Surges declared | Surge dmg per Surge | on enemies / own side | edge share | Leaving moves per Surge | Defeats by Surge | strike / surge / ground / collision+fall / arena share | total dmg |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| confirmed rules | 3v3 · 1 · 40 | 19 / 14 / 7 | 15.7 | 15 % | 4.90 | 4.35 | 0.34 | 0.21 / 0.13 | 0 % | 0.00 | 0.12 | 27 % / 5 % / 6 % / 10 % / 50 % | 26.82 |
| confirmed rules | 3v3 · 2 · 40 | 23 / 16 / 1 | 13.3 | 28 % | 4.42 | 4.60 | 0.57 | 0.32 / 0.24 | 0 % | 0.00 | 0.45 | 31 % / 11 % / 7 % / 10 % / 41 % | 24.40 |
| confirmed rules | 3v3 · 1 · 20 | 8 / 7 / 5 | 16.4 | 5 % | 4.85 | 4.85 | 0.36 | 0.26 / 0.10 | 0 % | 0.00 | 0.30 | 19 % / 7 % / 7 % / 10 % / 55 % | 26.10 |
| kinpush,push=2 | 3v3 · 1 · 20 | 7 / 11 / 2 | 16.1 | 5 % | 4.90 | 4.50 | 0.37 | 0.28 / 0.09 | 0 % | 0.00 | 0.30 | 24 % / 6 % / 5 % / 14 % / 50 % | 25.90 |
| confirmed rules | 2v2 · 1 · 60 | 22 / 30 / 8 | 11.3 | 32 % | 2.88 | 3.02 | 0.40 | 0.34 / 0.07 | 0 % | 0.00 | 0.27 | 32 % / 8 % / 6 % / 6 % / 47 % | 15.70 |
| confirmed rules | 1v1 · 1 · 100 | 46 / 50 / 4 | 6.3 | 62 % | 1.04 | 1.05 | 0.25 | 0.13 / 0.11 | 0 % | 0.00 | 0.10 | 44 % / 4 % / 4 % / 5 % / 42 % | 6.39 |

**Observations** (indications; bots only):

- *The build reproduces the experiment:* the `plan` row equals the matching S004 row (8 / 7 / 5, 0.36 per trap), so the fixed rules behave like the switches measured before.
- *Traps are a small damage source in bot play:* 0.25–0.57 damage per trap set, with a large part on the owner's side; Surge share of all damage 4–11 %. Collision + fall reach 10 % in 3v3 (14 % with 2-square pushes and Beast/Spirit displacement).
- *Late-round pressure decides more battles than before:* arena share 41–55 % in 3v3, 47 % in 2v2, 42 % in 1v1 (S002 confirmed rules: 36–38 %, 30 %, 26 %); 5–28 % of 3v3 battles end before pressure.
- *Side balance in 3v3:* 42 to 30 for side 0 with `AiBrain` over 80 battles, the reverse of S001–S003; with the `plan` bot 8 to 7.
- *Reading:* the bots neither set traps with a plan nor push into them on purpose, so these rows describe bot play, not the value of the rule. Human play decides (T38, T13).

**Follow-up:** T38 (decide the direction after playing), T13 (late-round pressure share, bots). No GDD rule or price was changed.

## S004 · 2026-11-12 · trap kit set with displacement skills (planning bot)

**State:** `9c1f1ed` dirty (uncommitted: experiment switches, test skills Headbutt / Quake Leap / Shove / Ambush Rift, kit set `kit_variants/trap`, data folder move) · content `2026-11-11.1` · kit set `a0dae446ce2a` for the default kits (see [Kit Sets](#kit-sets)); rows with `kits=trap` replace five kits as listed below. 180 battles in 9 runs (the first row is the confirmed-rules row of S003, repeated for comparison).

**Question:** S003 could not judge trap Surges because no kit was built for them. Do kits with a trap and a displacement skill change the picture? (T38; experiment content, no GDD rule.)

| Kit of `kits=trap` | Slots |
|---|---|
| blaze_tiger | headbutt (charge up to 2 squares, push the next monster 1 on), strike_jab, magma_pounce, lava_field |
| forge_golem | strike_jab, shove (no damage, push 1), crucible, immovable |
| gloom_wolf | run, strike_jab, gloom_rift, shove |
| hollow_serpent | burrow, strike_jab, coiling_rift, ambush_rift (a trap only monsters spring) |
| grove_wisp | quake_leap (leap, then push all eight neighbours 1 outward), strike_jab, spring_burst, gale |

The other four species keep their default kits. Variants `trap`, `edge=1`, `spiky=…`, `kinpush`, `push=2`, `turns=2` as in S002/S003. Command per row: `sim.gd -- 20 3v3 <seed> "9c1f1ed dirty" --paired --compact --bot-a plan --bot-b plan [--variant …]`. Rows are pasted unchanged from the tool.

| Variant | Mode · seed · battles | Side 0 / 1 / Draw | Mean rounds | Ended before pressure | Defeats | Surges declared | Surge dmg per Surge | on enemies / own side | edge share | Leaving moves per Surge | Defeats by Surge | strike / surge / ground / collision+fall / arena share | total dmg |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| confirmed rules | 3v3 · 1 · 20 | 1 / 18 / 1 | 13.7 | 25 % | 4.60 | 19.65 | 0.29 | 0.28 / 0.01 | 0 % | 0.49 | 0.75 | 23 % / 23 % / 15 % / 5 % / 28 % | 24.95 |
| confirmed rules | 3v3 · 2 · 20 | 10 / 9 / 1 | 12.2 | 30 % | 4.50 | 14.80 | 0.41 | 0.37 / 0.04 | 0 % | 0.49 | 0.95 | 30 % / 25 % / 13 % / 7 % / 21 % | 24.45 |
| kits=trap | 3v3 · 1 · 20 | 6 / 14 / 0 | 12.3 | 35 % | 4.35 | 14.45 | 0.43 | 0.40 / 0.02 | 0 % | 0.43 | 0.90 | 24 % / 26 % / 16 % / 5 % / 27 % | 23.95 |
| kits=trap,edge=1,spiky=bamboo_stand+stone_lion | 3v3 · 1 · 20 | 5 / 14 / 1 | 12.7 | 30 % | 4.50 | 13.65 | 0.45 | 0.44 / 0.02 | 0 % | 0.43 | 1.00 | 21 % / 25 % / 15 % / 8 % / 27 % | 24.75 |
| trap,kits=trap | 3v3 · 1 · 20 | 8 / 6 / 6 | 16.2 | 5 % | 4.90 | 5.20 | 0.39 | 0.21 / 0.18 | 0 % | 0.00 | 0.40 | 22 % / 8 % / 8 % / 8 % / 52 % | 25.90 |
| trap,kits=trap,edge=1,spiky=bamboo_stand+stone_lion | 3v3 · 1 · 20 | 8 / 7 / 5 | 16.4 | 5 % | 4.85 | 4.85 | 0.36 | 0.26 / 0.10 | 0 % | 0.00 | 0.30 | 19 % / 7 % / 7 % / 10 % / 55 % | 26.10 |
| trap,kits=trap,edge=1,spiky=bamboo_stand+stone_lion | 3v3 · 2 · 20 | 14 / 4 / 2 | 15.2 | 10 % | 4.85 | 5.15 | 0.70 | 0.47 / 0.23 | 0 % | 0.00 | 0.55 | 20 % / 14 % / 7 % / 9 % / 49 % | 25.95 |
| trap,kits=trap,edge=1,spiky=bamboo_stand+stone_lion,kinpush,push=2 | 3v3 · 1 · 20 | 7 / 11 / 2 | 16.1 | 5 % | 4.90 | 4.50 | 0.37 | 0.28 / 0.09 | 0 % | 0.00 | 0.30 | 24 % / 6 % / 5 % / 14 % / 50 % | 25.90 |
| turns=2,kits=trap,edge=1,spiky=bamboo_stand+stone_lion | 3v3 · 1 · 20 | 7 / 12 / 1 | 11.1 | 25 % | 4.40 | 14.65 | 0.84 | 0.80 / 0.04 | 0 % | 0.25 | 1.75 | 8 % / 49 % / 16 % / 5 % / 18 % | 25.05 |

**Observations** (indications; 20 battles per row):

- *The new kits alone help a little under the confirmed Surge rule:* 0.43–0.45 damage per Surge against 0.29 (seed 1), 30–35 % of battles ended before pressure against 25 %.
- *Trap Surges with these kits stay weak in bot play:* 0.36–0.70 damage per declared trap, a third to a half of it on the trap owner's side; Surge share of all damage 7–14 %; the arena share rises to 49–55 % and only 5–10 % of battles end before pressure. Collision + fall reach 8–14 %.
- *The 2-turn timer with the same kits is the strongest row measured so far:* 0.84 per Surge, Surge share 49 %, arena share 18 %.
- *Limit:* the planning bot looks two own actions ahead, not at an ally's later push or the opponent's reply, and walks its own monsters into traps. Human play is needed to judge traps; these rows only say that bots do not make them work.

**Follow-up:** T38. After this entry the user made trap Surges, board-edge damage and spiky props the standard of the Godot build and replaced the five default kits by the trap kits (see T38 and the handoff); later entries are therefore not comparable with S001–S004 row by row.

## S003 · 2026-11-12 · trap Surges and displacement payoffs (experiment switches, planning bot)

**State:** `9c1f1ed` dirty (further experiment switches and the `plan` bot are uncommitted) · content `2026-11-11.1` · kit set `6b9b5b7805d5`. 160 battles in 8 runs.

**Question:** the user wants square control with push/pull in front ([temp_todo.md](temp_todo.md) T38): do trap Surges and more displacement payoffs raise the impact, compared with the confirmed rules and the best timer of S002? All variants are **experiment switches, not rules**; `tests/battle` (131) and `tests/tools` (15) pass with the switches off.

| Variant | What changes (readings chosen for the test) |
|---|---|
| `trap` | a Surge needs monster-free squares at cast, never fires by itself and detonates when a ground monster stands on one of its squares (walk, push, pull, swap) or a prop or Mountain appears there; a walk ends on a trap square; one pending Surge per skill slot |
| `kinpush` | Beast Strikes push the target 1 square away; a Spirit Strike trades squares with one struck 1×1 monster |
| `edge=1` | a monster pushed or pulled against the board edge takes 1 collision damage |
| `spiky=bamboo_stand+stone_lion` | a monster displaced into one of these props takes 2 instead of 1 |
| `push=2` / `push=slide` | Strike and Surge pushes and pulls move up to 2 squares / until blocked; zone pushes stay 1 |
| `turns=2` | as in S002 |

Command per row: `sim.gd -- 20 3v3 1 "9c1f1ed dirty" --paired --compact --bot-a plan --bot-b plan [--variant …]`. Bot `plan` (tools/lib/sim_bots.gd): AiBrain's evaluation, but the six best first actions (and, with `trap`, up to six Surge casts) are judged together with their best second action of the same turn. It is about five times slower, hence 20 battles per row. The compact row now splits out collision + fall. Rows are pasted unchanged from the tool.

| Variant | Mode · seed · battles | Side 0 / 1 / Draw | Mean rounds | Ended before pressure | Defeats | Surges declared | Surge dmg per Surge | on enemies / own side | edge share | Leaving moves per Surge | Defeats by Surge | strike / surge / ground / collision+fall / arena share | total dmg |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| confirmed rules | 3v3 · 1 · 20 | 1 / 18 / 1 | 13.7 | 25 % | 4.60 | 19.65 | 0.29 | 0.28 / 0.01 | 0 % | 0.49 | 0.75 | 23 % / 23 % / 15 % / 5 % / 28 % | 24.95 |
| turns=2 | 3v3 · 1 · 20 | 8 / 11 / 1 | 12.3 | 35 % | 4.60 | 16.60 | 0.63 | 0.57 / 0.06 | 0 % | 0.24 | 1.35 | 14 % / 39 % / 10 % / 2 % / 31 % | 26.55 |
| trap | 3v3 · 1 · 20 | 7 / 8 / 5 | 15.8 | 10 % | 4.95 | 6.20 | 0.15 | 0.08 / 0.07 | 0 % | 0.00 | 0.30 | 26 % / 4 % / 15 % / 9 % / 44 % | 25.35 |
| trap,kinpush | 3v3 · 1 · 20 | 7 / 8 / 5 | 15.8 | 10 % | 4.95 | 5.80 | 0.17 | 0.11 / 0.06 | 0 % | 0.00 | 0.35 | 24 % / 4 % / 14 % / 7 % / 49 % | 25.55 |
| kinpush,edge=1,spiky=bamboo_stand+stone_lion | 3v3 · 1 · 20 | 3 / 17 / 0 | 13.1 | 30 % | 4.60 | 19.45 | 0.30 | 0.29 / 0.01 | 0 % | 0.52 | 0.75 | 26 % / 23 % / 14 % / 6 % / 25 % | 25.10 |
| trap,kinpush,edge=1,spiky=bamboo_stand+stone_lion,push=2 | 3v3 · 1 · 20 | 8 / 8 / 4 | 16.0 | 10 % | 4.80 | 5.65 | 0.19 | 0.11 / 0.08 | 0 % | 0.00 | 0.35 | 24 % / 4 % / 11 % / 9 % / 50 % | 25.45 |
| trap,kinpush,edge=1,spiky=bamboo_stand+stone_lion,push=slide | 3v3 · 1 · 20 | 8 / 8 / 4 | 16.4 | 10 % | 4.80 | 5.75 | 0.18 | 0.10 / 0.08 | 0 % | 0.00 | 0.35 | 23 % / 4 % / 11 % / 10 % / 50 % | 25.50 |
| turns=2,kinpush,edge=1,spiky=bamboo_stand+stone_lion,push=2 | 3v3 · 1 · 20 | 10 / 9 / 1 | 12.6 | 25 % | 4.65 | 16.90 | 0.55 | 0.49 / 0.06 | 0 % | 0.28 | 0.95 | 18 % / 34 % / 13 % / 5 % / 25 % | 27.00 |

**Observations** (indications; 20 battles per row, so differences of a few points are noise):

- *Traps hardly ever catch anyone with these bots:* 0.15–0.19 damage per declared trap, almost half of it on the trap owner's side; Surge share of all damage 4 %; the arena share rises to 44–50 % and only 10 % of battles end before pressure. A hand-built case confirms that the mechanic itself works (trap behind an enemy for 1 AP, Beast Strike pushes it in for 2 AP: 2 + 3 damage in one turn).
- *Why the bots do not use it:* the combination needs 3 AP and a pushing Strike in the same kit (two Beasts, two Scaled among nine kits); the test kits hold no skill made for pushing into a trap; the bots do not look at the opponent's reply or at an ally's later push; and traps are sprung empty by `raise_ground` and props.
- *Displacement payoffs alone change little:* `kinpush` + `edge` + `spiky` moves collision + fall from 5 % to 6 % of all damage; with `push=2` or `push=slide` 9–10 %. The bots push when it pays at once, but few pushes exist in the kits.
- *The timer stays the only variant with a clear effect:* `turns=2` gives 0.63 against 0.29 per Surge with the same planning bot, a Surge share of 39 % against 23 % and 35 % against 25 % of battles ended before pressure.
- *Side lead:* with the planning bot side 1 won 18 of 20 battles under the confirmed rules (17 of 20 with the displacement payoffs); the timer and trap rows are even. Too few battles to judge, but in line with the second-side lead of S001/S002.

**Follow-up:** T38 (the trap and displacement direction needs kits built for it and human play before it can be judged; the bots cannot show its value), T13 (bot quality, second-side lead). No rule, price or kit was changed.

## S002 · 2026-11-12 · Surge variants (experiment switches)

**State:** `9c1f1ed` dirty (experiment switches in `godot/battle/core/battle_experiment.gd` and the `sim.gd` options below are uncommitted) · content `2026-11-11.1` · kit set `6b9b5b7805d5` (runs with `--shield-once` change the repetition of the shield zone skills in memory, so their kit set differs). 2320 battles in 49 runs.

**Question:** S001 showed 0.36–0.65 damage per declared Surge. Which change to the Surge raises its impact? The variants are **experiment switches, not rules**; every default reproduces the confirmed rules, and `tests/battle` (131) and `tests/tools` (15) pass with the switches off.

| Variant | What changes (everything else as in the GDDs) |
|---|---|
| confirmed rules | nothing; a Surge fires at its caster's next queue entry |
| `turns=N` | a Surge fires after N finished turns of any monster following the cast turn, between two turns |
| `turns=alive-K` | as above with N = living monsters at cast − K (minimum 1) |
| `splash=1` / `splash=1d` | monsters on the orthogonal / all eight neighbours of the footprint take 1 Surge damage (reduced like Surge damage); no residue there |
| `grow` | the footprint also covers its orthogonal neighbours, with full damage and residue |
| `line` | every anchored Surge is a straight line from the square next to the caster to the board edge; a prop stops it |
| `hold=N` | the caster detonates the Surge by a free action in a later turn; it fires by itself at the caster's entry after N rounds; one pending Surge per skill slot |
| `shield-once` | test change of content: every shield zone skill is once per global round |
| `pressure +4` | late-round pressure starts four rounds later |

Command per row: `sim.gd -- <battles> <mode> <seed> "9c1f1ed dirty" --paired --compact [--variant …] [--shield-once] [--pressure 4]`. `--paired` starts battle *i* of every run from the same seed-derived state, so all variants play the same teams and boards. Seeded draft boards, random teams without repeats, no tamer skills, `AiBrain` on both sides. Rows are pasted unchanged from the tool.

| Variant | Mode · seed · battles | Side 0 / 1 / Draw | Mean rounds | Ended before pressure | Defeats | Surges declared | Surge dmg per Surge | on enemies / own side | edge share | Leaving moves per Surge | Defeats by Surge | strike / surge / ground / arena share | total dmg |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| confirmed rules | 3v3 · 1 · 40 | 11 / 25 / 4 | 15.2 | 13 % | 4.78 | 13.20 | 0.31 | 0.30 / 0.01 | 0 % | 0.64 | 0.50 | 23 % / 16 % / 14 % / 38 % | 26.40 |
| confirmed rules | 3v3 · 2 · 40 | 19 / 19 / 2 | 13.3 | 28 % | 4.42 | 10.38 | 0.49 | 0.46 / 0.03 | 0 % | 0.66 | 0.62 | 25 % / 20 % / 11 % / 36 % | 24.80 |
| shield-once | 3v3 · 1 · 40 | 14 / 24 / 2 | 14.9 | 10 % | 4.53 | 13.20 | 0.40 | 0.37 / 0.03 | 0 % | 0.61 | 0.70 | 25 % / 20 % / 13 % / 34 % | 25.93 |
| shield-once | 3v3 · 2 · 40 | 18 / 21 / 1 | 13.0 | 30 % | 4.45 | 10.82 | 0.49 | 0.44 / 0.04 | 0 % | 0.67 | 0.72 | 28 % / 22 % / 15 % / 28 % | 24.25 |
| pressure +4 | 3v3 · 1 · 40 | 11 / 25 / 4 | 18.4 | 15 % | 4.75 | 13.75 | 0.30 | 0.29 / 0.01 | 0 % | 0.63 | 0.50 | 25 % / 16 % / 13 % / 37 % | 26.25 |
| pressure +4 | 3v3 · 2 · 40 | 19 / 19 / 2 | 15.7 | 33 % | 4.42 | 10.68 | 0.47 | 0.45 / 0.03 | 0 % | 0.64 | 0.62 | 26 % / 20 % / 11 % / 35 % | 24.77 |
| shield-once + pressure +4 | 3v3 · 1 · 40 | 15 / 23 / 2 | 18.1 | 13 % | 4.53 | 14.57 | 0.37 | 0.34 / 0.03 | 0 % | 0.61 | 0.70 | 25 % / 21 % / 13 % / 33 % | 25.77 |
| shield-once + pressure +4 | 3v3 · 2 · 40 | 18 / 21 / 1 | 15.3 | 35 % | 4.45 | 10.68 | 0.49 | 0.44 / 0.04 | 0 % | 0.67 | 0.72 | 27 % / 21 % / 14 % / 30 % | 24.38 |
| turns=1 | 3v3 · 1 · 40 | 15 / 23 / 2 | 11.6 | 33 % | 4.40 | 13.32 | 0.92 | 0.88 / 0.05 | 0 % | 0.21 | 1.60 | 14 % / 48 % / 11 % / 21 % | 25.82 |
| turns=1 | 3v3 · 2 · 40 | 18 / 21 / 1 | 11.6 | 33 % | 4.45 | 10.15 | 1.21 | 1.14 / 0.07 | 0 % | 0.19 | 1.43 | 8 % / 49 % / 10 % / 25 % | 25.20 |
| turns=2 | 3v3 · 1 · 40 | 11 / 26 / 3 | 12.4 | 33 % | 4.50 | 11.18 | 0.84 | 0.80 / 0.03 | 0 % | 0.33 | 1.18 | 16 % / 36 % / 10 % / 28 % | 25.73 |
| turns=2 | 3v3 · 2 · 40 | 14 / 23 / 3 | 12.7 | 33 % | 4.60 | 10.05 | 0.93 | 0.89 / 0.04 | 0 % | 0.36 | 1.00 | 15 % / 36 % / 13 % / 28 % | 25.98 |
| turns=3 | 3v3 · 1 · 40 | 9 / 26 / 5 | 14.0 | 15 % | 4.67 | 10.90 | 0.64 | 0.63 / 0.01 | 0 % | 0.50 | 0.75 | 19 % / 27 % / 13 % / 32 % | 25.73 |
| turns=3 | 3v3 · 2 · 40 | 17 / 19 / 4 | 14.0 | 18 % | 4.58 | 10.60 | 0.66 | 0.63 / 0.02 | 0 % | 0.49 | 0.70 | 17 % / 28 % / 14 % / 33 % | 25.18 |
| turns=alive-1 | 3v3 · 1 · 40 | 15 / 21 / 4 | 14.9 | 18 % | 4.67 | 10.25 | 0.43 | 0.42 / 0.01 | 0 % | 0.61 | 0.62 | 22 % / 17 % / 12 % / 40 % | 26.40 |
| turns=alive-1 | 3v3 · 2 · 40 | 18 / 20 / 2 | 13.7 | 18 % | 4.50 | 9.82 | 0.45 | 0.41 / 0.03 | 0 % | 0.62 | 0.70 | 26 % / 17 % / 12 % / 37 % | 25.07 |
| turns=alive-3 | 3v3 · 1 · 40 | 9 / 25 / 6 | 13.5 | 23 % | 4.75 | 11.75 | 0.83 | 0.81 / 0.02 | 0 % | 0.31 | 1.32 | 15 % / 37 % / 10 % / 30 % | 26.38 |
| turns=alive-3 | 3v3 · 2 · 40 | 20 / 20 / 0 | 11.8 | 33 % | 4.45 | 9.70 | 0.96 | 0.91 / 0.04 | 0 % | 0.33 | 0.97 | 15 % / 38 % / 12 % / 27 % | 24.73 |
| turns=alive-4 | 3v3 · 1 · 40 | 10 / 26 / 4 | 11.2 | 38 % | 4.42 | 12.03 | 0.94 | 0.90 / 0.04 | 0 % | 0.22 | 1.35 | 13 % / 45 % / 10 % / 23 % | 25.12 |
| splash=1 | 3v3 · 1 · 40 | 9 / 29 / 2 | 14.6 | 15 % | 4.40 | 20.88 | 0.47 | 0.42 / 0.05 | 67 % | 0.43 | 1.43 | 17 % / 40 % / 9 % / 30 % | 24.98 |
| splash=1 | 3v3 · 2 · 40 | 17 / 21 / 2 | 15.6 | 8 % | 4.53 | 19.38 | 0.43 | 0.38 / 0.05 | 67 % | 0.48 | 1.30 | 19 % / 33 % / 15 % / 30 % | 25.02 |
| splash=1d | 3v3 · 1 · 40 | 10 / 25 / 5 | 14.7 | 13 % | 4.60 | 22.18 | 0.53 | 0.49 / 0.04 | 76 % | 0.43 | 1.80 | 17 % / 47 % / 8 % / 23 % | 25.05 |
| splash=1d | 3v3 · 2 · 40 | 20 / 20 / 0 | 14.2 | 15 % | 4.28 | 20.98 | 0.57 | 0.49 / 0.08 | 74 % | 0.41 | 1.75 | 18 % / 49 % / 7 % / 23 % | 24.23 |
| grow | 3v3 · 1 · 40 | 13 / 21 / 6 | 14.8 | 15 % | 4.83 | 9.45 | 0.77 | 0.66 / 0.11 | 0 % | 0.42 | 1.23 | 15 % / 27 % / 15 % / 35 % | 26.40 |
| grow | 3v3 · 2 · 40 | 19 / 16 / 5 | 14.8 | 18 % | 4.65 | 9.00 | 0.69 | 0.58 / 0.11 | 0 % | 0.48 | 0.85 | 13 % / 24 % / 16 % / 40 % | 25.95 |
| line | 3v3 · 1 · 40 | 24 / 14 / 2 | 15.4 | 10 % | 4.70 | 6.80 | 0.48 | 0.45 / 0.03 | 0 % | 0.65 | 0.35 | 28 % / 12 % / 12 % / 42 % | 26.48 |
| line | 3v3 · 2 · 40 | 20 / 13 / 7 | 15.6 | 10 % | 4.97 | 7.12 | 0.55 | 0.54 / 0.01 | 0 % | 0.70 | 0.53 | 25 % / 14 % / 12 % / 43 % | 27.12 |
| hold=2 | 3v3 · 1 · 40 | 11 / 22 / 7 | 14.8 | 15 % | 4.78 | 8.47 | 0.44 | 0.43 / 0.01 | 0 % | 0.74 | 0.50 | 30 % / 14 % / 11 % / 35 % | 26.55 |
| hold=2 | 3v3 · 2 · 40 | 17 / 20 / 3 | 14.9 | 8 % | 4.70 | 8.93 | 0.50 | 0.49 / 0.01 | 0 % | 0.72 | 0.60 | 30 % / 17 % / 11 % / 34 % | 25.95 |
| hold=3 | 3v3 · 1 · 40 | 14 / 20 / 6 | 14.9 | 15 % | 4.67 | 7.97 | 0.49 | 0.48 / 0.01 | 0 % | 0.73 | 0.47 | 31 % / 15 % / 12 % / 33 % | 26.62 |
| hold=3 | 3v3 · 2 · 40 | 17 / 21 / 2 | 14.9 | 8 % | 4.70 | 7.70 | 0.55 | 0.53 / 0.02 | 0 % | 0.74 | 0.50 | 31 % / 16 % / 10 % / 34 % | 26.30 |
| turns=3,splash=1 | 3v3 · 1 · 40 | 16 / 24 / 0 | 13.2 | 23 % | 4.20 | 19.38 | 0.63 | 0.58 / 0.05 | 55 % | 0.36 | 1.55 | 11 % / 49 % / 9 % / 26 % | 24.70 |
| turns=3,splash=1 | 3v3 · 2 · 40 | 16 / 20 / 4 | 14.9 | 15 % | 4.58 | 18.88 | 0.58 | 0.51 / 0.07 | 49 % | 0.42 | 1.30 | 10 % / 42 % / 9 % / 35 % | 25.75 |
| turns=2,splash=1 | 3v3 · 1 · 40 | 10 / 23 / 7 | 12.7 | 28 % | 4.62 | 21.60 | 0.69 | 0.63 / 0.07 | 58 % | 0.30 | 1.98 | 8 % / 59 % / 9 % / 20 % | 25.55 |
| turns=2 + shield-once | 3v3 · 1 · 40 | 11 / 26 / 3 | 13.5 | 18 % | 4.65 | 10.95 | 0.89 | 0.82 / 0.07 | 0 % | 0.35 | 1.20 | 16 % / 37 % / 9 % / 30 % | 26.55 |
| turns=3 + shield-once + pressure +4 | 3v3 · 1 · 40 | 12 / 27 / 1 | 17.5 | 23 % | 4.67 | 11.97 | 0.60 | 0.56 / 0.04 | 0 % | 0.49 | 0.88 | 18 % / 27 % / 12 % / 35 % | 26.32 |
| turns=3 + shield-once + pressure +4 | 3v3 · 2 · 40 | 16 / 18 / 6 | 17.2 | 25 % | 4.62 | 9.22 | 0.78 | 0.75 / 0.04 | 0 % | 0.53 | 0.68 | 16 % / 29 % / 11 % / 36 % | 25.12 |
| splash=1 + shield-once + pressure +4 | 3v3 · 1 · 40 | 11 / 26 / 3 | 17.6 | 25 % | 4.45 | 24.77 | 0.41 | 0.36 / 0.05 | 68 % | 0.45 | 1.52 | 17 % / 41 % / 11 % / 26 % | 25.05 |
| splash=1 + shield-once + pressure +4 | 3v3 · 2 · 40 | 15 / 20 / 5 | 18.6 | 15 % | 4.78 | 19.98 | 0.46 | 0.40 / 0.06 | 68 % | 0.46 | 1.38 | 18 % / 35 % / 12 % / 32 % | 26.20 |
| confirmed rules | 2v2 · 1 · 60 | 20 / 37 / 3 | 9.6 | 50 % | 2.68 | 7.73 | 0.44 | 0.42 / 0.02 | 0 % | 0.67 | 0.67 | 33 % / 22 % / 11 % / 30 % | 15.42 |
| turns=1 | 2v2 · 1 · 60 | 26 / 33 / 1 | 8.4 | 53 % | 2.62 | 7.05 | 0.84 | 0.79 / 0.05 | 0 % | 0.33 | 0.85 | 19 % / 41 % / 10 % / 25 % | 14.50 |
| turns=2 | 2v2 · 1 · 60 | 21 / 38 / 1 | 9.6 | 43 % | 2.68 | 7.43 | 0.59 | 0.58 / 0.01 | 0 % | 0.51 | 0.77 | 28 % / 28 % / 11 % / 28 % | 15.37 |
| turns=alive-2 | 2v2 · 1 · 60 | 25 / 34 / 1 | 8.5 | 57 % | 2.68 | 7.35 | 0.68 | 0.66 / 0.02 | 0 % | 0.40 | 0.87 | 27 % / 33 % / 10 % / 25 % | 15.02 |
| splash=1 | 2v2 · 1 · 60 | 23 / 37 / 0 | 10.0 | 40 % | 2.58 | 12.67 | 0.45 | 0.38 / 0.07 | 65 % | 0.36 | 1.00 | 22 % / 39 % / 11 % / 25 % | 14.82 |
| grow | 2v2 · 1 · 60 | 24 / 33 / 3 | 9.2 | 50 % | 2.60 | 5.22 | 0.72 | 0.63 / 0.09 | 0 % | 0.42 | 0.60 | 23 % / 27 % / 15 % / 31 % | 14.03 |
| confirmed rules | 1v1 · 1 · 100 | 41 / 54 / 5 | 5.6 | 72 % | 1.05 | 1.93 | 0.61 | 0.59 / 0.02 | 0 % | 0.62 | 0.19 | 46 % / 18 % / 5 % / 26 % | 6.58 |
| turns=1 | 1v1 · 1 · 100 | 38 / 57 / 5 | 5.8 | 70 % | 1.05 | 2.04 | 0.57 | 0.54 / 0.03 | 0 % | 0.61 | 0.19 | 44 % / 18 % / 6 % / 27 % | 6.64 |
| splash=1 | 1v1 · 1 · 100 | 37 / 57 / 6 | 6.6 | 62 % | 1.06 | 3.35 | 0.52 | 0.47 / 0.05 | 54 % | 0.36 | 0.31 | 34 % / 26 % / 7 % / 29 % | 6.67 |
| grow | 1v1 · 1 · 100 | 38 / 58 / 4 | 6.1 | 67 % | 1.04 | 2.41 | 0.76 | 0.64 / 0.12 | 0 % | 0.27 | 0.31 | 26 % / 28 % / 9 % / 34 % | 6.50 |

| Column | Meaning |
|---|---|
| Ended before pressure | share of battles decided no later than the round in which late-round pressure starts |
| Defeats / Surges declared / total dmg | per battle |
| on enemies / own side | Surge damage per declared Surge, split by the side of the monster hit |
| edge share | share of Surge damage dealt on the neighbouring squares (`splash`) |
| Leaving moves per Surge | moves that start on a square threatened by a pending Surge and end outside it, per declared Surge (each costs 2 AP) |
| Defeats by Surge | defeats per battle whose last damage was Surge damage |

**Observations** (indications; one naive bot, test kits; rows of one variant differ between seeds by up to about 0.2 damage per Surge):

- *Timing is the strongest lever:* in 3v3 the confirmed rules give 0.31–0.49 damage per Surge; `turns=1` 0.92–1.21, `turns=2` 0.84–0.93, `turns=alive-3` 0.83–0.96, `turns=alive-4` 0.94, `turns=3` 0.64–0.66. The Surge share of all damage rises from 16–20 % to 36–49 %, the arena share falls from 36–38 % to 21–30 %, and leaving moves fall from 0.64–0.66 to 0.19–0.36 per Surge. `turns=alive-1` (0.43–0.45) behaves like the confirmed rules. 2v2 shows the same order (0.44 → 0.84 with `turns=1`, 0.68 with `turns=alive-2`).
- *Bias to keep in mind:* with a timer the bot knows when a target cannot act before the detonation and weighs that hit higher (`AiBrain._threat_weight`); under the confirmed rules it has no such knowledge. Part of the gain is this bot knowledge.
- *1v1 is unaffected by timers:* `turns=1` equals the confirmed rules there (0.57 against 0.61), because the one opponent always acts in between.
- *Edge damage adds volume, not decisions:* `splash=1` keeps damage per Surge at 0.43–0.47 but the bot declares 19–21 Surges per battle instead of 10–13; about two thirds of Surge damage is edge damage; the share of battles ended before pressure does not rise (8–15 % against 13–28 %).
- *Larger footprint:* `grow` gives 0.69–0.77 per Surge, with the highest damage to the own side (0.11 per Surge) and no fewer collapse endings (arena 35–40 %).
- *Line and held Surges show nothing with this bot:* `line` 0.48–0.55 with the arena share at 42–43 %; `hold` 0.44–0.55. The bot does not plan a push into a held Surge, so `hold` is not judged by these rows.
- *Shield limit and later pressure alone change little:* 0.40–0.49 and 0.30–0.47 per Surge; later pressure lengthens battles (15.7–18.4 rounds) without making them more decisive.
- *Second side ahead in 3v3 in every variant* (for example 30 to 44 under the confirmed rules), as in S001.

**Follow-up:** T38 (Surge impact decision), T13 (bot that plans pushes; human play), T04 (second-side lead in 3v3) in [temp_todo.md](temp_todo.md). No rule, price or kit was changed.

## S001 · 2026-11-11 · first runs after the battle rewrite

**State:** `594b068` dirty (the whole battle rewrite is uncommitted) · content `2026-11-11.1` · kit set `c0610a49270f`. 260 battles in four runs.

#### Run · 3v3 · seed 1 · 60 battles

| Field | Value |
|---|---|
| State | 594b068 dirty · content `2026-11-11.1` · kit set `c0610a49270f` |
| Command | `sim.gd -- 60 3v3 1` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `c0610a49270f` |
| Props placed | bronze_gong 0.60, banner 0.57, wardstone 0.53, bamboo_stand 0.47, ancestor_tablet 0.37, clay_urn 0.37, pagoda_column 0.37, shrine 0.37, stone_lion 0.37, paper_lantern 0.33, peach_tree 0.33, totem 0.33 (per battle) |
| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 60 | 20 / 37 / 3 / 0 | 13.8 | 4.48 | 2.63 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | total |
|---|---|---|---|---|---|---|---|---|---|
| share | 23 % | 19 % | 11 % | 3 % | 1 % | 2 % | 2 % | 39 % | 100 % |
| per battle | 5.73 | 4.68 | 2.78 | 0.65 | 0.37 | 0.42 | 0.42 | 9.82 | 24.87 |

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 656 | 0.43 | 188 | 1.83 | 1680 |

| Monster | Played | Win rate |
|---|---|---|
| moss_turtle | 34 | 71 % |
| hollow_serpent | 38 | 66 % |
| forge_golem | 42 | 55 % |
| thorn_mites | 39 | 51 % |
| gloom_wolf | 46 | 46 % |
| blaze_tiger | 35 | 43 % |
| dusk_moth | 43 | 40 % |
| ember_hawk | 40 | 33 % |
| grove_wisp | 43 | 30 % |

Skill uses per battle: bark_veil 9.32, shade_veil 9.10, Step 5.95, mire 3.58, strike_jab 3.13, Glide 2.62, Run 2.22, raise_ground 2.22, bramble_tide 2.13, gloom_rift 1.83, lava_field 1.82, spring_burst 1.57, tidal_shell 1.53, coiling_rift 1.52, Phase 1.38, Leap 1.25, eclipse 1.25, Burrow 1.17, cinder_dive 0.83, thornbed 0.68, void_pull 0.68, shockwave 0.43, magma_pounce 0.23, gale 0.17, crucible 0.03

#### Run · 3v3 · seed 2 · 60 battles

| Field | Value |
|---|---|
| State | 594b068 dirty · content `2026-11-11.1` · kit set `c0610a49270f` |
| Command | `sim.gd -- 60 3v3 2` |
| Setup | 3v3 on 7×7, late-round pressure from round 8, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `c0610a49270f` |
| Props placed | bamboo_stand 0.63, stone_lion 0.60, paper_lantern 0.57, ancestor_tablet 0.50, bronze_gong 0.50, pagoda_column 0.43, shrine 0.40, totem 0.40, banner 0.37, wardstone 0.27, peach_tree 0.23, clay_urn 0.20 (per battle) |
| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 60 | 22 / 32 / 6 / 0 | 15.4 | 4.68 | 2.92 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | total |
|---|---|---|---|---|---|---|---|---|---|
| share | 20 % | 17 % | 13 % | 2 % | 1 % | 2 % | 1 % | 44 % | 100 % |
| per battle | 5.23 | 4.38 | 3.28 | 0.50 | 0.28 | 0.58 | 0.32 | 11.50 | 26.08 |

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 722 | 0.36 | 167 | 1.88 | 1749 |

| Monster | Played | Win rate |
|---|---|---|
| moss_turtle | 38 | 66 % |
| hollow_serpent | 41 | 63 % |
| forge_golem | 43 | 58 % |
| blaze_tiger | 35 | 54 % |
| ember_hawk | 40 | 43 % |
| grove_wisp | 38 | 39 % |
| dusk_moth | 38 | 37 % |
| gloom_wolf | 43 | 30 % |
| thorn_mites | 44 | 18 % |

Skill uses per battle: bark_veil 12.33, shade_veil 7.48, Step 6.63, mire 3.60, bramble_tide 2.97, strike_jab 2.78, Glide 2.45, raise_ground 2.28, gloom_rift 2.07, Run 2.03, tidal_shell 1.98, spring_burst 1.63, Burrow 1.57, lava_field 1.53, coiling_rift 1.35, Leap 1.22, Phase 1.07, eclipse 1.02, void_pull 0.78, cinder_dive 0.57, shockwave 0.52, magma_pounce 0.42, thornbed 0.40, gale 0.22, crucible 0.03

#### Run · 1v1 · seed 1 · 100 battles

| Field | Value |
|---|---|
| State | 594b068 dirty · content `2026-11-11.1` · kit set `c0610a49270f` |
| Command | `sim.gd -- 100 1v1 1` |
| Setup | 1v1 on 5×5, late-round pressure from round 6, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `c0610a49270f` |
| Props placed | bronze_gong 0.26, clay_urn 0.20, peach_tree 0.20, shrine 0.20, stone_lion 0.20, pagoda_column 0.18, bamboo_stand 0.16, ancestor_tablet 0.14, banner 0.14, totem 0.12, paper_lantern 0.10, wardstone 0.10 (per battle) |
| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 100 | 50 / 42 / 8 / 0 | 7.0 | 1.08 | 0.17 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | total |
|---|---|---|---|---|---|---|---|---|---|
| share | 34 % | 13 % | 5 % | 2 % | 1 % | 0 % | 0 % | 44 % | 100 % |
| per battle | 2.46 | 0.92 | 0.34 | 0.15 | 0.09 | 0.01 | 0.02 | 3.18 | 7.17 |

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 142 | 0.65 | 125 | 1.97 | 493 |

| Monster | Played | Win rate |
|---|---|---|
| moss_turtle | 23 | 74 % |
| forge_golem | 30 | 63 % |
| hollow_serpent | 21 | 62 % |
| thorn_mites | 18 | 56 % |
| gloom_wolf | 23 | 43 % |
| ember_hawk | 22 | 36 % |
| blaze_tiger | 17 | 29 % |
| dusk_moth | 21 | 24 % |
| grove_wisp | 25 | 20 % |

Skill uses per battle: bark_veil 2.02, shade_veil 1.56, strike_jab 1.25, Glide 0.75, Step 0.61, mire 0.61, Phase 0.53, Run 0.51, spring_burst 0.45, gloom_rift 0.44, raise_ground 0.43, Leap 0.23, coiling_rift 0.19, tidal_shell 0.17, Burrow 0.14, shockwave 0.10, gale 0.09, lava_field 0.09, cinder_dive 0.06, bramble_tide 0.05, eclipse 0.04, void_pull 0.03, magma_pounce 0.02

#### Run · 2v2 · seed 1 · 40 battles

| Field | Value |
|---|---|
| State | 594b068 dirty · content `2026-11-11.1` · kit set `c0610a49270f` |
| Command | `sim.gd -- 40 2v2 1` |
| Setup | 2v2 on 6×6, late-round pressure from round 7, seeded draft boards, random teams without repeats |
| Units | random teams from kit set `c0610a49270f` |
| Props placed | pagoda_column 0.40, bamboo_stand 0.35, paper_lantern 0.35, peach_tree 0.30, totem 0.30, clay_urn 0.25, ancestor_tablet 0.20, bronze_gong 0.20, wardstone 0.15, banner 0.10, shrine 0.10, stone_lion 0.10 (per battle) |
| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |
| Not covered | 2×2 and air units, tamer skills, human play |

| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |
|---|---|---|---|---|
| 40 | 19 / 20 / 1 / 0 | 8.8 | 2.73 | 1.30 |

| Damage | strike | surge | ground | collision | fall | collapse | aftermath | arena | total |
|---|---|---|---|---|---|---|---|---|---|
| share | 38 % | 23 % | 12 % | 1 % | 0 % | 1 % | 2 % | 22 % | 100 % |
| per battle | 5.75 | 3.52 | 1.88 | 0.17 | 0.07 | 0.17 | 0.33 | 3.30 | 15.20 |

| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |
|---|---|---|---|---|
| 316 | 0.45 | 117 | 1.97 | 409 |

| Monster | Played | Win rate |
|---|---|---|
| gloom_wolf | 17 | 76 % |
| moss_turtle | 17 | 71 % |
| hollow_serpent | 14 | 64 % |
| blaze_tiger | 15 | 60 % |
| forge_golem | 15 | 47 % |
| thorn_mites | 26 | 46 % |
| ember_hawk | 15 | 33 % |
| dusk_moth | 17 | 29 % |
| grove_wisp | 24 | 25 % |

Skill uses per battle: Step 4.53, bark_veil 3.38, strike_jab 2.92, shade_veil 2.45, mire 2.25, bramble_tide 2.05, Glide 1.88, tidal_shell 1.62, spring_burst 1.38, Run 1.27, Phase 1.18, gloom_rift 1.12, Burrow 0.95, raise_ground 0.90, coiling_rift 0.72, Leap 0.60, lava_field 0.42, cinder_dive 0.33, eclipse 0.30, magma_pounce 0.25, shockwave 0.25, gale 0.23, void_pull 0.23, crucible 0.12, thornbed 0.12

**Observations** (indications; single-species win rates are noisy, e.g. `thorn_mites` 51 % against 18 % between the two 3v3 seeds; only patterns that repeat across all four runs are listed):

- *Late-round pressure decides most battles:* `arena` is the largest damage source in 3v3 (39–44 %) and 1v1 (44 %), and battles end shortly after the pressure starts (1v1 round 6, mean 7.0; 3v3 round 8, mean 13.8–15.4). The historical v6.0 figure was about 1 battle in 5.
- *Surges rarely hit:* 0.36–0.65 damage per declared Surge at 2–3 nominal damage; Strikes deal more total damage than Surges in every run. The AI never combines pull or slow with a Surge, so this may be the bot rather than the rule.
- *High HP beats high initiative:* `moss_turtle` 66–74 %, `hollow_serpent` 62–66 %, `forge_golem` 47–63 %; `grove_wisp` 20–39 %, `dusk_moth` 24–40 %, `ember_hawk` 33–43 %. Consistent with collapse-decided endings.
- *Second side ahead in 3v3:* 69 to 42 over 120 battles; not visible in 1v1 or 2v2.
- *Shield zones dominate the action count:* `bark_veil` and `shade_veil` are the most used skills in 3v3 (7–12 uses per battle each), far ahead of any Surge. Repeated 1-AP protection casts are an existing T13 check item.
- *Props:* about 2.6–2.9 destroyed per 3v3 battle, aftermath damage about 1–2 % of all damage.

**Follow-up:** T13 (late-round pressure share, Surge hit rate with a better bot or human play, protection-zone recasting, first/second side in 3v3), T03 (HP against initiative, only after the pressure question), T04 reading I10/I15 in [temp_todo.md](temp_todo.md#implementation) (which squares convert, start rounds).
