extends Node
## Game world controller
## Coordinates all game systems and player interactions

@onready var tile_map_manager = $TileMapManager
@onready var planting_system = $PlantingSystem
@onready var growth_system = $GrowthSystem
@onready var harvest_system = $HarvestSystem
@onready var player = $Player
@onready var world_renderer = $WorldRenderer

var current_species_to_plant: String = "seagrass_zostera"
var species_resources: Dictionary = {}


func _ready() -> void:
	print("GameWorld initialized")
	
	# Load species resources
	_load_species()
	
	# Connect signals
	if tile_map_manager:
		tile_map_manager.tile_clicked.connect(_on_tile_clicked)
	
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
