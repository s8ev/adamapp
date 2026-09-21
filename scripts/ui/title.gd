extends Control


func _ready() -> void:
	PixelUI.setup(self)
	var backdrop := Node2D.new()
	backdrop.set_script(preload("res://scripts/visuals/relay_backdrop.gd"))
	add_child(backdrop)
	PixelUI.label(self, "SHIOTSUGI / COMMUNICATION NETWORK", Vector2(28, 22), 16, PixelUI.CYAN)
	PixelUI.label(self, "NULL RELAY", Vector2(27, 60), 48)
	PixelUI.label(self, "残響回線", Vector2(30, 119), 32, PixelUI.AMBER)
	PixelUI.label(self, "消したはずの声が、まだここにある。", Vector2(30, 165), 16, PixelUI.MUTED)
	PixelUI.button(self, "移動訓練を開始", Vector2(30, 205), 230, _start).grab_focus()
	var resume := PixelUI.button(self, "訓練を再開", Vector2(272, 205), 164, _resume)
	resume.disabled = not SaveManager.has_save()
	PixelUI.button(self, "設定", Vector2(30, 240), 112, _settings)
	PixelUI.button(self, "クレジット", Vector2(148, 240), 112, func(): SceneRouter.go("credits"))
	PixelUI.button(self, "入力確認", Vector2(30, 275), 112, func(): SceneRouter.go("calibration"))
	PixelUI.button(self, "終了", Vector2(148, 275), 112, func(): get_tree().quit())
	PixelUI.label(self, "PHASE 1 / MOVEMENT SLICE", Vector2(30, 326), 16, PixelUI.MUTED)
	PixelUI.label(self, "F11 : 全画面", Vector2(474, 326), 16, PixelUI.CYAN)


func _start() -> void:
	if SaveManager.has_save():
		var dialog := Control.new()
		dialog.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(dialog)
		PixelUI.panel(dialog, Rect2(0, 0, 640, 360), Color("080f1b"))
		PixelUI.label(dialog, "訓練の記録点を最初に戻しますか？", Vector2(70, 112))
		PixelUI.button(dialog, "最初から始める", Vector2(70, 180), 235, _new_training)
		PixelUI.button(dialog, "戻る", Vector2(330, 180), 235, func(): dialog.queue_free()).grab_focus()
		return
	_new_training()


func _new_training() -> void:
	GameState.reset_run()
	SceneRouter.go("training")


func _resume() -> void:
	if SaveManager.load_checkpoint():
		SceneRouter.go("training")


func _settings() -> void:
	SceneRouter.return_screen = "title"
	SceneRouter.go("settings")
