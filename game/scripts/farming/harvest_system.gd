extends Node
## Sustainable harvesting system
## Handles harvesting mature plants and collecting seeds

signal harvest_completed(tile_pos: Vector2i, items: Dictionary)
signal seeds_collected(tile_pos: Vector2i, species_key: String, quantity: int)
signal plant_harvested(tile_pos: Vector2i, species: String, growth_stage: int)

@export var tile_map_manager: TileMapManager
@export var player_inventory: Node

# Minimum growth stages for different actions
const MATURE_STAGE: int = 3  # Stage 3+ can be harvested for yield
const SEED_STAGE: int = 4    # Stage 4+ can produce seeds

# Harvest yield multipliers per growth stage
const YIELD_MULTIPLIERS: Dictionary = {
	0: 0.0,  # Seed - no yield
	1: 0.0,  # Sprout - no yield
	2: 0.3,  # Juvenile - small yield
	3: 0.7,  # Mature - good yield
	4: 1.0   # Established - full yield
}

# Seed drop rates per growth stage
const SEED_DROP_CHANCE: Dictionary = {
	0: 0.0,  # Seed - no seeds
	1: 0.0,  # Sprout - no seeds
	2: 0.0,  # Juvenile - no seeds
	3: 0.5,  # Mature - 50% chance
	4: 1.0   # Established - guaranteed seeds
}

var _species_cache: Dictionary = {}


func can_harvest(tile_pos: Vector2i) -> bool:
	"""Check if a tile has a plant that can be harvested"""
	var tile = tile_map_manager.get_tile_at(tile_pos)
	if not tile or not tile.is_planted:
		return false
	
	# Must be at least at mature stage
	return tile.growth_stage >= MATURE_STAGE


func harvest_plant(tile_pos: Vector2i) -> Dictionary:
	"""Harvest a plant and return items gained"""
	var harvest_result = {
		"success": false,
		"items": {},
		"seeds": 0,
		"species": ""
	}
	
	# Validate harvest
	if not can_harvest(tile_pos):
		return harvest_result
	
	var tile = tile_map_manager.get_tile_at(tile_pos)
	var species_key = tile.planted_species
	var growth_stage = tile.growth_stage
	
	# Load species data
	var species_data = _get_species_data(species_key)
	if not species_data:
		print("Warning: Species data not found for ", species_key)
		return harvest_result
	
	# Calculate harvest yield
	var yield_multiplier = YIELD_MULTIPLIERS.get(growth_stage, 0.0)
	var base_yield = 1  # Base amount of harvested material
	var harvest_quantity = max(1, int(base_yield * yield_multiplier * 10))  # Scale up for gameplay
	
	# Determine seed drops
	var seed_quantity = 0
	if growth_stage >= SEED_STAGE:
		var seed_chance = SEED_DROP_CHANCE.get(growth_stage, 0.0)
		if randf() < seed_chance:
			seed_quantity = randi_range(1, 3)  # 1-3 seeds for established plants
	
	# Add harvested items to inventory
	var harvest_item_name = species_key + "_harvest"
	if player_inventory:
		player_inventory.add_item(harvest_item_name, harvest_quantity)
		harvest_result.items[harvest_item_name] = harvest_quantity
		
		# Add seeds if any
		if seed_quantity > 0:
			var seed_item_name = species_key + "_seed"
			player_inventory.add_item(seed_item_name, seed_quantity)
			harvest_result.seeds = seed_quantity
	
	# Use TileMapManager to remove the plant
	tile_map_manager.harvest_tile(tile_pos)
	
	# Build result
	harvest_result.success = true
	harvest_result.species = species_key
	
	# Emit signals
	plant_harvested.emit(tile_pos, species_key, growth_stage)
	harvest_completed.emit(tile_pos, harvest_result.items)
	
	print("Harvested ", species_key, " at ", tile_pos, ": ", harvest_quantity, " items, ", seed_quantity, " seeds")
	
	return harvest_result


func collect_seeds(tile_pos: Vector2i) -> bool:
	"""Collect seeds from a mature plant without removing it"""
	var tile = tile_map_manager.get_tile_at(tile_pos)
	if not tile or not tile.is_planted:
		return false
	
	# Must be at seed-producing stage
	if tile.growth_stage < SEED_STAGE:
		print("Plant not mature enough to produce seeds (stage ", tile.growth_stage, ")")
		return false
	
	var species_key = tile.planted_species
	
	# Determine seed quantity (1-2 seeds without destroying plant)
	var seed_quantity = randi_range(1, 2)
	
	# Add seeds to inventory
	if player_inventory:
		var seed_item_name = species_key + "_seed"
		player_inventory.add_item(seed_item_name, seed_quantity)
		
		# Emit signal
		seeds_collected.emit(tile_pos, species_key, seed_quantity)
		
		print("Collected ", seed_quantity, " seeds from ", species_key, " at ", tile_pos)
		return true
	
	return false


func get_harvest_preview(tile_pos: Vector2i) -> Dictionary:
	"""Preview what would be harvested without actually harvesting"""
	var preview = {
		"can_harvest": false,
		"items": {},
		"seeds_min": 0,
		"seeds_max": 0,
		"species": "",
		"growth_stage": 0
	}
	
	if not can_harvest(tile_pos):
		return preview
	
	var tile = tile_map_manager.get_tile_at(tile_pos)
	var growth_stage = tile.growth_stage
	var species_key = tile.planted_species
	
	# Calculate potential yield
	var yield_multiplier = YIELD_MULTIPLIERS.get(growth_stage, 0.0)
	var harvest_quantity = max(1, int(yield_multiplier * 10))
	
	# Seed drop prediction
	var seed_min = 0
	var seed_max = 0
	if growth_stage >= SEED_STAGE:
		seed_min = 1
		seed_max = 3
	
	preview.can_harvest = true
	preview.items[species_key + "_harvest"] = harvest_quantity
	preview.seeds_min = seed_min
	preview.seeds_max = seed_max
	preview.species = species_key
	preview.growth_stage = growth_stage
	
	return preview


func can_collect_seeds(tile_pos: Vector2i) -> bool:
	"""Check if seeds can be collected from a tile"""
	var tile = tile_map_manager.get_tile_at(tile_pos)
	if not tile or not tile.is_planted:
		return false
	
	return tile.growth_stage >= SEED_STAGE


func _get_species_data(species_key: String) -> SpeciesData:
	"""Load and cache species data resource"""
	if species_key in _species_cache:
		return _species_cache[species_key]
	
	var resource_path = "res://game/data/species/" + species_key + ".tres"
	if ResourceLoader.exists(resource_path):
		var species_data = load(resource_path) as SpeciesData
		_species_cache[species_key] = species_data
		return species_data
	
	return null


func get_growth_stage_name(stage: int) -> String:
	"""Get human-readable name for growth stage"""
	match stage:
		0: return "Seed"
		1: return "Sprout"
		2: return "Juvenile"
		3: return "Mature"
		4: return "Established"
		_: return "Unknown"
