extends Control


func _ready() -> void:
	PixelUI.setup(self)
	PixelUI.label(self, "CREDITS / 制作", Vector2(28, 20), 32, PixelUI.CYAN)
	PixelUI.label(self, "残響回線 / NULL RELAY\n制作: s8ev / AI開発協働\nゲームエンジン: Godot 4.5.2 (MIT)\nフォント: DotGothic16 (SIL OFL 1.1)\nCopyright 2020 The DotGothic16 Project Authors\n\n本作専用の世界観・文章・2D図形を制作。\n現在は開発用の基盤です。", Vector2(28, 78))
	PixelUI.button(self, "タイトルへ / ESC", Vector2(28, 310), 240, func(): SceneRouter.go("title")).grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		SceneRouter.go("title")

