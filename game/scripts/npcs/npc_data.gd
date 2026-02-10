extends Resource
class_name NPCData
## Resource defining an NPC character with dialogue, schedule, and preferences

@export var npc_id: String = ""
@export var display_name: String = ""
@export var role: String = ""
@export_multiline var description: String = ""
@export var location_zone: String = "shallows"

# Schedule: Dictionary mapping hour (int) to location (String)
# Example: {8: "dock", 12: "beach", 18: "home"}
@export var schedule: Dictionary = {}

# Placeholder visuals
@export var portrait_color: Color = Color.WHITE

# Gift preferences: Dictionary mapping item_id (String) to preference value (int)
# Positive values = liked gifts, negative = disliked, 0 = neutral
@export var gift_preferences: Dictionary = {}

# Dialogue trees: Dictionary mapping context/state (String) to dialogue tree (Dictionary)
# Keys: "intro", "daily", "quest_<quest_id>", "friendship_<level>"
@export var dialogue_trees: Dictionary = {}

# Initial friendship level (0-100)
@export var initial_friendship: int = 0

# Associated quests that this NPC gives
@export var associated_quests: Array[String] = []


func get_dialogue_for_context(context: String) -> Dictionary:
	"""Get dialogue tree for a specific context"""
	if context in dialogue_trees:
		return dialogue_trees[context]
	return {}


func get_location_at_hour(hour: int) -> String:
	"""Get NPC's location at a specific hour"""
	if hour in schedule:
		return schedule[hour]
	# Return default location if not in schedule
	return location_zone


func likes_gift(item_id: String) -> int:
	"""Get gift preference value for an item (-3 to +3)"""
	return gift_preferences.get(item_id, 0)
