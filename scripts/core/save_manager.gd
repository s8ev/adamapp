extends Node

signal save_finished(error: Error)
const PATH := "user://training_save.json"
var message := ""


func has_save() -> bool:
	if OS.get_cmdline_user_args().has("--qa-isolation"):
		return false
	return JsonStore.read(PATH, GameState.valid).ok


func save_checkpoint() -> Error:
	if OS.get_cmdline_user_args().has("--qa-isolation"):
		return OK
	var error := JsonStore.write(PATH, GameState.snapshot(), GameState.valid)
	message = "記録しました" if error == OK else "記録できません。既存データを確認してください。"
	save_finished.emit(error)
	return error


func load_checkpoint() -> bool:
	var result := JsonStore.read(PATH, GameState.valid)
	if not result.ok:
		message = result.error
		return false
	message = "バックアップから記録を復旧しました" if result.recovered else "記録を読み込みました"
	return GameState.restore(result.data)
