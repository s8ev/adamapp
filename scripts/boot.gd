extends Node


func _ready() -> void:
	SceneRouter.call_deferred("go", "title")
	if OS.get_cmdline_user_args().has("--smoke"):
		_smoke()


func _smoke() -> void:
	# A tree-owned timer survives this boot scene's replacement.
	var tree := get_tree()
	tree.create_timer(2.0).timeout.connect(func(): tree.quit())
