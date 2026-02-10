extends CanvasLayer
## Inventory UI Controller
##
## Manages the visual display and interaction with the player's inventory.
## Handles grid display, category filtering, item tooltips, and item management.

## Art Direction color palette
const BG_COLOR := Color("#1A3A52", 0.9)
const BORDER_COLOR := Color("#8B7355")
const TEXT_COLOR := Color("#F5F0E1")
const SLOT_EMPTY_COLOR := Color(0.2, 0.2, 0.2, 0.5)
const SLOT_HOVER_COLOR := Color(0.3, 0.5, 0.7, 0.8)
const QUICKSLOT_HIGHLIGHT_COLOR := Color("#FFD700", 0.8)

## Item category colors
const CATEGORY_COLORS := {
	"seeds": Color("#7CB342"),
	"harvest": Color("#FF9800"),
	"tools": Color("#607D8B"),
	"special": Color("#9C27B0"),
	"default": Color("#90A4AE")
}

## Item categories for filtering
enum Category {
	ALL,
	SEEDS,
	HARVEST,
	TOOLS,
	SPECIAL
}

## UI References
@onready var grid_container := $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var quickslot_container := $PanelContainer/MarginContainer/VBoxContainer/QuickslotContainer
@onready var tooltip_panel := $TooltipPanel
@onready var tooltip_name := $TooltipPanel/TooltipMargin/TooltipVBox/ItemNameLabel
@onready var tooltip_desc := $TooltipPanel/TooltipMargin/TooltipVBox/ItemDescLabel
@onready var tooltip_quantity := $TooltipPanel/TooltipMargin/TooltipVBox/ItemQuantityLabel
@onready var close_button := $PanelContainer/MarginContainer/VBoxContainer/HeaderContainer/CloseButton
@onready var panel_container := $PanelContainer
@onready var overlay := $Overlay

## Category filter buttons
@onready var all_button := $PanelContainer/MarginContainer/VBoxContainer/CategoryContainer/AllButton
@onready var seeds_button := $PanelContainer/MarginContainer/VBoxContainer/CategoryContainer/SeedsButton
@onready var harvest_button := $PanelContainer/MarginContainer/VBoxContainer/CategoryContainer/HarvestButton
@onready var tools_button := $PanelContainer/MarginContainer/VBoxContainer/CategoryContainer/ToolsButton
@onready var special_button := $PanelContainer/MarginContainer/VBoxContainer/CategoryContainer/SpecialButton

## State
var _current_category: Category = Category.ALL
var _selected_slot_index: int = -1
var _inventory_slots: Array = []
var _quickslot_slots: Array = []
var _player_inventory: Node = null
var _player_tools: Node = null


func _ready() -> void:
	# Hide initially
	hide()
	
	# Wait for scene tree to be ready
	await get_tree().process_frame
	
	# Get player inventory reference from player node
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_node_or_null("/root/GameWorld/Player")
	
	if player:
		_player_inventory = player.get_node_or_null("PlayerInventory")
		_player_tools = player.get_node_or_null("PlayerTools")
	
	# Connect signals
	close_button.pressed.connect(_on_close_pressed)
	all_button.pressed.connect(func(): _set_category(Category.ALL))
	seeds_button.pressed.connect(func(): _set_category(Category.SEEDS))
	harvest_button.pressed.connect(func(): _set_category(Category.HARVEST))
	tools_button.pressed.connect(func(): _set_category(Category.TOOLS))
	special_button.pressed.connect(func(): _set_category(Category.SPECIAL))
	
	# Connect to player inventory changes
	if _player_inventory:
		_player_inventory.inventory_changed.connect(_on_inventory_changed)
	
	# Apply art direction styling
	_apply_styling()
	
	# Initialize UI
	_create_inventory_slots()
	_create_quickslot_slots()
	_refresh_display()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		toggle_inventory()


func _process(_delta: float) -> void:
	# Update tooltip position to follow mouse
	if tooltip_panel.visible:
		var mouse_pos := get_viewport().get_mouse_position()
		tooltip_panel.position = mouse_pos + Vector2(15, 15)


## Toggles the inventory visibility
func toggle_inventory() -> void:
	if visible:
		hide_inventory()
	else:
		show_inventory()


## Shows the inventory
func show_inventory() -> void:
	visible = true
	_close_other_uis()
	_refresh_display()


## Hides the inventory
func hide_inventory() -> void:
	visible = false
	tooltip_panel.hide()


## Closes other UI panels for mutual exclusion
func _close_other_uis() -> void:
	# Close pause menu if open
	var pause_menu = get_node_or_null("/root/GameWorld/PauseMenu")
	if pause_menu and pause_menu.visible:
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
	
	if panel_container:
		panel_container.add_theme_stylebox_override("panel", panel_style)
	
	# Style tooltip
	var tooltip_style := StyleBoxFlat.new()
	tooltip_style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	tooltip_style.border_color = BORDER_COLOR
	tooltip_style.border_width_left = 2
	tooltip_style.border_width_right = 2
	tooltip_style.border_width_top = 2
	tooltip_style.border_width_bottom = 2
	tooltip_style.corner_radius_top_left = 4
	tooltip_style.corner_radius_top_right = 4
	tooltip_style.corner_radius_bottom_left = 4
	tooltip_style.corner_radius_bottom_right = 4
	
	if tooltip_panel:
		tooltip_panel.add_theme_stylebox_override("panel", tooltip_style)
	
	# Set text colors
	if tooltip_name:
		tooltip_name.add_theme_color_override("font_color", TEXT_COLOR)
	if tooltip_desc:
		tooltip_desc.add_theme_color_override("font_color", TEXT_COLOR)
	if tooltip_quantity:
		tooltip_quantity.add_theme_color_override("font_color", TEXT_COLOR)


## Creates the inventory slot UI elements
func _create_inventory_slots() -> void:
	if not grid_container or not _player_inventory:
		return
	
	# Clear existing slots
	for child in grid_container.get_children():
		child.queue_free()
	_inventory_slots.clear()
	
	# Create 40 slots (10x4 grid)
	for i in range(40):
		var slot := _create_slot_ui(i, false)
		grid_container.add_child(slot)
		_inventory_slots.append(slot)


## Creates the quickslot UI elements
func _create_quickslot_slots() -> void:
	if not quickslot_container:
		return
	
	# Clear existing slots
	for child in quickslot_container.get_children():
		child.queue_free()
	_quickslot_slots.clear()
	
	# Create 5 quickslots
	for i in range(5):
		var slot := _create_slot_ui(i, true)
		quickslot_container.add_child(slot)
		_quickslot_slots.append(slot)


## Creates a single slot UI element
func _create_slot_ui(index: int, is_quickslot: bool) -> PanelContainer:
	var slot_panel := PanelContainer.new()
	slot_panel.custom_minimum_size = Vector2(60, 60)
	
	# Create slot style
	var slot_style := StyleBoxFlat.new()
	slot_style.bg_color = SLOT_EMPTY_COLOR
	slot_style.border_color = BORDER_COLOR
	slot_style.border_width_left = 2
	slot_style.border_width_right = 2
	slot_style.border_width_top = 2
	slot_style.border_width_bottom = 2
	slot_style.corner_radius_top_left = 4
	slot_style.corner_radius_top_right = 4
	slot_style.corner_radius_bottom_left = 4
	slot_style.corner_radius_bottom_right = 4
	slot_panel.add_theme_stylebox_override("panel", slot_style)
	
	# Container for item display
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	slot_panel.add_child(vbox)
	
	# Color rect for item color
	var color_rect := ColorRect.new()
	color_rect.custom_minimum_size = Vector2(0, 40)
	color_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	color_rect.color = Color.TRANSPARENT
	color_rect.name = "ColorRect"
	vbox.add_child(color_rect)
	
	# Label for quantity
	var quantity_label := Label.new()
	quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	quantity_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	quantity_label.add_theme_color_override("font_color", TEXT_COLOR)
	quantity_label.add_theme_font_size_override("font_size", 12)
	quantity_label.name = "QuantityLabel"
	vbox.add_child(quantity_label)
	
	# Store metadata
	slot_panel.set_meta("slot_index", index)
	slot_panel.set_meta("is_quickslot", is_quickslot)
	
	# Connect mouse events
	slot_panel.mouse_entered.connect(_on_slot_mouse_entered.bind(slot_panel))
	slot_panel.mouse_exited.connect(_on_slot_mouse_exited.bind(slot_panel))
	slot_panel.gui_input.connect(_on_slot_gui_input.bind(slot_panel))
	
	return slot_panel


## Updates the display of all inventory slots
func _refresh_display() -> void:
	if not _player_inventory:
		return
	
	# Update main inventory slots
	var inventory := _player_inventory.get_inventory()
	for i in range(min(_inventory_slots.size(), inventory.size())):
		var slot_ui = _inventory_slots[i]
		var slot_data = inventory[i]
		_update_slot_display(slot_ui, slot_data)
	
	# Update quickslots
	var quickslots := _player_inventory.get_quickslots()
	for i in range(min(_quickslot_slots.size(), quickslots.size())):
		var slot_ui = _quickslot_slots[i]
		var slot_data = quickslots[i]
		_update_slot_display(slot_ui, slot_data)
		
		# Highlight equipped tool
		_update_quickslot_highlight(i, slot_ui)
	
	# Apply category filter
	_apply_category_filter()


## Updates a single slot's visual display
func _update_slot_display(slot_ui: PanelContainer, slot_data) -> void:
	if not slot_ui or not slot_data:
		return
	
	var color_rect = slot_ui.get_node_or_null("VBoxContainer/ColorRect")
	var quantity_label = slot_ui.get_node_or_null("VBoxContainer/QuantityLabel")
	
	if slot_data.is_empty():
		# Empty slot
		if color_rect:
			color_rect.color = Color.TRANSPARENT
		if quantity_label:
			quantity_label.text = ""
	else:
		# Filled slot
		var item_category := _get_item_category(slot_data.item_type)
		var item_color := CATEGORY_COLORS.get(item_category, CATEGORY_COLORS["default"])
		
		if color_rect:
			color_rect.color = item_color
		if quantity_label:
			quantity_label.text = str(slot_data.quantity)


## Updates quickslot highlight based on equipped tool
func _update_quickslot_highlight(slot_index: int, slot_ui: PanelContainer) -> void:
	if not _player_tools or not slot_ui:
		return
	
	var current_tool := _player_tools.current_tool
	var slot_tool := _player_tools.get_tool_slot(slot_index)
	
	var slot_style := slot_ui.get_theme_stylebox("panel") as StyleBoxFlat
	if slot_style:
		var cloned_style := slot_style.duplicate() as StyleBoxFlat
		if current_tool == slot_tool and current_tool != -1:
			# Highlight equipped tool
			cloned_style.border_color = QUICKSLOT_HIGHLIGHT_COLOR
			cloned_style.border_width_left = 4
			cloned_style.border_width_right = 4
			cloned_style.border_width_top = 4
			cloned_style.border_width_bottom = 4
		else:
			# Normal border
			cloned_style.border_color = BORDER_COLOR
			cloned_style.border_width_left = 2
			cloned_style.border_width_right = 2
			cloned_style.border_width_top = 2
			cloned_style.border_width_bottom = 2
		slot_ui.add_theme_stylebox_override("panel", cloned_style)


## Gets the category of an item based on its type
func _get_item_category(item_type: String) -> String:
	var lower_type := item_type.to_lower()
	
	if "seed" in lower_type or "bulb" in lower_type:
		return "seeds"
	elif "harvest" in lower_type or "crop" in lower_type or "kelp" in lower_type or "seagrass" in lower_type:
		return "harvest"
	elif "tool" in lower_type or "spade" in lower_type or "net" in lower_type or "tester" in lower_type:
		return "tools"
	else:
		return "default"


## Sets the active category filter
func _set_category(category: Category) -> void:
	_current_category = category
	_apply_category_filter()
	_update_category_buttons()


## Applies the current category filter
func _apply_category_filter() -> void:
	if not _player_inventory:
		return
	
	var inventory := _player_inventory.get_inventory()
	
	for i in range(_inventory_slots.size()):
		var slot_ui = _inventory_slots[i]
		var slot_data = inventory[i] if i < inventory.size() else null
		
		if _current_category == Category.ALL:
			slot_ui.visible = true
		elif slot_data and not slot_data.is_empty():
			var item_category := _get_item_category(slot_data.item_type)
			var matches := false
			
			match _current_category:
				Category.SEEDS:
					matches = item_category == "seeds"
				Category.HARVEST:
					matches = item_category == "harvest"
				Category.TOOLS:
					matches = item_category == "tools"
				Category.SPECIAL:
					matches = item_category == "special"
			
			slot_ui.visible = matches
		else:
			slot_ui.visible = false


## Updates category button appearance
func _update_category_buttons() -> void:
	var buttons := [all_button, seeds_button, harvest_button, tools_button, special_button]
	var active_index := int(_current_category)
	
	for i in range(buttons.size()):
		if i == active_index:
			buttons[i].disabled = true
		else:
			buttons[i].disabled = false


## Shows tooltip for a slot
func _show_tooltip(slot_ui: PanelContainer) -> void:
	if not slot_ui:
		return
	
	var is_quickslot := slot_ui.get_meta("is_quickslot", false)
	var slot_index := slot_ui.get_meta("slot_index", -1)
	
	var slot_data
	if is_quickslot:
		slot_data = _player_inventory.get_quickslot(slot_index)
	else:
		slot_data = _player_inventory.get_slot(slot_index)
	
	if not slot_data or slot_data.is_empty():
		tooltip_panel.hide()
		return
	
	# Update tooltip content
	tooltip_name.text = _get_item_display_name(slot_data.item_type)
	tooltip_desc.text = _get_item_description(slot_data.item_type)
	tooltip_quantity.text = "Quantity: %d / %d" % [slot_data.quantity, slot_data.max_stack]
	
	# Show tooltip
	tooltip_panel.show()


## Hides tooltip
func _hide_tooltip() -> void:
	tooltip_panel.hide()


## Gets display name for an item
func _get_item_display_name(item_type: String) -> String:
	# Convert "item_type" to "Item Type"
	return item_type.capitalize()


## Gets description for an item
func _get_item_description(item_type: String) -> String:
	# TODO: Implement item database with descriptions
	var category := _get_item_category(item_type)
	match category:
		"seeds":
			return "Plant this to grow crops"
		"harvest":
			return "Harvested crop"
		"tools":
			return "A useful tool"
		_:
			return "An item"


## Handles mouse entering a slot
func _on_slot_mouse_entered(slot_ui: PanelContainer) -> void:
	# Show hover effect
	var slot_style := slot_ui.get_theme_stylebox("panel") as StyleBoxFlat
	if slot_style:
		var cloned_style := slot_style.duplicate() as StyleBoxFlat
		cloned_style.bg_color = SLOT_HOVER_COLOR
		slot_ui.add_theme_stylebox_override("panel", cloned_style)
	
	# Show tooltip
	_show_tooltip(slot_ui)


## Handles mouse exiting a slot
func _on_slot_mouse_exited(slot_ui: PanelContainer) -> void:
	# Remove hover effect
	var slot_style := slot_ui.get_theme_stylebox("panel") as StyleBoxFlat
	if slot_style:
		var cloned_style := slot_style.duplicate() as StyleBoxFlat
		cloned_style.bg_color = SLOT_EMPTY_COLOR
		slot_ui.add_theme_stylebox_override("panel", cloned_style)
	
	# Hide tooltip
	_hide_tooltip()


## Handles GUI input on a slot
func _on_slot_gui_input(event: InputEvent, slot_ui: PanelContainer) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_slot_clicked(slot_ui)


## Handles clicking on a slot
func _on_slot_clicked(slot_ui: PanelContainer) -> void:
	var is_quickslot := slot_ui.get_meta("is_quickslot", false)
	var slot_index := slot_ui.get_meta("slot_index", -1)
	
	if _selected_slot_index == -1:
		# Select this slot
		_selected_slot_index = slot_index
		print("Selected slot: ", slot_index)
	else:
		# Swap with previously selected slot
		if not is_quickslot and _player_inventory:
			_player_inventory.swap_slots(_selected_slot_index, slot_index)
			_selected_slot_index = -1
			_refresh_display()


## Handles close button press
func _on_close_pressed() -> void:
	hide_inventory()


## Handles inventory changed signal
func _on_inventory_changed() -> void:
	_refresh_display()
