extends Control

var draft: Dictionary
var status: Label
var content: Control


func _ready() -> void:
	PixelUI.setup(self)
	draft = SettingsManager.values.duplicate(true)
	PixelUI.panel(self, Rect2(0, 0, 640, 360))
	PixelUI.label(self, "SETTINGS / 設定", Vector2(28, 14), 32)
	PixelUI.button(self, "画面", Vector2(30, 57), 120, func(): _page(false))
	PixelUI.button(self, "音・演出", Vector2(160, 57), 160, func(): _page(true))
	status = PixelUI.label(self, SettingsManager.storage_message, Vector2(28, 282), 16, PixelUI.AMBER)
	PixelUI.button(self, "適用して戻る", Vector2(28, 312), 220, _apply)
	PixelUI.button(self, "キャンセル", Vector2(264, 312), 180, _back)
	_page(false)


func _page(effects: bool) -> void:
	if is_instance_valid(content):
		remove_child(content)
		content.queue_free()
	content = Control.new()
	add_child(content)
	if effects:
		_slider("マスター音量", "master", 94)
		_slider("BGM音量", "music", 124)
		_slider("効果音量", "sfx", 154)
		_slider("画面の揺れ", "screen_shake", 184)
		PixelUI.label(content, "音量は音声バスに適用。音素材は今後追加します。", Vector2(28, 235), 16, PixelUI.MUTED)
	else:
		_option("解像度", 94, ["1280 × 720", "1920 × 1080", "2560 × 1440", "3840 × 2160"], int(draft.resolution), func(i): draft.resolution = i)
		_option("ウィンドウ", 132, ["ウィンドウ", "フルスクリーン"], int(draft.fullscreen), func(i): draft.fullscreen = i == 1)
		_option("VSync", 170, ["OFF", "ON"], int(draft.vsync), func(i): draft.vsync = i == 1)
		_option("FPS上限", 208, ["60", "120", "144", "165", "240", "360", "Unlimited"], SettingsStore.FPS_LIMITS.find(int(draft.fps_limit)), func(i): draft.fps_limit = SettingsStore.FPS_LIMITS[i])
		PixelUI.label(content, "VSync ON時はモニター側の上限も適用されます。", Vector2(28, 249), 16, PixelUI.MUTED)


func _slider(text: String, key: String, y: float) -> void:
	PixelUI.label(content, text, Vector2(30, y))
	var node := HSlider.new()
	node.position = Vector2(300, y + 4)
	node.size = Vector2(240, 24)
	node.min_value = 0
	node.max_value = 100
	node.step = 5
	node.value = float(draft[key]) * 100
	var grip := Image.create(8, 10, false, Image.FORMAT_RGBA8)
	grip.fill(PixelUI.CYAN)
	var grip_texture := ImageTexture.create_from_image(grip)
	for icon in ["grabber", "grabber_highlight", "grabber_disabled"]:
		node.add_theme_icon_override(icon, grip_texture)
	for style_name in ["slider", "grabber_area", "grabber_area_highlight"]:
		var bar := StyleBoxFlat.new()
		bar.bg_color = Color("294552") if style_name == "slider" else PixelUI.CYAN
		bar.content_margin_top = 2
		bar.content_margin_bottom = 2
		node.add_theme_stylebox_override(style_name, bar)
	var number := PixelUI.label(content, str(int(node.value)), Vector2(565, y))
	node.value_changed.connect(func(value): draft[key] = value / 100.0; number.text = str(int(value)))
	content.add_child(node)
	if y == 94:
		node.grab_focus()


func _option(text: String, y: float, items: Array, selected: int, callback: Callable) -> void:
	PixelUI.label(content, text, Vector2(30, y + 2))
	var node := OptionButton.new()
	node.position = Vector2(300, y)
	node.size = Vector2(306, 30)
	for item in items:
		node.add_item(item)
	node.select(selected)
	node.item_selected.connect(callback)
	content.add_child(node)
	if y == 94:
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
