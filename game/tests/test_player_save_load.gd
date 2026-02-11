extends GutTest
## Test suite for Player save/load functionality
##
## Tests that player state (position, inventory, boat_unlocked) is properly saved and restored

var player: CharacterBody2D
var player_inventory: Node


func before_each():
	"""Set up before each test"""
	# Create a test player with controller script
	player = CharacterBody2D.new()
	player.set_script(load("res://scripts/player/player_controller.gd"))
	player.add_to_group("player")
	add_child_autofree(player)

	# Create and add player inventory as a child
	player_inventory = Node.new()
	player_inventory.set_script(load("res://scripts/player/player_inventory.gd"))
	player_inventory.name = "PlayerInventory"
	player.add_child(player_inventory)

	# Wait for ready to complete
	await wait_frames(1)


func test_player_save_position():
	"""Test saving player position"""
	# Set player position
	player.global_position = Vector2(100, 200)

	# Get save data
	var save_data = player.get_save_data()

	assert_has(save_data, "position", "Save data should have position")
	assert_eq(save_data["position"]["x"], 100.0, "Should save x position")
	assert_eq(save_data["position"]["y"], 200.0, "Should save y position")


func test_player_save_boat_unlocked():
	"""Test saving boat_unlocked state"""
	# Set boat unlocked
	player.boat_unlocked = true

	# Get save data
	var save_data = player.get_save_data()

	assert_has(save_data, "boat_unlocked", "Save data should have boat_unlocked")
	assert_true(save_data["boat_unlocked"], "Should save boat_unlocked as true")


func test_player_load_position():
	"""Test loading player position"""
	# Create save data with position
	var save_data = {
		"position": {
			"x": 300.0,
			"y": 400.0
		},
		"boat_unlocked": false
	}

	# Load the data
	player.load_save_data(save_data)

	# Verify position was loaded
	assert_almost_eq(player.global_position.x, 300.0, 0.01, "Should restore x position")
	assert_almost_eq(player.global_position.y, 400.0, 0.01, "Should restore y position")


func test_player_load_boat_unlocked():
	"""Test loading boat_unlocked state"""
	# Create save data with boat unlocked
	var save_data = {
		"position": {"x": 0.0, "y": 0.0},
		"boat_unlocked": true
	}

	# Load the data
	player.load_save_data(save_data)

	# Verify boat_unlocked was loaded
	assert_true(player.boat_unlocked, "Should restore boat_unlocked")


func test_player_save_load_roundtrip():
	"""Test that saving and loading preserves all player data"""
	# Set player state
	player.global_position = Vector2(150, 250)
	player.boat_unlocked = true

	# Get save data
	var save_data = player.get_save_data()

	# Create a new player and load the data
	var new_player = CharacterBody2D.new()
	new_player.set_script(load("res://scripts/player/player_controller.gd"))
	add_child_autofree(new_player)

	new_player.load_save_data(save_data)

	# Verify all data was restored
	assert_almost_eq(new_player.global_position.x, 150.0, 0.01, "Should restore x position")
	assert_almost_eq(new_player.global_position.y, 250.0, 0.01, "Should restore y position")
	assert_true(new_player.boat_unlocked, "Should restore boat_unlocked")


func test_inventory_save_empty():
	"""Test saving empty inventory"""
	# Get save data from empty inventory
	var save_data = player_inventory.get_save_data()

	assert_has(save_data, "inventory_slots", "Save data should have inventory_slots")
	assert_has(save_data, "quickslots", "Save data should have quickslots")
	assert_eq(save_data["inventory_slots"].size(), 40, "Should have 40 inventory slots")
	assert_eq(save_data["quickslots"].size(), 5, "Should have 5 quickslots")


func test_inventory_save_with_items():
	"""Test saving inventory with items"""
	# Add some items
	player_inventory.add_item("kelp_seed", 10)
	player_inventory.add_item("seagrass", 5)

	# Get save data
	var save_data = player_inventory.get_save_data()

	# Verify items are saved
	var found_kelp = false
	var found_seagrass = false

	for slot_data in save_data["inventory_slots"]:
		if not slot_data.is_empty():
			if slot_data["item_type"] == "kelp_seed":
				found_kelp = true
				assert_eq(slot_data["quantity"], 10, "Should save kelp quantity")
			elif slot_data["item_type"] == "seagrass":
				found_seagrass = true
				assert_eq(slot_data["quantity"], 5, "Should save seagrass quantity")

	assert_true(found_kelp, "Should save kelp_seed item")
	assert_true(found_seagrass, "Should save seagrass item")


func test_inventory_load_items():
	"""Test loading inventory with items"""
	# Create save data with items in specific slots
	var slots_data = []
	for i in range(40):
		slots_data.append({})

	slots_data[0] = {
		"item_type": "kelp_seed",
		"quantity": 15,
		"max_stack": 99
	}
	slots_data[5] = {
		"item_type": "oyster",
		"quantity": 3,
		"max_stack": 99
	}

	var quickslots_data = []
	for i in range(5):
		quickslots_data.append({})

	quickslots_data[0] = {
		"item_type": "shovel",
		"quantity": 1,
		"max_stack": 1
	}

	var save_data = {
		"inventory_slots": slots_data,
		"quickslots": quickslots_data
	}

	# Load the data
	player_inventory.load_save_data(save_data)

	# Verify items were loaded correctly
	var slot0 = player_inventory.get_slot(0)
	assert_eq(slot0.item_type, "kelp_seed", "Should restore kelp_seed in slot 0")
	assert_eq(slot0.quantity, 15, "Should restore kelp quantity")

	var slot5 = player_inventory.get_slot(5)
	assert_eq(slot5.item_type, "oyster", "Should restore oyster in slot 5")
	assert_eq(slot5.quantity, 3, "Should restore oyster quantity")

	var quickslot0 = player_inventory.get_quickslot(0)
	assert_eq(quickslot0.item_type, "shovel", "Should restore shovel in quickslot 0")
	assert_eq(quickslot0.quantity, 1, "Should restore shovel quantity")


func test_inventory_save_load_roundtrip():
	"""Test that saving and loading preserves all inventory data"""
	# Add various items
	player_inventory.add_item("kelp_seed", 25)
	player_inventory.add_item("seagrass", 10)
	player_inventory.add_item("coral_fragment", 7)
	player_inventory.set_quickslot(0, "shovel", 1)
	player_inventory.set_quickslot(2, "watering_can", 1)

	# Get save data
	var save_data = player_inventory.get_save_data()

	# Create a new inventory and load the data
	var new_inventory = Node.new()
	new_inventory.set_script(load("res://scripts/player/player_inventory.gd"))
	add_child_autofree(new_inventory)
	await wait_frames(1)

	new_inventory.load_save_data(save_data)

	# Verify all items were restored
	assert_eq(new_inventory.get_item_count("kelp_seed"), 25, "Should restore kelp_seed count")
	assert_eq(new_inventory.get_item_count("seagrass"), 10, "Should restore seagrass count")
	assert_eq(new_inventory.get_item_count("coral_fragment"), 7, "Should restore coral_fragment count")

	var quickslot0 = new_inventory.get_quickslot(0)
	assert_eq(quickslot0.item_type, "shovel", "Should restore quickslot 0")

	var quickslot2 = new_inventory.get_quickslot(2)
	assert_eq(quickslot2.item_type, "watering_can", "Should restore quickslot 2")


func test_inventory_load_empty_save_data():
	"""Test loading empty save data doesn't crash"""
	# Add some items first
	player_inventory.add_item("kelp_seed", 5)

	var save_data = {
		"inventory_slots": [],
		"quickslots": []
	}

	# Should not crash
	player_inventory.load_save_data(save_data)

	# Inventory should still be valid
	assert_not_null(player_inventory.get_inventory(), "Inventory should still exist")


func test_inventory_load_missing_fields():
	"""Test loading save data with missing fields uses defaults"""
	var save_data = {}

	# Should not crash
	player_inventory.load_save_data(save_data)

	# Inventory should still be valid
	assert_not_null(player_inventory.get_inventory(), "Inventory should still exist")


func test_player_load_missing_position():
	"""Test loading save data with missing position field"""
	var save_data = {
		"boat_unlocked": true
	}

	# Set initial position
	player.global_position = Vector2(50, 50)

	# Load data without position
	player.load_save_data(save_data)

	# Position should remain unchanged
	assert_almost_eq(player.global_position.x, 50.0, 0.01, "Should keep x position")
	assert_almost_eq(player.global_position.y, 50.0, 0.01, "Should keep y position")

	# But boat_unlocked should be loaded
	assert_true(player.boat_unlocked, "Should still load boat_unlocked")


func test_player_load_missing_boat_unlocked():
	"""Test loading save data with missing boat_unlocked field"""
	var save_data = {
		"position": {"x": 100.0, "y": 200.0}
	}

	# Set initial boat state
	player.boat_unlocked = true

	# Load data without boat_unlocked
	player.load_save_data(save_data)

	# Position should be loaded
	assert_almost_eq(player.global_position.x, 100.0, 0.01, "Should load x position")
	assert_almost_eq(player.global_position.y, 200.0, 0.01, "Should load y position")

	# boat_unlocked should remain unchanged
	assert_true(player.boat_unlocked, "Should keep boat_unlocked state")
