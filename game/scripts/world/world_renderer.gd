extends Node2D
## World renderer for isometric tilemap
## Renders tiles as colored rectangles with the tilemap data

@export var tile_width: int = 64
@export var tile_height: int = 32
@export var show_grid: bool = true

var tile_map_manager: TileMapManager
var hover_tile: Vector2i = Vector2i(-1, -1)


func _ready() -> void:
	# Get reference to TileMapManager
	tile_map_manager = get_node("../TileMapManager")
	if tile_map_manager:
		print("WorldRenderer connected to TileMapManager")
	
	# Request redraw
	queue_redraw()


func _process(_delta: float) -> void:
	# Update hover tile based on mouse position
	var mouse_pos = get_global_mouse_position()
	var tile_pos = screen_to_tile(mouse_pos)
	
	if tile_pos != hover_tile:
		hover_tile = tile_pos
		queue_redraw()


func _draw() -> void:
	if not tile_map_manager:
		return
	
	# Draw all tiles
	for y in range(tile_map_manager.map_size.y):
		for x in range(tile_map_manager.map_size.x):
			var tile_pos = Vector2i(x, y)
			var screen_pos = tile_to_screen(tile_pos)
			
			# Get tile color
			var color = tile_map_manager.get_tile_color(tile_pos)
			
			# Apply damage visual feedback
			var tile = tile_map_manager.get_tile_at(tile_pos)
			if tile and tile.is_planted:
				# Damaged plants appear darker/desaturated
				if tile.plant_health < 1.0:
					var damage_factor = tile.plant_health
					color = color.darkened(0.3 * (1.0 - damage_factor))
					# Also desaturate
					var gray = (color.r + color.g + color.b) / 3.0
					var desat_amount = 0.5 * (1.0 - damage_factor)
					color.r = lerp(color.r, gray, desat_amount)
					color.g = lerp(color.g, gray, desat_amount)
					color.b = lerp(color.b, gray, desat_amount)
			
			# Draw isometric diamond
			_draw_isometric_tile(screen_pos, color)
			
			# Draw hover highlight
			if tile_pos == hover_tile:
				_draw_isometric_tile(screen_pos, Color(1, 1, 1, 0.3))
	
	# Draw grid if enabled
	if show_grid:
		_draw_grid()


func _draw_isometric_tile(pos: Vector2, color: Color) -> void:
	"""Draw an isometric tile diamond"""
	var half_w = tile_width / 2
	var half_h = tile_height / 2
	
	var points = PackedVector2Array([
		pos + Vector2(0, -half_h),      # Top
		pos + Vector2(half_w, 0),       # Right
		pos + Vector2(0, half_h),       # Bottom
		pos + Vector2(-half_w, 0)       # Left
	])
	
	# Fill
	draw_colored_polygon(points, color)
	
	# Outline
	draw_polyline(points + PackedVector2Array([points[0]]), Color(0, 0, 0, 0.3), 1.0)


func _draw_grid() -> void:
	"""Draw grid lines"""
	var grid_color = Color(0, 0, 0, 0.1)
	
	# Draw horizontal lines
	for y in range(tile_map_manager.map_size.y + 1):
		var start = tile_to_screen(Vector2i(0, y))
		var end = tile_to_screen(Vector2i(tile_map_manager.map_size.x, y))
		draw_line(start, end, grid_color, 1.0)
	
	# Draw vertical lines
	for x in range(tile_map_manager.map_size.x + 1):
		var start = tile_to_screen(Vector2i(x, 0))
		var end = tile_to_screen(Vector2i(x, tile_map_manager.map_size.y))
		draw_line(start, end, grid_color, 1.0)


func tile_to_screen(tile_pos: Vector2i) -> Vector2:
	"""Convert tile coordinates to screen position (isometric)"""
	var x = (tile_pos.x - tile_pos.y) * (tile_width / 2)
	var y = (tile_pos.x + tile_pos.y) * (tile_height / 2)
	return Vector2(x, y) + Vector2(tile_width * 25, tile_height * 5)  # Center offset


func screen_to_tile(screen_pos: Vector2) -> Vector2i:
	"""Convert screen position to tile coordinates (isometric)"""
	# Remove offset
	var adjusted = screen_pos - Vector2(tile_width * 25, tile_height * 5)
	
	# Convert from isometric to tile coordinates
	var tile_x = (adjusted.x / (tile_width / 2) + adjusted.y / (tile_height / 2)) / 2
	var tile_y = (adjusted.y / (tile_height / 2) - adjusted.x / (tile_width / 2)) / 2
	
	return Vector2i(int(tile_x), int(tile_y))


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var tile_pos = screen_to_tile(get_global_mouse_position())
			if tile_map_manager:
				tile_map_manager.tile_clicked.emit(tile_pos)
				print("Clicked tile: ", tile_pos)
