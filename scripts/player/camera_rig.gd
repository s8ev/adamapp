extends Camera2D

var target: RelayPlayer
var trauma := 0.0
var phase := 0.0


func _ready() -> void:
	FeedbackManager.shake_requested.connect(func(strength): trauma = maxf(trauma, strength))
	position_smoothing_enabled = false
	limit_left = 0
	limit_right = 2460
	limit_top = -40
	limit_bottom = 480
	position = Vector2(320, 180)


func _physics_process(delta: float) -> void:
	if target == null:
		return
	var look := clampf(target.velocity.x * 0.16 + target.aim_direction.x * 22.0, -75.0, 75.0)
	var desired := target.global_position + Vector2(look, -78)
	global_position = global_position.lerp(desired, 1.0 - exp(-9.0 * delta))
	trauma = move_toward(trauma, 0, delta * 24.0)
	phase += delta * 75.0
	offset = Vector2(sin(phase * 1.3), cos(phase * 1.7)) * trauma


func snap() -> void:
	if target:
		global_position = target.global_position + Vector2(0, -78)
	trauma = 0
	offset = Vector2.ZERO
	reset_physics_interpolation()

