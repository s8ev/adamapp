class_name JsonStore
extends RefCounted
## Atomic same-directory writes, one last-known-good backup, explicit recovery.

static func read(path: String, validator: Callable) -> Dictionary:
	var exists := FileAccess.file_exists(path) or FileAccess.file_exists(path + ".bak")
	for candidate in [path, path + ".bak"]:
		if not FileAccess.file_exists(candidate):
			continue
		var parser := JSON.new()
		if parser.parse(FileAccess.get_file_as_string(candidate)) != OK:
			continue
		var parsed: Variant = parser.data
		# Never downgrade a file produced by a newer build, including a backup.
		if parsed is Dictionary:
			var version: Variant = parsed.get("schema_version", 0)
			if (version is int or version is float) and version > 1:
				return {"ok": false, "exists": true, "error": "新しい形式のため読み込めません。"}
		if parsed is Dictionary and validator.call(parsed):
			return {"ok": true, "exists": true, "data": parsed, "recovered": candidate != path}
	return {"ok": false, "exists": exists, "error": "保存データを読み込めません。" if exists else ""}


static func write(path: String, data: Dictionary, validator: Callable) -> Error:
	path = ProjectSettings.globalize_path(path)
	if not validator.call(data):
		return ERR_INVALID_DATA
	var previous := read(path, validator)
	if previous.exists and not previous.ok:
		return ERR_FILE_CORRUPT
	var pending := path + ".tmp"
	var file := FileAccess.open(pending, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK:
		return error
	var verified: Variant = JSON.parse_string(FileAccess.get_file_as_string(pending))
	if not verified is Dictionary or not validator.call(verified):
		return ERR_FILE_CORRUPT
	# A recovered backup must survive replacing a corrupt primary.
	if FileAccess.file_exists(path) and not previous.get("recovered", false):
		error = DirAccess.copy_absolute(path, path + ".bak")
		if error != OK:
			return error
	# Godot replaces the destination during rename on supported desktop platforms.
	error = DirAccess.rename_absolute(pending, path)
	return error
