extends CanvasLayer
## Dialogue Box UI Controller
## Handles dialogue display with typewriter effect, choices, and NPC portraits

signal dialogue_completed()

# Art Direction colors
const BG_COLOR = Color("#1A3A52", 0.9)
const BORDER_COLOR = Color("#8B7355")
const TEXT_COLOR = Color("#F5F0E1")

# Typewriter settings
const TYPEWRITER_SPEED: float = 30.0  # characters per second
const SKIP_KEY_DELAY: float = 0.1

var current_dialogue_tree: Dictionary = {}
var current_node_id: String = ""
var current_npc_id: String = ""
var current_text: String = ""
var displayed_text: String = ""
var typewriter_timer: float = 0.0
var text_fully_displayed: bool = false
var choice_buttons: Array = []


func _ready() -> void:
	# Hide initially
	$DialoguePanel.visible = false
	
	# Apply styling
	_apply_styling()
	
	# Connect to DialogueSystem signals if it exists
	var dialogue_system = get_node_or_null("/root/DialogueSystem")
	if dialogue_system:
		if dialogue_system.has_signal("dialogue_started"):
			dialogue_system.dialogue_started.connect(_on_dialogue_started)
		if dialogue_system.has_signal("dialogue_ended"):
			dialogue_system.dialogue_ended.connect(_on_dialogue_ended)
	
	print("DialogueBox initialized")


func _apply_styling() -> void:
	"""Apply Art Direction color palette"""
	var panel = $DialoguePanel
	
	# Create StyleBoxFlat for panel
	var style = StyleBoxFlat.new()
	style.bg_color = BG_COLOR
	style.border_color = BORDER_COLOR
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	
	panel.add_theme_stylebox_override("panel", style)
	
	# Set text colors
	var dialogue_text = $DialoguePanel/MarginContainer/HBoxContainer/TextSection/DialogueText
	if dialogue_text:
		dialogue_text.add_theme_color_override("default_color", TEXT_COLOR)
	
	var speaker_label = $DialoguePanel/MarginContainer/HBoxContainer/TextSection/SpeakerLabel
	if speaker_label:
		speaker_label.add_theme_color_override("font_color", TEXT_COLOR)
	
	var npc_name = $DialoguePanel/MarginContainer/HBoxContainer/PortraitSection/NPCNameLabel
	if npc_name:
		npc_name.add_theme_color_override("font_color", TEXT_COLOR)


func _process(delta: float) -> void:
	if not $DialoguePanel.visible:
		return
	
	_update_typewriter(delta)
	_handle_input()


func _update_typewriter(delta: float) -> void:
	"""Update typewriter effect"""
	if text_fully_displayed:
		return
	
	typewriter_timer += delta
	var chars_to_display = int(typewriter_timer * TYPEWRITER_SPEED)
	
	if chars_to_display >= current_text.length():
		displayed_text = current_text
		text_fully_displayed = true
		_show_continue_or_choices()
	else:
		displayed_text = current_text.substr(0, chars_to_display)
	
	_update_dialogue_text()


func _update_dialogue_text() -> void:
	"""Update the displayed dialogue text"""
	var dialogue_label = $DialoguePanel/MarginContainer/HBoxContainer/TextSection/DialogueText
	if dialogue_label:
		dialogue_label.text = displayed_text


func _handle_input() -> void:
	"""Handle dialogue input"""
	# Press Space to skip typewriter
	if Input.is_action_just_pressed("ui_accept"):
		if not text_fully_displayed:
			_skip_typewriter()
	
	# Press E to continue when text is fully displayed
	if Input.is_action_just_pressed("interact"):
		if text_fully_displayed and choice_buttons.size() == 0:
			_advance_dialogue(0)


func _skip_typewriter() -> void:
	"""Skip to end of typewriter animation"""
	displayed_text = current_text
	text_fully_displayed = true
	typewriter_timer = current_text.length() / TYPEWRITER_SPEED
	_update_dialogue_text()
	_show_continue_or_choices()


func start_dialogue(npc_id: String, dialogue_tree: Dictionary) -> void:
	"""Start a dialogue conversation"""
	current_npc_id = npc_id
	current_dialogue_tree = dialogue_tree
	current_node_id = "start"
	
	# Show dialogue panel
	$DialoguePanel.visible = true
	
	# Set game state to dialogue
	GameManager.set_game_state(GameManager.GameState.DIALOGUE)
	
	# Load NPC portrait info
	_load_npc_portrait(npc_id)
	
	# Process first node
	_process_dialogue_node()


func _load_npc_portrait(npc_id: String) -> void:
	"""Load NPC portrait color and name"""
	# Try to find NPC by ID
	var npc_manager = get_tree().get_first_node_in_group("npc_manager")
	if not npc_manager:
		npc_manager = get_node_or_null("/root/GameWorld/NPCManager")
	
	if npc_manager and npc_manager.has_method("get_npc_by_id"):
		var npc_node = npc_manager.get_npc_by_id(npc_id)
		if npc_node and npc_node.npc_data:
			var portrait_color_rect = $DialoguePanel/MarginContainer/HBoxContainer/PortraitSection/PortraitColor
			if portrait_color_rect:
				portrait_color_rect.color = npc_node.npc_data.portrait_color
			
			var npc_name_label = $DialoguePanel/MarginContainer/HBoxContainer/PortraitSection/NPCNameLabel
			if npc_name_label:
				npc_name_label.text = npc_node.npc_data.display_name
			
			var speaker_label = $DialoguePanel/MarginContainer/HBoxContainer/TextSection/SpeakerLabel
			if speaker_label:
				speaker_label.text = npc_node.npc_data.display_name


func _process_dialogue_node() -> void:
	"""Process the current dialogue node"""
	if current_node_id == "end" or current_node_id.is_empty():
		_end_dialogue()
		return
	
	var node = current_dialogue_tree.get(current_node_id, {})
	if node.is_empty():
		_end_dialogue()
		return
	
	# Set text for typewriter
	current_text = node.get("text", "...")
	displayed_text = ""
	typewriter_timer = 0.0
	text_fully_displayed = false
	
	# Clear existing choices
	_clear_choices()
	
	# Hide continue indicator initially
	var continue_indicator = $DialoguePanel/MarginContainer/HBoxContainer/TextSection/ContinueIndicator
	if continue_indicator:
		continue_indicator.visible = false


func _show_continue_or_choices() -> void:
	"""Show continue indicator or choice buttons when text is done"""
	var node = current_dialogue_tree.get(current_node_id, {})
	var choices = node.get("choices", [])
	
	if choices.size() > 0:
		_create_choice_buttons(choices)
	else:
		# Show continue indicator
		var continue_indicator = $DialoguePanel/MarginContainer/HBoxContainer/TextSection/ContinueIndicator
		if continue_indicator:
			continue_indicator.visible = true


func _create_choice_buttons(choices: Array) -> void:
	"""Create buttons for dialogue choices"""
	_clear_choices()
	
	var choices_container = $DialoguePanel/MarginContainer/HBoxContainer/TextSection/ChoicesContainer
	if not choices_container:
		return
	
	for i in range(choices.size()):
		if i >= 4:  # Max 4 choices
			break
		
		var choice = choices[i]
		var button = Button.new()
		button.text = choice.get("text", "Continue")
		button.pressed.connect(_on_choice_selected.bind(i))
		
		# Style button
		button.add_theme_color_override("font_color", TEXT_COLOR)
		button.add_theme_color_override("font_hover_color", Color("#E8A87C"))
		
		choices_container.add_child(button)
		choice_buttons.append(button)


func _clear_choices() -> void:
	"""Remove all choice buttons"""
	for button in choice_buttons:
		if button:
			button.queue_free()
	choice_buttons.clear()


func _on_choice_selected(choice_index: int) -> void:
	"""Handle choice button click"""
	_advance_dialogue(choice_index)


func _advance_dialogue(choice_index: int) -> void:
	"""Advance to next dialogue node based on choice"""
	var node = current_dialogue_tree.get(current_node_id, {})
	var choices = node.get("choices", [])
	
	if choice_index < 0 or choice_index >= choices.size():
		_end_dialogue()
		return
	
	var selected_choice = choices[choice_index]
	var next_node = selected_choice.get("next", "end")
	
	# Check for friendship changes
	var friendship_change = selected_choice.get("friendship", 0)
	if friendship_change != 0:
		_apply_friendship_change(friendship_change)
	
	# Move to next node
	current_node_id = next_node
	_process_dialogue_node()


func _apply_friendship_change(amount: int) -> void:
	"""Apply friendship change and show floating text"""
	# Apply to RelationshipSystem
	var rel_system = get_node_or_null("/root/RelationshipSystem")
	if not rel_system:
		rel_system = get_tree().get_first_node_in_group("relationship_system")
	
	if rel_system and rel_system.has_method("add_friendship"):
		rel_system.add_friendship(current_npc_id, amount)
	
	# Show floating text
	_show_friendship_change(amount)


func _show_friendship_change(amount: int) -> void:
	"""Show floating friendship change indicator"""
	var label = $FriendshipChangeLabel
	if not label:
		return
	
	var sign = "+" if amount > 0 else ""
	label.text = sign + str(amount) + " ❤️"
	label.visible = true
	
	# Animate
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 30, 1.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.0).set_delay(0.5)
	
	await tween.finished
	label.visible = false
	label.modulate.a = 1.0


func _end_dialogue() -> void:
	"""End the dialogue conversation"""
	# Hide panel
	$DialoguePanel.visible = false
	
	# Clear state
	current_dialogue_tree = {}
	current_node_id = ""
	current_npc_id = ""
	_clear_choices()
	
	# Return to playing state
	GameManager.set_game_state(GameManager.GameState.PLAYING)
	
	# Emit completion signal
	dialogue_completed.emit()
	
	# Notify DialogueSystem
	var dialogue_system = get_node_or_null("/root/DialogueSystem")
	if dialogue_system and dialogue_system.has_method("_end_dialogue"):
		dialogue_system._end_dialogue()


func _on_dialogue_started(speaker: String, text: String) -> void:
	"""Called when DialogueSystem starts dialogue"""
	# This is called by the old DialogueSystem singleton
	# We handle our own dialogue now, so we can ignore this
	pass


func _on_dialogue_ended() -> void:
	"""Called when DialogueSystem ends dialogue"""
	_end_dialogue()
