# Blueth Farm — Vertical Slice Prototype Plan

**Document Version:** 1.0  
**Last Updated:** February 10, 2026  
**Purpose:** Define scope and milestones for first playable prototype

---

## Table of Contents
1. [Prototype Scope](#prototype-scope)
2. [Core Features for Prototype](#core-features-for-prototype)
3. [Tech Stack Recommendations](#tech-stack-recommendations)
4. [Milestone Targets](#milestone-targets)
5. [Success Criteria](#success-criteria)
6. [Timeline & Resources](#timeline--resources)
7. [Risk Assessment](#risk-assessment)

---

## Prototype Scope

### What is a Vertical Slice?
A **vertical slice** is a fully playable segment of the game that demonstrates all core systems working together, even if content is limited. It's a "slice" through all layers of the game (art, mechanics, systems, audio, UI) rather than a horizontal prototype of disconnected systems.

### Prototype Focus: Year 1 — The Shallows

**Why Year 1?**
- Introduces core gameplay loop in simplest form
- Tests fundamental mechanics before adding complexity
- Provides complete 30-60 minute experience
- De-risks technical challenges early
- Creates compelling demo for playtesting, funding, or marketing

**Scope Boundaries:**
- **Single Zone:** The Shallows (seagrass meadows) only
- **Time Limit:** First in-game month (Spring, Year 1)
- **Core Loop:** Plant → Grow → Monitor → Harvest Carbon
- **Limited Content:** 1 NPC, 1 species, simplified systems

**What's Included:**
✅ Basic isometric tile map  
✅ Water and land tiles  
✅ Tidal system (high/low cycle)  
✅ Seagrass planting mechanics  
✅ Basic growth simulation  
✅ Simple carbon counter  
✅ One NPC interaction (Old Salt)  
✅ Day/night cycle  
✅ Basic inventory  
✅ Player movement and tools  
✅ Tutorial integration through dialogue  
✅ Simple UI (HUD + carbon dashboard)  
✅ Placeholder audio (ambient + music)  

**What's Deferred (Post-Prototype):**
❌ Multiple zones  
❌ Advanced research tree  
❌ Full NPC relationship system  
❌ Complex economy  
❌ Seasonal system (Spring only)  
❌ Storm events  
❌ Multiplayer  
❌ Full species diversity  
❌ Advanced boat mechanics  

---

## Core Features for Prototype

### 1. Isometric Tile Map System

**Requirements:**
- 2:1 isometric perspective (30° angle)
- Base tile size: 64x32 pixels
- Map dimensions: 50×50 tiles (expandable)
- Tile types:
  - Deep water (3+ meters)
  - Shallow water (0-3 meters)
  - Sandy substrate
  - Land (shoreline)
  - Transition tiles (water → land)
- Multi-layer rendering (water, substrate, vegetation, objects, player)

**Technical Details:**
- Tilemap data structure (2D array or grid)
- Z-ordering for layered sprites
- Camera system (pan, zoom 1x-2x)
- Tile coordinates ↔ screen coordinates conversion

**Success Metric:** Player can navigate 50×50 tile world smoothly at 60fps

### 2. Player Character & Movement

**Requirements:**
- Isometric 8-direction movement (N, NE, E, SE, S, SW, W, NW)
- Walk speed: ~3 tiles/second
- Simple collision detection (can't walk through objects, deep water)
- Smooth movement (no grid-locked snapping)
- Idle animation with breathing
- Walk animation (simple 4-frame cycle per direction)

**Controls:**
- **Keyboard:** WASD or Arrow Keys
- **Gamepad:** Left stick
- **Mouse:** Click-to-move (stretch goal)

**Success Metric:** Player movement feels responsive and smooth

### 3. Tidal System

**Requirements:**
- Two-tide daily cycle (simplified to ~10 real minutes per cycle for prototype)
- Tide states:
  - **High Tide:** Maximum water level, shallow areas flooded
  - **Mid Tide (Rising):** Water rising
  - **Mid Tide (Falling):** Water receding  
  - **Low Tide:** Minimum water level, shallow areas exposed
- Visual water level change:
  - Animated water tiles rising/falling
  - Substrate visibility toggling (hidden at high tide, visible at low tide)
- Tidal clock UI element
- Gameplay impact: Can only plant in shallow areas at high tide

**Technical Details:**
- Tidal timer (game time)
- Water tile alpha/position animation
- Conditional tile rendering based on tide state
- Tide forecast display (next high/low)

**Success Metric:** Players understand and use tidal timing for planting decisions

### 4. Planting System

**Requirements:**
- **Plantable Species:** Zostera marina (eelgrass) only
- **Planting Process:**
  1. Equip spade tool
  2. Navigate to shallow water area (at high tide)
  3. Press action button on empty substrate tile
  4. Plant animation plays (~1 second)
  5. Seedling appears on tile
- **Planting Constraints:**
  - Must be in shallow water (0-3m depth)
  - Must be at high tide (water covering substrate)
  - Can only plant on empty substrate tiles
  - Limited by seed inventory
- **Seed System:**
  - Start with 20 eelgrass seeds
  - Can collect more seeds from mature plants

**Visual Feedback:**
- Valid planting location: tile highlights green
- Invalid location: tile highlights red
- Planting animation: digging → placing → covering
- Seedling sprite appears immediately

**Success Metric:** Planting feels satisfying and intuitive

### 5. Growth Simulation

**Requirements:**
- **Growth Stages:** 
  1. Seedling (just planted) — small sprite
  2. Juvenile (3 in-game days) — medium sprite
  3. Mature (7 in-game days) — full sprite, produces seeds
- **Growth Factors (simplified for prototype):**
  - Time passage (primary factor)
  - Water quality (binary: good/bad)
- **Visual Transformation:**
  - Sprite changes at each growth stage
  - Gentle swaying animation (intensifies with maturity)
  - Color shift (lighter green → darker green)
- **Carbon Sequestration:**
  - Seedlings: 0.1 kg CO₂/day
  - Juvenile: 0.3 kg CO₂/day
  - Mature: 0.5 kg CO₂/day

**Technical Details:**
- Each plant tile has growth timer
- Daily update cycle checks all plants
- Visual sprite swap when growth threshold reached
- Carbon contribution added to total daily

**Success Metric:** Growth transformation is noticeable and rewarding

### 6. Carbon Tracking System

**Requirements:**
- **Carbon Dashboard (Simple Version):**
  - Total CO₂ sequestered (cumulative)
  - Current sequestration rate (kg CO₂/day)
  - Number of plants by stage
  - Simple line graph showing accumulation over time
- **UI Display:**
  - HUD shows current total (always visible)
  - Expandable dashboard (press Tab/Select)
  - Numbers count up with satisfying animation
- **Real-World Equivalency:**
  - "Equal to X car-miles offset"
  - Updates as total changes

**Visual Design:**
- Watercolor aesthetic (per Art Direction doc)
- Green-gold color scheme
- Handwritten-style numbers
- Graph animates smoothly

**Success Metric:** Players feel pride seeing carbon total grow

### 7. NPC Interaction: Old Salt

**Requirements:**
- **Single NPC:** Old Salt, the fisherman
- **Location:** Stands on dock (fixed position)
- **Interaction:**
  - Approach NPC, press interaction button
  - Dialogue box appears with portrait
  - Simple branching dialogue (2-3 choices)
  - Provides tutorial information
- **Dialogue Topics:**
  - Introduction to blue carbon concept
  - How to plant seagrass
  - Tidal timing advice
  - Story hint about grandmother

**Dialogue System:**
- Portrait + text box UI
- Player choice selections (up to 3 options)
- Text auto-advance or click-to-continue
- Tutorial messages integrated naturally

**Success Metric:** Players learn mechanics through NPC dialogue

### 8. Day/Night Cycle

**Requirements:**
- **Cycle Duration:** ~8 real minutes (10 in-game days in prototype)
- **Time Periods:**
  - Dawn (5:00-7:00)
  - Day (7:00-18:00)
  - Dusk (18:00-20:00)
  - Night (20:00-5:00)
- **Lighting Changes:**
  - Color grading shifts (per Art Direction doc)
  - Ambient light intensity changes
  - Water reflection color changes
- **Time Display:** Clock in HUD (in-game time)

**Technical Details:**
- Global lighting color/intensity
- Shader-based color grading (if engine supports)
- Smooth transitions between time periods

**Success Metric:** Day/night cycle enhances atmosphere without gameplay disruption

### 9. Basic Inventory

**Requirements:**
- **Inventory Items:**
  - Eelgrass seeds (quantity)
  - Basic spade (tool, always owned)
- **UI:**
  - Inventory panel (press I or Menu button)
  - Grid layout showing items
  - Item counts displayed
  - Tool equip/unequip
- **Functionality:**
  - View items
  - Equip tools
  - See seed count before planting

**Simple Implementation:**
- Dictionary/map data structure (item ID → quantity)
- UI reads from inventory data
- Equip system updates active tool

**Success Metric:** Inventory is clear and functional

### 10. Tutorial Integration

**Requirements:**
- **No Separate Tutorial Mode:** Learning through play
- **Tutorial Flow:**
  1. Start: Arrive at property, Old Salt greets you
  2. Objective: "Talk to Old Salt on the dock"
  3. Dialogue: Old Salt explains situation, grandmother's vision
  4. Objective: "Plant 5 eelgrass seedlings in the shallows"
  5. On-screen prompt: Shows planting controls
  6. Complete planting → Wait for growth
  7. Objective: "Check your carbon dashboard (press Tab)"
  8. Dashboard tutorial: Explains metrics
  9. Return to Old Salt
  10. Dialogue: "You're getting the hang of this..."
  11. Objective: "Plant 20 more seedlings"
  12. Free play until month end

**Tutorial Design:**
- Contextual hints (appear when needed)
- Non-intrusive (can be dismissed)
- Grandmother's journal entries unlock (narrative tutorial)

**Success Metric:** 80%+ playtesters complete tutorial without confusion

---

## Tech Stack Recommendations

### Game Engine

**Primary Recommendation: Godot 4.x**

**Reasons:**
- ✅ **Open Source:** Free, no licensing costs, community-driven
- ✅ **Excellent 2D Support:** Built-in tilemap system, sprite handling
- ✅ **Active Development:** Godot 4 is modern and well-supported
- ✅ **GDScript:** Python-like language, easy to learn
- ✅ **Cross-Platform:** Export to PC, Console, Mobile from one codebase
- ✅ **Scene System:** Perfect for modular game development
- ✅ **Built-in Tools:** Animation editor, tilemap editor, particle system
- ✅ **Asset Pipeline:** Imports Aseprite files directly
- ✅ **Community:** Large, helpful community, abundant tutorials

**Potential Challenges:**
- ⚠️ Learning curve if team unfamiliar
- ⚠️ Console export requires partners (Pineapple Works, etc.)
- ⚠️ C# option available but GDScript recommended for 2D

**Alternative: Unity**

**When to Choose Unity:**
- ✅ Team already experienced with Unity
- ✅ Need console export without partners (official support)
- ✅ C# preference over GDScript
- ✅ Large asset store for prototyping speed

**Trade-offs:**
- ❌ Heavier engine for 2D projects
- ❌ Licensing costs for revenue over threshold
- ❌ Less optimized for pure 2D than Godot

**Recommendation:** **Godot 4.x** unless team has strong Unity expertise

### Art & Animation Tools

**Pixel/Sprite Art: Aseprite**
- Industry-standard for 2D sprite work
- Animation tools built-in
- Onion skinning, layers, palettes
- Exports sprite sheets directly
- Cost: $20 one-time (or compile free from source)

**Alternative: Krita (Free)**
- Free and open source
- Good for 2D animation
- Less sprite-focused than Aseprite

**Concept Art: Procreate or Photoshop**
- Procreate for iPad (natural sketching)
- Photoshop for desktop (industry standard)

**Vector UI: Illustrator or Inkscape**
- Icons, UI elements
- Scalable graphics

### Audio Tools

**Adaptive Audio: FMOD or Wwise**

**FMOD:**
- Free for indie (under revenue threshold)
- Excellent for dynamic music
- Godot integration available
- Recommended for this project

**Wwise:**
- Also free for indie
- Slightly steeper learning curve
- Alternative if team has experience

**Music Production:**
- DAW: FL Studio, Ableton, Logic Pro
- Lo-fi ambient genre matches many free/affordable libraries

**Sound Effects:**
- Freesound.org (Creative Commons)
- Epidemic Sound (subscription)
- Custom foley recording (authentic ocean/nature sounds)

### Version Control

**Git + GitHub/GitLab**
- Standard for game development
- Free for small teams
- Essential for collaboration
- Use Git LFS for large binary assets

### Project Management

**Lightweight Options:**
- **Trello:** Simple kanban boards
- **GitHub Projects:** Integrated with code repo
- **Notion:** All-in-one workspace (docs + tasks)

**Recommendation:** Start simple (Trello or GitHub Projects), expand if needed

---

## Milestone Targets

### Milestone 1: Foundation (2 weeks)
**Goal:** Basic world and player movement working

**Deliverables:**
- ✅ Godot project set up, Git repository initialized
- ✅ Isometric tilemap system implemented
- ✅ 50×50 test map created (water, land, substrate tiles)
- ✅ Player character sprite (8 directions, walk animation)
- ✅ Player movement (WASD + gamepad)
- ✅ Camera system (pan, zoom)
- ✅ Collision detection (basic)
- ✅ Build runs on PC (Windows/Mac/Linux)

**Success Criteria:**
- Player can walk around test map smoothly
- Camera follows player correctly
- No major performance issues (60fps target)

**Risks:**
- Isometric coordinate math complexity
- Z-ordering sprite layering issues

**Mitigation:**
- Use Godot's built-in isometric tilemap support
- Reference existing isometric Godot tutorials

---

### Milestone 2: Core Planting Loop (3 weeks)
**Goal:** Planting and growth systems functional

**Deliverables:**
- ✅ Tidal system implemented (water level animation)
- ✅ Tidal clock UI element
- ✅ Seagrass sprites (3 growth stages + swaying animation)
- ✅ Planting interaction system
- ✅ Tool system (equip spade)
- ✅ Planting validation (location, tide, inventory)
- ✅ Growth timer and stage progression
- ✅ Seed inventory system
- ✅ Day/night cycle lighting

**Success Criteria:**
- Player can plant seagrass at high tide
- Growth progression visible over in-game days
- Tidal timing creates meaningful gameplay decision

**Risks:**
- Animation complexity (swaying seagrass)
- Growth timing balance (too fast/slow)
- Tidal system performance (many water tiles updating)

**Mitigation:**
- Start with simple sway (shader-based wave)
- Playtest timing early, iterate quickly
- Optimize water updates (only visible tiles)

---

### Milestone 3: Carbon Tracking & UI (2 weeks)
**Goal:** Core metric and UI systems complete

**Deliverables:**
- ✅ Carbon calculation system (per plant, per day)
- ✅ Carbon accumulation over time
- ✅ HUD design and implementation
- ✅ Carbon dashboard UI (expandable)
- ✅ Line graph visualization (simple)
- ✅ Real-world equivalency display
- ✅ Basic inventory UI
- ✅ Art pass on UI (watercolor aesthetic)

**Success Criteria:**
- Carbon totals update correctly
- Dashboard feels satisfying to check
- UI matches art direction (driftwood, watercolor)

**Risks:**
- Graphing library/implementation complexity
- Visual design iteration time
- Numbers/calculations accuracy

**Mitigation:**
- Use simple line chart (Godot can draw primitives)
- Placeholder art initially, polish later
- Unit tests for carbon calculations

---

### Milestone 4: NPC & Narrative (2 weeks)
**Goal:** Tutorial and story introduction functional

**Deliverables:**
- ✅ Old Salt NPC character sprite
- ✅ Dialogue system implemented
- ✅ Dialogue UI (portrait + text box)
- ✅ Branching dialogue tree (simple)
- ✅ Tutorial dialogue written
- ✅ On-screen objective system
- ✅ Contextual hints/prompts
- ✅ Grandmother's first journal entry

**Success Criteria:**
- New players understand how to play through dialogue
- Tutorial feels natural, not intrusive
- Story hook engages players

**Risks:**
- Dialogue system complexity (branching logic)
- Writing quality (clarity vs. narrative)
- Tutorial pacing (too fast/slow)

**Mitigation:**
- Use existing Godot dialogue plugin (Dialogic)
- Playtest with fresh players, iterate on feedback
- Multiple tutorial pacing options (skip for experienced players)

---

### Milestone 5: Polish, Audio, Juice (2 weeks)
**Goal:** Prototype feels complete and polished

**Deliverables:**
- ✅ Ambient ocean sounds
- ✅ Lo-fi background music (1-2 tracks)
- ✅ UI sound effects (clicks, confirmations)
- ✅ Planting sound effect
- ✅ Particle effects (planting sparkle, water ripples)
- ✅ Screen transitions (fade in/out)
- ✅ Visual polish (consistent art style)
- ✅ Bug fixing pass
- ✅ Performance optimization
- ✅ Build for Windows, Mac, Linux

**Success Criteria:**
- Prototype feels "juicy" and polished
- Audio enhances atmosphere
- No major bugs or crashes
- Runs smoothly on target hardware

**Risks:**
- Scope creep ("just one more feature...")
- Audio integration issues
- Last-minute bugs

**Mitigation:**
- Strict feature freeze after M4
- Test audio early and often
- Daily playthroughs to catch bugs

---

### Milestone 6: Playtesting & Iteration (1 week)
**Goal:** Gather feedback and refine

**Deliverables:**
- ✅ 10+ external playtest sessions
- ✅ Feedback synthesis and analysis
- ✅ Critical bug fixes
- ✅ Balancing adjustments (growth rates, seed count)
- ✅ Tutorial improvements based on feedback
- ✅ Final build for demo/pitch

**Success Criteria:**
- Playtesters complete prototype without major issues
- Positive feedback on core loop
- Identified pain points addressed

**Playtest Format:**
- Recruit diverse testers (age, experience level)
- Observation + post-play questionnaire
- Record sessions (with permission)
- Specific questions:
  - Did you understand the goal?
  - Was planting satisfying?
  - Did you want to keep playing?
  - What was confusing?

---

## Success Criteria

### Must-Have (Critical for Prototype Success)

1. **Core Loop is Fun:** Planting → Growing → Seeing carbon increase feels satisfying
2. **Tutorial Works:** 80%+ of new players understand mechanics without external help
3. **Technical Stability:** No crashes, runs at 60fps on target hardware
4. **Visual Clarity:** Players can clearly see what's plantable, tide state, growth stages
5. **One "Wow Moment":** At least one moment that delights (e.g., first fish appears in seagrass)

### Should-Have (Important but Not Blocking)

1. **Tidal Strategy Emerges:** Players plan planting around tides
2. **Atmosphere is Cozy:** Visuals and audio create peaceful, inviting vibe
3. **Story Hook Lands:** Players want to know more about grandmother's story
4. **30-Minute Play Session:** Average playtime 30-45 minutes (complete experience)
5. **Replayability:** Some players want to "optimize" their restoration

### Could-Have (Nice to Have)

1. **Visual Transformation:** Clear before/after of degraded → restored coast
2. **Wildlife Appearance:** First crab or fish appears in healthy seagrass
3. **Satisfying Numbers:** Carbon totals reach impressive-feeling numbers (1,000+ kg)
4. **Polish Moments:** Small delights (water splash when walking, seagrass rustle)

### Metrics to Track

**Quantitative:**
- Completion rate (% who finish prototype)
- Average playtime
- Crash/bug frequency
- Frame rate (target: 60fps)

**Qualitative:**
- Player feedback ratings (1-5 scale)
  - Fun factor
  - Clarity/understandability
  - Visual appeal
  - Desire to play full game
- Open-ended feedback themes
- Observed pain points

**Target Scores:**
- Fun factor: 4.0+/5.0
- Clarity: 4.5+/5.0
- Desire to play full game: 4.0+/5.0

---

## Timeline & Resources

### Estimated Duration: 12 weeks (3 months)

**Breakdown:**
- M1: Foundation — 2 weeks
- M2: Core Loop — 3 weeks
- M3: Carbon & UI — 2 weeks
- M4: NPC & Narrative — 2 weeks
- M5: Polish & Audio — 2 weeks
- M6: Playtesting — 1 week

**Team Size Assumptions:**
- **Minimum Viable:** 1-2 people (solo dev or small team)
  - 1 Programmer/Designer
  - 1 Artist (can be same person with right skills)
  - Audio: Asset store / freelancer
- **Recommended:** 3-4 people
  - 1 Programmer
  - 1 Designer/Writer
  - 1 Artist
  - 1 Audio Designer (part-time or contractor)

**Budget Considerations (If Applicable):**
- Software: ~$100 (Aseprite, audio libraries if needed)
- Audio Assets: $0-500 (can use free resources or commission)
- Contractor/Freelancer: $0-2,000 (optional for audio, additional art)
- **Total:** $100-2,600 depending on scope

---

## Risk Assessment

### Technical Risks

**Risk 1: Isometric Rendering Complexity**
- **Impact:** High (core visual system)
- **Likelihood:** Medium
- **Mitigation:** Use Godot's built-in isometric tilemap, reference tutorials early
- **Contingency:** Simplify to top-down if isometric proves too complex

**Risk 2: Performance Issues (Many Animated Tiles)**
- **Impact:** High (game feel)
- **Likelihood:** Medium
- **Mitigation:** Optimize early, cull off-screen objects, use shaders for water
- **Contingency:** Reduce map size, simplify animations

**Risk 3: Growth System Bugs**
- **Impact:** Medium (affects core loop)
- **Likelihood:** Medium
- **Mitigation:** Unit tests, daily playthroughs
- **Contingency:** Simplify growth to time-only (remove condition factors)

### Design Risks

**Risk 4: Core Loop Not Fun**
- **Impact:** Critical (invalidates prototype)
- **Likelihood:** Low-Medium
- **Mitigation:** Prototype core interaction ASAP (M2), iterate based on feel
- **Contingency:** Add feedback systems (particles, sounds, animations) to enhance satisfaction

**Risk 5: Tutorial Too Complex/Boring**
- **Impact:** High (first impression)
- **Likelihood:** Medium
- **Mitigation:** Playtest early with fresh users, iterate dialogue
- **Contingency:** Add skip option, simplify initial objectives

**Risk 6: Scope Creep**
- **Impact:** High (timeline)
- **Likelihood:** High (common in game dev)
- **Mitigation:** Strict milestone deliverables, feature freeze after M4
- **Contingency:** Cut nice-to-have features ruthlessly

### Resource Risks

**Risk 7: Art Asset Production Time**
- **Impact:** Medium (can use placeholders)
- **Likelihood:** Medium
- **Mitigation:** Use placeholder art early, polish later, reuse assets
- **Contingency:** Reduce art scope, use more procedural elements

**Risk 8: Team Availability**
- **Impact:** High (delays)
- **Likelihood:** Medium
- **Mitigation:** Realistic timeline with buffer, modular milestones
- **Contingency:** Extend timeline, reduce scope

---

## Post-Prototype Roadmap

### If Prototype Succeeds (Positive Playtesting)

**Next Steps:**
1. **Pre-Production:** Expand GDD, finalize art direction, technical architecture
2. **Vertical Slice Expansion:** Add Year 2 content (salt marshes)
3. **Full Production Kickoff:** Build out all zones, NPCs, systems
4. **Funding:** Use prototype for grants, publisher pitches, crowdfunding

### If Prototype Needs Iteration

**Pivot Options:**
1. **Simplify:** Focus on core satisfaction, remove complexity
2. **Re-scope:** Change genre (more narrative-focused, less simulation)
3. **Hybrid Approach:** Keep what works, redesign what doesn't

### Learning Goals

Regardless of outcome, the prototype should answer:
- ✅ Is the core loop satisfying?
- ✅ Do players understand blue carbon concept?
- ✅ Is the cozy aesthetic working?
- ✅ Are there technical blockers for full development?
- ✅ What's the market interest level?

---

## Conclusion

This prototype plan provides a clear, achievable path to a playable vertical slice of Blueth Farm. By focusing on the essential Year 1 experience, we can validate the core concept, test technical approaches, and create a compelling demo for future development.

**Key Principles:**
- ✅ **Focused Scope:** Year 1 only, one zone, core systems
- ✅ **Iterative Development:** Milestones build on each other
- ✅ **Playtesting Early:** Validate assumptions with real players
- ✅ **Polish Matters:** Even a prototype should feel good to play
- ✅ **Learn and Adapt:** Prototype is a learning tool, not final product

**Next Immediate Steps:**
1. Assemble team (or confirm solo development)
2. Set up Godot project and Git repository
3. Create detailed task breakdown for Milestone 1
4. Begin Foundation development
5. Schedule weekly check-ins to track progress

---

**Document End**

*This prototype plan is a living document. As development progresses, we'll update milestones, timelines, and risks based on what we learn.*
