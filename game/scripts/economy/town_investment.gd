extends Node
class_name TownInvestment
## Town building investment system
## Manages construction of town improvements with gold costs and effects

signal building_started(building_id: String)
signal building_completed(building_id: String)
signal building_unlocked(building_id: String)

enum BuildingState {
	NOT_BUILT,
	BUILDING,
	COMPLETE
}

# Building definitions
const BUILDINGS: Dictionary = {
	"dock_repair": {
		"name": "Dock Repair",
		"description": "Repair the old dock to unlock boat access to deeper zones.",
		"cost": 500,
		"construction_days": 3,
		"effects": ["unlock_boat", "unlock_reef_access"],
		"icon_color": Color(0.6, 0.4, 0.2)
	},
	"marine_lab": {
		"name": "Marine Lab",
		"description": "Build a marine research laboratory. Increases research speed by 25% and unlocks Dr. Marina's advanced quests.",
		"cost": 1500,
		"construction_days": 7,
		"effects": ["research_speed_bonus", "unlock_advanced_quests"],
		"icon_color": Color(0.4, 0.6, 0.7)
	},
	"eco_tourism": {
		"name": "Eco-Tourism Center",
		"description": "Establish an eco-tourism center. Generates passive income based on ecosystem biodiversity.",
		"cost": 2500,
		"construction_days": 5,
		"effects": ["passive_income", "tourism_events"],
		"icon_color": Color(0.5, 0.7, 0.4)
	},
	"community_center": {
		"name": "Community Center",
		"description": "Build a community gathering space. Unlocks festivals and NPC group events.",
		"cost": 1000,
		"construction_days": 4,
		"effects": ["unlock_festivals", "npc_events"],
		"icon_color": Color(0.8, 0.6, 0.3)
	},
	"nursery": {
		"name": "Nursery Building",
		"description": "Construct a seedling nursery. Unlocks nursery mechanics for faster, safer seedling growth.",
		"cost": 750,
		"construction_days": 3,
		"effects": ["unlock_nursery", "seedling_bonuses"],
		"icon_color": Color(0.4, 0.7, 0.3)
	}
}

# State tracking
var building_states: Dictionary = {}
var construction_progress: Dictionary = {}  # Building ID -> days remaining
var unlocked_buildings: Array[String] = []

# Effects tracking
var research_speed_multiplier: float = 1.0
var passive_income_enabled: bool = false
var boat_unlocked: bool = false
var nursery_unlocked: bool = false
var festivals_unlocked: bool = false


func _ready() -> void:
	# Initialize all buildings to NOT_BUILT
	for building_id in BUILDINGS.keys():
		building_states[building_id] = BuildingState.NOT_BUILT
	
	# Connect to TimeManager for daily updates
	if TimeManager:
		TimeManager.day_changed.connect(_on_day_changed)


func _on_day_changed(_day: int) -> void:
	"""Process construction progress each day"""
	var completed_buildings = []
	
	for building_id in construction_progress.keys():
		construction_progress[building_id] -= 1
		
		if construction_progress[building_id] <= 0:
			completed_buildings.append(building_id)
	
	# Complete buildings
	for building_id in completed_buildings:
		complete_building(building_id)


func can_build(building_id: String) -> bool:
	"""Check if a building can be constructed"""
	if building_id not in BUILDINGS:
		return false
	
	if building_states.get(building_id, BuildingState.NOT_BUILT) != BuildingState.NOT_BUILT:
		return false
	
	var building = BUILDINGS[building_id]
	return GameManager.gold >= building.cost


func start_building(building_id: String) -> bool:
	"""Begin construction of a building"""
	if not can_build(building_id):
		return false
	
	var building = BUILDINGS[building_id]
	
	# Spend gold
	if not GameManager.spend_gold(building.cost):
		return false
	
	# Set building state
	building_states[building_id] = BuildingState.BUILDING
	construction_progress[building_id] = building.construction_days
	
	building_started.emit(building_id)
	print("Started building: ", building.name)
	
	return true


func complete_building(building_id: String) -> void:
	"""Complete a building and apply its effects"""
	if building_id not in BUILDINGS:
		return
	
	building_states[building_id] = BuildingState.COMPLETE
	construction_progress.erase(building_id)
	
	if building_id not in unlocked_buildings:
		unlocked_buildings.append(building_id)
	
	# Apply effects
	var building = BUILDINGS[building_id]
	for effect in building.effects:
		apply_effect(effect)
	
	building_completed.emit(building_id)
	building_unlocked.emit(building_id)
	print("Completed building: ", building.name)


func apply_effect(effect: String) -> void:
	"""Apply a building effect"""
	match effect:
		"unlock_boat":
			boat_unlocked = true
		"unlock_reef_access":
			# Unlock reef edge zone
			if GameManager:
				GameManager.unlock_zone("reef_edge")
		"research_speed_bonus":
			research_speed_multiplier = 1.25
		"unlock_advanced_quests":
			# Signal that advanced quests are available
			pass
		"passive_income":
			passive_income_enabled = true
		"tourism_events":
			# Enable tourism event system
			pass
		"unlock_festivals":
			festivals_unlocked = true
		"npc_events":
			# Enable NPC group events
			pass
		"unlock_nursery":
			nursery_unlocked = true
		"seedling_bonuses":
			# Nursery bonuses applied in NurserySystem
			pass


func is_building_complete(building_id: String) -> bool:
	"""Check if a building is complete"""
	return building_states.get(building_id, BuildingState.NOT_BUILT) == BuildingState.COMPLETE


func is_building_in_progress(building_id: String) -> bool:
	"""Check if a building is currently being built"""
	return building_states.get(building_id, BuildingState.NOT_BUILT) == BuildingState.BUILDING


func get_building_state(building_id: String) -> BuildingState:
	"""Get the current state of a building"""
	return building_states.get(building_id, BuildingState.NOT_BUILT)


func get_construction_days_remaining(building_id: String) -> int:
	"""Get days remaining for a building under construction"""
	return construction_progress.get(building_id, 0)


func get_building_info(building_id: String) -> Dictionary:
	"""Get all information about a building"""
	if building_id not in BUILDINGS:
		return {}
	
	var info = BUILDINGS[building_id].duplicate()
	info["state"] = building_states.get(building_id, BuildingState.NOT_BUILT)
	info["days_remaining"] = get_construction_days_remaining(building_id)
	return info


func get_all_buildings() -> Array:
	"""Get list of all building IDs"""
	return BUILDINGS.keys()


func get_research_speed_multiplier() -> float:
	"""Get current research speed multiplier from buildings"""
	return research_speed_multiplier


func is_passive_income_enabled() -> bool:
	"""Check if passive income from tourism is enabled"""
	return passive_income_enabled


func is_boat_unlocked() -> bool:
	"""Check if boat is unlocked"""
	return boat_unlocked


func is_nursery_unlocked() -> bool:
	"""Check if nursery is unlocked"""
	return nursery_unlocked


func are_festivals_unlocked() -> bool:
	"""Check if festivals are unlocked"""
	return festivals_unlocked


func get_save_data() -> Dictionary:
	"""Get all data for saving"""
	return {
		"building_states": building_states,
		"construction_progress": construction_progress,
		"unlocked_buildings": unlocked_buildings,
		"research_speed_multiplier": research_speed_multiplier,
		"passive_income_enabled": passive_income_enabled,
		"boat_unlocked": boat_unlocked,
		"nursery_unlocked": nursery_unlocked,
		"festivals_unlocked": festivals_unlocked
	}


func load_save_data(data: Dictionary) -> void:
	"""Load saved data"""
	building_states = data.get("building_states", {})
	construction_progress = data.get("construction_progress", {})
	unlocked_buildings = data.get("unlocked_buildings", [])
	research_speed_multiplier = data.get("research_speed_multiplier", 1.0)
	passive_income_enabled = data.get("passive_income_enabled", false)
	boat_unlocked = data.get("boat_unlocked", false)
	nursery_unlocked = data.get("nursery_unlocked", false)
	festivals_unlocked = data.get("festivals_unlocked", false)
