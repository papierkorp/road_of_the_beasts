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

**Kit set `6e152c78b752`** (content `2026-11-13.1`): stats and kits of `f4086ae48783`; the movement skills other than Run cover the full Movement stat and cost 2 AP (Glide, Burrow, Blink, Leap, Phase, Quake Leap, Headbutt; S016 Part D).

**Kit set `f4086ae48783`** (content `2026-11-13.1`; HP/Init/Move/TPR/Reach/AP: slots): the kits of `164984ea835f` with the stats of the draft prices of 2026-11-13 (S015 set C).

- blaze_tiger 7/7/5/1/2/3 · dusk_moth 5/7/3/1/4/3 · ember_hawk 5/9/5/2/2/3 · forge_golem 8/5/1/1/3/3 · gloom_wolf 6/9/3/1/3/3 · grove_wisp 5/9/5/1/3/3 · hollow_serpent 7/5/3/1/3/3 · moss_turtle 8/3/2/1/3/3 · thorn_mites 6/3/3/2/3/3

# Entries

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
