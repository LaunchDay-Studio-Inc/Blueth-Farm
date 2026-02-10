# Blueth Farm - Godot 4.x Game Project

## Overview
Blueth Farm is a cozy simulation game about restoring coastal ecosystems, sequestering carbon, and saving a struggling coastal community. Built with Godot 4.x and GDScript.

## Requirements
- **Godot Engine 4.3** or later
- Operating System: Windows, macOS, or Linux

## How to Run the Project

### 1. Install Godot 4.3+
Download and install Godot 4.3 (or later) from the official website:
- https://godotengine.org/download

### 2. Open the Project
1. Launch Godot Engine
2. Click "Import" on the project manager
3. Navigate to this `game/` directory
4. Select the `project.godot` file
5. Click "Import & Edit"

### 3. Run the Game
- Press **F5** or click the Play button in the top-right corner
- The game will compile and launch

Alternatively, from the command line:
```bash
godot --path /path/to/game/ project.godot
```

## Project Structure

```
game/
├── project.godot           # Godot project configuration
├── scenes/                 # All game scenes (.tscn files)
│   ├── main.tscn          # Main entry point
│   ├── game_world.tscn    # Primary game world
│   ├── ui/                # UI scenes
│   ├── entities/          # Player, NPCs, wildlife
│   └── effects/           # Visual effects
├── scripts/               # All GDScript files
│   ├── autoloads/         # Global singleton managers
│   ├── player/            # Player-related scripts
│   ├── world/             # World/environment systems
│   ├── farming/           # Planting and growth systems
│   ├── ecosystem/         # Biodiversity and wildlife
│   ├── economy/           # Market and trading
│   ├── npcs/              # NPC and dialogue systems
│   ├── research/          # Tech tree and research
│   └── ui/                # UI controllers
├── resources/             # Godot resources (.tres files)
│   ├── species/           # Plant species definitions
│   ├── npcs/              # NPC character data
│   ├── quests/            # Quest definitions
│   └── research/          # Tech tree nodes
├── assets/                # Art, audio, fonts
│   ├── sprites/           # 2D sprites (placeholder)
│   ├── audio/             # Music and SFX (placeholder)
│   └── fonts/             # Font files
└── tests/                 # Unit tests
```

## Core Systems

### Autoload Singletons (Global Managers)
These are automatically loaded and available throughout the game:

- **GameManager** - Global game state, progression, gold, research points
- **TimeManager** - Day/night cycle, seasons, tidal system, lunar phases
- **CarbonManager** - Carbon tracking, sequestration, carbon credits
- **EcosystemManager** - Biodiversity, wildlife spawning, ecosystem health
- **SaveManager** - Save/load system with JSON serialization
- **AudioManager** - Music, SFX, and layered ambient audio

### Key Features
- **Isometric 2D World** - 8-directional movement, tilemap-based
- **Tidal System** - Realistic sinusoidal tides based on lunar cycles
- **Plant Growth** - Multi-stage growth simulation with real science data
- **Carbon Sequestration** - Track CO₂ sequestration based on real blue carbon science
- **Biodiversity** - Shannon diversity index, wildlife attraction
- **NPC Interactions** - Dialogue system, relationships, quests
- **Research Tree** - Unlock new species, tools, and capabilities
- **Dynamic Economy** - Market system, carbon credits, town investments

## Controls

### Movement
- **W/A/S/D** - Move player (8 directions)

### Tools & Interaction
- **E** - Interact with NPCs/objects
- **Q** - Open tool radial menu
- **1-5** - Quick-select tools

### UI Toggles
- **Tab** - Toggle carbon dashboard
- **I** - Toggle inventory
- **C** - Toggle codex (species encyclopedia)
- **ESC** - Pause menu

## Science Foundation

The game is based on real blue carbon science:
- Seagrass sequestration: ~138 tonnes CO₂/km²/year
- Salt marshes: ~218 tonnes CO₂/km²/year
- Mangroves: ~226 tonnes CO₂/km²/year

Carbon calculations use real data from `docs/SCIENCE_REFERENCE.md`.

## Development Status

This is a vertical slice prototype implementing:
- ✅ Core autoload managers
- ✅ Time and tidal systems
- 🚧 Player character and movement
- 🚧 Planting and growth systems
- 🚧 Carbon tracking and dashboard
- 🚧 NPC dialogue and quests
- 🚧 UI systems
- ⏳ Complete Year 1 gameplay loop
- ⏳ Audio and visual polish

Legend: ✅ Complete | 🚧 In Progress | ⏳ Planned

## Placeholder Art

Currently using simple colored shapes for visuals. The focus is on mechanics and systems. Art assets will be added in future iterations.

## Testing

Run tests from Godot's Script editor or use GUT (Godot Unit Testing):
```bash
godot --path /path/to/game/ -s --path tests/
```

## Troubleshooting

**Problem: Project won't open**
- Ensure you're using Godot 4.3 or later
- Check that `project.godot` is in the current directory

**Problem: Autoloads not working**
- Check Project Settings → Autoload to verify all managers are registered
- Restart Godot if you just imported the project

**Problem: Scenes are missing/empty**
- Some scenes are still being implemented
- Check the development status above

## Contributing

See the main repository `CONTRIBUTING.md` for development guidelines.

## License

See LICENSE file in the repository root.

## Documentation

Full design documentation is in the `docs/` directory:
- `docs/GDD.md` - Game Design Document
- `docs/PROTOTYPE_PLAN.md` - Vertical Slice Plan
- `docs/ART_DIRECTION.md` - Visual Style Guide
- `docs/SCIENCE_REFERENCE.md` - Blue Carbon Science Data

## Support

For issues or questions, please open an issue on the GitHub repository.
