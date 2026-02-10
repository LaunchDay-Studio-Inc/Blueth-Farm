extends Resource
## Item Data Resource
##
## Defines properties and metadata for items in the game.
## Used for inventory items including seeds, harvests, tools, and materials.

class_name ItemData

## Unique identifier for the item
@export var item_id: String = ""

## Display name shown in UI
@export var display_name: String = ""

## Description shown in tooltips and details
@export_multiline var description: String = ""

## Maximum stack size for this item type
@export var max_stack: int = 99

## Item category for filtering and organization
## Common values: "seed", "harvest", "tool", "material"
@export var item_category: String = ""

## Sell price at market
@export var sell_price: int = 0

## Buy price at market
@export var buy_price: int = 0

## Color used for visual representation (placeholder until real icons exist)
@export var icon_color: Color = Color.WHITE
