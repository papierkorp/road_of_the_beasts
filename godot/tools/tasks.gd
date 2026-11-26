extends SceneTree
## Task folder helper: the folder under `docs/todo/` is the status of a task, this script writes and checks
## what follows from it. No rule of the game, no simulation.
## godot --headless --path godot -s res://tools/tasks.gd -- generate   # writes the task table into docs/temp_todo.md
## godot --headless --path godot -s res://tools/tasks.gd -- check      # changes nothing; exit code 1 on an error
## godot --headless --path godot -s res://tools/tasks.gd -- next       # prints the next free task number

const STATUSES: Array[String] = ["to-clarify", "waiting", "in-progress", "open", "done"]
const LOOSE_FILES: Array[String] = ["ideas.md", "implementation.md"]
const MARK_START := "<!-- tasks:start -->"
const MARK_END := "<!-- tasks:end -->"
const TASK_LIMIT := 6000
const OVERVIEW_LIMIT := 10000      # without the generated table
const MAX_QUESTIONS := 10
const QUESTIONS_HEADING := "## Open Questions for the User"

var _docs := ""
var _errors: Array[String] = []
var _warnings: Array[String] = []
var _anchors := {}                 # path -> Array[String]


func _initialize() -> void:
	_docs = ProjectSettings.globalize_path("res://").path_join("../docs").simplify_path()
	var args := OS.get_cmdline_user_args()
	var command: String = args[0] if args.size() > 0 else ""
	var tasks := _collect()
	match command:
		"generate":
			quit(_generate(tasks))
		"check":
			quit(_check(tasks))
		"next":
			var highest := 0
			for t: Dictionary in tasks:
				highest = maxi(highest, int(t["number"]))
			print("T%02d" % (highest + 1))
			quit(0)
		_:
			printerr("usage: tasks.gd -- generate | check | next")
			quit(2)


## One Dictionary per task file: path (absolute), rel (from docs/), status, epic, file, id (from the file
## name), number, head_id and title (from the first heading), text.
func _collect() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var todo := _docs.path_join("todo")
	for f in DirAccess.get_files_at(todo):
		if f.ends_with(".md") and not LOOSE_FILES.has(f):
			_errors.append("todo/%s: file outside a status and epic folder" % f)
	for status in DirAccess.get_directories_at(todo):
		var status_dir := todo.path_join(status)
		if not STATUSES.has(status):
			_errors.append("todo/%s/: not a status folder" % status)
			continue
		for f in DirAccess.get_files_at(status_dir):
			if f.ends_with(".md"):
				_errors.append("todo/%s/%s: file outside an epic folder" % [status, f])
		for epic in DirAccess.get_directories_at(status_dir):
			var epic_dir := status_dir.path_join(epic)
			for sub in DirAccess.get_directories_at(epic_dir):
				_errors.append("todo/%s/%s/%s/: folder below an epic folder" % [status, epic, sub])
			for f in DirAccess.get_files_at(epic_dir):
				if f.ends_with(".md"):
					out.append(_read_task(status, epic, f))
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var sa := STATUSES.find(a["status"])
		var sb := STATUSES.find(b["status"])
		if sa != sb:
			return sa < sb
		if a["epic"] != b["epic"]:
			return String(a["epic"]) < String(b["epic"])
		return int(a["number"]) < int(b["number"]))
	return out


func _read_task(status: String, epic: String, file: String) -> Dictionary:
	var rel := "todo/%s/%s/%s" % [status, epic, file]
	var path := _docs.path_join(rel)
	var text := FileAccess.get_file_as_string(path)
	var task := {"path": path, "rel": rel, "status": status, "epic": epic, "file": file, "text": text,
		"id": "", "number": 0, "head_id": "", "title": ""}
	var name_match := _regex("^T(\\d+)-").search(file)
	if name_match:
		task["id"] = "T" + name_match.get_string(1)
		task["number"] = int(name_match.get_string(1))
	var first_line := text.get_slice("\n", 0)
	var head := _regex("^# (T\\d+) · (.+)$").search(first_line)
	if head:
		task["head_id"] = head.get_string(1)
		task["title"] = head.get_string(2).strip_edges()
	return task


# ---------------------------------------------------------------- generate

func _table(tasks: Array[Dictionary]) -> String:
	var lines: Array[String] = ["| ID | Task | Status | Epic |", "|---|---|---|---|"]
	var closed: Array[int] = []
	for t: Dictionary in tasks:
		if t["status"] == "done":
			closed.append(int(t["number"]))
			continue
		lines.append("| %s | [%s](%s) | %s | %s |" % [t["id"], t["title"], t["rel"], t["status"], t["epic"]])
	closed.sort()
	lines.append("")
	lines.append("Closed: %s ([todo/done/](todo/done/))." % (_ranges(closed) if not closed.is_empty() else "none"))
	return "\n".join(lines)


## 1, 2, 3, 7 -> "T01–T03, T07"
func _ranges(numbers: Array[int]) -> String:
	var parts: Array[String] = []
	var i := 0
	while i < numbers.size():
		var j := i
		while j + 1 < numbers.size() and numbers[j + 1] == numbers[j] + 1:
			j += 1
		if j - i >= 2:
			parts.append("T%02d–T%02d" % [numbers[i], numbers[j]])
		else:
			for k in range(i, j + 1):
				parts.append("T%02d" % numbers[k])
		i = j + 1
	return ", ".join(parts)


## The overview split at the marks: [before incl. start mark, between, from end mark on]; empty without marks.
func _split_overview(text: String) -> Array[String]:
	var a := text.find(MARK_START)
	var b := text.find(MARK_END)
	if a < 0 or b < a:
		return []
	var head_end := a + MARK_START.length()
	return [text.substr(0, head_end), text.substr(head_end, b - head_end), text.substr(b)]


func _generate(tasks: Array[Dictionary]) -> int:
	var path := _docs.path_join("temp_todo.md")
	var parts := _split_overview(FileAccess.get_file_as_string(path))
	if parts.is_empty():
		printerr("temp_todo.md: marks %s and %s not found" % [MARK_START, MARK_END])
		return 1
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(parts[0] + "\n" + _table(tasks) + "\n" + parts[2])
	file.close()
	print("temp_todo.md: table written, %d tasks" % tasks.size())
	return 0


# ---------------------------------------------------------------- check

func _check(tasks: Array[Dictionary]) -> int:
	var by_id := {}
	for t: Dictionary in tasks:
		var rel: String = t["rel"]
		var text: String = t["text"]
		var closed: bool = t["status"] == "done"
		if t["id"] == "":
			_errors.append("%s: file name does not start with T<number>-" % rel)
		if t["head_id"] == "":
			_errors.append("%s: first line is not '# T<number> · <title>'" % rel)
		elif t["head_id"] != t["id"]:
			_errors.append("%s: heading says %s, file name says %s" % [rel, t["head_id"], t["id"]])
		if by_id.has(t["id"]):
			_errors.append("%s: number %s is used twice (%s)" % [rel, t["id"], by_id[t["id"]]["rel"]])
		by_id[t["id"]] = t
		if _regex("(?m)^\\*\\*Status:\\*\\*").search(text):
			_errors.append("%s: has a Status line; the folder is the status" % rel)
		if t["status"] == "waiting" and not text.contains("**Waiting for:**"):
			_errors.append("%s: in waiting/ without 'Waiting for:'" % rel)
		if closed and not text.contains("**Closed:**"):
			_errors.append("%s: in done/ without 'Closed:'" % rel)
		if not closed and not text.contains("**Done when:**"):
			_errors.append("%s: without 'Done when:'" % rel)
		if not closed and text.length() > TASK_LIMIT:
			_warnings.append("%s: %d characters (guideline %d)" % [rel, text.length(), TASK_LIMIT])
		if not closed:
			var dates := _regex("20\\d\\d-\\d\\d-\\d\\d").search_all(text).size()
			if dates > 0:
				_warnings.append("%s: %d dates; history belongs in decisions.md" % [rel, dates])
		_check_links(t["path"], rel, text, not closed)

	for loose in LOOSE_FILES:
		var loose_path := _docs.path_join("todo").path_join(loose)
		if FileAccess.file_exists(loose_path):
			_check_links(loose_path, "todo/" + loose, FileAccess.get_file_as_string(loose_path), true)

	var overview_path := _docs.path_join("temp_todo.md")
	var overview := FileAccess.get_file_as_string(overview_path)
	_check_links(overview_path, "temp_todo.md", overview, true)
	var parts := _split_overview(overview)
	if parts.is_empty():
		_errors.append("temp_todo.md: marks %s and %s not found" % [MARK_START, MARK_END])
	else:
		if parts[1].strip_edges() != _table(tasks).strip_edges():
			_errors.append("temp_todo.md: the task table differs from the folders (run 'generate')")
		var own := parts[0].length() + parts[2].length()
		if own > OVERVIEW_LIMIT:
			_warnings.append("temp_todo.md: %d characters without the table (guideline %d)" % [own, OVERVIEW_LIMIT])
	_check_questions(overview, by_id)

	for w in _warnings:
		print("warning: " + w)
	for e in _errors:
		printerr("error: " + e)
	print("%d tasks, %d errors, %d warnings" % [tasks.size(), _errors.size(), _warnings.size()])
	return 1 if not _errors.is_empty() else 0


## Rows of the question table: | rank | question | recommendation | task |
func _check_questions(overview: String, by_id: Dictionary) -> void:
	var start := overview.find(QUESTIONS_HEADING)
	if start < 0:
		_errors.append("temp_todo.md: section '%s' not found" % QUESTIONS_HEADING)
		return
	var rest := overview.substr(start + QUESTIONS_HEADING.length())
	var next_heading := rest.find("\n## ")
	var section := rest.substr(0, next_heading) if next_heading >= 0 else rest
	var ranks := {}
	var asked := {}
	var count := 0
	for line in section.split("\n"):
		var row := _regex("^\\|\\s*(\\d+)\\s*\\|").search(line)
		if row == null:
			continue
		count += 1
		var rank := row.get_string(1)
		if ranks.has(rank):
			_errors.append("temp_todo.md: rank %s is used twice in the question table" % rank)
		ranks[rank] = true
		var cells := line.strip_edges().trim_prefix("|").trim_suffix("|").split("|")
		var ids := _regex("T\\d+").search_all(cells[cells.size() - 1])
		if ids.is_empty():
			_errors.append("temp_todo.md: question %s names no task" % rank)
		for m in ids:
			var id := m.get_string()
			asked[id] = true
			if not by_id.has(id):
				_errors.append("temp_todo.md: question %s names %s, which does not exist" % [rank, id])
			elif by_id[id]["status"] != "to-clarify":
				_errors.append("temp_todo.md: question %s names %s, which lies in %s/" % [rank, id, by_id[id]["status"]])
	if count > MAX_QUESTIONS:
		_errors.append("temp_todo.md: %d questions (at most %d)" % [count, MAX_QUESTIONS])
	var silent: Array[String] = []
	for id: String in by_id:
		if by_id[id]["status"] == "to-clarify" and not asked.has(id):
			silent.append(id)
	if not silent.is_empty():
		silent.sort()
		_warnings.append("to-clarify/ without a question in the table: %s" % ", ".join(silent))


func _check_links(path: String, rel: String, text: String, check_anchors: bool) -> void:
	var missing_anchors: Array[String] = []
	for m in _regex("\\]\\(([^)\\s]+)\\)").search_all(text):
		var link := m.get_string(1)
		if link.contains("://") or link.begins_with("mailto:"):
			continue
		var file_part := link.get_slice("#", 0)
		var anchor := link.substr(file_part.length() + 1) if link.contains("#") else ""
		var target := path if file_part == "" else path.get_base_dir().path_join(file_part).simplify_path()
		if not FileAccess.file_exists(target) and not DirAccess.dir_exists_absolute(target):
			_errors.append("%s: link to a missing file: %s" % [rel, link])
		elif check_anchors and anchor != "" and target.ends_with(".md") and not _anchors_of(target).has(anchor):
			missing_anchors.append("#" + anchor)
	if not missing_anchors.is_empty():
		_warnings.append("%s: links to missing anchors: %s" % [rel, ", ".join(missing_anchors)])


## Anchors of a Markdown file as GitHub builds them from its headings.
func _anchors_of(path: String) -> Array:
	if not _anchors.has(path):
		var found: Array[String] = []
		for line in FileAccess.get_file_as_string(path).split("\n"):
			var head := _regex("^#+\\s+(.*)$").search(line)
			if head:
				var slug := head.get_string(1).strip_edges().to_lower()
				slug = _regex("[^\\p{L}\\p{N}_\\- ]").sub(slug, "", true)
				found.append(slug.replace(" ", "-"))
		_anchors[path] = found
	return _anchors[path]


var _regex_cache := {}

func _regex(pattern: String) -> RegEx:
	if not _regex_cache.has(pattern):
		_regex_cache[pattern] = RegEx.create_from_string(pattern)
	return _regex_cache[pattern]
