extends Node2D
class_name UI

static var instance: UI

func _init() -> void:
	instance = self

@onready var title_label: Label = $Title
@onready var desc_label: Label = $Description
@onready var reset_button: Button = $UIDown/ResetButton
@onready var e_bar: Sprite2D = $UIDown/EBar
@onready var e_bar_fill: Sprite2D = $UIDown/EBar/EBarFill
@onready var mission_board: Label = $MissionBoard
@onready var block_desc: Label = $UIDown.get_node("BlockDesc")
@onready var block_desc_2: Label = $UIDown.get_node("BlockDesc2")
@onready var progress_arrow: Sprite2D = $Progress/ProgressArrow
@onready var progress_number: Label = $Progress/ProgressNumber

const E_BAR_FILL_MAX_X = 11.2
const DESC_ORIG_POS = Vector2(-600,-300)

const progress_delta = 66
const progress_start = -164

var e_bar_fill_now_x: float = 0

var progress_now: int = 50

var t_tween: Tween

var level_depth = [0, 50, 0, -1000, -2000, -3000, -5000, -998244353]

var ui_down_dest_modulate: Color = Color(1,1,1,1)

func _ready() -> void:
	reset_button.pressed.connect(reset_level)

func _process(delta: float) -> void:
	if Main.instance and Main.instance.current_level:
		title_label.text = Main.instance.current_level.level_name
		desc_label.text = Main.instance.current_level.level_desc
		mission_board.text = calc_mission_board(Main.instance.current_level.mission_desc, Main.instance.current_level.mission_cnum, Main.instance.mission_nnum)
		if InputDetect.instance.mouse_focus != null and InputDetect.instance.mouse_focus is Block:
			set_block_desc(InputDetect.instance.mouse_focus)
		else:
			set_block_desc(null)
		if Main.instance.level_init_done and Main.instance.gen_done:
			ui_down_dest_modulate = Color(1,1,1,1)
			set_ui_down_y(Main.instance.board[Main.instance.height-1][Main.instance.width-1].position.y + 50)
		else:
			ui_down_dest_modulate = Color(1,1,1,0)
		progress_number.text = str(progress_now)+'m'
	else:
		title_label.text = ""
		desc_label.text = "" 
	e_bar_fill.scale.x = lerp(e_bar_fill.scale.x, e_bar_fill_now_x, 0.1)
	$UIDown.modulate = lerp($UIDown.modulate, ui_down_dest_modulate, 0.1)

func reset_level():
	if Controller.instance.state == Controller.INLEVEL and Main.instance.is_locked == 0:
		Main.instance.reset_level()

func set_ui_down_y(y: float):
	$UIDown.position.y = y

func calc_mission_board(mission_desc: Array[String], mission_cnum: Array[int], mission_nnum: Array[int]) -> String:
	var text = ""
	var unc_fl: bool = false
	for i in range(len(mission_desc)):
		var nnum = 0
		if i<len(mission_nnum):
			nnum = mission_nnum[i]
		var cnum = 0
		if i<len(mission_cnum):
			cnum = mission_cnum[i]
		if !unc_fl:
			text += "- " + mission_desc[i] + " (" + str(nnum) + "/" + str(cnum) + ")\n"
		else:
			text += "- ??????\n"
		if nnum < cnum:
			unc_fl = true
	return text

func set_block_desc(block: Block):
	if block == null:
		block_desc.text = ""
		block_desc_2.text = ""
		e_bar.visible = false
		return
	if block.is_hidden:
		block_desc.text = "Hidden"
		block_desc_2.text = ""
		e_bar.visible = false
		return
	var name = block.block_name
	var energy = block.energy_num
	var desc = name
	var true_desc = block.block_desc
	block_desc.text = desc
	block_desc_2.text = true_desc
	e_bar_fill_now_x = E_BAR_FILL_MAX_X * energy / block.MAX_ENERGY
	e_bar.visible = block.star_bar.visible
func fade_out_ui():
	print("fade_out_ui")
	if t_tween != null and t_tween.is_running():
		t_tween.kill()
	t_tween = Root.instance.new_tween()
	t_tween.tween_property(self, "modulate", Color(1,1,1,0), 3)

func appear_ui():
	modulate = Color(1,1,1,1)

func fast_init_ui():
	desc_label.visible_ratio = 1
	desc_label.position = DESC_ORIG_POS

func level_init_ui():
	var black_bg = Sprite2D.new()
	black_bg.texture = load("res://imgs/white_bg.png")
	black_bg.z_index = 1000
	black_bg.modulate = Color(0,0,0,1)
	Root.instance.add_child(black_bg)
	

	desc_label.show()
	desc_label.z_index = 1001
	# desc_label.text = desc
	desc_label.visible_ratio = 0
	desc_label.position = Vector2(DESC_ORIG_POS.x,0)
	var d_tween = Root.instance.new_tween()
	d_tween.set_trans(Tween.TRANS_LINEAR).tween_property(desc_label, "visible_ratio", 1, 3 /Root.instance.speed_factor)
	d_tween.tween_interval(3.0/Root.instance.speed_factor)
	d_tween.set_trans(Tween.TRANS_CUBIC).tween_property(desc_label, "position", DESC_ORIG_POS, 4 /Root.instance.speed_factor)
	d_tween.parallel().tween_property(black_bg, "modulate", Color(0,0,0,0), 4 /Root.instance.speed_factor)
	await d_tween.finished
	black_bg.queue_free()
	set_progress_arrow_on_level(Main.instance.current_level.level_id)

var pp_tween: Tween
func set_progress_arrow_on_level(level_id: int):
	var progress_arrow_pos = progress_start + progress_delta * (level_id - 1)
	if pp_tween != null and pp_tween.is_running():
		pp_tween.kill()
	pp_tween = Root.instance.new_tween()
	pp_tween.tween_property(progress_arrow, "position", Vector2(progress_arrow.position.x, progress_arrow_pos), 3)
	pp_tween.parallel().tween_property(self, "progress_now", level_depth[level_id], 3)
