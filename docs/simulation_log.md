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

# Entries

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
