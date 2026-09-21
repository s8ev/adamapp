extends Node2D

var player: RelayPlayer
var camera: Camera2D
var hud: Control
var feedback_cooldown := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	TrainingLayout.build(self)
	var art := Node2D.new()
	art.set_script(preload("res://scripts/visuals/training_art.gd"))
	art.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(art)
	player = preload("res://scenes/actors/player.tscn").instantiate()
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(player)
	player.respawn(TrainingLayout.CHECKPOINTS[GameState.checkpoint])
	player.action_started.connect(_on_action)
	player.landed.connect(func(speed): FeedbackManager.shake(minf(speed / 250.0, 2.5)))
	camera = Camera2D.new()
	camera.process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	camera.set_script(preload("res://scripts/player/camera_rig.gd"))
	camera.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(camera)
	camera.target = player
	camera.snap()
	var canvas := CanvasLayer.new()
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(canvas)
	hud = Control.new()
	hud.set_script(preload("res://scripts/ui/training_hud.gd"))
	canvas.add_child(hud)
	hud.player = player
	hud.pause_changed = set_paused
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	if SaveManager.save_checkpoint() != OK:
		hud.notice.text = SaveManager.message
	set_process_input(true)


func _process(delta: float) -> void:
	if get_tree().paused:
		return
	GameState.play_time_seconds += delta
	feedback_cooldown = maxf(0.0, feedback_cooldown - delta)
	if player.position.y > 465:
		respawn()
	for i in range(GameState.checkpoint + 1, TrainingLayout.CHECKPOINTS.size()):
		if player.position.x >= TrainingLayout.CHECKPOINTS[i].x and player.is_on_floor():
			GameState.checkpoint = i
			var error := SaveManager.save_checkpoint()
			hud.notice.text = "CHECKPOINT %d / 記録完了" % i if error == OK else SaveManager.message


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("restart") and not get_tree().paused:
		respawn()
	elif event.is_action_pressed("interact") and not get_tree().paused and feedback_cooldown <= 0:
		for x in [1130, 1780, 2200]:
			if absf(player.position.x - x) < 55 and player.position.y > 260:
				FeedbackManager.hitstop()
				FeedbackManager.shake(7.0)
				feedback_cooldown = 0.25
				hud.notice.text = "衝撃テスト / 45ms ヒットストップ"


func set_paused(value: bool) -> void:
	FeedbackManager.reset()
	player.clear_inputs()
	get_tree().paused = value
	hud.show_pause(value)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if value else Input.MOUSE_MODE_HIDDEN


func respawn() -> void:
	FeedbackManager.reset()
	player.respawn(TrainingLayout.CHECKPOINTS[GameState.checkpoint])
	camera.snap()


func _on_action(action: StringName) -> void:
	if action == &"dash":
		FeedbackManager.shake(1.3)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(hud):
		set_paused(true)


func _exit_tree() -> void:
	FeedbackManager.reset()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
