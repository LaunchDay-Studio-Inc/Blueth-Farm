extends Node
## Player tool system controller
##
## Manages the player's tools and tool usage.
## Handles tool equipping, usage, and input for tool quickslots.

## Emitted when a tool is equipped
signal tool_equipped(tool_type: ToolType)

## Emitted when a tool is used
signal tool_used(tool_type: ToolType, target: Vector2)

## Available tool types
enum ToolType {
	NONE = -1,
	SPADE = 0,
	SEED_BAG = 1,
	WATER_TESTER = 2,
	COLLECTION_NET = 3,
	MONITORING_KIT = 4
}

## Currently equipped tool
var current_tool: ToolType = ToolType.NONE

## Tool names for display and identification
const TOOL_NAMES := {
	ToolType.NONE: "None",
	ToolType.SPADE: "Spade",
	ToolType.SEED_BAG: "Seed Bag",
	ToolType.WATER_TESTER: "Water Tester",
	ToolType.COLLECTION_NET: "Collection Net",
	ToolType.MONITORING_KIT: "Monitoring Kit"
}

## Mapping of tool slots to tool types
var _tool_slots: Array[ToolType] = [
	ToolType.NONE,
	ToolType.NONE,
	ToolType.NONE,
	ToolType.NONE,
	ToolType.NONE
]

## Whether tool input is enabled
var _input_enabled: bool = true


func _ready() -> void:
	# Initialize default tool configuration
	_tool_slots[0] = ToolType.SPADE
	_tool_slots[1] = ToolType.SEED_BAG
	_tool_slots[2] = ToolType.WATER_TESTER
	_tool_slots[3] = ToolType.COLLECTION_NET
	_tool_slots[4] = ToolType.MONITORING_KIT


func _input(event: InputEvent) -> void:
	if not _input_enabled:
		return
	
	# Handle tool slot selection (1-5 keys)
	if event.is_action_pressed("tool_slot_1"):
		_equip_tool_from_slot(0)
	elif event.is_action_pressed("tool_slot_2"):
		_equip_tool_from_slot(1)
	elif event.is_action_pressed("tool_slot_3"):
		_equip_tool_from_slot(2)
	elif event.is_action_pressed("tool_slot_4"):
		_equip_tool_from_slot(3)
	elif event.is_action_pressed("tool_slot_5"):
		_equip_tool_from_slot(4)


## Equips a tool from a specific slot
func _equip_tool_from_slot(slot_index: int) -> void:
	if slot_index >= 0 and slot_index < _tool_slots.size():
		equip_tool(_tool_slots[slot_index])


## Equips a specific tool type
func equip_tool(tool_type: ToolType) -> void:
	if current_tool == tool_type:
		return
	
	current_tool = tool_type
	tool_equipped.emit(tool_type)
	
	if tool_type != ToolType.NONE:
		print("Equipped: ", TOOL_NAMES[tool_type])
	else:
		print("Unequipped tool")


## Uses the currently equipped tool at a target position
func use_tool(target_position: Vector2) -> void:
	if current_tool == ToolType.NONE:
		push_warning("No tool equipped")
		return
	
	# Emit signal for other systems to handle tool usage
	tool_used.emit(current_tool, target_position)
	
	# Tool-specific logic can be handled by connected systems
	_perform_tool_action(current_tool, target_position)


## Performs the tool-specific action
func _perform_tool_action(tool_type: ToolType, target: Vector2) -> void:
	match tool_type:
		ToolType.SPADE:
			print("Using Spade at position: ", target)
		ToolType.SEED_BAG:
			print("Using Seed Bag at position: ", target)
		ToolType.WATER_TESTER:
			print("Using Water Tester at position: ", target)
		ToolType.COLLECTION_NET:
			print("Using Collection Net at position: ", target)
		ToolType.MONITORING_KIT:
			print("Using Monitoring Kit at position: ", target)
		_:
			print("Unknown tool used")


## Gets the name of the currently equipped tool
func get_current_tool_name() -> String:
	return TOOL_NAMES.get(current_tool, "Unknown")


## Checks if a specific tool is equipped
func is_tool_equipped(tool_type: ToolType) -> bool:
	return current_tool == tool_type


## Unequips the current tool
func unequip_tool() -> void:
	equip_tool(ToolType.NONE)


## Sets which tool is assigned to a specific slot (0-4)
func set_tool_slot(slot_index: int, tool_type: ToolType) -> bool:
	if slot_index < 0 or slot_index >= _tool_slots.size():
		return false
	
	_tool_slots[slot_index] = tool_type
	return true


## Gets the tool assigned to a specific slot
func get_tool_slot(slot_index: int) -> ToolType:
	if slot_index >= 0 and slot_index < _tool_slots.size():
		return _tool_slots[slot_index]
	return ToolType.NONE


## Enables or disables tool input
func set_input_enabled(enabled: bool) -> void:
	_input_enabled = enabled


## Gets whether tool input is enabled
func is_input_enabled() -> bool:
	return _input_enabled


## Gets all configured tool slots
func get_all_tool_slots() -> Array[ToolType]:
	return _tool_slots
