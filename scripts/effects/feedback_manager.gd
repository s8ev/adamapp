extends Node
## Uses real time for hitstop release so pause/slow motion cannot strand the game.

signal shake_requested(strength: float)
var _stop_until_usec := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func hitstop(seconds: float = 0.045) -> void:
	if get_tree().paused or _stop_until_usec != 0:
		return
	_stop_until_usec = Time.get_ticks_usec() + int(clampf(seconds, 0.0, 0.07) * 1000000)
	Engine.time_scale = 0.06


func shake(strength: float) -> void:
	shake_requested.emit(clampf(strength, 0.0, 8.0) * float(SettingsManager.values.screen_shake))


func _process(_delta: float) -> void:
	if _stop_until_usec > 0 and Time.get_ticks_usec() >= _stop_until_usec:
		reset()


func reset() -> void:
	_stop_until_usec = 0
	Engine.time_scale = 1.0

