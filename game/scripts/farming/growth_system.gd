extends Node
## Plant growth simulation system
## Processes growth for all planted tiles each game day

@export var tile_map_manager: TileMapManager

var _species_cache: Dictionary = {}


func _ready() -> void:
	# Connect to TimeManager day change signal
	TimeManager.day_changed.connect(_on_day_changed)
	print("GrowthSystem initialized and connected to TimeManager")


func _on_day_changed(day: int) -> void:
	"""Process growth for all planted tiles when a new day starts"""
	var tiles_processed = 0
	
	for tile_pos in tile_map_manager.tile_data:
		var tile = tile_map_manager.get_tile_at(tile_pos)
		if tile and tile.is_planted:
			var species_data = _get_species_data(tile.planted_species)
			if species_data:
				process_growth(tile_pos, tile, species_data)
				tiles_processed += 1
	
	if tiles_processed > 0:
		print("Processed growth for ", tiles_processed, " planted tiles on day ", day)


func process_growth(tile_pos: Vector2i, tile_data: TileMapManager.TileData, species: SpeciesData) -> void:
	"""Advance growth stage based on days_per_stage and growth modifiers"""
	if not tile_data.is_planted:
		return
	
	# Calculate growth rate multiplier
	var growth_rate = calculate_growth_rate(tile_pos)
	
	# Increment growth timer (in days, modified by growth rate)
	tile_data.growth_timer += growth_rate
	
	# Check if plant should advance to next growth stage
	if tile_data.growth_stage < species.growth_stages - 1:
		var days_needed = species.get_days_to_stage(tile_data.growth_stage + 1)
		
		# Account for cumulative days (sum of all previous stages)
		var cumulative_days = 0.0
		for stage in range(tile_data.growth_stage + 1):
			cumulative_days += species.get_days_to_stage(stage)
		
		if tile_data.growth_timer >= cumulative_days:
			# Advance to next stage
			var old_stage = tile_data.growth_stage
			tile_data.growth_stage += 1
			
			print("Plant at ", tile_pos, " advanced from stage ", old_stage, " to ", tile_data.growth_stage)
			
			# Update CarbonManager for stage change
			# Remove old stage carbon, add new stage carbon
			CarbonManager.remove_plant_carbon(tile_data.planted_species, old_stage)
			CarbonManager.add_plant_carbon(tile_data.planted_species, tile_data.growth_stage, 1)


func calculate_growth_rate(tile_pos: Vector2i) -> float:
	"""Calculate growth rate multiplier based on environmental factors"""
	var base_rate = 1.0
	
	# Season modifier from TimeManager
	var season_modifiers = TimeManager.get_current_season_modifiers()
	var season_modifier = season_modifiers.get("growth_rate_modifier", 1.0)
	
	# Biodiversity bonus from nearby plants (ecosystem synergy)
	var biodiversity_modifier = _get_nearby_plant_synergy(tile_pos)
	
	# Ecosystem health modifier
	var ecosystem_health = EcosystemManager.get_overall_health()
	var health_modifier = 0.5 + (ecosystem_health * 0.5)  # Range: 0.5 - 1.0
	
	# Combine all modifiers
	var total_rate = base_rate * season_modifier * biodiversity_modifier * health_modifier
	
	# Clamp to reasonable range (0.5 - 1.5)
	return clamp(total_rate, 0.5, 1.5)


func _get_nearby_plant_synergy(tile_pos: Vector2i) -> float:
	"""Calculate growth bonus from nearby diverse plants"""
	var nearby_species = {}
	var search_radius = 2
	
	# Check adjacent tiles
	for x in range(-search_radius, search_radius + 1):
		for y in range(-search_radius, search_radius + 1):
			if x == 0 and y == 0:
				continue
			
			var check_pos = tile_pos + Vector2i(x, y)
			var tile = tile_map_manager.get_tile_at(check_pos)
			
			if tile and tile.is_planted:
				nearby_species[tile.planted_species] = true
	
	# More species diversity nearby = better growth
	var species_count = nearby_species.size()
	var synergy_bonus = 0.0
	
	if species_count >= 3:
		synergy_bonus = 0.3  # 30% bonus
	elif species_count == 2:
		synergy_bonus = 0.15  # 15% bonus
	elif species_count == 1:
		synergy_bonus = 0.05  # 5% bonus
	
	return 1.0 + synergy_bonus


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


func get_growth_progress(tile_pos: Vector2i) -> float:
	"""Get growth progress as percentage (0.0 - 1.0) for a tile"""
	var tile = tile_map_manager.get_tile_at(tile_pos)
	if not tile or not tile.is_planted:
		return 0.0
	
	var species_data = _get_species_data(tile.planted_species)
	if not species_data:
		return 0.0
	
	# Calculate total days for current stage
	var total_days_for_stage = 0.0
	for stage in range(tile.growth_stage + 1):
		total_days_for_stage += species_data.get_days_to_stage(stage)
	
	if total_days_for_stage <= 0:
		return 1.0
	
	return min(tile.growth_timer / total_days_for_stage, 1.0)


func get_days_until_next_stage(tile_pos: Vector2i) -> float:
	"""Get estimated days until next growth stage"""
	var tile = tile_map_manager.get_tile_at(tile_pos)
	if not tile or not tile.is_planted:
		return 0.0
	
	var species_data = _get_species_data(tile.planted_species)
	if not species_data or tile.growth_stage >= species_data.growth_stages - 1:
		return 0.0  # Already at max stage
	
	# Calculate cumulative days for next stage
	var cumulative_days = 0.0
	for stage in range(tile.growth_stage + 1):
		cumulative_days += species_data.get_days_to_stage(stage)
	
	var days_remaining = cumulative_days - tile.growth_timer
	
	# Account for growth rate
	var growth_rate = calculate_growth_rate(tile_pos)
	if growth_rate > 0:
		days_remaining /= growth_rate
	
	return max(days_remaining, 0.0)
