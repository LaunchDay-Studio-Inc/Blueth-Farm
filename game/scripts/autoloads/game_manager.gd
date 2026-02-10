extends Node
## Global game state manager
## Handles game state, progression, and global game logic

signal game_state_changed(new_state: GameState)
signal year_changed(new_year: int)
signal zone_unlocked(zone_name: String)

enum GameState {
	MAIN_MENU,
	PLAYING,
	PAUSED,
	DIALOGUE,
	TRANSITION
}

# Game state
var current_state: GameState = GameState.MAIN_MENU
var current_year: int = 1
var current_zone: String = "shallows"

# Player stats
var gold: int = 100
var research_points: int = 0

# Unlocked zones
var unlocked_zones: Array[String] = ["shallows"]

# Tutorial flags
var tutorial_completed: bool = false
var first_plant_done: bool = false
var first_harvest_done: bool = false

# Game progression flags
var zones_data: Dictionary = {
	"shallows": {"unlocked": true, "year_unlocked": 1},
	"mudflats": {"unlocked": false, "year_unlocked": 2},
	"estuary": {"unlocked": false, "year_unlocked": 3},
	"reef_edge": {"unlocked": false, "year_unlocked": 4}
}


func _ready() -> void:
	print("GameManager initialized")


func set_game_state(new_state: GameState) -> void:
	"""Change the game state"""
	if current_state != new_state:
		current_state = new_state
		game_state_changed.emit(new_state)
		print("Game state changed to: ", GameState.keys()[new_state])


func is_state(state: GameState) -> bool:
	"""Check if current state matches"""
	return current_state == state


func add_gold(amount: int) -> void:
	"""Add gold to player"""
	gold += amount
	print("Gold added: +", amount, " (Total: ", gold, ")")


func spend_gold(amount: int) -> bool:
	"""Spend gold if player has enough"""
	if gold >= amount:
		gold -= amount
		print("Gold spent: -", amount, " (Remaining: ", gold, ")")
		return true
	else:
		print("Not enough gold! Need: ", amount, " Have: ", gold)
		return false


func add_research_points(amount: int) -> void:
	"""Add research points"""
	research_points += amount
	print("Research points added: +", amount, " (Total: ", research_points, ")")


func spend_research_points(amount: int) -> bool:
	"""Spend research points if player has enough"""
	if research_points >= amount:
		research_points -= amount
		print("Research points spent: -", amount, " (Remaining: ", research_points, ")")
		return true
	return false


func unlock_zone(zone_name: String) -> void:
	"""Unlock a new zone"""
	if zone_name in zones_data and not zones_data[zone_name].unlocked:
		zones_data[zone_name].unlocked = true
		zones_data[zone_name].year_unlocked = current_year
		if zone_name not in unlocked_zones:
			unlocked_zones.append(zone_name)
		zone_unlocked.emit(zone_name)
		print("Zone unlocked: ", zone_name)


func is_zone_unlocked(zone_name: String) -> bool:
	"""Check if a zone is unlocked"""
	return zone_name in zones_data and zones_data[zone_name].unlocked


func advance_year() -> void:
	"""Advance to the next year"""
	current_year += 1
	year_changed.emit(current_year)
	print("Advanced to Year ", current_year)
	
	# Auto-unlock zones based on year
	for zone_name in zones_data:
		var zone = zones_data[zone_name]
		if not zone.unlocked and current_year >= zone.year_unlocked:
			unlock_zone(zone_name)


func get_save_data() -> Dictionary:
	"""Get all game manager data for saving"""
	return {
		"current_state": current_state,
		"current_year": current_year,
		"current_zone": current_zone,
		"gold": gold,
		"research_points": research_points,
		"unlocked_zones": unlocked_zones,
		"tutorial_completed": tutorial_completed,
		"first_plant_done": first_plant_done,
		"first_harvest_done": first_harvest_done,
		"zones_data": zones_data
	}


func load_save_data(data: Dictionary) -> void:
	"""Load game manager data from save"""
	current_state = data.get("current_state", GameState.MAIN_MENU)
	current_year = data.get("current_year", 1)
	current_zone = data.get("current_zone", "shallows")
	gold = data.get("gold", 100)
	research_points = data.get("research_points", 0)
	unlocked_zones = data.get("unlocked_zones", ["shallows"])
	tutorial_completed = data.get("tutorial_completed", false)
	first_plant_done = data.get("first_plant_done", false)
	first_harvest_done = data.get("first_harvest_done", false)
	zones_data = data.get("zones_data", zones_data)
