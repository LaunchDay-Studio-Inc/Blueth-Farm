extends Node
## Year Progression System
## Tracks game years, triggers year-end summaries, and manages zone unlocks

signal year_advanced(new_year: int)
signal year_summary_shown()
signal zone_unlocked(zone_name: String)

const DAYS_PER_YEAR: int = 112  # 4 seasons × 28 days

var current_year: int = 1
var days_in_current_year: int = 0
var year_stats: Dictionary = {}
var zone_unlock_conditions: Dictionary = {}


func _ready() -> void:
	# Connect to TimeManager
	if TimeManager:
		TimeManager.day_changed.connect(_on_day_changed)
	
	_initialize_zone_unlock_conditions()
	_reset_year_stats()
	
	print("YearProgression initialized - Year ", current_year)


func _initialize_zone_unlock_conditions() -> void:
	"""Define zone unlock conditions for each year"""
	zone_unlock_conditions = {
		"mudflats": {
			"year": 2,
			"plants_required": 10,
			"zone_required": "shallows",
			"description": "Establish 10+ plants in Shallows"
		},
		"estuary": {
			"year": 3,
			"plants_required": 20,
			"biodiversity_required": 50,
			"description": "20+ total plants, biodiversity > 50"
		},
		"reef_edge": {
			"year": 4,
			"plants_required": 40,
			"building_required": "marine_lab",
			"description": "40+ plants, Marine Lab built"
		}
	}


func _reset_year_stats() -> void:
	"""Reset stats tracking for the new year"""
	year_stats = {
		"carbon_sequestered": 0.0,
		"species_planted": {},
		"plants_added": 0,
		"wildlife_attracted": [],
		"gold_earned": 0,
		"town_investments": [],
		"research_unlocked": [],
		"journal_entries": []
	}


func _on_day_changed(day: int, season: String, year_day: int) -> void:
	"""Called when a new day starts"""
	days_in_current_year += 1
	
	# Track daily stats
	_update_daily_stats()
	
	# Check for year end
	if days_in_current_year >= DAYS_PER_YEAR:
		_end_current_year()


func _update_daily_stats() -> void:
	"""Update year statistics daily"""
	# Track carbon
	if CarbonManager:
		var daily_carbon = CarbonManager.get_daily_carbon_rate()
		year_stats.carbon_sequestered += daily_carbon


func _end_current_year() -> void:
	"""End the current year and show summary"""
	print("Year ", current_year, " complete!")
	
	# Pause the game
	get_tree().paused = true
	
	# Show year-end summary screen
	_show_year_summary()


func _show_year_summary() -> void:
	"""Display year-end summary screen"""
	# Load and show year summary UI
	var year_summary_scene = load("res://scenes/ui/year_summary.tscn")
	if year_summary_scene:
		var summary = year_summary_scene.instantiate()
		get_tree().root.add_child(summary)
		
		# Pass year stats to summary
		if summary.has_method("display_summary"):
			summary.display_summary(current_year, year_stats)
		
		# Wait for player to continue
		if summary.has_signal("continue_pressed"):
			await summary.continue_pressed
		
		# Clean up
		summary.queue_free()
	
	year_summary_shown.emit()
	
	# Advance to next year
	_advance_year()


func _advance_year() -> void:
	"""Advance to the next year"""
	current_year += 1
	days_in_current_year = 0
	
	# Update GameManager
	if GameManager:
		GameManager.current_year = current_year
	
	# Check zone unlocks
	_check_zone_unlocks()
	
	# Reset year stats
	_reset_year_stats()
	
	# Emit signal
	year_advanced.emit(current_year)
	
	# Check for endgame (Year 5)
	if current_year == 5:
		_check_year_5_completion()
	
	# Resume game
	get_tree().paused = false
	
	print("Advanced to Year ", current_year)


func _check_zone_unlocks() -> void:
	"""Check if new zones should be unlocked"""
	for zone_name in zone_unlock_conditions:
		var conditions = zone_unlock_conditions[zone_name]
		
		# Check year requirement
		if current_year < conditions.get("year", 999):
			continue
		
		# Check if already unlocked
		if GameManager and GameManager.zones_data.get(zone_name, {}).get("unlocked", false):
			continue
		
		# Check conditions
		if _check_unlock_conditions(conditions):
			_unlock_zone(zone_name)


func _check_unlock_conditions(conditions: Dictionary) -> bool:
	"""Check if zone unlock conditions are met"""
	# Check plants required
	if conditions.has("plants_required"):
		var total_plants = _get_total_plant_count()
		if total_plants < conditions.plants_required:
			return false
	
	# Check biodiversity
	if conditions.has("biodiversity_required"):
		var biodiversity = EcosystemManager.biodiversity_score if EcosystemManager else 0
		if biodiversity < conditions.biodiversity_required:
			return false
	
	# Check building required
	if conditions.has("building_required"):
		var building_id = conditions.building_required
		# TODO: Check TownInvestment for building completion
		# For now, assume it's checked
	
	# Check zone required
	if conditions.has("zone_required"):
		var zone_name = conditions.zone_required
		if GameManager and not GameManager.zones_data.get(zone_name, {}).get("unlocked", false):
			return false
	
	return true


func _get_total_plant_count() -> int:
	"""Get total number of planted tiles"""
	var count = 0
	# TODO: Query TileMapManager for planted tile count
	# For now, return a placeholder
	if EcosystemManager:
		count = EcosystemManager.total_planted_species_count
	return count


func _unlock_zone(zone_name: String) -> void:
	"""Unlock a new zone"""
	if GameManager:
		GameManager.unlock_zone(zone_name)
	
	zone_unlocked.emit(zone_name)
	
	# Show notification
	var notification_system = get_node_or_null("/root/GameWorld/NotificationSystem")
	if notification_system:
		var display_name = zone_name.capitalize().replace("_", " ")
		notification_system.show_notification("🗺️ New Zone Unlocked: " + display_name + "!", 5)  # GROWTH type
	
	print("Zone unlocked: ", zone_name)


func _check_year_5_completion() -> void:
	"""Check if Year 5 has been reached (endgame)"""
	# Year 5 is the legacy mode / endgame
	print("Year 5 reached - Legacy Mode unlocked!")
	
	# Show notification
	var notification_system = get_node_or_null("/root/GameWorld/NotificationSystem")
	if notification_system:
		notification_system.show_notification("🎉 Year 5 Complete! Legacy Mode Unlocked!", 7)  # CARBON type


## Public API

func get_current_year() -> int:
	"""Get the current game year"""
	return current_year


func get_days_in_year() -> int:
	"""Get days elapsed in current year"""
	return days_in_current_year


func track_species_planted(species_name: String) -> void:
	"""Track when a species is planted (for year stats)"""
	if species_name not in year_stats.species_planted:
		year_stats.species_planted[species_name] = 0
	year_stats.species_planted[species_name] += 1
	year_stats.plants_added += 1


func track_wildlife_attracted(wildlife_type: String) -> void:
	"""Track when wildlife is first spotted (for year stats)"""
	if wildlife_type not in year_stats.wildlife_attracted:
		year_stats.wildlife_attracted.append(wildlife_type)


func track_investment_completed(building_id: String) -> void:
	"""Track when a town investment is completed (for year stats)"""
	if building_id not in year_stats.town_investments:
		year_stats.town_investments.append(building_id)


func track_research_unlocked(research_id: String) -> void:
	"""Track when research is unlocked (for year stats)"""
	if research_id not in year_stats.research_unlocked:
		year_stats.research_unlocked.append(research_id)


func track_journal_entry(entry_id: String) -> void:
	"""Track when a journal entry is discovered (for year stats)"""
	if entry_id not in year_stats.journal_entries:
		year_stats.journal_entries.append(entry_id)


func track_gold_earned(amount: int) -> void:
	"""Track gold earned this year"""
	year_stats.gold_earned += amount


## Save/Load

func get_save_data() -> Dictionary:
	"""Get save data for year progression"""
	return {
		"current_year": current_year,
		"days_in_current_year": days_in_current_year,
		"year_stats": year_stats
	}


func load_save_data(data: Dictionary) -> void:
	"""Load save data for year progression"""
	current_year = data.get("current_year", 1)
	days_in_current_year = data.get("days_in_current_year", 0)
	year_stats = data.get("year_stats", {})
	
	if year_stats.is_empty():
		_reset_year_stats()
