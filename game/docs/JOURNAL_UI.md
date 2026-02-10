# Journal UI System

The Journal UI is the emotional heart of Blueth Farm, displaying Grandmother Elara's journal entries as the player discovers them throughout the game.

## Overview

The journal system consists of three main components:

1. **JournalEntryData** (`game/scripts/npcs/journal_entry_data.gd`) - Resource class for journal entries
2. **JournalSystem** (`game/scripts/npcs/journal_system.gd`) - Backend system managing unlock conditions and entry discovery
3. **JournalUI** (`game/scenes/ui/journal_ui.tscn` + `game/scripts/ui/journal_controller.gd`) - Frontend UI for reading journal entries

## Features

### UI Components

- **Full-screen weathered notebook layout** with parchment background (#F5F0E1) and driftwood borders (#8B7355)
- **Left sidebar**: Scrollable list of all 12 journal entries
  - Discovered entries show title
  - Undiscovered entries show "🔒 ???"
  - New (unread) entries highlighted with golden glow ⭐
- **Right panel**: Selected entry content
  - Golden title text
  - Scrollable grandmother's journal text
  - Unlock condition information
- **Entry counter**: Shows "X / 12 entries discovered"
- **Close button**: X in top-right corner
- **Toggle hotkey**: Press **J** to open/close journal

### Discovery System

Journal entries unlock based on gameplay milestones:

- `game_start` - Available at game start
- `first_plant` - First successful planting
- `first_harvest` - First harvest
- `carbon_X` - Sequestering X tonnes of CO₂
- `year_X` - Reaching year X
- `friendship_X_NPC` - Reaching friendship level X with an NPC
- `wildlife_TYPE` - First sighting of wildlife type

### New Entry Notifications

When a new journal entry is discovered:
1. Entry appears in the list with golden glow
2. "⭐ (NEW!)" indicator appears on button
3. Notification popup shows: "📖 New Journal Entry!"
4. Research points bonus awarded automatically
5. New indicator removed when entry is read

## Integration

### Input Mapping

Added to `project.godot`:
```
toggle_journal={
  "deadzone": 0.5,
  "events": [J key (physical_keycode: 74)]
}
```

### Game World

Added to `game/scenes/game_world.tscn`:
- `JournalSystem` node (in "journal_system" group)
- `JournalUI` CanvasLayer (layer 8)

### Mutual Exclusion

The Journal UI automatically closes other UI panels when opened:
- Inventory UI
- Carbon Dashboard
- Market UI
- Pause Menu

## Journal Entries

All 12 journal entries are stored as resources in `game/resources/journal/`:

1. `01_welcome_home.tres` - Welcome Home
2. `02_seagrass_secret.tres` - The Seagrass Secret
3. `03_tides_of_change.tres` - Tides of Change
4. `04_old_friends.tres` - Old Friends
5. `05_numbers_dont_lie.tres` - The Numbers Don't Lie
6. `06_storm_warning.tres` - Storm Warning
7. `07_roots_run_deep.tres` - Roots Run Deep
8. `08_elders_wisdom.tres` - Elder's Wisdom
9. `09_mayors_doubt.tres` - The Mayor's Doubt
10. `10_life_returns.tres` - Life Returns
11. `11_legacy.tres` - Legacy
12. `12_dear_grandchild.tres` - Dear Grandchild

## Art Direction

The journal follows the game's art direction with:

- **Parchment background**: #F5F0E1 (warm, weathered notebook feel)
- **Driftwood borders**: #8B7355 (natural, coastal aesthetic)
- **Golden highlights**: #FFD700 (special discoveries, important text)
- **Dark text**: #2C2416 (readable against parchment)
- **Locked color**: #6B5D52 (muted, mysterious)
- **Overlay**: Semi-transparent black (0, 0, 0, 0.5)

### Typography

- **Journal title**: 32pt
- **Entry counter**: 18pt
- **Section headers**: 20pt
- **Entry titles**: 28pt (golden)
- **Entry content**: 16pt (scrollable RichTextLabel)
- **Unlock info**: 12pt

## Save System

The journal system saves:
- Discovered entry IDs (managed by JournalSystem)
- New/unread entry IDs (managed by JournalUI)

## Testing

To test the journal system:

1. Run the game
2. Press **J** to open the journal
3. Entry #1 "Welcome Home" should be unlocked (unlock_condition: "game_start")
4. Other entries will unlock as you hit milestones
5. Click entries to read them
6. New entries will have golden glow until clicked

## Future Enhancements

Potential improvements:
- Audio: Page-turning sound effects
- Animation: Smooth page transitions
- Search/filter: Find entries by keyword
- Bookmarks: Mark favorite entries
- Share: Screenshot/quote sharing feature
