class_name SaveSystem
extends RefCounted


static func get_save_path() -> String:
	var path: String = ""
	if OS.get_name() == "Android":
		path = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES) + ("/SaveImages")
		var dir: DirAccess = DirAccess.open(path)
		if not dir:
			DirAccess.make_dir_absolute(path)
	else:
		path = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
	return path


static func save_image(img: Image, prefix: String) -> int:
	var date: String = Time.get_datetime_string_from_system(false, true)
	date = date.replace_chars(" -:", "_".unicode_at(0))
	var code: int = img.save_png(
		SaveSystem.get_save_path() + "/" + prefix +
		"_" + str(date) + ".png",
	)
	return code
