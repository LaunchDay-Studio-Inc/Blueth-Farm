extends Node
## Time and environmental systems manager
## Handles day/night cycle, seasons, tidal cycles, and lunar phases

signal day_changed(day: int)
signal season_changed(season: Season)
signal tide_changed(tide_level: float, is_high_tide: bool)
signal moon_phase_changed(phase: MoonPhase)
signal time_tick(hour: int, minute: int)

enum Season {
	SPRING,
	SUMMER,
	AUTUMN,
	WINTER
}

enum MoonPhase {
	NEW_MOON,        # Spring tide
	WAXING_CRESCENT,
	FIRST_QUARTER,   # Neap tide
	WAXING_GIBBOUS,
	FULL_MOON,       # Spring tide
	WANING_GIBBOUS,
	LAST_QUARTER,    # Neap tide
	WANING_CRESCENT
}

# Time configuration
const REAL_SECONDS_PER_GAME_DAY: float = 1200.0  # 20 minutes real time = 1 game day
const GAME_HOURS_PER_DAY: int = 24
const GAME_MINUTES_PER_HOUR: int = 60
const DAYS_PER_SEASON: int = 28
const SEASONS_PER_YEAR: int = 4

# Current time
var current_day: int = 1
var current_season: Season = Season.SPRING
var current_year: int = 1
var current_hour: int = 6  # Start at 6 AM
var current_minute: int = 0
var time_scale: float = 1.0  # Multiplier for time speed

# Accumulated time
var accumulated_time: float = 0.0

# Tidal system
var tide_level: float = 0.0  # Range: -1.0 (low tide) to 1.0 (high tide)
var tide_cycle_hours: float = 12.0  # Full tide cycle (low -> high -> low)
var is_spring_tide: bool = false  # Higher tidal range during spring tides
var tide_amplitude: float = 1.0  # Affected by moon phase

# Season modifiers
var season_modifiers: Dictionary = {
	Season.SPRING: {
		"temperature": 18.0,
		"storm_chance": 0.15,
		"growth_rate_modifier": 1.2,
		"species_activity": 1.1
	},
	Season.SUMMER: {
		"temperature": 26.0,
		"storm_chance": 0.25,
		"growth_rate_modifier": 1.0,
		"species_activity": 1.3
	},
	Season.AUTUMN: {
		"temperature": 20.0,
		"storm_chance": 0.30,
		"growth_rate_modifier": 0.9,
		"species_activity": 1.0
	},
	Season.WINTER: {
		"temperature": 12.0,
		"storm_chance": 0.35,
		"growth_rate_modifier": 0.7,
		"species_activity": 0.6
	}
}


func _ready() -> void:
	print("TimeManager initialized - Day 1, Spring, Year 1")
	_update_tide()


func _process(delta: float) -> void:
	# Advance time
	accumulated_time += delta * time_scale
	
	var seconds_per_minute: float = REAL_SECONDS_PER_GAME_DAY / (GAME_HOURS_PER_DAY * GAME_MINUTES_PER_HOUR)
	
	if accumulated_time >= seconds_per_minute:
		accumulated_time -= seconds_per_minute
		_advance_minute()


func _advance_minute() -> void:
	"""Advance time by one game minute"""
	current_minute += 1
	
	if current_minute >= GAME_MINUTES_PER_HOUR:
		current_minute = 0
		current_hour += 1
		time_tick.emit(current_hour, current_minute)
		
		# Update tide every hour
		_update_tide()
		
		if current_hour >= GAME_HOURS_PER_DAY:
			current_hour = 0
			_advance_day()


func _advance_day() -> void:
	"""Advance to the next day"""
	current_day += 1
	day_changed.emit(current_day)
	print("Day ", current_day, " - ", Season.keys()[current_season], " Year ", current_year)
	
	# Check for season change
	var day_in_year = (current_day - 1) % (DAYS_PER_SEASON * SEASONS_PER_YEAR) + 1
	var new_season_index = int((day_in_year - 1) / DAYS_PER_SEASON)
	var new_season = new_season_index as Season
	
	if new_season != current_season:
		current_season = new_season
		season_changed.emit(current_season)
		print("Season changed to: ", Season.keys()[current_season])
	
	# Check for year change
	if current_day > 1 and (current_day - 1) % (DAYS_PER_SEASON * SEASONS_PER_YEAR) == 0:
		current_year += 1
		GameManager.advance_year()
	
	# Update moon phase every day
	_update_moon_phase()


func _update_tide() -> void:
	"""Update tidal level based on time and moon phase"""
	# Calculate tide based on time of day
	# Two high tides and two low tides per day (roughly every 6 hours)
	var hours_in_cycle = fmod(current_hour + current_minute / 60.0, tide_cycle_hours)
	var tide_position = (hours_in_cycle / tide_cycle_hours) * TAU  # Convert to radians
	
	# Sinusoidal tide calculation
	var base_tide = sin(tide_position)
	
	# Apply moon phase amplitude modifier
	tide_level = base_tide * tide_amplitude
	
	# Emit signal if tide state changed (high/low threshold)
	var is_high = tide_level > 0.5
	tide_changed.emit(tide_level, is_high)


func _update_moon_phase() -> void:
	"""Update moon phase based on day of lunar cycle (28 days)"""
	var lunar_day = (current_day - 1) % 28
	var phase_index = int(lunar_day / 3.5)  # 28 days / 8 phases = 3.5 days per phase
	phase_index = clamp(phase_index, 0, 7)
	
	var new_phase = phase_index as MoonPhase
	
	# Set spring tide flag (new moon and full moon)
	is_spring_tide = (new_phase == MoonPhase.NEW_MOON or new_phase == MoonPhase.FULL_MOON)
	
	# Modify tide amplitude based on moon phase
	if is_spring_tide:
		tide_amplitude = 1.3  # Higher tides during spring tides
	else:
		tide_amplitude = 0.8  # Lower tides during neap tides
	
	moon_phase_changed.emit(new_phase)


func get_current_season_modifiers() -> Dictionary:
	"""Get the modifiers for the current season"""
	return season_modifiers[current_season]


func get_time_of_day() -> String:
	"""Get human-readable time of day"""
	return "%02d:%02d" % [current_hour, current_minute]


func get_season_name() -> String:
	"""Get current season name"""
	return Season.keys()[current_season]


func is_day_time() -> bool:
	"""Check if it's daytime (6 AM - 8 PM)"""
	return current_hour >= 6 and current_hour < 20


func is_night_time() -> bool:
	"""Check if it's nighttime"""
	return not is_day_time()


func get_day_progress() -> float:
	"""Get progress through the day (0.0 - 1.0)"""
	return (current_hour + current_minute / 60.0) / 24.0


func set_time_scale(scale: float) -> void:
	"""Set time speed multiplier"""
	time_scale = clamp(scale, 0.0, 10.0)
	print("Time scale set to: ", time_scale, "x")


func skip_to_next_day() -> void:
	"""Skip to 6 AM of the next day"""
	current_hour = 6
	current_minute = 0
	_advance_day()


func get_save_data() -> Dictionary:
	"""Get time data for saving"""
	return {
		"current_day": current_day,
		"current_season": current_season,
		"current_year": current_year,
		"current_hour": current_hour,
		"current_minute": current_minute,
		"tide_level": tide_level,
		"is_spring_tide": is_spring_tide,
		"tide_amplitude": tide_amplitude
	}


func load_save_data(data: Dictionary) -> void:
	"""Load time data from save"""
	current_day = data.get("current_day", 1)
	current_season = data.get("current_season", Season.SPRING)
	current_year = data.get("current_year", 1)
	current_hour = data.get("current_hour", 6)
	current_minute = data.get("current_minute", 0)
	tide_level = data.get("tide_level", 0.0)
	is_spring_tide = data.get("is_spring_tide", false)
	tide_amplitude = data.get("tide_amplitude", 1.0)
	
	_update_tide()
	_update_moon_phase()
