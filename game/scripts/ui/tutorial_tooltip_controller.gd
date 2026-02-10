extends CanvasLayer
## Tutorial Tooltip Controller
## Displays tutorial step instructions

# Art Direction colors
const BG_COLOR = Color("#1A3A52", 0.95)
const BORDER_COLOR = Color("#E8A87C")  # Golden Hour for tutorial
const TEXT_COLOR = Color("#F5F0E1")

var is_visible_flag: bool = false


func _ready() -> void:
	_apply_styling()
	$TooltipPanel.visible = false


func _apply_styling() -> void:
	"""Apply Art Direction color palette"""
	var panel = $TooltipPanel
	
	# Create StyleBoxFlat for panel
	var style = StyleBoxFlat.new()
	style.bg_color = BG_COLOR
	style.border_color = BORDER_COLOR
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	
	panel.add_theme_stylebox_override("panel", style)
	
	# Set text colors
	var title = $TooltipPanel/MarginContainer/VBoxContainer/HBoxContainer/TitleLabel
	if title:
		title.add_theme_color_override("font_color", BORDER_COLOR)  # Golden
		title.add_theme_font_size_override("font_size", 18)
	
	var message = $TooltipPanel/MarginContainer/VBoxContainer/MessageLabel
	if message:
		message.add_theme_color_override("font_color", TEXT_COLOR)
	
	var icon = $TooltipPanel/MarginContainer/VBoxContainer/HBoxContainer/IconLabel
	if icon:
		icon.add_theme_font_size_override("font_size", 24)


func show_step(title: String, message: String, icon: String = "ℹ️") -> void:
	"""Show a tutorial step"""
	# Update content
	var title_label = $TooltipPanel/MarginContainer/VBoxContainer/HBoxContainer/TitleLabel
	if title_label:
		title_label.text = title
	
	var message_label = $TooltipPanel/MarginContainer/VBoxContainer/MessageLabel
	if message_label:
		message_label.text = message
	
	var icon_label = $TooltipPanel/MarginContainer/VBoxContainer/HBoxContainer/IconLabel
	if icon_label:
		icon_label.text = icon
	
	# Show panel
	$TooltipPanel.visible = true
	is_visible_flag = true
	
	# Animate in
	_animate_in()


func hide_tooltip() -> void:
	"""Hide the tooltip"""
	_animate_out()


func is_visible() -> bool:
	"""Check if tooltip is visible"""
	return is_visible_flag


func _animate_in() -> void:
	"""Slide tooltip in from left"""
	var panel = $TooltipPanel
	
	# Start off-screen
	panel.position.x = -panel.size.x
	
	# Tween to position
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(panel, "position:x", 20, 0.4)


func _animate_out() -> void:
	"""Slide tooltip out to left"""
	var panel = $TooltipPanel
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(panel, "position:x", -panel.size.x, 0.3)
	
	await tween.finished
	
	panel.visible = false
	is_visible_flag = false


func _on_skip_pressed() -> void:
	"""Handle skip button press"""
	var tutorial_system = get_tree().get_first_node_in_group("tutorial_system")
	if not tutorial_system:
		tutorial_system = get_node_or_null("/root/GameWorld/TutorialSystem")
	
	if tutorial_system and tutorial_system.has_method("skip_tutorial"):
		tutorial_system.skip_tutorial()
	
	hide_tooltip()
