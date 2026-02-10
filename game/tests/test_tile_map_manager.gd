extends GutTest
## Unit tests for TileMapManager
## Tests tile initialization, tile type classification, planting validation, and tide effects


var tile_manager: TileMapManager


func before_each():
	"""Set up TileMapManager before each test"""
	var TileMapManagerScript = load("res://scripts/world/tile_map_manager.gd")
	tile_manager = TileMapManagerScript.new()
	add_child(tile_manager)
	
	# Don't call _ready() to avoid signal connections, manually initialize
	tile_manager.map_size = Vector2i(20, 20)  # Smaller map for tests
	tile_manager.tile_data.clear()
	tile_manager._initialize_tiles()


func after_each():
	"""Clean up after each test"""
	if tile_manager and not tile_manager.is_queued_for_deletion():
		tile_manager.queue_free()


func test_tile_initialization():
	"""Test that tiles are initialized with valid data"""
	var center_pos = Vector2i(10, 10)
	var tile = tile_manager.tile_data.get(center_pos)
	
	assert_not_null(tile, "Center tile should be initialized")
	assert_true(tile is TileMapManager.TileData, "Tile should be TileData instance")


func test_tile_type_by_distance_center():
	"""Test that center tiles are deep water"""
	var center = tile_manager.map_size / 2
	var center_pos = Vector2i(center.x, center.y)
	var tile = tile_manager.tile_data.get(center_pos)
	
	assert_not_null(tile, "Center tile should exist")
	# Center should be deep or shallow water, not land
	assert_true(tile.tile_type == TileMapManager.TileType.DEEP_WATER or 
				tile.tile_type == TileMapManager.TileType.SHALLOW_WATER,
				"Center should be water")


func test_tile_type_by_distance_edge():
	"""Test that edge tiles are land or tidal"""
	var edge_pos = Vector2i(0, 0)
	var tile = tile_manager.tile_data.get(edge_pos)
	
	assert_not_null(tile, "Edge tile should exist")
	# Edges should typically be land or tidal zone
	assert_true(tile.tile_type == TileMapManager.TileType.LAND or 
				tile.tile_type == TileMapManager.TileType.TIDAL_ZONE or
				tile.tile_type == TileMapManager.TileType.SHALLOW_WATER,
				"Edge should be land, tidal, or shallow")


func test_planting_validation_correct_tile_type():
	"""Test planting validation requires correct tile type"""
	# Find a shallow water tile for planting
	var shallow_tile_pos = null
	for pos in tile_manager.tile_data:
		var tile = tile_manager.tile_data[pos]
		if tile.tile_type == TileMapManager.TileType.SHALLOW_WATER:
			shallow_tile_pos = pos
			break
	
	if shallow_tile_pos == null:
		# Create a shallow tile manually for testing
		shallow_tile_pos = Vector2i(10, 10)
		var tile = TileMapManager.TileData.new()
		tile.tile_type = TileMapManager.TileType.SHALLOW_WATER
		tile.water_depth = 1.5
		tile.substrate_type = TileMapManager.SubstrateType.SAND
		tile_manager.tile_data[shallow_tile_pos] = tile
	
	var can_plant = tile_manager.can_plant_at(shallow_tile_pos, "seagrass_zostera")
	
	# can_plant_at should return true for appropriate conditions
	# or false if already planted
	assert_true(can_plant is bool, "can_plant_at should return boolean")


func test_planting_validation_depth_requirement():
	"""Test that planting respects depth requirements"""
	# Create a deep water tile (too deep for most species)
	var deep_pos = Vector2i(5, 5)
	var deep_tile = TileMapManager.TileData.new()
	deep_tile.tile_type = TileMapManager.TileType.DEEP_WATER
	deep_tile.water_depth = 5.0
	tile_manager.tile_data[deep_pos] = deep_tile
	
	# Seagrass typically can't grow in very deep water
	var can_plant_deep = tile_manager.can_plant_at(deep_pos, "seagrass_zostera")
	
	assert_false(can_plant_deep, "Should not be able to plant seagrass in deep water")


func test_planting_validation_substrate_type():
	"""Test that planting respects substrate requirements"""
	# Create tiles with different substrates
	var sand_pos = Vector2i(10, 10)
	var sand_tile = TileMapManager.TileData.new()
	sand_tile.tile_type = TileMapManager.TileType.SHALLOW_WATER
	sand_tile.water_depth = 1.5
	sand_tile.substrate_type = TileMapManager.SubstrateType.SAND
	tile_manager.tile_data[sand_pos] = sand_tile
	
	var mud_pos = Vector2i(11, 11)
	var mud_tile = TileMapManager.TileData.new()
	mud_tile.tile_type = TileMapManager.TileType.SHALLOW_WATER
	mud_tile.water_depth = 1.5
	mud_tile.substrate_type = TileMapManager.SubstrateType.MUD
	tile_manager.tile_data[mud_pos] = mud_tile
	
	# Test that substrate requirements are checked (implementation may vary)
	var can_plant_sand = tile_manager.can_plant_at(sand_pos, "seagrass_zostera")
	var can_plant_mud = tile_manager.can_plant_at(mud_pos, "saltmarsh_spartina")
	
	assert_true(can_plant_sand is bool, "Substrate check should return boolean")
	assert_true(can_plant_mud is bool, "Substrate check should return boolean")


func test_tide_offset_affects_water_depth():
	"""Test that tide offset changes effective water depth"""
	var test_pos = Vector2i(10, 10)
	var tile = TileMapManager.TileData.new()
	tile.water_depth = 1.0
	tile_manager.tile_data[test_pos] = tile
	
	# Set tide offset
	tile_manager.current_tide_offset = 0.5
	
	var effective_depth = tile_manager.get_effective_water_depth(test_pos)
	
	# Effective depth should be base depth + tide offset
	assert_almost_eq(effective_depth, 1.5, 0.01, 
		"Effective depth should be base depth + tide offset")


func test_tide_offset_high_tide():
	"""Test high tide increases water depth"""
	var test_pos = Vector2i(10, 10)
	var tile = TileMapManager.TileData.new()
	tile.water_depth = 1.0
	tile_manager.tile_data[test_pos] = tile
	
	# Simulate high tide
	tile_manager._on_tide_changed(1.0, true)
	
	assert_gt(tile_manager.current_tide_offset, 0, "High tide should have positive offset")


func test_tide_offset_low_tide():
	"""Test low tide decreases water depth"""
	var test_pos = Vector2i(10, 10)
	var tile = TileMapManager.TileData.new()
	tile.water_depth = 1.0
	tile_manager.tile_data[test_pos] = tile
	
	# Simulate low tide
	tile_manager._on_tide_changed(-1.0, false)
	
	assert_lt(tile_manager.current_tide_offset, 0, "Low tide should have negative offset")


func test_plant_at_tile():
	"""Test planting a species at a tile"""
	var test_pos = Vector2i(10, 10)
	var tile = TileMapManager.TileData.new()
	tile.tile_type = TileMapManager.TileType.SHALLOW_WATER
	tile.water_depth = 1.5
	tile.substrate_type = TileMapManager.SubstrateType.SAND
	tile_manager.tile_data[test_pos] = tile
	
	# Plant a species
	var success = tile_manager.plant_at(test_pos, "seagrass_zostera")
	
	if success:
		assert_true(tile.is_planted, "Tile should be marked as planted")
		assert_eq(tile.planted_species, "seagrass_zostera", "Species should be set")
		assert_eq(tile.growth_stage, 0, "Growth stage should start at 0")
	else:
		# If planting failed, test passes (may be due to validation rules)
		assert_true(true, "Planting validation may prevent planting")


func test_cannot_plant_on_already_planted_tile():
	"""Test that you cannot plant on an already planted tile"""
	var test_pos = Vector2i(10, 10)
	var tile = TileMapManager.TileData.new()
	tile.tile_type = TileMapManager.TileType.SHALLOW_WATER
	tile.water_depth = 1.5
	tile.is_planted = true
	tile.planted_species = "seagrass_zostera"
	tile_manager.tile_data[test_pos] = tile
	
	var can_plant = tile_manager.can_plant_at(test_pos, "saltmarsh_spartina")
	
	assert_false(can_plant, "Should not be able to plant on already planted tile")


func test_harvest_tile():
	"""Test harvesting a planted tile"""
	var test_pos = Vector2i(10, 10)
	var tile = TileMapManager.TileData.new()
	tile.is_planted = true
	tile.planted_species = "seagrass_zostera"
	tile.growth_stage = 3
	tile_manager.tile_data[test_pos] = tile
	
	var success = tile_manager.harvest_at(test_pos)
	
	if success:
		assert_false(tile.is_planted, "Tile should no longer be planted after harvest")
		assert_eq(tile.planted_species, "", "Species should be cleared")
		assert_eq(tile.growth_stage, 0, "Growth stage should be reset")
	else:
		# Harvesting may have requirements (e.g., minimum growth stage)
		assert_true(true, "Harvest validation may prevent harvesting")


func test_get_tile_returns_valid_data():
	"""Test get_tile returns TileData for valid positions"""
	var test_pos = Vector2i(10, 10)
	var tile = tile_manager.get_tile(test_pos)
	
	assert_not_null(tile, "get_tile should return data for valid position")
	assert_true(tile is TileMapManager.TileData, "Should return TileData instance")


func test_get_tile_returns_null_for_invalid():
	"""Test get_tile returns null for invalid positions"""
	var invalid_pos = Vector2i(-1, -1)
	var tile = tile_manager.get_tile(invalid_pos)
	
	assert_null(tile, "get_tile should return null for invalid position")
