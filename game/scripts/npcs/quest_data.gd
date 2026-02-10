extends Resource
class_name QuestData
## Quest resource defining objectives, rewards, and prerequisites

@export var quest_id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""

# Objectives: Array of dictionaries with structure:
# {"type": "plant", "species": "eelgrass", "count": 5, "current": 0, "complete": false}
# Types: plant, harvest, visit_npc, carbon_goal, build, discover, survive
@export var objectives: Array[Dictionary] = []

# Rewards
@export var reward_gold: int = 0
@export var reward_research_points: int = 0
@export var reward_items: Dictionary = {}  # item_id: quantity
@export var reward_journal_entry: String = ""  # entry_id to unlock
@export var reward_unlocks: String = ""  # What this quest unlocks

# Prerequisites
@export var prerequisite_quests: Array[String] = []
@export var required_year: int = 1
@export var is_story_quest: bool = true

# Quest giver
@export var given_by_npc: String = ""  # npc_id

# Auto-complete flag for triggered quests
@export var auto_triggered: bool = false
