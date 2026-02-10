extends CharacterBody2D
## Player movement controller for 8-directional isometric movement
##
## Handles player movement using WASD input with support for diagonal movement.
## Emits signals when the player moves to notify other systems.

## Emitted when the player moves to a new position
signal player_moved(position: Vector2)

## Movement speed in pixels per second
const MOVE_SPEED: float = 150.0

## Smoothing factor for velocity interpolation (0.0 = no smoothing, 1.0 = instant)
const VELOCITY_SMOOTHING: float = 0.2

## Target velocity based on input
var _target_velocity: Vector2 = Vector2.ZERO

## Previous position for movement detection
var _previous_position: Vector2 = Vector2.ZERO

## References to world systems
var tile_map_manager: TileMapManager = null
var world_renderer: Node2D = null
var boat_unlocked: bool = false

## Collision feedback
var collision_flash_timer: float = 0.0
const COLLISION_FLASH_DURATION: float = 0.3


func _ready() -> void:
	_previous_position = global_position
	
	# Get references to world systems
	await get_tree().process_frame  # Wait for scene to be ready
	_find_world_references()


func _find_world_references() -> void:
	"""Find and cache references to world systems"""
	var game_world = get_tree().get_first_node_in_group("game_world")
	if not game_world:
		game_world = get_parent()
	
	if game_world:
		tile_map_manager = game_world.get_node_or_null("TileMapManager")
		world_renderer = game_world.get_node_or_null("WorldRenderer")
		
		if tile_map_manager:
			print("Player: Connected to TileMapManager")
		if world_renderer:
			print("Player: Connected to WorldRenderer")


func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_check_position_change()
	_update_collision_flash(delta)


## Handles player movement input and velocity calculation
func _handle_movement(delta: float) -> void:
	# Get input direction from action maps
	var input_direction := Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		input_direction.x += 1.0
	if Input.is_action_pressed("move_left"):
		input_direction.x -= 1.0
	if Input.is_action_pressed("move_down"):
		input_direction.y += 1.0
	if Input.is_action_pressed("move_up"):
		input_direction.y -= 1.0
	
	# Normalize to prevent faster diagonal movement
	if input_direction.length() > 0:
		input_direction = input_direction.normalized()
	
	# Calculate target velocity
	_target_velocity = input_direction * MOVE_SPEED
	
	# Check collision before moving
	if _target_velocity.length() > 0 and not _can_move_to_target():
		# Block movement - show feedback
		_on_collision_blocked()
		_target_velocity = Vector2.ZERO
	
	# Smoothly interpolate current velocity toward target velocity
	velocity = velocity.lerp(_target_velocity, VELOCITY_SMOOTHING)
	
	# Move the character
	move_and_slide()


func _can_move_to_target() -> bool:
	"""Check if the player can move to the target position"""
	if not tile_map_manager or not world_renderer:
		return true  # No collision checking if systems not ready
	
	# Calculate next position
	var next_position = global_position + _target_velocity * get_physics_process_delta_time()
	
	# Convert to tile coordinates
	var tile_pos = world_renderer.screen_to_tile(next_position)
	
	# Check if tile is within bounds
	if tile_pos.x < 0 or tile_pos.x >= tile_map_manager.map_size.x:
		return false
	if tile_pos.y < 0 or tile_pos.y >= tile_map_manager.map_size.y:
		return false
	
	# Get tile data
	var tile = tile_map_manager.get_tile_at(tile_pos)
	if not tile:
		return false
	
	# Check tile type - block deep water unless boat is unlocked
	if tile.tile_type == TileMapManager.TileType.DEEP_WATER and not boat_unlocked:
		return false
	
	# Allow movement on all other tile types
	return true


func _on_collision_blocked() -> void:
	"""Visual feedback when movement is blocked"""
	collision_flash_timer = COLLISION_FLASH_DURATION
	
	# Optional: Show notification (commented out to avoid spam)
	# var notification_system = get_node_or_null("/root/GameWorld/NotificationSystem")
	# if notification_system:
	#	notification_system.show_notification("Can't go there!", 6)


func _update_collision_flash(delta: float) -> void:
	"""Update visual feedback for collision"""
	if collision_flash_timer > 0:
		collision_flash_timer -= delta
		# Flash red
		var flash_intensity = collision_flash_timer / COLLISION_FLASH_DURATION
		modulate = Color(1.0 + flash_intensity * 0.5, 1.0 - flash_intensity * 0.3, 1.0 - flash_intensity * 0.3)
	else:
		modulate = Color.WHITE


## Checks if position has changed and emits signal
func _check_position_change() -> void:
	if global_position != _previous_position:
		player_moved.emit(global_position)
		_previous_position = global_position


## Gets the current movement direction (normalized)
func get_movement_direction() -> Vector2:
	return velocity.normalized() if velocity.length() > 0 else Vector2.ZERO


## Gets the current facing direction as a string (N, NE, E, SE, S, SW, W, NW)
func get_facing_direction() -> String:
	var direction := get_movement_direction()
	
	if direction.length() == 0:
		return ""
	
	# Calculate angle in degrees (0 = right, 90 = down, 180 = left, 270 = up)
	var angle := rad_to_deg(direction.angle())
	
	# Normalize to 0-360
	if angle < 0:
		angle += 360
	
	# Determine 8-directional facing
	if angle >= 337.5 or angle < 22.5:
		return "E"
	elif angle >= 22.5 and angle < 67.5:
		return "SE"
	elif angle >= 67.5 and angle < 112.5:
		return "S"
	elif angle >= 112.5 and angle < 157.5:
		return "SW"
	elif angle >= 157.5 and angle < 202.5:
		return "W"
	elif angle >= 202.5 and angle < 247.5:
		return "NW"
	elif angle >= 247.5 and angle < 292.5:
		return "N"
	else:  # 292.5 to 337.5
		return "NE"
	
	return ""


## Stops all player movement
func stop_movement() -> void:
	velocity = Vector2.ZERO
	_target_velocity = Vector2.ZERO



