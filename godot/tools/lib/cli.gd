extends RefCounted
## Argument helper for the headless tool scripts: everything after `--` on the Godot command
## line, split into positional values and `--key value` / `--flag` options.


## {"pos": Array[String], "opt": {key: String or true}, "error": String}. `flags` lists the
## options that take no value; `known` every accepted option (an unknown one is an error).
static func parse(flags: Array[String], known: Array[String]) -> Dictionary:
	var pos: Array[String] = []
	var opt := {}
	var args := OS.get_cmdline_user_args()
	var i := 0
	while i < args.size():
		var a := args[i]
		i += 1
		if not a.begins_with("--"):
			pos.append(a)
			continue
		var key := a.trim_prefix("--")
		if not known.has(key):
			return {"pos": pos, "opt": opt, "error": "unknown option --%s (try --help)" % key}
		if flags.has(key):
			opt[key] = true
		elif i < args.size():
			opt[key] = args[i]
			i += 1
		else:
			return {"pos": pos, "opt": opt, "error": "option --%s needs a value" % key}
	return {"pos": pos, "opt": opt, "error": ""}


static func names(text: String) -> Array[String]:
	var out: Array[String] = []
	for part in text.split(",", false):
		if part.strip_edges() != "":
			out.append(part.strip_edges())
	return out


## Comma list of whole numbers; an empty array if any entry is not one.
static func ints(text: String) -> Array[int]:
	var out: Array[int] = []
	for part in names(text):
		if not part.is_valid_int():
			return [] as Array[int]
		out.append(part.to_int())
	return out


## Fixed-width table: the first row is the header.
static func table(rows: Array) -> String:
	var widths: Array[int] = []
	for row: Array in rows:
		for i in row.size():
			if widths.size() <= i:
				widths.append(0)
			widths[i] = maxi(widths[i], String(row[i]).length())
	var lines: PackedStringArray = []
	for row: Array in rows:
		var cells: PackedStringArray = []
		for i in row.size():
			cells.append(String(row[i]).rpad(widths[i]))
		lines.append(" | ".join(cells).strip_edges(false, true))
	return "\n".join(lines)
