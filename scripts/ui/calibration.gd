extends Control

var info: Label
var inputs: Label
var elapsed := 0.0
var pointer := Vector2(480, 160)
const ACTIONS := ["move_left", "move_right", "jump", "dash", "slide", "dodge", "fire", "melee", "reload", "interact", "throw_weapon", "finisher"]


func _ready() -> void:
	PixelUI.setup(self)
	PixelUI.label(self, "SYSTEM CHECK", Vector2(28, 20), 32, PixelUI.CYAN)
	PixelUI.label(self, "入力 / 描画 / 日本語フォントの確認", Vector2(28, 65))
	info = PixelUI.label(self, "", Vector2(28, 105))
	inputs = PixelUI.label(self, "", Vector2(28, 169), 16, PixelUI.AMBER)
	PixelUI.label(self, "マウスを動かし、キーを押してください。\n移動訓練はタイトルから開始できます。", Vector2(28, 219), 16, PixelUI.MUTED)
	PixelUI.button(self, "タイトルへ / ESC", Vector2(28, 310), 240, func(): SceneRouter.go("title")).grab_focus()


func _process(delta: float) -> void:
	elapsed += delta
	pointer = get_global_mouse_position().round()
	info.text = "640 × 360 / INTEGER / NEAREST\n物理 %d Hz / 描画 %d FPS" % [Engine.physics_ticks_per_second, Engine.get_frames_per_second()]
	var pressed: Array[String] = []
	for action in ACTIONS:
		if Input.is_action_pressed(action):
			pressed.append(action)
	inputs.text = "INPUT: " + (", ".join(pressed) if not pressed.is_empty() else "READY")
	queue_redraw()


func _draw() -> void:
	for x in range(440, 620, 8):
		for y in range(104, 200, 8):
			var color := Color("203645") if (x / 8 + y / 8) % 2 == 0 else Color("122231")
			draw_rect(Rect2(x, y, 8, 8), color)
	draw_rect(Rect2(440 + int(fmod(elapsed * 55.0, 172.0)), 207, 4, 4), PixelUI.CYAN)
	draw_line(pointer - Vector2(5, 0), pointer + Vector2(5, 0), PixelUI.AMBER)
	draw_line(pointer - Vector2(0, 5), pointer + Vector2(0, 5), PixelUI.AMBER)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		SceneRouter.go("title")
