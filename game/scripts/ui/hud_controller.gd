extends CanvasLayer
## In-game HUD controller
## Displays time, tool, carbon, tide, and gold

@onready var time_label = $MarginContainer/HBoxContainer/LeftPanel/TimeLabel
@onready var season_label = $MarginContainer/HBoxContainer/LeftPanel/SeasonLabel
@onready var tool_label = $MarginContainer/HBoxContainer/LeftPanel/ToolLabel

@onready var carbon_label = $MarginContainer/HBoxContainer/RightPanel/CarbonLabel
@onready var gold_label = $MarginContainer/HBoxContainer/RightPanel/GoldLabel
@onready var tide_label = $MarginContainer/HBoxContainer/RightPanel/TideLabel


func _ready() -> void:
	# Connect to manager signals
	TimeManager.time_tick.connect(_on_time_tick)
	TimeManager.tide_changed.connect(_on_tide_changed)
	TimeManager.season_changed.connect(_on_season_changed)
	CarbonManager.carbon_updated.connect(_on_carbon_updated)
	
	# Initial update
	_update_all()


func _process(_delta: float) -> void:
	# Update time and gold every frame for smooth updates
	if time_label:
		time_label.text = "Time: " + TimeManager.get_time_of_day()
	if gold_label:
		gold_label.text = "Gold: " + str(GameManager.gold)


func _update_all() -> void:
	"""Update all HUD elements"""
	if time_label:
		time_label.text = "Time: " + TimeManager.get_time_of_day()
	
	if season_label:
		season_label.text = "Season: " + TimeManager.get_season_name()
	
	if gold_label:
		gold_label.text = "Gold: " + str(GameManager.gold)
	
	if carbon_label:
		var total = CarbonManager.total_co2_sequestered
		carbon_label.text = "Carbon: %.1f t CO₂" % total
	
	if tide_label:
		var tide = TimeManager.tide_level
		var tide_str = "High" if tide > 0.5 else ("Low" if tide < -0.5 else "Mid")
		tide_label.text = "Tide: " + tide_str


func _on_time_tick(hour: int, minute: int) -> void:
	"""Update when time changes"""
	if time_label:
		time_label.text = "Time: %02d:%02d" % [hour, minute]


func _on_tide_changed(tide_level: float, is_high_tide: bool) -> void:
	"""Update tide display"""
	if tide_label:
		var tide_str = "High" if is_high_tide else "Low"
		tide_label.text = "Tide: " + tide_str


func _on_season_changed(season: TimeManager.Season) -> void:
	"""Update season display"""
	if season_label:
		season_label.text = "Season: " + TimeManager.Season.keys()[season]


func _on_carbon_updated(total_co2: float, daily_rate: float) -> void:
	"""Update carbon display"""
	if carbon_label:
		carbon_label.text = "Carbon: %.1f t CO₂" % total_co2


func update_tool_display(tool_name: String) -> void:
	"""Update current tool display"""
	if tool_label:
		tool_label.text = "Tool: " + tool_name
