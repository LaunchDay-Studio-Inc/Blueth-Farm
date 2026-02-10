# Guided Tutorial Implementation via Old Salt

## Overview

This implementation adds a guided tutorial experience delivered through Old Salt, the fisherman NPC who serves as the player's mentor. The tutorial addresses the issue noted in the PROTOTYPE_PLAN: "No guided tutorial experience" and provides onboarding for new players to avoid confusion and frustration.

## Key Components

### 1. Tutorial-Specific Dialogue Trees (old_salt.tres)

Old Salt now has 8 tutorial-specific dialogue trees:
- `tutorial_welcome` - Introduction when tutorial starts
- `tutorial_after_movement` - Prompts player to open journal
- `tutorial_meet_at_dock` - Meeting Old Salt at the dock
- `tutorial_give_seeds` - Giving eelgrass seeds to player
- `tutorial_about_planting` - Instructions on how to plant
- `tutorial_first_plant_complete` - Congratulations on first planting
- `tutorial_about_dashboard` - Explanation of carbon dashboard
- `tutorial_complete` - Final encouragement message

### 2. Tutorial System Integration (tutorial_system.gd)

Enhanced the existing tutorial system with:
- `_trigger_old_salt_dialogue(dialogue_key)` - Method to trigger specific Old Salt dialogues
- Integration at each tutorial step to show appropriate Old Salt dialogue
- Automatic dialogue triggers on step transitions
- Congratulations dialogue after key achievements

### 3. NPC Controller Enhancement (npc_controller.gd)

Updated NPC dialogue selection to:
- Check if tutorial is active for Old Salt
- Return tutorial-specific dialogue during TALK_TO_OLD_SALT step
- Fall back to normal dialogue after tutorial completion

### 4. Game World Setup (game_world.tscn)

Added essential nodes:
- **DialogueBox** - UI for displaying NPC dialogue with typewriter effect
- **NPCManager** - Spawns and manages NPCs including Old Salt
- **TutorialTooltip** - Shows tutorial step instructions
- **TutorialSystem** - Added to "tutorial_system" group for easy lookup

### 5. DialogueBox Configuration (dialogue_controller.gd)

- Set `process_mode = PROCESS_MODE_ALWAYS` to work during DIALOGUE game state
- Integrated with NPCManager for NPC portrait colors and names
- Supports typewriter effect and player interaction

### 6. Automatic Tutorial Start (game_world_controller.gd)

- Tutorial starts automatically for new players
- Checks `GameManager.tutorial_completed` flag
- Only gives starting seeds if tutorial was already completed
- Tutorial-provided seeds given at appropriate step

## Tutorial Flow

The tutorial guides players through these steps:

1. **WELCOME** - Old Salt welcomes player, explains basic movement
2. **OPEN_JOURNAL** - Old Salt prompts to check grandmother's journal
3. **WALK_TO_DOCK** - Player navigates to meet Old Salt
4. **TALK_TO_OLD_SALT** - First NPC interaction, learn about restoration
5. **OPEN_INVENTORY** - Receive seeds, learn inventory system
6. **EQUIP_AND_PLANT** - Plant first seagrass, trigger ecosystem restoration
7. **CHECK_DASHBOARD** - Learn about carbon tracking
8. **COMPLETE** - Tutorial finished, normal gameplay begins

## Technical Details

### Integration Pattern

The tutorial uses a multi-pronged approach:
1. Tutorial system tracks current step
2. Tutorial tooltip shows objectives
3. Old Salt provides narrative context via dialogue
4. Step conditions check player actions
5. Automatic progression on completion

### Dialogue Triggering

Old Salt dialogue is triggered in two ways:
1. **Automatic** - Tutorial system calls `_trigger_old_salt_dialogue()` on step start
2. **Interactive** - Player presses E near Old Salt, NPC controller checks tutorial state

### State Management

- `GameManager.tutorial_completed` - Persistent flag across saves
- `tutorial_system.tutorial_active` - Active during tutorial
- `tutorial_system.current_step` - Current tutorial step enum
- `GameManager.current_state` - Switches to DIALOGUE during conversations

## Testing

### Automated Tests

File: `game/tests/test_tutorial_integration.gd`

Tests verify:
- Old Salt has all required dialogue trees
- Dialogue format is correct
- Tutorial system has integration methods
- Tutorial steps are properly defined
- Associated quests are configured

Run tests:
```bash
cd game
godot --headless --script addons/gut/gut_cmdln.gd -gconfig=.gutconfig.json -gexit
```

### Manual Testing

See `TUTORIAL_TESTING.md` for comprehensive manual test checklist covering all 8 tutorial steps.

## Files Modified

1. `game/resources/npcs/old_salt.tres` - Added tutorial dialogue trees
2. `game/scripts/progression/tutorial_system.gd` - Added Old Salt integration
3. `game/scripts/npcs/npc_controller.gd` - Tutorial dialogue selection
4. `game/scripts/ui/dialogue_controller.gd` - Process mode configuration
5. `game/scripts/world/game_world_controller.gd` - Auto-start tutorial
6. `game/scenes/game_world.tscn` - Added DialogueBox, NPCManager, TutorialTooltip

## Files Created

1. `game/tests/test_tutorial_integration.gd` - Automated test suite
2. `TUTORIAL_TESTING.md` - Manual testing guide

## Future Enhancements

Potential improvements:
1. Add objective markers pointing to dock location
2. Implement tutorial skip confirmation dialogue
3. Add tutorial replay option for returning players
4. Create additional tutorial quests beyond basics
5. Add visual indicators for NPC interaction prompts
6. Implement tutorial progress saving/loading
7. Add accessibility options for dialogue speed

## Success Metrics

The tutorial is successful if:
- ✅ New players receive guided onboarding
- ✅ Old Salt provides narrative context
- ✅ All core mechanics are introduced
- ✅ Tutorial integrates with existing systems
- ✅ Tutorial can be completed or skipped
- ✅ State persists correctly across sessions
