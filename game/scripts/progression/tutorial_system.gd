extends Node
## Tutorial System
## Guides new players through the first steps of the game

signal tutorial_step_completed(step_index: int)
signal tutorial_completed()
signal tutorial_skipped()

enum TutorialStep {
	WELCOME,           # Welcome and movement
	OPEN_JOURNAL,      # Press J to read journal
	WALK_TO_DOCK,      # Walk to dock location
	TALK_TO_OLD_SALT,  # Press E to talk
	OPEN_INVENTORY,    # Press I to open inventory
	EQUIP_AND_PLANT,   # Equip seed bag and plant
	CHECK_DASHBOARD,   # Press Tab for carbon dashboard
	COMPLETE           # Tutorial finished
}

var current_step: int = TutorialStep.WELCOME
var tutorial_active: bool = false
var tutorial_completed_flag: bool = false
var step_objectives: Dictionary = {}


func _ready() -> void:
	_initialize_tutorial_steps()
	print("TutorialSystem initialized")


func _initialize_tutorial_steps() -> void:
	"""Define tutorial step objectives"""
	step_objectives = {
		TutorialStep.WELCOME: {
			"title": "Welcome to Blueth Farm!",
			"message": "Use WASD to move around your grandmother's coastal property",
			"icon": "🌊",
			"objective": "move",
			"condition": "_check_movement"
		},
		TutorialStep.OPEN_JOURNAL: {
			"title": "Your Grandmother's Legacy",
			"message": "Press J to read your grandmother's journal",
			"icon": "📖",
			"objective": "open_journal",
			"condition": "_check_journal_opened"
		},
		TutorialStep.WALK_TO_DOCK: {
			"title": "Meet Old Salt",
			"message": "Walk to the dock to meet Old Salt, the local fisherman",
			"icon": "🎯",
			"objective": "reach_dock",
			"condition": "_check_at_dock",
			"show_marker": true,
			"marker_position": Vector2(300, 200)
		},
		TutorialStep.TALK_TO_OLD_SALT: {
			"title": "Talk to Old Salt",
			"message": "Press E to talk to Old Salt",
			"icon": "💬",
			"objective": "talk_to_npc",
			"condition": "_check_dialogue_started"
		},
		TutorialStep.OPEN_INVENTORY: {
			"title": "Check Your Items",
			"message": "Old Salt gave you eelgrass seeds! Open your inventory with I",
			"icon": "🎒",
			"objective": "open_inventory",
			"condition": "_check_inventory_opened"
		},
		TutorialStep.EQUIP_AND_PLANT: {
			"title": "Plant Your First Seeds",
			"message": "Equip the Seed Bag with 2, then click a shallow water tile to plant",
			"icon": "🌱",
			"objective": "plant_first",
			"condition": "_check_first_plant"
		},
		TutorialStep.CHECK_DASHBOARD: {
			"title": "Track Your Impact",
			"message": "Great! Press Tab to check your Carbon Dashboard",
			"icon": "📊",
			"objective": "open_dashboard",
			"condition": "_check_dashboard_opened"
		}
	}


func start_tutorial() -> void:
	"""Start the tutorial sequence"""
	if tutorial_completed_flag:
		print("Tutorial already completed")
		return
	
	tutorial_active = true
	current_step = TutorialStep.WELCOME
	
	# Show first step
	_show_current_step()
	
	print("Tutorial started")


func _process(_delta: float) -> void:
	if not tutorial_active:
		return
	
	# Check current step condition
	_check_step_completion()


func _check_step_completion() -> void:
	"""Check if current step is complete"""
	if current_step >= TutorialStep.COMPLETE:
		return
	
	var step_data = step_objectives.get(current_step, {})
	var condition_method = step_data.get("condition", "")
	
	if condition_method.is_empty():
		return
	
	# Call condition check method
	var is_complete = false
	if has_method(condition_method):
		is_complete = call(condition_method)
	
	if is_complete:
		_complete_current_step()


func _complete_current_step() -> void:
	"""Complete the current tutorial step"""
	tutorial_step_completed.emit(current_step)
	
	# Hide current step tooltip
	_hide_tutorial_tooltip()
	
	# Move to next step
	current_step += 1
	
	if current_step >= TutorialStep.COMPLETE:
		_complete_tutorial()
	else:
		# Small delay before showing next step
		await get_tree().create_timer(0.5).timeout
		_show_current_step()


func _show_current_step() -> void:
	"""Display the current tutorial step"""
	var step_data = step_objectives.get(current_step, {})
	
	var title = step_data.get("title", "")
	var message = step_data.get("message", "")
	var icon = step_data.get("icon", "")
	
	# Show tutorial tooltip
	_show_tutorial_tooltip(title, message, icon)
	
	# Show objective marker if needed
	if step_data.get("show_marker", false):
		var marker_pos = step_data.get("marker_position", Vector2.ZERO)
		_show_objective_marker(marker_pos)
	
	# Perform step-specific actions
	match current_step:
		TutorialStep.OPEN_INVENTORY:
			# Give player eelgrass seeds
			_give_starting_items()


func _show_tutorial_tooltip(title: String, message: String, icon: String) -> void:
	"""Show tutorial tooltip panel"""
	# Find or create tutorial tooltip UI
	var tooltip = get_tree().get_first_node_in_group("tutorial_tooltip")
	if not tooltip:
		# Load tooltip scene
		var tooltip_scene = load("res://scenes/ui/tutorial_tooltip.tscn")
		if tooltip_scene:
			tooltip = tooltip_scene.instantiate()
			get_tree().root.add_child(tooltip)
	
	if tooltip and tooltip.has_method("show_step"):
		tooltip.show_step(title, message, icon)


func _hide_tutorial_tooltip() -> void:
	"""Hide tutorial tooltip"""
	var tooltip = get_tree().get_first_node_in_group("tutorial_tooltip")
	if tooltip and tooltip.has_method("hide_tooltip"):
		tooltip.hide_tooltip()


func _show_objective_marker(position: Vector2) -> void:
	"""Show an arrow or marker pointing to objective"""
	# TODO: Implement objective marker
	pass


func _give_starting_items() -> void:
	"""Give player starting items for tutorial"""
	var player_inventory = get_tree().get_first_node_in_group("player_inventory")
	if not player_inventory:
		player_inventory = get_node_or_null("/root/GameWorld/Player/PlayerInventory")
	
	if player_inventory and player_inventory.has_method("add_item"):
		# Give 10 eelgrass seeds
		player_inventory.add_item("seagrass_zostera_seed", 10)
		print("Tutorial: Gave 10 eelgrass seeds to player")


func _complete_tutorial() -> void:
	"""Complete the tutorial"""
	tutorial_active = false
	tutorial_completed_flag = true
	current_step = TutorialStep.COMPLETE
	
	# Mark as complete in GameManager
	if GameManager:
		GameManager.tutorial_completed = true
	
	# Show completion message
	_show_tutorial_tooltip(
		"Tutorial Complete!",
		"Continue exploring and restoring the coast. Good luck!",
		"🎉"
	)
	
	# Hide tooltip after a delay
	await get_tree().create_timer(3.0).timeout
	_hide_tutorial_tooltip()
	
	tutorial_completed.emit()
	
	print("Tutorial completed!")


func skip_tutorial() -> void:
	"""Skip the tutorial"""
	tutorial_active = false
	tutorial_completed_flag = true
	current_step = TutorialStep.COMPLETE
	
	if GameManager:
		GameManager.tutorial_completed = true
	
	_hide_tutorial_tooltip()
	
	tutorial_skipped.emit()
	
	print("Tutorial skipped")


## Condition checks for tutorial steps

func _check_movement() -> bool:
	"""Check if player has moved"""
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_node_or_null("/root/GameWorld/Player")
	
	if player and player.has_method("get_movement_direction"):
		var direction = player.get_movement_direction()
		return direction.length() > 0.1
	
	return false


func _check_journal_opened() -> bool:
	"""Check if journal UI was opened"""
	var journal = get_tree().get_first_node_in_group("journal_ui")
	if journal and journal.has_method("is_visible"):
		return journal.is_visible()
	return false


func _check_at_dock() -> bool:
	"""Check if player is near the dock"""
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_node_or_null("/root/GameWorld/Player")
	
	if player:
		var dock_position = Vector2(300, 200)  # TODO: Use actual dock position
		var distance = player.global_position.distance_to(dock_position)
		return distance < 100
	
	return false


func _check_dialogue_started() -> bool:
	"""Check if dialogue with NPC started"""
	if GameManager:
		return GameManager.current_state == GameManager.GameState.DIALOGUE
	return false


func _check_inventory_opened() -> bool:
	"""Check if inventory UI was opened"""
	var inventory = get_tree().get_first_node_in_group("inventory_ui")
	if inventory and inventory.has_method("is_visible"):
		return inventory.is_visible()
	return false


func _check_first_plant() -> bool:
	"""Check if player planted their first plant"""
	if GameManager:
		return GameManager.first_plant_done
	return false


func _check_dashboard_opened() -> bool:
	"""Check if carbon dashboard was opened"""
	var dashboard = get_tree().get_first_node_in_group("carbon_dashboard")
	if dashboard and dashboard.has_method("is_visible"):
		return dashboard.is_visible()
	return false


## Save/Load

func get_save_data() -> Dictionary:
	"""Get save data"""
	return {
		"tutorial_completed": tutorial_completed_flag,
		"current_step": current_step
	}


func load_save_data(data: Dictionary) -> void:
	"""Load save data"""
	tutorial_completed_flag = data.get("tutorial_completed", false)
	current_step = data.get("current_step", TutorialStep.WELCOME)
	
	if tutorial_completed_flag:
		tutorial_active = false
