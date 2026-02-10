extends Node
class_name MarketSystem
## Market system for buying seeds and selling harvested goods
## Manages dynamic pricing based on supply/demand and seasons

signal item_purchased(item_id: String, quantity: int, price: int)
signal item_sold(item_id: String, quantity: int, price: int)
signal market_opened()
signal market_closed()

# Market hours (game time)
const MARKET_OPEN_HOUR: int = 8
const MARKET_CLOSE_HOUR: int = 18

# Base prices for seeds (gold per item)
const SEED_BASE_PRICES: Dictionary = {
	"eelgrass_seed": 10,
	"cordgrass_seed": 12,
	"red_mangrove_seed": 25,
	"giant_kelp_seed": 20,
	"posidonia_seed": 30,
	"thalassia_seed": 15,
	"salicornia_seed": 8,
	"black_mangrove_seed": 22,
	"laminaria_seed": 18
}

# Base prices for harvested goods (gold per item)
const HARVEST_BASE_PRICES: Dictionary = {
	"oyster": 8,
	"fish": 12,
	"seaweed": 6,
	"crab": 10,
	"kelp": 5,
	"glasswort": 7,
	"rare_ingredient": 25
}

# Seasonal price modifiers
const SEASONAL_MODIFIERS: Dictionary = {
	"spring": {"seagrass_seeds": 0.8, "harvest": 1.0},
	"summer": {"seagrass_seeds": 1.0, "harvest": 1.2},
	"fall": {"seagrass_seeds": 1.1, "harvest": 1.3},
	"winter": {"seagrass_seeds": 1.3, "harvest": 0.9}
}

var is_market_open: bool = false
var current_season: String = "spring"


func _ready() -> void:
	# Connect to TimeManager for hour/season updates
	if TimeManager:
		TimeManager.time_tick.connect(_on_time_tick)
		TimeManager.season_changed.connect(_on_season_changed)
		# Initialize market state based on current time
		var current_hour = TimeManager.current_hour
		is_market_open = current_hour >= MARKET_OPEN_HOUR and current_hour < MARKET_CLOSE_HOUR
		# Initialize season
		current_season = _get_season_name(TimeManager.current_season)


func _on_time_tick(hour: int, _minute: int) -> void:
	"""Check if market should open/close"""
	var was_open = is_market_open
	is_market_open = hour >= MARKET_OPEN_HOUR and hour < MARKET_CLOSE_HOUR
	
	if is_market_open and not was_open:
		market_opened.emit()
	elif not is_market_open and was_open:
		market_closed.emit()


func _on_season_changed(season: int) -> void:
	"""Update current season for pricing"""
	current_season = _get_season_name(season)


func _get_season_name(season_enum: int) -> String:
	"""Convert season enum to string"""
	match season_enum:
		0: return "spring"
		1: return "summer"
		2: return "fall"
		3: return "winter"
		_: return "spring"


func get_buy_price(item_id: String, quantity: int = 1) -> int:
	"""Calculate current buying price for an item"""
	var base_price = SEED_BASE_PRICES.get(item_id, 0)
	if base_price == 0:
		return 0
	
	# Apply seasonal modifier
	var season_mod = 1.0
	if "seagrass" in item_id and current_season in SEASONAL_MODIFIERS:
		season_mod = SEASONAL_MODIFIERS[current_season].get("seagrass_seeds", 1.0)
	
	var final_price = int(base_price * season_mod * quantity)
	return final_price


func get_sell_price(item_id: String, quantity: int = 1) -> int:
	"""Calculate current selling price for a harvested item"""
	var base_price = HARVEST_BASE_PRICES.get(item_id, 0)
	if base_price == 0:
		return 0
	
	# Apply seasonal modifier
	var season_mod = 1.0
	if current_season in SEASONAL_MODIFIERS:
		season_mod = SEASONAL_MODIFIERS[current_season].get("harvest", 1.0)
	
	var final_price = int(base_price * season_mod * quantity)
	return final_price


func can_buy(item_id: String, quantity: int = 1) -> bool:
	"""Check if player can afford to buy item"""
	if not is_market_open:
		return false
	
	var price = get_buy_price(item_id, quantity)
	if price == 0:
		return false
	
	return GameManager.gold >= price


func buy_item(item_id: String, quantity: int = 1) -> bool:
	"""Purchase an item from the market"""
	if not can_buy(item_id, quantity):
		return false
	
	var price = get_buy_price(item_id, quantity)
	
	# Deduct gold
	if not GameManager.spend_gold(price):
		return false
	
	# Add item to player inventory
	# Get player's inventory component
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("PlayerInventory"):
		var inventory = player.get_node("PlayerInventory")
		if inventory.has_method("add_item"):
			inventory.add_item(item_id, quantity)
	
	item_purchased.emit(item_id, quantity, price)
	return true


func can_sell(item_id: String, quantity: int = 1) -> bool:
	"""Check if player has item to sell"""
	if not is_market_open:
		return false
	
	# Check if item exists in harvest prices
	if item_id not in HARVEST_BASE_PRICES:
		return false
	
	# Check player inventory
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("PlayerInventory"):
		var inventory = player.get_node("PlayerInventory")
		if inventory.has_method("get_item_count"):
			return inventory.get_item_count(item_id) >= quantity
	
	return false


func sell_item(item_id: String, quantity: int = 1) -> bool:
	"""Sell a harvested item to the market"""
	if not can_sell(item_id, quantity):
		return false
	
	var price = get_sell_price(item_id, quantity)
	
	# Remove item from inventory
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("PlayerInventory"):
		var inventory = player.get_node("PlayerInventory")
		if inventory.has_method("remove_item"):
			if not inventory.remove_item(item_id, quantity):
				return false
	
	# Add gold
	GameManager.add_gold(price)
	
	item_sold.emit(item_id, quantity, price)
	return true


func get_market_status_text() -> String:
	"""Get human-readable market status"""
	if is_market_open:
		return "Market Open (8 AM - 6 PM)"
	else:
		return "Market Closed (Opens at 8 AM)"


func get_all_seed_prices() -> Dictionary:
	"""Get all seed prices for display in market UI"""
	var prices = {}
	for seed_id in SEED_BASE_PRICES.keys():
		prices[seed_id] = get_buy_price(seed_id, 1)
	return prices


func get_all_harvest_prices() -> Dictionary:
	"""Get all harvest prices for display in market UI"""
	var prices = {}
	for item_id in HARVEST_BASE_PRICES.keys():
		prices[item_id] = get_sell_price(item_id, 1)
	return prices
