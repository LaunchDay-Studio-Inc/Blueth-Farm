extends CharacterBody2D
## NPC controller for individual NPCs
## Handles interaction, schedule-based positioning, and visual feedback

signal interaction_started(npc_id: String)
signal interaction_ended(npc_id: String)

@export var npc_data: NPCData = null

var player_nearby: bool = false
var player_ref: Node2D = null
var current_location: Vector2 = Vector2.ZERO
var tween: Tween

# Visual animation
var idle_pulse_direction: float = 1.0
const PULSE_SPEED: float = 0.3
const PULSE_AMOUNT: float = 0.1


func _ready() -> void:
	if npc_data:
		_initialize_from_data()
	
	# Connect to TimeManager for schedule updates
	if TimeManager:
		TimeManager.hour_changed.connect(_on_hour_changed)


func _initialize_from_data() -> void:
	"""Initialize NPC from NPCData resource"""
	# Set name label
	var name_label = $NameLabel
	if name_label:
		name_label.text = npc_data.display_name
	
	# Set sprite color from portrait_color
	var sprite = $Sprite
	if sprite and sprite is ColorRect:
		sprite.color = npc_data.portrait_color
	
	# Set initial position based on schedule
	if TimeManager:
		var current_hour = TimeManager.current_hour
		_update_position_for_hour(current_hour)
	
	print("NPC initialized: ", npc_data.display_name)


func _process(delta: float) -> void:
	_handle_input()
	_update_idle_animation(delta)


func _handle_input() -> void:
	"""Handle interaction input"""
	if player_nearby and Input.is_action_just_pressed("interact"):
		_start_interaction()


func _update_idle_animation(delta: float) -> void:
	"""Subtle idle animation - pulse scale"""
	var pulse_scale = 1.0 + sin(Time.get_ticks_msec() * 0.001 * PULSE_SPEED * TAU) * PULSE_AMOUNT
	scale = Vector2(pulse_scale, pulse_scale)


func _start_interaction() -> void:
	"""Start dialogue interaction with this NPC"""
	if not npc_data:
		return
	
	# Notify interaction started
	interaction_started.emit(npc_data.npc_id)
	
	# Notify QuestEventBridge about this interaction
	var quest_bridge = get_tree().get_first_node_in_group("quest_event_bridge")
	if not quest_bridge:
		quest_bridge = get_node_or_null("/root/GameWorld/QuestEventBridge")
	if quest_bridge and quest_bridge.has_method("set_last_npc_talked_to"):
		quest_bridge.set_last_npc_talked_to(npc_data.npc_id)
	
	# Face the player
	if player_ref:
		_face_target(player_ref.global_position)
	
	# Get appropriate dialogue tree
	var dialogue_tree = _get_current_dialogue()
	
	# Start dialogue via DialogueSystem
	if dialogue_tree and not dialogue_tree.is_empty():
		GameManager.set_game_state(GameManager.GameState.DIALOGUE)
		
		# Convert dialogue tree to proper format
		var formatted_dialogue = _format_dialogue_tree(dialogue_tree)
		
		# Trigger dialogue system
		var dialogue_system = get_node_or_null("/root/DialogueSystem")
		if not dialogue_system:
			# Try to find it in the scene tree
			dialogue_system = get_tree().get_first_node_in_group("dialogue_system")
		
		if dialogue_system:
			dialogue_system.start_dialogue(formatted_dialogue)
		else:
			# Fallback: emit signal for dialogue box to catch
			var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")
			if dialogue_box and dialogue_box.has_method("start_dialogue"):
				dialogue_box.start_dialogue(npc_data.npc_id, formatted_dialogue)


func _get_current_dialogue() -> Dictionary:
	"""Get the appropriate dialogue tree for current context"""
	if not npc_data:
		return {}

	# Check if tutorial is active and this is Old Salt
	if npc_data.npc_id == "old_salt":
		var tutorial_system = get_tree().get_first_node_in_group("tutorial_system")
		if not tutorial_system:
			tutorial_system = get_node_or_null("/root/GameWorld/TutorialSystem")

		if tutorial_system and tutorial_system.tutorial_active:
			# Check current tutorial step
			var current_step = tutorial_system.current_step
			if current_step == tutorial_system.TutorialStep.TALK_TO_OLD_SALT:
				# Return tutorial dialogue for meeting at dock
				if "tutorial_meet_at_dock" in npc_data.dialogue_trees:
					return npc_data.dialogue_trees["tutorial_meet_at_dock"]

	# Check for quest-specific dialogue
	var quest_dialogue = _check_quest_dialogue()
	if not quest_dialogue.is_empty():
		return quest_dialogue

	# Check for friendship-level dialogue
	var friendship = 0
	if has_node("/root/RelationshipSystem"):
		var rel_system = get_node("/root/RelationshipSystem")
		if rel_system.has_method("get_friendship"):
			friendship = rel_system.get_friendship(npc_data.npc_id)

	# Try friendship-specific dialogue at thresholds
	for threshold in [80, 60, 40, 20]:
		if friendship >= threshold:
			var key = "friendship_" + str(threshold)
			if key in npc_data.dialogue_trees:
				return npc_data.dialogue_trees[key]

	# Try season-specific daily dialogue
	var season = "spring"
	if TimeManager:
		season = TimeManager.get_season_name().to_lower()

	var season_key = "daily_" + season
	if season_key in npc_data.dialogue_trees:
		return npc_data.dialogue_trees[season_key]

	# Fall back to intro or generic daily
	if "daily" in npc_data.dialogue_trees:
		return npc_data.dialogue_trees["daily"]
	if "intro" in npc_data.dialogue_trees:
		return npc_data.dialogue_trees["intro"]

	return {}


func _format_dialogue_tree(dialogue: Dictionary) -> Dictionary:
	"""Format dialogue from NPCData format to DialogueSystem format"""
	# Simple dialogue with just text and optional choices
	var formatted = {
		"start": {
			"speaker": npc_data.display_name if npc_data else "NPC",
			"text": dialogue.get("text", "Hello!"),
			"choices": []
		}
	}
	
	# Add choices if present
	var choices = dialogue.get("choices", [])
	if choices.size() > 0:
		formatted["start"]["choices"] = choices
	else:
		# Single line dialogue - add a continue choice
		formatted["start"]["choices"] = [
			{"text": "Continue", "next": "end"}
		]
	
	return formatted


func _face_target(target_pos: Vector2) -> void:
	"""Make NPC face toward target position"""
	var direction = (target_pos - global_position).normalized()
	# Simple flip based on x direction
	var sprite = $Sprite
	if sprite:
		sprite.scale.x = -1 if direction.x < 0 else 1


func _on_hour_changed(hour: int) -> void:
	"""Called when the in-game hour changes - update NPC position"""
	_update_position_for_hour(hour)


func _update_position_for_hour(hour: int) -> void:
	"""Move NPC to scheduled location for this hour"""
	if not npc_data:
		return
	
	var location_name = npc_data.get_location_at_hour(hour)
	var target_pos = _get_position_for_location(location_name)
	
	if target_pos != Vector2.ZERO and target_pos != global_position:
		_move_to_position(target_pos)


func _get_position_for_location(location_name: String) -> Vector2:
	"""Convert location name to world position"""
	# TODO: This should reference actual world positions
	# For now, using simple predefined positions
	var locations = {
		"dock": Vector2(300, 200),
		"beach": Vector2(500, 400),
		"home": Vector2(700, 300),
		"market": Vector2(400, 500),
		"lab": Vector2(600, 200),
		"shallows": Vector2(450, 350)
	}
	
	return locations.get(location_name, global_position)


func _move_to_position(target_pos: Vector2) -> void:
	"""Smoothly move NPC to target position"""
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", target_pos, 2.0)


func _on_interaction_area_body_entered(body: Node2D) -> void:
	"""Player entered interaction range"""
	if body.is_in_group("player") or body.name == "Player":
		player_nearby = true
		player_ref = body
		# TODO: Show interaction prompt


func _on_interaction_area_body_exited(body: Node2D) -> void:
	"""Player left interaction range"""
	if body.is_in_group("player") or body.name == "Player":
		player_nearby = false
		player_ref = null
		# TODO: Hide interaction prompt


func _on_animation_timer_timeout() -> void:
	"""Timer for periodic animation updates"""
	# Could be used for random movements, expressions, etc.
	pass


func _check_quest_dialogue() -> Dictionary:
	"""Check if this NPC has quest-specific dialogue for active quests"""
	if not npc_data:
		return {}
	
	# Find QuestSystem
	var quest_system = get_tree().get_first_node_in_group("quest_system")
	if not quest_system:
		quest_system = get_node_or_null("/root/GameWorld/QuestSystem")
	
	if not quest_system:
		return {}
	
	# Check active quests for ones given by this NPC
	for quest_id in quest_system.active_quests.keys():
		var quest = quest_system.active_quests[quest_id]
		var quest_def = quest_system.quest_definitions.get(quest_id, {})
		var given_by = quest_def.get("given_by_npc", "")
		
		if given_by == npc_data.npc_id:
			# Look for quest-specific dialogue tree
			var dialogue_key = "quest_" + quest_id
			if dialogue_key in npc_data.dialogue_trees:
				return npc_data.dialogue_trees[dialogue_key]
	
	return {}
