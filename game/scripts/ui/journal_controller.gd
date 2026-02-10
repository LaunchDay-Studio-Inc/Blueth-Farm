extends CanvasLayer
## Journal UI Controller
##
## Manages grandmother's journal entries - the emotional heart of the game.
## Displays discovered entries, tracks read status, and handles entry unlocks.

## Art Direction color palette
const PARCHMENT_BG := Color("#F5F0E1")
const DRIFTWOOD_BORDER := Color("#8B7355")
const GOLDEN_TEXT := Color("#FFD700")
const TEXT_COLOR := Color("#2C2416")
const LOCKED_COLOR := Color("#6B5D52")
const NEW_ENTRY_GLOW := Color("#FFD700", 0.3)
const OVERLAY_COLOR := Color(0, 0, 0, 0.5)

## UI References
@onready var overlay := $Overlay
@onready var main_panel := $MainPanel
@onready var close_button := $MainPanel/MarginContainer/VBoxContainer/Header/CloseButton
@onready var entry_counter := $MainPanel/MarginContainer/VBoxContainer/Header/EntryCounter
@onready var entries_list := $MainPanel/MarginContainer/VBoxContainer/Content/LeftSide/ScrollContainer/EntriesVBox
@onready var content_title := $MainPanel/MarginContainer/VBoxContainer/Content/RightSide/ScrollContainer/ContentVBox/TitleLabel
@onready var content_date := $MainPanel/MarginContainer/VBoxContainer/Content/RightSide/ScrollContainer/ContentVBox/DateLabel
@onready var content_text := $MainPanel/MarginContainer/VBoxContainer/Content/RightSide/ScrollContainer/ContentVBox/ContentText
@onready var content_unlock := $MainPanel/MarginContainer/VBoxContainer/Content/RightSide/ScrollContainer/ContentVBox/UnlockLabel

## State
var _journal_system: Node = null
var _entry_buttons: Dictionary = {}  # entry_id -> Button
var _new_entries: Array[String] = []  # Entries discovered but not yet read
var _selected_entry_id: String = ""
var _total_entries: int = 12


func _ready() -> void:
	# Hide initially
	hide()
	
	# Wait for scene tree
	await get_tree().process_frame
	
	# Get JournalSystem reference
	_journal_system = get_node_or_null("/root/GameWorld/JournalSystem")
	if not _journal_system:
		_journal_system = get_tree().get_first_node_in_group("journal_system")
	
	# Connect signals
	close_button.pressed.connect(_on_close_pressed)
	
	if _journal_system:
		_journal_system.journal_entry_unlocked.connect(_on_entry_unlocked)
		_total_entries = _journal_system.total_entries
	
	# Apply styling
	_apply_styling()
	
	# Load journal entries
	_load_journal_entries()
	
	# Initialize display
	_refresh_ui()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_journal"):
		toggle_journal()


## Toggle journal visibility
func toggle_journal() -> void:
	if visible:
		hide_journal()
	else:
		show_journal()


## Show the journal
func show_journal() -> void:
	visible = true
	_close_other_uis()
	_refresh_ui()


## Hide the journal
func hide_journal() -> void:
	visible = false


## Close other UI panels for mutual exclusion
func _close_other_uis() -> void:
	var uis_to_check := [
		"/root/GameWorld/InventoryUI",
		"/root/GameWorld/CarbonDashboard",
		"/root/GameWorld/MarketUI",
		"/root/GameWorld/PauseMenu"
	]
	
	for ui_path in uis_to_check:
		var ui = get_node_or_null(ui_path)
		if ui and ui.visible and ui != self:
			if ui.has_method("hide_inventory"):
				ui.hide_inventory()
			elif ui.has_method("hide_dashboard"):
				ui.hide_dashboard()
			elif ui.has_method("hide_market"):
				ui.hide_market()
			elif ui.has_method("hide_pause_menu"):
				ui.hide_pause_menu()
			else:
				ui.hide()


## Apply art direction styling
func _apply_styling() -> void:
	# Main panel - weathered notebook style
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = PARCHMENT_BG
	panel_style.border_color = DRIFTWOOD_BORDER
	panel_style.border_width_left = 5
	panel_style.border_width_right = 5
	panel_style.border_width_top = 5
	panel_style.border_width_bottom = 5
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.shadow_color = Color(0, 0, 0, 0.4)
	panel_style.shadow_size = 10
	
	if main_panel:
		main_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Style text colors
	if entry_counter:
		entry_counter.add_theme_color_override("font_color", DRIFTWOOD_BORDER)
	
	if content_title:
		content_title.add_theme_color_override("font_color", GOLDEN_TEXT)
	
	if content_date:
		content_date.add_theme_color_override("font_color", DRIFTWOOD_BORDER)
	
	if content_text:
		content_text.add_theme_color_override("default_color", TEXT_COLOR)
	
	if content_unlock:
		content_unlock.add_theme_color_override("font_color", LOCKED_COLOR)
	
	# Overlay
	if overlay:
		overlay.color = OVERLAY_COLOR


## Load all journal entries and create UI buttons
func _load_journal_entries() -> void:
	if not _journal_system:
		return
	
	# Clear existing buttons
	for child in entries_list.get_children():
		child.queue_free()
	_entry_buttons.clear()
	
	# Load all 12 journal entry resources
	var entry_paths := [
		"res://resources/journal/01_welcome_home.tres",
		"res://resources/journal/02_seagrass_secret.tres",
		"res://resources/journal/03_tides_of_change.tres",
		"res://resources/journal/04_old_friends.tres",
		"res://resources/journal/05_numbers_dont_lie.tres",
		"res://resources/journal/06_storm_warning.tres",
		"res://resources/journal/07_roots_run_deep.tres",
		"res://resources/journal/08_elders_wisdom.tres",
		"res://resources/journal/09_mayors_doubt.tres",
		"res://resources/journal/10_life_returns.tres",
		"res://resources/journal/11_legacy.tres",
		"res://resources/journal/12_dear_grandchild.tres"
	]
	
	# Register entries with journal system
	for entry_path in entry_paths:
		var entry_data = load(entry_path) as Resource
		if entry_data:
			# Create a JournalEntry for the system
			var journal_entry = _journal_system.JournalEntry.new()
			journal_entry.entry_id = entry_data.entry_id
			journal_entry.title = entry_data.title
			journal_entry.content = entry_data.content
			journal_entry.unlock_condition = entry_data.unlock_condition
			journal_entry.research_point_bonus = entry_data.research_point_bonus
			journal_entry.unlocks = entry_data.unlocks
			
			# Register with system
			_journal_system.register_entry(journal_entry)
			
			# Create UI button
			_create_entry_button(journal_entry)
	
	# Check for unlockable entries
	_journal_system.check_all_conditions()


## Create a button for a journal entry
func _create_entry_button(entry) -> void:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 50)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	# Style the button
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(1, 1, 1, 0.1)
	normal_style.border_color = DRIFTWOOD_BORDER
	normal_style.border_width_left = 2
	normal_style.border_width_right = 2
	normal_style.border_width_top = 2
	normal_style.border_width_bottom = 2
	normal_style.corner_radius_top_left = 4
	normal_style.corner_radius_top_right = 4
	normal_style.corner_radius_bottom_left = 4
	normal_style.corner_radius_bottom_right = 4
	
	var hover_style := normal_style.duplicate() as StyleBoxFlat
	hover_style.bg_color = Color(1, 1, 1, 0.3)
	
	var pressed_style := normal_style.duplicate() as StyleBoxFlat
	pressed_style.bg_color = GOLDEN_TEXT
	pressed_style.modulate_color = Color(1, 1, 1, 0.5)
	
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_color_override("font_color", TEXT_COLOR)
	
	# Connect signal
	button.pressed.connect(_on_entry_selected.bind(entry.entry_id))
	
	# Add to list
	entries_list.add_child(button)
	_entry_buttons[entry.entry_id] = button
	
	# Update button text
	_update_entry_button(entry.entry_id)


## Update a single entry button's text and appearance
func _update_entry_button(entry_id: String) -> void:
	if not _journal_system or entry_id not in _entry_buttons:
		return
	
	var entry = _journal_system.get_entry(entry_id)
	var button = _entry_buttons[entry_id]
	
	if entry.discovered:
		# Show title
		button.text = entry.title
		
		# Highlight if new (unread)
		if entry_id in _new_entries:
			var glow_style := button.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
			glow_style.bg_color = NEW_ENTRY_GLOW
			glow_style.border_color = GOLDEN_TEXT
			glow_style.border_width_left = 3
			glow_style.border_width_right = 3
			glow_style.border_width_top = 3
			glow_style.border_width_bottom = 3
			button.add_theme_stylebox_override("normal", glow_style)
			
			# Add "NEW!" indicator
			button.text = "⭐ " + entry.title + " (NEW!)"
	else:
		# Show as locked
		button.text = "🔒 ???"
		button.add_theme_color_override("font_color", LOCKED_COLOR)
		button.disabled = true


## Refresh the entire UI
func _refresh_ui() -> void:
	if not _journal_system:
		return
	
	# Update counter
	var progress = _journal_system.get_discovery_progress()
	entry_counter.text = "%d / %d entries discovered" % [progress.discovered, progress.total]
	
	# Update all entry buttons
	for entry_id in _entry_buttons.keys():
		_update_entry_button(entry_id)
	
	# If no entry selected, select first discovered one
	if _selected_entry_id.is_empty():
		var discovered = _journal_system.get_discovered_entries()
		if discovered.size() > 0:
			_select_entry(discovered[0])


## Select and display an entry
func _select_entry(entry_id: String) -> void:
	if not _journal_system:
		return
	
	var entry = _journal_system.get_entry(entry_id)
	if not entry or not entry.discovered:
		return
	
	_selected_entry_id = entry_id
	
	# Update content display
	content_title.text = entry.title
	content_text.text = entry.content
	
	# Format unlock condition as readable text
	var unlock_text := _format_unlock_condition(entry.unlock_condition)
	content_unlock.text = "Unlocked by: " + unlock_text
	
	# Mark as read (remove from new entries)
	if entry_id in _new_entries:
		_new_entries.erase(entry_id)
		_update_entry_button(entry_id)


## Format unlock condition for display
func _format_unlock_condition(condition: String) -> String:
	if condition == "game_start":
		return "Starting the game"
	elif condition == "first_plant":
		return "Your first planting"
	elif condition == "first_harvest":
		return "Your first harvest"
	elif condition.begins_with("carbon_"):
		var amount = condition.split("_")[1]
		return "Sequestering " + amount + " tonnes of CO₂"
	elif condition.begins_with("year_"):
		var year = condition.split("_")[1]
		return "Reaching year " + year
	elif condition.begins_with("friendship_"):
		var parts = condition.split("_")
		if parts.size() >= 3:
			return "Building friendship with " + parts[2]
	elif condition.begins_with("wildlife_"):
		var wildlife = condition.split("_")[1]
		return "First " + wildlife + " sighting"
	
	return condition.capitalize()


## Handle entry button pressed
func _on_entry_selected(entry_id: String) -> void:
	_select_entry(entry_id)


## Handle entry unlocked signal
func _on_entry_unlocked(entry_id: String) -> void:
	# Add to new entries list
	if entry_id not in _new_entries:
		_new_entries.append(entry_id)
	
	# Refresh UI to show the new entry
	_refresh_ui()
	
	# Show notification
	_show_new_entry_notification(entry_id)


## Show notification for new entry
func _show_new_entry_notification(entry_id: String) -> void:
	if not _journal_system:
		return
	
	var entry = _journal_system.get_entry(entry_id)
	if not entry:
		return
	
	# Try to find notification system
	var notification_popup = get_node_or_null("/root/GameWorld/NotificationPopup")
	if notification_popup and notification_popup.has_method("show_notification"):
		notification_popup.show_notification(
			"📖 New Journal Entry!",
			entry.title + "\nPress J to read",
			5.0
		)


## Handle close button
func _on_close_pressed() -> void:
	hide_journal()


## Get save data
func get_save_data() -> Dictionary:
	return {
		"new_entries": _new_entries
	}


## Load save data
func load_save_data(data: Dictionary) -> void:
	_new_entries = data.get("new_entries", [])
	_refresh_ui()
