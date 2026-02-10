extends CanvasLayer
## Quest Log UI Controller
##
## Displays active and completed quests with objectives and progress tracking.
## Shows quest details, objectives with checkboxes, and rewards.

## Art Direction color palette
const BG_COLOR := Color("#1A3A52", 0.9)
const BORDER_COLOR := Color("#8B7355")
const TEXT_COLOR := Color("#F5F0E1")
const HEADER_COLOR := Color("#2E5E8C")
const ACTIVE_QUEST_COLOR := Color("#4A7C59")
const COMPLETED_QUEST_COLOR := Color("#D4A76A")
const NEW_QUEST_BADGE_COLOR := Color("#C75B3A")

## UI References
@onready var overlay := $Overlay
@onready var main_panel := $MainPanel
@onready var close_button := $MainPanel/MarginContainer/VBoxContainer/Header/CloseButton
@onready var quest_count_label := $MainPanel/MarginContainer/VBoxContainer/Header/QuestCount
@onready var active_quests_list := $MainPanel/MarginContainer/VBoxContainer/Content/LeftSide/ScrollContainer/ActiveQuestsVBox
@onready var completed_quests_toggle := $MainPanel/MarginContainer/VBoxContainer/Content/LeftSide/CompletedToggle
@onready var completed_quests_list := $MainPanel/MarginContainer/VBoxContainer/Content/LeftSide/CompletedScrollContainer/CompletedQuestsVBox
@onready var detail_title := $MainPanel/MarginContainer/VBoxContainer/Content/RightSide/ScrollContainer/DetailVBox/QuestTitle
@onready var detail_description := $MainPanel/MarginContainer/VBoxContainer/Content/RightSide/ScrollContainer/DetailVBox/QuestDescription
@onready var objectives_container := $MainPanel/MarginContainer/VBoxContainer/Content/RightSide/ScrollContainer/DetailVBox/ObjectivesContainer
@onready var rewards_label := $MainPanel/MarginContainer/VBoxContainer/Content/RightSide/ScrollContainer/DetailVBox/RewardsLabel

## State
var _quest_system: Node = null
var _active_quest_buttons: Dictionary = {}  # quest_id -> Button
var _completed_quest_buttons: Dictionary = {}  # quest_id -> Button
var _selected_quest_id: String = ""
var _new_quests: Array[String] = []  # Quest IDs with unread badge
var _show_completed: bool = false


func _ready() -> void:
	# Set process mode for pause handling
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Hide initially
	hide()
	
	# Wait for scene tree
	await get_tree().process_frame
	
	# Get QuestSystem reference
	_quest_system = get_node_or_null("/root/GameWorld/QuestSystem")
	if not _quest_system:
		_quest_system = get_tree().get_first_node_in_group("quest_system")
	
	# Connect signals
	close_button.pressed.connect(_on_close_pressed)
	completed_quests_toggle.toggled.connect(_on_completed_toggle_changed)
	
	# Connect to QuestSystem signals
	if _quest_system:
		if _quest_system.has_signal("quest_started"):
			_quest_system.quest_started.connect(_on_quest_started)
		if _quest_system.has_signal("quest_updated"):
			_quest_system.quest_updated.connect(_on_quest_updated)
		if _quest_system.has_signal("quest_completed"):
			_quest_system.quest_completed.connect(_on_quest_completed)
	
	# Apply styling
	_apply_styling()
	
	# Initialize display
	_refresh_ui()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_quest_log"):
		toggle_quest_log()
	elif event.is_action_pressed("ui_cancel") and visible:
		hide_quest_log()


## Toggle quest log visibility
func toggle_quest_log() -> void:
	if visible:
		hide_quest_log()
	else:
		show_quest_log()


## Show the quest log
func show_quest_log() -> void:
	visible = true
	
	# Notify UI State Manager
	if has_node("/root/UIStateManager"):
		get_node("/root/UIStateManager").open_panel("quest_log")
	
	_refresh_ui()


## Hide the quest log
func hide_quest_log() -> void:
	visible = false
	
	# Notify UI State Manager
	if has_node("/root/UIStateManager"):
		get_node("/root/UIStateManager").close_panel()


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
	if detail_title:
		detail_title.add_theme_color_override("font_color", TEXT_COLOR)
	if detail_description:
		detail_description.add_theme_color_override("font_color", TEXT_COLOR)
	if rewards_label:
		rewards_label.add_theme_color_override("font_color", TEXT_COLOR)
	if quest_count_label:
		quest_count_label.add_theme_color_override("font_color", TEXT_COLOR)


## Refresh the entire UI display
func _refresh_ui() -> void:
	if not _quest_system:
		return
	
	# Update active quests list
	_update_active_quests()
	
	# Update completed quests list
	_update_completed_quests()
	
	# Update quest count
	_update_quest_count()
	
	# Refresh selected quest details
	if _selected_quest_id != "":
		_display_quest_details(_selected_quest_id)


## Update the active quests list
func _update_active_quests() -> void:
	if not _quest_system or not active_quests_list:
		return
	
	# Clear existing buttons
	for child in active_quests_list.get_children():
		child.queue_free()
	_active_quest_buttons.clear()
	
	# Get active quests from system
	var active_quests = _quest_system.get_active_quests() if _quest_system.has_method("get_active_quests") else []
	
	# Create button for each active quest
	for quest in active_quests:
		var quest_id = quest.quest_id if quest.has("quest_id") else ""
		var quest_title = quest.title if quest.has("title") else "Unknown Quest"
		
		var button := Button.new()
		button.text = quest_title
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_color_override("font_color", TEXT_COLOR)
		button.pressed.connect(_on_quest_selected.bind(quest_id))
		
		# Add new quest badge if applicable
		if quest_id in _new_quests:
			button.text = "⭐ " + button.text
		
		active_quests_list.add_child(button)
		_active_quest_buttons[quest_id] = button


## Update the completed quests list
func _update_completed_quests() -> void:
	if not _quest_system or not completed_quests_list:
		return
	
	# Clear existing buttons
	for child in completed_quests_list.get_children():
		child.queue_free()
	_completed_quest_buttons.clear()
	
	# Get completed quests from system
	var completed_quests = _quest_system.get_completed_quests() if _quest_system.has_method("get_completed_quests") else []
	
	# Create button for each completed quest
	for quest in completed_quests:
		var quest_id = quest.quest_id if quest.has("quest_id") else ""
		var quest_title = quest.title if quest.has("title") else "Unknown Quest"
		
		var button := Button.new()
		button.text = "✓ " + quest_title
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_color_override("font_color", COMPLETED_QUEST_COLOR)
		button.pressed.connect(_on_quest_selected.bind(quest_id))
		
		completed_quests_list.add_child(button)
		_completed_quest_buttons[quest_id] = button


## Update quest count display
func _update_quest_count() -> void:
	if not _quest_system or not quest_count_label:
		return
	
	var active_count = 0
	var completed_count = 0
	
	if _quest_system.has_method("get_active_quests"):
		active_count = _quest_system.get_active_quests().size()
	
	if _quest_system.has_method("get_completed_quests"):
		completed_count = _quest_system.get_completed_quests().size()
	
	quest_count_label.text = "Active: %d | Completed: %d" % [active_count, completed_count]


## Display details for a selected quest
func _display_quest_details(quest_id: String) -> void:
	if not _quest_system:
		return
	
	var quest = _quest_system.get_quest(quest_id) if _quest_system.has_method("get_quest") else null
	
	if not quest:
		return
	
	# Set title and description
	if detail_title:
		detail_title.text = quest.get("title", "Quest")
	
	if detail_description:
		detail_description.text = quest.get("description", "No description available.")
	
	# Display objectives
	_display_objectives(quest)
	
	# Display rewards
	_display_rewards(quest)
	
	# Remove new quest badge
	if quest_id in _new_quests:
		_new_quests.erase(quest_id)
		_update_active_quests()


## Display quest objectives with checkboxes
func _display_objectives(quest: Dictionary) -> void:
	if not objectives_container:
		return
	
	# Clear existing objectives
	for child in objectives_container.get_children():
		if child.name != "ObjectivesHeader":
			child.queue_free()
	
	var objectives = quest.get("objectives", [])
	
	for objective in objectives:
		var obj_text = objective.get("description", "")
		var obj_completed = objective.get("completed", false)
		
		var hbox := HBoxContainer.new()
		
		# Checkbox
		var checkbox := CheckBox.new()
		checkbox.button_pressed = obj_completed
		checkbox.disabled = true
		hbox.add_child(checkbox)
		
		# Objective text
		var label := Label.new()
		label.text = obj_text
		label.add_theme_color_override("font_color", TEXT_COLOR)
		hbox.add_child(label)
		
		objectives_container.add_child(hbox)


## Display quest rewards
func _display_rewards(quest: Dictionary) -> void:
	if not rewards_label:
		return
	
	var rewards = quest.get("rewards", {})
	var reward_text := "Rewards: "
	
	var reward_parts := []
	
	if rewards.has("gold") and rewards.gold > 0:
		reward_parts.append(str(rewards.gold) + " Gold")
	
	if rewards.has("research_points") and rewards.research_points > 0:
		reward_parts.append(str(rewards.research_points) + " Research Points")
	
	if rewards.has("items") and rewards.items.size() > 0:
		for item in rewards.items:
			reward_parts.append(item)
	
	if reward_parts.is_empty():
		reward_text += "None"
	else:
		reward_text += ", ".join(reward_parts)
	
	rewards_label.text = reward_text


## Signal handlers

func _on_close_pressed() -> void:
	hide_quest_log()


func _on_quest_selected(quest_id: String) -> void:
	_selected_quest_id = quest_id
	_display_quest_details(quest_id)


func _on_completed_toggle_changed(toggled_on: bool) -> void:
	_show_completed = toggled_on
	
	if completed_quests_list.get_parent():
		completed_quests_list.get_parent().visible = _show_completed


func _on_quest_started(quest_id: String) -> void:
	# Add to new quests list
	_new_quests.append(quest_id)
	
	# Refresh display
	_refresh_ui()


func _on_quest_updated(quest_id: String) -> void:
	# Refresh if this quest is currently selected
	if _selected_quest_id == quest_id:
		_display_quest_details(quest_id)
	
	# Refresh lists in case quest completion status changed
	_refresh_ui()


func _on_quest_completed(quest_id: String) -> void:
	# Remove from new quests
	if quest_id in _new_quests:
		_new_quests.erase(quest_id)
	
	# Refresh display
	_refresh_ui()
