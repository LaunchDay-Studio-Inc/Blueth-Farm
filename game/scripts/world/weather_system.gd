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
	
	# Calculate potential damage
	var base_damage = storm_intensity * 100.0
	
	# Ecosystem reduces damage
	var actual_damage = base_damage * (1.0 - ecosystem_protection)
	var damage_prevented = base_damage - actual_damage
	
	print("Storm passed! Damage prevented by ecosystem: %.1f%%" % (ecosystem_protection * 100.0))
	
	# Could apply actual damage to tiles here
	
	storm_ended.emit(damage_prevented)


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
