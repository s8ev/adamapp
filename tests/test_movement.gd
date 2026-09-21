extends SceneTree
## Exercises real CharacterBody2D contacts using the public InputMap.

var failures := 0
var checks := 0
var player: RelayPlayer
var room: Node2D
var metrics := {}


func _initialize() -> void:
	call_deferred("_run")


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		print("FAIL: ", message)


func frames(count: int) -> void:
	for i in range(count):
		await physics_frame


func press(action: String, down: bool = true) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = down
	Input.parse_input_event(event)


func reset(at: Vector2 = Vector2(80, 304)) -> void:
	for action in ["move_left", "move_right", "jump", "dash", "slide", "dodge"]:
		press(action, false)
	player.respawn(at)
	await frames(3)


func _run() -> void:
	create_timer(60.0, true, false, true).timeout.connect(func(): print("FAIL: movement timeout"); quit(1))
	Engine.max_fps = 0
	root.get_node("SceneRouter").go("training")
	await process_frame
	await process_frame
	room = current_scene
	player = room.player
	await reset()
	check(player.is_on_floor(), "floor contact")
	var initial := player.position.x
	press("move_right")
	await frames(120)
	metrics.run_distance = player.position.x - initial
	check(metrics.run_distance > 200 and metrics.run_distance < 222, "one-second run distance: " + str(metrics.run_distance))
	check(is_equal_approx(player.velocity.x, RelayPlayer.RUN_SPEED), "run speed reached")
	press("move_right", false)
	var brake_start := player.position.x
	await frames(15)
	check(is_zero_approx(player.velocity.x), "rapid stopping")
	check(player.position.x - brake_start < 12, "braking distance")

	await reset()
	press("jump")
	await frames(30)
	metrics.jump_y = player.position.y
	check(player.position.y < 255, "held jump height")
	press("jump", false)
	await frames(90)
	check(player.is_on_floor(), "jump landing")
	await reset()
	press("jump")
	await frames(4)
	press("jump", false)
	await frames(26)
	check(player.position.y > metrics.jump_y + 10, "variable jump cut")

	await reset(Vector2(881, 304))
	press("move_right")
	for tick in range(60):
		await frames(1)
		if not player.is_on_floor():
			break
	check(not player.is_on_floor(), "left the ledge")
	press("jump")
	await frames(2)
	check(player.velocity.y < -300, "coyote jump after leaving ledge")
	await reset(Vector2(100, 275))
	for tick in range(90):
		await frames(1)
		if player.position.y > 299:
			break
	press("jump")
	await frames(10)
	check(player.velocity.y < -250, "jump input buffered before landing")
	await reset(Vector2(100, 220))
	check(player.coyote_time == 0, "airborne respawn does not reuse old floor contact")

	await reset()
	press("move_right")
	press("dash")
	await frames(3)
	check(player.motion == RelayPlayer.Motion.DASH, "dash starts immediately")
	check(player.velocity.x == RelayPlayer.DASH_SPEED, "dash speed")
	await frames(12)
	check(player.position.x > 138 and player.position.x < 165, "dash distance")
	check(player.dash_cooldown > 0, "dash cooldown")
	press("dash", false)
	press("dash")
	await frames(3)
	check(player.motion != RelayPlayer.Motion.DASH, "dash spam cannot reset cooldown")

	await reset(Vector2(583, 304))
	press("move_right")
	press("slide")
	await frames(10)
	check(player.position.x > 600, "slide enters tunnel")
	check(player.low_profile, "slide shrinks collision")
	press("slide", false)
	press("move_right", false)
	await frames(75)
	check(player.low_profile and not player.can_stand(), "cannot stand into ceiling")
	check(absf(player.position.y - 304) < 1, "slide keeps feet on floor")
	press("move_right")
	await frames(150)
	check(player.position.x > 770, "can leave low tunnel")
	check(not player.low_profile, "standing shape restored")

	await reset()
	press("dodge")
	await frames(2)
	check(player.motion == RelayPlayer.Motion.DODGE, "dodge state")
	check(player.invulnerable, "early dodge invulnerability")
	await frames(15)
	check(not player.invulnerable, "dodge invulnerability expires")

	await reset(Vector2(1322, 244))
	press("move_right")
	await frames(6)
	check(player.is_on_wall() and not player.is_on_floor(), "wall contact while airborne")
	press("jump")
	await frames(2)
	check(player.velocity.x < -200 and player.velocity.y < -300, "wall kick pushes up and away")

	await reset()
	press("move_right")
	await frames(8)
	room.set_paused(true)
	var paused_at := player.position
	var paused_time: float = root.get_node("GameState").play_time_seconds
	await frames(10)
	check(player.position == paused_at, "pause freezes player")
	check(root.get_node("GameState").play_time_seconds == paused_time, "pause excludes play time")
	press("pause")
	await process_frame
	check(not paused, "Escape resumes through input while paused")
	press("pause", false)
	press("move_right", false)
	var feedback := root.get_node("FeedbackManager")
	feedback.hitstop(0.045)
	check(Engine.time_scale < 0.1, "hitstop starts")
	var deadline := Time.get_ticks_msec() + 90
	while Time.get_ticks_msec() < deadline:
		await process_frame
	check(Engine.time_scale == 1, "hitstop restores time with real-time deadline")
	feedback.hitstop(0.07)
	room.set_paused(true)
	check(Engine.time_scale == 1, "pause cancels hitstop")
	room.set_paused(false)
	root.get_node("GameState").checkpoint = 1
	player.respawn(Vector2(970, 470))
	await process_frame
	await process_frame
	check(player.position.distance_to(TrainingLayout.CHECKPOINTS[1]) < 3, "fall recovers to checkpoint")
	var settings := root.get_node("SettingsManager")
	settings.values.screen_shake = 0.0
	room.camera.trauma = 0.0
	feedback.shake(8.0)
	check(room.camera.trauma == 0, "shake option disables camera impulse")
	check(player.buffer.values().all(func(value): return value == 0), "respawn clears buffered input")
	print("MOVEMENT: %d checks, %d failures, metrics=%s" % [checks, failures, JSON.stringify(metrics)])
	quit(1 if failures else 0)
