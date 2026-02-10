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


func _ready() -> void:
	_previous_position = global_position


func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_check_position_change()


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
	
	# Smoothly interpolate current velocity toward target velocity
	velocity = velocity.lerp(_target_velocity, VELOCITY_SMOOTHING)
	
	# Move the character
	move_and_slide()


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


## Sets the player's movement speed
func set_movement_speed(speed: float) -> void:
	# Note: This would require making MOVE_SPEED a variable instead of const
	push_warning("set_movement_speed called but MOVE_SPEED is const")
