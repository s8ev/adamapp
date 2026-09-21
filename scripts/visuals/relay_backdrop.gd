extends Node2D
## Original pixel geometry. No rasterized photograph or 3D content.

var elapsed := 0.0


func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("080f1b"))
	for layer in range(3):
		for i in range(12):
			var x := i * 61 - layer * 19
			var h := 35 + posmod(i * 41 + layer * 37, 110)
			var y := 275 - h + layer * 17
			draw_rect(Rect2(x, y, 43, h + 80), Color("122231") if layer == 0 else Color("10202b"))
			for w in range(3):
				for row in range(h / 13):
					if posmod(i + row * 3 + w, 4) == 0:
						draw_rect(Rect2(x + 7 + w * 11, y + 8 + row * 13, 3, 2), Color("376366"))
	draw_rect(Rect2(448, 38, 4, 263), Color("3b6470"))
	draw_rect(Rect2(425, 80, 52, 3), Color("69ddce"))
	draw_rect(Rect2(438, 58, 28, 2), Color("376366"))
	draw_line(Vector2(450, 65), Vector2(534, 289), Color("28424e"), 1.0)
	draw_line(Vector2(450, 65), Vector2(366, 289), Color("28424e"), 1.0)
	for i in range(45):
		var x := posmod(i * 73 + int(elapsed * 22), 640)
		var y := posmod(i * 47 + int(elapsed * 90.0), 360)
		draw_rect(Rect2(x, y, 1, 3), Color("25404d"))
	draw_rect(Rect2(0, 315, 640, 45), Color("080f1b"))
	draw_line(Vector2(24, 315), Vector2(616, 315), Color("294552"), 1)
