extends SceneTree
## Real renderer capture. Run without --headless; writes only inside artifacts/qa.


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://artifacts/qa")
	var router := root.get_node("SceneRouter")
	for screen in ["title", "settings", "calibration", "credits", "training"]:
		router.go(screen)
		await process_frame
		await create_timer(0.3).timeout
		await RenderingServer.frame_post_draw
		var picture := root.get_texture().get_image()
		picture.save_png("res://artifacts/qa/%s.png" % screen)
		print("CAPTURE: ", screen, " ", picture.get_size())
		if screen == "settings":
			current_scene._page(true)
			await create_timer(0.2).timeout
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://artifacts/qa/settings_effects.png")
		if screen == "training":
			current_scene.set_paused(true)
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://artifacts/qa/pause.png")
			current_scene.set_paused(false)
	quit()
