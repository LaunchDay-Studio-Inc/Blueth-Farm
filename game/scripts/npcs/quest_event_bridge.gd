extends Node
## Quest Event Bridge
## Loads quest resources, connects gameplay events to quest objectives, and manages quest chains

@onready var quest_system = get_node_or_null("../QuestSystem")
@onready var tile_map_manager = get_node_or_null("../TileMapManager")
@onready var weather_system = get_node_or_null("../WeatherSystem")

const QUEST_RESOURCES_PATH = "res://resources/quests/"


func _ready() -> void:
	# Wait one frame for all systems to initialize
	await get_tree().process_frame
	
	# Load and register all quest resources
	_load_quest_resources()
	
	# Connect to gameplay signals
	_connect_signals()
	
	# Auto-start eligible quests
	_auto_start_quests()


func _load_quest_resources() -> void:
	"""Load all .tres quest files from resources/quests/ and register them"""
	if not quest_system:
		push_error("QuestSystem not found - cannot load quest resources")
		return
	
	var dir = DirAccess.open(QUEST_RESOURCES_PATH)
	if not dir:
		push_error("Cannot open quest resources directory: %s" % QUEST_RESOURCES_PATH)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var loaded_count = 0
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var file_path = QUEST_RESOURCES_PATH + file_name
			var quest_resource = load(file_path) as QuestData
			
			if quest_resource:
				var quest_dict = _convert_quest_resource_to_dict(quest_resource)
				quest_system.register_quest(quest_dict)
				loaded_count += 1
				print("Loaded quest: ", quest_resource.quest_id, " - ", quest_resource.title)
			else:
				push_warning("Failed to load quest resource: %s" % file_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	print("Quest resources loaded: ", loaded_count)


func _convert_quest_resource_to_dict(resource: QuestData) -> Dictionary:
	"""Convert QuestData resource to Dictionary format expected by QuestSystem"""
	var quest_dict = {
		"id": resource.quest_id,
		"title": resource.title,
		"description": resource.description,
		"objectives": [],
		"rewards": {
			"gold": resource.reward_gold,
			"research_points": resource.reward_research_points,
			"items": resource.reward_items,
			"journal_entry": resource.reward_journal_entry,
			"unlocks": resource.reward_unlocks
		},
		"prerequisite_quests": resource.prerequisite_quests,
		"required_year": resource.required_year,
		"is_story_quest": resource.is_story_quest,
		"given_by_npc": resource.given_by_npc,
		"auto_triggered": resource.auto_triggered
	}
	
	# Convert objectives array
	for obj in resource.objectives:
		var objective_dict = {
			"type": obj.get("type", ""),
			"description": _generate_objective_description(obj),
			"target": _get_objective_target(obj),
			"species": obj.get("species", ""),
			"npc_id": obj.get("npc_id", ""),
			"amount": obj.get("amount", 0.0),
			"item": obj.get("item", ""),
			"location": obj.get("location", "")
		}
		quest_dict["objectives"].append(objective_dict)
	
	return quest_dict


func _generate_objective_description(objective: Dictionary) -> String:
	"""Generate a human-readable description from objective data"""
	var type = objective.get("type", "")
	
	match type:
		"plant":
			var species = objective.get("species", "plants")
			var count = objective.get("count", 1)
			return "Plant %d %s" % [count, species]
		"harvest":
			var species = objective.get("species", "plants")
			var count = objective.get("count", 1)
			return "Harvest %d %s" % [count, species]
		"visit_npc":
			var npc_id = objective.get("npc_id", "NPC")
			return "Visit %s" % npc_id.replace("_", " ").capitalize()
		"carbon_goal":
			var amount = objective.get("amount", 0.0)
			return "Sequester %.1f tonnes of CO₂" % amount
		"survive_storm":
			return "Survive a storm"
		"test_water":
			var count = objective.get("count", 1)
			return "Test water quality on %d tiles" % count
		"explore":
			var location = objective.get("location", "area")
			return "Explore the %s" % location
		"discover":
			var item = objective.get("item", "item")
			return "Discover %s" % item
		_:
			return objective.get("description", "Complete objective")


func _get_objective_target(objective: Dictionary) -> int:
	"""Get the target/count for an objective"""
	var type = objective.get("type", "")
	
	# For objectives that track counts
	if type in ["plant", "harvest", "test_water"]:
		return objective.get("count", 1)
	
	# For objectives that are boolean (complete/incomplete)
	if type in ["visit_npc", "survive_storm", "explore", "discover"]:
		return 1
	
	# For carbon goals, we'll use the amount directly (quest system will handle float)
	if type == "carbon_goal":
		return int(objective.get("amount", 1.0))
	
	return 1


func _connect_signals() -> void:
	"""Connect to all relevant gameplay signals"""
	print("QuestEventBridge: Connecting gameplay signals...")
	
	# TileMapManager signals for planting and harvesting
	if tile_map_manager:
		if tile_map_manager.has_signal("tile_planted"):
			tile_map_manager.tile_planted.connect(_on_tile_planted)
			print("  Connected to tile_planted signal")
		
		if tile_map_manager.has_signal("tile_harvested"):
			tile_map_manager.tile_harvested.connect(_on_tile_harvested)
			print("  Connected to tile_harvested signal")
	
	# CarbonManager signals for carbon goals
	if CarbonManager and CarbonManager.has_signal("carbon_updated"):
		CarbonManager.carbon_updated.connect(_on_carbon_updated)
		print("  Connected to carbon_updated signal")
	
	# WeatherSystem signals for storm survival
	if weather_system and weather_system.has_signal("storm_ended"):
		weather_system.storm_ended.connect(_on_storm_ended)
		print("  Connected to storm_ended signal")
	
	# QuestSystem signals for quest completion
	if quest_system and quest_system.has_signal("quest_completed"):
		quest_system.quest_completed.connect(_on_quest_completed)
		print("  Connected to quest_completed signal")
	
	# DialogueSystem signals for NPC visits
	var dialogue_system = get_node_or_null("/root/DialogueSystem")
	if not dialogue_system:
		dialogue_system = get_tree().get_first_node_in_group("dialogue_system")
	
	if dialogue_system and dialogue_system.has_signal("dialogue_ended"):
		dialogue_system.dialogue_ended.connect(_on_dialogue_ended)
		print("  Connected to dialogue_ended signal")
	
	# Also try to connect to DialogueBox directly as a fallback
	var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")
	if dialogue_box and dialogue_box.has_signal("dialogue_ended"):
		if not dialogue_system:  # Only connect if DialogueSystem didn't work
			dialogue_box.dialogue_ended.connect(_on_dialogue_ended)
			print("  Connected to DialogueBox dialogue_ended signal")
	
	print("QuestEventBridge: Signal connections complete")


func _auto_start_quests() -> void:
	"""Auto-start quests with no prerequisites and matching year requirements"""
	if not quest_system:
		return
	
	var current_year = GameManager.current_year if GameManager else 1
	
	for quest_id in quest_system.quest_definitions.keys():
		var quest_def = quest_system.quest_definitions[quest_id]
		var prerequisites = quest_def.get("prerequisite_quests", [])
		var required_year = quest_def.get("required_year", 1)
		
		# Check if quest can be auto-started
		if prerequisites.is_empty() and required_year <= current_year:
			# Don't start if already active or completed
			if not quest_system.active_quests.has(quest_id) and not quest_system.is_quest_completed(quest_id):
				quest_system.start_quest(quest_id)
				print("Auto-started quest: ", quest_id)


# Signal handlers for gameplay events

func _on_tile_planted(tile_pos: Vector2i, species: String) -> void:
	"""Handle plant placed event - update plant objectives"""
	if not quest_system:
		return
	
	for quest_id in quest_system.active_quests.keys():
		var quest = quest_system.active_quests[quest_id]
		var objectives = quest.get("objectives", [])
		
		for i in range(objectives.size()):
			var objective = objectives[i]
			if objective.get("completed", false):
				continue
			
			# Check if this is a plant objective
			var obj_def = _get_objective_definition(quest_id, i)
			if not obj_def:
				continue
			
			if obj_def.get("type") == "plant":
				var target_species = obj_def.get("species", "")
				# Match if species matches or if target is empty (any species)
				if target_species.is_empty() or species.contains(target_species) or target_species.contains(species):
					quest_system.update_objective(quest_id, i, 1)
					print("Quest objective updated: ", quest_id, " - planted ", species)


func _on_tile_harvested(tile_pos: Vector2i) -> void:
	"""Handle tile harvested event - update harvest objectives"""
	if not quest_system:
		return
	
	# Get the tile data to know what species was harvested
	var tile = null
	if tile_map_manager and tile_map_manager.has_method("get_tile_at"):
		tile = tile_map_manager.get_tile_at(tile_pos)
	
	for quest_id in quest_system.active_quests.keys():
		var quest = quest_system.active_quests[quest_id]
		var objectives = quest.get("objectives", [])
		
		for i in range(objectives.size()):
			var objective = objectives[i]
			if objective.get("completed", false):
				continue
			
			var obj_def = _get_objective_definition(quest_id, i)
			if not obj_def:
				continue
			
			if obj_def.get("type") == "harvest":
				# For now, count all harvests (could filter by species if tile data available)
				quest_system.update_objective(quest_id, i, 1)
				print("Quest objective updated: ", quest_id, " - harvested tile")


func _on_carbon_updated(total_co2: float, daily_rate: float) -> void:
	"""Handle carbon update event - update carbon_goal objectives"""
	if not quest_system:
		return
	
	for quest_id in quest_system.active_quests.keys():
		var quest = quest_system.active_quests[quest_id]
		var objectives = quest.get("objectives", [])
		
		for i in range(objectives.size()):
			var objective = objectives[i]
			if objective.get("completed", false):
				continue
			
			var obj_def = _get_objective_definition(quest_id, i)
			if not obj_def:
				continue
			
			if obj_def.get("type") == "carbon_goal":
				var target_amount = obj_def.get("amount", 0.0)
				# Check if we've reached the target
				if total_co2 >= target_amount:
					# Set progress to target to complete the objective
					var current_progress = objective.get("current", 0)
					var target_progress = objective.get("target", 1)
					var needed = target_progress - current_progress
					if needed > 0:
						quest_system.update_objective(quest_id, i, needed)
						print("Quest objective updated: ", quest_id, " - carbon goal reached: ", total_co2, " tonnes")


func _on_storm_ended(damage_prevented: float) -> void:
	"""Handle storm ended event - update survive_storm objectives"""
	if not quest_system:
		return
	
	for quest_id in quest_system.active_quests.keys():
		var quest = quest_system.active_quests[quest_id]
		var objectives = quest.get("objectives", [])
		
		for i in range(objectives.size()):
			var objective = objectives[i]
			if objective.get("completed", false):
				continue
			
			var obj_def = _get_objective_definition(quest_id, i)
			if not obj_def:
				continue
			
			if obj_def.get("type") == "survive_storm":
				quest_system.update_objective(quest_id, i, 1)
				print("Quest objective updated: ", quest_id, " - survived storm")


var last_npc_talked_to: String = ""

func _on_dialogue_ended() -> void:
	"""Handle dialogue ended event - update visit_npc objectives"""
	if not quest_system:
		return
	
	# Try to find out which NPC we just talked to
	var npc_id = _get_last_npc_interacted()
	if npc_id.is_empty():
		return
	
	for quest_id in quest_system.active_quests.keys():
		var quest = quest_system.active_quests[quest_id]
		var objectives = quest.get("objectives", [])
		
		for i in range(objectives.size()):
			var objective = objectives[i]
			if objective.get("completed", false):
				continue
			
			var obj_def = _get_objective_definition(quest_id, i)
			if not obj_def:
				continue
			
			if obj_def.get("type") == "visit_npc":
				var target_npc = obj_def.get("npc_id", "")
				if target_npc == npc_id:
					quest_system.update_objective(quest_id, i, 1)
					print("Quest objective updated: ", quest_id, " - visited ", npc_id)


func _get_last_npc_interacted() -> String:
	"""Try to determine which NPC the player just talked to"""
	# Check DialogueBox for current NPC
	var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")
	if dialogue_box and dialogue_box.has_method("get_current_npc_id"):
		var npc_id = dialogue_box.get_current_npc_id()
		if npc_id:
			return npc_id
	
	# Check DialogueSystem
	var dialogue_system = get_node_or_null("/root/DialogueSystem")
	if not dialogue_system:
		dialogue_system = get_tree().get_first_node_in_group("dialogue_system")
	
	if dialogue_system and dialogue_system.has_method("get_current_speaker"):
		return dialogue_system.get_current_speaker()
	
	# Fallback: use cached value
	return last_npc_talked_to


func set_last_npc_talked_to(npc_id: String) -> void:
	"""Set the last NPC talked to (called by NPC controller)"""
	last_npc_talked_to = npc_id


func _on_quest_completed(quest_id: String) -> void:
	"""Handle quest completion - auto-start next quests in chain if prerequisites met"""
	if not quest_system:
		return
	
	print("Quest completed: ", quest_id, " - checking for next quests in chain...")
	
	var current_year = GameManager.current_year if GameManager else 1
	
	# Check all quest definitions for quests that can now be started
	for check_quest_id in quest_system.quest_definitions.keys():
		# Skip if already active or completed
		if quest_system.active_quests.has(check_quest_id):
			continue
		if quest_system.is_quest_completed(check_quest_id):
			continue
		
		var quest_def = quest_system.quest_definitions[check_quest_id]
		var prerequisites = quest_def.get("prerequisite_quests", [])
		var required_year = quest_def.get("required_year", 1)
		
		# Check if year requirement is met
		if required_year > current_year:
			continue
		
		# Check if all prerequisites are completed
		var all_prerequisites_met = true
		for prereq_id in prerequisites:
			if not quest_system.is_quest_completed(prereq_id):
				all_prerequisites_met = false
				break
		
		# Start the quest if all conditions are met
		if all_prerequisites_met:
			quest_system.start_quest(check_quest_id)
			print("  Auto-started next quest: ", check_quest_id)


func _get_objective_definition(quest_id: String, objective_index: int) -> Dictionary:
	"""Get the original objective definition from quest_definitions"""
	if not quest_system or not quest_system.quest_definitions.has(quest_id):
		return {}
	
	var quest_def = quest_system.quest_definitions[quest_id]
	var objectives = quest_def.get("objectives", [])
	
	if objective_index < 0 or objective_index >= objectives.size():
		return {}
	
	return objectives[objective_index]
