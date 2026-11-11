# Simulation Log — Road of the Beasts

Dated record of AI-vs-AI simulation runs of the Godot battle (`godot/tools/sim.gd`), kept as a series so that later states can be compared with earlier ones. Design rules live in the GDDs, open questions in [temp_todo.md](temp_todo.md); this file holds measurements only.

## Usage

- **Indications, not validation:** every run uses a naive one-step AI on unapproved test content and no human play. No entry approves a rule, price, kit or balance value; a change needs a decision under the task named in the entry.
- **Append only:** newest entry first; an existing entry is never edited except to fix a transcription error. A rerun on a newer state is a new entry.
- **One entry = one session on one code state.** It may hold several run blocks (modes, seeds). IDs `S001`, `S002`, … are never reused.
- **Reproducibility:** a run is fully determined by code state, content, mode, battle count and seed. Commit before a run where possible; `dirty` marks uncommitted changes, in which case the commit hash alone does not identify the state.
- **Kit sets:** the units of a run are named by the short content fingerprint printed by the tool. Each fingerprint is listed once under [Kit Sets](#kit-sets).

## Entry Format

```text
## S000 · YYYY-MM-DD · short title
State:        <commit> [dirty] · content version · kit set fingerprint
Runs:         one block per run, pasted unchanged from the tool
Observations: 3–6 bullets, worded as indications; say what is noise
Follow-up:    task ids the observations concern; never a rule change here
```

Command per run block (the tool prints the block in this format):

```sh
godot --headless --path godot -s res://tools/sim.gd -- <battles> <mode> <seed> "$(git rev-parse --short HEAD) [dirty]" [kits]
```

| Value in a run block | Meaning |
|---|---|
| Side 0 / side 1 | side 0 holds the player's start area; teams are random, so the sides differ only by position and tie rules |
| Draw / timeout | both sides fell in one resolution / no result after 600 turns |
| Damage share, per battle | damage dealt to monsters by source: `strike`, `surge`, `ground` (hazard ground and Voidscar), `collision`, `fall`, `collapse` (Mountain), `aftermath` (props), `arena` (late-round collapse of the whole board) |
| Surge damage per Surge | Surge damage ÷ declared Surges (nominal 2–3 per struck monster) |
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

# Entries

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
