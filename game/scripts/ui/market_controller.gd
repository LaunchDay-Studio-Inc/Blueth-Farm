extends CanvasLayer
## Market UI Controller
##
## Manages the visual display and interaction with the Town Market.
## Handles buying seeds, selling goods, and trading carbon credits.

## Art Direction color palette (matching inventory)
const BG_COLOR := Color("#1A3A52", 0.9)
const BORDER_COLOR := Color("#8B7355")
const TEXT_COLOR := Color("#F5F0E1")
const BUTTON_NORMAL_COLOR := Color("#2A5A72", 0.9)
const BUTTON_HOVER_COLOR := Color("#3A7A92", 0.9)
const BUTTON_PRESSED_COLOR := Color("#1A4A62", 0.9)
const BUY_BUTTON_COLOR := Color("#7CB342", 0.9)
const SELL_BUTTON_COLOR := Color("#FF9800", 0.9)

## UI References
@onready var panel_container := $CenterContainer/PanelContainer
@onready var close_button := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HeaderContainer/CloseButton
@onready var market_hours_label := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/InfoContainer/MarketHoursLabel
@onready var gold_label := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/InfoContainer/GoldLabel
@onready var tab_container := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TabContainer
@onready var buy_items_container := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TabContainer/"Buy Seeds"/ScrollContainer/BuyItemsContainer
@onready var sell_items_container := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TabContainer/"Sell Goods"/ScrollContainer/SellItemsContainer
@onready var credits_label := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CarbonSection/CarbonInfoContainer/CreditsLabel
@onready var price_label := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CarbonSection/CarbonInfoContainer/PriceLabel
@onready var sell_carbon_button := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CarbonSection/CarbonInfoContainer/SellCarbonButton
@onready var market_closed_overlay := $CenterContainer/MarketClosedOverlay
@onready var overlay := $Overlay

## State
var _market_system: MarketSystem = null
var _player_inventory: Node = null
var _buy_quantity_spinners: Dictionary = {}

## Item display names
const ITEM_DISPLAY_NAMES := {
	"eelgrass_seed": "Eelgrass Seeds",
	"cordgrass_seed": "Cordgrass Seeds",
	"red_mangrove_seed": "Red Mangrove Seeds",
	"giant_kelp_seed": "Giant Kelp Seeds",
	"posidonia_seed": "Posidonia Seeds",
	"thalassia_seed": "Thalassia Seeds",
	"salicornia_seed": "Salicornia Seeds",
	"black_mangrove_seed": "Black Mangrove Seeds",
	"laminaria_seed": "Laminaria Seeds",
	"oyster": "Oysters",
	"fish": "Fish",
	"seaweed": "Seaweed",
	"crab": "Crabs",
	"kelp": "Kelp",
	"glasswort": "Glasswort",
	"rare_ingredient": "Rare Ingredients"
}


func _ready() -> void:
	# Hide initially
	hide()
	
	# Wait for scene tree to be ready
	await get_tree().process_frame
	
	# Get MarketSystem reference from autoload
	_market_system = MarketSystem
	
	# Get player inventory reference
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_node_or_null("/root/GameWorld/Player")
	
	if player:
		_player_inventory = player.get_node_or_null("PlayerInventory")
	
	# Connect signals
	close_button.pressed.connect(_on_close_pressed)
	sell_carbon_button.pressed.connect(_on_sell_carbon_pressed)
	
	# Connect to gold changes
	if GameManager:
		GameManager.game_state_changed.connect(_on_game_state_changed)
	
	# Connect to market system signals
	if _market_system:
		_market_system.item_purchased.connect(_on_item_purchased)
		_market_system.item_sold.connect(_on_item_sold)
		_market_system.market_opened.connect(_on_market_opened)
		_market_system.market_closed.connect(_on_market_closed)
	
	# Connect to player inventory changes
	if _player_inventory:
		_player_inventory.inventory_changed.connect(_on_inventory_changed)
	
	# Apply art direction styling
	_apply_styling()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_market"):
		toggle_market()
	elif event.is_action_pressed("ui_cancel") and visible:
		hide_market()


func _process(_delta: float) -> void:
	# Update gold display continuously
	if visible:
		_update_gold_display()


## Toggles the market visibility
func toggle_market() -> void:
	if visible:
		hide_market()
	else:
		show_market()


## Shows the market
func show_market() -> void:
	# Check if market is open
	if _market_system and not _market_system.is_market_open:
		# Show market closed overlay
		visible = true
		market_closed_overlay.visible = true
		_close_other_uis()
		_refresh_display()  # Refresh even when closed to show current state
		return
	
	visible = true
	market_closed_overlay.visible = false
	_close_other_uis()
	_refresh_display()


## Hides the market
func hide_market() -> void:
	visible = false


## Closes other UI panels for mutual exclusion
func _close_other_uis() -> void:
	# Close inventory if open
	var inventory = get_node_or_null("/root/GameWorld/InventoryUI")
	if inventory and inventory.visible:
		if inventory.has_method("hide_inventory"):
			inventory.hide_inventory()
	
	# Close pause menu if open
	var pause_menu = get_node_or_null("/root/GameWorld/PauseMenu")
	if pause_menu and pause_menu.visible:
		if pause_menu.has_method("hide_pause_menu"):
			pause_menu.hide_pause_menu()


## Applies art direction styling to UI elements
func _apply_styling() -> void:
	# Style panel background
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = BG_COLOR
	panel_style.border_color = BORDER_COLOR
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_container.add_theme_stylebox_override("panel", panel_style)
	
	# Style overlay
	overlay.color = Color(0, 0, 0, 0.4)
	
	# Style close button
	_style_button(close_button, Color("#D32F2F", 0.9))
	
	# Style sell carbon button
	_style_button(sell_carbon_button, SELL_BUTTON_COLOR)


## Styles a button with the given color
func _style_button(button: Button, base_color: Color) -> void:
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = base_color
	normal_style.corner_radius_top_left = 4
	normal_style.corner_radius_top_right = 4
	normal_style.corner_radius_bottom_left = 4
	normal_style.corner_radius_bottom_right = 4
	button.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = base_color.lightened(0.2)
	hover_style.corner_radius_top_left = 4
	hover_style.corner_radius_top_right = 4
	hover_style.corner_radius_bottom_left = 4
	hover_style.corner_radius_bottom_right = 4
	button.add_theme_stylebox_override("hover", hover_style)
	
	var pressed_style := StyleBoxFlat.new()
	pressed_style.bg_color = base_color.darkened(0.2)
	pressed_style.corner_radius_top_left = 4
	pressed_style.corner_radius_top_right = 4
	pressed_style.corner_radius_bottom_left = 4
	pressed_style.corner_radius_bottom_right = 4
	button.add_theme_stylebox_override("pressed", pressed_style)


## Refreshes the entire market display
func _refresh_display() -> void:
	_update_gold_display()
	_update_market_hours_display()
	_update_buy_items()
	_update_sell_items()
	_update_carbon_section()


## Updates the gold display
func _update_gold_display() -> void:
	if GameManager:
		gold_label.text = "💰 Gold: %d" % GameManager.gold


## Updates the market hours display
func _update_market_hours_display() -> void:
	if _market_system:
		market_hours_label.text = _market_system.get_market_status_text()


## Updates the buy items list
func _update_buy_items() -> void:
	# Clear existing items
	for child in buy_items_container.get_children():
		child.queue_free()
	
	_buy_quantity_spinners.clear()
	
	if not _market_system:
		return
	
	# Get all seed prices
	var seed_prices = _market_system.get_all_seed_prices()
	
	for seed_id in seed_prices.keys():
		var item_row = _create_buy_item_row(seed_id, seed_prices[seed_id])
		buy_items_container.add_child(item_row)


## Creates a buy item row
func _create_buy_item_row(item_id: String, price: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	
	# Item name
	var name_label := Label.new()
	name_label.text = ITEM_DISPLAY_NAMES.get(item_id, item_id.capitalize())
	name_label.custom_minimum_size = Vector2(200, 0)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)
	
	# Base price
	var base_price = _market_system.SEED_BASE_PRICES.get(item_id, 0)
	var base_price_label := Label.new()
	base_price_label.text = "Base: %d" % base_price
	base_price_label.custom_minimum_size = Vector2(80, 0)
	row.add_child(base_price_label)
	
	# Current price (with seasonal modifier)
	var price_label := Label.new()
	price_label.text = "Price: %d 💰" % price
	price_label.custom_minimum_size = Vector2(100, 0)
	row.add_child(price_label)
	
	# Quantity controls
	var quantity_container := HBoxContainer.new()
	quantity_container.add_theme_constant_override("separation", 5)
	
	var minus_button := Button.new()
	minus_button.text = "-"
	minus_button.custom_minimum_size = Vector2(30, 30)
	_style_button(minus_button, BUTTON_NORMAL_COLOR)
	quantity_container.add_child(minus_button)
	
	var quantity_label := Label.new()
	quantity_label.text = "1"
	quantity_label.custom_minimum_size = Vector2(30, 0)
	quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quantity_container.add_child(quantity_label)
	
	var plus_button := Button.new()
	plus_button.text = "+"
	plus_button.custom_minimum_size = Vector2(30, 30)
	_style_button(plus_button, BUTTON_NORMAL_COLOR)
	quantity_container.add_child(plus_button)
	
	row.add_child(quantity_container)
	
	# Store quantity label for later reference
	_buy_quantity_spinners[item_id] = quantity_label
	
	# Connect quantity buttons
	minus_button.pressed.connect(func(): _change_buy_quantity(item_id, -1))
	plus_button.pressed.connect(func(): _change_buy_quantity(item_id, 1))
	
	# Buy button
	var buy_button := Button.new()
	buy_button.text = "Buy"
	buy_button.custom_minimum_size = Vector2(80, 35)
	_style_button(buy_button, BUY_BUTTON_COLOR)
	buy_button.pressed.connect(func(): _on_buy_item_pressed(item_id))
	row.add_child(buy_button)
	
	return row


## Changes the buy quantity for an item
func _change_buy_quantity(item_id: String, delta: int) -> void:
	if item_id not in _buy_quantity_spinners:
		return
	
	var label = _buy_quantity_spinners[item_id]
	var current = int(label.text)
	var new_value = max(1, current + delta)
	label.text = str(new_value)


## Updates the sell items list
func _update_sell_items() -> void:
	# Clear existing items
	for child in sell_items_container.get_children():
		child.queue_free()
	
	if not _market_system or not _player_inventory:
		return
	
	# Get all harvest prices
	var harvest_prices = _market_system.get_all_harvest_prices()
	
	for item_id in harvest_prices.keys():
		var quantity = _player_inventory.get_item_count(item_id)
		if quantity > 0:
			var item_row = _create_sell_item_row(item_id, harvest_prices[item_id], quantity)
			sell_items_container.add_child(item_row)
	
	# Add message if no items to sell
	if sell_items_container.get_child_count() == 0:
		var empty_label := Label.new()
		empty_label.text = "No items to sell. Harvest some goods first!"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sell_items_container.add_child(empty_label)


## Creates a sell item row
func _create_sell_item_row(item_id: String, price: int, quantity: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	
	# Item name
	var name_label := Label.new()
	name_label.text = ITEM_DISPLAY_NAMES.get(item_id, item_id.capitalize())
	name_label.custom_minimum_size = Vector2(200, 0)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)
	
	# Quantity owned
	var quantity_label := Label.new()
	quantity_label.text = "Owned: %d" % quantity
	quantity_label.custom_minimum_size = Vector2(100, 0)
	row.add_child(quantity_label)
	
	# Sell price
	var price_label := Label.new()
	price_label.text = "%d 💰 each" % price
	price_label.custom_minimum_size = Vector2(100, 0)
	row.add_child(price_label)
	
	# Sell One button
	var sell_one_button := Button.new()
	sell_one_button.text = "Sell 1"
	sell_one_button.custom_minimum_size = Vector2(80, 35)
	_style_button(sell_one_button, SELL_BUTTON_COLOR)
	sell_one_button.pressed.connect(func(): _on_sell_item_pressed(item_id, 1))
	row.add_child(sell_one_button)
	
	# Sell All button
	var sell_all_button := Button.new()
	sell_all_button.text = "Sell All"
	sell_all_button.custom_minimum_size = Vector2(80, 35)
	_style_button(sell_all_button, SELL_BUTTON_COLOR)
	sell_all_button.pressed.connect(func(): _on_sell_item_pressed(item_id, quantity))
	row.add_child(sell_all_button)
	
	return row


## Updates the carbon credits section
func _update_carbon_section() -> void:
	if not CarbonManager:
		return
	
	var credits = CarbonManager.total_carbon_credits
	var price = CarbonManager.credit_price
	
	credits_label.text = "Available Credits: %.2f" % credits
	price_label.text = "Price: %d gold/credit" % price
	
	# Enable/disable sell button based on credits
	sell_carbon_button.disabled = credits <= 0


## Handles buy item button press
func _on_buy_item_pressed(item_id: String) -> void:
	if not _market_system:
		return
	
	# Get quantity from spinner
	var quantity = 1
	if item_id in _buy_quantity_spinners:
		quantity = int(_buy_quantity_spinners[item_id].text)
	
	# Attempt to buy
	if _market_system.buy_item(item_id, quantity):
		# Success - refresh display
		_refresh_display()
		# Play success sound
		if AudioManager and AudioManager.has_method("play_sfx"):
			AudioManager.play_sfx("purchase")
	else:
		# Failed - show error
		if AudioManager and AudioManager.has_method("play_sfx"):
			AudioManager.play_sfx("error")
		# Could show a notification here
		print("Failed to buy %s x%d - not enough gold or market closed" % [item_id, quantity])


## Handles sell item button press
func _on_sell_item_pressed(item_id: String, quantity: int) -> void:
	if not _market_system:
		return
	
	# Attempt to sell
	if _market_system.sell_item(item_id, quantity):
		# Success - refresh display
		_refresh_display()
		# Play success sound
		if AudioManager and AudioManager.has_method("play_sfx"):
			AudioManager.play_sfx("sell")
	else:
		# Failed - show error
		if AudioManager and AudioManager.has_method("play_sfx"):
			AudioManager.play_sfx("error")
		print("Failed to sell %s x%d" % [item_id, quantity])


## Handles sell carbon credits button press
func _on_sell_carbon_pressed() -> void:
	if not CarbonManager:
		return
	
	var credits = CarbonManager.total_carbon_credits
	if credits <= 0:
		return
	
	var price = CarbonManager.credit_price
	var total_gold = int(credits * price)
	
	# Add gold to player
	if GameManager:
		GameManager.add_gold(total_gold)
	
	# Remove credits from carbon manager
	CarbonManager.total_carbon_credits = 0
	
	# Refresh display
	_refresh_display()
	
	# Play success sound
	if AudioManager and AudioManager.has_method("play_sfx"):
		AudioManager.play_sfx("sell")
	
	print("Sold %.2f carbon credits for %d gold" % [credits, total_gold])


## Handles close button press
func _on_close_pressed() -> void:
	hide_market()


## Handles item purchased signal
func _on_item_purchased(_item_id: String, _quantity: int, _price: int) -> void:
	_refresh_display()


## Handles item sold signal
func _on_item_sold(_item_id: String, _quantity: int, _price: int) -> void:
	_refresh_display()


## Handles market opened signal
func _on_market_opened() -> void:
	if visible:
		market_closed_overlay.visible = false
		_refresh_display()


## Handles market closed signal
func _on_market_closed() -> void:
	if visible:
		market_closed_overlay.visible = true


## Handles inventory changed signal
func _on_inventory_changed() -> void:
	if visible:
		_update_sell_items()


## Handles game state changed signal
func _on_game_state_changed(_new_state: int) -> void:
	_update_gold_display()
