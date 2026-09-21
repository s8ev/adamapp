extends SceneTree

var failures := 0
var checks := 0
var base := "res://artifacts/qa/store_%d" % OS.get_process_id()


func _initialize() -> void:
	call_deferred("_run")


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		print("FAIL: ", message)


func _run() -> void:
	create_timer(20.0).timeout.connect(func(): print("FAIL: test timeout"); quit(1))
	DirAccess.make_dir_recursive_absolute("res://artifacts/qa")
	check(Engine.physics_ticks_per_second == 120, "120Hz physics")
	check(ProjectSettings.get_setting("physics/common/physics_interpolation"), "interpolation")
	check(ProjectSettings.get_setting("display/window/stretch/scale_mode") == "integer", "integer scaling")
	check(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter") == 0, "nearest texture sampling")
	for action in ["move_left", "move_right", "jump", "dash", "slide", "dodge", "fire", "melee", "reload", "weapon_next", "weapon_1", "weapon_2", "interact", "throw_weapon", "finisher", "pause", "fullscreen"]:
		check(InputMap.has_action(action) and not InputMap.action_get_events(action).is_empty(), "input " + action)
	var key_checks := {"dash": KEY_SHIFT, "slide": KEY_S, "dodge": KEY_ALT, "fullscreen": KEY_F11, "restart": KEY_F5}
	for action in key_checks:
		var event := InputMap.action_get_events(action)[0] as InputEventKey
		check(event.physical_keycode == key_checks[action], "key " + action)
	for fps in SettingsStore.FPS_LIMITS:
		var values := SettingsStore.DEFAULTS.duplicate()
		values.fps_limit = fps
		check(SettingsStore.valid(values), "FPS " + str(fps))
		root.get_node("SettingsManager").commit(values)
		check(Engine.max_fps == fps, "applied FPS " + str(fps))
	var defaults := SettingsStore.DEFAULTS.duplicate(true)
	var first_error := JsonStore.write(base, defaults, SettingsStore.valid)
	check(first_error == OK, "initial write: " + error_string(first_error))
	if first_error != OK:
		quit(1)
		return
	var modified := defaults.duplicate()
	modified.fps_limit = 240
	check(JsonStore.write(base, modified, SettingsStore.valid) == OK, "replace primary")
	check(JsonStore.read(base, SettingsStore.valid).data.fps_limit == 240, "round trip")
	_write_raw(base, "{broken")
	var recovered := JsonStore.read(base, SettingsStore.valid)
	check(recovered.ok and recovered.recovered and recovered.data.fps_limit == 120, "recover backup")
	check(JsonStore.write(base, modified, SettingsStore.valid) == OK, "write after recovery")
	_write_raw(base, "{\"schema_version\":999}")
	check(not JsonStore.read(base, SettingsStore.valid).ok, "reject future schema without downgrade")
	check(JsonStore.write(base, defaults, SettingsStore.valid) != OK, "preserve future schema")
	for invalid in [{"fps_limit": 241}, {"resolution": -1}, {"resolution": 0.5}, {"vsync": "true"}, {"master": 2}, {"dialogue_speed": 0}]:
		var data := defaults.duplicate()
		data.merge(invalid, true)
		check(not SettingsStore.valid(data), "reject invalid " + str(invalid))
	var state := root.get_node("GameState")
	var snapshot: Dictionary = state.snapshot()
	check(state.restore(snapshot), "state round trip")
	var save_path := base + "_save"
	check(JsonStore.write(save_path, snapshot, state.valid) == OK, "persist game snapshot")
	var loaded := JsonStore.read(save_path, state.valid)
	check(loaded.ok and state.restore(loaded.data), "load JSON game snapshot")
	DirAccess.remove_absolute(save_path)
	snapshot.flags.saved_target = true
	snapshot.flags.killed_target = true
	check(not state.restore(snapshot), "reject contradictory flags")
	var router := root.get_node("SceneRouter")
	check(router.go("missing") == ERR_DOES_NOT_EXIST, "unknown route rejected")
	for scene in ["title", "settings", "calibration", "credits", "title"]:
		check(router.go(scene) == OK, "route " + scene)
		await process_frame
		await process_frame
		check(current_scene != null, "scene live " + scene)
		check(_only_2d(current_scene), "2D scene " + scene)
	for suffix in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(base + suffix):
			DirAccess.remove_absolute(base + suffix)
	print("FOUNDATION: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)


func _write_raw(path: String, content: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)
	file.close()


func _only_2d(node: Node) -> bool:
	if node is Node3D:
		return false
	for child in node.get_children():
		if not _only_2d(child):
			return false
	return true
