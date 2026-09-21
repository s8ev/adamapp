class_name SettingsStore
extends RefCounted

const FPS_LIMITS := [60, 120, 144, 165, 240, 360, 0]
const RESOLUTIONS := [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2560, 1440), Vector2i(3840, 2160)]
const DEFAULTS := {
	"schema_version": 1, "resolution": 0, "fullscreen": false, "vsync": true,
	"fps_limit": 120, "master": 0.8, "music": 0.7, "sfx": 0.8,
	"screen_shake": 0.65, "blood": 1.0, "flash_effects": false, "dialogue_speed": 1.0,
}


static func valid(data: Dictionary) -> bool:
	if data.get("schema_version") != 1:
		return false
	for key in DEFAULTS:
		if not data.has(key):
			return false
	for key in ["fullscreen", "vsync", "flash_effects"]:
		if not data[key] is bool:
			return false
	for key in ["resolution", "fps_limit", "master", "music", "sfx", "screen_shake", "blood", "dialogue_speed"]:
		if not (data[key] is float or data[key] is int) or not is_finite(float(data[key])):
			return false
	if data.resolution != int(data.resolution) or int(data.resolution) not in range(RESOLUTIONS.size()):
		return false
	if data.fps_limit != int(data.fps_limit) or int(data.fps_limit) not in FPS_LIMITS:
		return false
	for key in ["master", "music", "sfx", "screen_shake", "blood"]:
		if data[key] < 0.0 or data[key] > 1.0:
			return false
	return data.dialogue_speed >= 0.5 and data.dialogue_speed <= 2.0
