extends Node
## Game world controller
## Coordinates all game systems and player interactions

@onready var tile_map_manager = $TileMapManager
@onready var planting_system = $PlantingSystem
@onready var growth_system = $GrowthSystem
@onready var harvest_system = $HarvestSystem
@onready var player = $Player
@onready var world_renderer = $WorldRenderer
@onready var weather_system = $WeatherSystem
@onready var nursery_system = $NurserySystem
@onready var quest_system = $QuestSystem
@onready var journal_system = $JournalSystem
@onready var tutorial_system = $TutorialSystem
@onready var year_progression_system = $YearProgressionSystem
@onready var notification_system = $NotificationSystem
@onready var market_system = $MarketSystem
@onready var town_investment_system = $TownInvestmentSystem
@onready var eco_tourism_system = $EcoTourismSystem
@onready var tech_tree = $TechTree

var current_species_to_plant: String = "seagrass_zostera"
var species_resources: Dictionary = {}


func _ready() -> void:
	print("GameWorld initialized")
	
	# Load species resources
	_load_species()
	
	# Connect all system signals
	_connect_signals()
	
	# Give player some starting seeds
	if player and player.has_node("PlayerInventory"):
		var inventory = player.get_node("PlayerInventory")
		inventory.add_item("seed_eelgrass", 10)
		inventory.add_item("seed_cordgrass", 5)
		inventory.add_item("seed_red_mangrove", 3)
		print("Starting inventory: 10 eelgrass seeds, 5 cordgrass seeds, 3 red mangrove seeds")


func _load_species() -> void:
	"""Load all species resource files"""
	var species_files = [
		"res://resources/species/seagrass_zostera.tres",
		"res://resources/species/spartina.tres",
		"res://resources/species/mangrove_red.tres",
		"res://resources/species/kelp_macrocystis.tres"
	]
	
	for file_path in species_files:
		if ResourceLoader.exists(file_path):
			var species = load(file_path) as SpeciesData
			if species:
				var key = species.get_resource_key()
				species_resources[key] = species
				print("Loaded species: ", species.species_name, " (", key, ")")


func _connect_signals() -> void:
	"""Connect signals between all game systems"""
	print("Connecting game system signals...")
	
	# TileMapManager signals
	if tile_map_manager:
		tile_map_manager.tile_clicked.connect(_on_tile_clicked)
	
	# PlantingSystem signals
	if planting_system:
		# Connect to QuestSystem for plant objectives
		if quest_system and planting_system.has_signal("plant_placed"):
			planting_system.plant_placed.connect(_on_plant_placed)
		
		# Connect to JournalSystem for unlock conditions
		if journal_system and planting_system.has_signal("plant_placed"):
			planting_system.plant_placed.connect(journal_system._check_unlock_conditions)
	
	# HarvestSystem signals
	if harvest_system:
		# Connect to QuestSystem for harvest objectives
		if quest_system and harvest_system.has_signal("plant_harvested"):
			harvest_system.plant_harvested.connect(_on_plant_harvested)
		
		# Connect to JournalSystem for unlock conditions
		if journal_system and harvest_system.has_signal("plant_harvested"):
			harvest_system.plant_harvested.connect(journal_system._check_unlock_conditions)
	
	# CarbonManager signals
	if CarbonManager.has_signal("carbon_updated"):
		# Connect to QuestSystem for carbon objectives
		if quest_system:
			CarbonManager.carbon_updated.connect(_on_carbon_updated)
		
		# Connect to JournalSystem for carbon milestones
		if journal_system:
			CarbonManager.carbon_updated.connect(journal_system._check_unlock_conditions)
	
	# WeatherSystem signals
	if weather_system:
		if weather_system.has_signal("storm_started"):
			weather_system.storm_started.connect(_on_storm_started)
		if weather_system.has_signal("storm_ended"):
			weather_system.storm_ended.connect(_on_storm_ended)
	
	# TimeManager signals - these connect to multiple systems
	if TimeManager.has_signal("day_changed"):
		# Note: GrowthSystem, MarketSystem, EcoTourismSystem, etc. connect directly in their _ready()
		pass
	
	# QuestSystem signals
	if quest_system and quest_system.has_signal("quest_completed"):
		quest_system.quest_completed.connect(_on_quest_completed)
	
	# JournalSystem signals
	if journal_system and journal_system.has_signal("entry_discovered"):
		journal_system.entry_discovered.connect(_on_journal_entry_discovered)
	
	# TutorialSystem signals
	if tutorial_system:
		if tutorial_system.has_signal("tutorial_step_completed"):
			tutorial_system.tutorial_step_completed.connect(_on_tutorial_step_completed)
	
	# TechTree signals
	if tech_tree and tech_tree.has_signal("research_completed"):
		tech_tree.research_completed.connect(_on_research_completed)
	
	# TownInvestmentSystem signals
	if town_investment_system and town_investment_system.has_signal("building_completed"):
		town_investment_system.building_completed.connect(_on_building_completed)
	
	print("All game system signals connected")


# Signal handlers
func _on_plant_placed(tile_pos: Vector2i, species: String) -> void:
	"""Handle plant placed for quest updates"""
	if quest_system:
		quest_system.update_objective("plant", species, 1)


func _on_plant_harvested(tile_pos: Vector2i, species: String, growth_stage: int) -> void:
	"""Handle plant harvested for quest updates"""
	if quest_system:
		quest_system.update_objective("harvest", species, 1)


func _on_carbon_updated(total_carbon: float) -> void:
	"""Handle carbon updates for quest objectives"""
	if quest_system:
		quest_system.update_objective("carbon", "total", total_carbon)


func _on_storm_started() -> void:
	"""Handle storm started - show warning notification"""
	if notification_system:
		notification_system.show_notification(
			"⚠️ Storm Warning! Your ecosystems will help protect the coast.",
			notification_system.NotificationType.WARNING
		)


func _on_storm_ended(damage_prevented: float) -> void:
	"""Handle storm ended - show results notification"""
	if notification_system:
		var carbon_prevented = damage_prevented / 100.0  # Convert to tonnes
		notification_system.show_notification(
			"Storm passed! Your ecosystems prevented %.1f tonnes of CO₂ release." % carbon_prevented,
			notification_system.NotificationType.CARBON
		)
	
	# Request renderer update to show damage
	if world_renderer:
		world_renderer.queue_redraw()


func _on_quest_completed(quest_id: String) -> void:
	"""Handle quest completion notification"""
	if notification_system:
		notification_system.show_notification(
			"Quest completed!",
			notification_system.NotificationType.GOLD
		)


func _on_journal_entry_discovered(entry_id: String) -> void:
	"""Handle journal entry discovered - already handled by NotificationSystem"""
	pass


func _on_tutorial_step_completed(step_id: String) -> void:
	"""Handle tutorial step completion"""
	print("Tutorial step completed: ", step_id)


func _on_research_completed(node_id: String) -> void:
	"""Handle research completion notification"""
	if notification_system:
		notification_system.show_notification(
			"Research completed!",
			notification_system.NotificationType.RESEARCH
		)


func _on_building_completed(building_id: String) -> void:
	"""Handle building completion notification"""
	if notification_system:
		notification_system.show_notification(
			"Building completed!",
			notification_system.NotificationType.BUILDING
		)



func _on_tile_clicked(tile_pos: Vector2i) -> void:
	"""Handle tile clicks for planting/harvesting"""
	if not tile_map_manager:
		return
	
	var tile = tile_map_manager.get_tile_at(tile_pos)
	if not tile:
		return
	
	print("Tile clicked: ", tile_pos, " - Type: ", tile_map_manager.TileType.keys()[tile.tile_type])
	
	# Check current tool
	var tool = player.get_node("PlayerTools").current_tool
	
	match tool:
		player.get_node("PlayerTools").ToolType.SEED_BAG:
			_try_plant_at_tile(tile_pos)
		player.get_node("PlayerTools").ToolType.COLLECTION_NET:
			_try_harvest_at_tile(tile_pos)
		player.get_node("PlayerTools").ToolType.WATER_TESTER:
			_test_water_at_tile(tile_pos)
		player.get_node("PlayerTools").ToolType.MONITORING_KIT:
			_monitor_tile(tile_pos)


func _try_plant_at_tile(tile_pos: Vector2i) -> void:
	"""Try to plant current species at tile"""
	if current_species_to_plant not in species_resources:
		print("Species not loaded: ", current_species_to_plant)
		return
	
	var species = species_resources[current_species_to_plant]
	
	# Check if player has seeds
	var inventory = player.get_node("PlayerInventory")
	var seed_name = "seed_" + current_species_to_plant.replace("_", "_")
	
	if not inventory.has_item(seed_name):
		print("No seeds for ", species.species_name)
		return
	
	# Try to plant
	if planting_system.plant_species(tile_pos, current_species_to_plant, species):
		# Deduct seed
		inventory.remove_item(seed_name, 1)
		print("Planted ", species.species_name, " at ", tile_pos)
		
		# Mark as planted in tutorial
		if not GameManager.first_plant_done:
			GameManager.first_plant_done = true
			print("First plant milestone reached!")
		
		# Redraw world
		if world_renderer:
			world_renderer.queue_redraw()
	else:
		print("Cannot plant here - incompatible conditions")


func _try_harvest_at_tile(tile_pos: Vector2i) -> void:
	"""Try to harvest at tile"""
	var result = harvest_system.harvest_plant(tile_pos)
	
	if not result.is_empty():
		print("Harvested ", result.species, " - Stage ", result.growth_stage)
		
		# Add items to inventory
		var inventory = player.get_node("PlayerInventory")
		for item in result.get("items", []):
			inventory.add_item(item.type, item.quantity)
		
		# Mark tutorial
		if not GameManager.first_harvest_done:
			GameManager.first_harvest_done = true
			print("First harvest milestone reached!")
		
		# Redraw world
		if world_renderer:
			world_renderer.queue_redraw()


func _test_water_at_tile(tile_pos: Vector2i) -> void:
	"""Display water quality info for a tile"""
	var tile = tile_map_manager.get_tile_at(tile_pos)
	if tile:
		print("=== Water Quality at ", tile_pos, " ===")
		print("Depth: ", tile.water_depth + tile_map_manager.current_tide_offset, " m")
		print("Salinity: ", tile.salinity, " ppt")
		print("Temperature: ", tile.temperature, " °C")
		print("Clarity: ", tile.clarity * 100, "%")
		print("Substrate: ", tile_map_manager.SubstrateType.keys()[tile.substrate_type])


func _monitor_tile(tile_pos: Vector2i) -> void:
	"""Display ecosystem health info for a tile"""
	var tile = tile_map_manager.get_tile_at(tile_pos)
	if tile:
		print("=== Tile Monitoring: ", tile_pos, " ===")
		if tile.is_planted:
			print("Species: ", tile.planted_species)
			print("Growth Stage: ", tile.growth_stage, "/4")
			print("Plant Health: ", tile.plant_health * 100, "%")
			print("Biomass Carbon: ", tile.biomass_carbon, " t CO₂")
			print("Sediment Carbon: ", tile.sediment_carbon, " t CO₂")
		else:
			print("No plant here")
		print("Biodiversity Score: ", EcosystemManager.biodiversity_score)


func _input(event: InputEvent) -> void:
	# Quick species selection
	if event.is_action_pressed("ui_page_up"):
		_cycle_species(1)
	elif event.is_action_pressed("ui_page_down"):
		_cycle_species(-1)


func _cycle_species(direction: int) -> void:
	"""Cycle through available species"""
	var species_keys = species_resources.keys()
	if species_keys.is_empty():
		return
	
	var current_index = species_keys.find(current_species_to_plant)
	var new_index = (current_index + direction) % species_keys.size()
	if new_index < 0:
		new_index = species_keys.size() - 1
	
	current_species_to_plant = species_keys[new_index]
	var species = species_resources[current_species_to_plant]
	print("Selected species: ", species.species_name)
