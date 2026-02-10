extends CanvasLayer
## Nursery UI Controller
##
## Manages the nursery system UI where players can plant seedlings and monitor growth.
## Connects to NurserySystem for slot management and growth tracking.

## Art Direction color palette
const BG_COLOR := Color("#1A3A52", 0.9)
const BORDER_COLOR := Color("#8B7355")
const TEXT_COLOR := Color("#F5F0E1")
const HEADER_COLOR := Color("#2E5E8C")
const SLOT_EMPTY_COLOR := Color(0.2, 0.2, 0.2, 0.5)
const SLOT_FILLED_COLOR := Color("#4A7C59", 0.8)
const GROWTH_BAR_BG_COLOR := Color(0.2, 0.2, 0.2, 0.8)
const GROWTH_BAR_FILL_COLOR := Color("#6B9D6E")

## UI References
@onready var overlay := $Overlay
@onready var main_panel := $MainPanel
@onready var close_button := $MainPanel/MarginContainer/VBoxContainer/Header/CloseButton
@onready var slots_container := $MainPanel/MarginContainer/VBoxContainer/Content/SlotsGrid
@onready var plant_button := $MainPanel/MarginContainer/VBoxContainer/ButtonsContainer/PlantButton
@onready var transplant_button := $MainPanel/MarginContainer/VBoxContainer/ButtonsContainer/TransplantButton
@onready var upgrade_button := $MainPanel/MarginContainer/VBoxContainer/ButtonsContainer/UpgradeButton
@onready var info_label := $MainPanel/MarginContainer/VBoxContainer/InfoContainer/InfoLabel

## State
var _nursery_system: Node = null
var _player_inventory: Node = null
var _slot_panels: Array = []
var _selected_slot_index: int = -1


func _ready() -> void:
	# Set process mode for pause handling
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Hide initially
	hide()
	
	# Wait for scene tree
	await get_tree().process_frame
	
	# Get NurserySystem reference
	_nursery_system = get_node_or_null("/root/GameWorld/NurserySystem")
	if not _nursery_system:
		_nursery_system = get_tree().get_first_node_in_group("nursery_system")
	
	# Get player inventory
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_node_or_null("/root/GameWorld/Player")
	
	if player:
		_player_inventory = player.get_node_or_null("PlayerInventory")
	
	# Connect signals
	close_button.pressed.connect(_on_close_pressed)
	plant_button.pressed.connect(_on_plant_pressed)
	transplant_button.pressed.connect(_on_transplant_pressed)
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	
	# Connect to NurserySystem signals
	if _nursery_system:
		if _nursery_system.has_signal("seedling_planted"):
			_nursery_system.seedling_planted.connect(_on_seedling_planted)
		if _nursery_system.has_signal("seedling_ready"):
			_nursery_system.seedling_ready.connect(_on_seedling_ready)
		if _nursery_system.has_signal("nursery_upgraded"):
			_nursery_system.nursery_upgraded.connect(_on_nursery_upgraded)
	
	# Apply styling
	_apply_styling()
	
	# Create slots
	_create_slots()
	
	# Initialize display
	_refresh_ui()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_nursery"):
		toggle_nursery()


## Toggle nursery visibility
func toggle_nursery() -> void:
	if visible:
		hide_nursery()
	else:
		show_nursery()


## Show the nursery
func show_nursery() -> void:
	# Check if nursery building is constructed
	if not _is_nursery_available():
		_show_unavailable_message()
		return
	
	visible = true
	
	# Notify UI State Manager
	if has_node("/root/UIStateManager"):
		get_node("/root/UIStateManager").open_panel("nursery")
	
	_refresh_ui()


## Hide the nursery
func hide_nursery() -> void:
	visible = false
	
	# Notify UI State Manager
	if has_node("/root/UIStateManager"):
		get_node("/root/UIStateManager").close_panel()


## Check if nursery building is available
func _is_nursery_available() -> bool:
	# Check TownInvestment for nursery building
	var town_investment = get_node_or_null("/root/TownInvestment")
	if not town_investment:
		town_investment = get_tree().get_first_node_in_group("town_investment")
	
	if town_investment and town_investment.has_method("is_building_completed"):
		return town_investment.is_building_completed("nursery")
	
	# Default to true for testing if system not found
	return true


## Show message when nursery is not available
func _show_unavailable_message() -> void:
	print("Nursery building must be constructed first!")
	
	# TODO: Show notification popup
	if has_node("/root/NotificationSystem"):
		var notif_system = get_node("/root/NotificationSystem")
		if notif_system.has_method("show_notification"):
			notif_system.show_notification(
				"Build the Nursery first through Town Investments (B key)",
				0  # NotificationType.JOURNAL or similar
			)


## Apply Art Direction color styling
func _apply_styling() -> void:
	# Main panel styling
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
	
	if main_panel:
		main_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Set text colors
	if info_label:
		info_label.add_theme_color_override("font_color", TEXT_COLOR)


## Create nursery slot UI elements
func _create_slots() -> void:
	if not slots_container:
		return
	
	# Clear existing slots
	for child in slots_container.get_children():
		child.queue_free()
	_slot_panels.clear()
	
	# Get number of slots from nursery system
	var num_slots = 10
	if _nursery_system and _nursery_system.has_method("get_max_slots"):
		num_slots = _nursery_system.get_max_slots()
	
	# Create slots
	for i in range(num_slots):
		var slot_panel := _create_slot_ui(i)
		slots_container.add_child(slot_panel)
		_slot_panels.append(slot_panel)


## Create a single slot UI element
func _create_slot_ui(index: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(150, 120)
	
	# Slot styling
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
	panel.add_theme_stylebox_override("panel", slot_style)
	
	# Content container
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(vbox)
	
	# Slot number label
	var slot_label := Label.new()
	slot_label.text = "Slot " + str(index + 1)
	slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot_label.add_theme_color_override("font_color", TEXT_COLOR)
	slot_label.name = "SlotLabel"
	vbox.add_child(slot_label)
	
	# Species name label
	var species_label := Label.new()
	species_label.text = "Empty"
	species_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	species_label.add_theme_color_override("font_color", TEXT_COLOR)
	species_label.name = "SpeciesLabel"
	vbox.add_child(species_label)
	
	# Growth progress bar
	var progress_bar := ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(0, 20)
	progress_bar.value = 0
	progress_bar.max_value = 100
	progress_bar.show_percentage = false
	progress_bar.name = "ProgressBar"
	vbox.add_child(progress_bar)
	
	# Days remaining label
	var days_label := Label.new()
	days_label.text = ""
	days_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	days_label.add_theme_color_override("font_color", TEXT_COLOR)
	days_label.add_theme_font_size_override("font_size", 10)
	days_label.name = "DaysLabel"
	vbox.add_child(days_label)
	
	# Store metadata
	panel.set_meta("slot_index", index)
	
	# Connect click event
	panel.gui_input.connect(_on_slot_gui_input.bind(panel))
	
	return panel


## Refresh the entire UI display
func _refresh_ui() -> void:
	if not _nursery_system:
		return
	
	# Update all slots
	for i in range(_slot_panels.size()):
		_update_slot_display(i)
	
	# Update buttons
	_update_buttons()
	
	# Update info label
	_update_info_label()


## Update a single slot's display
func _update_slot_display(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= _slot_panels.size():
		return
	
	var panel = _slot_panels[slot_index]
	if not panel:
		return
	
	# Get slot data from nursery system
	var slot_data = null
	if _nursery_system and _nursery_system.has_method("get_slot"):
		slot_data = _nursery_system.get_slot(slot_index)
	
	# Update labels
	var species_label = panel.get_node_or_null("VBoxContainer/SpeciesLabel")
	var progress_bar = panel.get_node_or_null("VBoxContainer/ProgressBar")
	var days_label = panel.get_node_or_null("VBoxContainer/DaysLabel")
	
	if slot_data and not slot_data.get("is_empty", true):
		# Slot is occupied
		var species_name = slot_data.get("species_name", "Unknown")
		var growth_progress = slot_data.get("growth_progress", 0.0)
		var days_remaining = slot_data.get("days_remaining", 0)
		var is_ready = slot_data.get("is_ready", false)
		
		if species_label:
			species_label.text = species_name
		
		if progress_bar:
			progress_bar.value = growth_progress * 100
		
		if days_label:
			if is_ready:
				days_label.text = "Ready!"
			else:
				days_label.text = str(days_remaining) + " days"
		
		# Change slot color if ready
		var slot_style = panel.get_theme_stylebox("panel") as StyleBoxFlat
		if slot_style:
			var cloned_style = slot_style.duplicate() as StyleBoxFlat
			cloned_style.bg_color = SLOT_FILLED_COLOR if not is_ready else Color("#FFD700", 0.8)
			panel.add_theme_stylebox_override("panel", cloned_style)
	else:
		# Slot is empty
		if species_label:
			species_label.text = "Empty"
		
		if progress_bar:
			progress_bar.value = 0
		
		if days_label:
			days_label.text = ""
		
		# Reset slot color
		var slot_style = panel.get_theme_stylebox("panel") as StyleBoxFlat
		if slot_style:
			var cloned_style = slot_style.duplicate() as StyleBoxFlat
			cloned_style.bg_color = SLOT_EMPTY_COLOR
			panel.add_theme_stylebox_override("panel", cloned_style)


## Update button states
func _update_buttons() -> void:
	if not plant_button or not transplant_button:
		return
	
	# Plant button enabled if a slot is selected and empty
	var can_plant = _selected_slot_index >= 0
	if can_plant and _nursery_system and _nursery_system.has_method("get_slot"):
		var slot = _nursery_system.get_slot(_selected_slot_index)
		can_plant = slot and slot.get("is_empty", true)
	
	plant_button.disabled = not can_plant
	
	# Transplant button enabled if selected slot is ready
	var can_transplant = false
	if _selected_slot_index >= 0 and _nursery_system and _nursery_system.has_method("get_slot"):
		var slot = _nursery_system.get_slot(_selected_slot_index)
		can_transplant = slot and slot.get("is_ready", false)
	
	transplant_button.disabled = not can_transplant


## Update info label
func _update_info_label() -> void:
	if not info_label or not _nursery_system:
		return
	
	var used_slots = 0
	var max_slots = 10
	
	if _nursery_system.has_method("get_used_slots"):
		used_slots = _nursery_system.get_used_slots()
	
	if _nursery_system.has_method("get_max_slots"):
		max_slots = _nursery_system.get_max_slots()
	
	info_label.text = "Slots Used: %d / %d" % [used_slots, max_slots]


## Signal handlers

func _on_close_pressed() -> void:
	hide_nursery()


func _on_slot_gui_input(event: InputEvent, panel: PanelContainer) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var slot_index = panel.get_meta("slot_index", -1)
		_selected_slot_index = slot_index
		_update_buttons()


func _on_plant_pressed() -> void:
	if _selected_slot_index < 0:
		return
	
	# TODO: Show species selection dialog from inventory
	# For now, just print
	print("Plant button pressed for slot ", _selected_slot_index)
	
	# Example: Plant a random species
	if _nursery_system and _nursery_system.has_method("plant_seedling"):
		# Get available species from inventory
		# For demo, use a placeholder
		_nursery_system.plant_seedling(_selected_slot_index, "eelgrass")
		_refresh_ui()


func _on_transplant_pressed() -> void:
	if _selected_slot_index < 0:
		return
	
	# Transplant seedling to inventory
	if _nursery_system and _nursery_system.has_method("transplant_seedling"):
		_nursery_system.transplant_seedling(_selected_slot_index)
		_refresh_ui()


func _on_upgrade_pressed() -> void:
	# Upgrade nursery capacity
	if _nursery_system and _nursery_system.has_method("upgrade_nursery"):
		_nursery_system.upgrade_nursery()
		_create_slots()
		_refresh_ui()


func _on_seedling_planted(_slot_index: int, _species_name: String) -> void:
	_refresh_ui()


func _on_seedling_ready(_slot_index: int) -> void:
	_refresh_ui()


func _on_nursery_upgraded(_new_capacity: int) -> void:
	_create_slots()
	_refresh_ui()
