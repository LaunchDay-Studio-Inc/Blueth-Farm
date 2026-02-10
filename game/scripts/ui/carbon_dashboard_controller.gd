extends CanvasLayer
## Carbon Dashboard UI Controller
##
## Displays comprehensive carbon sequestration data, trends, and impact metrics.
## Provides live updates, historical graphs, and carbon credit management.

# Art Direction color palette
const BG_COLOR := Color("#1A3A52", 0.9)
const BORDER_COLOR := Color("#8B7355")
const TEXT_COLOR := Color("#F5F0E1")
const PANEL_BG_COLOR := Color("#2A5A72", 0.85)
const BIOMASS_COLOR := Color("#6B9D6E")
const SEDIMENT_COLOR := Color("#8B6F47")
const GRAPH_LINE_COLOR := Color("#6CC4A1")
const GRAPH_BG_COLOR := Color("#2E5E8C", 0.3)
const HEALTH_GOOD_COLOR := Color("#7CB342")
const HEALTH_WARNING_COLOR := Color("#FFB84D")
const HEALTH_BAD_COLOR := Color("#D32F2F")

# UI References
@onready var panel_container := $CenterContainer/PanelContainer
@onready var close_button := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HeaderContainer/CloseButton
@onready var total_carbon_label := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TopSection/TotalCarbonPanel/VBoxContainer/TotalCarbonLabel
@onready var daily_rate_label := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TopSection/DailyRatePanel/VBoxContainer/DailyRateLabel
@onready var trend_label := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TopSection/DailyRatePanel/VBoxContainer/TrendLabel
@onready var biomass_label := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BreakdownSection/BiomassContainer/BiomassLabel
@onready var biomass_progress := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BreakdownSection/BiomassContainer/BiomassProgressBar
@onready var sediment_label := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BreakdownSection/SedimentContainer/SedimentLabel
@onready var sediment_progress := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BreakdownSection/SedimentContainer/SedimentProgressBar
@onready var graph_canvas := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/GraphSection/GraphContainer/GraphCanvas
@onready var cars_label := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/EquivalenciesSection/EquivalenciesPanel/EquivalenciesContainer/CarsLabel
@onready var flights_label := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/EquivalenciesSection/EquivalenciesPanel/EquivalenciesContainer/FlightsLabel
@onready var trees_label := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/EquivalenciesSection/EquivalenciesPanel/EquivalenciesContainer/TreesLabel
@onready var credits_available_label := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BottomSection/CarbonCreditsPanel/VBoxContainer/CreditsAvailableLabel
@onready var credits_price_label := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BottomSection/CarbonCreditsPanel/VBoxContainer/CreditsPriceLabel
@onready var sell_credits_button := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BottomSection/CarbonCreditsPanel/VBoxContainer/SellCreditsButton
@onready var health_value_label := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BottomSection/EcosystemHealthPanel/VBoxContainer/HealthValueLabel
@onready var ecosystem_health_bar := $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BottomSection/EcosystemHealthPanel/VBoxContainer/EcosystemHealthBar
@onready var overlay := $Overlay

# State
var _previous_total: float = 0.0
var _previous_rate: float = 0.0
var _tween: Tween = null


func _ready() -> void:
	hide()
	
	await get_tree().process_frame
	
	# Connect signals
	close_button.pressed.connect(_on_close_pressed)
	sell_credits_button.pressed.connect(_on_sell_credits_pressed)
	
	# Connect to CarbonManager signals
	if CarbonManager:
		CarbonManager.carbon_updated.connect(_on_carbon_updated)
	
	# Connect to graph canvas draw
	graph_canvas.draw.connect(_draw_graph)
	
	# Apply art direction styling
	_apply_styling()
	
	# Initial data refresh
	_refresh_display()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_carbon_dashboard"):
		toggle_dashboard()
	elif event.is_action_pressed("ui_cancel") and visible:
		hide_dashboard()


func toggle_dashboard() -> void:
	if visible:
		hide_dashboard()
	else:
		show_dashboard()


func show_dashboard() -> void:
	visible = true
	_close_other_uis()
	_refresh_display()


func hide_dashboard() -> void:
	visible = false


func _close_other_uis() -> void:
	# Close inventory if open
	var inventory = get_node_or_null("/root/GameWorld/InventoryUI")
	if inventory and inventory.visible:
		if inventory.has_method("hide_inventory"):
			inventory.hide_inventory()
	
	# Close market if open
	var market = get_node_or_null("/root/GameWorld/MarketUI")
	if market and market.visible:
		if market.has_method("hide_market"):
			market.hide_market()
	
	# Close pause menu if open
	var pause_menu = get_node_or_null("/root/GameWorld/PauseMenu")
	if pause_menu and pause_menu.visible:
		if pause_menu.has_method("hide_pause_menu"):
			pause_menu.hide_pause_menu()


func _apply_styling() -> void:
	# Style main panel background
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = BG_COLOR
	panel_style.border_color = BORDER_COLOR
	panel_style.border_width_left = 4
	panel_style.border_width_right = 4
	panel_style.border_width_top = 4
	panel_style.border_width_bottom = 4
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10
	panel_container.add_theme_stylebox_override("panel", panel_style)
	
	# Style overlay
	overlay.color = Color(0, 0, 0, 0.4)
	
	# Style close button
	_style_button(close_button, Color("#D32F2F", 0.9))
	
	# Style sell credits button
	_style_button(sell_credits_button, Color("#FF9800", 0.9))
	
	# Style progress bars
	_style_progress_bar(biomass_progress, BIOMASS_COLOR)
	_style_progress_bar(sediment_progress, SEDIMENT_COLOR)
	_style_progress_bar(ecosystem_health_bar, HEALTH_GOOD_COLOR)
	
	# Style sub-panels
	for node_path in [
		"CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TopSection/TotalCarbonPanel",
		"CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TopSection/DailyRatePanel",
		"CenterContainer/PanelContainer/MarginContainer/VBoxContainer/GraphSection/GraphContainer",
		"CenterContainer/PanelContainer/MarginContainer/VBoxContainer/EquivalenciesSection/EquivalenciesPanel",
		"CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BottomSection/CarbonCreditsPanel",
		"CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BottomSection/EcosystemHealthPanel"
	]:
		var sub_panel = get_node_or_null(node_path)
		if sub_panel:
			var sub_style := StyleBoxFlat.new()
			sub_style.bg_color = PANEL_BG_COLOR
			sub_style.corner_radius_top_left = 6
			sub_style.corner_radius_top_right = 6
			sub_style.corner_radius_bottom_left = 6
			sub_style.corner_radius_bottom_right = 6
			sub_panel.add_theme_stylebox_override("panel", sub_style)


func _style_button(button: Button, base_color: Color) -> void:
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = base_color
	normal_style.corner_radius_top_left = 5
	normal_style.corner_radius_top_right = 5
	normal_style.corner_radius_bottom_left = 5
	normal_style.corner_radius_bottom_right = 5
	button.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = base_color.lightened(0.2)
	hover_style.corner_radius_top_left = 5
	hover_style.corner_radius_top_right = 5
	hover_style.corner_radius_bottom_left = 5
	hover_style.corner_radius_bottom_right = 5
	button.add_theme_stylebox_override("hover", hover_style)
	
	var pressed_style := StyleBoxFlat.new()
	pressed_style.bg_color = base_color.darkened(0.2)
	pressed_style.corner_radius_top_left = 5
	pressed_style.corner_radius_top_right = 5
	pressed_style.corner_radius_bottom_left = 5
	pressed_style.corner_radius_bottom_right = 5
	button.add_theme_stylebox_override("pressed", pressed_style)


func _style_progress_bar(progress_bar: ProgressBar, fill_color: Color) -> void:
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2, 0.5)
	bg_style.corner_radius_top_left = 4
	bg_style.corner_radius_top_right = 4
	bg_style.corner_radius_bottom_left = 4
	bg_style.corner_radius_bottom_right = 4
	progress_bar.add_theme_stylebox_override("background", bg_style)
	
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = fill_color
	fill_style.corner_radius_top_left = 4
	fill_style.corner_radius_top_right = 4
	fill_style.corner_radius_bottom_left = 4
	fill_style.corner_radius_bottom_right = 4
	progress_bar.add_theme_stylebox_override("fill", fill_style)


func _refresh_display() -> void:
	if not CarbonManager:
		return
	
	# Update total carbon with animation
	_animate_carbon_value(CarbonManager.total_co2_sequestered)
	
	# Update daily rate
	_update_daily_rate(CarbonManager.daily_sequestration_rate)
	
	# Update breakdown
	_update_breakdown()
	
	# Update equivalencies
	_update_equivalencies()
	
	# Update carbon credits
	_update_carbon_credits()
	
	# Update ecosystem health
	_update_ecosystem_health()
	
	# Redraw graph
	graph_canvas.queue_redraw()


func _animate_carbon_value(new_value: float) -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	
	var current_value = _previous_total
	_tween.tween_method(func(val: float):
		total_carbon_label.text = "%.1f" % val,
		current_value,
		new_value,
		0.8
	)
	
	_previous_total = new_value


func _update_daily_rate(rate: float) -> void:
	daily_rate_label.text = "%.2f" % rate
	
	# Update trend indicator
	var trend_text = "tonnes/day"
	if rate > _previous_rate:
		trend_text = "↑ " + trend_text
		daily_rate_label.add_theme_color_override("font_color", HEALTH_GOOD_COLOR)
	elif rate < _previous_rate:
		trend_text = "↓ " + trend_text
		daily_rate_label.add_theme_color_override("font_color", HEALTH_BAD_COLOR)
	else:
		trend_text = "→ " + trend_text
		daily_rate_label.add_theme_color_override("font_color", TEXT_COLOR)
	
	trend_label.text = trend_text
	_previous_rate = rate


func _update_breakdown() -> void:
	if not CarbonManager:
		return
	
	var breakdown = CarbonManager.get_carbon_breakdown()
	
	var biomass_tonnes = breakdown.get("biomass_tonnes", 0.0)
	var sediment_tonnes = breakdown.get("sediment_tonnes", 0.0)
	var biomass_percent = breakdown.get("biomass_percent", 0.0)
	var sediment_percent = breakdown.get("sediment_percent", 0.0)
	
	biomass_label.text = "🌱 Biomass: %.1f tonnes (%.1f%%)" % [biomass_tonnes, biomass_percent]
	biomass_progress.value = biomass_percent
	
	sediment_label.text = "🪨 Sediment: %.1f tonnes (%.1f%%)" % [sediment_tonnes, sediment_percent]
	sediment_progress.value = sediment_percent


func _update_equivalencies() -> void:
	if not CarbonManager:
		return
	
	var equiv = CarbonManager.get_equivalencies()
	
	cars_label.text = "🚗 Equal to %d cars off the road for a year" % equiv.get("cars_offset", 0)
	flights_label.text = "✈️ Equal to %d transatlantic flights offset" % equiv.get("flights_offset", 0)
	trees_label.text = "🌳 Equal to %d trees grown for 10 years" % equiv.get("trees_equivalent", 0)


func _update_carbon_credits() -> void:
	if not CarbonManager:
		return
	
	var credits = CarbonManager.total_carbon_credits
	var price = CarbonManager.credit_price
	
	credits_available_label.text = "Available: %.2f credits" % credits
	credits_price_label.text = "Price: %d gold/credit" % price
	
	sell_credits_button.disabled = credits <= 0.0


func _update_ecosystem_health() -> void:
	if not EcosystemManager:
		return
	
	var health = EcosystemManager.ecosystem_health
	health_value_label.text = "Health: %.0f%%" % health
	ecosystem_health_bar.value = health
	
	# Update health bar color based on health level
	var health_color: Color
	if health >= 70.0:
		health_color = HEALTH_GOOD_COLOR
	elif health >= 40.0:
		health_color = HEALTH_WARNING_COLOR
	else:
		health_color = HEALTH_BAD_COLOR
	
	_style_progress_bar(ecosystem_health_bar, health_color)


func _draw_graph() -> void:
	if not CarbonManager:
		return
	
	var history = CarbonManager.get_history_data(28)
	if history.is_empty():
		return
	
	var canvas_size = graph_canvas.size
	var margin = 10.0
	var graph_width = canvas_size.x - (margin * 2)
	var graph_height = canvas_size.y - (margin * 2)
	
	# Draw background
	graph_canvas.draw_rect(Rect2(Vector2.ZERO, canvas_size), GRAPH_BG_COLOR, true)
	
	# Find max value for scaling
	var max_value = 0.0
	for entry in history:
		var daily_rate = entry.get("daily_rate", 0.0)
		if daily_rate > max_value:
			max_value = daily_rate
	
	if max_value == 0.0:
		max_value = 1.0
	
	# Draw grid lines
	var grid_color = Color(1, 1, 1, 0.1)
	for i in range(5):
		var y = margin + (graph_height * i / 4.0)
		graph_canvas.draw_line(
			Vector2(margin, y),
			Vector2(canvas_size.x - margin, y),
			grid_color,
			1.0
		)
	
	# Draw line graph
	if history.size() > 1:
		var points: PackedVector2Array = []
		var step = graph_width / max(1, history.size() - 1)
		
		for i in range(history.size()):
			var entry = history[i]
			var daily_rate = entry.get("daily_rate", 0.0)
			var x = margin + (i * step)
			var y = margin + graph_height - (daily_rate / max_value * graph_height)
			points.append(Vector2(x, y))
		
		# Draw the line
		for i in range(points.size() - 1):
			graph_canvas.draw_line(
				points[i],
				points[i + 1],
				GRAPH_LINE_COLOR,
				2.0
			)
		
		# Draw points
		for point in points:
			graph_canvas.draw_circle(point, 3.0, GRAPH_LINE_COLOR)


func _on_carbon_updated(_total_co2: float, _daily_rate: float) -> void:
	if visible:
		_refresh_display()


func _on_close_pressed() -> void:
	hide_dashboard()


func _on_sell_credits_pressed() -> void:
	if not CarbonManager:
		return
	
	var credits = CarbonManager.total_carbon_credits
	if credits <= 0.0:
		return
	
	if CarbonManager.sell_carbon_credits(credits):
		_refresh_display()
		
		# Play success sound
		if AudioManager and AudioManager.has_method("play_sfx"):
			AudioManager.play_sfx("sell")
