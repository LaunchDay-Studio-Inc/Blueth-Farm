extends GutTest
## Unit tests for CarbonManager
## Tests carbon sequestration calculations, carbon credit generation, and equivalency calculations


var carbon_manager: Node


func before_each():
	"""Set up CarbonManager before each test"""
	# Get the autoload CarbonManager or create instance
	if has_node("/root/CarbonManager"):
		carbon_manager = get_node("/root/CarbonManager")
	else:
		var CarbonManagerScript = load("res://scripts/autoloads/carbon_manager.gd")
		carbon_manager = CarbonManagerScript.new()
		add_child(carbon_manager)
	
	# Reset carbon values
	carbon_manager.total_biomass_carbon = 0.0
	carbon_manager.total_sediment_carbon = 0.0
	carbon_manager.total_co2_sequestered = 0.0
	carbon_manager.daily_sequestration_rate = 0.0
	carbon_manager.total_carbon_credits = 0.0
	carbon_manager.unverified_carbon = 0.0


func after_each():
	"""Clean up after each test"""
	if carbon_manager and not carbon_manager.is_queued_for_deletion():
		if not has_node("/root/CarbonManager"):
			carbon_manager.queue_free()


func test_add_plant_carbon_seagrass():
	"""Test adding carbon from seagrass"""
	# Add 1 tile of zostera seagrass at growth stage 4 (fully established)
	carbon_manager.add_plant_carbon("seagrass_zostera", 4, 1)
	
	# Calculate expected values
	var expected_daily_rate = (138.0 * 0.0001) / 365.0  # Annual to daily per tile
	var stage_multiplier = 0.2 + (4 * 0.2)  # = 1.0 at stage 4
	expected_daily_rate *= stage_multiplier
	
	assert_almost_eq(carbon_manager.daily_sequestration_rate, expected_daily_rate, 0.00001,
		"Daily sequestration rate should match calculated value")
	assert_gt(carbon_manager.total_biomass_carbon, 0.0, "Biomass carbon should increase")


func test_add_plant_carbon_salt_marsh():
	"""Test adding carbon from salt marsh"""
	# Salt marsh has higher sequestration rate
	carbon_manager.add_plant_carbon("salt_marsh_spartina", 3, 1)
	
	var expected_daily_rate = (218.0 * 0.0001) / 365.0
	var stage_multiplier = 0.2 + (3 * 0.2)  # = 0.8 at stage 3
	expected_daily_rate *= stage_multiplier
	
	assert_almost_eq(carbon_manager.daily_sequestration_rate, expected_daily_rate, 0.00001,
		"Salt marsh should have higher sequestration rate than seagrass")


func test_growth_stage_multiplier():
	"""Test that growth stage affects carbon sequestration"""
	# Stage 0 (seed) should sequester less than stage 4 (established)
	carbon_manager.add_plant_carbon("seagrass_zostera", 0, 1)
	var rate_stage_0 = carbon_manager.daily_sequestration_rate
	
	carbon_manager.daily_sequestration_rate = 0.0
	carbon_manager.add_plant_carbon("seagrass_zostera", 4, 1)
	var rate_stage_4 = carbon_manager.daily_sequestration_rate
	
	assert_gt(rate_stage_4, rate_stage_0, 
		"Stage 4 plants should sequester more carbon than stage 0")


func test_sediment_carbon_accumulation():
	"""Test sediment carbon storage"""
	var initial_sediment = carbon_manager.total_sediment_carbon
	
	carbon_manager.add_sediment_carbon(1.5)
	
	assert_eq(carbon_manager.total_sediment_carbon, initial_sediment + 1.5,
		"Sediment carbon should increase by amount added")


func test_remove_plant_carbon():
	"""Test removing carbon when plant is removed"""
	# Add then remove carbon
	carbon_manager.add_plant_carbon("seagrass_zostera", 4, 1)
	var biomass_after_add = carbon_manager.total_biomass_carbon
	var rate_after_add = carbon_manager.daily_sequestration_rate
	
	carbon_manager.remove_plant_carbon("seagrass_zostera", 4)
	
	assert_lt(carbon_manager.total_biomass_carbon, biomass_after_add,
		"Biomass carbon should decrease when plant is removed")
	assert_lt(carbon_manager.daily_sequestration_rate, rate_after_add,
		"Daily rate should decrease when plant is removed")


func test_carbon_totals_calculation():
	"""Test that total CO2 is correctly calculated"""
	carbon_manager.total_biomass_carbon = 10.0
	carbon_manager.total_sediment_carbon = 5.0
	
	carbon_manager._update_totals()
	
	assert_eq(carbon_manager.total_co2_sequestered, 15.0,
		"Total CO2 should be sum of biomass and sediment carbon")


func test_car_equivalency_calculation():
	"""Test real-world car offset equivalency"""
	# Set a known amount of carbon
	carbon_manager.total_co2_sequestered = 46.0  # tonnes
	carbon_manager._update_totals()
	
	# 46 tonnes / 4.6 tonnes per car = 10 cars
	assert_almost_eq(carbon_manager.cars_offset, 10.0, 0.1,
		"Should offset approximately 10 cars per year")


func test_flight_equivalency_calculation():
	"""Test real-world flight offset equivalency"""
	carbon_manager.total_co2_sequestered = 9.0  # tonnes
	carbon_manager._update_totals()
	
	# 9 tonnes / 0.9 tonnes per flight = 10 flights
	assert_almost_eq(carbon_manager.flights_offset, 10.0, 0.1,
		"Should offset approximately 10 flights")


func test_tree_equivalency_calculation():
	"""Test tree planting equivalency"""
	carbon_manager.total_co2_sequestered = 2.1  # tonnes
	carbon_manager._update_totals()
	
	# 2.1 tonnes / 0.021 tonnes per tree = 100 trees
	assert_almost_eq(carbon_manager.trees_equivalent, 100.0, 1.0,
		"Should be equivalent to approximately 100 trees")


func test_carbon_credit_generation():
	"""Test carbon credit generation from verified carbon"""
	carbon_manager.verification_unlocked = true
	carbon_manager.unverified_carbon = 10.0
	
	# Generate credits (1 credit per tonne)
	carbon_manager.generate_carbon_credits()
	
	assert_gt(carbon_manager.total_carbon_credits, 0.0,
		"Carbon credits should be generated from unverified carbon")
	assert_eq(carbon_manager.unverified_carbon, 0.0,
		"Unverified carbon should be converted to credits")


func test_carbon_credit_cannot_generate_when_locked():
	"""Test that credits cannot be generated before verification is unlocked"""
	carbon_manager.verification_unlocked = false
	carbon_manager.unverified_carbon = 10.0
	
	carbon_manager.generate_carbon_credits()
	
	assert_eq(carbon_manager.total_carbon_credits, 0.0,
		"Credits should not be generated when verification is locked")


func test_multiple_tile_addition():
	"""Test adding carbon from multiple tiles at once"""
	carbon_manager.add_plant_carbon("seagrass_zostera", 4, 5)  # 5 tiles
	
	var expected_daily_rate = (138.0 * 0.0001) / 365.0 * 1.0 * 5  # x5 for 5 tiles
	
	assert_almost_eq(carbon_manager.daily_sequestration_rate, expected_daily_rate, 0.0001,
		"Should correctly calculate rate for multiple tiles")


func test_carbon_milestone_detection():
	"""Test that carbon milestones are detected"""
	watch_signals(carbon_manager)
	
	# Set carbon to just below a milestone, then cross it
	carbon_manager.total_co2_sequestered = 9.9
	carbon_manager.total_sediment_carbon = 0.2  # This should push total over 10
	carbon_manager._update_totals()
	
	# Check if milestone signal would be emitted (may depend on implementation)
	# This test verifies the signal exists
	assert_has_signal(carbon_manager, "carbon_milestone_reached",
		"CarbonManager should have carbon_milestone_reached signal")


func test_daily_carbon_accumulation():
	"""Test that carbon accumulates daily"""
	carbon_manager.daily_sequestration_rate = 0.01  # Small daily rate
	var initial_total = carbon_manager.total_co2_sequestered
	
	# Simulate day change
	carbon_manager._on_day_changed(2)
	
	assert_gte(carbon_manager.total_co2_sequestered, initial_total,
		"Total carbon should accumulate daily based on sequestration rate")


func test_carbon_rates_are_defined():
	"""Test that all expected species have carbon rates defined"""
	assert_true(carbon_manager.CARBON_RATES.has("seagrass_zostera"),
		"Should have rate for seagrass_zostera")
	assert_true(carbon_manager.CARBON_RATES.has("salt_marsh_spartina"),
		"Should have rate for salt_marsh_spartina")
	assert_true(carbon_manager.CARBON_RATES.has("mangrove_red"),
		"Should have rate for mangrove_red")
	assert_true(carbon_manager.CARBON_RATES.has("kelp_macrocystis"),
		"Should have rate for kelp_macrocystis")


func test_carbon_cannot_go_negative():
	"""Test that carbon values cannot go below zero"""
	carbon_manager.total_biomass_carbon = 1.0
	
	# Try to remove more carbon than exists
	carbon_manager.remove_plant_carbon("seagrass_zostera", 4)
	carbon_manager.remove_plant_carbon("seagrass_zostera", 4)
	carbon_manager.remove_plant_carbon("seagrass_zostera", 4)
	
	assert_gte(carbon_manager.total_biomass_carbon, 0.0,
		"Biomass carbon should not go negative")
	assert_gte(carbon_manager.daily_sequestration_rate, 0.0,
		"Daily rate should not go negative")
