# Codex UI System

## Overview
The Codex UI is an educational encyclopedia that tracks discovered species, wildlife, ecosystem services, and real-world blue carbon science facts. It serves as the game's educational hub, making complex climate science accessible and engaging.

## Files Created
1. `game/scripts/ui/codex_controller.gd` - Main controller script
2. `game/scenes/ui/codex_ui.tscn` - UI scene definition
3. `game/scenes/game_world.tscn` - Updated to include CodexUI instance

## Features

### 1. Species Tab
- **Discovery System**: Species are marked as discovered when planted or encountered
- **Organized by Zone**: Seagrass, Salt Marsh, Mangrove, Kelp Forest
- **Detailed Information**:
  - Common and scientific names
  - Zone and habitat requirements
  - Carbon sequestration rates
  - Growth stages
  - Preferred environmental conditions (depth, salinity)
  - Real-world science facts from species resources
- **Progress Tracking**: "X/9 Species Discovered" counter
- **Visual Feedback**: Discovered species show full details with green highlight, undiscovered show "???" with zone hints

### 2. Wildlife Tab
- **8 Wildlife Types**: fish_small, fish_large, crab, shorebird, wadingbird, turtle, dolphin, manatee
- **Rich Descriptions**: Educational information about each animal's role in the ecosystem
- **Unlock Requirements**: Shows biodiversity thresholds and plant requirements
- **First Sighting Tracking**: Records the date when each wildlife type was first spotted
- **Progressive Discovery**: Undiscovered wildlife shows requirements as hints

### 3. Ecosystem Services Tab
Real-time metrics showing current farm impact:
- **Biodiversity Index** (0-100): Species diversity and habitat complexity
- **Ecosystem Health** (0-100): Overall vitality from biodiversity + food web balance
- **Total Carbon Sequestered**: Running total in tonnes CO₂
- **Coastal Protection** (0-100): Wave attenuation and erosion prevention
- **Fisheries Habitat Value** (0-100): Nursery habitat quality
- **Water Filtration** (0-100): Sediment trapping and nutrient filtering
- **Wildlife Populations**: Live counts of all discovered wildlife

### 4. Science Facts Tab
Educational content from `docs/SCIENCE_REFERENCE.md`:
- **Blue vs Green Carbon**: Comparison table showing sequestration rates
- **Seagrass Facts**: 138 tonnes CO₂/km²/year, 1000+ year storage
- **Salt Marsh Facts**: 218 tonnes CO₂/km²/year, deep peat deposits
- **Mangrove Facts**: 226 tonnes CO₂/km²/year, 3-5x more carbon than rainforests
- **Kelp Facts**: Fastest growing (30cm/day), deep ocean carbon export
- **Global Impact**: Status of blue carbon habitats worldwide
- **Why It Matters**: The importance of blue carbon for climate and communities

## User Experience

### Opening the Codex
- **Keyboard**: Press `C` key
- **Input Action**: `toggle_codex` (defined in project.godot)
- **Mutual Exclusion**: Automatically closes if another UI is open

### Navigation
- **4 Tabs**: Click to switch between Species, Wildlife, Ecosystem Services, Science Facts
- **Scrolling**: Each tab has vertical scrolling for content
- **Close Button**: X button in top-right or press C again

### Visual Design
- **Layer 7**: Between Market (6) and Journal (8) for proper z-ordering
- **Dark Overlay**: Semi-transparent background (50% opacity)
- **Centered Panel**: 1200x900px main panel
- **Color Palette**:
  - Ocean Deep (#0A2540) - Headers
  - Ocean Mid (#1B4965) - Accents
  - Seagrass Green (#4A7C59) - Discovered items
  - Coral Accent (#FF6B6B) - Wildlife highlights
  - Sand Light (#F5DEB3) - Science fact panels
- **Progressive Disclosure**: Locked content shows hints without spoiling

## Integration

### Data Sources
1. **EcosystemManager** (Autoload):
   - `discovered_species`: Array of planted species IDs
   - `planted_species`: Dictionary of species counts
   - `biodiversity_score`: Current biodiversity (0-100)
   - `ecosystem_health`: Overall health (0-100)
   - `wildlife_populations`: Dictionary of wildlife counts

2. **WildlifeSpawner** (Group: "wildlife_spawner"):
   - `first_sightings`: Dictionary tracking first encounter dates
   - Wildlife spawn requirements and thresholds

3. **CarbonManager** (Autoload):
   - `total_carbon_sequestered`: Running total in tonnes

4. **Species Resources** (*.tres files):
   - Species data: names, zones, carbon rates, growth stages
   - `codex_entry`: Science facts for educational value

### Signals Connected
- `EcosystemManager.species_discovered` → Updates species list
- `EcosystemManager.wildlife_spawned` → Updates wildlife list

### Pause Behavior
- Opens in paused state (`get_tree().paused = true`)
- Closes unpause automatically

## Educational Value

### Learning Outcomes
Players will learn:
1. **Blue carbon ecosystems** are 10-50x more effective than forests at sequestering CO₂
2. **Species diversity** creates resilient ecosystems with multiple benefits
3. **Coastal protection** from mangroves and salt marshes saves lives and property
4. **Fisheries support** - 20% of major fisheries depend on seagrass nurseries
5. **Real-world data** - All sequestration rates from peer-reviewed research
6. **Biodiversity thresholds** needed to support different wildlife
7. **Ecosystem services** provide measurable economic and environmental value

### Scientific Accuracy
All data sourced from:
- `docs/SCIENCE_REFERENCE.md` - Peer-reviewed carbon sequestration rates
- Species resource files - Realistic habitat requirements
- Wildlife spawner - Biologically accurate population thresholds

## Technical Details

### Performance
- **Lazy Loading**: Tabs built only when first shown
- **Refresh on Open**: Data updated each time codex opens
- **Efficient Rendering**: Uses VBoxContainers with ScrollContainers
- **No Heavy Assets**: All UI is procedurally generated

### Code Structure
```gdscript
# Main sections (963 lines total)
- Art Direction Colors (14 lines)
- UI References (@onready vars)
- Species/Wildlife Data (constants)
- Ready/Input/Toggle (core functions)
- Species Tab Builder (150 lines)
- Wildlife Tab Builder (120 lines)
- Ecosystem Services Tab Builder (200 lines)
- Science Facts Tab Builder (150 lines)
- Style Helpers (panel creation)
```

### Extensibility
Easy to add:
- New species (add to SPECIES_PATHS constant + resource file)
- New wildlife (add to WILDLIFE_INFO dictionary)
- New ecosystem services (add metric to services tab builder)
- New science facts (add section in facts tab builder)

## Testing Checklist

### Manual Testing
- [ ] Press C to open codex
- [ ] All 4 tabs are accessible
- [ ] Species counter shows 0/9 initially
- [ ] Discovered species show full details
- [ ] Undiscovered species show "???" with hints
- [ ] Wildlife tab shows 8 wildlife types
- [ ] Ecosystem services show current values
- [ ] Science facts display all sections
- [ ] Close button works
- [ ] Pressing C again closes codex
- [ ] Game pauses when open
- [ ] Cannot open if another UI is visible
- [ ] Scrolling works in all tabs

### Integration Testing
- [ ] Plant a species → appears in codex as discovered
- [ ] Trigger wildlife spawn → appears in wildlife tab
- [ ] Ecosystem metrics update in real-time
- [ ] First sighting dates recorded correctly

## Future Enhancements
1. **Search/Filter**: Add search bar for species and facts
2. **Achievements**: Track "discovered all wildlife" milestones
3. **Comparison Mode**: Side-by-side species comparison
4. **Export**: Generate PDF report of farm's ecosystem services
5. **Tooltips**: Hover info on technical terms
6. **Animations**: Smooth transitions when discovering new content
7. **Sound**: Page flip sounds, discovery chimes

## Maintenance Notes
- Species data lives in `game/resources/species/*.tres` - update there for changes
- Science facts are in code - consider moving to JSON/resource file for easier editing
- Wildlife requirements mirror `wildlife_spawner.gd` - keep in sync
- Color palette defined as constants - change at top of script for theme updates
