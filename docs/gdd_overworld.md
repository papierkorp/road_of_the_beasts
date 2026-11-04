# GDD — OVERWORLD & META
*Working Draft v0.8 · synced with gdd_battle.md **v6.0** (battle GDD is the source of truth for all battle rules, stats and skills)*

---

## 1. Overview

A **management + cultivation layer** wrapped around deterministic grid battles (see gdd_battle.md), set in a wuxia world. The player is a disrespected beast tamer in a great clan who builds a business empire in the city and cultivates toward immortality.

### 1.1 Setting & Player Fantasy

- Wuxia world; the player is a **beast tamer** with a spatial space inside their body that houses monsters — higher cultivation = larger space = more monsters
- Based in a great city ruled by 5 cultivation families; the player belongs to one of them but is **poorly regarded** within the clan
- The player cannot leave the city (at launch) — travel arrays teleport to dungeon regions
- Core fantasy: **the disrespected genius** — win fights you're "supposed" to lose through tactics, build a faction the clan can't ignore through commerce

### 1.2 The Three Loops

```
MINUTE   Battle      → grid control, terrain combos, exact damage (gdd_battle.md)
DAY      Management  → spend AP: dungeons, business, deals, building
                       night resolves everything into one results screen
ARC      Cultivation → XP → sub-tiers → breakthrough trials → new
                       mechanics, bigger internal world, deeper dungeons
```

Each loop feeds the next: battles bring loot and monsters → business turns loot into money and favor → money and favor fuel cultivation → cultivation unlocks harder battles and bigger business.

### 1.3 How Overworld and Battle Connect

The battle is a closed, deterministic box. The overworld **prepares** it and **reads the result**; it never reaches into a running battle (tamer skills are the one controlled exception, gdd_battle §15).

```
OVERWORLD ──► BATTLE REQUEST ──► BATTLE ──► BATTLE RESULT ──► OVERWORLD
  roster +      mode, board,       (rules in      winner, HP left per
  gear +        both teams as      gdd_battle)    monster, kills,
  pills +       finished unit                     drops, catch chance
  arrays        sheets, modifiers
```

- **Everything is decided before the battle starts.** Stats, evolved skills, passives, artifacts, pills and arrays all resolve into a finished **unit sheet** per monster. The battle only ever sees that sheet — never "this is level X so it gets Y".
- **Nothing is consumed mid-battle** and nothing hidden: the pre-battle screen shows both teams' full sheets (stats, kit, passives, gear) — no hidden information (gdd_battle pillar 6). Wild monsters in a dungeon telegraph kin/aspect in the world; the exact sheet is visible when you engage.
- **The battle returns facts, not rewards:** winner, surviving HP per monster, kills, which props/squares mattered. The overworld decides what that is worth (XP, loot, catch).

---

## 2. Overworld Design Pillars

1. **Progression is horizontal, not vertical** — stage-ups unlock new *kinds* of play; numbers stay small and hard-capped
2. **Money buys speed and breadth, never exclusive power** — the best things are earned through battles, favor, and story
3. **Decisions are free, execution costs** — AP is spent on doing, never on looking, walking, or thinking
4. **One design language** — battle turns, city days, and building layouts all reward planning under visible constraints
5. **Everything feeds power or story** — any management feature that outputs neither gets cut
6. **Archetypes over uniques** — businesses, materials, structures, items: build the schema once, ship content as configurations
7. **Options, not numbers** — everything you tune outside battle (shapes, twists, utilities, gear) adds *choices* to the battle, never raw damage. Same rule as the battle's "Options, not luck"

---

## 3. Day & Cultivation Loops

### 3.1 Day Loop (session)

1. Day starts → player has N action points (see Time System)
2. Spend AP: dungeon expeditions (→ battle loop), business work, deals, cultivation, building, story events
3. Day ends → **night phase** resolves automatically: production, staff, growth, idle XP, market shifts, events
4. Morning results screen → new day

### 3.2 Cultivation Loop (long-term)

1. Battles, pills, and cultivation actions fill XP bars (player + monsters)
2. Full bar = sub-tier up (Lower → Middle → High); stats snap to new values
3. High sub-tier + breakthrough trial/ritual = next stage
4. Stage-ups unlock mechanics (bigger teams, evolution tiers, air layer, tamer skills), expand the internal world, raise stat ceilings, open deeper dungeons

## 4. Progression Systems

### 4.1 Cultivation Structure (shared naming, player & monsters)

```
STAGES     Qi Gathering → Foundation → Core Formation → Soul Tier → Immortal → Sovereign
SUB-TIERS  Lower → Middle → High   (per stage)
BREAKTHROUGH  High → next stage's Lower
```

### 4.2 Player Progression (3 layers)

```
1. STAGE       → unlocks mechanics (see 4.5)
2. SUB-TIER    → grows spatial space capacity, tamer skill potency
3. WITHIN      → cultivation XP bar (battles, story, resources)
                 full bar = sub-tier up
                 breakthroughs (High → next stage) gated by trials / story
                 events / rare resources — natural narrative beats
```

### 4.3 The Individual Monster

A monster the player owns is **two layers**: a fixed *species* and a unique *individual*.

```
SPECIES  (data file, shared by all individuals — gdd_battle §6.2)
  Kin · Aspect · Strike (from Kin) · base Surge (type from aspect, shape + twist
  from species) · default utility · species passive · blurb · art

INDIVIDUAL  (one per monster the player owns or meets in the wild)
  stat shape      glass cannon | anvil | skirmisher | berserker | balanced …
  rarity          Normal | Rare | Epic | Legendary
  stage + sub-tier + XP
  evolutions      the paths picked for its skills (4.7)
  artifact(s)     socketed passives (10.3)
  current HP      persists between battles of an expedition
```

- **The stat shape belongs to the individual, not the species.** Two Blaze Tigers can be a fast skirmisher and a hard-hitting berserker — same Surge, different playstyle. Collection depth without new art.
- The species' **Kin leans** towards certain shapes (gdd_battle §6 "stat lean": Winged → glass cannon, Ancient → anvil, …). A wild or newly caught monster **rolls its shape weighted by that lean**, so a rare off-lean individual is a prized find. The monsters listed in gdd_battle §6.2 are the **reference individuals** (the typical roll at Core Formation).
- **Every stat is paid for** (gdd_battle §4.2): the shape only decides *where* a fixed stat budget goes. A fast shape gets less HP or a weaker kit, a slow shape gets it back in HP and Reach. No shape is strictly better.

### 4.4 Monster Stats: Shape × Stage × Sub-Tier

```
STAT = stat shape (where the budget goes)
     × stage ceiling (4.6, how big the budget is)
     × sub-tier (Lower → Middle → High: how much of it is filled)
```

- No per-level stat picks, no stat bookkeeping — a sub-tier up makes the stats **snap** to the next fixed values of that individual's shape
- Monster complexity lives in **shape, skill evolution and rarity**, not in levels
- **Ceiling rule:** monsters cannot exceed the player's stage (the spatial space can only sustain what the tamer's qi can feed)
- The same stat shapes as the battle GDD (§4.5), shown as the reference Core Formation spread:

| Shape | HP | Init | TPR | Move | Reach | Feel |
|---|---|---|---|---|---|---|
| Glass cannon | 2 | 9.0 | 2 | 3 | 1 | commits fast, dies if its Surge is cut away |
| Anvil | 8 | 2.0 | 1 | 1 | 2 | slow, hard to dislodge, threatens a radius it can't leave |
| Skirmisher | 4 | 6.0 | 1 | 4 | 1 | never in its own Surge when it fires |
| Berserker | 5 | 7.0 | 3 | 2 | 1 | escalates one Surge with Empower |

*(The battle GDD lists Berserker TPR 3, which is above the Core cap of 2 — see Open Questions. Exact fractions per sub-tier are a tuning task.)*

### 4.5 Stage Unlock Table

The **full base kit is available from the first day** — Move, Strike, Surge, one utility and one passive. Battles must never feel starved of options. Progression adds *slots, choices and modes*, not the basic verbs.

| Stage | Monster unlock | Player unlock |
|---|---|---|
| Qi Gathering | full base kit (Move, Strike, Surge, 1 utility, 1 passive) · TPR 1 | holds 1 monster · **1v1** (5×5) |
| Foundation | **2nd utility slot** · first skill evolution · TPR 2 possible | holds 3+ monsters · **3v3** (7×7, standard) · **2v2** (6×6) · 1 tamer skill |
| Core Formation | second skill evolution · 2nd artifact slot at Epic+ | holds 5+ monsters (bench for counter-picks) · 2nd tamer skill · **5v5** special battles |
| Soul Tier | Air layer access (Winged) · 2x2 size · TPR 3 possible | mid-battle **Beast Swap** from the spatial space |
| Immortal | Dual-aspect monsters *(rules open)* | 3rd tamer skill |
| Sovereign | Signature skills (Legendary) · Major Surge (Ancient, Legendary only) | full spatial arsenal |

> Expansion features (bigger teams, air layer, 2x2, swap) **are** the reward structure — mechanics introduced one breakthrough at a time, solving the tutorial problem for free. Battle modes follow the team size the player can field; **which mode a fight uses is set by the encounter** (a narrow corridor node is a 1v1/2v2, a dungeon hall a 3v3, a tournament a 5v5), and the player needs at least that many monsters.

### 4.6 Stat Ceilings per Stage

Each stage defines hard caps; the stat shape spends them and sub-tiers snap stats toward them:

| | Qi Gathering | Foundation | Core Formation | Soul+ |
|---|---|---|---|---|
| Max HP | 4 | 6 | 8 | 10 |
| Max Initiative | 5.0 | 7.0 | 9.0 | 10.0 |
| Max TurnsPerRound | 1 | 2 | 2 | 3 |
| Max Movement | 3 | 3 | 4 | 4 |
| Max Reach (Strike distance, see gdd_battle §4.2) | 1 | 2 | 2 | 3 |

The base stat ranges (HP 1-10, Init 0.1-10.0, TPR 1-3) are the **lifetime scale of the entire game** — number inflation would kill the deterministic low-HP feel. The damage law (gdd_battle §11) is **never** scaled by stage: Surge base damage, Strike (max 2) and ground damage are the same at Qi Gathering and at Sovereign.

### 4.7 Skill Evolution — Variants over Numbers

Every skill a monster has (its Surge and its utilities) can **evolve**. At an evolution the player picks **one** path instead of getting flat number increases. Four path families exist; each evolution offers a few of them (how many, and how many you may take, depends on rarity — §5):

| Family | What changes | Rules |
|---|---|---|
| **Shape** | other shape family or orientation | same cell count = free. +1 cell is a *Widen*: it pays the Wide price (Surge damage −1, see gdd_battle §9.4.2). Shapes stay fixed in battle |
| **Twist** *(Surge only)* | swap the Surge's twist, or add one to a baseline Surge | at most ONE twist, each twist pays its own price (gdd_battle §9.4.2) |
| **Small value** | zone lasts 3 instead of 2 rounds (zones only, max 3) · cast range +1 (max +1 per skill) | tiny, capped; **never raises Surge or ground damage**. No level-II start (that is the Overgrowth passive's job and would make a Veil shield 3 in one cast, gdd_battle §18 Double Veil) |
| **Swap** *(utility only)* | exchange the utility for another one from the matrix (gdd_battle §9.5) | must respect the Kin's locked-out archetypes (gdd_battle §6) |

```
GLOOM RIFT (Surge, I3 vertical), evolve → pick ONE:
  a) Shape  — I3 → L3 (same cells, new territory)
  b) Twist  — baseline → Lingering (residue lasts 3 rounds, damage −1)
  c) Value  — cast range 3 → 4 (max +1)

MIRE (utility, T4), evolve → pick ONE:
  a) Shape  — T4 → L4 (+1 cell)
  b) Value  — duration 2 → 3 rounds
  c) Swap   — Mire → Grasping Shade (Dark Snare)
```

- Same species + different evolution picks = different playstyles → collection depth without new art
- An evolved skill is still **exactly one shape, one fixed orientation, one twist** — all battle rules stay valid; the preview shows the evolved skill like any other
- Evolution is a **Train** action (§7). Picks can be reversed through a ritual (cost open, §12) — "exchange, not just upgrade"

---

## 5. Monster Rarity

**Rarity = potential and flexibility, NOT raw power.** A Normal and a Legendary at the same stage are close in raw stats — the Legendary has more options and a higher ceiling.

| | Normal | Rare | Epic | Legendary |
|---|---|---|---|---|
| Base kit | Move, Strike, Surge, 1 utility (2 from Foundation) | same | same | same (+ signature at max stage) |
| Passives | 1 | 1 | 2 | 2 |
| Evolution paths offered / picked | 2 offered, pick 1 | 3 offered, pick 1 | 3 offered, pick 2 | all offered, pick all |
| Max stage reachable | Core | Soul | Immortal | Sovereign |
| Aspect | fixed | fixed | fixed | can shift once |

- "Max stage reachable" is the core axis — the wuxia "noble bloodline" trope, long-term potential over instant power
- **No stat bonuses from rarity.** Soul+ caps already sit on the absolute scale (HP 10, Init 10.0, TPR 3, Reach 3), so rarity buys slots, evolutions and ceiling — never numbers
- **High mechanics are Rare+ territory by design:** Air layer and 2x2 need Soul, TPR 3 needs Soul, the Ancient's Major Surge needs Sovereign. A Normal monster (max Core) stays grounded, single-turn-count and simple
- Rarity does **not** decide the stat shape: any rarity can roll any shape (weighted by Kin lean, §4.3)
- Offered / picked counts are a tuning start, not final (§12)

### 5.1 Rarity Ascension

- A **major event**, not a grind: rare material + ritual (bloodline awakening), story-flavored
- On ascension: unlock new rarity's slots/caps, keep everything else
- **Hard cap:** Normal can climb to Epic but never Legendary — true Legendaries remain rare finds

---

## 6. The Two Overworlds

### 6.1 The City (External World)

- The player **cannot leave the city** (at launch); travel arrays / long-range teleports lead to self-contained dungeon regions (deserts, mountains, forests)
- **District-based, not open world:** Clan Compound · Market District · Arena · Business District (player properties) · Gates/Teleport Plaza · Slums (underworld content)
- Each district = one small handcrafted 3D scene, same iso camera and art pipeline as battles
- City = economy and story; internal world = collection and cultivation — no overlap, each has a reason to visit

### 6.2 Monsters in the Overworld

- **Dungeons:** wild monsters roam visibly (no random encounters) — touching = battle; touching from behind = small round-1 initiative advantage for the player's team (exact value tuned in battle)
- Dungeon monsters are full **individuals** (own stat shape, stage, evolutions) and telegraph kin/aspect visually; their complete sheet is shown in the pre-battle screen → informed roster picks and counter-picks
- A dungeon node fixes the **battle mode** (1v1 / 2v2 / 3v3 / 5v5) and the number of wild monsters; the board follows the generation rules of gdd_battle §13
- **City:** the player's active monster follows them — walking the market with a Magma Drake behind you is the status fantasy, for free

### 6.3 The Internal World (Spatial Space)

The cultivator's inner world where monsters live — the pause menu made physical.

- Monsters walk around freely; the collection is *visible and alive*
- **Grows with cultivation:** Qi Gathering = barren rock → Foundation = grass, pond → Core = forests, structures; each stage physically expands buildable area
- Roster functions: capacity grows with stage/sub-tier (1 → 3+ → 5+ → ...), **pre-battle draft / counter-pick happens here** — pick your team from the owned monsters for the mode the encounter demands (at Core+ the bench is bigger than the team)
- Passive functions: cultivation spots (assign monster → idle XP at night), growing plots (feeds Producer business)
- Monster management lives here: inspect stat shape, assign evolutions, equip artifacts — all free actions (only the evolution ritual itself costs AP)

### 6.4 Building System

Everything placeable is a **Structure**; blueprints are one acquisition path among several.

```
STRUCTURE
  name, size (grid footprint), category
  source     : blueprint (craft w/ materials) | buy | quest/story reward
  aspect     : Force | Nature | Dark | None    ← affinity bonuses
  level      : upgradeable with materials
  placed_on  : internal world grid cell
```

- **Coarse grid placement**, free to move anytime, structures never lost
- **Adjacency bonuses** make layout a real puzzle: herb plot + water = -1 grow night; Dark monster housed near Dark altar = +XP; furnace + qi spring = better craft quality

| Category | Examples | Function |
|---|---|---|
| Cultivation | Qi Spring, Meditation Stone | assigned monster gains idle XP at night |
| Growing | Herb plot, Spirit tree | plant materials → grow N nights → harvest |
| Housing | Nest, Cave, Shrine grove | +capacity, kin-matched = mood/loyalty bonus |
| Production | Refining furnace, Array workshop | night-crafting inside the space |
| Special | Trial pillar, Aspect altar | breakthrough rituals, rarity ascension site, evolution ritual site |

---

## 7. Time System — Action-Based Days

A day = a turn. The overworld plays like the battles: limited AP, opportunity cost, deterministic, no real-time pressure.

```
DAY    → N action points (start: 3, grows with cultivation stage)
       → spend them → day ends
NIGHT  → automatic resolution: businesses produce, staff report,
         plants grow a tick, monsters gain idle XP, market prices
         shift, event triggers roll (sabotage, visitor, clan summons)
       → one results screen per day
```

**Golden rule: decisions are free, execution costs.** Walking, dialogue, browsing, assigning staff, queueing production, rearranging the internal world, **choosing the battle team and inspecting sheets** — all free. Never punish looking around.

| Action (1 AP) | Notes |
|---|---|
| Dungeon expedition | includes its battles; deeper floors cost 2 AP |
| Cultivate | progress player XP toward next sub-tier |
| Train a monster | focused XP / perform a skill evolution |
| Work a business | personally boost one facility (craft batch, run shop) |
| Deal / Negotiate | bulk trade, recruit staff, faction favor actions, auctions |
| Build | place/construct in the internal world |
| Story / Social event | clan meetings, investigations, key NPC scenes |

- No visual clock: day = bright city, night = results screen (optionally tint districts by remaining AP — cosmetic only)
- **Nothing time-critical:** quests expire in "days," never force specific actions — thinking time is the player's luxury
- Night phase = single synchronization point for all systems → save-friendly, no real-time simulation, "on day end, run all resolvers once"

---

## 8. Businesses (Management Layer)

The player, disrespected in the clan, builds a business → money → faction. All 6 business ideas decompose into **4 shared verbs** — one Facility system (slots: staff, input, timer, output) + one Market system (fluctuating prices) covers everything:

```
ACQUIRE  → get resources in (dungeon runs, buying, catching, recruiting)
PROCESS  → transform them (train, refine, craft — time + input → output)
SELL     → convert to money/favor (shop, auction, contracts)
STAFF    → hire people who automate the above at night
```

| Business | Acquire | Process | Sell |
|---|---|---|---|
| Monster hall | catch (battles!) | train monsters | sell trained beasts |
| Trader | buy low / dungeon loot | — | sell high |
| Producer | buy/gather materials | craft pills/artifacts/arrays | sell products |
| Auction hall | attract consignors | appraise/list | commission cut |
| Dojo | recruit disciples | train them | sell contracts/manpower |
| Dungeon company | expeditions | — | sell raw loot |

**Verb → action mapping:** Acquire = expedition/Deal/catch · Process = Work (or staff at night, 0 AP) · Sell = Deal (daily shop sales resolve free at night) · Staff = Deal (recruit).

The Monster hall deals in **individuals**: a trained beast is sold with its stat shape, rarity and evolutions — a good roll is worth more, which makes catching off-lean shapes a business in itself.

**Built-in progression arc:** early game the player spends AP on everything personally → staff take over Process/Sell at night → AP shifts toward dungeons, story, cultivation. The idle layer = "night phase does what you used to spend AP on."

### 8.1 The One Economy Loop

```
DUNGEONS → materials + wild monsters (battles)
BUSINESS → processes materials → money
MONEY    → cultivation resources, breakthrough materials,
           ascension rituals, artifacts, staff
STRONGER → deeper dungeons → better materials → bigger business
```

**Business is the engine, battles are the gate.** Deeper floors need battle skill; better business needs deeper floors. Neither loop works alone.

### 8.2 Favor & Faction

Connections are a **currency**, not a nebulous relationship system:

```
FAVOR (per faction: 5 families, guilds, city watch, underworld...)
  earn:  quests, selling cheap to them, arena wins, auctioning
         items they want, defeating their rivals
  spend: business licenses, protection (fewer sabotage events),
         rare auction invites, breakthrough trial access,
         recruiting THEIR people
```

- **The player's faction = recruited staff** — each hire is a character with a stat, loyalty value, and story hook
- The Dojo doubles as the faction pipeline; late game, faction members run dungeon expeditions (idle Acquire)
- Clan arc writes itself: success forces the clan to notice → tribute demands or absorption attempts → loyalty vs independence

---

## 9. Economy & Resources

### 9.1 Currency — Spirit Stones Only

One integer internally, **tiered denominations** for display and flavor:

```
100 Lower = 1 Middle · 100 Middle = 1 Upper
```

- Display auto-formats (`3 Middle, 42 Lower`); vendors/regions can display in different tiers (slums in Lower, auction hall in Upper)
- Optional depth: Upper stones double as a *material* — breakthrough rituals physically consume them (money-as-cultivation-resource, genre-authentic)
- No gold+stones dual currency, no stamina currencies (AP is that), no per-business currencies

### 9.2 The 4 Resource Kinds

| Resource | What | Sources | Sinks |
|---|---|---|---|
| **Spirit Stones** | money | business profit, loot sales, auctions | staff, materials, structures, rituals |
| **Materials** | tiered crafting inputs | dungeons, growing plots, buying | crafting, blueprints, upgrades |
| **Favor** | per-faction relationship currency | quests, deals, arena | licenses, invites, access, recruits |
| **XP bars** | progression (player + per monster) | battles, cultivate, idle spots | sub-tier ups |

### 9.3 Materials Schema (mirror existing systems)

```
MATERIAL = aspect (F/N/D/neutral) × tier (cultivation stages) × form (herb/ore/beast-part)
```

- Foundation-tier pill needs Foundation-tier herbs → deeper dungeons stay relevant automatically
- Beast parts drop by **kin** (Scaled hide, Winged feather) → collection ties into crafting
- ~3 forms × 3-4 aspects × 4 tiers ≈ 36+ materials from one schema

### 9.4 Economy Design Rule

> **Spirit stones buy speed and breadth — never things battles can't earn.** Rarity-ascension materials, trial access, unique monsters: locked behind favor/story/dungeon depth, money only a partial input. Otherwise Trader becomes the only correct playstyle and the battle game dies.

---

## 10. Items: Pills, Artifacts, Arrays

Goods are the **output tier of the material chain** — tradeable, one shared schema, no new resource category:

```
ITEM
  kind    : Material | Pill | Artifact | Array | Blueprint
  aspect  : F / N / D / neutral
  tier    : matches cultivation stages
  value   : spirit stone base price
  effect  : null (materials) | on_use (pills) | while_equipped (artifacts)
            | while_deployed (arrays)
```

### 10.1 The Balance Rule

> **Pills fuel progression outside battle. Artifacts grant options, not numbers, inside battle. Nothing is consumed mid-battle.** All effects resolve before battle starts — the deterministic preview stays honest. Tamer skills (gdd_battle §15) are *not* consumables: once per battle, free.

### 10.2 Pills (out-of-battle consumables)

| Pill type | Effect | Role |
|---|---|---|
| Cultivation | chunk of XP (player or monster) | bread-and-butter product |
| Breakthrough | required ingredient / removes trial penalty | stage-up moments |
| Healing | restore monster HP **between** battles | dungeon attrition supply line |
| Battle prep | small buff for the *next 1 battle* (+1 init, first-hit immunity) | chosen at pre-battle draft |
| Bloodline | rarity ascension ingredient | major rare sink |

Healing pills create the **dungeon attrition loop**: HP persists between fights in an expedition → pills are logistics → deeper floors need better supply → feeds Producer. A battle always *starts* at the monster's current HP (never above its max).

### 10.3 Artifacts (equipment = socketed passives)

```
ARTIFACT = passive from the Passives Library (gdd_battle §10) + aspect + tier + (tiny capped stat mod)
```

Reuses the passive implementation — near-zero new code. Crafting = Producer picks which passive to forge in (recipe determines options). The unit sheet simply lists the species passive, the Epic+ passive and the artifact passive(s).

| Wearer | Slots | Effects |
|---|---|---|
| **Monster** | 1 (2nd at Epic+ rarity) | extra passive OR +1 to one stat, **never above stage caps** |
| **Player (tamer)** | 2–3 | tamer skill mods (+1 Spirit Shield use, +Spatial Pull range), +1 AP once/day, +spatial capacity, dungeon utility |

Monster artifacts deepen the battle game; tamer artifacts feed the management/expedition game. A Normal-rarity beast with a perfect artifact-passive combo can rival an Epic — "skill beats stats."

### 10.4 Arrays (artifacts for places)

- Battlefield modifiers deployed pre-battle on home turf. Battles start **neutral on purpose** (no monster born disadvantaged, gdd_battle §7.5), so arrays are the only thing allowed to break that — and the one deliberate exception to the mirrored-fairness rule of gdd_battle §13 — kept small: e.g. one or two squares start attuned to the owner's aspect, or one start square begins elevated
- Internal-world structure boosters, business protections

### 10.5 Hard Caps

- Artifact stat mods: **+1 max, never exceeding stage ceilings** — artifacts break ties, not tiers
- One monster slot default — the choice *is* the content
- No artifact grants an active skill at launch (Legendary signature territory)
- No gear, pill or evolution raises Surge damage, Strike damage or ground damage (damage law, gdd_battle §11)
- All gear effects visible in the pre-battle preview

---

## 11. Technical Notes (Overworld) & Development Phases

- **Overworld = same 3D + fixed iso camera as battles** — one art pipeline (character controller, camera rig, props, lighting shared)
- Structure: connected small scenes (hub-based city districts + dungeon nodes), never open world
- Cheapest v1: **node-based map** (Slay-the-Spire style) — click location → scene/battle; upgrade to walkable districts later
- Night phase = single synchronization point → save-friendly, no real-time simulation ("on day end, run all resolvers once")

**Data model (mirrors the battle's data-driven approach, gdd_battle §16):**

- **Species** = the existing `MonsterDef` data files (Kin, Aspect, base kit, species passive). They no longer carry fixed stats for a stage — stats come from the individual
- **Individual** = a save-game record (species id, stat shape, rarity, stage / sub-tier / XP, evolution picks, artifacts, current HP). It owns **no battle rules**
- **Evolution paths, stat shapes, stage ceilings, items, structures, businesses, dungeons** = data files with fixed templates, loaded and validated by the same registry pattern as monsters / skills / zones. New content = a new file
- **Battle request / result** is the single contract between the two halves: the request carries mode, board parameters, both teams as **finished unit sheets** (resolved stats, evolved skills, passives, current HP) and pre-battle modifiers (pills, arrays, tamer skills); the result carries winner, remaining HP, kills. The battle core stays headless and never imports overworld code
- Game state (day, AP, money, inventory, owned individuals, structures) lives in one save object, written at the night phase

**Development phases:**
```
PHASE 1  Battle system (done: 1v1 + 3v3, draft, 9 monsters) + individual monsters
         (stat shapes, stage caps, XP → sub-tier snap) + node-based dungeon access
         + Trader business (pure buy/sell) + money → power loop
         (money → cultivation pills → XP → stronger stats)
PHASE 2  Walkable city districts, internal world v1, skill evolution,
         Producer business, favor system with 2-3 factions
PHASE 3  Dojo/faction staff, auction hall, monster hall,
         internal world growth stages, clan storyline
```

> If a management feature doesn't eventually output battle power or story access — cut it.

## 12. Open Questions (Overworld & Meta)

**Monsters & progression**
- Exact stat budget per stage and fraction per sub-tier (Lower / Middle / High); the four reference shapes at each stage
- **Berserker TPR 3** in gdd_battle §4.5 exceeds the Core cap of 2 — make it a Soul+ shape, or lower it?
- Can an individual's **stat shape change** later (ritual / rare item), or is it fixed for life?
- Are **evolution picks reversible**, and what does the respec ritual cost (materials, favor, AP)?
- Evolution schedule: how many evolutions per skill per stage, and what XP / materials do they cost?
- Rarity "paths offered / picked" counts for the four path families (§5)
- **Tamer skills:** are the five skills of gdd_battle §15 chosen or fixed per stage, and what does "sub-tier grows potency" mean for once-per-battle skills? The artifact line "+1 Spirit Shield use" contradicts "once per battle" — reword
- **Stat shapes:** a closed set (glass cannon / anvil / skirmisher / berserker / balanced) or a free distribution of the stage budget? Only some shapes exist in gdd_battle §4.5
- **Evolution × twist × Kin:** Shape evolutions must respect the twist (Ring has no free shape, Trail needs a straight line, Pounce uses O4) and the Kin's Surge size access (Swarm = 2-cell shapes) — validation rules to write
- Do monsters share the exact cultivation stage names, or beast-flavored equivalents?
- Rarity ascension materials & acquisition sources
- XP curve per sub-tier; what breakthrough trials look like mechanically
- **Dual-aspect monsters** (Immortal): gdd_battle has no rules for a second aspect (Surge type, zone family, ground) — define there first
- **Air layer / 2x2** rules live in gdd_battle open questions; stage gating is set here (Soul)

**Battle hand-off**
- What happens to a monster that **dies in an expedition** (revived by pills, injured for N days, lost)?
- Exact round-1 initiative bonus for attacking a wild monster from behind (the rule itself is now in gdd_battle §3)
- Does a victory give a **catch** chance, a catch action (costs AP / item), or a guaranteed catch of one defeated monster?
- Which board parameters does a dungeon node control (props, elevated squares) versus the generator in gdd_battle §13?
- Spatial space capacity per player sub-tier, and the bench size for counter-picks

**Management & world**
- AP growth curve per cultivation stage; exact AP costs per action
- Night event pool (sabotage, visitors, clan summons) and trigger weights
- Market price fluctuation model for the Trader loop
- Staff stats/loyalty model; can staff betray or be poached?
- Internal world grid size per stage; adjacency bonus table
- Dungeon expedition structure: floors per run, HP persistence rules, retreat rules

---

## 13. Changes in v0.8 (sync with gdd_battle v6.0)

- **Monsters are individuals** (§4.3): the species fixes Kin / Aspect / base kit, the individual owns **stat shape**, rarity, stage, evolutions, artifacts and HP. Stats = shape × stage ceiling × sub-tier (§4.4)
- **Full base kit from day one** (§4.5): Move, Strike, Surge, 1 utility, 1 passive at Qi Gathering. The old "1 active + 1 passive, 2nd active at Foundation" is gone; Foundation adds the 2nd utility slot
- **Team sizes earlier** (§4.5): 1v1 at Qi Gathering, **3v3 (standard) and 2v2 from Foundation**, 5v5 special battles from Core, Beast Swap at Soul. The encounter, not the player, picks the mode
- **Skill evolution reworked** (§4.7) to the battle's skill system: four path families — Shape, Twist, Small value, Utility swap — with Surge/Strike/ground damage never growing. The old "Deeper +1 StartOfTurn damage" and "duration 3 → 5" examples were dropped (damage law, 2-round zone clock)
- **Rarity** (§5): "2 active skills" row replaced by the real kit; evolution choices now count path offers / picks
- **TPR cap fixed**: TPR 2 is possible from Foundation (matches the stage-cap table); old "Core: TPR 2" removed
- **Pre-battle**: full sheets of both teams visible (no hidden info), healing pills and HP persistence defined against the battle's start HP, arrays limited by the neutral-start rule
- **Rarity gives no stat bonuses** (Soul+ caps = absolute scale); Normal monsters never reach Soul mechanics (air, 2x2, TPR 3) or the Major Surge — intended
- Evolution **Small value** limited to zone duration +1 (max 3) and cast range +1; no level-II start
- New §1.3 and §11 describe the battle request / result contract between both halves
