# Blueth Farm — Art Direction & Visual Design

**Document Version:** 1.0  
**Last Updated:** February 10, 2026

---

## Table of Contents
1. [Visual Style Overview](#visual-style-overview)
2. [Color Palette](#color-palette)
3. [Reference & Inspiration](#reference--inspiration)
4. [Character Design](#character-design)
5. [Environment Art Direction](#environment-art-direction)
6. [UI Art Direction](#ui-art-direction)
7. [Animation Principles](#animation-principles)
8. [VFX & Particle Systems](#vfx--particle-systems)
9. [Lighting Design](#lighting-design)
10. [Seasonal Visual Changes](#seasonal-visual-changes)
11. [Cross-Discipline Cohesion](#cross-discipline-cohesion)

---

## Visual Style Overview

### Core Aesthetic
**Warm, Hand-Painted 2D Isometric Art**

The visual style of Blueth Farm sits at the intersection of:
- **Cozy Accessibility:** Welcoming, non-threatening, inviting for all ages
- **Scientific Authenticity:** Recognizable real-world species and ecosystems
- **Artistic Expression:** Stylized beauty that goes beyond photorealism
- **Emotional Resonance:** Colors and composition that evoke wonder and peace

### Isometric Perspective
- **Angle:** Classic 2:1 isometric (30° angle)
- **Tile Size:** 64x32 base tiles (scalable for different resolutions)
- **Layering:** Strong use of depth through layered sprites
- **Camera:** Fixed isometric view with smooth panning and zoom (2x-4x range)

### Art Philosophy
"Every frame should feel like a watercolor painting of a place you want to visit — scientifically accurate, emotionally resonant, endlessly pleasant to look at."

### Visual Priorities
1. **Transformation Visibility:** Player should *see* the coast heal and thrive
2. **Ecosystem Diversity:** Each zone feels distinct and special
3. **Wildlife Character:** Animals have personality and presence
4. **Water Excellence:** Water is a star character — must be beautiful and dynamic
5. **UI Integration:** Interface elements feel organic, not overlaid

### Key Visual Goals
- **Hopeful Restoration:** Visuals move clearly from degraded to thriving, reinforcing player impact.
- **Readable at a Glance:** Silhouettes, UI hierarchy, and tile readability stay clear even when dense with detail.
- **Scientific Warmth:** Real species and habitats shown with approachable, hand-crafted charm.
- **Water as Hero:** Every scene keeps water quality, reflections, and motion as a primary focal point.
- **Cozy Utility:** Interfaces and tools look inviting and practical, never cold or clinical.

---

## Color Palette

### Master Palette Philosophy
The color palette shifts from **degraded grays and browns** in the opening to **vibrant blues and greens** as the player restores ecosystems. This visual transformation is core to the game's emotional arc.

### Primary Palette

**Ocean Blues:**
- **Deep Navy:** `#1A3A52` — Deep water, night ocean
- **Ocean Blue:** `#2E5E8C` — Standard deep water
- **Cerulean:** `#4A90B8` — Mid-depth water, clear skies
- **Turquoise:** `#6CC4A1` — Shallow tropical water
- **Seafoam:** `#A8D8C9` — Surf, foam, highlights

**Lush Greens:**
- **Kelp Green:** `#2F5233` — Dark seaweed, deep vegetation
- **Mangrove Canopy:** `#4A7C59` — Healthy mangrove foliage
- **Seagrass:** `#6B9D6E` — Underwater meadows
- **Salt Marsh:** `#8FBC8F` — Cordgrass, marsh vegetation
- **Coastal Sage:** `#A8CDAF` — Upland coastal plants

**Earth Tones:**
- **Wet Sand:** `#C4A57B` — Beach sand
- **Mudflat Brown:** `#8B6F47` — Rich tidal mud
- **Sediment:** `#A68A5C` — Underwater sediment
- **Driftwood Gray:** `#9E9E9E` — Weathered wood, rocks
- **Dark Soil:** `#3E2723` — Organic-rich peat

**Golden Hour:**
- **Sunrise Gold:** `#FFD700` — Dawn light
- **Sunset Orange:** `#FF8C42` — Evening glow
- **Warm Amber:** `#FFB84D` — Late afternoon
- **Rose Tint:** `#FFB3C1` — Dusk highlights

**Storm Palette:**
- **Storm Gray:** `#546E7A` — Overcast sky
- **Thunder Cloud:** `#37474F` — Dark storm clouds
- **Lightning Flash:** `#E0F7FA` — Bright lightning
- **Rain Blue:** `#78909C` — Rainy atmosphere

### Degraded vs. Restored Visual Shift

**Degraded Ecosystem (Game Start):**
- Desaturated colors (reduced saturation by 40%)
- More grays and browns
- Murky water (opacity increased)
- Sparse vegetation (empty tiles)
- Minimal wildlife

**Restored Ecosystem (Healthy):**
- Vibrant, saturated colors
- Rich greens and blues dominate
- Crystal-clear water (transparency)
- Dense vegetation coverage
- Abundant wildlife

### Zone-Specific Color Variations

**The Shallows:**
- Lightest blues and turquoises
- Bright sandy tones
- High contrast (sunlight penetration)
- Dappled light effects

**The Mudflats:**
- Rich browns and earth tones
- Muted greens
- Lower saturation overall
- Warm afternoon light

**The Estuary:**
- Deep greens
- Murky brown-green water
- Filtered, dappled lighting
- High complexity

**The Reef Edge:**
- Cooler color temperature
- Deep blues with bright highlights
- Emerald kelp greens
- Dynamic light rays

**The Deep:**
- Darkest blues approaching black
- Minimal color (depth)
- Bioluminescent accents (cyan, green)
- Mysterious, spacious feeling

### Biome Palette Cheat Sheet
- **Shallows:** `#6CC4A1` turquoise, `#A8D8C9` seafoam, `#C4A57B` wet sand, `#FFD700` sunrise gold, `#2F5233` kelp green accents
- **Mudflats:** `#8B6F47` mudflat brown, `#A68A5C` sediment, `#8FBC8F` salt marsh green, `#FFB84D` warm amber light, `#546E7A` storm gray for overcast
- **Estuary:** `#4A7C59` mangrove canopy, `#6B9D6E` seagrass, `#37474F` thunder cloud shadows, `#A8CDAF` coastal sage highlights, `#6CC4A1` water glints
- **Reef Edge:** `#2E5E8C` ocean blue, `#4A90B8` cerulean, `#2F5233` kelp green, `#6CC4A1` turquoise rim light, `#E0F7FA` lightning flash for sparkle
- **Deep:** `#1A3A52` deep navy, `#2E5E8C` ocean blue, `#37474F` thunder cloud, `#A8D8C9` subtle bioluminescent glow, `#E0F7FA` accents

---

## Reference & Inspiration

### Reference Games

**Stardew Valley**
- Pixel art charm
- Readable character designs
- Clear UI hierarchy
- Seasonal color shifts
- **Take:** Clarity, readability, cozy warmth
- **Avoid:** Too retro/pixelated — we want slightly higher fidelity

**Spiritfarer**
- Hand-drawn character animation
- Gorgeous water rendering
- Emotional environmental storytelling
- Beautiful lighting and atmosphere
- **Take:** Emotional depth, water excellence, hand-crafted feel
- **Avoid:** Too stylized/fantastical — we need scientific grounding

**Eastward**
- Detailed pixel art environments
- Rich color palettes
- Layered depth
- Nostalgic but modern
- **Take:** Environmental detail, layering, color richness
- **Avoid:** Post-apocalyptic tone — we want hopeful restoration

**Moonglow Bay**
- Voxel-inspired ocean
- Wholesome fishing themes
- Coastal town atmosphere
- Water effects
- **Take:** Cozy coastal vibe, fishing aesthetics
- **Avoid:** Blocky voxel style — we prefer traditional 2D

**Alba: A Wildlife Adventure**
- Species documentation
- Environmental conservation theme
- Mediterranean color palette
- Peaceful exploration
- **Take:** Species catalog approach, conservation messaging
- **Avoid:** 3D low-poly style — we're 2D isometric

### Real-World Visual References

**Photography:**
- National Geographic ocean photography (accurate species depiction)
- Coastal landscape photography (atmosphere and lighting)
- Underwater photography (color filtering, caustics)
- Tidal pool macro photography (intricate detail)

**Scientific Illustration:**
- Ernst Haeckel's marine biology illustrations (beautiful scientific art)
- Vintage oceanography charts (maps and diagrams)
- Field guide illustrations (species accuracy with artistic style)

**Fine Art:**
- Japanese woodblock prints (Hokusai waves, composition)
- Winslow Homer seascapes (dramatic ocean moments)
- Impressionist coastal paintings (Monet, Renoir — light and atmosphere)
- Watercolor botanical illustrations (soft, organic feel)

### Moodboard Snapshot
- **Water & Atmosphere:** Spiritfarer water rendering, Hokusai wave forms, and National Geographic coastal photography for light, spray, and clarity cues.
- **Habitats by Biome:** Shallow seagrass meadows (Alba: A Wildlife Adventure vibe), muddy marsh channels with cordgrass (Winslow Homer tonal range), and kelp forests with Eastward-style layering.
- **UI & Tools:** Field journal sketch motifs, weathered wood frames, watercolor infill; compass roses and rope knots as recurring anchors.
- **Characters & Wildlife:** Warm, approachable faces (Spiritfarer), practical coastal attire, species drawn like field-guide plates with gentle personality.
- **Palette Progression:** Early-game desaturation from storm grays/browns → late-game saturation from turquoise/kelp greens and golden hour light.

---

## Character Design

### Design Philosophy
"Characters should feel like real people you'd meet in a coastal community — diverse, expressive, grounded in their environment."

### Character Art Style
- **2D Hand-Drawn Sprites:** Frame-by-frame animation
- **Proportions:** Slightly stylized (small heads, expressive faces) but realistic
- **Detail Level:** Readable at distance, detailed enough for portrait close-ups
- **Diversity:** Wide range of ages, ethnicities, body types
- **Coastal Aesthetic:** Maritime clothing, weather-appropriate attire

### Player Character

**Customization Options:**
- **Body Type:** 3 options (slim, average, broad)
- **Skin Tone:** 8 diverse options
- **Hair:** 12 styles × 10 colors
- **Eyes:** 6 shapes × 12 colors
- **Facial Features:** 5 options (facial hair, freckles, etc.)
- **Starting Outfit:** Practical coastal work clothes (customizable later)

**Animation States:**
- Idle (with breathing)
- Walk (8 directions)
- Run (8 directions)
- Plant/dig
- Harvest
- Tool use (spade, rake, nets)
- Boat rowing
- Celebrate/success
- Tired/low stamina
- Interact with NPCs

### Core NPCs

**Old Salt (The Fisherman)**
- **Age:** 70s
- **Build:** Weathered, wiry strength
- **Clothing:** Worn fishing vest, rubber boots, captain's hat
- **Features:** Deep-set eyes, sun-weathered skin, white beard
- **Color Scheme:** Navy blues, faded yellows, earthy tones
- **Expression Range:** Skeptical → Warm smile progression

**Dr. Marina Chen (The Climate Scientist)**
- **Age:** 30s
- **Build:** Average, athletic
- **Clothing:** Field research gear, waterproof jacket, clipboard
- **Features:** Glasses, practical ponytail, enthusiastic expression
- **Color Scheme:** Research navy, safety orange, khaki
- **Expression Range:** Analytical → Excited discovery

**Mayor Stormwell (The Skeptical Politician)**
- **Age:** 50s
- **Build:** Portly, formal posture
- **Clothing:** Button-down shirt, slacks (gradually casual as relationship grows)
- **Features:** Receding hairline, serious expression, gradually softens
- **Color Scheme:** Grays, muted blues, white shirts
- **Expression Range:** Stern → Genuine smile progression

**Kai (The Young Activist)**
- **Age:** Late teens
- **Build:** Energetic, lean
- **Clothing:** Band t-shirts, canvas pants, sneakers, sometimes wetsuit
- **Features:** Bright eyes, animated expressions, colorful accessories
- **Color Scheme:** Bright teals, ocean blues, sunset oranges
- **Expression Range:** Frustrated → Hopeful → Triumphant

**Elder Riverwatcher (Indigenous Elder)**
- **Age:** 70s+
- **Build:** Dignified bearing, traditional clothing elements
- **Clothing:** Mix of traditional and practical coastal wear
- **Features:** Wise eyes, traditional jewelry, respectful design
- **Color Scheme:** Earth tones, ocean blues, natural materials
- **Expression Range:** Thoughtful → Proud blessing

**Captain Rosa (Eco-Tourism Operator)**
- **Age:** 40s
- **Build:** Strong, capable
- **Clothing:** Boat captain uniform, practical but stylish
- **Features:** Confident smile, sun-tanned, windswept hair
- **Color Scheme:** Maritime stripes, rope accents, teal and white
- **Expression Range:** Business-focused → Thrilled partnership

### Wildlife Character Design

**Guiding Principle:** Wildlife should be scientifically accurate but with subtle personality.

**Character Traits:**
- **Sea Otters:** Playful, curious, floating on backs
- **Dolphins:** Graceful, social, occasional jumps
- **Manatees:** Gentle, slow-moving, serene
- **Sea Turtles:** Ancient, wise feeling, peaceful
- **Herons:** Statuesque, patient, sudden strikes
- **Crabs:** Scuttling, defensive postures, personality in eyes

**Animation Approach:**
- Smooth, naturalistic movement
- Occasional personality moments (otter somersault, dolphin breach)
- React to player presence subtly
- Species-specific behavior patterns

---

## Environment Art Direction

### Tile Design System

**Base Tiles:**
- **Water Tiles:** Multiple variations (deep, shallow, wave states)
- **Land Tiles:** Sand, mud, soil, rock
- **Transition Tiles:** Seamless water-to-land blending
- **Vegetation Tiles:** Grass, seagrass, mangrove roots, kelp

**Layering Strategy:**
1. **Base Layer:** Water/land terrain
2. **Vegetation Layer:** Plants, seagrass, kelp
3. **Object Layer:** Rocks, shells, equipment
4. **Wildlife Layer:** Mobile creatures
5. **Effect Layer:** Particles, weather, lighting

### Zone-Specific Environment Design

#### The Shallows

**Visual Identity:** "Crystal clarity and gentle motion"

**Key Visual Elements:**
- **Water:** Translucent turquoise, visible sandy bottom, gentle wave ripples
- **Seagrass:** Swaying meadows in varying heights (seedling to mature)
- **Sandy Bottom:** Varied textures (ripple patterns, shell scatter)
- **Sunlight:** Dappled light patterns on seafloor, god rays through water
- **Wildlife Integration:** Small fish darting through grass, crabs on sand

**Color Grading:** Bright, high saturation, warm tones

**Time-of-Day Variation:**
- **Dawn:** Pink-tinted water, long shadows
- **Midday:** Brightest blues, minimal shadows
- **Dusk:** Golden light filtering through water
- **Night:** Deep blue-black, bioluminescent plankton sparkles

#### The Mudflats

**Visual Identity:** "Rich earth and tidal rhythm"

**Key Visual Elements:**
- **Mudflats:** Glossy wet mud at high tide, cracked at low tide
- **Cordgrass:** Dense stands swaying in wind, golden seed heads
- **Tidal Channels:** Winding water paths through marsh
- **Exposed Substrate:** Shells, worm burrows, crab holes at low tide
- **Wading Birds:** Herons and egrets stalking through shallows

**Color Grading:** Earthy browns, muted greens, warm afternoon light

**Tidal Visual Shift:**
- **High Tide:** Flooded marsh, only grass tops visible, reflective water
- **Mid Tide:** Exposed mud edges, channels visible
- **Low Tide:** Maximum exposure, revealed substrate detail

#### The Estuary

**Visual Identity:** "Mysterious complexity and filtered light"

**Key Visual Elements:**
- **Mangrove Roots:** Complex prop root systems above waterline
- **Canopy:** Dense overhead foliage creating dappled shade
- **Murky Water:** Brown-green water with limited visibility
- **Root Attachments:** Oysters, barnacles encrusting roots
- **Wildlife Haven:** Fish hiding in roots, birds in canopy

**Color Grading:** Deep greens, filtered warm light, high complexity

**Depth Layers:**
- **Canopy Layer:** Dense foliage overhead
- **Mid Layer:** Trunks and prop roots
- **Water Surface:** Murky, calm, reflective
- **Submerged Roots:** Visible just below surface

#### The Reef Edge

**Visual Identity:** "Swaying vertical forests and deep blue"

**Key Visual Elements:**
- **Kelp Fronds:** Tall swaying kelp reaching toward surface
- **Rocky Substrate:** Boulder fields, crevices, vertical surfaces
- **Water Column:** Clear deep blue with light rays
- **Kelp Canopy:** Dense surface canopy when mature
- **Active Wildlife:** Fish schools weaving through kelp, otters floating

**Color Grading:** Cool blues, emerald kelp, high contrast

**Current Motion:**
- Strong directional sway in kelp
- Particle drift showing current
- Surface canopy moving in waves

#### The Deep

**Visual Identity:** "Vast mystery and bioluminescent wonder"

**Key Visual Elements:**
- **Open Water:** Minimal features, sense of depth
- **Light Penetration:** Fading to darkness with depth
- **Whale Silhouettes:** Massive shapes in distance
- **Bioluminescence:** Glowing jellyfish, deep-sea creatures
- **Depth Gradient:** Blue fading to near-black

**Color Grading:** Dark blues to black, minimal saturation, bioluminescent accents

**Scale Communication:**
- Whales shown at large scale for impact
- Vertical depth indicated through light fade
- Sense of vastness through negative space

---

## UI Art Direction

### UI Philosophy
"The interface should feel like tools from your grandmother's coastal lab — weathered, natural, functional, beautiful."

### Visual Themes
- **Driftwood Frames:** UI panels bordered with weathered wood texture
- **Watercolor Elements:** Soft-edged backgrounds, painterly fills
- **Hand-Lettered Fonts:** Readable but artisanal feeling
- **Nautical Accents:** Rope borders, compass roses, wave motifs
- **Field Journal Aesthetic:** Sketches, notes, scientific diagrams

### UI Color Palette
- **Backgrounds:** Soft cream `#F5F5DC` with watercolor texture
- **Frames:** Weathered wood brown `#8B7355`
- **Accents:** Ocean blue `#4A90B8`
- **Text:** Dark charcoal `#2C3E50` (high readability)
- **Highlights:** Turquoise `#6CC4A1`

### Key UI Screens

**Main Dashboard:**
- Large central area showing carbon graph (watercolor line art)
- Driftwood frame with rope corner decorations
- Handwritten-style labels
- Subtle wave pattern background
- Ecosystem icons as watercolor badges

**Inventory:**
- Grid layout with sketched item boxes
- Items drawn in field-guide illustration style
- Tooltips appear as journal notes
- Category tabs look like notebook dividers
- Quantity displayed in handwritten numbers

**Map Screen:**
- Parchment-style background
- Hand-drawn map aesthetic
- Watercolor shading for zones
- Icons for species, quests, points of interest
- Compass rose in corner

**Dialogue Box:**
- Bottom-screen placement
- Character portrait in driftwood frame
- Text on cream background
- Watercolor emotion indicators
- Friendship hearts as shell icons

**Radial Tool Menu:**
- Center: currently equipped tool (illustrated)
- 8 directions: tool icons in circular arrangement
- Rope connecting elements
- Subtle wave-pulse animation on selection

### Icon Design
- **Style:** Line art with watercolor fill
- **Consistency:** 64x64px standard size
- **Readability:** Clear silhouettes, distinct shapes
- **Categories:** Color-coded by type
  - Seeds: Green tones
  - Tools: Gray/brown tones
  - Marine life: Blue tones
  - Products: Varied by item

### Font Choices

**Headers:** Hand-lettered style (similar to "Amatic SC" or "Caveat")
- Warm, organic
- Slightly irregular but readable
- Used for titles, zone names

**Body Text:** Clean serif (similar to "Merriweather" or "Lora")
- High readability
- Warm, friendly
- Used for descriptions, dialogue

**UI Elements:** Simple sans-serif (similar to "Open Sans")
- Ultimate clarity
- Used for numbers, stats, small labels

---

## Animation Principles

### Core Animation Philosophy
"Movement should feel organic, fluid, and alive — like watching nature through a patient observer's eyes."

### Plant Animation

**Seagrass:**
- Gentle undulating motion (underwater current)
- Wave propagation effect (one blade influences next)
- Speed varies with current strength
- Occasional faster sway during tidal shifts

**Salt Marsh Cordgrass:**
- Wind-driven sway
- Synchronized motion in patches
- Seed head bobbing
- Rustling effect through fields

**Mangroves:**
- Canopy leaves rustling
- Branches swaying slightly
- Calm, stately motion
- Prop roots static (structural)

**Kelp:**
- Continuous flowing motion
- Fronds reaching toward surface
- Current-responsive swaying
- Occasional wrapping/unwrapping

### Water Animation

**Surface Water:**
- Subtle wave bobbing (vertical motion)
- Wave crests moving across surface
- Reflections rippling
- Shore wave lapping

**Tidal Motion:**
- Slow rise/fall animation over time
- Waterline moving up/down shores
- Pools filling/draining

**Storm Waves:**
- Larger amplitude swells
- Whitecaps appearing
- Spray particles
- Dramatic crashes on shore

**Underwater:**
- Gentle swaying particles (suspended sediment)
- Light caustics moving
- Occasional bubble rise

### Wildlife Animation

**Fish:**
- School swimming (synchronized turning)
- Darting motion when startled
- Feeding behavior (pecking at substrate)
- Resting in vegetation

**Birds:**
- Perched idle animation (head turns, wing adjusts)
- Flight paths (graceful arcs)
- Hunting strikes (sudden lunge)
- Takeoff and landing

**Marine Mammals:**
- Breathing at surface
- Smooth swimming motion
- Diving sequences
- Social interactions

**Crustaceans:**
- Scuttling walk cycles
- Claw movements
- Defensive postures
- Burrowing into sand

### Player Animation

**Smooth Movement:**
- 8-directional walk with smooth transitions
- Idle breathing animation
- Tool use with anticipation, action, follow-through
- Satisfaction gestures after planting

**Planting Sequence:**
1. Kneel down
2. Dig small hole
3. Place seedling
4. Cover with sediment
5. Pat gently
6. Stand and observe (brief satisfaction moment)

**Harvesting:**
1. Reach/bend
2. Grasp item
3. Pull/lift
4. Inspect briefly
5. Place in collection bag

### Weather Effects Animation

**Rain:**
- Angled raindrops
- Splash effects on water surface
- Accumulating puddles on land
- Lighter/heavier intensities

**Wind:**
- Vegetation bending
- Leaves/debris blowing
- Water surface chop
- Sound sync with visual

**Lightning:**
- Flash (screen brighten)
- Bolt strike
- Thunder delay (distance-based)
- Temporary illumination

---

## VFX & Particle Systems

### Water Particles

**Ripples:**
- Concentric circles expanding from disturbances
- Player movement through water
- Wildlife surfacing
- Rain impact on surface

**Bubbles:**
- Rising from substrate
- Occasional bursts (organic activity)
- Size variation
- Catching light

**Spray:**
- Wave crash on rocks
- Storm surge
- Boat wake
- Wind-blown mist

**Caustics:**
- Moving light patterns on seafloor
- Intensity varies with depth
- Slow, organic motion
- Enhanced at midday

### Plant Effects

**Growth Sparkles:**
- Gentle shimmer when plant reaches new growth stage
- Organic particle motion
- Green-gold color
- Brief duration

**Pollination/Seeding:**
- Seeds/spores drifting
- Carried by water current or wind
- Landing creates small pulse

**Seasonal Transitions:**
- Leaves changing color (marsh grasses)
- Falling particles (autumn)
- New growth bursts (spring)

### Wildlife Effects

**Fish Schools:**
- Coordinated particle movement
- Sudden direction changes
- Schooling behavior patterns
- Shimmer effect (scales catching light)

**Bioluminescence:**
- Plankton glow in disturbed water
- Jellyfish pulsing light
- Deep-sea creature illumination
- Magical nighttime water trails

### Weather Particles

**Rain System:**
- Multi-layered rain (foreground, midground, background for depth)
- Wind-affected angle
- Impact splashes
- Puddle accumulation

**Snow (if applicable in region):**
- Gentle falling
- Accumulation on surfaces
- Melting effect

**Fog:**
- Layered mist particles
- Distance fade effect
- Moves with wind
- Morning/evening concentration

### Special Event Effects

**Carbon Milestone:**
- Radiant green-gold burst
- Upward floating particles
- Lingering shimmer
- Satisfying visual reward

**Species Discovery:**
- Exclamation effect
- Brief highlight on creature
- Codex entry popup animation
- Camera focus shift

**Storm Protection:**
- Ecosystem barrier visualization
- Wave energy absorption effect
- Protected area shimmer
- Dramatic contrast between protected/unprotected

---

## Lighting Design

### Lighting Philosophy
"Lighting should communicate time, weather, mood, and ecosystem health — it's not just illumination, it's storytelling."

### Day/Night Cycle

**Dawn (5:00-7:00):**
- **Color Temperature:** Warm pink-orange `#FFB3C1` to `#FFD700`
- **Shadows:** Long, dramatic
- **Ambient:** Soft, peaceful
- **Special:** God rays through mist

**Morning (7:00-12:00):**
- **Color Temperature:** Neutral to slightly warm
- **Shadows:** Shortening
- **Ambient:** Clear, energizing
- **Special:** Sparkling water highlights

**Midday (12:00-15:00):**
- **Color Temperature:** Neutral white
- **Shadows:** Minimal, directly below
- **Ambient:** Bright, high contrast
- **Special:** Maximum caustic effects underwater

**Afternoon (15:00-18:00):**
- **Color Temperature:** Warm golden `#FFB84D`
- **Shadows:** Lengthening
- **Ambient:** Warm, relaxed
- **Special:** Golden hour glow on water

**Dusk (18:00-20:00):**
- **Color Temperature:** Orange to purple gradient
- **Shadows:** Long, soft edges
- **Ambient:** Romantic, reflective
- **Special:** Silhouettes, reflected sky colors in water

**Night (20:00-5:00):**
- **Color Temperature:** Cool blue `#2E5E8C`
- **Shadows:** Deep, mysterious
- **Ambient:** Dark, peaceful
- **Special:** Bioluminescence, stars reflected, moonlight path on water

### Weather Lighting

**Sunny:**
- High contrast
- Sharp shadows
- Vibrant colors
- Sparkling highlights

**Cloudy:**
- Diffused light
- Soft shadows
- Slightly desaturated
- Even illumination

**Rainy:**
- Darker overall
- Cool color grading
- No sharp shadows
- Wet surface reflections

**Stormy:**
- Very dark
- Dramatic contrast
- Lightning flashes (brief full illumination)
- Ominous atmosphere

**Foggy:**
- Low contrast
- Soft edges everything
- Desaturated
- Atmospheric depth

### Underwater Lighting

**Shallow Water (0-3m):**
- High light penetration
- Visible caustics
- Warm color cast
- Clear visibility

**Mid Water (3-10m):**
- Reduced light
- Cooler colors
- Fading caustics
- Good visibility

**Deep Water (10-25m):**
- Low light
- Blue-green cast
- Minimal caustics
- Limited visibility

**Very Deep (25m+):**
- Minimal light
- Dark blue to black
- Bioluminescence becomes visible
- Mystery and depth

### Ecosystem Health Lighting

**Degraded:**
- Slightly desaturated
- Murky water (light scatter)
- Dull, lifeless feeling
- Less contrast

**Healthy:**
- Vibrant, saturated
- Clear water (clean light penetration)
- Lively, energetic feeling
- Good contrast

**Thriving:**
- Maximum saturation
- Crystal-clear water
- Special subtle glow effect
- Heightened contrast and beauty

---

## Seasonal Visual Changes

### Visual Season Design
Each season transforms the coast, providing variety and reinforcing the passage of time.

### Spring

**Visual Identity:** "Renewal and vibrant growth"

**Changes:**
- **Vegetation:** Brightest greens, new growth everywhere
- **Wildlife:** Increased activity, breeding behaviors
- **Water:** Clear, warming temperatures
- **Weather:** Mix of rain and sun, occasional storms
- **Flowers:** Marsh flowers blooming (yellow, purple)

**Particle Effects:**
- Seeds/pollen drifting
- Spring rain showers
- Blossom petals (upland areas)

### Summer

**Visual Identity:** "Abundant life and golden warmth"

**Changes:**
- **Vegetation:** Lush, full coverage, deeper greens
- **Wildlife:** Maximum biodiversity, young animals
- **Water:** Warmest, most transparent
- **Weather:** Long sunny days, occasional thunderstorms
- **Light:** Extended golden hour, bright midday

**Particle Effects:**
- Heat shimmer over mudflats
- Abundant fish schools
- Flying insects over marsh

### Fall/Autumn

**Visual Identity:** "Golden transformation and migration"

**Changes:**
- **Vegetation:** Marsh grasses turn golden, mangrove leaves yellow
- **Wildlife:** Migration events, birds gathering
- **Water:** Cooling, storm-churned
- **Weather:** More storms, dramatic clouds
- **Colors:** Warm oranges and golds in vegetation

**Particle Effects:**
- Leaves falling (marsh, mangrove)
- Seeds dispersing
- Storm debris

### Winter

**Visual Identity:** "Quiet resilience and stark beauty"

**Changes:**
- **Vegetation:** Dormant grasses (brown/tan), evergreen mangroves muted
- **Wildlife:** Reduced but hardy species, winter migrants
- **Water:** Coldest, stormy, darker color
- **Weather:** More storms, possible frost (region-dependent)
- **Colors:** Desaturated overall, dramatic skies

**Particle Effects:**
- Storm waves and spray
- Wind-blown debris
- Frost crystals (if applicable)
- Dramatic weather systems

### Seasonal Color Grading

**Spring:** +10% saturation, warm shift (+5° color temperature)
**Summer:** +15% saturation, neutral-warm
**Fall:** +5% saturation, orange shift (+10° warm)
**Winter:** -10% saturation, cool shift (-5° color temperature)

---

## Technical Art Specifications

### Asset Creation Guidelines

**Sprites:**
- **Format:** PNG with transparency
- **Base Resolution:** 64x32 tiles, characters ~64px tall
- **Color Depth:** 32-bit RGBA
- **Anti-aliasing:** Minimal (crisp edges for pixel art style)

**Animations:**
- **Frame Rate:** 12 FPS for character animation, 6 FPS for ambient
- **Format:** Sprite sheets
- **Optimization:** Shared palettes where possible

**Backgrounds:**
- **Layering:** Separate layers for parallax scrolling
- **Resolution:** 2x base for zoom support
- **Tiling:** Seamless tiles for water, terrain

**UI Elements:**
- **Resolution:** 2x for retina support
- **Format:** SVG where possible for scalability
- **9-Slice:** UI panels use 9-slice scaling

### Performance Considerations

**Particle Limits:**
- **High Settings:** 5000 active particles
- **Medium Settings:** 2000 active particles
- **Low Settings:** 500 active particles

**Draw Call Optimization:**
- Sprite batching for vegetation
- Instancing for repeated elements
- LOD for distant objects

**Memory Budget:**
- **Texture Memory:** 512MB target
- **Animation Cache:** 128MB
- **UI Assets:** 64MB

---

## Art Pipeline & Tools

### Recommended Tools

**Illustration:**
- **Primary:** Aseprite (pixel art, sprite animation)
- **Secondary:** Procreate or Photoshop (concept art)
- **Vector:** Illustrator (UI elements, icons)

**Animation:**
- Aseprite (sprite animation)
- Spine or DragonBones (skeletal animation for complex creatures)

**VFX:**
- Particle Designer or custom engine tools
- After Effects (for prototyping effects)

**Concept Art:**
- Procreate, Photoshop
- Physical watercolors (scanned) for authentic texture

### Asset Naming Conventions

**Sprites:**
- `{category}_{name}_{state}_{frame}.png`
- Example: `char_player_walk_north_01.png`

**Tiles:**
- `tile_{zone}_{type}_{variant}.png`
- Example: `tile_shallows_seagrass_mature.png`

**UI:**
- `ui_{element}_{state}.png`
- Example: `ui_button_hover.png`

## Cross-Discipline Cohesion
- **Gameplay:** Art communicates mechanics (tide height, growth stages, carbon progress) with readable silhouettes, tile clarity, and state changes.
- **UX/UI:** UI motifs echo environmental materials (rope, wood, parchment) while maintaining accessibility contrast and clear hierarchy.
- **Narrative:** Character and biome visuals reflect story beats (from degraded to restored), and NPC attire matches their role and environment.
- **Audio & VFX:** Water, wind, and wildlife VFX pair with corresponding audio layers; particle intensity respects performance budgets and clarity.
- **Technical:** Palette and asset specs align with texture budgets, LOD, and batching guidelines to keep performance targets achievable.

---

## Conclusion

The art of Blueth Farm should create a world that players want to spend hours in — a place of beauty, transformation, and hope. Every visual decision should support the core experience: watching a degraded coast come back to life through your patient, caring work.

The visuals aren't just decoration — they're the primary feedback system showing players their impact. When the water clears, the wildlife returns, and the colors shift from gray to vibrant green, players should *feel* the restoration happening.

**Guiding Question for All Art Decisions:**
"Does this help the player see and feel the coast healing?"

---

**Document End**

*This art direction guide is a living document. As we prototype and iterate, we'll refine these guidelines based on what works best for the game experience.*
