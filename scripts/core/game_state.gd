extends Node
## Foundation snapshot; narrative events/ending resolution arrive in PHASE 7.

const FLAG_DEFAULTS := {
	"found_secret_file": false, "saved_target": false, "killed_target": false,
	"trusted_partner": true, "found_hidden_room": false, "lied_to_partner": false,
	"spared_enemy": false,
}
var chapter_id := "training"
var checkpoint := 0
var play_time_seconds := 0.0
var flags: Dictionary = FLAG_DEFAULTS.duplicate()


func reset_run() -> void:
	chapter_id = "training"
	checkpoint = 0
	play_time_seconds = 0.0
	flags = FLAG_DEFAULTS.duplicate()


func snapshot() -> Dictionary:
	return {"schema_version": 1, "chapter_id": chapter_id, "checkpoint": checkpoint,
		"play_time_seconds": play_time_seconds, "flags": flags.duplicate()}


func valid(data: Dictionary) -> bool:
	if data.get("schema_version") != 1 or data.get("chapter_id") != "training":
		return false
	var point: Variant = data.get("checkpoint")
	if not (point is int or point is float):
		return false
	if not is_finite(float(point)) or point != int(point) or int(point) not in [0, 1, 2, 3]:
		return false
	var seconds: Variant = data.get("play_time_seconds")
	if not (seconds is int or seconds is float) or not is_finite(float(seconds)) or seconds < 0:
		return false
	var saved_flags: Variant = data.get("flags")
	if not saved_flags is Dictionary:
		return false
	for key in FLAG_DEFAULTS:
		if not saved_flags.get(key) is bool:
			return false
	return not (saved_flags.saved_target and saved_flags.killed_target)


func restore(data: Dictionary) -> bool:
	if not valid(data):
		return false
	chapter_id = data.chapter_id
	checkpoint = int(data.checkpoint)
	play_time_seconds = float(data.play_time_seconds)
	flags = data.flags.duplicate()
	return true
