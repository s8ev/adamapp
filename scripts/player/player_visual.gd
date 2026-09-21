extends Node2D

var stride := 0.0
var trail_clock := 0.0
var trails: Array[Dictionary] = []
@onready var player: RelayPlayer = get_parent()


func _process(delta: float) -> void:
	stride += absf(player.velocity.x) * delta * 0.10
	trail_clock -= delta
	if player.motion in [RelayPlayer.Motion.DASH, RelayPlayer.Motion.DODGE] and trail_clock <= 0:
		trails.append({"position": player.global_position, "life": 0.16, "low": player.low_profile})
		trail_clock = 0.025
	for trail in trails:
		trail.life -= delta
	trails = trails.filter(func(t): return t.life > 0)
	queue_redraw()


func _draw() -> void:
	for trail in trails:
		var at: Vector2 = (trail.position - player.global_position).round()
		draw_rect(Rect2(at + Vector2(-6, -16 if trail.low else -28), Vector2(12, 16 if trail.low else 28)), Color(0.41, 0.87, 0.81, trail.life * 2.0))
	var direction := player.facing
	var low := player.low_profile
	var running := player.motion == RelayPlayer.Motion.RUN
	var step := int(sin(stride) * 4) if running else 1
	var height := 16 if low else 30
	var torso_y := -height + 9
	# A compact, original technician silhouette with an amber jacket and white arm band.
	draw_rect(Rect2(-7, -3, 14, 3), Color("152c36"))
	draw_rect(Rect2(-5 - step, -9, 4, 8), Color("396171"))
	draw_rect(Rect2(1 + step, -8, 4, 7), Color("274354"))
	draw_rect(Rect2(-6, torso_y, 12, 13 if not low else 7), Color("c77d45"))
	draw_rect(Rect2(-5, torso_y, 3, 11 if not low else 5), Color("f4b86a"))
	draw_rect(Rect2(-5, -height, 10, 8), Color("bacbc7"))
	draw_rect(Rect2(-4, -height + 4, 9, 5), Color("b88979"))
	draw_rect(Rect2(0 if direction > 0 else -5, -height + 4, 5, 2), Color("69ddce"))
	var shoulder := Vector2(direction * 3, torso_y + 3)
	var hand := (shoulder + player.aim_direction * 10.0).round()
	draw_line(shoulder, hand, Color("d9e7e5"), 3.0)
	draw_line(hand, (hand + player.aim_direction * 8.0).round(), Color("506a76"), 3.0)
	if player.invulnerable:
		draw_rect(Rect2(-9, -height - 2, 18, height + 3), Color("69ddce"), false, 1)

