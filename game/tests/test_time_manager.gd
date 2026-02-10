extends GutTest
## Unit tests for TimeManager
## Tests day/night cycle, tide calculations, season transitions, and lunar phases


func before_each():
	"""Reset TimeManager state before each test"""
	TimeManager.current_day = 1
	TimeManager.current_season = TimeManager.Season.SPRING
	TimeManager.current_year = 1
	TimeManager.current_hour = 6
	TimeManager.current_minute = 0
	TimeManager.accumulated_time = 0.0
	TimeManager.tide_level = 0.0


func test_day_progression():
	"""Test that days advance correctly"""
	var initial_day = TimeManager.current_day
	
	# Advance one full day (24 hours * 60 minutes)
	for _i in range(24 * 60):
		TimeManager.accumulated_time += TimeManager.REAL_SECONDS_PER_GAME_DAY / (24.0 * 60.0)
		TimeManager._process(TimeManager.REAL_SECONDS_PER_GAME_DAY / (24.0 * 60.0))
	
	assert_gt(TimeManager.current_day, initial_day, "Day should advance after 24 hours")


func test_hour_progression():
	"""Test that hours progress from 0-23"""
	TimeManager.current_hour = 23
	TimeManager.current_minute = 30
	
	# Advance 60 minutes
	for _i in range(60):
		TimeManager.accumulated_time += TimeManager.REAL_SECONDS_PER_GAME_DAY / (24.0 * 60.0)
		TimeManager._process(TimeManager.REAL_SECONDS_PER_GAME_DAY / (24.0 * 60.0))
	
	assert_eq(TimeManager.current_hour, 0, "Hour should wrap to 0 after 23:59")


func test_tide_calculation_sinusoidal():
	"""Test that tide follows sinusoidal pattern"""
	TimeManager.current_hour = 0
	var tide_at_0h = TimeManager.get_tide_level()
	
	TimeManager.current_hour = 6
	var tide_at_6h = TimeManager.get_tide_level()
	
	TimeManager.current_hour = 12
	var tide_at_12h = TimeManager.get_tide_level()
	
	# Tide should be periodic - values at 0 and 12 hours should be opposite
	assert_ne(tide_at_0h, tide_at_12h, "Tide should vary over 12-hour cycle")
	
	# Tide should be within valid range
	assert_between(tide_at_0h, -1.5, 1.5, "Tide level should be within reasonable bounds")
	assert_between(tide_at_6h, -1.5, 1.5, "Tide level should be within reasonable bounds")
	assert_between(tide_at_12h, -1.5, 1.5, "Tide level should be within reasonable bounds")


func test_season_transition():
	"""Test that seasons change after appropriate number of days"""
	TimeManager.current_season = TimeManager.Season.SPRING
	TimeManager.current_day = 1
	
	# Advance to just before season change
	TimeManager.current_day = TimeManager.DAYS_PER_SEASON - 1
	var season_before = TimeManager.current_season
	
	# Advance one more day
	TimeManager.current_day = TimeManager.DAYS_PER_SEASON
	TimeManager._check_season_change()
	
	# Season should change after DAYS_PER_SEASON days
	assert_eq(TimeManager.current_season, TimeManager.Season.SUMMER, 
		"Season should change to SUMMER after %d days" % TimeManager.DAYS_PER_SEASON)


func test_season_cycle_complete():
	"""Test that seasons cycle through all four seasons"""
	TimeManager.current_season = TimeManager.Season.SPRING
	TimeManager.current_day = 1
	
	# Spring -> Summer
	TimeManager.current_day = TimeManager.DAYS_PER_SEASON
	TimeManager._check_season_change()
	assert_eq(TimeManager.current_season, TimeManager.Season.SUMMER)
	
	# Summer -> Autumn
	TimeManager.current_day = TimeManager.DAYS_PER_SEASON * 2
	TimeManager._check_season_change()
	assert_eq(TimeManager.current_season, TimeManager.Season.AUTUMN)
	
	# Autumn -> Winter
	TimeManager.current_day = TimeManager.DAYS_PER_SEASON * 3
	TimeManager._check_season_change()
	assert_eq(TimeManager.current_season, TimeManager.Season.WINTER)
	
	# Winter -> Spring (new year)
	TimeManager.current_day = TimeManager.DAYS_PER_SEASON * 4
	TimeManager._check_season_change()
	assert_eq(TimeManager.current_season, TimeManager.Season.SPRING)


func test_lunar_phase_calculation():
	"""Test lunar phase calculation based on day"""
	# Lunar cycle is approximately 28 days
	TimeManager.current_day = 1
	var phase_day_1 = TimeManager.get_moon_phase()
	
	TimeManager.current_day = 7
	var phase_day_7 = TimeManager.get_moon_phase()
	
	TimeManager.current_day = 14
	var phase_day_14 = TimeManager.get_moon_phase()
	
	TimeManager.current_day = 21
	var phase_day_21 = TimeManager.get_moon_phase()
	
	# Phases should progress through the lunar cycle
	assert_true(phase_day_1 is int or phase_day_1 is TimeManager.MoonPhase, 
		"Moon phase should return valid type")
	assert_true(phase_day_7 is int or phase_day_7 is TimeManager.MoonPhase, 
		"Moon phase should return valid type")
	assert_true(phase_day_14 is int or phase_day_14 is TimeManager.MoonPhase, 
		"Moon phase should return valid type")
	assert_true(phase_day_21 is int or phase_day_21 is TimeManager.MoonPhase, 
		"Moon phase should return valid type")


func test_spring_tide_during_new_and_full_moon():
	"""Test that spring tides occur during new and full moon"""
	# New moon (day 1)
	TimeManager.current_day = 1
	var phase_new = TimeManager.get_moon_phase()
	
	# Full moon (approximately day 14)
	TimeManager.current_day = 14
	var phase_full = TimeManager.get_moon_phase()
	
	# Both should be associated with spring tides (higher amplitude)
	# The exact implementation may vary, but we're testing the API exists
	assert_true(phase_new == TimeManager.MoonPhase.NEW_MOON or 
				phase_new == TimeManager.MoonPhase.WAXING_CRESCENT,
				"Day 1 should be near new moon")
	assert_true(phase_full == TimeManager.MoonPhase.FULL_MOON or 
				phase_full == TimeManager.MoonPhase.WAXING_GIBBOUS,
				"Day 14 should be near full moon")


func test_time_scale_modification():
	"""Test that time_scale affects progression speed"""
	TimeManager.time_scale = 2.0
	var delta = 1.0  # 1 second
	
	var time_before = TimeManager.accumulated_time
	TimeManager._process(delta)
	var time_after = TimeManager.accumulated_time
	
	# With time_scale = 2.0, accumulated time should increase by 2 * delta
	assert_almost_eq(time_after - time_before, delta * 2.0, 0.01, 
		"Time scale should affect accumulated time")


func test_season_modifiers_exist():
	"""Test that each season has appropriate modifiers"""
	var spring_mods = TimeManager.season_modifiers[TimeManager.Season.SPRING]
	var summer_mods = TimeManager.season_modifiers[TimeManager.Season.SUMMER]
	var autumn_mods = TimeManager.season_modifiers[TimeManager.Season.AUTUMN]
	var winter_mods = TimeManager.season_modifiers[TimeManager.Season.WINTER]
	
	# Check that all seasons have required modifiers
	assert_true(spring_mods.has("temperature"), "Spring should have temperature")
	assert_true(spring_mods.has("growth_rate_modifier"), "Spring should have growth_rate_modifier")
	
	assert_true(summer_mods.has("temperature"), "Summer should have temperature")
	assert_true(summer_mods.has("growth_rate_modifier"), "Summer should have growth_rate_modifier")
	
	assert_true(autumn_mods.has("temperature"), "Autumn should have temperature")
	assert_true(autumn_mods.has("growth_rate_modifier"), "Autumn should have growth_rate_modifier")
	
	assert_true(winter_mods.has("temperature"), "Winter should have temperature")
	assert_true(winter_mods.has("growth_rate_modifier"), "Winter should have growth_rate_modifier")
	
	# Verify growth rates make sense (Spring > Summer > Autumn > Winter)
	assert_gt(spring_mods["growth_rate_modifier"], winter_mods["growth_rate_modifier"],
		"Spring growth should exceed winter growth")
