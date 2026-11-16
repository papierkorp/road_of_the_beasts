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
Runs:         one block per run, pasted unchanged from the tool; every result row states the mean rounds
              and how many battles ended in under 3 and in over 5 rounds (user instruction 2026-11-15;
              length target: a mean of 3.0–4.9 rounds)
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

Kit sets of the entries below (S019 and later). Entries S001–S018 measured rules that no longer exist (Surges, height, marker traps) and were removed; Git keeps them.

**Kit set `230e32c911cc`** (content `2026-11-13.1`): the reshaped build without Surges and traps: 26 skills on the skill card, the nine kits of [content.md §5](content.md#5-the-nine-monsters), spread test stats (S019). The fingerprint of the S018 runs (reshape with Surges still in the kits) was not noted.

**Kit set `a30a9be42850`** (content `2026-11-13.1`; S020): current ten-monster pool (the nine named monsters plus the user experiment `asdf`), with more displacement in the kits and stat zones as extras. Includes the user skills `asdf`, `asdf_2`, `asdf_3` and Blaze Tiger slot 1 `new_skill`, deliberately preserved. The fingerprint identifies this content, not the earlier nine-kit set or a content approval.

**Kit set `789f3d326286`** (content `2026-11-13.1`; S028): the same ten-monster pool; each of the nine named monsters carries a fifth slot with a prop skill (Blaze Tiger Light Brazier, Dusk Moth Lay Vortex, Ember Hawk Lay Spikes, Forge Golem Earth Wall, Gloom Wolf Lay Spikes, Grove Wisp Set Thorn Idol, Hollow Serpent Lay Vortex, Moss Turtle Earth Wall, Thorn Mites Set Clay Urn). New props Earth Wall, Thorn Idol, Ember Brazier, Spike Trap, Vortex Trap; the Storm Drum pushes at the round end; Banner, Shrine, Totem and Wardstone are archived. User records unchanged. Not a content approval.

**Kit set `f564899a2ac8`** (content `2026-11-13.1`; S030): the ten-monster pool and five-skill kits of `789f3d326286` on the rules of 2026-11-15 before the shape merge. The stat Initiative is called Pace and counts 0.1 per point (asdf 1.2 · blaze_tiger 1.3 · dusk_moth 1.3 · ember_hawk 1.4 · forge_golem 1.0 · gloom_wolf 1.4 · grove_wisp 1.4 · hollow_serpent 1.2 · moss_turtle 1.1 · thorn_mites 1.1; every other stat as before), Mire drains 1 Pace point (2 from level II), and Strikes carry `strike_push`. Kit set lines of this and later states read HP/Pace/Stamina/TPR/Reach/AP.

**Kit set `953ee09679e4`** (content `2026-11-15.1`): the same pool, stats and kits after the shape merge of 2026-11-15: one shape per skill (Thrust is a Jab +1 in eight directions, Cinder Dive a Jab +2 around its user), a Strike costs the AP on its card (Shove 1 AP instead of 2), and a free shape can be arranged per monster. Used in S031.

# Entries

## S033 · 2026-11-16 · The opponent AI fights for the Dragon Veins

**State:** main, base `a93e6f7` dirty (the AI of 2026-11-16: `ai_veins`, `ai_try_all` on by default); Godot 4.7.2; the in-game kits of the ten-monster pool (fingerprint not printed by `--compact-head`). Battle suites green; the full suite has its two known non-battle failures.

**Runs:** `sim.gd -- 20 3v3 <seed> --paired --compact-head --bot-a game --bot-b game [--variant …]`, seeds 1–8 = 160 battles per row, default board 7×7 with 3 Dragon Veins, **not side-swapped**. Rows A and B partly on two cores at idle priority, row C in parallel; the speed does not change a result. Bot `game` is AiBrain as the game's opponent plays it; with `noveins` it has no lookahead, so row B is the AI before this entry.

| Row | AI | Mean rounds (mean of the 8 seeds) | Under 3 rounds | Over 5 rounds | Longest | First defeat (round) | Veins owned per round end, both sides | Vein damage share |
|---|---|---|---|---|---|---|---|---|
| A | veins + tries every skill (the new default) | 3.54 | 25 of 160 | 5 of 160 | 7 | 1.36 | 2.01 of 3 | 20–23 % |
| B | `noveins,notry` (the AI before) | 3.96 | 19 of 160 | 18 of 160 | 11 | 1.60 | 1.78 of 3 | 19–24 % |
| C | veins, `notry` | 3.46 | 34 of 160 | 11 of 160 | 9 | 1.35 | 2.07 of 3 | 17–25 % |

Per-seed mean rounds: A 4.0 / 3.5 / 3.0 / 3.5 / 3.9 / 3.4 / 3.4 / 3.6; B 4.4 / 4.0 / 3.4 / 3.5 / 4.0 / 4.7 / 4.2 / 3.5; C 3.9 / 3.5 / 3.2 / 3.2 / 3.5 / 3.3 / 3.6 / 3.5.

**Observations** (indications; bots on both sides):

- *The vein fight shortens the battles by about 0.4–0.5 rounds* (B 3.96 → A 3.54, C 3.46) and takes most of the long tail (over 5 rounds: 18 → 5 and 11 of 160; longest 11 → 7 and 9). The seeds of B are longer than those of A in 6 of 8 pairs.
- *More veins are owned at the round end* (1.78 → 2.0 of 3), and the first defeat comes earlier (round 1.6 → 1.35); the share of vein damage stays near a fifth, while Strikes take a smaller share of the damage.
- *Trying every skill changes the length little* (A 3.54 against C 3.46); with it fewer battles end under 3 rounds (25 against 34).
- Both AI rows lie in the user's "perfect" band of 3.5–4.5 or just below it (C). A human who fights the AI differently is not measured.

**Follow-up:** T13 (battle length; why the earlier series were longer), T39 (Dragon Veins). No rule was changed by this entry.

## S032 · 2026-11-16 · What the parts of a skill are worth: random kits of generated skills, a first price list and its check

**State:** main, base `f81f250` dirty; Godot 4.7.2; runs in parallel on a frozen copy of the working tree. Content fingerprint `f206e96918c5` (series 1) and `3c1b2fd9e587` (series 2, with the experiment content of T43 and the fitted price list). Full suite on the final state: 373 cases, the two known non-battle failures.

**Tool:** `godot/tools/skill_impact.gd` ([tools/README.md](../godot/tools/README.md)). 3v3 on the default board, bot `plan` on both sides with the try bonus (`ai_try_all`). Both teams field the same three species; every monster draws a kit template (so many Strikes, movements, zones, grounds, props) and gets skills generated for the battle; a kit loses 0–2 of its six skills. **Every pairing is played twice with the kits swapped between the sides.** A least-squares fit over all parts at once (ridge 1.0) reads what one unit of a part adds to the win rate; a Jab, walking and “a placed skill” are the baseline the others are read against.

| Series | AP of a skill | Extra | Battles | Side 0 won | Mean rounds | Under 3 rounds | Over 5 rounds |
|---|---|---|---|---|---|---|---|
| 1 | random 1–3 | — | 60 000 | 48.6 % | 4.40 | 5 146 (9 %) | 10 845 (18 %) |
| 2a | from the price list of series 1 | self buffs, experiment content | 15 000 | 48.4 % | 4.19 | 1 677 (11 %) | 2 269 (15 %) |
| 2b | random 1–3 | self buffs, experiment content, `stamina_base=1`, `trap_defuse=1` | 15 000 | 48.9 % | 4.94 | 533 (4 %) | 4 186 (28 %) |

**Series 1, win rate per unit of a part (points; ± one standard error):**

| Part | Win rate | ± | Used at least once | Note |
|---|---|---|---|---|
| 1 AP of cost | −2.10 | 0.04 | — | AP 1: used in 81 % of fieldings, AP 2: 61 %, AP 3: 31 % |
| 1 damage of a Strike | +3.60 | 0.16 | — | |
| push of a Strike | +2.00 | 0.22 | — | |
| a further square of a Strike, ground, zone or prop skill | −0.12 to +0.10 | 0.04–0.09 | — | no measurable value for the bots |
| a Strike at all (against a placed skill) | +1.40 | 0.38 | 56 % | |
| a movement at all | +6.19 | 0.23 | 79 % | |
| landing: pushes all neighbours | +6.23 | 0.28 | 86 % | 0.92 damage per use |
| landing: pushes the monster ahead | +1.64 | 0.28 | 83 % | |
| range above 2, per square | +0.40 | 0.07 | — | |
| path: line / free (against walking) | +0.13 / −1.00 | 0.31 | 83 % / 78 % | |
| shape: Jab +2 / Arc +1 / Jab +1 (against a Jab) | +5.32 / +4.40 / +3.27 | 0.3–0.5 | 67–72 % | |
| shape: Arc / Storm / Pincer / Whirl / Cross | +1.31 / +1.07 / −0.79 / −1.12 / −2.71 | 0.3–0.7 | 33–60 % | Cross used in 33 % |
| ground: Mossbed, Snare / Blight / Lava / Thornbed | +3.5 / +2.6 / +2.0 / +1.5 | 0.2 | 55–58 % | |
| zone: Bog, Void Pull, Gale, Shockwave / Tailwind / Slowing / Mire | +2.4 to +2.6 / +1.6 / +1.4 / +1.0 | 0.2–0.4 | 51–62 % | |
| prop: Clay Urn / Thorn Idol / Ember Brazier / Bamboo Stand | +5.3 / +4.9 / +4.7 / +4.5 | 0.34 | 55–65 % | |
| prop: the other eleven | +2.5 to +3.8 | 0.34 (traps 0.65) | 45–58 % | |
| a ground or zone left by a Strike / by a movement | −2.65 / −2.54 | 0.16 | — | worth less than the same thing placed by a skill of its own |
| use: twice a turn / once a round / once a battle (against once a turn) | +0.43 / +0.24 / −1.31 | 0.11 | — | |
| zone rounds above 1, per round | +0.18 | 0.09 | — | |

**Combinations in one kit** (points of the price list, 10 = 1 AP; on top of the parts): movement with a landing push together with a hazard +6.7 ± 1.6, with a solid prop +6.6 ± 1.4, with a pushing Strike +4.0 ± 1.9; push with a hazard +3.6 ± 1.7; hazard with a trap +3.5 ± 2.4. Below zero: push with an area Strike −4.7 ± 1.8, hazard with a solid prop −4.5 ± 1.5, hazard with an area Strike −3.2 ± 1.6, hazard with slow −3.1 ± 1.7. The other 19 pairs lie within ±2.6.

**Price list (draft, `godot/battle/defs/skill_calc.gd`):** points = 10 × win rate of the part ÷ win rate one AP takes; zero point: a Jab with 2 damage and a push is 20 points (its 2 AP). Grounds, zones, props and shapes are pulled toward the mean of their group by the share of noise in their spread. On that scale one placed square is worth 7–24 points before the offset of its kind (−30.5), so **every ground, zone and prop skill comes out below the price of 1 AP** and gets the floor of 1 AP.

**Series 2a, the check (what is left over when the skills cost the AP of the list; 0 would be a fair list):** Jab +2 −7.5 ± 0.7, landing push on all neighbours −5.9 ± 0.6, Arc +1 −4.6 ± 1.1, Jab +1 −4.1 ± 0.6, Cross −3.8 ± 0.8 (the list priced them too high: at 3–4 AP the bots use them in 35–53 % of fieldings); 1 damage still +1.1 ± 0.35; a Strike +6.8 and a movement +6.0 against a placed skill (all three at the 1 AP floor or above; the placed skills cannot go lower). Grounds −0.5 to +2.0, zones −0.8 to +0.9, props −4.4 (Vortex Trap) to +4.1 (Clay Urn). With the price list the placed skills are used more often (68–75 % against 47–51 %).
**Fine-tuning after 2a:** half of the left-over taken off Jab +1, Jab +2, Arc +1, Cross and the landing push on all neighbours, half added to damage, zero point restored. Not measured again.

**Series 2b, experiment content and switches** (same reading as series 1; 1 AP takes 1.96 ± 0.08):

| Part | Win rate | ± | Note |
|---|---|---|---|
| ground Shifting Sand | +2.93 | 0.44 | level with Mossbed (+2.96) |
| ground Springwater | +1.51 | 0.43 | level with Blight and Lava (+1.6, +1.4) |
| zone Erosion | +2.15 | 0.49 | level with Void Pull and Bog |
| zone Updraft | +1.30 | 0.54 | |
| a self buff at all | +3.98 | 0.74 | used in 64 % of fieldings |
| per point of quicken / haste / extend / refresh | −0.88 / −0.36 / −0.88 / −0.10 | 0.53 | no value of the effect itself for the bots |
| path: line / free (against walking), with a Stamina base cost of 1 | −1.24 / −2.67 | 0.66 | series 1: +0.13 / −1.00 |
| a movement at all, with the base cost | +6.14 | 0.45 | series 1: +6.19; used in 71 % against 79 % |

Battles of 2b are longer than those of series 1 (4.94 against 4.40 rounds; 4 % under 3 against 9 %); the series switches four things at once, so the share of the Stamina base cost is not separated. Trap burying: a kit with a trap and a solid prop reads +12.9 ± 4.9 points against +1.3 ± 2.2 in series 1; one series, wide error.

**Observations** (indications; bots only):

- *Damage and tempo decide for the bots:* a point of Strike damage, a movement skill and the landing push are worth more than any placed thing; a further square of any shape is worth nothing measurable. The bots do not aim an area, do not plan around ground and do not budget Stamina, so the low value of placed skills and of extra squares is as much a statement about the bots as about the skills.
- *A linear AP price does not hold above 2 AP:* a skill at 3 AP is used in 31 % of fieldings; the check series shows the expensive shapes overpriced.
- *The experiment content plays like its neighbours;* none of the four board ideas stands out, and the Stamina effects of Springwater, Updraft and Deep Breath show no value of their own.

**Follow-up:** T02 (price form, the floor of 1 AP for placed skills, AP above 2), T10, T43. No rule and no content value was changed by this entry; the price list is a draft in the build.

About 90 000 battles in 60 runs.

## S031 · 2026-11-15 · After the shape merge: the board rows of S030 again, with the battles under 3 and over 5 rounds

**State:** main, base `6573a05` dirty; content `2026-11-15.1`, kit set `953ee09679e4`; Godot 4.7.2, normal CPU settings (processes at nice 10), runs in parallel on a frozen copy of the working tree. Full suite on that state: 355 cases, 0 failures in `tests/battle` and `tests/game`, the two known non-battle failures.

**Rules of the measured state:** as S030, plus the shape merge of 2026-11-15: one shape per skill (Thrust is a Jab +1 and, like Cinder Dive, aimed in eight directions), a Strike costs the AP on its card (Shove 1 AP instead of 2), free shapes in their default arrangements. The Stamina recovery still read the Pace on the sheet; every monster of the kits lies below Pace 2.0 and recovers 1, so the series plays the same under the rule decided later that day (the current Pace counts).

**Runs:** greedy: 8 seeds (1–8) × 40 = 320 battles per row; tactic: 8 seeds × 20 = 160 battles per row on the default board, on 8×8 with four veins and on 9×9 with five. All `--paired` with the seeds of S030 (battle *i* of a seed has the same teams and board draw), **not side-swapped**. Rows are sums over the full blocks of the eight seeds; the blocks themselves are not pasted. **Length target (user, 2026-11-15): a mean of 3.0–4.9 rounds; every row states the battles under 3 and over 5 rounds** (a battle counts the round it ended in).

| Bot · board | Battles | Side 0 / 1 / Draw / timeout | Mean rounds | Under 3 rounds | 3–5 rounds | Over 5 rounds | Over 7 | Longest | First defeat (round) | Defeated before own first turn / battle | Battles that reached pressure | Strike | Ground | Collision | Prop | Vein | Flank | Total damage / battle |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| greedy · 7×7, 3 veins (default) | 320 | 142 / 173 / 5 / 0 | 4.32 | 27 (8 %) | 240 (75 %) | 53 (17 %) | 14 | 14 | 1.75 | 0.00 | 10 | 7.8 | 2.7 | 5.7 | 1.9 | 6.8 | 0.8 | 25.7 |
| greedy · 8×8, 4 veins | 320 | 146 / 162 / 12 / 0 | 4.14 | 16 (5 %) | 258 (81 %) | 46 (14 %) | 6 | 9 | 1.85 | 0.00 | 3 | 7.2 | 2.2 | 5.0 | 1.5 | 9.8 | 0.4 | 26.2 |
| greedy · 8×8, 2 veins | 320 | 160 / 158 / 2 / 0 | 5.38 | 6 (2 %) | 198 (62 %) | 116 (36 %) | 36 | 18 | 1.95 | 0.00 | 27 | 7.5 | 3.4 | 6.1 | 2.0 | 5.7 | 0.5 | 25.1 |
| greedy · 9×9, 3 veins | 320 | 150 / 160 / 10 / 0 | 4.78 | 2 (1 %) | 245 (77 %) | 73 (23 %) | 20 | 11 | 2.17 | 0.00 | 8 | 7.4 | 2.7 | 4.8 | 1.3 | 9.5 | 0.2 | 26.0 |
| greedy · 9×9, 5 veins | 320 | 150 / 158 / 12 / 0 | 4.44 | 4 (1 %) | 266 (83 %) | 50 (16 %) | 4 | 10 | 2.14 | 0.00 | 2 | 6.4 | 2.4 | 4.7 | 1.5 | 11.0 | 0.3 | 26.2 |
| tactic · 7×7, 3 veins (default) | 160 | 68 / 90 / 2 / 0 | 4.70 | 7 (4 %) | 109 (68 %) | 44 (28 %) | 9 | 10 | 1.91 | 0.00 | 3 | 5.9 | 2.5 | 6.0 | 2.3 | 7.6 | 0.6 | 24.9 |
| tactic · 8×8, 4 veins | 160 | 82 / 75 / 3 / 0 | 4.80 | 4 (2 %) | 115 (72 %) | 41 (26 %) | 12 | 14 | 2.19 | 0.00 | 6 | 5.0 | 2.0 | 5.3 | 2.0 | 11.4 | 0.4 | 26.1 |
| tactic · 9×9, 5 veins | 160 | 74 / 77 / 9 / 0 | 4.67 | 0 (0 %) | 128 (80 %) | 32 (20 %) | 5 | 10 | 2.38 | 0.00 | 1 | 4.8 | 2.1 | 4.4 | 1.7 | 12.9 | 0.3 | 26.3 |

### The same rows in S030 and S031 (counts from the stored blocks of both series)

| Bot · board | S030: mean rounds · under 3 · over 5 | S031: mean rounds · under 3 · over 5 |
|---|---|---|
| greedy · 7×7, 3 veins | 4.51 · 23 of 320 · 69 of 320 | 4.32 · 27 of 320 · 53 of 320 |
| greedy · 8×8, 4 veins | 4.23 · 18 of 320 · 51 of 320 | 4.14 · 16 of 320 · 46 of 320 |
| greedy · 8×8, 2 veins | 5.61 · 4 of 320 · 128 of 320 | 5.38 · 6 of 320 · 116 of 320 |
| greedy · 9×9, 3 veins | 4.89 · 2 of 320 · 78 of 320 | 4.78 · 2 of 320 · 73 of 320 |
| greedy · 9×9, 5 veins | 4.50 · 2 of 320 · 56 of 320 | 4.44 · 4 of 320 · 50 of 320 |
| tactic · 7×7, 3 veins | 5.09 · 3 of 160 · 59 of 160 | 4.70 · 7 of 160 · 44 of 160 |
| tactic · 8×8, 4 veins | 4.92 · 6 of 160 · 43 of 160 | 4.80 · 4 of 160 · 41 of 160 |
| tactic · 8×8, 2 veins | 6.99 · 1 of 160 · 98 of 160 | not run |
| tactic · 9×9, 3 veins | 5.50 · 0 of 160 · 70 of 160 | not run |
| tactic · 9×9, 5 veins | 4.79 · 0 of 160 · 36 of 160 | 4.67 · 0 of 160 · 32 of 160 |

### Team win rate by monster, `tactic` / `greedy`

Wins of the teams that fielded the monster; 86–104 fieldings per cell with `tactic`, 182–211 with `greedy`: about ±10 and ±7 points of noise. Sorted by the first column.

| Monster | 7×7, 3 veins | 8×8, 4 veins | 9×9, 5 veins | 8×8, 2 veins (greedy) | 9×9, 3 veins (greedy) |
|---|---|---|---|---|---|
| hollow_serpent | 66 % / 64 % | 60 % / 65 % | 53 % / 55 % | 65 % | 61 % |
| gloom_wolf | 66 % / 55 % | 56 % / 49 % | 61 % / 58 % | 52 % | 46 % |
| moss_turtle | 60 % / 52 % | 59 % / 46 % | 57 % / 57 % | 51 % | 46 % |
| thorn_mites | 58 % / 59 % | 48 % / 56 % | 46 % / 54 % | 55 % | 64 % |
| forge_golem | 49 % / 57 % | 64 % / 58 % | 48 % / 47 % | 64 % | 54 % |
| blaze_tiger | 48 % / 49 % | 46 % / 53 % | 52 % / 50 % | 46 % | 49 % |
| asdf | 46 % / 39 % | 40 % / 47 % | 49 % / 45 % | 39 % | 43 % |
| grove_wisp | 44 % / 51 % | 55 % / 47 % | 59 % / 47 % | 43 % | 52 % |
| ember_hawk | 30 % / 37 % | 35 % / 33 % | 24 % / 36 % | 45 % | 44 % |
| dusk_moth | 29 % / 30 % | 31 % / 28 % | 24 % / 31 % | 37 % | 27 % |

**Observations (indications):**

- **Every row is a little shorter than in S030:** greedy by 0.06–0.23 mean rounds, tactic by 0.12–0.39. The largest change is `tactic` on the default board: 5.09 → 4.70 mean rounds, with 44 instead of 59 of the 160 battles over 5 rounds. Shove at 1 AP and the eight directions of Thrust and Cinder Dive changed together, so the difference is not assigned to one of them.
- **Against the length target (mean 3.0–4.9):** all three `tactic` rows (4.70 / 4.80 / 4.67) and four of the five greedy rows (4.14–4.78) lie inside; 8×8 with two veins stays outside (5.38, 116 of 320 battles over 5 rounds, 27 battles reached late-round pressure).
- **The tails:** over 5 rounds end 20–28 % of the `tactic` battles and 14–23 % of the greedy ones on the boards inside the target; under 3 rounds the default board keeps the most (27 of 320 greedy, 7 of 160 tactic) and 9×9 almost none (2–4 of 320, 0 of 160). For a share near 25 % in 160 battles the noise is about ±7 points, so the three boards do not differ in their `tactic` tails.
- **Draws** are more frequent on the larger boards with three or more veins: 10–12 of 320 (greedy) on 8×8 with four veins and on both 9×9 rows, 9 of 160 (tactic) on 9×9 with five; 2–5 on the default board and 2 on 8×8 with two veins.
- **Monsters:** the order is the one of S030 (Hollow Serpent high in most rows, Dusk Moth lowest in every row, Ember Hawk next to it in every row played with `tactic`). Gloom Wolf and Moss Turtle, the two kits with Shove, read higher with `tactic` on the default board (66 % and 60 %; S030: 57 % and 49 %), which is a lead inside the noise of ±10 points, not an established effect of the cheaper Shove.
- No row has a defeat before the victim's own first turn; the first defeat falls in round 1.75–2.17 (greedy) and 1.91–2.38 (tactic).

**Follow-up:** T13 (the target and its tails; what shortened the rows), T39 (board size and number of Dragon Veins; human play), T03 (the stat calculation under discussion; the test stats filled later that day are not measured). No rule, board or value follows from these runs.

## S030 · 2026-11-15 · Rules of 2026-11-15 and 3v3 on 8×8 and 9×9 boards

**State:** main, base `6573a05` dirty; content `2026-11-13.1`, kit set `f564899a2ac8`; Godot 4.7.2, normal CPU settings, runs in parallel on a frozen copy of the working tree. Full suite on that state: 344 cases, 0 failures in `tests/battle` and `tests/game`, the two known non-battle failures.

**Rules of the measured state (user decisions of 2026-11-15, written into the GDDs):** the stat Initiative is called **Pace** and counts 0.1 per point (the monsters of the kits 1.0–1.4, converted by their points, so the turn order is the one of S029); **Stamina is the rule:** a movement skill costs its AP and Stamina for every square (range 3), and every monster recovers the whole number of its Pace at the round end, which is 1 for all monsters of the kits; at the round end everything acts before the clocks tick; a Strike pushes if its record says so (every Strike of the content does); board generation may start a prop pair on Dragon Veins, so the seeded boards differ from those of S029. **Not yet in this state:** the shape merge of the same day. Shove still cost 2 AP here (the AP of its Jab shape; 1 AP on its card afterwards), Thrust and Cinder Dive were aimed in four directions.

**Board switches measured** (`--variant size=N`; switches, not rules): 3v3 on 8×8 and 9×9 with the back two rows as start areas (the lines stand 5 and 6 squares apart instead of 4). 9×9 has its Dragon Veins on the centre row (3: x = 1, 4, 7; 5: x = 0, 2, 4, 6, 8). 8×8 has no centre row: mirrored pairs on the two centre rows (4: (1,4), (5,4), (2,3), (6,3); 2: (2,4), (5,3)). The larger boards draw 3–4 mirrored prop pairs instead of 2–3.

**Runs:** greedy: 8 seeds (1–8) × 40 = 320 battles per row; tactic: 8 seeds × 20 = 160 battles per row; greedy with `balanced,mixstats` on 7×7: 8 seeds × 60 = 480 battles. All `--paired`, **not side-swapped**. Rows are sums over the full blocks of the eight seeds; the blocks themselves are not pasted. Late-round pressure was reached in 11 / 3 / 23 / 10 / 1 of the 320 greedy battles and in 8 / 7 / 36 / 8 / 3 of the 160 tactic battles (rows in the order of the table).

| Bot · content · board | Battles | Side 0 / 1 / Draw / timeout | Mean rounds | Under 3 | Over 5 | Over 7 | Longest | First defeat (round) | Defeated before own first turn / battle | Strike | Ground | Collision | Prop | Vein | Flank | Total damage / battle |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| greedy · kits · 7×7, 3 veins (default) | 320 | 144 / 172 / 4 / 0 | 4.51 | 7 % | 22 % | 6 % | 14 | 1.84 | 0.00 | 7.7 | 2.7 | 5.6 | 1.8 | 7.1 | 0.8 | 25.8 |
| greedy · kits · 8×8, 4 veins | 320 | 151 / 152 / 17 / 0 | 4.23 | 6 % | 16 % | 3 % | 10 | 1.86 | 0.00 | 7.1 | 2.2 | 5.0 | 1.5 | 10.1 | 0.4 | 26.3 |
| greedy · kits · 8×8, 2 veins | 320 | 163 / 154 / 3 / 0 | 5.61 | 1 % | 40 % | 12 % | 23 | 2.05 | 0.00 | 7.8 | 3.3 | 6.0 | 2.0 | 5.8 | 0.5 | 25.5 |
| greedy · kits · 9×9, 3 veins | 320 | 153 / 159 / 8 / 0 | 4.89 | 1 % | 24 % | 6 % | 22 | 2.21 | 0.00 | 7.4 | 2.6 | 4.5 | 1.3 | 9.8 | 0.2 | 25.9 |
| greedy · kits · 9×9, 5 veins | 320 | 160 / 147 / 13 / 0 | 4.50 | 1 % | 18 % | 1 % | 11 | 2.16 | 0.00 | 6.5 | 2.3 | 4.6 | 1.5 | 11.2 | 0.3 | 26.3 |
| tactic · kits · 7×7, 3 veins (default) | 160 | 75 / 84 / 1 / 0 | 5.09 | 2 % | 37 % | 8 % | 10 | 1.98 | 0.00 | 6.2 | 2.4 | 5.8 | 2.2 | 8.2 | 0.6 | 25.2 |
| tactic · kits · 8×8, 4 veins | 160 | 88 / 68 / 4 / 0 | 4.92 | 4 % | 27 % | 8 % | 12 | 2.25 | 0.00 | 5.1 | 2.3 | 5.0 | 1.9 | 11.4 | 0.4 | 26.2 |
| tactic · kits · 8×8, 2 veins | 160 | 71 / 86 / 3 / 0 | 6.99 | 1 % | 61 % | 31 % | 23 | 2.70 | 0.00 | 5.9 | 2.9 | 5.8 | 1.8 | 8.3 | 0.5 | 25.3 |
| tactic · kits · 9×9, 3 veins | 160 | 80 / 77 / 3 / 0 | 5.50 | 0 % | 44 % | 9 % | 15 | 2.45 | 0.00 | 5.2 | 2.3 | 4.5 | 1.6 | 11.8 | 0.3 | 25.7 |
| tactic · kits · 9×9, 5 veins | 160 | 72 / 79 / 9 / 0 | 4.79 | 0 % | 22 % | 4 % | 10 | 2.35 | 0.00 | 5.1 | 1.9 | 4.1 | 1.5 | 13.6 | 0.3 | 26.5 |
| greedy · balanced,mixstats · 7×7, 3 veins | 480 | 229 / 244 / 7 / 0 | 3.74 | 10 % | 8 % | 2 % | 16 | 1.91 | 0.00 | 9.2 | 2.3 | 6.1 | 2.4 | 5.9 | 1.1 | 27.0 |

### Team win rate by monster, `tactic` / `greedy`

Wins of the teams that fielded the monster; 86–104 fieldings per cell with `tactic`, 182–211 with `greedy`: about ±10 and ±7 points of noise. Sorted by the first column.

| Monster | 7×7, 3 veins | 8×8, 4 veins | 8×8, 2 veins | 9×9, 3 veins | 9×9, 5 veins |
|---|---|---|---|---|---|
| hollow_serpent | 68 % / 65 % | 62 % / 64 % | 61 % / 65 % | 58 % / 54 % | 54 % / 56 % |
| thorn_mites | 62 % / 61 % | 52 % / 58 % | 58 % / 62 % | 49 % / 60 % | 56 % / 54 % |
| forge_golem | 58 % / 52 % | 60 % / 53 % | 55 % / 60 % | 50 % / 54 % | 50 % / 49 % |
| gloom_wolf | 57 % / 60 % | 47 % / 44 % | 53 % / 55 % | 55 % / 46 % | 63 % / 57 % |
| moss_turtle | 49 % / 43 % | 58 % / 47 % | 51 % / 46 % | 48 % / 44 % | 54 % / 50 % |
| blaze_tiger | 47 % / 50 % | 51 % / 50 % | 56 % / 46 % | 59 % / 51 % | 46 % / 54 % |
| asdf | 46 % / 43 % | 46 % / 44 % | 40 % / 38 % | 42 % / 49 % | 47 % / 42 % |
| grove_wisp | 42 % / 50 % | 52 % / 45 % | 50 % / 50 % | 57 % / 58 % | 58 % / 49 % |
| ember_hawk | 40 % / 42 % | 30 % / 35 % | 35 % / 42 % | 41 % / 42 % | 26 % / 40 % |
| dusk_moth | 29 % / 31 % | 31 % / 32 % | 33 % / 33 % | 32 % / 29 % | 20 % / 28 % |

### Team win rate by fielded stat value, greedy with `balanced,mixstats` (7×7, 480 battles)

Every monster plays random stats (HP 3–8, Pace 1.0–2.9, Stamina pool 1–5, Reach 2–4, TPR 1–2, AP 2–3) and a balanced draw of skills. Team win rates conditional on a fielded stat value, not prices; about ±3 points of noise per Pace, TPR and AP row, ±4 per other row.

| Stat value | Wins / times fielded on a team |
|---|---|
| HP 3 | 198/527 = 38 % |
| HP 4 | 208/491 = 42 % |
| HP 5 | 217/473 = 46 % |
| HP 6 | 251/450 = 56 % |
| HP 7 | 266/457 = 58 % |
| HP 8 | 279/482 = 58 % |
| Pace 1.0–1.9 (recovers 1) | 700/1424 = 49 % |
| Pace 2.0–2.9 (recovers 2) | 719/1456 = 49 % |
| Stamina pool 1 | 264/578 = 46 % |
| Stamina pool 2 | 277/581 = 48 % |
| Stamina pool 3 | 278/580 = 48 % |
| Stamina pool 4 | 287/553 = 52 % |
| Stamina pool 5 | 313/588 = 53 % |
| Reach 2 | 464/941 = 49 % |
| Reach 3 | 505/980 = 52 % |
| Reach 4 | 450/959 = 47 % |
| TPR 1 | 606/1419 = 43 % |
| TPR 2 | 813/1461 = 56 % |
| AP 2 | 641/1434 = 45 % |
| AP 3 | 778/1446 = 54 % |

**Observations (indications):**

- **Larger boards delay the first contact:** the first defeat moves from round 1.84 to 2.05–2.21 (greedy; 8×8 with four veins: 1.86) and from 1.98 to 2.25–2.70 (tactic), and battles under 3 rounds nearly vanish on 9×9 and on 8×8 with two veins (greedy 7 % → 1 %, tactic 2 % → 0–1 %). 8×8 with four veins keeps them (6 % / 4 %).
- **The number of veins moves the length more than the board does:** 8×8 with two veins is the longest row under both bots (5.61 and 6.99 mean rounds, 40 % and 61 % of the battles over 5 rounds, the longest 23 rounds, late-round pressure reached most often); 8×8 with four and 9×9 with five veins are the shortest. Vein damage per battle rises with the veins (greedy 5.8 / 7.1 / 9.8 / 10.1 / 11.2 for 2 / 3 / 3 / 4 / 5 veins; tactic 8.3 / 8.2 / 11.8 / 11.4 / 13.6) while Strike damage falls.
- **Draws:** four veins on 8×8 give 17 Draws in 320 greedy battles (4 in 160 with tactic), five veins on 9×9 13 and 9; the other rows 3–8 and 1–3.
- **Against the length target (3–5 mean rounds):** with `tactic` the default board now reads 5.09 with 37 % of the battles over 5 rounds (S028, tactic with last touch: 4.25); 8×8 with four veins 4.92, 9×9 with five 4.79, 9×9 with three 5.50. Stamina as the rule, the round end with the clocks last and props on veins at generation changed together since S029, so the difference cannot be assigned to one of them. No row has a defeat before the victim's own first turn.
- **Monsters:** their order is similar on every board (Hollow Serpent and Thorn Mites high, Dusk Moth lowest in every row); most differences between boards lie inside the noise. With `tactic`, Ember Hawk falls on 8×8 with four and 9×9 with five veins and Grove Wisp rises on the larger boards.
- **Pace shows no slope with its second job:** in the random-stat series a Pace of 2.x (recovering 2 Stamina) wins as often as 1.x (49 % each). HP keeps the steepest slope (38 → 58 %), then TPR (43 → 56 %) and AP (45 → 54 %); the Stamina pool has a small one (46 → 53 %); Reach is flat. The greedy bot does not budget Stamina and these battles last 3.7 rounds, so the series says little about what a human gains from a faster recovery.

**Follow-up:** T39 (board size and number of Dragon Veins; an even number and Draws; human play of 8×8 and 9×9), T13 (the tactic rows against the length target; a series after the shape merge; bots that budget Stamina), T03 (the Pace range and what a recovery of 2 should cost), T41 (Stamina details). No rule, board or value follows from these runs.

## S029 · 2026-11-14 · Stamina at 1 per square, last touch back as the build default

**State:** main, base `593f770` dirty; content `2026-11-13.1`, kit set `789f3d326286` (as S028); Godot 4.7.2, normal CPU settings, runs in parallel. Battle suite before the runs: 177 cases, 0 errors, 0 failures.

**Build default changed after S028 (user decision):** a Dragon Vein belongs to the side that touched it last (`vein_touch` = true, the GDD rule) again. **Stamina reworked after user feedback** (test switch, not a rule): a slotted movement skill costs 1 Stamina per movement point of its route (a square, or what slowing ground costs), reaches at most the range on the skill (3) and never further than the Stamina left, and also costs its AP (`staminafree`: Stamina only); `stamina=N` comes back at the round end (default 1); Step stays 1 AP for 1 square without Stamina. The Stamina of S028 (a flat cost per use, no AP) is gone. The bots do not budget Stamina: they spend it like Movement and Step once it is empty.

**Runs:** greedy: 8 seeds (1–8) × 32 = 256 battles per kit row; greedy with `balanced,mixstats`: 8 seeds × 60 = 480 battles per row and column. All `--paired`, **not side-swapped**. Rows are sums over the full blocks of the eight seeds; the blocks themselves are not pasted.

| Bot · content · variant | Battles | Side 0 / 1 / Draw / timeout | Mean rounds | Under 3 | Over 5 | Longest | Defeated before own first turn / battle | Strike | Ground | Collision | Prop | Vein | Flank | Total damage / battle |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| greedy · kits · build defaults (last touch) | 256 | 127 / 124 / 5 / 0 | 3.50 | 11 % | 3 % | 8 | 0.00 | 9.5 | 2.2 | 4.6 | 0.9 | 7.7 | 0.8 | 25.7 |
| greedy · kits · stamina | 256 | 133 / 113 / 10 / 0 | 3.68 | 12 % | 6 % | 7 | 0.00 | 8.7 | 2.2 | 4.3 | 1.1 | 8.7 | 0.6 | 25.8 |
| greedy · kits · stamina=2 | 256 | 122 / 127 / 7 / 0 | 3.61 | 12 % | 4 % | 7 | 0.00 | 9.3 | 2.1 | 4.5 | 1.1 | 8.4 | 0.7 | 26.0 |
| greedy · kits · stamina,staminafree | 256 | 131 / 120 / 5 / 0 | 3.27 | 21 % | 4 % | 8 | 0.00 | 10.1 | 2.4 | 4.0 | 1.1 | 7.4 | 0.3 | 25.4 |
| greedy · balanced,mixstats | 480 | 231 / 242 / 7 / 0 | 3.44 | 13 % | 3 % | 9 | 0.01 | 9.9 | 2.0 | 5.5 | 1.6 | 7.4 | 1.0 | 27.4 |
| greedy · balanced,mixstats,stamina | 480 | 223 / 243 / 14 / 0 | 3.58 | 13 % | 6 % | 12 | 0.00 | 9.5 | 2.1 | 5.1 | 1.8 | 8.5 | 0.8 | 27.6 |
| greedy · balanced,mixstats,stamina=2 | 480 | 223 / 249 / 8 / 0 | 3.52 | 14 % | 4 % | 17 | 0.00 | 9.8 | 2.0 | 5.3 | 1.7 | 8.0 | 0.8 | 27.5 |
| greedy · balanced,mixstats,stamina,staminafree | 480 | 218 / 246 / 16 / 0 | 3.06 | 33 % | 2 % | 9 | 0.01 | 11.3 | 2.2 | 5.0 | 1.6 | 6.8 | 0.6 | 27.6 |

### Team win rate by fielded stat band, greedy with `balanced,mixstats`

480 battles per column; each cell wins / times fielded on a team. Team win rates conditional on a fielded stat, not individual win rates or prices; about ±3 points of band noise (single Movement values about ±4).

| Stat band | balanced,mixstats (Movement) | + stamina (+1 per round) | + stamina=2 | + stamina,staminafree |
|---|---|---|---|---|
| HP 3–4 | 404/1018 = 40 % | 386/1018 = 38 % | 389/1018 = 38 % | 370/1018 = 36 % |
| HP 5–6 | 473/923 = 51 % | 455/923 = 49 % | 463/923 = 50 % | 478/923 = 52 % |
| HP 7–8 | 542/939 = 58 % | 557/939 = 59 % | 564/939 = 60 % | 544/939 = 58 % |
| Initiative 1–3 | 482/969 = 50 % | 470/969 = 49 % | 474/969 = 49 % | 502/969 = 52 % |
| Initiative 4–6 | 460/947 = 49 % | 445/947 = 47 % | 471/947 = 50 % | 450/947 = 48 % |
| Initiative 7–9 | 477/964 = 49 % | 483/964 = 50 % | 471/964 = 49 % | 440/964 = 46 % |
| Movement / Stamina 1 | 246/578 = 43 % | 271/578 = 47 % | 279/578 = 48 % | 268/578 = 46 % |
| Movement / Stamina 2 | 273/581 = 47 % | 261/581 = 45 % | 282/581 = 49 % | 265/581 = 46 % |
| Movement / Stamina 3 | 302/580 = 52 % | 297/580 = 51 % | 298/580 = 51 % | 293/580 = 51 % |
| Movement / Stamina 4 | 293/553 = 53 % | 270/553 = 49 % | 269/553 = 49 % | 287/553 = 52 % |
| Movement / Stamina 5 | 305/588 = 52 % | 299/588 = 51 % | 288/588 = 49 % | 279/588 = 47 % |
| Reach 2 | 446/941 = 47 % | 443/941 = 47 % | 436/941 = 46 % | 450/941 = 48 % |
| Reach 3 | 496/980 = 51 % | 485/980 = 49 % | 500/980 = 51 % | 491/980 = 50 % |
| Reach 4 | 477/959 = 50 % | 470/959 = 49 % | 480/959 = 50 % | 451/959 = 47 % |
| TPR 1 | 614/1419 = 43 % | 615/1419 = 43 % | 641/1419 = 45 % | 644/1419 = 45 % |
| TPR 2 | 805/1461 = 55 % | 783/1461 = 54 % | 775/1461 = 53 % | 748/1461 = 51 % |
| AP 2 | 647/1434 = 45 % | 628/1434 = 44 % | 639/1434 = 45 % | 622/1434 = 43 % |
| AP 3 | 772/1446 = 53 % | 770/1446 = 53 % | 777/1446 = 54 % | 770/1446 = 53 % |

**Observations** (indications; bots on working content):

- **Last touch as the default** reproduces S028: 3.50 rounds on the kits (S028: 3.48), 3 % of the battles over 5 rounds, no defeat before the victim's own first turn.
- **Stamina at 1 per square does not make the stat worth more than Movement is, with these bots:** Movement 1 / 2 / 3 / 4 / 5 wins 43 / 47 / 52 / 53 / 52 %; as a Stamina pool with +1 per round 47 / 45 / 51 / 49 / 51 %, with +2 per round 48 / 49 / 51 / 49 / 49 % (flat). A pool of 1–2 no longer limits the range of every move, only how often a monster moves far; the bot then Steps. A bot that saves Stamina for the right moment could read differently; these runs cannot show that.
- **Recovery:** +2 per round removes what slope +1 has. With +1 the pool is the stat; a recovery stat next to it would mostly decide the late rounds of long battles (3.5 rounds on average here).
- **AP on top or Stamina only:** with AP the length stays where Movement has it (3.58 / 3.68 against 3.44 / 3.50). Stamina only shortens battles (3.06 / 3.27, a third / a fifth under 3 rounds) because moving no longer competes with Strikes for AP, as in S028.
- **Other stats** as in S028: HP steepest (36–40 → 58–60 %), TPR and AP next, initiative and Reach flat in every column.

**Follow-up:** T39 (vein rule kept: last touch; Stamina open with the user), T38 (switches), T13 (stat value). No rule or price follows from this entry.

## S028 · 2026-11-14 · New build defaults, prop rework, balanced kit draw and Stamina

**State:** main, base `593f770` dirty; content `2026-11-13.1`, kit set `789f3d326286` (the nine kits carry a fifth slot with a prop skill; five new props, seven new prop skills; aura props archived; the user records `asdf*` and `new_skill` unchanged); Godot 4.7.2, normal CPU settings, runs in parallel. Battle suite before the runs: 176 cases, 0 errors, 0 failures. One autonomous session after the user's requests of 2026-11-14; decisions taken in it are listed in [temp_todo.md](temp_todo.md).

**Build defaults measured** (not GDD rules except the first): every slotted skill at most `usage_limit` (1) times per turn; push and pull zones do not move at cast; a Dragon Vein works only for the side whose monster stands on it at the round end ("vein held", user wish for these tests); generated boards never start with a prop on a vein. **Variants** (`sim.gd --variant`, in memory only): `turnfree`, `castpush`, `veintouch` undo one default each; `veinlate` as S027; `balanced` / `balanced=6`: every monster plays one Strike, one movement skill and 2 / 4 skills of different kinds from zone, ground, prop and trap, kinds going round per side (draft-status skills only); `mixstats` as S026; `stamina` / `stamina=N`: Movement is a Stamina pool, a movement skill costs Stamina (its AP cost) instead of AP and covers 3 squares, +N (1) per monster at the round end; `openmap` removes the pre-placed props.

**Runs:** greedy: 8 seeds (1–8) × 32 = 256 battles per row; tactic both sides: 8 seeds × 4 = 32 battles per row; greedy with `balanced,mixstats`: 8 seeds × 60 = 480 battles per column. All `--paired`, **not side-swapped**. Rows are sums over the full blocks of the eight seeds (mean rounds from the exact histograms, damage from the per-battle rows); the blocks themselves are not pasted. A first pass of the same series is discarded and not reported: its boards started with props on Dragon Veins (side effect of allowing props on veins), which lengthened battles (greedy · kits · veintouch: 4.18 against 3.48 rounds; the fifth kit slot was also added in between).

### Length and damage

| Bot · content · variant | Battles | Side 0 / 1 / Draw / timeout | Mean rounds | Under 3 | Over 5 | Longest | Defeated before own first turn / battle | Strike | Ground | Collision | Prop | Vein | Flank | Total damage / battle |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| greedy · kits · turnfree,castpush,veintouch (rules before this session) | 256 | 125 / 129 / 2 / 0 | 2.46 | 57 % | 0 % | 4 | 0.05 | 4.8 | 2.1 | 12.4 | 0.9 | 4.7 | 0.4 | 25.3 |
| greedy · kits · build defaults (vein held) | 256 | 133 / 120 / 3 / 0 | 4.73 | 5 % | 27 % | 19 | 0.00 | 9.4 | 2.9 | 5.0 | 1.3 | 6.1 | 0.6 | 25.5 |
| greedy · kits · veintouch | 256 | 107 / 146 / 3 / 0 | 3.48 | 11 % | 2 % | 7 | 0.00 | 9.8 | 2.3 | 4.1 | 0.8 | 7.8 | 0.9 | 25.6 |
| greedy · kits · veinlate | 256 | 110 / 143 / 3 / 0 | 3.99 | 8 % | 11 % | 12 | 0.00 | 10.2 | 2.3 | 4.3 | 0.9 | 6.9 | 0.8 | 25.4 |
| greedy · kits · stamina | 256 | 117 / 136 / 3 / 0 | 4.14 | 13 % | 17 % | 14 | 0.00 | 10.7 | 2.4 | 4.8 | 1.7 | 5.1 | 0.3 | 25.2 |
| greedy · balanced (4 slots) | 256 | 110 / 143 / 3 / 0 | 4.48 | 6 % | 18 % | 21 | 0.00 | 10.0 | 2.0 | 4.9 | 1.9 | 5.4 | 0.6 | 24.9 |
| greedy · balanced=6 | 256 | 125 / 127 / 4 / 0 | 4.82 | 7 % | 26 % | 17 | 0.00 | 9.0 | 2.7 | 4.9 | 2.3 | 5.7 | 0.6 | 25.3 |
| greedy · balanced,veintouch | 256 | 116 / 130 / 10 / 0 | 3.41 | 12 % | 4 % | 9 | 0.01 | 9.7 | 1.7 | 4.1 | 1.4 | 7.6 | 1.0 | 25.5 |
| greedy · balanced,openmap | 256 | 115 / 138 / 3 / 0 | 4.39 | 7 % | 17 % | 16 | 0.00 | 11.2 | 2.0 | 3.6 | 1.6 | 6.2 | 0.9 | 25.4 |
| greedy · balanced,stamina | 256 | 132 / 121 / 3 / 0 | 3.90 | 18 % | 13 % | 13 | 0.00 | 11.8 | 1.8 | 4.7 | 1.6 | 4.8 | 0.4 | 25.1 |
| greedy · balanced,stamina=0 | 256 | 128 / 125 / 3 / 0 | 4.66 | 15 % | 25 % | 21 | 0.00 | 10.8 | 2.0 | 4.0 | 1.7 | 5.8 | 0.4 | 24.9 |
| tactic · kits · build defaults (vein held) | 32 | 16 / 16 / 0 / 0 | 5.50 | 3 % | 50 % | 9 | 0.00 | 6.9 | 2.8 | 4.7 | 1.1 | 7.8 | 0.8 | 24.3 |
| tactic · kits · veintouch | 32 | 16 / 14 / 2 / 0 | 4.25 | 6 % | 9 % | 9 | 0.00 | 7.9 | 2.3 | 5.0 | 0.9 | 9.4 | 0.8 | 26.2 |
| tactic · kits · veinlate | 32 | 11 / 21 / 0 / 0 | 5.16 | 9 % | 38 % | 12 | 0.00 | 7.3 | 2.6 | 4.4 | 1.3 | 8.8 | 0.9 | 25.3 |
| tactic · kits · stamina | 32 | 13 / 19 / 0 / 0 | 3.94 | 9 % | 19 % | 8 | 0.03 | 11.6 | 2.3 | 5.0 | 1.0 | 4.5 | 0.3 | 24.8 |
| tactic · balanced (4 slots) | 32 | 12 / 20 / 0 / 0 | 5.91 | 3 % | 53 % | 11 | 0.00 | 8.4 | 2.7 | 5.0 | 2.3 | 7.2 | 0.4 | 26.1 |
| tactic · balanced,veintouch | 32 | 14 / 18 / 0 / 0 | 4.62 | 3 % | 16 % | 10 | 0.00 | 7.6 | 2.0 | 4.4 | 1.9 | 11.0 | 0.8 | 27.7 |
| tactic · balanced,stamina | 32 | 17 / 15 / 0 / 0 | 4.41 | 12 % | 22 % | 12 | 0.00 | 12.8 | 1.4 | 5.0 | 2.1 | 4.3 | 0.4 | 25.9 |

"Prop" is the tool's `aftermath` column (all prop damage: destroyed, hit, entered, round end). Balanced, greedy, 256 battles, prop damage by source: Spike Trap 176 · Ember Brazier 145 · Clay Urn 65 · Thorn Idol 62 · Bamboo Stand 29.

### Skill use in the balanced draw (greedy, 256 battles, vein held)

Team win rate by drawn kind: strike 49 %, move 49 %, zone 49 %, ground 51 %, prop 49 %, trap 48 % (742–786 fielded slots per flexible kind; all within noise).

| Drawn kind | Skill | Uses | Fielded slots | Uses / slot | Team win rate when fielded |
|---|---|---|---|---|---|
| strike | strike_jab | 550 | 516 | 1.07 | 49 % |
| strike | strike_thrust | 475 | 508 | 0.94 | 47 % |
| strike | thorn_lash | 538 | 512 | 1.05 | 52 % |
| move | run | 496 | 263 | 1.89 | 54 % |
| move | glide | 430 | 256 | 1.68 | 50 % |
| move | leap | 409 | 247 | 1.66 | 46 % |
| move | quake_leap | 530 | 250 | 2.12 | 51 % |
| move | headbutt | 476 | 276 | 1.72 | 52 % |
| move | fire_trail | 380 | 244 | 1.56 | 42 % |
| zone | bog | 261 | 230 | 1.13 | 53 % |
| zone | gale | 96 | 277 | 0.35 | 48 % |
| zone | void_pull | 70 | 256 | 0.27 | 47 % |
| ground | cinder_dive | 92 | 132 | 0.70 | 51 % |
| ground | coiling_rift | 80 | 102 | 0.78 | 54 % |
| ground | gloom_rift | 337 | 150 | 2.25 | 47 % |
| ground | lava_field | 180 | 121 | 1.49 | 55 % |
| ground | snare | 61 | 141 | 0.43 | 49 % |
| ground | thornbed | 247 | 140 | 1.76 | 54 % |
| prop | plant_bamboo | 161 | 119 | 1.35 | 45 % |
| prop | set_gong | 44 | 106 | 0.42 | 53 % |
| prop | set_urn | 122 | 93 | 1.31 | 51 % |
| prop | raise_wall | 18 | 120 | 0.15 | 43 % |
| prop | set_idol | 112 | 87 | 1.29 | 51 % |
| prop | light_brazier | 80 | 105 | 0.76 | 49 % |
| prop | set_drum | 42 | 112 | 0.38 | 53 % |
| trap | lay_spikes | 622 | 402 | 1.55 | 47 % |
| trap | lay_vortex | 96 | 379 | 0.25 | 50 % |

Per-skill win rates rest on 87–516 fielded slots: about ±5 to ±10 points, none is established.

### Team win rate by fielded stat band, greedy with `balanced,mixstats`

480 battles per column; each cell wins / times fielded on a team. Team win rates conditional on a fielded stat, not individual win rates or prices; about ±3 points of band noise.

| Stat band | balanced,mixstats (vein held) | + veintouch | + veinlate | + stamina (band = Stamina pool) |
|---|---|---|---|---|
| Mean rounds | 4.26 | 3.41 | 3.84 | 3.61 |
| HP 3–4 | 407/1018 = 40 % | 396/1018 = 39 % | 418/1018 = 41 % | 409/1018 = 40 % |
| HP 5–6 | 474/923 = 51 % | 471/923 = 51 % | 487/923 = 53 % | 463/923 = 50 % |
| HP 7–8 | 535/939 = 57 % | 543/939 = 58 % | 535/939 = 57 % | 544/939 = 58 % |
| Initiative 1–3 | 463/969 = 48 % | 487/969 = 50 % | 484/969 = 50 % | 490/969 = 51 % |
| Initiative 4–6 | 465/947 = 49 % | 439/947 = 46 % | 452/947 = 48 % | 460/947 = 49 % |
| Initiative 7–9 | 488/964 = 51 % | 484/964 = 50 % | 504/964 = 52 % | 466/964 = 48 % |
| Movement 1–2 | 553/1159 = 48 % | 513/1159 = 44 % | 551/1159 = 48 % | 554/1159 = 48 % |
| Movement 3 | 304/580 = 52 % | 305/580 = 53 % | 302/580 = 52 % | 299/580 = 52 % |
| Movement 4–5 | 559/1141 = 49 % | 592/1141 = 52 % | 587/1141 = 51 % | 563/1141 = 49 % |
| Reach 2 | 462/941 = 49 % | 468/941 = 50 % | 462/941 = 49 % | 456/941 = 48 % |
| Reach 3 | 478/980 = 49 % | 473/980 = 48 % | 491/980 = 50 % | 493/980 = 50 % |
| Reach 4 | 476/959 = 50 % | 469/959 = 49 % | 487/959 = 51 % | 467/959 = 49 % |
| TPR 1 | 621/1419 = 44 % | 633/1419 = 45 % | 635/1419 = 45 % | 640/1419 = 45 % |
| TPR 2 | 795/1461 = 54 % | 777/1461 = 53 % | 805/1461 = 55 % | 776/1461 = 53 % |
| AP 2 | 632/1434 = 44 % | 649/1434 = 45 % | 656/1434 = 46 % | 633/1434 = 44 % |
| AP 3 | 784/1446 = 54 % | 761/1446 = 53 % | 784/1446 = 54 % | 783/1446 = 54 % |

**Observations** (indications; bots on working content):

- **Length:** the rules before this session end in 2.46 rounds (greedy, 57 % under 3). The new defaults reach 3.5–4.7 with greedy and 4.3–5.5 with tactic, with no defeat before the victim's own first turn. Which vein rule is on decides the top end: vein held 4.73 / 5.50 (27 % / 50 % of the battles over 5 rounds, longest 19), last touch 3.48 / 4.25 (2 % / 9 % over 5), first touch with round-end damage 3.99 / 5.16.
- **Vein held flattens Movement and initiative:** Movement bands 48 / 52 / 49 % and initiative 48 / 49 / 51 %. Under last touch Movement 1–2 falls to 44 % against 52–53 % (the only Movement slope so far); initiative stays flat in every column of this entry (the S026/S027 initiative slope of `veinlate`, 46 / 48 / 53 %, shows here as 50 / 48 / 52 %: not confirmed on the balanced draw). HP keeps the steepest slope (about 40 → 57 %), TPR and AP follow (44–46 → 53–55 %), Reach is flat.
- **Props:** in the balanced draw props deal 1.4–2.3 damage per battle (kits: 0.8–1.7), mostly Spike Trap and Ember Brazier. No drawn kind stands out in win rate. The greedy bot hardly uses what it cannot score: Earth Wall 0.15 uses per slot, Vortex Trap 0.25, Storm Drum 0.38, Bronze Gong 0.42 (and the push and pull zones Gale 0.35, Void Pull 0.27 now that they no longer move at cast). That is a limit of the bot, not a finding about the skills.
- **Six slots** (balanced=6): 4.82 against 4.48 rounds with greedy; strike damage falls from 10.0 to 9.0 per battle, prop and ground damage rise. A small shift, within what one rerun can move.
- **Stamina:** battles get shorter, because movement no longer competes with Strikes for AP (strike damage 10.0 → 11.8 per battle with greedy, 8.4 → 12.8 with tactic; length 4.48 → 3.90 and 5.91 → 4.41). The size of the pool shows no slope (48 / 52 / 49 %): with +1 per round and once-per-turn movement a pool of 2 is rarely empty in a battle of four rounds. Without regeneration (`stamina=0`) length returns to 4.66.
- **Side balance:** several greedy rows give side 1 about 56 % (107 / 146, 110 / 143 twice), others are level; teams are random and not side-swapped. A lead to check, not established.

**Follow-up:** T13 (length target, vein rule), T39 (vein rule), T03 (stat values: HP, Movement, initiative), T40 (prop rework, Stamina, slots), T10 (prop skills). No rule, price or kit is approved by this entry.

## S027 · 2026-11-14 · Charged Dragon Veins with the damage at the end of the round

**State:** main, base `593f770` dirty (switches of S025/S026 plus `vein_charge_late`, all off by default; no resource change); content `2026-11-13.1`, kit set `a30a9be42850`; Godot 4.7.2, normal CPU settings, runs in parallel. Battle suite before the runs: 165 cases, 0 errors, 0 failures. User idea after S026: the first monster to reach a vein wins it for the round, where it stands afterwards does not matter, and the damage comes at the end of the round.

**Variant** `veinlate` (`sim.gd --variant`, in memory only): as `veincharge` of S026 (every vein charged at round start; first touch, or the occupant at the end of its own turn, takes the charge), but the touch deals no damage. At the end of the round every vein taken in that round deals 1 damage to the enemy nearest to it, for the side that took it, in the same simultaneous step as surround damage. The greedy bot scores a taken vein for the side that took it. Other settings as S026.

**Runs:** greedy, authored stats: 2 variants × 4 seeds (202–505) × 32 = 256 battles. Tactic both sides: 4 seeds × 8 = 32 battles. Greedy with `mixstats`: 6 seeds (202–707) × 80 = 480 battles. `--paired` with the S025/S026 rows of the same seeds, **not side-swapped**; the comparison rows below are copied from S025/S026, not rerun. Each run was executed twice (full block, then `--compact`); the second execution is an exact rerun.

### Exact histogram summary, authored stats

| Bot | Variant | Battles | Round sum / battles = mean | Ended <2 / >5 · longest | Defeats before own first turn | Damage per battle: strike / ground / collision / vein / total |
|---|---|---|---|---|---|---|
| greedy | veinlate | 128 | 326/128 = 2.547 | 1 / 0 · 5 | 8 | 5.3 / 2.9 / 12.0 / 4.4 / 25.2 |
| greedy | nocastpush (S025) | 128 | 437/128 = 3.414 | 0 / 3 · 6 | 0 | 10.0 / 2.8 / 3.8 / 8.2 / 26.0 |
| greedy | nocastpush,veincharge (S026) | 128 | 459/128 = 3.586 | 0 / 4 · 6 | 10 | 9.8 / 2.2 / 3.6 / 7.9 / 24.5 |
| greedy | nocastpush,veinlate | 128 | 466/128 = 3.641 | 0 / 4 · 7 | 0 | 10.8 / 2.7 / 4.2 / 7.4 / 26.3 |
| tactic | nocastpush (S025) | 32 | 108/32 = 3.375 | 0 / 0 · 5 | 0 | 7.3 / 3.3 / 3.9 / 8.9 / 24.5 |
| tactic | nocastpush,veincharge (S026) | 32 | 143/32 = 4.469 | 0 / 7 · 7 | 2 | 7.8 / 2.7 / 3.4 / 9.4 / 24.0 |
| tactic | nocastpush,veinlate | 32 | 137/32 = 4.281 | 0 / 6 · 7 | 0 | 8.1 / 3.1 / 4.4 / 9.3 / 26.2 |

### Team win rate by fielded stat band, greedy with `mixstats`

480 battles per variant; each cell wins / times fielded on a team. Team win rates conditional on a fielded stat, not individual win rates or prices; about ±3 points of band noise.

| Stat band | nocastpush (S026) | + veincharge (S026) | + veinlate |
|---|---|---|---|
| Mean rounds | 3.31 | 3.68 | 3.61 |
| Defeats before own first turn | 2 | 12 | 2 |
| HP 3–4 | 381/928 = 41 % | 388/928 = 42 % | 371/928 = 40 % |
| HP 5–6 | 497/998 = 50 % | 493/998 = 49 % | 490/998 = 49 % |
| HP 7–8 | 544/954 = 57 % | 559/954 = 59 % | 561/954 = 59 % |
| Initiative 1–3 | 492/979 = 50 % | 444/979 = 45 % | 455/979 = 46 % |
| Initiative 4–6 | 461/946 = 49 % | 478/946 = 51 % | 458/946 = 48 % |
| Initiative 7–9 | 469/955 = 49 % | 518/955 = 54 % | 509/955 = 53 % |
| Movement 1–2 | 529/1155 = 46 % | 544/1155 = 47 % | 537/1155 = 46 % |
| Movement 3 | 298/580 = 51 % | 312/580 = 54 % | 292/580 = 50 % |
| Movement 4–5 | 595/1145 = 52 % | 584/1145 = 51 % | 593/1145 = 52 % |
| Reach 2 / 3 / 4 | 49 / 49 / 50 % | 51 / 50 / 50 % | 49 / 50 / 49 % |
| TPR 1 / 2 | 45 / 54 % | 46 / 54 % | 44 / 54 % |
| AP 2 / 3 | 46 / 53 % | 46 / 54 % | 46 / 53 % |

### Compact rows

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used | Reached pressure: HP leader won / lost / HP level / no winner | Rounds under 3 / over 7 / over 10 (%) · longest | First defeat in round (mean) | Defeated before own first turn (per battle) | Wellspring / surrounded: last defeat · all defeats · damage (%) · Wellsprings held per round end, side 0 / 1 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| veinlate | 3v3 · 202 · 32 | 13 / 19 / 0 / 0 | 2.4 | 100 % | 22 / 0 / 0 / 16 / 34 / 0 / 0 | 16 / 0 / 0 / 14 / 53 / 0 / 0 | 22 / 0 / 0 / 13 / 46 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 24.78 | 2.7 / 0.0 / 0.0 / 8.8 / 4.2 / 7.0 / 1.3 | 6.8 / 0.0 / 0.0 / 4.9 / 6.8 / 5.5 / 0.0 | 0.39 / — / — / 1.81 / 0.62 / 1.28 | run 17 % | cinder_dive, set_gong, snare | 0 / 0 / 0 / 0 | 63 / 0 / 0 · 4 | 1.1 | 0.12 | 22 / 0 · 11 / 2 · 16 / 1 · 1.25 / 1.17 |
| veinlate | 3v3 · 303 · 32 | 8 / 24 / 0 / 0 | 2.5 | 100 % | 19 / 0 / 0 / 13 / 47 / 0 / 0 | 18 / 0 / 0 / 12 / 55 / 0 / 0 | 22 / 0 / 0 / 12 / 47 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 24.41 | 2.8 / 0.0 / 0.0 / 8.5 / 3.7 / 7.9 / 0.9 | 7.3 / 0.0 / 0.0 / 4.6 / 6.8 / 5.4 / 0.0 | 0.39 / — / — / 1.86 / 0.55 / 1.47 | run 20 % | set_gong, snare | 0 / 0 / 0 / 0 | 59 / 0 / 0 · 4 | 1.1 | 0.06 | 19 / 3 · 11 / 2 · 17 / 1 · 1.13 / 1.35 |
| veinlate | 3v3 · 404 · 32 | 16 / 15 / 1 / 0 | 2.6 | 100 % | 25 / 0 / 0 / 22 / 28 / 0 / 0 | 16 / 0 / 0 / 19 / 51 / 0 / 0 | 22 / 0 / 0 / 12 / 46 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.31 | 3.0 / 0.0 / 0.0 / 10.4 / 3.3 / 7.0 / 0.8 | 7.2 / 0.0 / 0.0 / 5.1 / 6.3 / 5.4 / 0.0 | 0.41 / — / — / 2.04 / 0.52 / 1.30 | run 13 % | snare | 0 / 0 / 0 / 0 | 56 / 0 / 0 · 5 | 1.1 | 0.03 | 22 / 3 · 9 / 4 · 17 / 2 · 1.20 / 1.22 |
| veinlate | 3v3 · 505 · 32 | 17 / 15 / 0 / 0 | 2.7 | 100 % | 25 / 0 / 0 / 16 / 28 / 0 / 0 | 19 / 0 / 0 / 12 / 53 / 0 / 0 | 19 / 0 / 0 / 10 / 51 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.38 | 2.5 / 0.0 / 0.0 / 10.5 / 4.0 / 8.1 / 1.2 | 6.8 / 0.0 / 0.0 / 5.0 / 6.7 / 5.6 / 0.0 | 0.37 / — / — / 2.12 / 0.59 / 1.45 | run 16 % | cinder_dive, snare | 0 / 0 / 0 / 0 | 44 / 0 / 0 · 4 | 1.1 | 0.03 | 25 / 0 · 11 / 3 · 19 / 1 · 1.13 / 1.35 |
| nocastpush,veinlate | 3v3 · 202 · 32 | 13 / 19 / 0 / 0 | 3.5 | 100 % | 38 / 0 / 0 / 13 / 19 / 0 / 0 | 36 / 0 / 0 / 12 / 29 / 0 / 0 | 40 / 0 / 0 / 12 / 17 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.41 | 5.6 / 0.0 / 0.0 / 2.9 / 8.7 / 13.3 / 3.7 | 6.8 / 0.0 / 0.0 / 4.9 / 6.8 / 5.5 / 0.0 | 0.82 / — / — / 0.60 / 1.27 / 2.43 | run 21 % | snare | 0 / 0 / 0 / 0 | 6 / 0 / 0 · 5 | 1.6 | 0.00 | 31 / 0 · 14 / 8 · 26 / 4 · 1.08 / 1.31 |
| nocastpush,veinlate | 3v3 · 303 · 32 | 16 / 16 / 0 / 0 | 3.6 | 100 % | 28 / 0 / 0 / 9 / 9 / 0 / 0 | 33 / 0 / 0 / 14 / 26 / 0 / 0 | 42 / 0 / 0 / 11 / 15 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.19 | 5.9 / 0.0 / 0.0 / 2.8 / 8.8 / 12.2 / 4.0 | 7.3 / 0.0 / 0.0 / 4.6 / 6.8 / 5.4 / 0.0 | 0.82 / — / — / 0.61 / 1.30 / 2.27 | run 20 % | cinder_dive | 0 / 0 / 0 / 0 | 6 / 0 / 0 · 6 | 1.6 | 0.00 | 50 / 3 · 23 / 3 · 29 / 3 · 1.20 / 1.24 |
| nocastpush,veinlate | 3v3 · 404 · 32 | 14 / 17 / 1 / 0 | 3.8 | 100 % | 44 / 0 / 0 / 6 / 9 / 0 / 0 | 43 / 0 / 0 / 9 / 22 / 0 / 0 | 42 / 0 / 0 / 9 / 17 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.19 | 6.2 / 0.0 / 0.0 / 3.2 / 8.3 / 12.9 / 4.3 | 7.2 / 0.0 / 0.0 / 5.1 / 6.3 / 5.4 / 0.0 | 0.86 / — / — / 0.63 / 1.32 / 2.38 | run 17 % | snare | 0 / 0 / 0 / 0 | 9 / 0 / 0 · 6 | 1.6 | 0.00 | 31 / 9 · 15 / 7 · 28 / 5 · 1.17 / 1.08 |
| nocastpush,veinlate | 3v3 · 505 · 32 | 11 / 20 / 1 / 0 | 3.7 | 100 % | 38 / 0 / 0 / 0 / 9 / 0 / 0 | 45 / 0 / 0 / 9 / 18 / 0 / 0 | 41 / 0 / 0 / 10 / 15 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 27.47 | 6.3 / 0.0 / 0.0 / 3.7 / 9.2 / 13.7 / 4.2 | 6.8 / 0.0 / 0.0 / 5.0 / 6.7 / 5.6 / 0.0 | 0.93 / — / — / 0.74 / 1.38 / 2.46 | run 18 % | cinder_dive | 0 / 0 / 0 / 0 | 9 / 0 / 0 · 7 | 1.8 | 0.00 | 50 / 3 · 21 / 6 · 29 / 4 · 1.07 / 1.40 |
| nocastpush,veinlate + bots tactic | 3v3 · 202 · 8 | 5 / 3 / 0 / 0 | 3.9 | 100 % | 13 / 0 / 0 / 0 / 25 / 0 / 0 | 20 / 0 / 0 / 14 / 34 / 0 / 0 | 28 / 0 / 0 / 14 / 19 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.38 | 4.1 / 0.0 / 0.0 / 2.0 / 9.8 / 14.4 / 7.5 | 7.0 / 0.0 / 0.0 / 4.6 / 7.0 / 5.4 / 0.0 | 0.59 / — / — / 0.43 / 1.39 / 2.67 | run 24 % | asdf, cinder_dive, new_skill, snare | 0 / 0 / 0 / 0 | 0 / 0 / 0 · 5 | 1.5 | 0.00 | 50 / 13 · 20 / 11 · 33 / 5 · 1.43 / 1.07 |
| nocastpush,veinlate + bots tactic | 3v3 · 303 · 8 | 5 / 2 / 1 / 0 | 4.2 | 100 % | 13 / 0 / 0 / 25 / 13 / 0 / 0 | 31 / 0 / 0 / 23 / 14 / 0 / 0 | 34 / 0 / 0 / 15 / 11 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.38 | 5.0 / 0.0 / 0.0 / 2.8 / 11.5 / 12.4 / 7.6 | 7.1 / 0.0 / 0.0 / 4.6 / 6.6 / 5.6 / 0.0 | 0.70 / — / — / 0.59 / 1.74 / 2.20 | Step 19 % | asdf, asdf_3, snare, strike_thrust | 0 / 0 / 0 / 0 | 0 / 0 / 0 · 6 | 1.8 | 0.00 | 50 / 0 · 20 / 9 · 35 / 4 · 1.47 / 1.00 |
| nocastpush,veinlate + bots tactic | 3v3 · 404 · 8 | 3 / 5 / 0 / 0 | 4.4 | 100 % | 38 / 0 / 0 / 13 / 13 / 0 / 0 | 38 / 0 / 0 / 12 / 29 / 0 / 0 | 32 / 0 / 0 / 8 / 22 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.12 | 4.6 / 0.0 / 0.0 / 5.8 / 10.1 / 13.4 / 11.0 | 7.1 / 0.0 / 0.0 / 5.4 / 6.2 / 5.2 / 0.0 | 0.65 / — / — / 1.07 / 1.62 / 2.55 | Step 25 % | snare, strike_thrust | 0 / 0 / 0 / 0 | 0 / 0 / 0 · 6 | 1.5 | 0.00 | 25 / 13 · 15 / 6 · 33 / 6 · 1.30 / 1.00 |
| nocastpush,veinlate + bots tactic | 3v3 · 505 · 8 | 4 / 4 / 0 / 0 | 4.6 | 100 % | 25 / 0 / 0 / 0 / 0 / 0 / 0 | 32 / 0 / 0 / 12 / 26 / 0 / 0 | 30 / 0 / 0 / 11 / 15 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.12 | 4.9 / 0.0 / 0.0 / 4.0 / 12.0 / 14.9 / 9.9 | 6.9 / 0.0 / 0.0 / 4.5 / 7.1 / 5.5 / 0.0 | 0.71 / — / — / 0.89 / 1.68 / 2.70 | Step 22 % | new_skill, snare | 0 / 0 / 0 / 0 | 0 / 0 / 0 · 7 | 1.8 | 0.00 | 75 / 0 · 26 / 3 · 41 / 3 · 0.91 / 1.51 |
| mixstats,nocastpush,veinlate | 3v3 · 202 · 80 | 42 / 37 / 1 / 0 | 3.6 | 100 % | 31 / 0 / 0 / 8 / 15 / 0 / 0 | 33 / 0 / 0 / 13 / 29 / 0 / 0 | 36 / 0 / 0 / 13 / 19 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 27.93 | 5.6 / 0.0 / 0.0 / 2.8 / 11.2 / 12.5 / 5.4 | 7.2 / 0.0 / 0.0 / 4.8 / 6.6 / 5.3 / 0.0 | 0.78 / — / — / 0.59 / 1.69 / 2.35 | run 15 % | none | 0 / 0 / 0 / 0 | 14 / 1 / 0 · 8 | 2.0 | 0.00 | 40 / 4 · 21 / 3 · 26 / 4 · 1.18 / 1.22 |
| mixstats,nocastpush,veinlate | 3v3 · 303 · 80 | 44 / 34 / 2 / 0 | 3.5 | 100 % | 28 / 0 / 0 / 13 / 16 / 0 / 0 | 33 / 0 / 0 / 19 / 21 / 0 / 0 | 36 / 0 / 0 / 15 / 18 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 27.98 | 5.5 / 0.0 / 0.0 / 3.2 / 11.5 / 13.0 / 5.6 | 7.1 / 0.0 / 0.0 / 4.6 / 6.8 / 5.5 / 0.0 | 0.77 / — / — / 0.68 / 1.71 / 2.38 | run 17 % | none | 0 / 0 / 0 / 0 | 10 / 0 / 0 · 7 | 1.9 | 0.01 | 38 / 6 · 20 / 5 · 26 / 4 · 1.22 / 1.25 |
| mixstats,nocastpush,veinlate | 3v3 · 404 · 80 | 45 / 35 / 0 / 0 | 3.6 | 99 % | 25 / 0 / 0 / 16 / 18 / 0 / 0 | 35 / 0 / 0 / 19 / 22 / 0 / 0 | 36 / 0 / 0 / 14 / 18 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 28.24 | 5.8 / 0.0 / 0.0 / 3.4 / 10.5 / 12.6 / 5.7 | 7.2 / 0.0 / 0.0 / 5.0 / 6.4 / 5.4 / 0.0 | 0.82 / — / — / 0.68 / 1.63 / 2.32 | run 15 % | none | 0 / 0 / 1 / 0 | 8 / 1 / 0 · 9 | 1.9 | 0.00 | 39 / 3 · 18 / 5 · 26 / 5 · 1.26 / 1.16 |
| mixstats,nocastpush,veinlate | 3v3 · 505 · 80 | 36 / 43 / 1 / 0 | 3.7 | 99 % | 19 / 0 / 0 / 16 / 18 / 0 / 0 | 34 / 0 / 0 / 20 / 22 / 0 / 0 | 34 / 0 / 0 / 16 / 18 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 28.04 | 5.5 / 0.0 / 0.0 / 3.7 / 11.0 / 13.2 / 5.8 | 7.0 / 0.0 / 0.0 / 4.9 / 6.7 / 5.5 / 0.0 | 0.78 / — / — / 0.76 / 1.65 / 2.42 | run 17 % | none | 0 / 1 / 0 / 0 | 9 / 1 / 0 · 9 | 1.9 | 0.01 | 44 / 4 · 18 / 4 · 27 / 4 · 1.18 / 1.18 |
| mixstats,nocastpush,veinlate | 3v3 · 606 · 80 | 39 / 40 / 1 / 0 | 3.6 | 100 % | 20 / 0 / 0 / 16 / 14 / 0 / 0 | 32 / 0 / 0 / 17 / 23 / 0 / 0 | 36 / 0 / 0 / 15 / 18 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 28.01 | 5.7 / 0.0 / 0.0 / 3.4 / 10.8 / 12.1 / 5.3 | 7.3 / 0.0 / 0.0 / 4.9 / 6.5 / 5.4 / 0.0 | 0.79 / — / — / 0.69 / 1.67 / 2.25 | run 15 % | none | 0 / 0 / 0 / 0 | 13 / 0 / 0 · 6 | 2.0 | 0.00 | 39 / 9 · 20 / 5 · 26 / 4 · 1.18 / 1.18 |
| mixstats,nocastpush,veinlate | 3v3 · 707 · 80 | 44 / 35 / 1 / 0 | 3.6 | 100 % | 28 / 0 / 0 / 9 / 14 / 0 / 0 | 36 / 0 / 0 / 14 / 23 / 0 / 0 | 36 / 0 / 0 / 14 / 18 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 28.20 | 5.7 / 0.0 / 0.0 / 3.5 / 11.1 / 12.5 / 6.0 | 7.3 / 0.0 / 0.0 / 4.7 / 6.6 / 5.4 / 0.0 | 0.78 / — / — / 0.75 / 1.69 / 2.33 | Step 15 % | none | 0 / 0 / 0 / 0 | 11 / 0 / 0 · 7 | 2.1 | 0.00 | 44 / 5 · 21 / 4 · 27 / 4 · 1.25 / 1.25 |

**Observations** (indications; bots on working content, not tuned for these rules):

- **The early defeats of S026 are gone:** with `nocastpush,veinlate` no monster is defeated before its own first turn in the authored-stat rows (greedy 0 of 128 battles, tactic 0 of 32; `veincharge` 10 and 2), and 2 against 12 with random stats, the level of `nocastpush` alone.
- **The initiative slope stays:** 46 / 48 / 53 % against 45 / 51 / 54 % with the immediate discharge and 50 / 49 / 49 % without charged veins. Movement and Reach stay level; HP keeps the steepest slope (40 → 59 %).
- **Length** about as with the immediate discharge: greedy 3.64 (3.59), tactic 4.28 (4.47) with 6 of 32 battles past round 5, longest 7.
- Vein damage per battle (7.4–9.3) is at the level of last-touch ownership; the variant changes who gets it, not how much there is.
- Not measured: human play, side-swapped fairness, one vein instead of three under this rule.

**Follow-up:** T39/T40/T13: human play of `veinlate` with `zone_cast_push` off against the current rule; Movement still has no measured lever (T03). No rule or default is changed by this entry.

## S026 · 2026-11-14 · Charged Dragon Veins and a Step over the full Movement

**State:** main, base `593f770` dirty (the three switches of S025 plus two new ones, all off by default; no resource change); content `2026-11-13.1`, kit set `a30a9be42850`; Godot 4.7.2, normal CPU settings, runs in parallel. Battle suite before the runs: 164 cases, 0 errors, 0 failures. User request: build and measure the charged veins and the basic move.

**Variants** (`sim.gd --variant`, in memory only):
- `veincharge`: every Dragon Vein is charged at the start of a round (round 1 included). The first monster that touches it (walks onto or across it, is pushed or pulled onto it), or the monster standing on it at the end of its own turn, discharges it: 1 damage at once to the enemy nearest to the square (ties as in Battle §4.2, last tie roster order). Then it is empty until the next round. No ownership, no Dragon Vein damage at the end of the round; surround damage unchanged. Late-round pressure `idle` counts a vein discharged in the round as held.
- `fullstep`: the universal Step walks up to the monster's Movement for 1 AP with the walking profile of Run; kits unchanged, so Run stays in the kits that have it.
- `nocastpush`: as in S025. Three veins, authored kits, cost 1 for zone push/pull.
- The greedy bot's ownership term for veins is off under `veincharge` (its copy of the battle already shows the discharge damage); it walks toward charged veins. Neither bot was tuned for the new rules.

**Runs:** greedy, authored stats: 5 new variants × 4 seeds (202–505) × 32 = 640 battles; control and `nocastpush` rows are the S025 runs, repeated here with identical results. Tactic both sides: 2 new variants × 4 seeds × 8 = 64 battles. Greedy with `mixstats` (every monster random stats: HP 3–8, initiative 1–9, Movement 1–5, Reach 2–4, TPR 1–2, AP 2–3): 4 variants × 6 seeds (202–707) × 80 = 1920 battles. All `--paired` within a seed, **not side-swapped**; variants of a seed are correlated. Each run was executed twice (full block, then `--compact`); the second execution is an exact rerun.

### Exact histogram summary, authored stats

| Bot | Variant | Battles | Round sum / battles = mean | Ended <2 / >5 · longest | Defeats before own first turn | Damage per battle: strike / ground / collision / vein / total |
|---|---|---|---|---|---|---|
| greedy | control (S025) | 128 | 308/128 = 2.406 | 3 / 0 · 4 | 8 | 5.0 / 2.3 / 12.2 / 4.8 / 25.0 |
| greedy | veincharge | 128 | 335/128 = 2.617 | 0 / 0 · 5 | 18 | 4.9 / 2.5 / 11.1 / 5.5 / 24.5 |
| greedy | fullstep | 128 | 309/128 = 2.414 | 3 / 0 · 4 | 8 | 6.2 / 2.3 / 11.8 / 4.8 / 25.6 |
| greedy | veincharge,fullstep | 128 | 339/128 = 2.648 | 3 / 0 · 5 | 17 | 6.5 / 2.4 / 10.5 / 5.7 / 25.5 |
| greedy | nocastpush (S025) | 128 | 437/128 = 3.414 | 0 / 3 · 6 | 0 | 10.0 / 2.8 / 3.8 / 8.2 / 26.0 |
| greedy | nocastpush,veincharge | 128 | 459/128 = 3.586 | 0 / 4 · 6 | 10 | 9.8 / 2.2 / 3.6 / 7.9 / 24.5 |
| greedy | nocastpush,veincharge,fullstep | 128 | 459/128 = 3.586 | 0 / 8 · 9 | 11 | 10.0 / 2.8 / 3.9 / 7.9 / 25.5 |
| tactic | control (S025) | 32 | 77/32 = 2.406 | 0 / 0 · 4 | 3 | 2.9 / 2.8 / 14.5 / 4.5 / 25.5 |
| tactic | nocastpush (S025) | 32 | 108/32 = 3.375 | 0 / 0 · 5 | 0 | 7.3 / 3.3 / 3.9 / 8.9 / 24.5 |
| tactic | nocastpush,veincharge | 32 | 143/32 = 4.469 | 0 / 7 · 7 | 2 | 7.8 / 2.7 / 3.4 / 9.4 / 24.0 |
| tactic | nocastpush,veincharge,fullstep | 32 | 119/32 = 3.719 | 0 / 2 · 7 | 3 | 8.6 / 2.2 / 3.2 / 9.2 / 24.1 |

Damage per battle is the mean of the per-seed “per battle” rows (rounded inputs); the other columns are exact counts.

### Team win rate by fielded stat band, greedy with `mixstats`

480 battles per variant (6 seeds × 80). Each cell: wins / times fielded on a team. **Team win rates conditional on a fielded stat, not individual win rates or prices;** bands pool the per-value rows of the six full blocks. A band of about 950 fielded slots moves by roughly ±3 points between seeds.

| Stat band | nocastpush | + veincharge | + fullstep | + veincharge,fullstep |
|---|---|---|---|---|
| Mean rounds | 3.31 | 3.68 | 3.19 | 3.39 |
| HP 3–4 | 381/928 = 41 % | 388/928 = 42 % | 369/928 = 40 % | 366/928 = 39 % |
| HP 5–6 | 497/998 = 50 % | 493/998 = 49 % | 480/998 = 48 % | 519/998 = 52 % |
| HP 7–8 | 544/954 = 57 % | 559/954 = 59 % | 552/954 = 58 % | 555/954 = 58 % |
| Initiative 1–3 | 492/979 = 50 % | 444/979 = 45 % | 489/979 = 50 % | 447/979 = 46 % |
| Initiative 4–6 | 461/946 = 49 % | 478/946 = 51 % | 461/946 = 49 % | 473/946 = 50 % |
| Initiative 7–9 | 469/955 = 49 % | 518/955 = 54 % | 451/955 = 47 % | 520/955 = 54 % |
| Movement 1–2 | 529/1155 = 46 % | 544/1155 = 47 % | 502/1155 = 43 % | 522/1155 = 45 % |
| Movement 3 | 298/580 = 51 % | 312/580 = 54 % | 299/580 = 52 % | 307/580 = 53 % |
| Movement 4–5 | 595/1145 = 52 % | 584/1145 = 51 % | 600/1145 = 52 % | 611/1145 = 53 % |
| Reach 2 / 3 / 4 | 49 / 49 / 50 % | 51 / 50 / 50 % | 49 / 48 / 49 % | 50 / 50 / 50 % |
| TPR 1 / 2 | 45 / 54 % | 46 / 54 % | 44 / 53 % | 47 / 53 % |
| AP 2 / 3 | 46 / 53 % | 46 / 54 % | 44 / 53 % | 47 / 54 % |

### Compact rows, greedy, authored stats

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used | Reached pressure: HP leader won / lost / HP level / no winner | Rounds under 3 / over 7 / over 10 (%) · longest | First defeat in round (mean) | Defeated before own first turn (per battle) | Wellspring / surrounded: last defeat · all defeats · damage (%) · Wellsprings held per round end, side 0 / 1 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| veincharge | 3v3 · 202 · 32 | 16 / 16 / 0 / 0 | 2.5 | 100 % | 31 / 0 / 0 / 19 / 19 / 0 / 0 | 19 / 0 / 0 / 13 / 52 / 0 / 0 | 21 / 0 / 0 / 12 / 43 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 24.56 | 2.6 / 0.0 / 0.0 / 8.2 / 4.4 / 7.1 / 1.0 | 6.8 / 0.0 / 0.0 / 4.9 / 6.8 / 5.5 / 0.0 | 0.38 / — / — / 1.69 / 0.64 / 1.30 | run 18 % | cinder_dive, set_gong, snare | 0 / 0 / 0 / 0 | 53 / 0 / 0 · 4 | 1.1 | 0.19 | 31 / 0 · 15 / 2 · 22 / 1 · 1.27 / 1.35 |
| veincharge | 3v3 · 303 · 32 | 8 / 24 / 0 / 0 | 2.6 | 100 % | 19 / 0 / 0 / 9 / 41 / 0 / 0 | 17 / 0 / 0 / 13 / 52 / 0 / 0 | 21 / 0 / 0 / 9 / 44 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 23.81 | 2.7 / 0.0 / 0.0 / 8.1 / 3.3 / 7.7 / 0.8 | 7.3 / 0.0 / 0.0 / 4.6 / 6.8 / 5.4 / 0.0 | 0.37 / — / — / 1.76 / 0.50 / 1.43 | run 20 % | cinder_dive, snare | 0 / 0 / 0 / 0 | 53 / 0 / 0 · 5 | 1.0 | 0.09 | 25 / 0 · 14 / 1 · 23 / 1 · 1.29 / 1.31 |
| veincharge | 3v3 · 404 · 32 | 14 / 18 / 0 / 0 | 2.5 | 100 % | 19 / 0 / 0 / 9 / 44 / 0 / 0 | 14 / 0 / 0 / 14 / 58 / 0 / 0 | 20 / 0 / 0 / 9 / 47 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 24.16 | 2.5 / 0.0 / 0.0 / 9.1 / 3.1 / 7.2 / 0.8 | 7.2 / 0.0 / 0.0 / 5.1 / 6.3 / 5.4 / 0.0 | 0.35 / — / — / 1.77 / 0.49 / 1.33 | run 14 % | cinder_dive, snare | 0 / 0 / 0 / 0 | 56 / 0 / 0 · 4 | 1.1 | 0.12 | 25 / 3 · 11 / 2 · 22 / 2 · 1.16 / 1.41 |
| veincharge | 3v3 · 505 · 32 | 14 / 18 / 0 / 0 | 2.8 | 100 % | 13 / 0 / 0 / 19 / 41 / 0 / 0 | 15 / 0 / 0 / 12 / 55 / 0 / 0 | 18 / 0 / 0 / 10 / 47 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.47 | 2.4 / 0.0 / 0.0 / 9.7 / 3.8 / 8.5 / 1.5 | 6.8 / 0.0 / 0.0 / 5.0 / 6.7 / 5.6 / 0.0 | 0.35 / — / — / 1.94 / 0.57 / 1.53 | run 18 % | set_gong, snare | 0 / 0 / 0 / 0 | 34 / 0 / 0 · 5 | 1.1 | 0.16 | 22 / 3 · 12 / 4 · 23 / 1 · 1.17 / 1.33 |
| fullstep | 3v3 · 202 · 32 | 15 / 17 / 0 / 0 | 2.3 | 100 % | 22 / 0 / 0 / 22 / 31 / 0 / 0 | 21 / 0 / 0 / 8 / 54 / 0 / 0 | 22 / 0 / 0 / 8 / 49 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 24.78 | 2.8 / 0.0 / 0.0 / 7.6 / 3.2 / 4.0 / 5.2 | 6.8 / 0.0 / 0.0 / 4.9 / 6.8 / 5.5 / 0.0 | 0.41 / — / — / 1.56 / 0.47 / 0.74 | Step 23 % | cinder_dive, set_gong, snare | 0 / 0 / 0 / 0 | 69 / 0 / 0 · 4 | 1.1 | 0.12 | 22 / 0 · 13 / 1 · 18 / 1 · 1.62 / 1.26 |
| fullstep | 3v3 · 303 · 32 | 11 / 21 / 0 / 0 | 2.4 | 100 % | 28 / 0 / 0 / 16 / 28 / 0 / 0 | 18 / 0 / 0 / 13 / 53 / 0 / 0 | 23 / 0 / 0 / 11 / 45 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.56 | 3.1 / 0.0 / 0.0 / 8.2 / 3.7 / 4.3 / 4.8 | 7.3 / 0.0 / 0.0 / 4.6 / 6.8 / 5.4 / 0.0 | 0.43 / — / — / 1.79 / 0.54 / 0.81 | Step 20 % | snare | 0 / 0 / 0 / 0 | 56 / 0 / 0 · 4 | 1.0 | 0.06 | 19 / 6 · 11 / 3 · 19 / 1 · 1.30 / 1.56 |
| fullstep | 3v3 · 404 · 32 | 14 / 18 / 0 / 0 | 2.4 | 100 % | 16 / 0 / 0 / 19 / 44 / 0 / 0 | 23 / 0 / 0 / 13 / 49 / 0 / 0 | 26 / 0 / 0 / 8 / 46 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.34 | 3.3 / 0.0 / 0.0 / 8.3 / 2.5 / 4.6 / 4.9 | 7.2 / 0.0 / 0.0 / 5.1 / 6.3 / 5.4 / 0.0 | 0.47 / — / — / 1.62 / 0.40 / 0.85 | Step 21 % | cinder_dive, snare | 0 / 0 / 0 / 0 | 56 / 0 / 0 · 4 | 1.0 | 0.03 | 22 / 0 · 10 / 4 · 18 / 2 · 1.32 / 1.49 |
| fullstep | 3v3 · 505 · 32 | 13 / 18 / 1 / 0 | 2.4 | 100 % | 16 / 0 / 0 / 3 / 28 / 0 / 0 | 18 / 0 / 0 / 8 / 52 / 0 / 0 | 25 / 0 / 0 / 9 / 44 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.78 | 3.4 / 0.0 / 0.0 / 9.5 / 3.1 / 3.8 / 5.2 | 6.8 / 0.0 / 0.0 / 5.0 / 6.7 / 5.6 / 0.0 | 0.51 / — / — / 1.92 / 0.47 / 0.67 | Step 21 % | cinder_dive, set_gong | 0 / 0 / 0 / 0 | 56 / 0 / 0 · 3 | 1.1 | 0.03 | 50 / 0 · 19 / 1 · 20 / 1 · 1.13 / 1.66 |
| veincharge,fullstep | 3v3 · 202 · 32 | 15 / 17 / 0 / 0 | 2.7 | 100 % | 19 / 0 / 0 / 9 / 47 / 0 / 0 | 22 / 0 / 0 / 9 / 53 / 0 / 0 | 26 / 0 / 0 / 8 / 41 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.28 | 3.2 / 0.0 / 0.0 / 7.5 / 2.9 / 3.8 / 5.5 | 6.8 / 0.0 / 0.0 / 4.9 / 6.8 / 5.5 / 0.0 | 0.48 / — / — / 1.53 / 0.42 / 0.69 | Step 24 % | set_gong, snare | 0 / 0 / 0 / 0 | 56 / 0 / 0 · 5 | 1.1 | 0.19 | 25 / 0 · 12 / 1 · 23 / 1 · 1.09 / 1.42 |
| veincharge,fullstep | 3v3 · 303 · 32 | 18 / 14 / 0 / 0 | 2.7 | 100 % | 34 / 0 / 0 / 9 / 31 / 0 / 0 | 24 / 0 / 0 / 10 / 55 / 0 / 0 | 26 / 0 / 0 / 11 / 38 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.16 | 3.7 / 0.0 / 0.0 / 7.3 / 3.4 / 3.5 / 5.2 | 7.3 / 0.0 / 0.0 / 4.6 / 6.8 / 5.4 / 0.0 | 0.51 / — / — / 1.59 / 0.50 / 0.65 | Step 23 % | set_gong, snare | 0 / 0 / 0 / 0 | 38 / 0 / 0 · 4 | 1.0 | 0.06 | 22 / 0 · 9 / 0 · 22 / 1 · 1.38 / 1.22 |
| veincharge,fullstep | 3v3 · 404 · 32 | 13 / 19 / 0 / 0 | 2.7 | 100 % | 22 / 0 / 0 / 6 / 38 / 0 / 0 | 20 / 0 / 0 / 11 / 55 / 0 / 0 | 25 / 0 / 0 / 9 / 42 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.69 | 3.2 / 0.0 / 0.0 / 8.6 / 2.8 / 3.8 / 4.7 | 7.2 / 0.0 / 0.0 / 5.1 / 6.3 / 5.4 / 0.0 | 0.45 / — / — / 1.68 / 0.45 / 0.69 | Step 20 % | cinder_dive, set_gong, shove, snare | 0 / 0 / 0 / 0 | 44 / 0 / 0 · 4 | 1.0 | 0.12 | 28 / 3 · 10 / 3 · 22 / 1 · 1.31 / 1.25 |
| veincharge,fullstep | 3v3 · 505 · 32 | 13 / 19 / 0 / 0 | 2.5 | 100 % | 22 / 0 / 0 / 9 / 38 / 0 / 0 | 22 / 0 / 0 / 11 / 54 / 0 / 0 | 24 / 0 / 0 / 9 / 43 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 24.91 | 3.1 / 0.0 / 0.0 / 8.0 / 3.3 / 3.6 / 5.4 | 6.8 / 0.0 / 0.0 / 5.0 / 6.7 / 5.6 / 0.0 | 0.45 / — / — / 1.62 / 0.50 / 0.65 | Step 23 % | cinder_dive, snare | 0 / 0 / 0 / 0 | 50 / 0 / 0 · 4 | 1.0 | 0.16 | 25 / 3 · 11 / 1 · 23 / 1 · 1.04 / 1.58 |
| nocastpush,veincharge | 3v3 · 202 · 32 | 15 / 17 / 0 / 0 | 3.8 | 100 % | 22 / 0 / 0 / 22 / 6 / 0 / 0 | 34 / 0 / 0 / 14 / 25 / 0 / 0 | 38 / 0 / 0 / 11 / 16 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.66 | 5.4 / 0.0 / 0.0 / 3.2 / 8.4 / 13.2 / 3.6 | 6.8 / 0.0 / 0.0 / 4.9 / 6.8 / 5.5 / 0.0 | 0.80 / — / — / 0.65 / 1.23 / 2.42 | run 21 % | none | 0 / 0 / 0 / 0 | 6 / 0 / 0 · 6 | 1.7 | 0.09 | 47 / 3 · 22 / 4 · 32 / 3 · 1.09 / 1.31 |
| nocastpush,veincharge | 3v3 · 303 · 32 | 16 / 16 / 0 / 0 | 3.5 | 100 % | 34 / 0 / 0 / 3 / 25 / 0 / 0 | 43 / 0 / 0 / 10 / 20 / 0 / 0 | 44 / 0 / 0 / 9 / 13 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 23.75 | 5.8 / 0.0 / 0.0 / 2.0 / 7.0 / 11.6 / 3.1 | 7.3 / 0.0 / 0.0 / 4.6 / 6.8 / 5.4 / 0.0 | 0.80 / — / — / 0.44 / 1.04 / 2.16 | run 21 % | snare | 0 / 0 / 0 / 0 | 9 / 0 / 0 · 5 | 1.6 | 0.03 | 34 / 0 · 23 / 1 · 30 / 3 · 1.28 / 1.19 |
| nocastpush,veincharge | 3v3 · 404 · 32 | 13 / 19 / 0 / 0 | 3.5 | 100 % | 31 / 0 / 0 / 3 / 9 / 0 / 0 | 39 / 0 / 0 / 10 / 21 / 0 / 0 | 39 / 0 / 0 / 7 / 16 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 23.50 | 5.3 / 0.0 / 0.0 / 2.7 / 7.2 / 11.9 / 3.6 | 7.2 / 0.0 / 0.0 / 5.1 / 6.3 / 5.4 / 0.0 | 0.74 / — / — / 0.52 / 1.15 / 2.21 | run 17 % | snare | 0 / 0 / 0 / 0 | 22 / 0 / 0 · 6 | 1.5 | 0.06 | 50 / 6 · 24 / 5 · 33 / 4 · 1.36 / 1.19 |
| nocastpush,veincharge | 3v3 · 505 · 32 | 11 / 21 / 0 / 0 | 3.6 | 100 % | 28 / 0 / 0 / 9 / 19 / 0 / 0 | 39 / 0 / 0 / 11 / 24 / 0 / 0 | 39 / 0 / 0 / 8 / 15 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.22 | 5.7 / 0.0 / 0.0 / 3.3 / 8.2 / 12.8 / 3.1 | 6.8 / 0.0 / 0.0 / 5.0 / 6.7 / 5.6 / 0.0 | 0.84 / — / — / 0.66 / 1.22 / 2.30 | run 20 % | snare | 0 / 0 / 0 / 0 | 9 / 0 / 0 · 6 | 1.7 | 0.12 | 41 / 3 · 22 / 4 · 33 / 4 · 1.17 / 1.42 |
| nocastpush,veincharge,fullstep | 3v3 · 202 · 32 | 17 / 15 / 0 / 0 | 3.4 | 100 % | 28 / 0 / 0 / 19 / 13 / 0 / 0 | 35 / 0 / 0 / 13 / 27 / 0 / 0 | 38 / 0 / 0 / 10 / 18 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 24.78 | 5.2 / 0.0 / 0.0 / 3.2 / 7.7 / 5.5 / 9.3 | 6.8 / 0.0 / 0.0 / 4.9 / 6.8 / 5.5 / 0.0 | 0.77 / — / — / 0.66 / 1.13 / 1.00 | Step 30 % | snare | 0 / 0 / 0 / 0 | 9 / 0 / 0 · 6 | 1.5 | 0.09 | 31 / 3 · 20 / 2 · 30 / 3 · 1.24 / 1.19 |
| nocastpush,veincharge,fullstep | 3v3 · 303 · 32 | 17 / 15 / 0 / 0 | 3.4 | 100 % | 41 / 0 / 0 / 16 / 9 / 0 / 0 | 43 / 0 / 0 / 19 / 17 / 0 / 0 | 42 / 0 / 0 / 12 / 13 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.25 | 5.6 / 0.0 / 0.0 / 2.6 / 7.0 / 7.1 / 9.2 | 7.3 / 0.0 / 0.0 / 4.6 / 6.8 / 5.4 / 0.0 | 0.77 / — / — / 0.57 / 1.04 / 1.31 | Step 29 % | none | 0 / 0 / 0 / 0 | 16 / 0 / 0 · 5 | 1.5 | 0.03 | 31 / 3 · 16 / 3 · 32 / 2 · 1.48 / 1.13 |
| nocastpush,veincharge,fullstep | 3v3 · 404 · 32 | 18 / 14 / 0 / 0 | 3.7 | 100 % | 22 / 0 / 0 / 13 / 16 / 0 / 0 | 33 / 0 / 0 / 12 / 26 / 0 / 0 | 39 / 0 / 0 / 10 / 17 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.94 | 5.5 / 0.0 / 0.0 / 3.7 / 7.5 / 7.1 / 9.2 | 7.2 / 0.0 / 0.0 / 5.1 / 6.3 / 5.4 / 0.0 | 0.77 / — / — / 0.71 / 1.19 / 1.31 | Step 28 % | snare | 0 / 0 / 0 / 0 | 6 / 0 / 0 · 7 | 1.4 | 0.09 | 44 / 6 · 24 / 5 · 30 / 4 · 1.16 / 1.07 |
| nocastpush,veincharge,fullstep | 3v3 · 505 · 32 | 14 / 18 / 0 / 0 | 3.8 | 97 % | 19 / 0 / 0 / 6 / 22 / 0 / 0 | 41 / 0 / 0 / 14 / 20 / 0 / 0 | 38 / 0 / 0 / 12 / 14 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.91 | 5.6 / 0.0 / 0.0 / 3.7 / 8.3 / 7.1 / 10.0 | 6.8 / 0.0 / 0.0 / 5.0 / 6.7 / 5.6 / 0.0 | 0.82 / — / — / 0.75 / 1.24 / 1.28 | Step 29 % | snare | 0 / 0 / 1 / 0 | 0 / 3 / 0 · 9 | 1.6 | 0.12 | 53 / 0 · 23 / 2 · 33 / 3 · 1.09 / 1.48 |

### Compact rows, tactic on both sides

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used | Reached pressure: HP leader won / lost / HP level / no winner | Rounds under 3 / over 7 / over 10 (%) · longest | First defeat in round (mean) | Defeated before own first turn (per battle) | Wellspring / surrounded: last defeat · all defeats · damage (%) · Wellsprings held per round end, side 0 / 1 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| nocastpush,veincharge + bots tactic | 3v3 · 202 · 8 | 5 / 3 / 0 / 0 | 4.4 | 100 % | 25 / 0 / 0 / 0 / 0 / 0 / 0 | 32 / 0 / 0 / 12 / 26 / 0 / 0 | 36 / 0 / 0 / 14 / 13 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 23.88 | 4.5 / 0.0 / 0.0 / 2.1 / 10.8 / 11.6 / 7.4 | 7.0 / 0.0 / 0.0 / 4.6 / 7.0 / 5.4 / 0.0 | 0.64 / — / — / 0.46 / 1.54 / 2.16 | run 21 % | asdf, coiling_rift, new_skill, shove, snare | 0 / 0 / 0 / 0 | 0 / 0 / 0 · 6 | 1.8 | 0.00 | 75 / 0 · 29 / 0 · 36 / 2 · 1.11 / 1.00 |
| nocastpush,veincharge + bots tactic | 3v3 · 303 · 8 | 6 / 2 / 0 / 0 | 4.2 | 100 % | 25 / 0 / 0 / 0 / 13 / 0 / 0 | 26 / 0 / 0 / 13 / 26 / 0 / 0 | 31 / 0 / 0 / 13 / 14 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 23.62 | 4.5 / 0.0 / 0.0 / 3.5 / 9.8 / 12.8 / 8.4 | 7.1 / 0.0 / 0.0 / 4.6 / 6.6 / 5.6 / 0.0 | 0.63 / — / — / 0.76 / 1.47 / 2.27 | Step 22 % | asdf, new_skill, snare, strike_thrust | 0 / 0 / 0 / 0 | 0 / 0 / 0 · 6 | 1.6 | 0.00 | 63 / 0 · 26 / 10 · 39 / 4 · 1.62 / 0.69 |
| nocastpush,veincharge + bots tactic | 3v3 · 404 · 8 | 6 / 2 / 0 / 0 | 4.5 | 100 % | 38 / 0 / 0 / 13 / 13 / 0 / 0 | 38 / 0 / 0 / 12 / 21 / 0 / 0 | 29 / 0 / 0 / 9 / 18 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 24.62 | 4.6 / 0.0 / 0.0 / 3.4 / 8.9 / 14.2 / 9.1 | 7.1 / 0.0 / 0.0 / 5.4 / 6.2 / 5.2 / 0.0 | 0.65 / — / — / 0.63 / 1.42 / 2.71 | Step 23 % | coiling_rift, new_skill, snare | 0 / 0 / 0 / 0 | 0 / 0 / 0 · 6 | 1.4 | 0.00 | 38 / 0 · 26 / 3 · 40 / 4 · 1.54 / 0.89 |
| nocastpush,veincharge + bots tactic | 3v3 · 505 · 8 | 3 / 5 / 0 / 0 | 4.8 | 100 % | 0 / 0 / 0 / 0 / 13 / 0 / 0 | 34 / 0 / 0 / 14 / 20 / 0 / 0 | 33 / 0 / 0 / 8 / 11 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 24.00 | 4.6 / 0.0 / 0.0 / 2.4 / 9.5 / 14.0 / 9.0 | 6.9 / 0.0 / 0.0 / 4.5 / 7.1 / 5.5 / 0.0 | 0.67 / — / — / 0.53 / 1.33 / 2.55 | run 23 % | coiling_rift, new_skill, snare | 0 / 0 / 0 / 0 | 0 / 0 / 0 · 7 | 1.5 | 0.25 | 88 / 0 · 26 / 6 · 43 / 3 · 0.90 / 1.37 |
| nocastpush,veincharge,fullstep + bots tactic | 3v3 · 202 · 8 | 4 / 4 / 0 / 0 | 3.4 | 100 % | 38 / 0 / 0 / 0 / 25 / 0 / 0 | 34 / 0 / 0 / 17 / 23 / 0 / 0 | 39 / 0 / 0 / 11 / 12 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 23.75 | 5.1 / 0.0 / 0.0 / 1.0 / 8.1 / 1.5 / 15.2 | 7.0 / 0.0 / 0.0 / 4.6 / 7.0 / 5.4 / 0.0 | 0.73 / — / — / 0.22 / 1.16 / 0.28 | Step 49 % | cinder_dive, coiling_rift, run, snare | 0 / 0 / 0 / 0 | 0 / 0 / 0 · 4 | 1.5 | 0.12 | 38 / 0 · 23 / 3 · 33 / 6 · 0.63 / 2.00 |
| nocastpush,veincharge,fullstep + bots tactic | 3v3 · 303 · 8 | 4 / 4 / 0 / 0 | 3.9 | 100 % | 13 / 0 / 0 / 0 / 38 / 0 / 0 | 33 / 0 / 0 / 9 / 27 / 0 / 0 | 35 / 0 / 0 / 9 / 15 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.25 | 5.4 / 0.0 / 0.0 / 2.2 / 8.9 / 2.8 / 17.6 | 7.1 / 0.0 / 0.0 / 4.6 / 6.6 / 5.6 / 0.0 | 0.75 / — / — / 0.49 / 1.34 / 0.49 | Step 48 % | new_skill, run, snare | 0 / 0 / 0 / 0 | 0 / 0 / 0 · 5 | 1.4 | 0.00 | 50 / 0 · 24 / 6 · 38 / 3 · 1.87 / 0.87 |
| nocastpush,veincharge,fullstep + bots tactic | 3v3 · 404 · 8 | 4 / 4 / 0 / 0 | 3.2 | 100 % | 38 / 0 / 0 / 0 / 13 / 0 / 0 | 37 / 0 / 0 / 11 / 19 / 0 / 0 | 37 / 0 / 0 / 7 / 16 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 22.12 | 4.5 / 0.0 / 0.0 / 2.8 / 6.1 / 2.2 / 15.8 | 7.1 / 0.0 / 0.0 / 5.4 / 6.2 / 5.2 / 0.0 | 0.63 / — / — / 0.51 / 0.98 / 0.43 | Step 50 % | fire_trail, run, snare | 0 / 0 / 0 / 0 | 13 / 0 / 0 · 5 | 1.5 | 0.12 | 38 / 13 · 26 / 7 · 37 / 3 · 1.63 / 1.21 |
| nocastpush,veincharge,fullstep + bots tactic | 3v3 · 505 · 8 | 4 / 4 / 0 / 0 | 4.4 | 100 % | 13 / 0 / 0 / 25 / 25 / 0 / 0 | 28 / 0 / 0 / 8 / 25 / 0 / 0 | 33 / 0 / 0 / 9 / 11 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.38 | 4.6 / 0.0 / 0.0 / 2.8 / 10.8 / 2.6 / 20.9 | 6.9 / 0.0 / 0.0 / 4.5 / 7.1 / 5.5 / 0.0 | 0.67 / — / — / 0.61 / 1.51 / 0.48 | Step 50 % | asdf_3, cinder_dive, run, snare, strike_thrust | 0 / 0 / 0 / 0 | 0 / 0 / 0 · 7 | 1.4 | 0.12 | 38 / 0 · 25 / 14 · 44 / 3 · 1.15 / 1.56 |

### Compact rows, greedy with mixstats

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used | Reached pressure: HP leader won / lost / HP level / no winner | Rounds under 3 / over 7 / over 10 (%) · longest | First defeat in round (mean) | Defeated before own first turn (per battle) | Wellspring / surrounded: last defeat · all defeats · damage (%) · Wellsprings held per round end, side 0 / 1 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mixstats,nocastpush | 3v3 · 202 · 80 | 44 / 36 / 0 / 0 | 3.3 | 100 % | 24 / 0 / 0 / 16 / 18 / 0 / 0 | 32 / 0 / 0 / 17 / 25 / 0 / 0 | 34 / 0 / 0 / 12 / 19 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 27.40 | 5.0 / 0.0 / 0.0 / 2.9 / 10.7 / 11.8 / 5.2 | 7.2 / 0.0 / 0.0 / 4.8 / 6.6 / 5.3 / 0.0 | 0.69 / — / — / 0.60 / 1.62 / 2.22 | run 15 % | none | 0 / 0 / 0 / 0 | 10 / 0 / 0 · 5 | 2.0 | 0.00 | 39 / 4 · 18 / 5 · 29 / 4 · 1.37 / 1.53 |
| mixstats,nocastpush | 3v3 · 303 · 80 | 40 / 39 / 1 / 0 | 3.3 | 100 % | 28 / 0 / 0 / 11 / 14 / 0 / 0 | 35 / 0 / 0 / 14 / 23 / 0 / 0 | 36 / 0 / 0 / 14 / 18 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 27.98 | 5.6 / 0.0 / 0.0 / 2.9 / 10.8 / 12.1 / 5.8 | 7.1 / 0.0 / 0.0 / 4.6 / 6.8 / 5.5 / 0.0 | 0.78 / — / — / 0.62 / 1.61 / 2.21 | Step 16 % | none | 0 / 0 / 0 / 0 | 15 / 0 / 0 · 5 | 1.9 | 0.01 | 40 / 5 · 20 / 5 · 28 / 3 · 1.41 / 1.42 |
| mixstats,nocastpush | 3v3 · 404 · 80 | 49 / 30 / 1 / 0 | 3.3 | 100 % | 23 / 0 / 0 / 14 / 18 / 0 / 0 | 35 / 0 / 0 / 16 / 21 / 0 / 0 | 36 / 0 / 0 / 12 / 19 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 27.75 | 5.7 / 0.0 / 0.0 / 3.1 / 9.9 / 11.8 / 5.3 | 7.2 / 0.0 / 0.0 / 5.0 / 6.4 / 5.4 / 0.0 | 0.80 / — / — / 0.62 / 1.54 / 2.17 | Step 15 % | none | 0 / 0 / 0 / 0 | 13 / 0 / 0 · 5 | 1.9 | 0.00 | 41 / 4 · 19 / 6 · 28 / 4 · 1.51 / 1.35 |
| mixstats,nocastpush | 3v3 · 505 · 80 | 42 / 37 / 1 / 0 | 3.3 | 100 % | 28 / 0 / 0 / 8 / 9 / 0 / 0 | 33 / 0 / 0 / 17 / 25 / 0 / 0 | 32 / 0 / 0 / 14 / 21 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 28.16 | 5.5 / 0.0 / 0.0 / 3.3 / 10.8 / 11.9 / 4.9 | 7.0 / 0.0 / 0.0 / 4.9 / 6.7 / 5.5 / 0.0 | 0.79 / — / — / 0.69 / 1.62 / 2.18 | run 16 % | none | 0 / 0 / 0 / 0 | 10 / 0 / 0 · 6 | 1.9 | 0.01 | 50 / 5 · 18 / 6 · 28 / 4 · 1.50 / 1.30 |
| mixstats,nocastpush | 3v3 · 606 · 80 | 37 / 41 / 2 / 0 | 3.5 | 100 % | 21 / 0 / 0 / 9 / 16 / 0 / 0 | 29 / 0 / 0 / 18 / 23 / 0 / 0 | 34 / 0 / 0 / 14 / 17 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 28.09 | 5.4 / 0.0 / 0.0 / 3.5 / 10.5 / 11.9 / 5.7 | 7.3 / 0.0 / 0.0 / 4.9 / 6.5 / 5.4 / 0.0 | 0.75 / — / — / 0.73 / 1.62 / 2.22 | Step 15 % | none | 0 / 0 / 0 / 0 | 10 / 0 / 0 · 5 | 1.9 | 0.00 | 45 / 3 · 22 / 5 · 30 / 4 · 1.41 / 1.47 |
| mixstats,nocastpush | 3v3 · 707 · 80 | 35 / 44 / 1 / 0 | 3.3 | 100 % | 21 / 0 / 0 / 9 / 19 / 0 / 0 | 35 / 0 / 0 / 12 / 23 / 0 / 0 | 35 / 0 / 0 / 12 / 18 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 27.36 | 5.4 / 0.0 / 0.0 / 3.1 / 10.5 / 11.8 / 5.5 | 7.3 / 0.0 / 0.0 / 4.7 / 6.6 / 5.4 / 0.0 | 0.73 / — / — / 0.66 / 1.61 / 2.19 | run 15 % | none | 0 / 0 / 0 / 0 | 13 / 0 / 0 · 6 | 2.0 | 0.00 | 43 / 8 · 22 / 6 · 30 / 4 · 1.34 / 1.54 |
| mixstats,nocastpush,veincharge | 3v3 · 202 · 80 | 40 / 40 / 0 / 0 | 3.7 | 100 % | 30 / 0 / 0 / 9 / 11 / 0 / 0 | 35 / 0 / 0 / 12 / 25 / 0 / 0 | 34 / 0 / 0 / 13 / 19 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 27.00 | 5.1 / 0.0 / 0.0 / 2.9 / 10.5 / 11.9 / 5.5 | 7.2 / 0.0 / 0.0 / 4.8 / 6.6 / 5.3 / 0.0 | 0.71 / — / — / 0.60 / 1.59 / 2.24 | Step 15 % | none | 0 / 0 / 0 / 0 | 9 / 0 / 0 · 7 | 2.0 | 0.03 | 46 / 0 · 23 / 1 · 30 / 4 · 1.23 / 1.18 |
| mixstats,nocastpush,veincharge | 3v3 · 303 · 80 | 41 / 39 / 0 / 0 | 3.6 | 100 % | 23 / 0 / 0 / 14 / 10 / 0 / 0 | 32 / 0 / 0 / 17 / 21 / 0 / 0 | 34 / 0 / 0 / 15 / 16 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.71 | 5.1 / 0.0 / 0.0 / 3.0 / 10.4 / 12.3 / 5.5 | 7.1 / 0.0 / 0.0 / 4.6 / 6.8 / 5.5 / 0.0 | 0.72 / — / — / 0.65 / 1.55 / 2.24 | run 17 % | none | 0 / 0 / 0 / 0 | 8 / 0 / 0 · 6 | 1.9 | 0.03 | 53 / 0 · 25 / 4 · 31 / 3 · 1.23 / 1.29 |
| mixstats,nocastpush,veincharge | 3v3 · 404 · 80 | 42 / 38 / 0 / 0 | 3.7 | 100 % | 20 / 0 / 0 / 14 / 15 / 0 / 0 | 36 / 0 / 0 / 19 / 19 / 0 / 0 | 36 / 0 / 0 / 13 / 17 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 27.35 | 5.6 / 0.0 / 0.0 / 2.9 / 9.3 / 12.3 / 5.4 | 7.2 / 0.0 / 0.0 / 5.0 / 6.4 / 5.4 / 0.0 | 0.78 / — / — / 0.59 / 1.44 / 2.27 | run 16 % | none | 0 / 0 / 0 / 0 | 8 / 1 / 0 · 8 | 1.9 | 0.01 | 48 / 1 · 22 / 1 · 30 / 4 · 1.29 / 1.17 |
| mixstats,nocastpush,veincharge | 3v3 · 505 · 80 | 36 / 44 / 0 / 0 | 3.8 | 99 % | 23 / 0 / 0 / 14 / 18 / 0 / 0 | 34 / 0 / 0 / 16 / 22 / 0 / 0 | 34 / 0 / 0 / 13 / 17 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 27.14 | 5.3 / 0.0 / 0.0 / 3.4 / 10.4 / 12.7 / 5.3 | 7.0 / 0.0 / 0.0 / 4.9 / 6.7 / 5.5 / 0.0 | 0.75 / — / — / 0.69 / 1.57 / 2.32 | run 17 % | none | 1 / 0 / 0 / 0 | 6 / 1 / 1 · 11 | 1.9 | 0.01 | 43 / 4 · 23 / 4 · 31 / 4 · 1.26 / 1.16 |
| mixstats,nocastpush,veincharge | 3v3 · 606 · 80 | 37 / 43 / 0 / 0 | 3.7 | 100 % | 16 / 0 / 0 / 13 / 20 / 0 / 0 | 31 / 0 / 0 / 16 / 23 / 0 / 0 | 33 / 0 / 0 / 14 / 18 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.43 | 5.1 / 0.0 / 0.0 / 3.0 / 10.6 / 11.9 / 5.2 | 7.3 / 0.0 / 0.0 / 4.9 / 6.5 / 5.4 / 0.0 | 0.70 / — / — / 0.62 / 1.64 / 2.21 | run 16 % | none | 0 / 0 / 0 / 0 | 8 / 0 / 0 · 7 | 1.9 | 0.04 | 46 / 0 · 23 / 4 · 30 / 4 · 1.17 / 1.23 |
| mixstats,nocastpush,veincharge | 3v3 · 707 · 80 | 43 / 37 / 0 / 0 | 3.6 | 100 % | 24 / 0 / 0 / 14 / 6 / 0 / 0 | 35 / 0 / 0 / 16 / 21 / 0 / 0 | 35 / 0 / 0 / 13 / 16 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.66 | 5.1 / 0.0 / 0.0 / 2.9 / 9.9 / 12.2 / 5.7 | 7.3 / 0.0 / 0.0 / 4.7 / 6.6 / 5.4 / 0.0 | 0.70 / — / — / 0.61 / 1.51 / 2.26 | run 17 % | none | 0 / 0 / 0 / 0 | 11 / 0 / 0 · 7 | 2.0 | 0.04 | 50 / 4 · 24 / 3 · 31 / 4 · 1.24 / 1.25 |
| mixstats,nocastpush,fullstep | 3v3 · 202 · 80 | 41 / 36 / 3 / 0 | 3.2 | 100 % | 33 / 0 / 0 / 5 / 14 / 0 / 0 | 38 / 0 / 0 / 12 / 21 / 0 / 0 | 37 / 0 / 0 / 12 / 17 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 28.14 | 5.6 / 0.0 / 0.0 / 2.5 / 9.7 / 7.7 / 9.6 | 7.2 / 0.0 / 0.0 / 4.8 / 6.6 / 5.3 / 0.0 | 0.78 / — / — / 0.52 / 1.47 / 1.44 | Step 27 % | none | 0 / 0 / 0 / 0 | 21 / 0 / 0 · 6 | 1.8 | 0.00 | 43 / 5 · 20 / 8 · 28 / 5 · 1.44 / 1.47 |
| mixstats,nocastpush,fullstep | 3v3 · 303 · 80 | 44 / 35 / 1 / 0 | 3.2 | 100 % | 30 / 0 / 0 / 10 / 13 / 0 / 0 | 37 / 0 / 0 / 15 / 21 / 0 / 0 | 38 / 0 / 0 / 13 / 17 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 28.26 | 6.0 / 0.0 / 0.0 / 2.3 / 10.1 / 7.2 / 9.4 | 7.1 / 0.0 / 0.0 / 4.6 / 6.8 / 5.5 / 0.0 | 0.84 / — / — / 0.49 / 1.50 / 1.32 | Step 27 % | none | 0 / 0 / 0 / 0 | 20 / 0 / 0 · 6 | 1.8 | 0.01 | 43 / 3 · 21 / 5 · 27 / 4 · 1.37 / 1.51 |
| mixstats,nocastpush,fullstep | 3v3 · 404 · 80 | 37 / 39 / 4 / 0 | 3.2 | 100 % | 33 / 0 / 0 / 13 / 14 / 0 / 0 | 35 / 0 / 0 / 17 / 22 / 0 / 0 | 36 / 0 / 0 / 14 / 18 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 28.40 | 5.9 / 0.0 / 0.0 / 3.0 / 9.2 / 7.8 / 9.2 | 7.2 / 0.0 / 0.0 / 5.0 / 6.4 / 5.4 / 0.0 | 0.82 / — / — / 0.60 / 1.42 / 1.44 | Step 26 % | none | 0 / 0 / 0 / 0 | 14 / 0 / 0 · 5 | 1.8 | 0.00 | 34 / 6 · 18 / 6 · 26 / 4 · 1.45 / 1.44 |
| mixstats,nocastpush,fullstep | 3v3 · 505 · 80 | 39 / 38 / 3 / 0 | 3.3 | 100 % | 23 / 0 / 0 / 11 / 18 / 0 / 0 | 28 / 0 / 0 / 19 / 24 / 0 / 0 | 35 / 0 / 0 / 13 / 18 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 28.60 | 5.6 / 0.0 / 0.0 / 3.2 / 9.9 / 7.9 / 9.6 | 7.0 / 0.0 / 0.0 / 4.9 / 6.7 / 5.5 / 0.0 | 0.80 / — / — / 0.66 / 1.49 / 1.45 | Step 26 % | none | 0 / 0 / 0 / 0 | 14 / 0 / 0 · 6 | 1.9 | 0.00 | 43 / 4 · 20 / 7 · 27 / 5 · 1.44 / 1.42 |
| mixstats,nocastpush,fullstep | 3v3 · 606 · 80 | 41 / 39 / 0 / 0 | 3.2 | 100 % | 26 / 0 / 0 / 14 / 14 / 0 / 0 | 35 / 0 / 0 / 17 / 21 / 0 / 0 | 37 / 0 / 0 / 13 / 17 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 28.04 | 5.9 / 0.0 / 0.0 / 2.7 / 9.2 / 7.8 / 9.0 | 7.3 / 0.0 / 0.0 / 4.9 / 6.5 / 5.4 / 0.0 | 0.81 / — / — / 0.55 / 1.42 / 1.46 | Step 26 % | none | 0 / 0 / 0 / 0 | 18 / 0 / 0 · 5 | 1.8 | 0.01 | 41 / 3 · 19 / 6 · 27 / 5 · 1.37 / 1.46 |
| mixstats,nocastpush,fullstep | 3v3 · 707 · 80 | 36 / 42 / 2 / 0 | 3.0 | 100 % | 25 / 0 / 0 / 9 / 20 / 0 / 0 | 36 / 0 / 0 / 14 / 23 / 0 / 0 | 39 / 0 / 0 / 13 / 16 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 27.06 | 5.8 / 0.0 / 0.0 / 2.3 / 8.3 / 7.3 / 9.3 | 7.3 / 0.0 / 0.0 / 4.7 / 6.6 / 5.4 / 0.0 | 0.78 / — / — / 0.49 / 1.26 / 1.36 | Step 28 % | none | 0 / 0 / 0 / 0 | 29 / 0 / 0 · 6 | 1.8 | 0.00 | 38 / 6 · 18 / 7 · 26 / 5 · 1.37 / 1.48 |
| mixstats,nocastpush,veincharge,fullstep | 3v3 · 202 · 80 | 44 / 36 / 0 / 0 | 3.4 | 100 % | 29 / 0 / 0 / 9 / 14 / 0 / 0 | 36 / 0 / 0 / 14 / 21 / 0 / 0 | 36 / 0 / 0 / 13 / 14 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.65 | 5.2 / 0.0 / 0.0 / 2.3 / 9.3 / 7.3 / 9.2 | 7.2 / 0.0 / 0.0 / 4.8 / 6.6 / 5.3 / 0.0 | 0.72 / — / — / 0.48 / 1.41 / 1.36 | Step 28 % | none | 0 / 0 / 0 / 0 | 16 / 3 / 0 · 8 | 1.9 | 0.04 | 46 / 1 · 24 / 3 · 30 / 5 · 1.34 / 1.24 |
| mixstats,nocastpush,veincharge,fullstep | 3v3 · 303 · 80 | 47 / 33 / 0 / 0 | 3.2 | 100 % | 34 / 0 / 0 / 14 / 11 / 0 / 0 | 33 / 0 / 0 / 17 / 22 / 0 / 0 | 37 / 0 / 0 / 13 / 17 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.88 | 5.6 / 0.0 / 0.0 / 2.3 / 9.2 / 7.4 / 9.1 | 7.1 / 0.0 / 0.0 / 4.6 / 6.8 / 5.5 / 0.0 | 0.78 / — / — / 0.49 / 1.37 / 1.35 | Step 27 % | none | 0 / 0 / 0 / 0 | 13 / 0 / 0 · 6 | 1.8 | 0.05 | 38 / 4 · 24 / 3 · 28 / 4 · 1.32 / 1.31 |
| mixstats,nocastpush,veincharge,fullstep | 3v3 · 404 · 80 | 38 / 42 / 0 / 0 | 3.4 | 100 % | 31 / 0 / 0 / 10 / 16 / 0 / 0 | 38 / 0 / 0 / 13 / 23 / 0 / 0 | 38 / 0 / 0 / 12 / 17 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 27.39 | 5.7 / 0.0 / 0.0 / 2.6 / 8.9 / 7.5 / 9.2 | 7.2 / 0.0 / 0.0 / 5.0 / 6.4 / 5.4 / 0.0 | 0.80 / — / — / 0.53 / 1.38 / 1.38 | Step 27 % | none | 0 / 0 / 0 / 0 | 13 / 0 / 0 · 6 | 1.7 | 0.07 | 40 / 1 · 20 / 4 · 28 / 5 · 1.25 / 1.30 |
| mixstats,nocastpush,veincharge,fullstep | 3v3 · 505 · 80 | 32 / 48 / 0 / 0 | 3.5 | 100 % | 26 / 0 / 0 / 14 / 15 / 0 / 0 | 36 / 0 / 0 / 13 / 21 / 0 / 0 | 37 / 0 / 0 / 12 / 16 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 27.19 | 5.5 / 0.0 / 0.0 / 3.0 / 9.4 / 7.3 / 9.8 | 7.0 / 0.0 / 0.0 / 4.9 / 6.7 / 5.5 / 0.0 | 0.77 / — / — / 0.61 / 1.41 / 1.34 | Step 28 % | none | 0 / 0 / 0 / 0 | 16 / 0 / 0 · 7 | 1.8 | 0.05 | 43 / 3 · 23 / 7 · 30 / 5 · 1.21 / 1.30 |
| mixstats,nocastpush,veincharge,fullstep | 3v3 · 606 · 80 | 35 / 45 / 0 / 0 | 3.4 | 100 % | 30 / 0 / 0 / 14 / 15 / 0 / 0 | 35 / 0 / 0 / 16 / 20 / 0 / 0 | 36 / 0 / 0 / 13 / 17 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.90 | 5.4 / 0.0 / 0.0 / 2.4 / 9.1 / 7.3 / 9.5 | 7.3 / 0.0 / 0.0 / 4.9 / 6.5 / 5.4 / 0.0 | 0.75 / — / — / 0.48 / 1.41 / 1.35 | Step 28 % | none | 0 / 0 / 0 / 0 | 16 / 0 / 0 · 6 | 1.8 | 0.06 | 38 / 4 · 22 / 6 · 29 / 5 · 1.19 / 1.35 |
| mixstats,nocastpush,veincharge,fullstep | 3v3 · 707 · 80 | 41 / 39 / 0 / 0 | 3.3 | 100 % | 26 / 0 / 0 / 14 / 21 / 0 / 0 | 33 / 0 / 0 / 17 / 25 / 0 / 0 | 37 / 0 / 0 / 12 / 16 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.68 | 5.2 / 0.0 / 0.0 / 2.5 / 8.4 / 7.3 / 8.7 | 7.3 / 0.0 / 0.0 / 4.7 / 6.6 / 5.4 / 0.0 | 0.71 / — / — / 0.53 / 1.29 / 1.35 | Step 27 % | none | 0 / 0 / 0 / 0 | 19 / 1 / 0 · 8 | 1.7 | 0.07 | 36 / 3 · 21 / 4 · 29 / 4 · 1.15 / 1.33 |

**Observations** (indications; bots on working content, not tuned for these rules):

- **Initiative gets a slope with charged veins:** with `nocastpush` alone the three initiative bands are level (50 / 49 / 49 %); with `veincharge` added they read 45 / 51 / 54 %, and the same with `fullstep` on top (46 / 50 / 54 %). The same teams and boards are compared; the spread of 9 points is larger than the band noise, the direction is the first one measured for initiative in this series. HP keeps the steepest slope (about 41 → 58 %) in every variant.
- **Movement barely moves:** `veincharge` leaves the Movement bands within noise. `fullstep` lowers Movement 1–2 by 3 points (46 → 43 %) and changes nothing above 3; no established effect.
- **Length:** `veincharge` adds little with greedy (3.41 → 3.59 with `nocastpush`; 2.41 → 2.62 without) and a full round with tactic (3.38 → 4.47, 32 battles, 7 of them past round 5). `fullstep` adds nothing with greedy and shortens the tactic rows (4.47 → 3.72). Vein damage per battle is about the same as under last-touch ownership (7.9 against 8.2).
- **Early defeats return:** defeats before the victim's own first turn rise from 0 to 10–11 of 128 battles with `nocastpush,veincharge` (2–3 of 32 with tactic), and from 8 to 18 without `nocastpush`. A discharge hits at once, also in round 1 and also a monster that has not acted; three veins can hit one low-HP monster in a row. This is a measured conflict with the goal “no defeat without a chance to act”; no variant that charges from round 2 or spreads the hits was run.
- **Not measured:** human play, whether `fullstep` frees a kit slot (kits still carry Run), side-swapped fairness, bots that play for the discharge order.

**Follow-up:** T39/T40/T03/T13: human play of charged veins with `zone_cast_push` off; a variant without round-1 or repeated hits on one monster before it has acted; `fullstep` needs kits without Run before it says anything about Movement. No rule or default is changed by this entry.

## S025 · 2026-11-14 · Three battle-length switches: once per turn, no cast push, one-sided collision

**State:** main, base `593f770` dirty (three new test switches in `battle_experiment.gd`, off by default; no resource change); content `2026-11-13.1`, kit set `a30a9be42850`; Godot 4.7.2, normal CPU settings, runs in parallel. Battle suite before the runs: 158 cases, 0 errors, 0 failures (defaults unchanged). User request: test proposals 1–3 for longer battles; higher HP was declined by the user and is not part of this series.

**Variants** (`sim.gd --variant`, in memory only): `turnonce` = every slotted skill at most once per turn of its monster (the universal Step is not slotted; Run is); `nocastpush` = a push or pull zone does not move its occupants when it is cast, only at the end of their turn; `collideone` = a monster moved into another monster takes the collision damage alone. Normal map with three Dragon Veins, authored stats and kits, cost 1 for zone push/pull.

**Runs:** greedy (`AiBrain` both sides): 6 variants × 4 seeds (202, 303, 404, 505) × 32 = 768 battles. Tactic both sides: 3 variants × 4 seeds × 8 = 96 battles. `--paired`: the variants of one seed share teams, boards and starts, **not side-swapped**; rows of one seed are correlated, do not pool variants as independent samples. Each run was executed twice (full block for histograms and damage, `--compact` for the rows below); the second execution is an exact rerun, not new evidence.

### Exact histogram summary

| Bot | Variant | Battles | Round sum / battles = mean | Rounds 1 / 2 / 3 / 4 / 5 / 6 / 7 | Ended <2 / >5 | Defeats before own first turn | Damage per battle: strike / collision / vein / total |
|---|---|---|---|---|---|---|---|
| greedy | control | 128 | 308/128 = 2.406 | 3 / 78 / 39 / 8 / 0 / 0 / 0 | 3 / 0 | 8 | 5.0 / 12.2 / 4.8 / 25.0 |
| greedy | turnonce | 128 | 326/128 = 2.547 | 2 / 63 / 54 / 9 / 0 / 0 / 0 | 2 / 0 | 7 | 6.2 / 10.5 / 5.2 / 25.3 |
| greedy | nocastpush | 128 | 437/128 = 3.414 | 0 / 14 / 63 / 38 / 10 / 3 / 0 | 0 / 3 | 0 | 10.0 / 3.8 / 8.2 / 26.0 |
| greedy | collideone | 128 | 321/128 = 2.508 | 2 / 64 / 57 / 5 / 0 / 0 / 0 | 2 / 0 | 1 | 5.3 / 10.8 / 5.1 / 24.1 |
| greedy | turnonce,nocastpush | 128 | 430/128 = 3.359 | 0 / 18 / 57 / 46 / 4 / 2 / 1 | 0 / 3 | 0 | 10.3 / 4.2 / 8.0 / 26.0 |
| greedy | turnonce,nocastpush,collideone | 128 | 435/128 = 3.398 | 0 / 16 / 56 / 46 / 9 / 1 / 0 | 0 / 1 | 0 | 10.5 / 3.4 / 8.0 / 25.7 |
| tactic | control | 32 | 77/32 = 2.406 | 0 / 22 / 7 / 3 / 0 / 0 / 0 | 0 / 0 | 3 | 2.9 / 14.5 / 4.5 / 25.5 |
| tactic | nocastpush | 32 | 108/32 = 3.375 | 0 / 3 / 15 / 13 / 1 / 0 / 0 | 0 / 0 | 0 | 7.3 / 3.9 / 8.9 / 24.5 |
| tactic | turnonce,nocastpush,collideone | 32 | 128/32 = 4.000 | 0 / 1 / 7 / 16 / 7 / 1 / 0 | 0 / 1 | 0 | 8.8 / 3.3 / 10.0 / 26.1 |

Damage per battle is the mean of the four per-seed “per battle” rows of the full blocks (rounded inputs); the histogram columns are exact counts.

### Compact rows, greedy

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used | Reached pressure: HP leader won / lost / HP level / no winner | Rounds under 3 / over 7 / over 10 (%) · longest | First defeat in round (mean) | Defeated before own first turn (per battle) | Wellspring / surrounded: last defeat · all defeats · damage (%) · Wellsprings held per round end, side 0 / 1 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| build rules | 3v3 · 202 · 32 | 16 / 15 / 1 / 0 | 2.2 | 100 % | 13 / 0 / 0 / 9 / 34 / 0 / 0 | 15 / 0 / 0 / 9 / 61 / 0 / 0 | 19 / 0 / 0 / 10 / 50 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 24.34 | 2.5 / 0.0 / 0.0 / 9.1 / 3.5 / 7.2 / 0.8 | 6.8 / 0.0 / 0.0 / 4.9 / 6.8 / 5.5 / 0.0 | 0.37 / — / — / 1.87 / 0.51 / 1.31 | run 16 % | cinder_dive, snare | 0 / 0 / 0 / 0 | 75 / 0 / 0 · 4 | 1.1 | 0.12 | 38 / 3 · 12 / 1 · 18 / 1 · 1.49 / 1.23 |
| build rules | 3v3 · 303 · 32 | 9 / 22 / 1 / 0 | 2.3 | 100 % | 6 / 0 / 0 / 6 / 50 / 0 / 0 | 14 / 0 / 0 / 8 / 61 / 0 / 0 | 19 / 0 / 0 / 11 / 49 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.16 | 2.5 / 0.0 / 0.0 / 8.5 / 3.4 / 7.9 / 0.8 | 7.3 / 0.0 / 0.0 / 4.6 / 6.8 / 5.4 / 0.0 | 0.34 / — / — / 1.84 / 0.50 / 1.47 | run 19 % | cinder_dive, set_gong, snare | 0 / 0 / 0 / 0 | 66 / 0 / 0 · 3 | 1.1 | 0.06 | 31 / 6 · 11 / 3 · 18 / 1 · 1.15 / 1.60 |
| build rules | 3v3 · 404 · 32 | 16 / 16 / 0 / 0 | 2.4 | 100 % | 22 / 0 / 0 / 3 / 38 / 0 / 0 | 20 / 0 / 0 / 10 / 56 / 0 / 0 | 21 / 0 / 0 / 9 / 48 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 24.91 | 2.7 / 0.0 / 0.0 / 9.8 / 2.9 / 6.7 / 1.0 | 7.2 / 0.0 / 0.0 / 5.1 / 6.3 / 5.4 / 0.0 | 0.38 / — / — / 1.91 / 0.46 / 1.24 | run 13 % | none | 0 / 0 / 0 / 0 | 69 / 0 / 0 · 4 | 1.1 | 0.03 | 31 / 3 · 10 / 2 · 19 / 2 · 1.33 / 1.45 |
| build rules | 3v3 · 505 · 32 | 18 / 14 / 0 / 0 | 2.7 | 100 % | 16 / 0 / 0 / 0 / 56 / 0 / 0 | 18 / 0 / 0 / 5 / 58 / 0 / 0 | 21 / 0 / 0 / 7 / 48 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.53 | 2.9 / 0.0 / 0.0 / 9.1 / 3.6 / 8.4 / 1.4 | 6.8 / 0.0 / 0.0 / 5.0 / 6.7 / 5.6 / 0.0 | 0.42 / — / — / 1.83 / 0.54 / 1.52 | run 17 % | cinder_dive, snare | 0 / 0 / 0 / 0 | 44 / 0 / 0 · 4 | 1.1 | 0.03 | 28 / 0 · 12 / 5 · 21 / 2 · 1.31 / 1.38 |
| turnonce | 3v3 · 202 · 32 | 12 / 19 / 1 / 0 | 2.4 | 100 % | 9 / 0 / 0 / 6 / 34 / 0 / 0 | 18 / 0 / 0 / 12 / 45 / 0 / 0 | 25 / 0 / 0 / 10 / 40 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 24.66 | 3.2 / 0.0 / 0.0 / 6.8 / 4.2 / 7.2 / 3.1 | 6.8 / 0.0 / 0.0 / 4.9 / 6.8 / 5.5 / 0.0 | 0.47 / — / — / 1.38 / 0.62 / 1.33 | run 15 % | snare | 0 / 0 / 0 / 0 | 56 / 0 / 0 · 3 | 1.2 | 0.12 | 41 / 9 · 16 / 7 · 22 / 2 · 1.30 / 1.49 |
| turnonce | 3v3 · 303 · 32 | 7 / 25 / 0 / 0 | 2.6 | 100 % | 22 / 0 / 0 / 16 / 38 / 0 / 0 | 19 / 0 / 0 / 11 / 53 / 0 / 0 | 25 / 0 / 0 / 10 / 42 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.41 | 3.4 / 0.0 / 0.0 / 6.9 / 4.1 / 7.0 / 3.0 | 7.3 / 0.0 / 0.0 / 4.6 / 6.8 / 5.4 / 0.0 | 0.47 / — / — / 1.50 / 0.61 / 1.31 | run 15 % | none | 0 / 0 / 0 / 0 | 50 / 0 / 0 · 4 | 1.1 | 0.03 | 22 / 3 · 10 / 6 · 19 / 2 · 1.36 / 1.36 |
| turnonce | 3v3 · 404 · 32 | 18 / 14 / 0 / 0 | 2.5 | 100 % | 22 / 0 / 0 / 19 / 16 / 0 / 0 | 22 / 0 / 0 / 16 / 43 / 0 / 0 | 25 / 0 / 0 / 9 / 42 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.03 | 3.2 / 0.0 / 0.0 / 7.3 / 4.0 / 7.6 / 2.3 | 7.2 / 0.0 / 0.0 / 5.1 / 6.3 / 5.4 / 0.0 | 0.44 / — / — / 1.43 / 0.64 / 1.40 | run 14 % | none | 0 / 0 / 0 / 0 | 53 / 0 / 0 · 4 | 1.2 | 0.03 | 34 / 6 · 14 / 3 · 21 / 1 · 1.52 / 1.21 |
| turnonce | 3v3 · 505 · 32 | 14 / 17 / 1 / 0 | 2.7 | 100 % | 25 / 0 / 0 / 28 / 16 / 0 / 0 | 24 / 0 / 0 / 18 / 37 / 0 / 0 | 23 / 0 / 0 / 13 / 41 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.09 | 3.2 / 0.0 / 0.0 / 7.4 / 4.6 / 7.6 / 3.1 | 6.8 / 0.0 / 0.0 / 5.0 / 6.7 / 5.6 / 0.0 | 0.48 / — / — / 1.50 / 0.69 / 1.37 | run 15 % | snare | 0 / 0 / 0 / 0 | 44 / 0 / 0 · 4 | 1.3 | 0.03 | 22 / 9 · 11 / 8 · 21 / 3 · 1.23 / 1.43 |
| nocastpush | 3v3 · 202 · 32 | 14 / 17 / 1 / 0 | 3.4 | 100 % | 22 / 0 / 0 / 13 / 13 / 0 / 0 | 37 / 0 / 0 / 14 / 18 / 0 / 0 | 37 / 0 / 0 / 13 / 13 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.03 | 5.5 / 0.0 / 0.0 / 2.9 / 9.0 / 11.8 / 3.9 | 6.8 / 0.0 / 0.0 / 4.9 / 6.8 / 5.5 / 0.0 | 0.81 / — / — / 0.60 / 1.32 / 2.16 | run 18 % | snare | 0 / 0 / 0 / 0 | 16 / 0 / 0 · 6 | 1.7 | 0.00 | 53 / 0 · 25 / 6 · 32 / 4 · 1.33 / 1.49 |
| nocastpush | 3v3 · 303 · 32 | 16 / 16 / 0 / 0 | 3.3 | 100 % | 31 / 0 / 0 / 6 / 19 / 0 / 0 | 34 / 0 / 0 / 13 / 24 / 0 / 0 | 40 / 0 / 0 / 10 / 14 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.50 | 5.7 / 0.0 / 0.0 / 2.7 / 8.4 / 11.4 / 4.1 | 7.3 / 0.0 / 0.0 / 4.6 / 6.8 / 5.4 / 0.0 | 0.79 / — / — / 0.59 / 1.24 / 2.12 | run 19 % | cinder_dive, snare | 0 / 0 / 0 / 0 | 13 / 0 / 0 · 5 | 1.5 | 0.00 | 41 / 3 · 21 / 6 · 31 / 3 · 1.45 / 1.46 |
| nocastpush | 3v3 · 404 · 32 | 18 / 12 / 2 / 0 | 3.3 | 100 % | 44 / 0 / 0 / 6 / 3 / 0 / 0 | 38 / 0 / 0 / 10 / 24 / 0 / 0 | 39 / 0 / 0 / 7 / 18 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.00 | 5.6 / 0.0 / 0.0 / 3.5 / 7.9 / 12.0 / 3.5 | 7.2 / 0.0 / 0.0 / 5.1 / 6.3 / 5.4 / 0.0 | 0.78 / — / — / 0.68 / 1.25 / 2.22 | run 16 % | snare | 0 / 0 / 0 / 0 | 9 / 0 / 0 · 6 | 1.6 | 0.00 | 44 / 3 · 23 / 5 · 31 / 4 · 1.69 / 1.19 |
| nocastpush | 3v3 · 505 · 32 | 16 / 16 / 0 / 0 | 3.6 | 100 % | 34 / 0 / 0 / 16 / 6 / 0 / 0 | 41 / 0 / 0 / 16 / 16 / 0 / 0 | 37 / 0 / 0 / 12 / 13 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.53 | 5.7 / 0.0 / 0.0 / 3.7 / 9.7 / 12.4 / 3.9 | 6.8 / 0.0 / 0.0 / 5.0 / 6.7 / 5.6 / 0.0 | 0.83 / — / — / 0.75 / 1.45 / 2.23 | run 17 % | snare | 0 / 0 / 0 / 0 | 6 / 0 / 0 · 6 | 1.6 | 0.00 | 41 / 3 · 16 / 10 · 33 / 5 · 1.47 / 1.36 |
| collideone | 3v3 · 202 · 32 | 14 / 18 / 0 / 0 | 2.5 | 100 % | 28 / 0 / 0 / 3 / 31 / 0 / 0 | 19 / 0 / 0 / 7 / 59 / 0 / 0 | 22 / 0 / 0 / 9 / 44 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 23.53 | 2.7 / 0.0 / 0.0 / 10.0 / 3.8 / 7.7 / 1.1 | 6.8 / 0.0 / 0.0 / 4.9 / 6.8 / 5.5 / 0.0 | 0.40 / — / — / 2.06 / 0.56 / 1.41 | run 17 % | cinder_dive, set_gong, snare | 0 / 0 / 0 / 0 | 47 / 0 / 0 · 3 | 1.0 | 0.03 | 34 / 0 · 10 / 2 · 22 / 2 · 1.43 / 1.28 |
| collideone | 3v3 · 303 · 32 | 14 / 18 / 0 / 0 | 2.5 | 100 % | 13 / 0 / 0 / 3 / 44 / 0 / 0 | 16 / 0 / 0 / 7 / 59 / 0 / 0 | 22 / 0 / 0 / 9 / 44 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 24.22 | 2.8 / 0.0 / 0.0 / 9.4 / 3.9 / 8.0 / 0.6 | 7.3 / 0.0 / 0.0 / 4.6 / 6.8 / 5.4 / 0.0 | 0.38 / — / — / 2.04 / 0.58 / 1.49 | run 17 % | cinder_dive, set_gong, shove | 0 / 0 / 0 / 0 | 50 / 0 / 0 · 4 | 1.1 | 0.00 | 31 / 9 · 10 / 6 · 21 / 2 · 1.20 / 1.52 |
| collideone | 3v3 · 404 · 32 | 14 / 18 / 0 / 0 | 2.3 | 100 % | 19 / 0 / 0 / 9 / 31 / 0 / 0 | 14 / 0 / 0 / 8 / 59 / 0 / 0 | 23 / 0 / 0 / 9 / 47 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 23.81 | 2.7 / 0.0 / 0.0 / 10.6 / 2.9 / 7.2 / 0.6 | 7.2 / 0.0 / 0.0 / 5.1 / 6.3 / 5.4 / 0.0 | 0.37 / — / — / 2.07 / 0.46 / 1.34 | gale 13 % | cinder_dive, set_gong, snare | 0 / 0 / 0 / 0 | 72 / 0 / 0 · 3 | 1.1 | 0.00 | 38 / 3 · 13 / 4 · 20 / 2 · 1.35 / 1.41 |
| collideone | 3v3 · 505 · 32 | 19 / 13 / 0 / 0 | 2.8 | 100 % | 19 / 0 / 0 / 19 / 34 / 0 / 0 | 20 / 0 / 0 / 11 / 49 / 0 / 0 | 21 / 0 / 0 / 9 / 44 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 24.91 | 2.6 / 0.0 / 0.0 / 11.0 / 3.7 / 8.2 / 0.9 | 6.8 / 0.0 / 0.0 / 5.0 / 6.7 / 5.6 / 0.0 | 0.39 / — / — / 2.21 / 0.55 / 1.47 | run 16 % | none | 0 / 0 / 0 / 0 | 38 / 0 / 0 · 4 | 1.2 | 0.00 | 28 / 0 · 14 / 5 · 23 / 2 · 1.48 / 1.29 |
| turnonce,nocastpush | 3v3 · 202 · 32 | 13 / 19 / 0 / 0 | 3.3 | 100 % | 28 / 0 / 0 / 9 / 13 / 0 / 0 | 35 / 0 / 0 / 13 / 19 / 0 / 0 | 38 / 0 / 0 / 12 / 14 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.06 | 5.3 / 0.0 / 0.0 / 2.9 / 7.4 / 10.2 / 5.4 | 6.8 / 0.0 / 0.0 / 4.9 / 6.8 / 5.5 / 0.0 | 0.78 / — / — / 0.60 / 1.08 / 1.87 | Step 17 % | none | 0 / 0 / 0 / 0 | 16 / 0 / 0 · 5 | 1.8 | 0.00 | 44 / 0 · 22 / 6 · 31 / 3 · 1.34 / 1.47 |
| turnonce,nocastpush | 3v3 · 303 · 32 | 15 / 17 / 0 / 0 | 3.3 | 100 % | 38 / 0 / 0 / 6 / 9 / 0 / 0 | 38 / 0 / 0 / 5 / 30 / 0 / 0 | 43 / 0 / 0 / 8 / 15 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.34 | 6.1 / 0.0 / 0.0 / 2.3 / 6.2 / 9.8 / 4.9 | 7.3 / 0.0 / 0.0 / 4.6 / 6.8 / 5.4 / 0.0 | 0.84 / — / — / 0.50 / 0.91 / 1.81 | Step 17 % | cinder_dive | 0 / 0 / 0 / 0 | 19 / 0 / 0 · 4 | 1.6 | 0.00 | 47 / 0 · 21 / 4 · 30 / 3 · 1.35 / 1.45 |
| turnonce,nocastpush | 3v3 · 404 · 32 | 19 / 12 / 1 / 0 | 3.2 | 100 % | 34 / 0 / 0 / 3 / 13 / 0 / 0 | 35 / 0 / 0 / 9 / 25 / 0 / 0 | 40 / 0 / 0 / 7 / 18 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.03 | 6.0 / 0.0 / 0.0 / 2.8 / 6.3 / 9.8 / 4.6 | 7.2 / 0.0 / 0.0 / 5.1 / 6.3 / 5.4 / 0.0 | 0.83 / — / — / 0.55 / 1.00 / 1.82 | Step 16 % | cinder_dive | 0 / 0 / 0 / 0 | 16 / 0 / 0 · 6 | 1.7 | 0.00 | 50 / 0 · 24 / 6 · 30 / 4 · 1.56 / 1.28 |
| turnonce,nocastpush | 3v3 · 505 · 32 | 14 / 16 / 2 / 0 | 3.6 | 100 % | 19 / 0 / 0 / 16 / 13 / 0 / 0 | 35 / 0 / 0 / 13 / 22 / 0 / 0 | 38 / 0 / 0 / 10 / 17 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 27.72 | 5.9 / 0.0 / 0.0 / 3.1 / 7.6 / 9.9 / 6.5 | 6.8 / 0.0 / 0.0 / 5.0 / 6.7 / 5.6 / 0.0 | 0.88 / — / — / 0.63 / 1.14 / 1.78 | Step 20 % | none | 0 / 0 / 0 / 0 | 6 / 0 / 0 · 7 | 1.7 | 0.00 | 50 / 3 · 26 / 4 · 32 / 3 · 1.36 / 1.42 |
| turnonce,nocastpush,collideone | 3v3 · 202 · 32 | 11 / 21 / 0 / 0 | 3.4 | 100 % | 41 / 0 / 0 / 6 / 16 / 0 / 0 | 40 / 0 / 0 / 14 / 17 / 0 / 0 | 40 / 0 / 0 / 12 / 11 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.09 | 5.7 / 0.0 / 0.0 / 2.8 / 7.9 / 10.2 / 5.3 | 6.8 / 0.0 / 0.0 / 4.9 / 6.8 / 5.5 / 0.0 | 0.83 / — / — / 0.58 / 1.15 / 1.87 | Step 17 % | none | 0 / 0 / 0 / 0 | 9 / 0 / 0 · 4 | 1.7 | 0.00 | 34 / 0 · 18 / 9 · 31 / 4 · 1.35 / 1.45 |
| turnonce,nocastpush,collideone | 3v3 · 303 · 32 | 15 / 17 / 0 / 0 | 3.3 | 100 % | 34 / 0 / 0 / 9 / 16 / 0 / 0 | 44 / 0 / 0 / 7 / 25 / 0 / 0 | 44 / 0 / 0 / 9 / 12 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.09 | 6.1 / 0.0 / 0.0 / 2.4 / 6.3 / 9.7 / 5.1 | 7.3 / 0.0 / 0.0 / 4.6 / 6.8 / 5.4 / 0.0 | 0.84 / — / — / 0.52 / 0.94 / 1.80 | Step 17 % | cinder_dive | 0 / 0 / 0 / 0 | 16 / 0 / 0 · 5 | 1.6 | 0.00 | 38 / 3 · 18 / 5 · 31 / 3 · 1.41 / 1.41 |
| turnonce,nocastpush,collideone | 3v3 · 404 · 32 | 20 / 11 / 1 / 0 | 3.2 | 100 % | 22 / 0 / 0 / 3 / 13 / 0 / 0 | 34 / 0 / 0 / 10 / 23 / 0 / 0 | 41 / 0 / 0 / 8 / 16 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.41 | 6.0 / 0.0 / 0.0 / 2.6 / 6.3 / 9.6 / 5.3 | 7.2 / 0.0 / 0.0 / 5.1 / 6.3 / 5.4 / 0.0 | 0.84 / — / — / 0.50 / 1.00 / 1.77 | Step 18 % | cinder_dive | 0 / 0 / 0 / 0 | 19 / 0 / 0 · 6 | 1.7 | 0.00 | 63 / 0 · 28 / 4 · 31 / 4 · 1.62 / 1.20 |
| turnonce,nocastpush,collideone | 3v3 · 505 · 32 | 14 / 17 / 1 / 0 | 3.7 | 100 % | 38 / 0 / 0 / 13 / 3 / 0 / 0 | 39 / 0 / 0 / 18 / 16 / 0 / 0 | 39 / 0 / 0 / 12 / 14 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 27.25 | 6.0 / 0.0 / 0.0 / 3.2 / 7.5 / 10.2 / 5.8 | 6.8 / 0.0 / 0.0 / 5.0 / 6.7 / 5.6 / 0.0 | 0.88 / — / — / 0.65 / 1.12 / 1.84 | Step 18 % | none | 0 / 0 / 0 / 0 | 6 / 0 / 0 · 5 | 1.6 | 0.00 | 47 / 0 · 25 / 2 · 32 / 3 · 1.34 / 1.48 |

### Compact rows, tactic on both sides

| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used | Reached pressure: HP leader won / lost / HP level / no winner | Rounds under 3 / over 7 / over 10 (%) · longest | First defeat in round (mean) | Defeated before own first turn (per battle) | Wellspring / surrounded: last defeat · all defeats · damage (%) · Wellsprings held per round end, side 0 / 1 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| bots tactic | 3v3 · 202 · 8 | 4 / 4 / 0 / 0 | 2.4 | 100 % | 0 / 0 / 0 / 0 / 38 / 0 / 0 | 3 / 0 / 0 / 17 / 64 / 0 / 0 | 10 / 0 / 0 / 15 / 52 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 25.25 | 1.5 / 0.0 / 0.0 / 10.2 / 3.5 / 7.2 / 2.1 | 7.0 / 0.0 / 0.0 / 4.6 / 7.0 / 5.4 / 0.0 | 0.21 / — / — / 2.22 / 0.50 / 1.35 | gale 18 % | asdf, cinder_dive, coiling_rift, new_skill, shove, snare, strike_thrust | 0 / 0 / 0 / 0 | 63 / 0 / 0 · 3 | 1.2 | 0.12 | 63 / 0 · 14 / 3 · 20 / 3 · 1.44 / 1.06 |
| bots tactic | 3v3 · 303 · 8 | 3 / 5 / 0 / 0 | 2.8 | 100 % | 25 / 0 / 0 / 0 / 50 / 0 / 0 | 11 / 0 / 0 / 5 / 57 / 0 / 0 | 15 / 0 / 0 / 6 / 54 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 27.12 | 2.4 / 0.0 / 0.0 / 8.9 / 3.2 / 7.4 / 3.5 | 7.1 / 0.0 / 0.0 / 4.6 / 6.6 / 5.6 / 0.0 | 0.33 / — / — / 1.92 / 0.49 / 1.31 | run 17 % | asdf, cinder_dive, coiling_rift, new_skill, snare, strike_thrust | 0 / 0 / 0 / 0 | 50 / 0 / 0 · 4 | 1.1 | 0.12 | 25 / 0 · 16 / 3 · 21 / 1 · 1.44 / 1.38 |
| bots tactic | 3v3 · 404 · 8 | 7 / 1 / 0 / 0 | 2.1 | 100 % | 25 / 0 / 0 / 13 / 38 / 0 / 0 | 8 / 0 / 0 / 8 / 69 / 0 / 0 | 8 / 0 / 0 / 10 / 67 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.62 | 1.1 / 0.0 / 0.0 / 11.6 / 3.1 / 7.8 / 1.5 | 7.1 / 0.0 / 0.0 / 5.4 / 6.2 / 5.2 / 0.0 | 0.16 / — / — / 2.16 / 0.50 / 1.48 | gale 20 % | asdf, cinder_dive, coiling_rift, new_skill, shove, snare, thorn_lash | 0 / 0 / 0 / 0 | 88 / 0 / 0 · 3 | 1.0 | 0.00 | 25 / 0 · 8 / 3 · 13 / 0 · 1.73 / 0.73 |
| bots tactic | 3v3 · 505 · 8 | 5 / 3 / 0 / 0 | 2.4 | 100 % | 0 / 0 / 0 / 25 / 50 / 0 / 0 | 6 / 0 / 0 / 15 / 62 / 0 / 0 | 12 / 0 / 0 / 13 / 54 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 23.12 | 1.5 / 0.0 / 0.0 / 9.8 / 4.5 / 7.5 / 3.2 | 6.9 / 0.0 / 0.0 / 4.5 / 7.1 / 5.5 / 0.0 | 0.22 / — / — / 2.17 / 0.63 / 1.36 | run 17 % | asdf, coiling_rift, snare, strike_thrust | 0 / 0 / 0 / 0 | 75 / 0 / 0 · 4 | 1.1 | 0.12 | 13 / 0 · 6 / 3 · 17 / 2 · 1.50 / 1.17 |
| nocastpush + bots tactic | 3v3 · 202 · 8 | 5 / 3 / 0 / 0 | 3.4 | 100 % | 25 / 0 / 0 / 0 / 0 / 0 / 0 | 22 / 0 / 0 / 22 / 28 / 0 / 0 | 31 / 0 / 0 / 13 / 14 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 24.38 | 5.0 / 0.0 / 0.0 / 2.0 / 9.2 / 10.5 / 8.0 | 7.0 / 0.0 / 0.0 / 4.6 / 7.0 / 5.4 / 0.0 | 0.71 / — / — / 0.43 / 1.32 / 1.95 | Step 23 % | cinder_dive, coiling_rift, new_skill, snare | 0 / 0 / 0 / 0 | 13 / 0 / 0 · 5 | 1.6 | 0.00 | 63 / 13 · 19 / 6 · 38 / 4 · 1.48 / 1.48 |
| nocastpush + bots tactic | 3v3 · 303 · 8 | 4 / 4 / 0 / 0 | 3.5 | 100 % | 25 / 0 / 0 / 25 / 13 / 0 / 0 | 33 / 0 / 0 / 20 / 23 / 0 / 0 | 31 / 0 / 0 / 17 / 12 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 24.12 | 4.5 / 0.0 / 0.0 / 3.1 / 10.6 / 10.6 / 6.4 | 7.1 / 0.0 / 0.0 / 4.6 / 6.6 / 5.6 / 0.0 | 0.63 / — / — / 0.68 / 1.60 / 1.89 | Step 18 % | asdf_3, new_skill, snare | 0 / 0 / 0 / 0 | 0 / 0 / 0 · 4 | 1.6 | 0.00 | 38 / 0 · 17 / 7 · 35 / 4 · 1.39 / 1.52 |
| nocastpush + bots tactic | 3v3 · 404 · 8 | 4 / 4 / 0 / 0 | 3.6 | 100 % | 13 / 0 / 0 / 0 / 0 / 0 / 0 | 19 / 0 / 0 / 22 / 19 / 0 / 0 | 26 / 0 / 0 / 13 / 18 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.62 | 4.6 / 0.0 / 0.0 / 3.8 / 9.4 / 13.2 / 8.8 | 7.1 / 0.0 / 0.0 / 5.4 / 6.2 / 5.2 / 0.0 | 0.65 / — / — / 0.70 / 1.50 / 2.52 | Step 22 % | new_skill, snare | 0 / 0 / 0 / 0 | 0 / 0 / 0 · 4 | 1.6 | 0.00 | 63 / 25 · 31 / 9 · 39 / 4 · 1.43 / 1.54 |
| nocastpush + bots tactic | 3v3 · 505 · 8 | 2 / 5 / 1 / 0 | 3.0 | 100 % | 0 / 0 / 0 / 25 / 0 / 0 / 0 | 29 / 0 / 0 / 6 / 26 / 0 / 0 | 32 / 0 / 0 / 11 / 20 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 22.75 | 4.1 / 0.0 / 0.0 / 3.0 / 10.4 / 11.1 / 5.4 | 6.9 / 0.0 / 0.0 / 4.5 / 7.1 / 5.5 / 0.0 | 0.60 / — / — / 0.67 / 1.46 / 2.02 | run 18 % | asdf_3, gale, snare, strike_thrust | 0 / 0 / 0 / 0 | 25 / 0 / 0 · 4 | 1.8 | 0.00 | 75 / 0 · 35 / 3 · 34 / 3 · 1.36 / 1.45 |
| turnonce,nocastpush,collideone + bots tactic | 3v3 · 202 · 8 | 5 / 3 / 0 / 0 | 4.1 | 100 % | 25 / 0 / 0 / 13 / 0 / 0 / 0 | 34 / 0 / 0 / 20 / 17 / 0 / 0 | 33 / 0 / 0 / 14 / 11 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.25 | 5.2 / 0.0 / 0.0 / 3.2 / 8.9 / 10.2 / 11.1 | 7.0 / 0.0 / 0.0 / 4.6 / 7.0 / 5.4 / 0.0 | 0.75 / — / — / 0.70 / 1.27 / 1.91 | Step 29 % | cinder_dive, new_skill | 0 / 0 / 0 / 0 | 0 / 0 / 0 · 6 | 1.9 | 0.00 | 63 / 0 · 23 / 6 · 40 / 1 · 1.17 / 1.60 |
| turnonce,nocastpush,collideone + bots tactic | 3v3 · 303 · 8 | 6 / 2 / 0 / 0 | 4.1 | 100 % | 13 / 0 / 0 / 13 / 38 / 0 / 0 | 26 / 0 / 0 / 14 / 34 / 0 / 0 | 32 / 0 / 0 / 14 / 13 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.62 | 5.4 / 0.0 / 0.0 / 4.4 / 8.6 / 10.9 / 10.0 | 7.1 / 0.0 / 0.0 / 4.6 / 6.6 / 5.6 / 0.0 | 0.75 / — / — / 0.95 / 1.30 / 1.93 | Step 25 % | strike_thrust | 0 / 0 / 0 / 0 | 0 / 0 / 0 · 5 | 2.0 | 0.00 | 13 / 13 · 17 / 3 · 37 / 2 · 1.74 / 1.19 |
| turnonce,nocastpush,collideone + bots tactic | 3v3 · 404 · 8 | 3 / 4 / 1 / 0 | 3.9 | 100 % | 25 / 0 / 0 / 0 / 13 / 0 / 0 | 42 / 0 / 0 / 6 / 25 / 0 / 0 | 35 / 0 / 0 / 10 / 15 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 26.75 | 5.4 / 0.0 / 0.0 / 4.5 / 7.6 / 10.4 / 11.4 | 7.1 / 0.0 / 0.0 / 5.4 / 6.2 / 5.2 / 0.0 | 0.75 / — / — / 0.84 / 1.22 / 1.98 | Step 29 % | cinder_dive, new_skill, strike_thrust | 0 / 0 / 0 / 0 | 0 / 0 / 0 · 5 | 1.8 | 0.00 | 63 / 0 · 22 / 6 · 36 / 5 · 1.50 / 1.21 |
| turnonce,nocastpush,collideone + bots tactic | 3v3 · 505 · 8 | 4 / 4 / 0 / 0 | 3.9 | 100 % | 25 / 0 / 0 / 0 / 13 / 0 / 0 | 40 / 0 / 0 / 3 / 20 / 0 / 0 | 34 / 0 / 0 / 7 / 12 / 0 / 0 | 0.00 | 0.00 / 0.00 / 0.00 | — / — | 24.88 | 5.0 / 0.0 / 0.0 / 3.1 / 7.9 / 10.8 / 10.6 | 6.9 / 0.0 / 0.0 / 4.5 / 7.1 / 5.5 / 0.0 | 0.73 / — / — / 0.69 / 1.11 / 1.95 | Step 28 % | cinder_dive | 0 / 0 / 0 / 0 | 13 / 0 / 0 · 5 | 1.6 | 0.00 | 63 / 0 · 29 / 9 · 41 / 6 · 1.54 / 1.39 |

**Observations** (indications; bots on working content):

- `nocastpush` is the only single switch with a clear effect: greedy 2.41 → 3.41 rounds, tactic 2.41 → 3.38, in every one of the four seeds. Collision damage per battle falls from about 12 to about 4; strike and Dragon Vein damage rise, total damage per battle stays near 25. Defeats before the victim's own first turn: 8 → 0 (greedy), 3 → 0 (tactic).
- `turnonce` alone (+0.14) and `collideone` alone (+0.10) are within the seed spread of the control (per-seed means 2.2–2.7); no effect is established for either alone.
- Added to `nocastpush`, the two others change nothing with greedy (3.36 and 3.40). With tactic the three together reach 4.00 against 3.38, on 32 battles per row: a lead, not a result.
- No battle ends in round 1 with `nocastpush`; 1–3 of 128 greedy battles pass round 5 (longest 7).
- With cast pushes off, the Dragon Veins carry about a third of all damage (8 of 26 per battle). The series does not tell whether the longer battles hold more decisions; that needs human play.
- Not measured: stat roles (initiative, Movement), kit balance, side-swapped fairness. Per-monster win rates shift between variants but come from unswapped team draws.

**Follow-up:** T13/T40/T39: human play with `zone_cast_push` off; the tactic lead for the combination needs more seeds before any reading. No rule or default is changed by this entry.

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
