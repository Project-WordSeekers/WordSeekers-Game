extends RefCounted
const SIZE: int = 8
# Roman Walls: exatamente duas horizontais, uma vertical e uma diagonal.
const WORD_DIRECTIONS: Dictionary = {
	"CASTLE": Vector2i(1, 0),
	"CITY": Vector2i(0, 1),
	"WALLS": Vector2i(1, 0),
	"LEARN": Vector2i(1, 1),
}

static func generate(words: Array[String], seed_value: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for attempt in range(500):
		var cells: Array = []
		for y in range(SIZE):
			var line: Array[String] = []
			for x in range(SIZE):
				line.append("")
			cells.append(line)
		var placements: Dictionary = {}
		var ordered := words.duplicate()
		ordered.sort_custom(func(a: String, b: String) -> bool: return a.length() > b.length())
		var ok := true
		for word in ordered:
			if not WORD_DIRECTIONS.has(word):
				ok = false
				break
			var direction: Vector2i = WORD_DIRECTIONS[word]
			var candidates: Array[Vector2i] = []
			for y in range(SIZE):
				for x in range(SIZE):
					var start := Vector2i(x, y)
					var finish: Vector2i = start + direction * (word.length() - 1)
					if finish.x < 0 or finish.x >= SIZE or finish.y < 0 or finish.y >= SIZE:
						continue
					var fits := true
					for i in range(word.length()):
						var p: Vector2i = start + direction * i
						if cells[p.y][p.x] != "" and cells[p.y][p.x] != word[i]:
							fits = false
							break
					if fits:
						candidates.append(start)
			if candidates.is_empty():
				ok = false
				break
			var pick: Vector2i = candidates[rng.randi_range(0, candidates.size() - 1)]
			var positions: Array[Vector2i] = []
			for i in range(word.length()):
				var p: Vector2i = pick + direction * i
				cells[p.y][p.x] = word[i]
				positions.append(p)
			placements[word] = positions
		if ok:
			for y in range(SIZE):
				for x in range(SIZE):
					if cells[y][x] == "":
						cells[y][x] = char(65 + rng.randi_range(0, 25))
			return {"grid": cells, "placements": placements}
	return {}
