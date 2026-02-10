extends Node
## Unit test for carbon calculation system
## Tests the CarbonManager's carbon sequestration calculations

var test_results: Array[Dictionary] = []


func _ready() -> void:
	print("=== Running Carbon Calculation Tests ===")
	
	# Run tests
	test_carbon_addition()
	test_sediment_carbon()
	test_carbon_removal()
	test_equivalencies()
	test_milestone_detection()
	
	# Print results
	print_results()


func test_carbon_addition() -> void:
	"""Test adding carbon from planted species"""
	print("\n[TEST] Carbon Addition")
	
	# Reset carbon manager
	CarbonManager.total_biomass_carbon = 0.0
	CarbonManager.daily_sequestration_rate = 0.0
	
	# Add eelgrass at growth stage 4 (established)
	CarbonManager.add_plant_carbon("seagrass_zostera", 4, 1)
	
	var expected_daily_rate = (138.0 * 0.0001) / 365.0  # Annual rate to daily per tile
	var stage_multiplier = 0.2 + (4 * 0.2)  # = 1.0 at stage 4
	expected_daily_rate *= stage_multiplier
	
	var passed = abs(CarbonManager.daily_sequestration_rate - expected_daily_rate) < 0.00001
	
	test_results.append({
		"name": "Carbon Addition",
		"passed": passed,
		"expected": expected_daily_rate,
		"actual": CarbonManager.daily_sequestration_rate
	})


func test_sediment_carbon() -> void:
	"""Test sediment carbon accumulation"""
	print("\n[TEST] Sediment Carbon")
	
	CarbonManager.total_sediment_carbon = 0.0
	
	var sediment_amount = 1.5
	CarbonManager.add_sediment_carbon(sediment_amount)
	
	var passed = abs(CarbonManager.total_sediment_carbon - sediment_amount) < 0.001
	
	test_results.append({
		"name": "Sediment Carbon",
		"passed": passed,
		"expected": sediment_amount,
		"actual": CarbonManager.total_sediment_carbon
	})


func test_carbon_removal() -> void:
	"""Test carbon removal when plants are harvested"""
	print("\n[TEST] Carbon Removal")
	
	CarbonManager.total_biomass_carbon = 10.0
	CarbonManager.daily_sequestration_rate = 0.1
	
	var initial_biomass = CarbonManager.total_biomass_carbon
	var initial_rate = CarbonManager.daily_sequestration_rate
	
	# Remove a plant
	CarbonManager.remove_plant_carbon("seagrass_zostera", 4)
	
	var biomass_decreased = CarbonManager.total_biomass_carbon < initial_biomass
	var rate_decreased = CarbonManager.daily_sequestration_rate < initial_rate
	
	var passed = biomass_decreased and rate_decreased
	
	test_results.append({
		"name": "Carbon Removal",
		"passed": passed,
		"expected": "Biomass and rate decrease",
		"actual": "Biomass: %.4f -> %.4f, Rate: %.4f -> %.4f" % [
			initial_biomass, CarbonManager.total_biomass_carbon,
			initial_rate, CarbonManager.daily_sequestration_rate
		]
	})


func test_equivalencies() -> void:
	"""Test carbon equivalency calculations"""
	print("\n[TEST] Carbon Equivalencies")
	
	# Set a known carbon amount
	CarbonManager.total_co2_sequestered = 100.0  # 100 tonnes
	CarbonManager._update_totals()
	
	# Calculate expected equivalencies
	var expected_cars = 100.0 / 4.6  # ~21.7 cars
	var expected_flights = 100.0 / 0.9  # ~111 flights
	
	var cars_close = abs(CarbonManager.cars_offset - expected_cars) < 1.0
	var flights_close = abs(CarbonManager.flights_offset - expected_flights) < 1.0
	
	var passed = cars_close and flights_close
	
	test_results.append({
		"name": "Carbon Equivalencies",
		"passed": passed,
		"expected": "Cars: %.1f, Flights: %.1f" % [expected_cars, expected_flights],
		"actual": "Cars: %.1f, Flights: %.1f" % [CarbonManager.cars_offset, CarbonManager.flights_offset]
	})


func test_milestone_detection() -> void:
	"""Test carbon milestone detection"""
	print("\n[TEST] Milestone Detection")
	
	var milestone_reached = false
	var milestone_value = 0
	
	# Connect to milestone signal
	var milestone_handler = func(milestone: int):
		milestone_reached = true
		milestone_value = milestone
	
	CarbonManager.carbon_milestone_reached.connect(milestone_handler)
	
	# Set carbon just below milestone
	CarbonManager.total_co2_sequestered = 9.5
	CarbonManager.daily_sequestration_rate = 1.0
	
	# Trigger update (should cross 10 tonne milestone)
	CarbonManager._update_totals()
	
	var passed = milestone_reached and milestone_value == 10
	
	test_results.append({
		"name": "Milestone Detection",
		"passed": passed,
		"expected": "Milestone 10 triggered",
		"actual": "Triggered: %s, Value: %d" % [milestone_reached, milestone_value]
	})
	
	CarbonManager.carbon_milestone_reached.disconnect(milestone_handler)


func print_results() -> void:
	"""Print test results summary"""
	print("\n=== Test Results ===")
	
	var passed_count = 0
	var total_count = test_results.size()
	
	for result in test_results:
		var status = "✓ PASS" if result.passed else "✗ FAIL"
		print("%s - %s" % [status, result.name])
		if not result.passed:
			print("  Expected: %s" % result.expected)
			print("  Actual:   %s" % result.actual)
		
		if result.passed:
			passed_count += 1
	
	print("\n%d/%d tests passed" % [passed_count, total_count])
	
	if passed_count == total_count:
		print("✓ All tests passed!")
	else:
		print("✗ Some tests failed")
