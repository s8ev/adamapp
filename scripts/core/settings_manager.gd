extends Node

signal settings_changed
var values: Dictionary = SettingsStore.DEFAULTS.duplicate(true)
var storage_message := ""
const PATH := "user://settings.json"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.use_accumulated_input = false
	if not OS.get_cmdline_user_args().has("--qa-isolation"):
		var result := JsonStore.read(PATH, SettingsStore.valid)
		if result.ok:
			values = result.data
			if result.recovered:
				storage_message = "設定をバックアップから復旧しました。"
		elif result.exists:
			storage_message = result.error
	apply()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		var next := values.duplicate(true)
		next.fullscreen = not next.fullscreen
		commit(next)
		get_viewport().set_input_as_handled()


func commit(next: Dictionary) -> Error:
	if not SettingsStore.valid(next):
		return ERR_INVALID_DATA
	values = next.duplicate(true)
	apply()
	if OS.get_cmdline_user_args().has("--qa-isolation"):
		return OK
	var error := JsonStore.write(PATH, values, SettingsStore.valid)
	storage_message = "" if error == OK else "設定を保存できません。ファイルを保護しています。"
	return error


func apply() -> void:
	Engine.max_fps = int(values.fps_limit)
	for pair in [["Master", "master"], ["Music", "music"], ["SFX", "sfx"]]:
		var index := AudioServer.get_bus_index(pair[0])
		if index >= 0:
			AudioServer.set_bus_volume_db(index, linear_to_db(maxf(float(values[pair[1]]), 0.0001)))
			AudioServer.set_bus_mute(index, values[pair[1]] == 0)
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if values.vsync else DisplayServer.VSYNC_DISABLED)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if values.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
		if not values.fullscreen:
			var requested: Vector2i = SettingsStore.RESOLUTIONS[int(values.resolution)]
			var usable := DisplayServer.screen_get_usable_rect()
			var actual := requested.min(usable.size - Vector2i(32, 64))
			DisplayServer.window_set_size(actual)
			DisplayServer.window_set_position(usable.position + (usable.size - actual) / 2)
	settings_changed.emit()

