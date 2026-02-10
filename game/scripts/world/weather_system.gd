extends Node
## Weather system
## Manages weather states, transitions, and storm events

signal weather_changed(new_weather: WeatherState)
signal storm_started()
signal storm_ended(damage_prevented: float)

enum WeatherState {
	CLEAR,
	CLOUDY,
	RAIN,
	HEAVY_RAIN,
	STORM,
	HEATWAVE
}

var current_weather: WeatherState = WeatherState.CLEAR
var weather_duration: float = 0.0
var weather_timer: float = 0.0

# Weather probabilities by season
var weather_chances: Dictionary = {}

# Storm parameters
var storm_active: bool = false
var storm_intensity: float = 0.0
var ecosystem_protection: float = 0.0


func _ready() -> void:
	print("WeatherSystem initialized")
	TimeManager.day_changed.connect(_on_day_changed)
	_initialize_weather_chances()


func _initialize_weather_chances() -> void:
	"""Set up weather probability tables"""
	weather_chances = {
		TimeManager.Season.SPRING: {
			WeatherState.CLEAR: 0.5,
			WeatherState.CLOUDY: 0.25,
			WeatherState.RAIN: 0.15,
			WeatherState.STORM: 0.10
		},
		TimeManager.Season.SUMMER: {
			WeatherState.CLEAR: 0.60,
			WeatherState.CLOUDY: 0.15,
			WeatherState.RAIN: 0.10,
			WeatherState.STORM: 0.10,
			WeatherState.HEATWAVE: 0.05
		},
		TimeManager.Season.AUTUMN: {
			WeatherState.CLEAR: 0.35,
			WeatherState.CLOUDY: 0.30,
			WeatherState.RAIN: 0.20,
			WeatherState.HEAVY_RAIN: 0.10,
			WeatherState.STORM: 0.05
		},
		TimeManager.Season.WINTER: {
			WeatherState.CLEAR: 0.40,
			WeatherState.CLOUDY: 0.30,
			WeatherState.RAIN: 0.20,
			WeatherState.STORM: 0.10
		}
	}


func _on_day_changed(day: int) -> void:
	"""Potentially change weather each day"""
	var season = TimeManager.current_season
	var chances = weather_chances.get(season, {})
	
	# Apply heatwave stress if currently in a heatwave
	if current_weather == WeatherState.HEATWAVE:
		_apply_heatwave_stress()
	
	# Roll for new weather
	var roll = randf()
	var cumulative = 0.0
	
	for weather in chances:
		cumulative += chances[weather]
		if roll <= cumulative:
			set_weather(weather)
			break


func set_weather(new_weather: WeatherState) -> void:
	"""Change the weather"""
	if current_weather == new_weather:
		return
	
	var old_weather = current_weather
	current_weather = new_weather
	weather_changed.emit(new_weather)
	
	print("Weather changed: ", WeatherState.keys()[old_weather], " -> ", WeatherState.keys()[new_weather])
	
	# Handle storm events
	if new_weather == WeatherState.STORM:
		_start_storm()
	elif old_weather == WeatherState.STORM:
		_end_storm()
	
	# Handle heatwave warnings
	if new_weather == WeatherState.HEATWAVE:
		var notification_system = get_node_or_null("/root/GameWorld/NotificationSystem")
		if notification_system:
			notification_system.show_notification(
				"🌡️ Heatwave! Shallow plants may be stressed.",
				notification_system.NotificationType.WARNING
			)
	
	# Update audio ambient layers
	AudioManager.update_ambient_layers(
		EcosystemManager.get_overall_health(),
		WeatherState.keys()[current_weather].to_lower(),
		EcosystemManager.biodiversity_score
	)


func _start_storm() -> void:
	"""Start a storm event"""
	storm_active = true
	storm_intensity = randf_range(0.5, 1.0)
	
	# Calculate ecosystem protection
	ecosystem_protection = EcosystemManager.get_overall_health()
	
	storm_started.emit()
	print("Storm brewing! Intensity: ", storm_intensity)


func _end_storm() -> void:
	"""End a storm and calculate damage"""
	if not storm_active:
		return
	
	storm_active = false
	
	# Get TileMapManager reference
	var tile_map_manager = get_node_or_null("/root/GameWorld/TileMapManager")
	if not tile_map_manager:
		print("Warning: TileMapManager not found for storm damage")
		storm_ended.emit(0.0)
		return
	
	# Calculate ecosystem protection from healthy mature ecosystems
	ecosystem_protection = EcosystemManager.get_overall_health()
	var planted_count = EcosystemManager.total_planted_count
	if planted_count > 20:
		# Bonus protection from established ecosystems
		ecosystem_protection = min(1.0, ecosystem_protection * 1.2)
	
	# Track damage statistics
	var total_base_damage = 0.0
	var total_actual_damage = 0.0
	var plants_damaged = 0
	var plants_destroyed = 0
	
	# Apply damage to all planted tiles
	for tile_pos in tile_map_manager.tile_data:
		var tile = tile_map_manager.get_tile_at(tile_pos)
		if tile and tile.is_planted:
			# Calculate base damage for this tile
			var tile_base_damage = _calculate_tile_storm_damage(tile, tile_map_manager.current_tide_offset)
			
			# Apply ecosystem protection mitigation (max 80% reduction)
			var protection_factor = ecosystem_protection * 0.8
			var tile_actual_damage = tile_base_damage * (1.0 - protection_factor)
			
			total_base_damage += tile_base_damage
			total_actual_damage += tile_actual_damage
			
			# Apply damage to plant
			if tile_actual_damage > 0.05:  # Only apply significant damage
				tile_map_manager.damage_plant(tile_pos, tile_actual_damage)
				plants_damaged += 1
				
				# Check if plant died
				if tile.plant_health <= 0.0:
					plants_destroyed += 1
				# Regress growth stage if heavily damaged but survived
				elif tile_actual_damage > 0.4 and tile.growth_stage > 0:
					tile_map_manager.regress_growth_stage(tile_pos)
	
	var damage_prevented = total_base_damage - total_actual_damage
	
	print("Storm ended! Plants damaged: ", plants_damaged, ", destroyed: ", plants_destroyed)
	print("Ecosystem prevented %.1f%% of potential damage" % (ecosystem_protection * 80.0))
	
	storm_ended.emit(damage_prevented)


func _calculate_tile_storm_damage(tile: TileMapManager.TileData, tide_offset: float) -> float:
	"""Calculate base storm damage for a single tile"""
	var base_damage = storm_intensity * 0.3  # Base: 15-30% damage
	
	# Deeper water = more exposed to storm waves
	var actual_depth = tile.water_depth + tide_offset
	var depth_factor = 1.0
	if actual_depth > 2.0:
		depth_factor = 1.5  # 50% more damage in deep water
	elif actual_depth < 0.5:
		depth_factor = 0.7  # 30% less damage in shallow protected areas
	
	# Younger plants are more vulnerable
	var growth_factor = 1.0
	if tile.growth_stage < 2:
		growth_factor = 1.3  # Young plants take 30% more damage
	elif tile.growth_stage >= 3:
		growth_factor = 0.8  # Mature plants are more resilient
	
	# Add random variation
	var random_factor = randf_range(0.8, 1.2)
	
	# Combine all factors
	var total_damage = base_damage * depth_factor * growth_factor * random_factor
	
	# Clamp to reasonable range
	return clamp(total_damage, 0.0, 0.9)  # Max 90% damage per storm


func get_weather_name() -> String:
	"""Get human-readable weather name"""
	return WeatherState.keys()[current_weather].capitalize().replace("_", " ")


func is_raining() -> bool:
	"""Check if it's currently raining"""
	return current_weather in [WeatherState.RAIN, WeatherState.HEAVY_RAIN, WeatherState.STORM]


func get_growth_modifier() -> float:
	"""Get growth rate modifier based on weather"""
	match current_weather:
		WeatherState.CLEAR:
			return 1.0
		WeatherState.CLOUDY:
			return 0.95
		WeatherState.RAIN:
			return 1.1  # Rain helps growth
		WeatherState.HEAVY_RAIN:
			return 1.05
		WeatherState.STORM:
			return 0.8  # Storms stress plants
		WeatherState.HEATWAVE:
			return 0.7  # Heat stress
	return 1.0


func _apply_heatwave_stress() -> void:
	"""Apply daily stress damage during heatwaves"""
	var tile_map_manager = get_node_or_null("/root/GameWorld/TileMapManager")
	if not tile_map_manager:
		return
	
	var plants_stressed = 0
	
	# Apply stress to shallow water plants
	for tile_pos in tile_map_manager.tile_data:
		var tile = tile_map_manager.get_tile_at(tile_pos)
		if tile and tile.is_planted:
			var actual_depth = tile.water_depth + tile_map_manager.current_tide_offset
			
			# Shallow plants are more vulnerable to heat
			var heat_damage = 0.0
			if actual_depth < 0.5:
				heat_damage = 0.05  # 5% damage per day for very shallow plants
			elif actual_depth < 1.0:
				heat_damage = 0.03  # 3% damage for shallow plants
			elif actual_depth < 2.0:
				heat_damage = 0.01  # 1% damage for moderate depth
			# Deeper plants are protected
			
			if heat_damage > 0:
				tile_map_manager.damage_plant(tile_pos, heat_damage)
				plants_stressed += 1
	
	if plants_stressed > 0:
		print("Heatwave stress: ", plants_stressed, " plants affected")


func get_save_data() -> Dictionary:
	"""Get weather data for saving"""
	return {
		"current_weather": current_weather,
		"storm_active": storm_active,
		"storm_intensity": storm_intensity
	}


func load_save_data(data: Dictionary) -> void:
	"""Load weather data from save"""
	current_weather = data.get("current_weather", WeatherState.CLEAR)
	storm_active = data.get("storm_active", false)
	storm_intensity = data.get("storm_intensity", 0.0)
