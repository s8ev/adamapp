extends Node

const SCENES := {
	"title": "res://scenes/boot/title.tscn",
	"settings": "res://scenes/ui/settings.tscn",
	"calibration": "res://scenes/ui/calibration.tscn",
	"credits": "res://scenes/ui/credits.tscn",
	"training": "res://scenes/levels/training.tscn",
}
var return_screen := "title"
var transitioning := false


func go(screen: String) -> Error:
	if not SCENES.has(screen):
		return ERR_DOES_NOT_EXIST
	if transitioning:
		return ERR_BUSY
	transitioning = true
	FeedbackManager.reset()
	get_tree().paused = false
	Engine.time_scale = 1.0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var error := get_tree().change_scene_to_file(SCENES[screen])
	call_deferred("_unlock")
	return error


func _unlock() -> void:
	transitioning = false
