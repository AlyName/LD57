extends Node
class_name DataLoader

static var instance: DataLoader

func _init() -> void:
	instance = self

var csv_map
var csv_object
var csv_dialogs

func _ready() -> void:
	csv_map = load("res://map.csv")
	csv_object = load("res://object.csv")
	csv_dialogs = load("res://dialogs.csv")

func parse_block(s: String) -> Dictionary:
	var res = {}
	var parts = s.split("-")
	res['id'] = int(parts[0])
	res['energy_num'] = int(parts[1])
	if len(parts) >= 3:
		var p2 = parts[2].replace("_",",")
		var json = JSON.new()
		print(p2)
		var err = json.parse(p2)
		if err != OK:
			print("Error parsing block misc: ", err)
			res['misc'] = {}
		else:
			res['misc'] = json.data
	else:
		res['misc'] = {}
	return res

func get_map_info(id: int) -> Array:
	var records = csv_map.records
	for i in len(records):
		var record = records[i]
		if record[0] == "id" and record[1] == id:
			var height = int(record[2])
			var width = int(record[3])
			var n_map = []
			for j in range(height):
				var row = []
				for k in range(width):
					row.append(parse_block(records[i + j + 1][k]))
				n_map.append(row)
			return n_map
	return []

func get_block_by_id(id: int) -> Block:
	for record in csv_object.records:
		if record['id'] == id:
			var script_path = record['script_path']
			if script_path == "":
				script_path = record['type'] + ".gd"
			var block = load("res://scripts/block.gd").new()
			if load("res://scripts/blocks/" + script_path) != null:
				block = load("res://scripts/blocks/" + script_path).new()
			block.b_id = record['id']
			block.b_type = record['type']
			block.block_name = record['name']
			block.block_desc = record['desc']
			block.border_sprite = load("res://imgs/border.png")
			var pattern_path = record['sprite_path']
			if pattern_path == "":
				pattern_path = record['type'] + ".png"
			block.pattern_sprite = load("res://imgs/" + pattern_path)
			var color_string = record['color']
			if color_string != "":
				block.color = Color(color_string)
			else:
				block.color = Color(1, 1, 1, 1)
			return block
	return null

func parse_dialog(s: String) -> Dictionary:
	var parts = s.split("_")
	return {'character' : parts[0], 'time': float(parts[1]), 'dialog' : parts[2]}
	

func get_dialogs_by_level(level_id: int) -> Dictionary:
	var result: Dictionary = {}
	var records = csv_dialogs.records
	for i in len(records):
		var record = records[i]
		if int(record['level']) == level_id:
			if result.has(record['name']):
				result[record['name']]['dialog'].append(parse_dialog(record['content']))
			else:
				result[record['name']] = {
					'pos' : Vector2(float(record['pos_x']), float(record['pos_y'])),
					'duration' : float(record['duration']),
					'dialog' : [parse_dialog(record['content'])]
				}
	return result
