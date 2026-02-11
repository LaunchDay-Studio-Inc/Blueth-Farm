extends Node
## Player inventory management system
##
## Manages a grid-based inventory system with main storage and quickslot bar.
## Handles item stacking, adding, removing, and querying items.

## Emitted when inventory contents change
signal inventory_changed()

## Inventory grid dimensions
const GRID_WIDTH: int = 10
const GRID_HEIGHT: int = 4
const TOTAL_SLOTS: int = GRID_WIDTH * GRID_HEIGHT

## Quickslot bar size
const QUICKSLOT_COUNT: int = 5

## Inventory slot data structure
class InventorySlot:
	var item_type: String = ""
	var quantity: int = 0
	var max_stack: int = 99
	
	func is_empty() -> bool:
		return item_type.is_empty() or quantity <= 0
	
	func can_add(amount: int) -> bool:
		return quantity + amount <= max_stack
	
	func add(amount: int) -> int:
		var space_available := max_stack - quantity
		var amount_to_add := min(amount, space_available)
		quantity += amount_to_add
		return amount_to_add
	
	func remove(amount: int) -> int:
		var amount_to_remove := min(amount, quantity)
		quantity -= amount_to_remove
		if quantity <= 0:
			clear()
		return amount_to_remove
	
	func clear() -> void:
		item_type = ""
		quantity = 0
	
	func set_item(type: String, qty: int, max: int = 99) -> void:
		item_type = type
		quantity = qty
		max_stack = max

## Main inventory storage
var _inventory: Array[InventorySlot] = []

## Quickslot bar for tools
var _quickslots: Array[InventorySlot] = []


func _ready() -> void:
	_initialize_inventory()


## Initializes all inventory slots
func _initialize_inventory() -> void:
	_inventory.clear()
	_quickslots.clear()
	
	# Create main inventory slots
	for i in range(TOTAL_SLOTS):
		_inventory.append(InventorySlot.new())
	
	# Create quickslot slots
	for i in range(QUICKSLOT_COUNT):
		_quickslots.append(InventorySlot.new())


## Adds an item to the inventory
## Returns true if all items were added, false if inventory is full
func add_item(item_type: String, quantity: int, max_stack: int = 99) -> bool:
	if item_type.is_empty() or quantity <= 0:
		return false
	
	var remaining := quantity
	
	# First, try to stack with existing items
	for slot in _inventory:
		if slot.item_type == item_type and not slot.is_empty():
			var added := slot.add(remaining)
			remaining -= added
			if remaining <= 0:
				inventory_changed.emit()
				return true
	
	# Then, try to add to empty slots
	for slot in _inventory:
		if slot.is_empty():
			slot.set_item(item_type, 0, max_stack)
			var added := slot.add(remaining)
			remaining -= added
			if remaining <= 0:
				inventory_changed.emit()
				return true
	
	# If there's still remaining items, inventory is full
	if remaining > 0:
		inventory_changed.emit()
		return false
	
	inventory_changed.emit()
	return true


## Removes an item from the inventory
## Returns the actual amount removed
func remove_item(item_type: String, quantity: int) -> int:
	if item_type.is_empty() or quantity <= 0:
		return 0
	
	var remaining := quantity
	
	# Remove from slots containing this item
	for slot in _inventory:
		if slot.item_type == item_type and not slot.is_empty():
			var removed := slot.remove(remaining)
			remaining -= removed
			if remaining <= 0:
				break
	
	var total_removed := quantity - remaining
	if total_removed > 0:
		inventory_changed.emit()
	
	return total_removed


## Checks if the inventory contains an item
func has_item(item_type: String, quantity: int = 1) -> bool:
	return get_item_count(item_type) >= quantity


## Gets the total count of an item in the inventory
func get_item_count(item_type: String) -> int:
	var total := 0
	
	for slot in _inventory:
		if slot.item_type == item_type:
			total += slot.quantity
	
	return total


## Gets a slot at a specific index
func get_slot(index: int) -> InventorySlot:
	if index >= 0 and index < _inventory.size():
		return _inventory[index]
	return null


## Gets the entire inventory array
func get_inventory() -> Array[InventorySlot]:
	return _inventory


## Clears the entire inventory
func clear_inventory() -> void:
	for slot in _inventory:
		slot.clear()
	inventory_changed.emit()


## Adds an item to a specific quickslot
func set_quickslot(slot_index: int, item_type: String, quantity: int = 1, max_stack: int = 99) -> bool:
	if slot_index < 0 or slot_index >= QUICKSLOT_COUNT:
		return false
	
	_quickslots[slot_index].set_item(item_type, quantity, max_stack)
	inventory_changed.emit()
	return true


## Gets a quickslot at a specific index
func get_quickslot(index: int) -> InventorySlot:
	if index >= 0 and index < _quickslots.size():
		return _quickslots[index]
	return null


## Clears a specific quickslot
func clear_quickslot(slot_index: int) -> void:
	if slot_index >= 0 and slot_index < QUICKSLOT_COUNT:
		_quickslots[slot_index].clear()
		inventory_changed.emit()


## Gets all quickslots
func get_quickslots() -> Array[InventorySlot]:
	return _quickslots


## Swaps two inventory slots
func swap_slots(index_a: int, index_b: int) -> bool:
	if index_a < 0 or index_a >= _inventory.size():
		return false
	if index_b < 0 or index_b >= _inventory.size():
		return false
	
	var temp := InventorySlot.new()
	var slot_a := _inventory[index_a]
	var slot_b := _inventory[index_b]
	
	temp.set_item(slot_a.item_type, slot_a.quantity, slot_a.max_stack)
	slot_a.set_item(slot_b.item_type, slot_b.quantity, slot_b.max_stack)
	slot_b.set_item(temp.item_type, temp.quantity, temp.max_stack)
	
	inventory_changed.emit()
	return true


## Gets all items and their quantities as a dictionary
## Returns: Dictionary with item types as keys and quantities as values
func get_all_items() -> Dictionary:
	var items: Dictionary = {}
	
	for slot in _inventory:
		if not slot.is_empty():
			if items.has(slot.item_type):
				items[slot.item_type] += slot.quantity
			else:
				items[slot.item_type] = slot.quantity
	
	return items


## Loads inventory from saved data
## Data format: Dictionary with item types as keys and quantities as values
func load_inventory(data: Dictionary) -> void:
	# Clear existing inventory
	clear_inventory()

	# Add items from data
	for item_type in data.keys():
		var quantity: int = data[item_type]
		add_item(item_type, quantity)

	inventory_changed.emit()


## Gets save data for the inventory system
func get_save_data() -> Dictionary:
	var inventory_data = {}

	# Save main inventory slots with their complete state
	var slots_data = []
	for slot in _inventory:
		if not slot.is_empty():
			slots_data.append({
				"item_type": slot.item_type,
				"quantity": slot.quantity,
				"max_stack": slot.max_stack
			})
		else:
			slots_data.append({})

	# Save quickslots with their complete state
	var quickslots_data = []
	for slot in _quickslots:
		if not slot.is_empty():
			quickslots_data.append({
				"item_type": slot.item_type,
				"quantity": slot.quantity,
				"max_stack": slot.max_stack
			})
		else:
			quickslots_data.append({})

	return {
		"inventory_slots": slots_data,
		"quickslots": quickslots_data
	}


## Loads save data for the inventory system
func load_save_data(data: Dictionary) -> void:
	# Load main inventory slots
	if "inventory_slots" in data:
		var slots_data = data["inventory_slots"]
		for i in range(min(slots_data.size(), _inventory.size())):
			var slot_data = slots_data[i]
			if slot_data.is_empty():
				_inventory[i].clear()
			else:
				_inventory[i].set_item(
					slot_data.get("item_type", ""),
					slot_data.get("quantity", 0),
					slot_data.get("max_stack", 99)
				)

	# Load quickslots
	if "quickslots" in data:
		var quickslots_data = data["quickslots"]
		for i in range(min(quickslots_data.size(), _quickslots.size())):
			var slot_data = quickslots_data[i]
			if slot_data.is_empty():
				_quickslots[i].clear()
			else:
				_quickslots[i].set_item(
					slot_data.get("item_type", ""),
					slot_data.get("quantity", 0),
					slot_data.get("max_stack", 99)
				)

	inventory_changed.emit()
