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
	PixelUI.button(self, "起動チェック", Vector2(30, 210), 230, func(): SceneRouter.go("calibration")).grab_focus()
	PixelUI.button(self, "設定", Vector2(30, 243), 112, func(): SceneRouter.go("settings"))
	PixelUI.button(self, "クレジット", Vector2(148, 243), 112, func(): SceneRouter.go("credits"))
	PixelUI.button(self, "終了", Vector2(30, 276), 230, func(): get_tree().quit())
	PixelUI.label(self, "PHASE 0 / 起動基盤", Vector2(30, 326), 16, PixelUI.MUTED)
	PixelUI.label(self, "F11 : 全画面", Vector2(474, 326), 16, PixelUI.CYAN)

