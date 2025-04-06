extends MonoLevel
class_name Level5

const ORDER = [0, 1, 2, 3]

var cave
var now_order: Array[int] = []

func _init() -> void:
	level_id = 5
	level_name = "#5. The Depth"
	level_desc = "At times I glimpse the vast expanse of another's heart, seemingly capable of holding the entirety of existence."
	mission_num = 2
	mission_desc = ["Find out all of the notes", "Play the notes in a certain order?"]
	mission_cnum = [4, 1]


func _ready() -> void:
	pass

func level_init()-> void:
	UI.instance.appear_ui()
	now_order = []
	cave = load("res://scenes/cave.tscn").instantiate()
	cave.position = Vector2(0, 0)
	cave.z_index = 10
	cave.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	Main.instance.add_child(cave)
	await Root.instance.get_tree().create_timer(8).timeout
	create_dialog("opening")

func first_operate() -> void:
	pass

func after_operate() -> void:
	if Main.instance.now_round % 17 == 0:
		make_laqe()

func level_complete_anim() -> void:
	for i in range(0,Main.instance.height):
		for j in range(0,Main.instance.width):
			var block = Main.instance.board[i][j]
			block.fly_out()
	UI.instance.fade_out_ui()
	await Root.instance.get_tree().create_timer(1).timeout
	create_dialog("final")
	await Root.instance.get_tree().create_timer(12).timeout
	await ParticleManager.instance.change_scene_in()
	cave.queue_free()

func short_level_complete() -> void:
	cave.queue_free()

func sound_note(note_type: int) -> void:
	now_order.append(note_type)

var history_max_note_num = 0
func check_mission_clear() -> Array[int]:
	var note_num = 0
	for i in range(Main.instance.height):
		for j in range(Main.instance.width):
			if Main.instance.board[i][j] is BlockNote and Main.instance.board[i][j].energy_num > 0:
				note_num += 1
	if note_num > history_max_note_num:
		history_max_note_num = note_num
		if note_num == 2:
			create_dialog("note2")
		elif note_num == 4:
			create_dialog("note4")
			cave.appear_label()
	var is_correct = 0
	if len(now_order)>=4:
		if now_order[-4] == ORDER[0] and now_order[-3] == ORDER[1] and now_order[-2] == ORDER[2] and now_order[-1] == ORDER[3]:
			is_correct = 1
	return [note_num, is_correct]


func make_laqe() -> void:
	var laqe = load("res://scenes/small_thing.tscn").instantiate()
	laqe.texture = load("res://imgs/laqe_bg.png")
	Root.instance.add_child(laqe)
