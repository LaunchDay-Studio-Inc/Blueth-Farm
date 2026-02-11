extends Node

signal quest_started(quest_id: String)
signal quest_updated(quest_id: String)
signal quest_completed(quest_id: String)

enum QuestState {
	NOT_STARTED,
	ACTIVE,
	COMPLETED,
	FAILED
}

var quest_definitions: Dictionary = {}
var active_quests: Dictionary = {}
var completed_quests: Dictionary = {}  # Changed to Dictionary to store full quest data
var failed_quests: Array = []

func register_quest(quest_data: Dictionary) -> void:
	var quest_id = quest_data.get("id", "")
	if quest_id.is_empty():
		push_error("Quest data missing 'id' field")
		return
	
	quest_definitions[quest_id] = quest_data

func start_quest(quest_id: String) -> void:
	if not quest_definitions.has(quest_id):
		push_error("Quest not found: %s" % quest_id)
		return
	
	if active_quests.has(quest_id):
		push_warning("Quest already active: %s" % quest_id)
		return
	
	if completed_quests.has(quest_id):
		push_warning("Quest already completed: %s" % quest_id)
		return
	
	var quest_def = quest_definitions[quest_id].duplicate(true)
	var objectives = quest_def.get("objectives", [])
	
	var quest_state = {
		"id": quest_id,
		"title": quest_def.get("title", ""),
		"description": quest_def.get("description", ""),
		"objectives": [],
		"rewards": quest_def.get("rewards", {}),
		"state": QuestState.ACTIVE
	}
	
	for objective in objectives:
		quest_state["objectives"].append({
			"description": objective.get("description", ""),
			"target": objective.get("target", 1),
			"current": 0,
			"completed": false
		})
	
	active_quests[quest_id] = quest_state
	quest_started.emit(quest_id)

func update_objective(quest_id: String, objective_index: int, progress: int = 1) -> void:
	if not active_quests.has(quest_id):
		push_warning("Quest not active: %s" % quest_id)
		return
	
	var quest = active_quests[quest_id]
	var objectives = quest["objectives"]
	
	if objective_index < 0 or objective_index >= objectives.size():
		push_error("Invalid objective index: %d for quest %s" % [objective_index, quest_id])
		return
	
	var objective = objectives[objective_index]
	
	if objective["completed"]:
		return
	
	objective["current"] = min(objective["current"] + progress, objective["target"])
	
	if objective["current"] >= objective["target"]:
		objective["completed"] = true
	
	quest_updated.emit(quest_id)
	
	if _all_objectives_completed(quest_id):
		complete_quest(quest_id)

func complete_quest(quest_id: String) -> void:
	if not active_quests.has(quest_id):
		push_warning("Quest not active: %s" % quest_id)
		return
	
	var quest = active_quests[quest_id]
	quest["state"] = QuestState.COMPLETED
	
	_grant_rewards(quest["rewards"])
	
	completed_quests[quest_id] = quest  # Store the full quest data
	active_quests.erase(quest_id)
	
	quest_completed.emit(quest_id)

func fail_quest(quest_id: String) -> void:
	if not active_quests.has(quest_id):
		push_warning("Quest not active: %s" % quest_id)
		return
	
	var quest = active_quests[quest_id]
	quest["state"] = QuestState.FAILED
	
	failed_quests.append(quest_id)
	active_quests.erase(quest_id)

func get_quest_state(quest_id: String) -> int:
	if active_quests.has(quest_id):
		return QuestState.ACTIVE
	elif completed_quests.has(quest_id):
		return QuestState.COMPLETED
	elif failed_quests.has(quest_id):
		return QuestState.FAILED
	else:
		return QuestState.NOT_STARTED

func get_active_quest(quest_id: String) -> Dictionary:
	return active_quests.get(quest_id, {})

func get_all_active_quests() -> Dictionary:
	return active_quests.duplicate()

## Get active quests as an array (UI-friendly format)
func get_active_quests() -> Array:
	var quest_array: Array = []
	for quest_id in active_quests.keys():
		var quest = active_quests[quest_id].duplicate()
		quest["quest_id"] = quest_id
		quest_array.append(quest)
	return quest_array

## Get completed quests with full details
func get_completed_quests() -> Array:
	var quest_array: Array = []
	for quest_id in completed_quests.keys():
		var quest = completed_quests[quest_id].duplicate()
		quest["quest_id"] = quest_id
		quest_array.append(quest)
	return quest_array

## Get a specific quest by ID (active or completed)
func get_quest(quest_id: String) -> Dictionary:
	# Check if quest is active
	if active_quests.has(quest_id):
		var quest = active_quests[quest_id].duplicate()
		quest["quest_id"] = quest_id
		return quest
	
	# Check if quest is completed
	if completed_quests.has(quest_id):
		var quest = completed_quests[quest_id].duplicate()
		quest["quest_id"] = quest_id
		return quest
	
	# Quest not found or not started
	return {}

func is_quest_completed(quest_id: String) -> bool:
	return completed_quests.has(quest_id)

func _all_objectives_completed(quest_id: String) -> bool:
	if not active_quests.has(quest_id):
		return false
	
	var quest = active_quests[quest_id]
	var objectives = quest["objectives"]
	
	for objective in objectives:
		if not objective["completed"]:
			return false
	
	return true

func _grant_rewards(rewards: Dictionary) -> void:
	var gold = rewards.get("gold", 0)
	var research_points = rewards.get("research_points", 0)

	if gold > 0 and GameManager:
		GameManager.add_money(gold)

	if research_points > 0 and GameManager and GameManager.has_method("add_research_points"):
		GameManager.add_research_points(research_points)

	var items = rewards.get("items", [])
	for item in items:
		print("Rewarding item: %s" % item)


func get_save_data() -> Dictionary:
	"""Get quest data for saving"""
	return {
		"active_quests": active_quests,
		"completed_quests": completed_quests,
		"failed_quests": failed_quests
	}


func load_save_data(data: Dictionary) -> void:
	"""Load quest data from save"""
	active_quests = data.get("active_quests", {})
	completed_quests = data.get("completed_quests", {})
	failed_quests = data.get("failed_quests", [])
