extends Control

var draft: Dictionary
var status: Label


func _ready() -> void:
	PixelUI.setup(self)
	draft = SettingsManager.values.duplicate(true)
	PixelUI.panel(self, Rect2(0, 0, 640, 360))
	PixelUI.label(self, "SETTINGS / 画面設定", Vector2(28, 18), 32)
	_option("解像度", 78, ["1280 × 720", "1920 × 1080", "2560 × 1440", "3840 × 2160"], int(draft.resolution), func(i): draft.resolution = i)
	_option("ウィンドウ", 118, ["ウィンドウ", "フルスクリーン"], int(draft.fullscreen), func(i): draft.fullscreen = i == 1)
	_option("VSync", 158, ["OFF", "ON"], int(draft.vsync), func(i): draft.vsync = i == 1)
	_option("FPS上限", 198, ["60", "120", "144", "165", "240", "360", "Unlimited"], SettingsStore.FPS_LIMITS.find(int(draft.fps_limit)), func(i): draft.fps_limit = SettingsStore.FPS_LIMITS[i])
	PixelUI.label(self, "VSync ON時はモニター側の上限も適用されます。", Vector2(28, 242), 16, PixelUI.MUTED)
	status = PixelUI.label(self, SettingsManager.storage_message, Vector2(28, 267), 16, PixelUI.AMBER)
	PixelUI.button(self, "適用して戻る", Vector2(28, 312), 220, _apply)
	PixelUI.button(self, "キャンセル", Vector2(264, 312), 180, _back)


func _option(text: String, y: float, items: Array, selected: int, callback: Callable) -> void:
	PixelUI.label(self, text, Vector2(30, y + 2))
	var node := OptionButton.new()
	node.position = Vector2(300, y)
	node.size = Vector2(306, 30)
	for item in items:
		node.add_item(item)
	node.select(selected)
	node.item_selected.connect(callback)
	add_child(node)
	if y == 78:
		node.grab_focus()


func _apply() -> void:
	var error := SettingsManager.commit(draft)
	if error == OK:
		_back()
	else:
		status.text = SettingsManager.storage_message


func _back() -> void:
	SceneRouter.go(SceneRouter.return_screen)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_back()

