extends Node
class_name JournalSystem
## Grandmother's journal discovery and narrative system
## The emotional heart of the game's story

signal journal_entry_unlocked(entry_id: String)
signal new_entry_discovered()

# Journal entry resource class definition
class JournalEntry extends Resource:
	@export var entry_id: String = ""
	@export var title: String = ""
	@export_multiline var content: String = ""
	@export var unlock_condition: String = ""
	@export var research_point_bonus: int = 0
	@export var unlocks: String = ""  # Optional unlock (recipe, species hint, etc.)
	@export var discovered: bool = false

var entries: Dictionary = {}  # entry_id -> JournalEntry
var discovered_entries: Array[String] = []
var total_entries: int = 0


func _ready() -> void:
	# Load all journal entries
	load_journal_entries()
	
	# Connect to various systems for unlock conditions
	if GameManager:
		GameManager.year_changed.connect(_check_milestone_unlocks)
	
	if TimeManager:
		TimeManager.season_changed.connect(_check_seasonal_unlocks)
	
	if EcosystemManager:
		EcosystemManager.wildlife_spawned.connect(_check_wildlife_unlocks)


func load_journal_entries() -> void:
	"""Load all journal entry resources from the resources/journal/ directory"""
	# This will be populated when we create the journal entry resources
	# For now, entries will be registered manually or loaded from resources
	pass


func register_entry(entry: JournalEntry) -> void:
	"""Register a journal entry"""
	if entry.entry_id.is_empty():
		push_error("Journal entry missing ID")
		return
	
	entries[entry.entry_id] = entry
	total_entries += 1


func check_unlock_condition(condition: String) -> bool:
	"""Check if an unlock condition is met"""
	# Parse condition string and check if it's satisfied
	# Conditions can be:
	# - "game_start" - unlocked at game start
	# - "first_plant" - first successful planting
	# - "first_harvest" - first harvest
	# - "carbon_1" - 1 tonne CO2 sequestered
	# - "storm_survived" - survived first storm
	# - "friendship_20_old_salt" - 20 friendship with Old Salt
	# - "year_3" - reached year 3
	# - "wildlife_dolphin" - first dolphin sighting
	# etc.
	
	if condition == "game_start":
		return true
	
	if condition == "first_plant":
		return GameManager and GameManager.first_plant_done
	
	if condition == "first_harvest":
		return GameManager and GameManager.first_harvest_done
	
	if condition.begins_with("carbon_"):
		var target = int(condition.split("_")[1])
		if CarbonManager:
			return CarbonManager.get_total_carbon_sequestered() >= target
	
	if condition.begins_with("year_"):
		var target_year = int(condition.split("_")[1])
		return GameManager and GameManager.current_year >= target_year
	
	if condition.begins_with("friendship_"):
		var parts = condition.split("_")
		if parts.size() >= 3:
			var target_level = int(parts[1])
			var npc_id = parts[2]
			# Check with RelationshipSystem
			# TODO: Implement when RelationshipSystem is integrated
			return false
	
	if condition.begins_with("wildlife_"):
		var wildlife_type = condition.split("_")[1]
		# Check with EcosystemManager
		# TODO: Check wildlife sightings
		return false
	
	return false


func try_unlock_entry(entry_id: String) -> bool:
	"""Attempt to unlock a journal entry if conditions are met"""
	if entry_id not in entries:
		return false
	
	var entry = entries[entry_id]
	
	# Already discovered
	if entry.discovered:
		return false
	
	# Check unlock condition
	if not check_unlock_condition(entry.unlock_condition):
		return false
	
	# Unlock the entry!
	unlock_entry(entry_id)
	return true


func unlock_entry(entry_id: String) -> void:
	"""Unlock a journal entry (grant discovery)"""
	if entry_id not in entries:
		return
	
	var entry = entries[entry_id]
	
	if entry.discovered:
		return  # Already unlocked
	
	entry.discovered = true
	discovered_entries.append(entry_id)
	
	# Award research points bonus
	if entry.research_point_bonus > 0 and GameManager:
		GameManager.add_research_points(entry.research_point_bonus)
	
	# Process unlocks
	if not entry.unlocks.is_empty():
		process_unlock(entry.unlocks)
	
	# Emit signals
	journal_entry_unlocked.emit(entry_id)
	new_entry_discovered.emit()
	
	print("📖 Journal Entry Discovered: ", entry.title)
	print("   ", entry.content.substr(0, 100), "...")


func process_unlock(unlock_str: String) -> void:
	"""Process what an entry unlocks"""
	# Can unlock recipes, species hints, special items, etc.
	# Format: "recipe:kelp_salad" or "hint:posidonia_location"
	print("Unlocked: ", unlock_str)


func check_all_conditions() -> void:
	"""Check all entries to see if any can be unlocked"""
	for entry_id in entries.keys():
		try_unlock_entry(entry_id)


func _check_milestone_unlocks(_year: int) -> void:
	"""Check for milestone-based unlocks"""
	check_all_conditions()


func _check_seasonal_unlocks(_season: String) -> void:
	"""Check for seasonal unlocks"""
	check_all_conditions()


func _check_wildlife_unlocks(_wildlife_type: String) -> void:
	"""Check for wildlife-based unlocks"""
	check_all_conditions()


func is_entry_discovered(entry_id: String) -> bool:
	"""Check if an entry has been discovered"""
	return entry_id in discovered_entries


func get_entry(entry_id: String) -> JournalEntry:
	"""Get a journal entry by ID"""
	return entries.get(entry_id, null)


func get_discovered_entries() -> Array:
	"""Get list of all discovered entry IDs"""
	return discovered_entries.duplicate()


func get_undiscovered_entries() -> Array:
	"""Get list of undiscovered entry IDs"""
	var undiscovered = []
	for entry_id in entries.keys():
		if not is_entry_discovered(entry_id):
			undiscovered.append(entry_id)
	return undiscovered


func get_discovery_progress() -> Dictionary:
	"""Get discovery progress stats"""
	return {
		"discovered": discovered_entries.size(),
		"total": total_entries,
		"percentage": (discovered_entries.size() * 100.0 / max(total_entries, 1))
	}


func get_save_data() -> Dictionary:
	"""Get all data for saving"""
	return {
		"discovered_entries": discovered_entries
	}


func load_save_data(data: Dictionary) -> void:
	"""Load saved data"""
	discovered_entries = data.get("discovered_entries", [])
	
	# Mark entries as discovered
	for entry_id in discovered_entries:
		if entry_id in entries:
			entries[entry_id].discovered = true
