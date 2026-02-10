# UI Testing Guide for Quest Journal, Research Tree, and Market

## Overview

This document describes how to test the three main UI systems that have been integrated:
1. **Quest Journal** (Quest Log) - Press `J` to toggle
2. **Research Tree** (Tech Tree) - Press `R` to toggle
3. **Market/Shop** - Press `M` to toggle

All UIs support ESC key to close and are integrated with UIStateManager for mutual exclusion (only one UI panel open at a time).

## Prerequisites

- Godot 4.x installed
- Blueth Farm project loaded
- Game scene running (scenes/game_world.tscn)

## Testing Quest Journal (J Key)

### Basic Functionality
1. Press `J` to open the Quest Journal
2. Verify the UI displays with:
   - "Quest Log" title at top
   - Active quests count and completed quests count
   - Two sections: Active Quests and Completed Quests
   - Quest details panel on the right

### Test Quest Registration
```gdscript
# In QuestSystem node or GameWorldController:
var quest_system = get_node("/root/GameWorld/QuestSystem")

var test_quest = {
    "id": "test_first_quest",
    "title": "Your First Restoration",
    "description": "Learn the basics of coastal restoration.",
    "objectives": [
        {"description": "Plant 3 seagrass", "target": 3},
        {"description": "Talk to Dr. Marina", "target": 1}
    ],
    "rewards": {
        "gold": 50,
        "research_points": 5
    }
}

quest_system.register_quest(test_quest)
quest_system.start_quest("test_first_quest")
```

### Expected Behavior
- Quest appears in Active Quests list with title
- Clicking the quest shows details on the right
- Objectives show with checkboxes (unchecked initially)
- Rewards displayed at bottom: "50 Gold, 5 Research Points"
- New quest badge (⭐) appears next to the quest

### Test Quest Updates
```gdscript
# Update objective progress
quest_system.update_objective("test_first_quest", 0, 1)  # Plant 1 seagrass
quest_system.update_objective("test_first_quest", 0, 2)  # Plant 2 more
```

### Expected Behavior
- Quest updates in real-time
- Objective shows progress (3/3)
- Checkbox becomes checked when objective complete
- When all objectives complete, quest auto-moves to Completed section

### UI Controls
- `J` key toggles visibility
- `ESC` key closes the UI
- Close button (X) in top-right corner
- Completed Quests toggle checkbox to show/hide completed section

## Testing Research Tree (R Key)

### Basic Functionality
1. Press `R` to open the Research Tree
2. Verify the UI displays with:
   - "Research Tree" or similar title
   - Current research points balance displayed prominently
   - 4 branches displayed: Ecology, Engineering, Policy, Culture
   - 8 nodes per branch

### Test Branch Status
- **Ecology** - Should be unlocked by default (green checkmark)
- **Engineering** - Locked until Marine Lab built (gray, shows requirement)
- **Policy** - Locked until Mayor Hayes friendship 40+ (gray)
- **Culture** - Locked until Elder Tide friendship 20+ (gray)

### Test Node States
Nodes should display in three states:
1. **Locked** (gray) - Prerequisites not met or insufficient points
2. **Available** (highlighted/glowing) - Prerequisites met and enough points
3. **Unlocked** (full color) - Already researched

### Test Research Unlock
```gdscript
# Give player research points
GameManager.research_points = 50

# Unlock a node (click on available node in UI)
# Or programmatically:
var tech_tree = get_node("/root/TechTree")
tech_tree.research_node("eco_survey")  # 10 points
```

### Expected Behavior
- Click on available node shows detail popup
- Detail popup shows:
  - Node name and description
  - Cost in research points
  - Prerequisites (if any)
  - Unlock effect description
  - "Research" button (enabled if affordable)
- Clicking Research button:
  - Deducts points
  - Unlocks node (changes to full color)
  - Dependent nodes may become available
  - Popup closes
  - Effect is applied to game

### UI Controls
- `R` key toggles visibility
- `ESC` key closes the UI
- Close button (X) in top-right corner
- Click nodes to see details
- Cancel button closes detail popup

## Testing Market/Shop (M Key)

### Basic Functionality
1. Press `M` to open the Market
2. Verify the UI displays with:
   - "Market" title
   - Current gold balance displayed
   - Market hours status (Open 8am-6pm)
   - Two tabs: "Buy Seeds" and "Sell Goods"
   - Carbon credits section at bottom

### Test Buy Tab
- Lists all available seeds with:
  - Item name
  - Base price
  - Current price (with seasonal modifier if active)
  - Quantity selector (- / number / +)
  - Buy button

### Test Purchase
```gdscript
# Give player gold
GameManager.gold = 500
```

1. Select item quantity (click + or -)
2. Click Buy button
3. Expected behavior:
   - Gold deducts (price × quantity)
   - Item added to player inventory
   - Buy list refreshes
   - Success sound plays (if audio enabled)
   - If insufficient gold, button grayed out

### Test Sell Tab
1. Switch to "Sell Goods" tab
2. Lists items from player inventory that are sellable
3. Shows:
   - Item name
   - Quantity owned
   - Sell price (with seasonal modifier)
   - "Sell 1" button
   - "Sell All" button

### Test Selling
1. Click "Sell 1" or "Sell All"
2. Expected behavior:
   - Item removed from inventory
   - Gold added
   - Sell list refreshes
   - If no items, shows "No items to sell" message

### Test Market Hours
Market is open 8am-6pm (game time).

```gdscript
# Close market (simulate time passing to 7pm)
TimeManager.current_hour = 19
```

Expected behavior:
- Market closed overlay appears
- Shows "Market Closed" message
- Cannot buy/sell items
- Can still view prices and inventory

### Test Carbon Credits
- Shows available carbon credits from CarbonManager
- Shows current price per credit
- "Sell Carbon Credits" button
- Click to sell all credits for gold

### UI Controls
- `M` key toggles visibility
- `ESC` key closes the UI
- Close button (X) in top-right corner
- Tab buttons to switch between Buy/Sell
- Quantity spinners (+ / -)

## HUD Keybinding Hints

At the bottom center of the screen, you should see:
```
[I] Inventory  [J] Quests  [R] Research  [M] Market  [Tab] Carbon
```

This provides a quick reference for players to know which keys open which UIs.

## Common Issues and Troubleshooting

### Quest Journal doesn't show quests
- Verify QuestSystem node exists in GameWorld
- Check that quests are registered before starting
- Verify quest data has required fields: id, title, description, objectives

### Tech Tree doesn't show nodes
- Verify TechTree autoload is configured in project.godot
- Check that tech_tree.initialize_tech_tree() was called
- Verify GameManager.research_points exists

### Market doesn't show items
- Verify MarketSystem autoload is configured
- Check that player inventory exists and is accessible
- Verify SEED_BASE_PRICES and HARVEST_BASE_PRICES are defined in MarketSystem

### UIs don't close with ESC
- Verify process_mode is set to PROCESS_MODE_ALWAYS
- Check that _input() function is not being blocked by another UI

### Multiple UIs open at once
- Verify UIStateManager autoload is configured
- Check that each UI calls UIStateManager.open_panel() and close_panel()
- Ensure all UIs are registered in UIStateManager

## Integration Testing

### Test UI Mutual Exclusion
1. Open Quest Journal (`J`)
2. Open Research Tree (`R`)
3. Expected: Quest Journal closes, Research Tree opens
4. Open Market (`M`)
5. Expected: Research Tree closes, Market opens
6. Press `ESC`
7. Expected: Market closes

### Test with Pause Menu
1. Open Quest Journal (`J`)
2. Press `ESC` to pause
3. Expected: Pause menu opens, game state changes
4. Resume game
5. Press `J` again
6. Expected: Quest Journal opens normally

### Test Input Actions
Verify all keybindings in project.godot:
- `toggle_quest_log` = `J` (physical_keycode 74)
- `toggle_tech_tree` = `R` (physical_keycode 82)
- `toggle_market` = `M` (physical_keycode 77)

## Visual Verification

### Color Palette
All UIs should use the game's color palette:
- Ocean Blue: `#2E5E8C`
- Cerulean: `#4A90B8`
- Seafoam: `#A8D8C9`
- Kelp Green: `#2F5233`
- Sand: `#C4A882`
- Warm White: `#FAF3E8`

### Quest Journal
- Background: Dark ocean blue with transparency
- Border: Sand/brown color
- Text: Warm white
- Active quests: Green-tinted buttons
- Completed quests: Gold/yellow checkmark

### Research Tree
- Node colors:
  - Ecology: Seagrass Green `#4A7C59`
  - Engineering: Coral Accent `#FF6B6B`
  - Policy: Ocean Mid `#1B4965`
  - Culture: Sand Light `#F5DEB3`
- Locked nodes: Gray `#6B5D52`
- Available nodes: Highlighted with glow

### Market
- Background: Matching Quest Journal style
- Buy button: Green tint
- Sell button: Orange tint
- Gold display: Yellow/gold color

## Performance Testing

### Load Testing
1. Register 10+ quests
2. Start all quests
3. Open Quest Journal
4. Expected: Smooth scrolling, no lag

### Memory Testing
1. Open and close each UI 20+ times
2. Check for memory leaks
3. Expected: No increase in memory usage

### Input Responsiveness
1. Rapidly press keybindings
2. Expected: UI toggles smoothly, no stuttering
3. No duplicate UI instances

## Success Criteria

✅ All three UIs can be opened and closed with their respective keys
✅ ESC key closes any open UI
✅ Only one UI panel is visible at a time
✅ Quest Journal displays active and completed quests correctly
✅ Research Tree shows all 4 branches and 32 nodes
✅ Market allows buying seeds and selling goods
✅ All UIs respect game pause state
✅ HUD shows keybinding hints at bottom
✅ UIs follow the art direction color palette
✅ No console errors or warnings

## Next Steps

After testing, verify:
1. Screenshots of all three UIs are taken
2. Any issues are documented
3. Code review is performed
4. Security scan is run
5. Integration with save/load system is tested
