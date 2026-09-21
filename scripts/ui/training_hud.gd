extends Control

var player: RelayPlayer
var info: Label
var prompt: Label
var notice: Label
var pause_panel: Control
var pause_changed: Callable


func _ready() -> void:
	PixelUI.setup(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	PixelUI.panel(self, Rect2(0, 0, 640, 54), Color("080f1b"))
	PixelUI.label(self, "NULL RELAY / 移動訓練", Vector2(14, 7), 16, PixelUI.CYAN)
	info = PixelUI.label(self, "", Vector2(14, 29), 16, PixelUI.MUTED)
	PixelUI.panel(self, Rect2(0, 320, 640, 40), Color("080f1b"))
	prompt = PixelUI.label(self, "", Vector2(14, 321), 16, PixelUI.INK)
	notice = PixelUI.label(self, "ESC ポーズ / F5 復帰", Vector2(14, 341), 16, PixelUI.MUTED)
	pause_panel = Control.new()
	pause_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(pause_panel)
	PixelUI.panel(pause_panel, Rect2(0, 0, 640, 360), Color(0.02, 0.04, 0.08, 0.94))
	PixelUI.label(pause_panel, "PAUSED", Vector2(224, 58), 32, PixelUI.CYAN)
	PixelUI.button(pause_panel, "再開 / ESC", Vector2(195, 123), 250, func(): pause_changed.call(false))
	PixelUI.button(pause_panel, "最寄りの記録点へ", Vector2(195, 160), 250, _restart)
	PixelUI.button(pause_panel, "画面設定", Vector2(195, 197), 250, _settings)
	PixelUI.button(pause_panel, "記録してタイトルへ", Vector2(195, 234), 250, _title)
	pause_panel.hide()


func _process(_delta: float) -> void:
	if player == null:
		return
	info.text = "%s  /  %03d px/s  /  %d FPS" % [RelayPlayer.Motion.keys()[player.motion], absf(player.velocity.x), Engine.get_frames_per_second()]
	var x := player.position.x
	if x < 480:
		prompt.text = "A/D 移動   SPACE ジャンプ   SHIFT ダッシュ"
	elif x < 850:
		prompt.text = "S / CTRL スライド  —  低い通路を抜ける"
	elif x < 1220:
		prompt.text = "SPACE → SHIFT で跳び越える / 端末で E"
	elif x < 1630:
		prompt.text = "壁に触れて SPACE 壁蹴り / 高い経路も探索"
	elif x < 2270:
		prompt.text = "ALT 回避 / マウスで照準 / 端末で E 衝撃テスト"
	else:
		prompt.text = "訓練完了。逆走して連係を試す / ESC メニュー"
	queue_redraw()


func _draw() -> void:
	if pause_panel != null and pause_panel.visible:
		return
	var at := get_local_mouse_position().round()
	draw_line(at + Vector2(-6, 0), at + Vector2(-2, 0), PixelUI.AMBER)
	draw_line(at + Vector2(2, 0), at + Vector2(6, 0), PixelUI.AMBER)
	draw_line(at + Vector2(0, -6), at + Vector2(0, -2), PixelUI.AMBER)
	draw_line(at + Vector2(0, 2), at + Vector2(0, 6), PixelUI.AMBER)


func show_pause(value: bool) -> void:
	pause_panel.visible = value
	if value:
		pause_panel.get_child(2).grab_focus()


func _restart() -> void:
	pause_changed.call(false)
	get_tree().current_scene.respawn()


func _settings() -> void:
	SaveManager.save_checkpoint()
	SceneRouter.return_screen = "training"
	SceneRouter.go("settings")


func _title() -> void:
	var error := SaveManager.save_checkpoint()
	if error != OK:
		PixelUI.label(pause_panel, SaveManager.message, Vector2(30, 290), 16, PixelUI.AMBER)
		PixelUI.button(pause_panel, "保存せずタイトルへ", Vector2(195, 317), 250, func(): SceneRouter.go("title"))
		return
	SceneRouter.go("title")
