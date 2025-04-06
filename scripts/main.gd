extends Node2D
class_name Main

static var instance: Main
var select_box: Sprite2D

func _init() -> void:
	instance = self

func _process(delta: float) -> void:
	process_select_box()

var n_level_id: int = 0
var n_level_map: Array = []
var height: int = 0
var width: int = 0

var board: Array = []

var is_locked: int = 0

var current_level: MonoLevel = null
var now_round: int = 0
var last_operate: Block = null

var mission_nnum: Array[int] = []

var level_init_done: bool = false
var played_dialogs: Dictionary = {}

var last_init_level_id: int = 0

func children_clear() -> void:
	for child in get_children():
		child.queue_free()

func level_clear() -> void:
	children_clear()
	Root.instance.clear_dia_box()
	Root.instance.clear_special()
	ParticleManager.instance.clear_particles()
	board = []
	height = 0
	width = 0
	n_level_id = 0
	if current_level:
		current_level = null

func level_init(level_id: int) -> void:
	level_init_done = false
	n_level_id = level_id
	n_level_map = DataLoader.instance.get_map_info(level_id)
	height = len(n_level_map)
	width = len(n_level_map[0])
	now_round = 0
	lock_board()
	if last_init_level_id != level_id:
		await UI.instance.level_init_ui()
		last_init_level_id = level_id
	else:
		UI.instance.fast_init_ui()
	gen_blocks_by_map()
	mission_nnum = []
	last_operate = null
	unlock_board()
	level_init_done = true

var gen_done: bool = false
func gen_blocks_by_map() -> void:
	gen_done = false
	for i in range(height):
		var row = []
		for j in range(width):
			var block = DataLoader.instance.get_block_by_id(n_level_map[j][i]['id'])
			block.energy_num = n_level_map[j][i]['energy_num']
			if block.energy_num == 0:
				block.is_hidden = true
			else:
				block.is_hidden = false
			block.b_pos = Vector2(i, j)
			block.construct_misc(n_level_map[j][i]['misc'])
			row.append(block)
			block.name = "block_" + str(i) + "_" + str(j)
			add_child(block)
		board.append(row)
	gen_done = true
	if current_level:
		current_level.first_operate()

## input detect
func handle_input(input_s: String) -> void:
	if check_locked():
		return
	
	if input_s == "click":
		var succeed: bool = false
		var mouse_focus = InputDetect.instance.mouse_focus
		if mouse_focus is Block:
			succeed = activate_block(mouse_focus)
		if succeed:
			# if !(mouse_focus != null and mouse_focus is BlockNote):
			# 	play_sfx_combo()
			await after_operate()
		return
	if Controller.instance.state != Controller.INLEVEL:
		return
	if input_s == "cheat_forward":
		current_level.short_level_complete()
		Controller.instance.insert_interrupt(Controller.LEVELINIT)
		if Controller.instance.g_level_id < Controller.instance.MAX_LEVEL_ID:
			Controller.instance.g_level_id += 1
	elif input_s == "cheat_backward":
		current_level.short_level_complete()
		Controller.instance.insert_interrupt(Controller.LEVELINIT)
		if Controller.instance.g_level_id > 1:
			Controller.instance.g_level_id -= 1

func activate_block(block: Block) -> bool:
	var succeed = block.activate_move()
	if succeed:
		last_operate = block
	return succeed

func get_block_by_pos(pos: Vector2) -> Block:
	if pos.x < 0 or pos.x >= height or pos.y < 0 or pos.y >= width:
		return null
	return board[pos.x][pos.y]

func change_block_pos(blocks: Array,new_poses: Array) -> void:
	lock_board()
	for i in range(len(blocks)):
		board[new_poses[i].x][new_poses[i].y] = blocks[i]
		blocks[i].b_pos = new_poses[i]
	unlock_board()

func lock_board() -> void:
	is_locked += 1

func unlock_board() -> void:
	is_locked -= 1

func check_locked() -> bool:
	return is_locked > 0

func init_level_meta(level_id: int) -> void:
	var level_path = "res://scripts/levels/level_%d.gd" % level_id
	if ResourceLoader.exists(level_path):
		var LevelClass = load(level_path)
		current_level = LevelClass.new()
		current_level.dialogs = DataLoader.instance.get_dialogs_by_level(level_id)
		current_level.level_init()

func after_operate() -> void:
	if current_level:
		now_round += 1
		current_level.after_operate()
		mission_nnum = current_level.check_mission_clear()
		if check_level_complete(mission_nnum, current_level.mission_cnum):
			lock_board()
			await current_level.level_complete_anim()
			unlock_board()
			Controller.instance.insert_interrupt(Controller.LEVELINIT)
			Controller.instance.g_level_id += 1

func check_level_complete(missions_nnum: Array[int], mission_cnum: Array[int]) -> bool:
	if len(missions_nnum) != len(mission_cnum):
		return false
	for i in range(len(missions_nnum)):
		if missions_nnum[i] < mission_cnum[i]:
			return false
	return true

func reset_level():
	lock_board()
	Controller.instance.insert_interrupt(Controller.LEVELRESET)
	now_round = 0
	unlock_board()

func process_select_box() -> void:
	if select_box == null:
		select_box = Sprite2D.new()
		select_box.texture = load("res://imgs/select.png")
		select_box.scale = Vector2(1,1) * 3
		select_box.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		select_box.visible = false
		select_box.z_index = 25
		add_child(select_box)
	if InputDetect.instance.mouse_focus != null and InputDetect.instance.mouse_focus is Block:
		select_box.global_position = InputDetect.instance.mouse_focus.global_position
		select_box.scale = Vector2(1,1) * (3 + 0.25 * sin(Root.instance.global_time))
		select_box.visible = true
	else:
		select_box.visible = false

var last_sfx_time: float = 0.0
var combo_count: int = 0
func play_sfx_combo() -> void:
	var now_time = Root.instance.global_time
	if now_time - last_sfx_time < 2.0:
		combo_count += 1
	else:
		combo_count = 0
	print(now_time - last_sfx_time)
	last_sfx_time = now_time
	var sfx_name = str(min(8, combo_count+3))
	AudioManager.instance.play_sfx(sfx_name)
