extends PanelContainer
## Individual notification popup controller
## Handles appearance, positioning, and animations

const NOTIFICATION_WIDTH: float = 300.0
const NOTIFICATION_HEIGHT: float = 80.0
const NOTIFICATION_SPACING: float = 10.0
const SLIDE_DURATION: float = 0.3

# Art Direction colors
const COLORS = {
	"journal": Color("#E8A87C"),      # Golden Hour
	"wildlife": Color("#4A90B8"),     # Cerulean
	"research": Color("#8B7ACC"),     # Purple
	"building": Color("#8B7355"),     # Driftwood brown
	"gold": Color("#D4956B"),         # Warm Amber
	"growth": Color("#6B9D6E"),       # Seagrass Green
	"warning": Color("#D46B6B"),      # Red
	"carbon": Color("#A8D8C9")        # Seafoam
}

var notification_type: int = 0
var target_position: Vector2 = Vector2.ZERO
var tween: Tween


func _ready() -> void:
	# Set initial position off-screen
	var viewport_size = get_viewport_rect().size
	position = Vector2(viewport_size.x, 20)
	
	# Set size
	custom_minimum_size = Vector2(NOTIFICATION_WIDTH, NOTIFICATION_HEIGHT)
	
	# Configure panel style
	_apply_style()


func setup(message: String, type: int, icon: String = "") -> void:
	"""Configure the notification with message and type"""
	notification_type = type
	
	# Set message
	var message_label = $MarginContainer/HBoxContainer/MessageLabel
	if message_label:
		message_label.text = message
	
	# Set icon
	var icon_label = $MarginContainer/HBoxContainer/IconLabel
	if icon_label and not icon.is_empty():
		icon_label.text = icon
	elif icon_label:
		# Set default icon based on type
		icon_label.text = _get_default_icon(type)
	
	# Apply color
	_apply_style()
	
	# Slide in
	_slide_in()


func _apply_style() -> void:
	"""Apply styling based on notification type"""
	var type_name = _get_type_name(notification_type)
	var border_color = COLORS.get(type_name, Color.WHITE)
	
	# Create StyleBoxFlat
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#1A3A52", 0.95)  # Semi-transparent dark background
	style.border_color = border_color
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	
	add_theme_stylebox_override("panel", style)
	
	# Set text color
	var message_label = $MarginContainer/HBoxContainer/MessageLabel
	if message_label:
		message_label.add_theme_color_override("font_color", Color("#F5F0E1"))  # Cream


func _slide_in() -> void:
	"""Slide notification in from the right"""
	var viewport_size = get_viewport_rect().size
	target_position = Vector2(viewport_size.x - NOTIFICATION_WIDTH - 20, position.y)
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", target_position, SLIDE_DURATION)


func _slide_out() -> void:
	"""Slide notification out to the right"""
	var viewport_size = get_viewport_rect().size
	var out_position = Vector2(viewport_size.x, position.y)
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", out_position, SLIDE_DURATION)
	
	await tween.finished
	queue_free()


func update_position(index: int) -> void:
	"""Update vertical position based on stack index"""
	var viewport_size = get_viewport_rect().size
	var y_pos = 20 + index * (NOTIFICATION_HEIGHT + NOTIFICATION_SPACING)
	target_position = Vector2(viewport_size.x - NOTIFICATION_WIDTH - 20, y_pos)
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position", target_position, 0.2)


func _get_type_name(type: int) -> String:
	"""Get type name from enum value"""
	match type:
		0: return "journal"
		1: return "wildlife"
		2: return "research"
		3: return "building"
		4: return "gold"
		5: return "growth"
		6: return "warning"
		7: return "carbon"
		_: return "journal"


func _get_default_icon(type: int) -> String:
	"""Get default icon for notification type"""
	match type:
		0: return "📖"  # Journal
		1: return "🐬"  # Wildlife
		2: return "🔬"  # Research
		3: return "🏗️"  # Building
		4: return "💰"  # Gold
		5: return "🌱"  # Growth
		6: return "⚠️"  # Warning
		7: return "📊"  # Carbon
		_: return "ℹ️"
