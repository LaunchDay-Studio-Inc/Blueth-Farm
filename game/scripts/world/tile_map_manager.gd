extends Node
## TileMap manager for isometric game world
## Handles tile properties, interactions, and state

class_name TileMapManager

signal tile_clicked(tile_pos: Vector2i)
signal tile_hovered(tile_pos: Vector2i)
signal tile_planted(tile_pos: Vector2i, species: String)
signal tile_harvested(tile_pos: Vector2i)

enum TileType {
	DEEP_WATER,      # > 3m depth, not plantable
	SHALLOW_WATER,   # 0-3m depth, plantable zone
	TIDAL_ZONE,      # Alternates wet/dry with tides
	SAND,            # Sandy substrate
	MUD,             # Muddy substrate
	ROCKY,           # Rocky substrate
	LAND             # Shoreline, buildings
}

enum SubstrateType {
	SAND,
	MUD,
	ROCKY,
	ORGANIC
}

# Tile data structure
class TileData:
	var tile_type: TileType = TileType.SHALLOW_WATER
	var substrate_type: SubstrateType = SubstrateType.SAND
	var water_depth: float = 1.0  # meters
	var salinity: float = 35.0    # ppt
	var temperature: float = 20.0  # celsius
	var clarity: float = 0.8       # 0-1, water clarity
	
	# Planting data
	var is_planted: bool = false
	var planted_species: String = ""
	var growth_stage: int = 0
	var growth_timer: float = 0.0
	var plant_health: float = 1.0
	
	# Carbon tracking
	var sediment_carbon: float = 0.0
	var biomass_carbon: float = 0.0
	
	func _init():
		pass

# Map data
var map_size: Vector2i = Vector2i(50, 50)
var tile_data: Dictionary = {}  # Vector2i -> TileData

# Current tide offset (affects water depth)
var current_tide_offset: float = 0.0


func _ready() -> void:
	# Connect to TimeManager signals
	TimeManager.tide_changed.connect(_on_tide_changed)
	
	# Initialize tile map
	_initialize_tiles()


func _initialize_tiles() -> void:
	"""Initialize the tile map with default data"""
	print("Initializing tilemap (", map_size.x, "x", map_size.y, ")...")
	
	for x in range(map_size.x):
		for y in range(map_size.y):
			var pos = Vector2i(x, y)
			var tile = TileData.new()
			
			# Create a simple map layout
			# Center is deeper water, edges are land/tidal
			var center = map_size / 2
			var distance_from_center = pos.distance_to(center)
			
			if distance_from_center > 20:
				# Land
				tile.tile_type = TileType.LAND
				tile.water_depth = 0.0
				tile.substrate_type = SubstrateType.SAND
			elif distance_from_center > 15:
				# Tidal zone
				tile.tile_type = TileType.TIDAL_ZONE
				tile.water_depth = 0.5
				tile.substrate_type = SubstrateType.MUD if randf() > 0.5 else SubstrateType.SAND
			elif distance_from_center > 10:
				# Shallow plantable water
				tile.tile_type = TileType.SHALLOW_WATER
				tile.water_depth = 1.5
				tile.substrate_type = SubstrateType.SAND if randf() > 0.3 else SubstrateType.MUD
			else:
				# Deep water
				tile.tile_type = TileType.DEEP_WATER
				tile.water_depth = 5.0
				tile.substrate_type = SubstrateType.MUD
			
			tile_data[pos] = tile
	
	print("Tilemap initialized with ", tile_data.size(), " tiles")


func _on_tide_changed(tide_level: float, is_high_tide: bool) -> void:
	"""Update water depths based on tide"""
	# Tide affects water depth by +/- 1 meter
	current_tide_offset = tide_level
	
	# Update tidal zone tiles
	for pos in tile_data:
		var tile = tile_data[pos]
		if tile.tile_type == TileType.TIDAL_ZONE:
			# Tidal tiles alternate between wet and dry
			var adjusted_depth = tile.water_depth + current_tide_offset
			if adjusted_depth < 0.2:
				# Exposed during low tide
				pass
			else:
				# Submerged during high tide
				pass


func get_tile_at(tile_pos: Vector2i) -> TileData:
	"""Get tile data at position"""
	if tile_pos in tile_data:
		return tile_data[tile_pos]
	return null


func is_tile_plantable(tile_pos: Vector2i) -> bool:
	"""Check if a tile can be planted"""
	var tile = get_tile_at(tile_pos)
	if tile == null:
		return false
	
	# Must be shallow water or tidal zone
	if tile.tile_type not in [TileType.SHALLOW_WATER, TileType.TIDAL_ZONE]:
		return false
	
	# Must not already be planted
	if tile.is_planted:
		return false
	
	# Must have appropriate water depth (accounting for tide)
	var actual_depth = tile.water_depth + current_tide_offset
	if actual_depth < 0.1 or actual_depth > 4.0:
		return false
	
	return true


func plant_species(tile_pos: Vector2i, species_key: String) -> bool:
	"""Plant a species at a tile position"""
	var tile = get_tile_at(tile_pos)
	if tile == null or not is_tile_plantable(tile_pos):
		return false
	
	# Mark tile as planted
	tile.is_planted = true
	tile.planted_species = species_key
	tile.growth_stage = 0
	tile.growth_timer = 0.0
	tile.plant_health = 1.0
	
	# Register with ecosystem manager
	EcosystemManager.register_planted_species(species_key)
	
	# Emit signal
	tile_planted.emit(tile_pos, species_key)
	
	print("Planted ", species_key, " at ", tile_pos)
	return true


func harvest_tile(tile_pos: Vector2i) -> Dictionary:
	"""Harvest a planted tile"""
	var tile = get_tile_at(tile_pos)
	if tile == null or not tile.is_planted:
		return {}
	
	var harvest_data = {
		"species": tile.planted_species,
		"growth_stage": tile.growth_stage,
		"carbon": tile.biomass_carbon
	}
	
	# Remove plant
	var species_key = tile.planted_species
	tile.is_planted = false
	tile.planted_species = ""
	tile.growth_stage = 0
	tile.biomass_carbon = 0.0
	
	# Update managers
	EcosystemManager.unregister_planted_species(species_key)
	CarbonManager.remove_plant_carbon(species_key, harvest_data.growth_stage)
	
	tile_harvested.emit(tile_pos)
	
	print("Harvested ", species_key, " from ", tile_pos)
	return harvest_data


func update_tile_growth(delta: float) -> void:
	"""Update growth for all planted tiles"""
	for pos in tile_data:
		var tile = tile_data[pos]
		if tile.is_planted:
			tile.growth_timer += delta


func get_tile_color(tile_pos: Vector2i) -> Color:
	"""Get the color for a tile (for rendering)"""
	var tile = get_tile_at(tile_pos)
	if tile == null:
		return Color.BLACK
	
	# If planted, get species color
	if tile.is_planted:
		# Would get from species data
		var stage_progress = float(tile.growth_stage) / 5.0
		return Color.GREEN.lerp(Color.DARK_GREEN, stage_progress)
	
	# Otherwise, base color on tile type
	match tile.tile_type:
		TileType.DEEP_WATER:
			return Color("#2E5E8C")  # Ocean Blue
		TileType.SHALLOW_WATER:
			return Color("#6CC4A1")  # Turquoise
		TileType.TIDAL_ZONE:
			if current_tide_offset > 0:
				return Color("#4A90B8")  # Cerulean (wet)
			else:
				return Color("#C4A57B")  # Wet Sand (exposed)
		TileType.SAND:
			return Color("#C4A57B")  # Wet Sand
		TileType.MUD:
			return Color("#8B6F47")  # Mudflat Brown
		TileType.ROCKY:
			return Color("#9E9E9E")  # Driftwood Gray
		TileType.LAND:
			return Color("#4A7C59")  # Mangrove Canopy
	
	return Color.GRAY


func get_save_data() -> Dictionary:
	"""Get tilemap data for saving"""
	var tiles_save = {}
	for pos in tile_data:
		var tile = tile_data[pos]
		if tile.is_planted:  # Only save planted tiles to reduce save size
			tiles_save[var_to_str(pos)] = {
				"planted_species": tile.planted_species,
				"growth_stage": tile.growth_stage,
				"growth_timer": tile.growth_timer,
				"plant_health": tile.plant_health,
				"sediment_carbon": tile.sediment_carbon,
				"biomass_carbon": tile.biomass_carbon
			}
	
	return {
		"map_size": map_size,
		"tiles": tiles_save,
		"current_tide_offset": current_tide_offset
	}


func load_save_data(data: Dictionary) -> void:
	"""Load tilemap data from save"""
	if "map_size" in data:
		map_size = data.map_size
	
	current_tide_offset = data.get("current_tide_offset", 0.0)
	
	# Reinitialize tiles
	_initialize_tiles()
	
	# Load planted tiles
	if "tiles" in data:
		var tiles_save = data.tiles
		for pos_str in tiles_save:
			var pos = str_to_var(pos_str)
			if pos in tile_data:
				var tile = tile_data[pos]
				var tile_save = tiles_save[pos_str]
				tile.is_planted = true
				tile.planted_species = tile_save.planted_species
				tile.growth_stage = tile_save.growth_stage
				tile.growth_timer = tile_save.growth_timer
				tile.plant_health = tile_save.plant_health
				tile.sediment_carbon = tile_save.sediment_carbon
				tile.biomass_carbon = tile_save.biomass_carbon



func damage_plant(tile_pos: Vector2i, damage_amount: float) -> void:
var tile = get_tile_at(tile_pos)
if not tile or not tile.is_planted:
return
tile.plant_health = max(0.0, tile.plant_health - damage_amount)
if tile.plant_health <= 0.0:
remove_dead_plant(tile_pos)
else:
print("Plant damaged at ", tile_pos)


func remove_dead_plant(tile_pos: Vector2i) -> void:
var tile = get_tile_at(tile_pos)
if not tile or not tile.is_planted:
return
var species_key = tile.planted_species
var biomass = tile.biomass_carbon
if biomass > 0:
CarbonManager.remove_plant_carbon(species_key, tile.growth_stage)
var sediment = tile.sediment_carbon
if sediment > 0:
tile.sediment_carbon = sediment * 0.5
tile.is_planted = false
tile.planted_species = ""
tile.growth_stage = 0
tile.growth_timer = 0.0
tile.plant_health = 1.0
tile.biomass_carbon = 0.0
EcosystemManager.unregister_planted_species(species_key)
print("Plant removed at ", tile_pos)


func regress_growth_stage(tile_pos: Vector2i) -> void:
var tile = get_tile_at(tile_pos)
if not tile or not tile.is_planted or tile.growth_stage <= 0:
return
var old_stage = tile.growth_stage
tile.growth_stage -= 1
CarbonManager.remove_plant_carbon(tile.planted_species, old_stage)
CarbonManager.add_plant_carbon(tile.planted_species, tile.growth_stage, 1)
print("Plant regressed at ", tile_pos)
