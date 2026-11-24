extends GdUnitTestSuite
## Guards a quirk of the Godot export (README, "Adding content"): an exported field of a packed array type whose
## default is an array literal loses the value stored in its .tres or .tscn when the project is exported. The game
## then runs with the default, and only the exported build shows it.

const SKIP: Array[String] = ["res://addons", "res://tests", "res://.godot"]


func test_no_exported_packed_array_has_an_array_literal_as_default() -> void:
	var pattern := RegEx.new()
	pattern.compile("@export[^\\n]*\\bvar\\s+\\w+\\s*:\\s*Packed\\w+Array\\s*=\\s*\\[")
	var found: PackedStringArray = PackedStringArray()
	for path in _scripts("res://"):
		var lines := FileAccess.get_file_as_string(path).split("\n")
		for i in lines.size():
			if pattern.search(lines[i]) != null:
				found.append("%s:%d" % [path, i + 1])
	assert_str(", ".join(found)).is_empty()


func test_the_guard_knows_the_spelling_it_looks_for() -> void:
	var pattern := RegEx.new()
	pattern.compile("@export[^\\n]*\\bvar\\s+\\w+\\s*:\\s*Packed\\w+Array\\s*=\\s*\\[")
	assert_object(pattern.search("@export var learns: PackedStringArray = []")).is_not_null()
	assert_object(pattern.search("@export_group(\"x\") @export var n: PackedInt32Array = [1]")).is_not_null()
	assert_object(pattern.search("@export var learns: PackedStringArray")).is_null()
	assert_object(pattern.search("@export var learns: Array[String] = []")).is_null()
	assert_object(pattern.search("var learns: PackedStringArray = []")).is_null()


func _scripts(dir: String) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	if SKIP.has(dir.trim_suffix("/")):
		return out
	for sub in DirAccess.get_directories_at(dir):
		out.append_array(_scripts(dir.path_join(sub)))
	for file in DirAccess.get_files_at(dir):
		if file.ends_with(".gd"):
			out.append(dir.path_join(file))
	return out
