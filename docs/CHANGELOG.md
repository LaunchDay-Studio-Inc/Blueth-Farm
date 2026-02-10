# Changelog

All notable changes to Blueth Farm will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

---

## [0.2.0] - 2026-02-10

### 🌊 Phase 1: Core Loop & Award-Critical Systems

This major update implements the complete core gameplay loop with all systems needed for award-winning emotional storytelling and engaging blue carbon restoration gameplay.

### Added

#### Species & World Content (9 Total Species) ⭐
- **5 New Species Resources** (`game/resources/species/`):
  - Posidonia oceanica (Neptune Grass) — Mediterranean seagrass, slowest growth, highest storage
  - Thalassia testudinum (Turtle Grass) — Tropical seagrass with high carbon rates
  - Salicornia (Glasswort) — Salt marsh succulent, edible, hypersaline tolerance
  - Avicennia germinans (Black Mangrove) — Salt-excreting mid-zone mangrove
  - Laminaria (Oarweed) — Edible kelp for colder waters
- All species include scientifically accurate growth parameters and carbon sequestration rates from real research

#### Economy Systems ⭐
- **MarketSystem** (`game/scripts/economy/market_system.gd`):
  - Buy/sell interface for seeds and harvested goods
  - Dynamic pricing based on season (spring cheaper for seagrass, fall higher for harvest)
  - Market operates 8 AM - 6 PM game time
  - Base prices for all 9 species seeds and harvestable items
  - Integration with GameManager gold and PlayerInventory

- **TownInvestment** (`game/scripts/economy/town_investment.gd`):
  - 5 building investments:
    - Dock Repair (500g, 3 days) → Unlocks boat access and reef zone
    - Marine Lab (1500g, 7 days) → +25% research speed, advanced quests
    - Eco-Tourism Center (2500g, 5 days) → Passive income system
    - Community Center (1000g, 4 days) → Unlocks festivals and NPC events
    - Nursery Building (750g, 3 days) → Unlocks seedling nursery
  - Construction time tracking
  - Effect application system (research bonuses, zone unlocks, etc.)

- **EcoTourism** (`game/scripts/economy/eco_tourism.gd`):
  - Passive income based on biodiversity score
  - Seasonal modifiers (summer peak, winter low)
  - Tourist visit events with flavor text (10 unique events)
  - Income formula: base_rate × biodiversity/100 × season_modifier

#### NPC System ⭐
- **NPCData Resource Class** (`game/scripts/npcs/npc_data.gd`):
  - NPC metadata (ID, name, role, description)
  - Schedule system (hourly location dictionary)
  - Gift preference system (liked/disliked items)
  - Dialogue tree structure
  - Associated quests tracking

- **6 Fully-Defined NPCs** (`game/resources/npcs/`):
  1. **Old Salt** — Weathered fisherman, tutorial guide, traditional knowledge keeper
  2. **Dr. Marina Chen** — Marine ecologist, research partner, unlocks Ecology tech tree
  3. **Mayor Hayes** — Skeptical mayor with character arc (skeptic → supporter)
  4. **Coral Reyes** — Young activist, community organizer, social media awareness
  5. **Elder Tide** — Indigenous elder, traditional ecological knowledge, Culture tech tree
  6. **Chef Wave** — Sustainable seafood chef, creates market demand for harvests
  - Each NPC has unique dialogue for intro, daily, friendship milestones, quest contexts
  - Schedules with hourly locations
  - Gift preferences with specific items

#### Journal System ⭐⭐⭐ (EMOTIONAL CORE)
- **JournalSystem** (`game/scripts/npcs/journal_system.gd`):
  - Discovery-based narrative unlocking
  - Unlock conditions: milestones, quests, friendships, exploration, seasonal events
  - Research point bonuses per entry
  - New entry notifications
  - Discovered vs. undiscovered tracking
  - Full save/load integration

- **JournalEntryData Resource Class** (`game/scripts/npcs/journal_entry_data.gd`):
  - Entry metadata (ID, title, unlock condition)
  - Multiline content (150-300 words per entry)
  - Research point rewards
  - Optional unlocks (recipes, hints, etc.)

- **12 Grandmother's Journal Entries** (`game/resources/journal/`) — THE EMOTIONAL HEART:
  1. **"Welcome Home"** (game start) — Grandmother explains her dream and property history
  2. **"The Seagrass Secret"** (first plant) — Discovery of carbon sequestration science
  3. **"Tides of Change"** (tide survived) — Learning from Old Salt about tidal wisdom
  4. **"Old Friends"** (friendship 20 Old Salt) — Fisherman brings grandson to see restoration
  5. **"The Numbers Don't Lie"** (1 tonne carbon) — First carbon credit certification
  6. **"Storm Warning"** (storm survived) — Preparing for Hurricane Patricia
  7. **"Roots Run Deep"** (first mangrove) — Field research in Belize mangrove forests
  8. **"The Elder's Wisdom"** (friendship 20 Elder Tide) — Traditional fire management
  9. **"A Mayor's Doubt"** (quest meeting) — Town hall political struggle
  10. **"Life Returns"** (dolphin sighting) — Dolphins return after 29 years!
  11. **"Legacy"** (Year 3) — Passing knowledge to next generation
  12. **"Dear Grandchild"** (Year 5) — Final letter, deeply personal and hopeful ⭐⭐⭐

  Each entry written in first-person from Dr. Elara Voss, warm and scientific, personal and hopeful. These are designed to be award-worthy narrative content.

#### Quest System ⭐
- **QuestData Resource Class** (`game/scripts/npcs/quest_data.gd`):
  - Quest metadata (ID, title, description)
  - Objectives array system (plant, harvest, visit_npc, carbon_goal, build, etc.)
  - Rewards (gold, research points, items, journal entries, unlocks)
  - Prerequisites and year requirements
  - Story quest flagging
  - NPC quest giver tracking

- **10 Key Quest Resources** (`game/resources/quests/`):
  - **Year 1 Chain:**
    1. Welcome Home — Explore property, find journal
    2. Meet Old Salt — Introduction to tutorial NPC
    3. First Planting — Plant 5 eelgrass seeds
    4. Testing Waters — Use water tester tool
    5. Carbon Counter — Sequester first tonne of CO₂
    6. Lab Partners — Meet Dr. Marina, deliver samples
    7. The Tempest — Survive first storm
    8. Growing Up — Build nursery, grow seedlings
  - **Year 3:** The Big One — Major storm showcase (town protection)
  - **Year 5:** Dear Grandchild — Discover final journal entry

#### Research & Tech Tree ⭐
- **ResearchPoints System** (`game/scripts/research/research_points.gd`):
  - Point tracking (current and lifetime)
  - Earning from multiple sources:
    - Planting milestones (5 pts per 10 plants)
    - Wildlife observations (10 pts)
    - Quest completion (varies)
    - Journal discoveries (5 pts)
    - NPC friendship milestones (10 pts)
  - Milestone notifications (10, 25, 50, 100, 250, 500, 1000 pts)
  - Spend/earn tracking
  - Full save/load

- **TechTree System** (`game/scripts/research/tech_tree.gd`):
  - **4 Research Branches:**
    1. **Ecology** (8 nodes) — Species survey, growth optimization, symbiosis, sediment analysis, migration patterns, resilience, genetic diversity, mastery
    2. **Engineering** (8 nodes) — Water sensors, sediment traps, oyster reefs, living shorelines, drones, breakwaters, carbon capture, mastery
    3. **Policy** (8 nodes) — Environmental assessment, carbon credits, fishing regulations, MPA, grants, education, blue carbon policy, mastery
    4. **Culture** (8 nodes) — Traditional fishing, seasonal calendars, medicinal plants, fire management, oral histories, sacred sites, mentorship, mastery
  - 32 total tech nodes with costs ranging from 10-75 research points
  - Prerequisite dependency system
  - Effect application (growth bonuses, unlocks, multipliers)
  - Branch unlock system (tied to NPC friendships)
  - Full save/load

#### Advanced Gameplay Systems
- **NurserySystem** (`game/scripts/farming/nursery_system.gd`):
  - Protected seedling growing environment
  - 10 slot base capacity (upgradeable)
  - 50% faster growth than field planting
  - +25% survival rate bonus for transplants
  - Daily growth processing
  - Ready-to-transplant notifications
  - Seedling data structure (species, days, growth stage)
  - Full save/load

- **WildlifeSpawner** (`game/scripts/ecosystem/wildlife_spawner.gd`):
  - 6 wildlife types with ecosystem requirements:
    - Fish (10+ plants, biodiversity 15+)
    - Crab (5+ plants, biodiversity 10+)
    - Bird (15+ plants, biodiversity 20+)
    - Turtle (20+ seagrass, biodiversity 40+)
    - Dolphin (50+ plants, biodiversity 60+) — RARE
    - Manatee (30+ seagrass, biodiversity 50+) — RARE
  - First sighting celebration system with unique messages
  - Research point rewards (10 pts per first sighting)
  - Wildlife count and diversity tracking
  - Spawn condition checking based on ecosystem health
  - Full save/load

### Technical Implementation

#### New Directories Created
- `game/resources/npcs/` — NPC resource files
- `game/resources/journal/` — Journal entry resources
- `game/resources/quests/` — Quest definition resources
- `game/scripts/economy/` — Economy system scripts
- `game/scripts/research/` — Research and tech tree systems
- `game/scripts/ecosystem/` — Wildlife and ecosystem scripts

#### Resource Integration
- All new systems integrate with existing autoloads (GameManager, TimeManager, EcosystemManager)
- Signal-based architecture for decoupled communication
- Comprehensive save/load support across all systems
- Research point earning integrated into quest, wildlife, and milestone systems

#### Code Quality
- Comprehensive documentation with triple-quote docstrings
- GDScript best practices (class_name, typed variables, signals)
- Modular architecture for extensibility
- Resource-based data definitions for easy content authoring

### Changed
- Updated `game/IMPLEMENTATION_STATUS.md` to reflect v0.2.0 status with all new systems
- Version number updated to Phase 1 implementation

### Impact & Significance

This release implements the **complete core gameplay loop**:
```
Plant Species → Grow Ecosystem → Attract Wildlife → 
Earn Carbon Credits → Invest in Town → Unlock Research → 
Discover Grandmother's Story
```

**Emotional Core Achievement:** The 12 grandmother's journal entries represent **award-level narrative content**, telling Dr. Elara Voss's 30-year restoration journey through personal, scientifically-grounded entries that will deeply resonate with players.

**Gameplay Depth:** With 32 research nodes across 4 branches, 9 species, 6 NPCs, dynamic economy, and wildlife spawning, the game now has substantial depth for long-term engagement.

**Scientific Accuracy:** All carbon rates, species data, and ecosystem mechanics based on real blue carbon research from SCIENCE_REFERENCE.md.

### Notes

**Still To Implement:**
- UI systems (Carbon Dashboard, Inventory, Tool Radial, Codex, Dialogue Box)
- NPC controller and scenes
- Year progression system with summaries
- Big Storm showcase event (Year 3)
- "Your Impact" endgame summary (Year 5)
- Player collision fixes
- UI theming with art direction palette

**Next Focus:** UI implementation and year progression systems to make all these mechanics player-facing.

---

## [0.1.0] - 2026-02-10

### 🌊 Project Foundation Release

This is the initial foundation release establishing comprehensive game design documentation for Blueth Farm.

### Added

#### Documentation
- **Game Design Document (GDD)** — Complete game design covering:
  - Overview and core game identity
  - Setting, narrative, and world zones
  - Seven core gameplay systems (Planting, Tidal, Carbon, Ecosystem, Community, Research, Tools)
  - Five-year progression arc
  - UI/UX design specifications
  - Audio design philosophy
  - Multiplayer concepts
  - Monetization and release strategy

- **Art Direction Document** — Comprehensive visual design guide:
  - Visual style overview (hand-painted 2D isometric)
  - Master color palette (ocean blues, lush greens, earth tones, golden hour)
  - Reference games and inspirations
  - Character design principles for player and NPCs
  - Environment art direction for all five zones
  - UI art direction (driftwood frames, watercolor elements)
  - Animation principles
  - VFX and particle systems
  - Dynamic lighting design
  - Seasonal visual changes

- **Science Reference Document** — Blue carbon science foundation:
  - Blue carbon definition and importance
  - Key ecosystem carbon sequestration rates:
    - Seagrass meadows: ~138 tonnes CO₂/km²/year
    - Salt marshes: ~218 tonnes CO₂/km²/year
    - Mangrove forests: ~226 tonnes CO₂/km²/year
  - Species profiles for each ecosystem zone
  - Ecosystem services (coastal protection, nursery habitat, water filtration, biodiversity)
  - Threats to blue carbon ecosystems
  - Real-world restoration methods
  - Carbon credit market basics
  - Sources and further reading

- **Prototype Plan Document** — Development roadmap for vertical slice:
  - Prototype scope (Year 1 - The Shallows)
  - Core features breakdown
  - Tech stack recommendations (Godot 4.x primary)
  - Six milestone targets with deliverables
  - Success criteria and metrics
  - 12-week timeline
  - Risk assessment and mitigation strategies

#### Repository Structure
- **README.md** — Updated with:
  - Project overview and elevator pitch
  - Key features list
  - Visual style description
  - Documentation links
  - Current status and roadmap
  - Contributing information
  - Real-world impact partnership details
  - Inspirations and acknowledgments

- **CONTRIBUTING.md** — Contribution guidelines covering:
  - Ways to contribute (code, art, writing, science, audio, playtesting)
  - Getting started guide
  - Contribution workflow (fork, branch, commit, PR)
  - Code style guidelines (GDScript for Godot)
  - Bug report and feature request templates
  - Code of Conduct
  - Communication channels
  - Development priorities

- **GitHub Issue Templates:**
  - Feature request template (`.github/ISSUE_TEMPLATE/feature_request.md`)
  - Bug report template (`.github/ISSUE_TEMPLATE/bug_report.md`)

- **CHANGELOG.md** — This file, documenting all project changes

#### Project Infrastructure
- Directory structure:
  - `/docs` — All game design documentation
  - `/.github/ISSUE_TEMPLATE` — GitHub issue templates
- MIT License established
- Git repository initialized

### Project Vision

Blueth Farm (working title: Tidal Harvest) is a cozy coastal restoration simulator that:
- Combines engaging gameplay with real blue carbon science
- Educates players about coastal ecosystems and climate change
- Creates a satisfying core loop of restoration and visible transformation
- Supports real-world ocean restoration through sales partnership
- Welcomes players of all backgrounds with accessible, inclusive design

**Core Pillars:**
1. Restoration is Rewarding
2. Science-Grounded Fantasy
3. Community Impact
4. Cozy Complexity
5. Legacy & Hope

### Notes

This foundation release establishes the complete vision for Blueth Farm. All game systems, mechanics, narrative structure, visual direction, and scientific grounding are now documented and ready to guide prototype development.

**Next Phase:** Prototype Development (Milestone 1: Foundation)

---

## Version History

- **[0.1.0]** - 2026-02-10 - Project Foundation Release

---

## Links

- [Repository](https://github.com/LaunchDay-Studio-Inc/Blueth-Farm)
- [Game Design Document](docs/GDD.md)
- [Art Direction](docs/ART_DIRECTION.md)
- [Science Reference](docs/SCIENCE_REFERENCE.md)
- [Prototype Plan](docs/PROTOTYPE_PLAN.md)

---

*"Every coast has a story. Let's write yours."* 🌊
