# GDD — OVERWORLD & META
*Working Draft v0.7 · companion file: gdd_battle.md*

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

---

## 2. Overworld Design Pillars

1. **Progression is horizontal, not vertical** — stage-ups unlock new *kinds* of play; numbers stay small and hard-capped
2. **Money buys speed and breadth, never exclusive power** — the best things are earned through battles, favor, and story
3. **Decisions are free, execution costs** — AP is spent on doing, never on looking, walking, or thinking
4. **One design language** — battle turns, city days, and building layouts all reward planning under visible constraints
5. **Everything feeds power or story** — any management feature that outputs neither gets cut
6. **Archetypes over uniques** — businesses, materials, structures, items: build the schema once, ship content as configurations

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
4. Stage-ups unlock mechanics (air layer, teams, tamer skills), expand the internal world, raise stat ceilings, open deeper dungeons

## 4. Progression Systems

### 4.1 Cultivation Structure (shared naming, player & monsters)

```
STAGES     Qi Gathering → Foundation → Core Formation → Soul Tier → Immortal → Sovereign
SUB-TIERS  Lower → Middle → High   (per stage)
BREAKTHROUGH  High → next stage's Lower
```

### 4.2 Player Progression (3 layers)

```
1. STAGE       → unlocks mechanics (see 4.4)
2. SUB-TIER    → grows spatial space capacity, tamer skill potency
3. WITHIN      → cultivation XP bar (battles, story, resources)
                 full bar = sub-tier up
                 breakthroughs (High → next stage) gated by trials / story
                 events / rare resources — natural narrative beats
```

### 4.3 Monster Progression (1 layer, simple)

```
XP bar → full → sub-tier up → stats SNAP to new sub-tier values
High sub-tier → breakthrough item/ritual → next stage
```

- No per-level stat picks — each sub-tier defines **fixed stat values**, zero bookkeeping
- Monster complexity lives in **skill evolution choices** and **rarity**, not levels
- **Ceiling rule:** monsters cannot exceed the player's stage (spatial space can only sustain what the tamer's qi can feed)

### 4.4 Stage Unlock Table

| Stage | Monster unlock | Player unlock |
|---|---|---|
| Qi Gathering | 1 active + 1 passive skill | Holds 1 monster |
| Foundation | 2nd active skill, skill variants | 2-3 monsters, 1 tamer skill |
| Core Formation | TPR 2 possible, skill evolution | 2v2 battles, 2nd tamer skill |
| Soul Tier | Air layer access (flying), 2x2 evolutions | Mid-battle monster swap |
| Immortal | Dual-aspect monsters | 3rd tamer skill |
| Sovereign | Signature/ultimate skills | Full spatial arsenal |

> Expansion features (air layer, 2x2, teams) **are** the reward structure — mechanics introduced one breakthrough at a time, solving the tutorial problem for free.

### 4.5 Stat Ceilings per Stage

Each stage defines hard caps; sub-tiers snap stats toward them:

| | Qi Gathering | Foundation | Core Formation | Soul+ |
|---|---|---|---|---|
| Max HP | 4 | 6 | 8 | 10 |
| Max Initiative | 5.0 | 7.0 | 9.0 | 10.0 |
| Max TurnsPerRound | 1 | 2 | 2 | 3 |
| Max Movement | 3 | 3 | 4 | 4 |

The base stat ranges (HP 1-10, Init 0.1-10.0, TPR 1-3) are the **lifetime scale of the entire game** — number inflation would kill the deterministic low-HP feel.

### 4.6 Skill Progression — Variants over Numbers

At skill evolution, the player picks **one** path instead of getting flat number increases:

```
LAVA POOL, evolve → pick ONE:
  a) Wider  — pattern Single → Cross
  b) Longer — duration 3 → 5 rounds
  c) Deeper — +1 StartOfTurn dmg (small vertical bump)
```

Same species + different evolution picks = different playstyles → collection depth without new art.

---

## 5. Monster Rarity

**Rarity = potential and flexibility, NOT raw power.** A Normal and a Legendary at the same stage are close in raw stats — the Legendary has more options and a higher ceiling.

| | Normal | Rare | Epic | Legendary |
|---|---|---|---|---|
| Active skills | 2 | 2 | 2 | 2 (+signature at max stage) |
| Passives | 1 | 1 | 2 | 2 |
| Skill evolution choices | 1 of 2 | 1 of 3 | 2 of 3 | all 3 paths |
| Stat cap bonus | — | +1 one cap | +1 two caps | +1 two caps, flexible |
| Max stage reachable | Core | Soul | Immortal | Sovereign |
| Aspect | fixed | fixed | fixed | can shift once |

- "Max stage reachable" is the core axis — the wuxia "noble bloodline" trope, long-term potential over instant power
- Stat cap bonuses stay tiny (+1) to protect balance

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

- **Dungeons:** wild monsters roam visibly (no random encounters) — touching = battle; touching from behind = small initiative advantage
- Dungeon monsters telegraph kin/aspect visually → informed pre-battle roster picks
- **City:** the player's active monster follows them — walking the market with a Magma Drake behind you is the status fantasy, for free

### 6.3 The Internal World (Spatial Space)

The cultivator's inner world where monsters live — the pause menu made physical.

- Monsters walk around freely; the collection is *visible and alive*
- **Grows with cultivation:** Qi Gathering = barren rock → Foundation = grass, pond → Core = forests, structures; each stage physically expands buildable area
- Roster functions: capacity grows with stage/sub-tier (1 → 3 → 5 → ...), pre-battle draft/counterpick happens here
- Passive functions: cultivation spots (assign monster → idle XP at night), growing plots (feeds Producer business)

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
| Special | Trial pillar, Aspect altar | breakthrough rituals, rarity ascension site |

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

**Golden rule: decisions are free, execution costs.** Walking, dialogue, browsing, assigning staff, queueing production, rearranging the internal world — all free. Never punish looking around.

| Action (1 AP) | Notes |
|---|---|
| Dungeon expedition | includes its battles; deeper floors cost 2 AP |
| Cultivate | progress player XP toward next sub-tier |
| Train a monster | focused XP / start skill evolution |
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

> **Pills fuel progression outside battle. Artifacts grant options, not numbers, inside battle. Nothing is consumed mid-battle.** All effects resolve before battle starts — the deterministic preview stays honest.

### 10.2 Pills (out-of-battle consumables)

| Pill type | Effect | Role |
|---|---|---|
| Cultivation | chunk of XP (player or monster) | bread-and-butter product |
| Breakthrough | required ingredient / removes trial penalty | stage-up moments |
| Healing | restore monster HP **between** battles | dungeon attrition supply line |
| Battle prep | small buff for the *next 1 battle* (+1 init, first-hit immunity) | chosen at pre-battle draft |
| Bloodline | rarity ascension ingredient | major rare sink |

Healing pills create the **dungeon attrition loop**: HP persists between fights in an expedition → pills are logistics → deeper floors need better supply → feeds Producer.

### 10.3 Artifacts (equipment = socketed passives)

```
ARTIFACT = passive from the Passives Library + aspect + tier + (tiny capped stat mod)
```

Reuses the passive implementation — near-zero new code. Crafting = Producer picks which passive to forge in (recipe determines options).

| Wearer | Slots | Effects |
|---|---|---|
| **Monster** | 1 (2nd at Epic+ rarity) | extra passive OR +1 to one stat, **never above stage caps** |
| **Player (tamer)** | 2–3 | tamer skill mods (+1 Spirit Shield use, +Spatial Pull range), +1 AP once/day, +spatial capacity, dungeon utility |

Monster artifacts deepen the battle game; tamer artifacts feed the management/expedition game. A Normal-rarity beast with a perfect artifact-passive combo can rival an Epic — "skill beats stats."

### 10.4 Arrays (artifacts for places)

- Battlefield modifiers deployed pre-battle on home turf (e.g. one square starts as own-aspect zone)
- Internal-world structure boosters, business protections

### 10.5 Hard Caps

- Artifact stat mods: **+1 max, never exceeding stage ceilings** — artifacts break ties, not tiers
- One monster slot default — the choice *is* the content
- No artifact grants an active skill at launch (Legendary signature territory)
- All gear effects visible in the pre-battle preview

---

## 11. Technical Notes (Overworld) & Development Phases

- **Overworld = same 3D + fixed iso camera as battles** — one art pipeline (character controller, camera rig, props, lighting shared)
- Structure: connected small scenes (hub-based city districts + dungeon nodes), never open world
- Cheapest v1: **node-based map** (Slay-the-Spire style) — click location → scene/battle; upgrade to walkable districts later
- Night phase = single synchronization point → save-friendly, no real-time simulation ("on day end, run all resolvers once")

**Development phases:**
```
PHASE 1  Battle system + node-based dungeon access + Trader business
         (pure buy/sell) + money → power loop
PHASE 2  Walkable city districts, internal world v1, Producer business,
         favor system with 2-3 factions
PHASE 3  Dojo/faction staff, auction hall, monster hall,
         internal world growth stages, clan storyline
```

> If a management feature doesn't eventually output battle power or story access — cut it.

## 12. Open Questions (Overworld & Meta)

- Do monsters share the exact cultivation stage names, or beast-flavored equivalents?
- Rarity ascension materials & acquisition sources
- XP curve per sub-tier; what breakthrough trials look like mechanically
- Exact spatial space capacity per player sub-tier
- AP growth curve per cultivation stage; exact AP costs per action
- Night event pool (sabotage, visitors, clan summons) and trigger weights
- Market price fluctuation model for the Trader loop
- Staff stats/loyalty model; can staff betray or be poached?
- Internal world grid size per stage; adjacency bonus table
- Dungeon expedition structure: floors per run, HP persistence rules, retreat rules
