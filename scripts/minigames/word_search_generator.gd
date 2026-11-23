extends RefCounted
const FORWARD_DIRECTIONS := [Vector2i.RIGHT, Vector2i.DOWN, Vector2i(1, 1), Vector2i(-1, 1)]
# Roman Walls: exatamente duas horizontais, uma vertical e uma diagonal.
const WORD_DIRECTIONS: Dictionary = {
	"CASTLE": Vector2i(1, 0),
	"CITY": Vector2i(0, 1),
	"WALLS": Vector2i(1, 0),
	"LEARN": Vector2i(1, 1),
}

static func generate(words: Array[String], seed_value: int, size: int = 8, use_roman_directions: bool = true, allow_reverse: bool = false) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for attempt in range(500):
		var cells: Array = []
		for y in range(size):
			var line: Array[String] = []
			for x in range(size):
				line.append("")
			cells.append(line)
		var placements: Dictionary = {}
		var ordered := words.duplicate()
		ordered.sort_custom(func(a: String, b: String) -> bool: return a.length() > b.length())
		var ok := true
		for word in ordered:
			var directions: Array = FORWARD_DIRECTIONS.duplicate()
			if use_roman_directions:
				directions = [WORD_DIRECTIONS[word]]
			elif allow_reverse:
				for forward in FORWARD_DIRECTIONS:
					directions.append(-forward)
			var candidates: Array[Vector4i] = []
			for direction: Vector2i in directions:
				for y in range(size):
					for x in range(size):
						var start := Vector2i(x, y)
						var finish: Vector2i = start + direction * (word.length() - 1)
						if not Rect2i(0, 0, size, size).has_point(finish):
							continue
						var fits := true
						for i in range(word.length()):
							var p := start + direction * i
							if cells[p.y][p.x] != "" and cells[p.y][p.x] != word[i]:
								fits = false
								break
						if fits:
							candidates.append(Vector4i(x, y, direction.x, direction.y))
			if candidates.is_empty():
				ok = false
				break
			var pick: Vector4i = candidates[rng.randi_range(0, candidates.size() - 1)]
			var direction := Vector2i(pick.z, pick.w)
			var positions: Array[Vector2i] = []
			for i in range(word.length()):
				var p := Vector2i(pick.x, pick.y) + direction * i
				cells[p.y][p.x] = word[i]
				positions.append(p)
			placements[word] = positions
		if ok:
			for y in range(size):
				for x in range(size):
					if cells[y][x] == "":
						cells[y][x] = char(65 + rng.randi_range(0, 25))
			return {"grid": cells, "placements": placements}
	return {}
