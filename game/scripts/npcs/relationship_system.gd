extends Node

signal relationship_changed(npc_name: String, new_value: int, tier: String)

const TIER_STRANGER = "Stranger"
const TIER_ACQUAINTANCE = "Acquaintance"
const TIER_FRIEND = "Friend"
const TIER_CLOSE_FRIEND = "Close Friend"
const TIER_BEST_FRIEND = "Best Friend"

const MILESTONE_ACQUAINTANCE = 20
const MILESTONE_FRIEND = 40
const MILESTONE_CLOSE_FRIEND = 60
const MILESTONE_BEST_FRIEND = 80
const MILESTONE_MAX = 100

var relationships: Dictionary = {}

func modify_relationship(npc_name: String, amount: int) -> void:
	var current_value = relationships.get(npc_name, 0)
	var previous_tier = get_relationship_tier(npc_name)
	
	var new_value = clamp(current_value + amount, 0, MILESTONE_MAX)
	relationships[npc_name] = new_value
	
	var new_tier = get_relationship_tier(npc_name)
	
	relationship_changed.emit(npc_name, new_value, new_tier)
	
	if previous_tier != new_tier:
		print("Relationship with %s changed to %s (%d)" % [npc_name, new_tier, new_value])

func get_relationship(npc_name: String) -> int:
	return relationships.get(npc_name, 0)

func get_relationship_tier(npc_name: String) -> String:
	var value = get_relationship(npc_name)
	
	if value >= MILESTONE_MAX:
		return TIER_BEST_FRIEND
	elif value >= MILESTONE_BEST_FRIEND:
		return TIER_CLOSE_FRIEND
	elif value >= MILESTONE_CLOSE_FRIEND:
		return TIER_FRIEND
	elif value >= MILESTONE_FRIEND:
		return TIER_ACQUAINTANCE
	elif value >= MILESTONE_ACQUAINTANCE:
		return TIER_ACQUAINTANCE
	else:
		return TIER_STRANGER

func set_relationship(npc_name: String, value: int) -> void:
	var clamped_value = clamp(value, 0, MILESTONE_MAX)
	relationships[npc_name] = clamped_value
	var tier = get_relationship_tier(npc_name)
	relationship_changed.emit(npc_name, clamped_value, tier)

func get_all_relationships() -> Dictionary:
	return relationships.duplicate()

func reset_relationship(npc_name: String) -> void:
	if relationships.has(npc_name):
		relationships.erase(npc_name)
		relationship_changed.emit(npc_name, 0, TIER_STRANGER)

func get_save_data() -> Dictionary:
	"""Get relationship data for saving"""
	return {
		"relationships": relationships
	}

func load_save_data(data: Dictionary) -> void:
	"""Load relationship data from save"""
	relationships = data.get("relationships", {})
