extends Node2D

var clock := 0.0


func _process(delta: float) -> void:
	clock += delta
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-100, -100, 2800, 600), Color("080f1b"))
	for i in range(70):
		var x := i * 40
		var top := 100 + posmod(i * 43, 90)
		draw_rect(Rect2(x, top, 30, 200), Color("122231"))
		for j in range(5):
			if posmod(i + j * 7, 3) == 0:
				draw_rect(Rect2(x + 7, top + 12 + j * 18, 5, 3), Color("284952"))
	for rect in TrainingLayout.SOLIDS:
		draw_rect(rect, Color("203645"))
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, 2)), Color("629392"))
		for x in range(int(rect.position.x) + 8, int(rect.end.x), 20):
			draw_rect(Rect2(x, rect.position.y + 7, 4, 2), Color("345262"))
	for p in TrainingLayout.CHECKPOINTS:
		draw_rect(Rect2(p + Vector2(-3, -58), Vector2(3, 58)), Color("345262"))
		draw_rect(Rect2(p + Vector2(0, -58), Vector2(14, 8)), Color("69ddce"))
	for x in [1130, 1780, 2200]:
		draw_rect(Rect2(x - 10, 278, 20, 26), Color("203645"))
		draw_rect(Rect2(x - 5, 282, 10, 3), Color("f4b86a"))
	for i in range(80):
		var x := posmod(i * 71 + int(clock * 20), 2500)
		var y := posmod(i * 47 + int(clock * 95), 304)
		draw_rect(Rect2(x, y, 1, 3), Color("1c3442"))
	# The gap has a visible safe-recovery cable below it.
	draw_line(Vector2(900, 398), Vector2(1020, 398), Color("c77d45"), 2)

