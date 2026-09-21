class_name PixelUI
extends RefCounted

const THEME := preload("res://ui/pixel_theme.tres")
const INK := Color("d9e7e5")
const MUTED := Color("8fa8b5")
const CYAN := Color("69ddce")
const AMBER := Color("f4b86a")


static func setup(control: Control) -> void:
	control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	control.theme = THEME
	control.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var font := THEME.default_font as FontFile
	font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	font.multichannel_signed_distance_field = false
	font.oversampling = 1.0


static func label(parent: Node, text: String, at: Vector2, size: int = 16, color: Color = INK) -> Label:
	var node := Label.new()
	node.text = text
	node.position = at
	node.add_theme_font_size_override("font_size", size)
	node.add_theme_color_override("font_color", color)
	parent.add_child(node)
	return node


static func button(parent: Node, text: String, at: Vector2, width: float, callback: Callable) -> Button:
	var node := Button.new()
	node.text = text
	node.position = at
	node.size = Vector2(width, 28)
	node.alignment = HORIZONTAL_ALIGNMENT_LEFT
	for state in ["normal", "hover", "pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("122231") if state == "normal" else Color("203645")
		style.border_color = CYAN if state == "hover" else AMBER
		style.set_border_width_all(1 if state != "normal" else 0)
		style.content_margin_left = 10
		node.add_theme_stylebox_override(state, style)
	node.pressed.connect(callback)
	parent.add_child(node)
	return node


static func panel(parent: Node, rect: Rect2, color: Color = Color("0c1725")) -> ColorRect:
	var node := ColorRect.new()
	node.position = rect.position
	node.size = rect.size
	node.color = color
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node

