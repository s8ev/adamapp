extends SceneTree
## Continuous input-driven traversal; no teleports or altered movement values.

var room: Node2D
var stage := 0
var last_jump := -100
var screenshots: Dictionary = {}


func _initialize() -> void:
	call_deferred("_run")


func press(action: String, down: bool = true) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = down
	Input.parse_input_event(event)


func _run() -> void:
	root.get_node("SettingsManager").values.vsync = false
	root.get_node("SettingsManager").apply()
	root.get_node("SceneRouter").go("training")
	await process_frame
	await process_frame
	room = current_scene
	var player: RelayPlayer = room.player
	press("move_right")
	var completed := false
	for tick in range(4800):
		await physics_frame
		var x := player.position.x
		if x > 565 and stage == 0:
			press("slide")
			stage = 1
		if x > 780 and stage == 1:
			press("slide", false)
			stage = 2
		if x > 854 and stage == 2:
			press("jump")
			stage = 3
		if x > 920 and stage == 3:
			press("dash")
			stage = 4
		if x > 1100 and stage == 4:
			press("dash", false)
			press("jump", false)
			stage = 5
		if x > 1210 and stage == 5:
			press("jump")
			last_jump = tick
			stage = 6
		if x > 1200 and player.is_on_wall() and tick - last_jump > 24:
			press("jump", false)
			press("jump")
			last_jump = tick
		if stage == 6 and x > 1580:
			press("jump", false)
			stage = 7
		if stage == 7 and x > 1700:
			press("dodge")
			stage = 8
		if stage == 8 and x > 1840:
			press("jump")
			stage = 9
		if tick % 12 == 0 and not screenshots.has(stage) and DisplayServer.get_name() != "headless":
			screenshots[stage] = true
			_capture.call_deferred(stage)
		if x > 2335:
			completed = true
			break
		if x < 400 and tick > 500:
			print("FAIL: traversal fell back to start at stage ", stage)
			break
	press("move_right", false)
	await process_frame
	print("TRAVERSAL: ", "PASS" if completed else "FAIL", " x=", player.position.x, " stage=", stage, " checkpoint=", root.get_node("GameState").checkpoint)
	quit(0 if completed else 1)


func _capture(index: int) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/qa/route_%02d.png" % index)

