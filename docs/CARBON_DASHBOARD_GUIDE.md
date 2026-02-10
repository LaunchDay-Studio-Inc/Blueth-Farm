# Carbon Dashboard - Usage Guide

## Overview
The Carbon Dashboard provides comprehensive real-time carbon sequestration tracking, historical trends, and environmental impact visualization for Blueth Farm.

## Opening the Dashboard
- **Keyboard**: Press **Tab** key to toggle the dashboard
- **Input Action**: `toggle_carbon_dashboard` (configured in project.godot)

## Dashboard Features

### 1. Total CO₂ Sequestered
- Large animated counter showing lifetime total carbon sequestration
- Smoothly animates when values change using Tween
- Displayed in tonnes

### 2. Daily Rate
- Current daily carbon sequestration rate
- Trend indicator:
  - **↑ Green** - Rate is increasing
  - **↓ Red** - Rate is decreasing  
  - **→ White** - Rate is stable
- Displayed in tonnes/day

### 3. Carbon Storage Breakdown
Two progress bars showing the distribution:
- **🌱 Biomass** (Green): Volatile carbon stored in living plants
- **🪨 Sediment** (Brown): Permanent carbon stored in sediment
- Shows both absolute values and percentages

### 4. Historical Graph
- Line graph showing daily carbon sequestration over the last 28 days
- Automatically updates as new data arrives
- Uses custom drawing with Line2D
- Includes grid lines for readability

### 5. Real-World Equivalencies
Helps contextualize carbon impact:
- **🚗 Cars**: Equivalent cars taken off the road for a year
- **✈️ Flights**: Transatlantic flights offset
- **🌳 Trees**: Trees grown for 10 years

Based on real science:
- 4.6 tonnes CO₂ per car/year
- 0.9 tonnes CO₂ per flight
- 0.021 tonnes CO₂ per tree/year

### 6. Carbon Credits
- **Available Credits**: Total verified carbon credits
- **Price**: Current market price (gold per credit)
- **Sell All Credits** button: Convert all credits to gold instantly
- Button disabled when no credits available

### 7. Ecosystem Health
- Visual health bar (0-100%)
- Dynamic color coding:
  - **Green** (70%+): Excellent health
  - **Yellow** (40-69%): Moderate health
  - **Red** (<40%): Poor health
- Affects carbon credit verification

## Integration Points

### CarbonManager
The dashboard reads from:
- `total_co2_sequestered` - Total lifetime CO₂
- `daily_sequestration_rate` - Current daily rate
- `total_biomass_carbon` - Living plant carbon
- `total_sediment_carbon` - Permanent sediment carbon
- `total_carbon_credits` - Available credits
- `credit_price` - Current market price
- `carbon_history` - Array of daily data
- `carbon_updated` signal - Live updates

Methods used:
- `get_carbon_breakdown()` - Biomass/sediment percentages
- `get_equivalencies()` - Cars, flights, trees
- `get_history_data(28)` - Last 28 days of data
- `sell_carbon_credits(amount)` - Sell credits for gold

### EcosystemManager
- `ecosystem_health` - Overall ecosystem health (0-100)
- Affects carbon credit verification
- Displayed as color-coded health bar

### GameManager
- `add_gold(amount)` - Called when selling carbon credits

## UI Behavior

### Mutual Exclusion
Opening the Carbon Dashboard automatically closes:
- Inventory UI
- Market UI
- Pause Menu

### Animations
- Total carbon counter smoothly counts up/down over 0.8 seconds
- Uses cubic ease-out for natural feel

### Styling
Follows Art Direction color palette:
- **Background**: Deep Navy (#1A3A52)
- **Borders**: Weathered Wood (#8B7355)
- **Panels**: Ocean Blue (#2A5A72)
- **Biomass**: Seagrass Green (#6B9D6E)
- **Sediment**: Mudflat Brown (#8B6F47)
- **Graph Line**: Turquoise (#6CC4A1)

## Technical Notes

### Performance
- Graph redraws only when visible
- Uses PackedVector2Array for efficient line drawing
- Tween animation automatically cleaned up

### Data Flow
1. CarbonManager updates daily carbon values
2. Emits `carbon_updated` signal
3. Dashboard receives signal (if visible)
4. Refreshes all displays
5. Graph canvas queues redraw
6. Custom `_draw_graph()` renders line chart

### Save/Load
- Dashboard state not saved (UI only)
- All data comes from CarbonManager (which is saved)
- Graph history preserved in CarbonManager.carbon_history

## Future Enhancements
Potential additions:
- Click on graph to see specific day details
- Export carbon report as PDF/image
- Carbon offset calculator
- Comparison with regional averages
- Achievement badges for carbon milestones
- Shareable carbon impact cards
