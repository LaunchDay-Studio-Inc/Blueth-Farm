extends Node
## Unit test for inventory system
## Tests the PlayerInventory's item management and save/load functionality

var test_results: Array[Dictionary] = []
var inventory: Node


func _ready() -> void:
	print("=== Running Inventory System Tests ===")
	
	# Create a test inventory instance
	var PlayerInventory = load("res://scripts/player/player_inventory.gd")
	inventory = PlayerInventory.new()
	add_child(inventory)
	
	# Wait for inventory to be ready
	await get_tree().process_frame
	
	# Run tests
	test_add_item()
	test_remove_item()
	test_has_item()
	test_get_item_count()
	test_stacking()
	test_inventory_full()
	test_get_all_items()
	test_load_inventory()
	test_clear_inventory()
	
	# Print results
	print_results()
	
	# Cleanup
	inventory.queue_free()


## Test adding items to inventory
func test_add_item() -> void:
	print("\n[TEST] Add Item")
	
	inventory.clear_inventory()
	var success = inventory.add_item("seed_eelgrass", 5)
	var count = inventory.get_item_count("seed_eelgrass")
	
	var passed = success and count == 5
	
	test_results.append({
		"name": "Add Item",
		"passed": passed,
		"expected": "Added 5 eelgrass seeds",
		"actual": "Success: %s, Count: %d" % [success, count]
	})


## Test removing items from inventory
func test_remove_item() -> void:
	print("\n[TEST] Remove Item")
	
	inventory.clear_inventory()
	inventory.add_item("seed_cordgrass", 10)
	
	var removed = inventory.remove_item("seed_cordgrass", 3)
	var remaining = inventory.get_item_count("seed_cordgrass")
	
	var passed = removed == 3 and remaining == 7
	
	test_results.append({
		"name": "Remove Item",
		"passed": passed,
		"expected": "Removed 3, leaving 7",
		"actual": "Removed: %d, Remaining: %d" % [removed, remaining]
	})


## Test checking if inventory has items
func test_has_item() -> void:
	print("\n[TEST] Has Item")
	
	inventory.clear_inventory()
	inventory.add_item("seed_mangrove", 5)
	
	var has_5 = inventory.has_item("seed_mangrove", 5)
	var has_10 = inventory.has_item("seed_mangrove", 10)
	var has_none = inventory.has_item("seed_kelp", 1)
	
	var passed = has_5 and not has_10 and not has_none
	
	test_results.append({
		"name": "Has Item",
		"passed": passed,
		"expected": "Has 5 mangrove, not 10, not kelp",
		"actual": "Has 5: %s, Has 10: %s, Has kelp: %s" % [has_5, has_10, has_none]
	})


## Test getting item count across multiple slots
func test_get_item_count() -> void:
	print("\n[TEST] Get Item Count")
	
	inventory.clear_inventory()
	inventory.add_item("harvest_eelgrass", 50)
	inventory.add_item("harvest_eelgrass", 30)
	
	var count = inventory.get_item_count("harvest_eelgrass")
	var passed = count == 80
	
	test_results.append({
		"name": "Get Item Count",
		"passed": passed,
		"expected": 80,
		"actual": count
	})


## Test item stacking behavior
func test_stacking() -> void:
	print("\n[TEST] Item Stacking")
	
	inventory.clear_inventory()
	
	# Add items up to stack limit
	inventory.add_item("test_item", 50, 99)
	inventory.add_item("test_item", 40, 99)
	
	# Should stack in first slot (90 total)
	var slot_0 = inventory.get_slot(0)
	var slot_1 = inventory.get_slot(1)
	
	var passed = slot_0.quantity == 90 and slot_1.quantity == 0
	
	test_results.append({
		"name": "Item Stacking",
		"passed": passed,
		"expected": "90 in first slot, 0 in second",
		"actual": "Slot 0: %d, Slot 1: %d" % [slot_0.quantity, slot_1.quantity]
	})


## Test inventory full behavior
func test_inventory_full() -> void:
	print("\n[TEST] Inventory Full")
	
	inventory.clear_inventory()
	
	# Fill all 40 slots with different items
	for i in range(40):
		inventory.add_item("item_%d" % i, 1)
	
	# Try to add one more item
	var success = inventory.add_item("overflow_item", 1)
	
	var passed = not success
	
	test_results.append({
		"name": "Inventory Full",
		"passed": passed,
		"expected": "Adding to full inventory fails",
		"actual": "Add returned: %s" % success
	})


## Test getting all items as a dictionary
func test_get_all_items() -> void:
	print("\n[TEST] Get All Items")
	
	inventory.clear_inventory()
	inventory.add_item("seed_eelgrass", 10)
	inventory.add_item("seed_cordgrass", 5)
	inventory.add_item("harvest_eelgrass", 20)
	
	var all_items = inventory.get_all_items()
	
	var has_correct_items = (
		all_items.get("seed_eelgrass", 0) == 10 and
		all_items.get("seed_cordgrass", 0) == 5 and
		all_items.get("harvest_eelgrass", 0) == 20 and
		all_items.size() == 3
	)
	
	test_results.append({
		"name": "Get All Items",
		"passed": has_correct_items,
		"expected": "3 item types with correct quantities",
		"actual": "Items: %s" % str(all_items)
	})


## Test loading inventory from saved data
func test_load_inventory() -> void:
	print("\n[TEST] Load Inventory")
	
	inventory.clear_inventory()
	
	var save_data = {
		"seed_eelgrass": 15,
		"seed_cordgrass": 8,
		"harvest_mangrove": 25
	}
	
	inventory.load_inventory(save_data)
	
	var eelgrass = inventory.get_item_count("seed_eelgrass")
	var cordgrass = inventory.get_item_count("seed_cordgrass")
	var mangrove = inventory.get_item_count("harvest_mangrove")
	
	var passed = eelgrass == 15 and cordgrass == 8 and mangrove == 25
	
	test_results.append({
		"name": "Load Inventory",
		"passed": passed,
		"expected": "15, 8, 25",
		"actual": "%d, %d, %d" % [eelgrass, cordgrass, mangrove]
	})


## Test clearing inventory
func test_clear_inventory() -> void:
	print("\n[TEST] Clear Inventory")
	
	inventory.add_item("test_item", 50)
	inventory.clear_inventory()
	
	var all_items = inventory.get_all_items()
	var passed = all_items.size() == 0
	
	test_results.append({
		"name": "Clear Inventory",
		"passed": passed,
		"expected": "Empty inventory",
		"actual": "Items: %d" % all_items.size()
	})


## Print test results summary
func print_results() -> void:
	print("\n=== Test Results ===")
	
	var passed_count = 0
	var total_count = test_results.size()
	
	for result in test_results:
		var status = "[PASS]" if result.passed else "[FAIL]"
		print("%s - %s" % [status, result.name])
		if not result.passed:
			print("  Expected: %s" % result.expected)
			print("  Actual:   %s" % result.actual)
		
		if result.passed:
			passed_count += 1
	
	print("\n%d/%d tests passed" % [passed_count, total_count])
	
	if passed_count == total_count:
		print("[SUCCESS] All tests passed!")
	else:
		print("[FAILURE] Some tests failed")
