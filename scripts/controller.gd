# Controller : The state machine for the game
extends Node2D
class_name Controller

static var instance: Controller

const MAX_LEVEL_ID = 6

# state machine
enum {NONE, REALINIT, INIT, GAMESTART, LEVELINIT, INLEVEL, LEVELRESET, LEVELCOMPLETE}
var state = NONE
var interrupt_state = NONE

# global game info
var g_level_id: int = 0

var wheel: Node2D

func _init() -> void:
	instance = self

func _ready() -> void:
	wheel = Root.instance.get_node("Wheel")

func _process(_delta: float) -> void:
	if state == NONE:
		return
	var next_state = process_state(state)
	if interrupt_state != NONE:
		var i_state = interrupt_state
		interrupt_state = NONE
		if i_state != state:
			init_state(i_state)
		state = i_state
	if next_state != NONE:
		if next_state != state:
			init_state(next_state)
		state = next_state
	wheel.visible = (Main.instance.is_locked > 0)

func process_state(state):
	var next_state = NONE
	match state:
		INLEVEL:
			# 每帧调用关卡的background_control
			if Main.instance.current_level:
				Main.instance.current_level.background_control()
	return next_state

func init_state(state) -> void:
	if state == INIT:
		insert_interrupt(GAMESTART)
	elif state == GAMESTART:
		Main.instance.level_clear()
		g_level_id = 1
		insert_interrupt(LEVELINIT)
	elif state == LEVELINIT:
		ParticleManager.instance.change_scene_out()
		Main.instance.level_clear()
		if g_level_id > MAX_LEVEL_ID:
			insert_interrupt(LEVELCOMPLETE)
		else:
			Main.instance.level_init(g_level_id)
			# 初始化关卡元数据
			Main.instance.init_level_meta(g_level_id)
			insert_interrupt(INLEVEL)
	elif state == LEVELRESET:
		insert_interrupt(LEVELINIT)
	elif state == LEVELCOMPLETE:
		var epilogue = load("res://scenes/epilogue.tscn").instantiate()
		epilogue.z_index = 200
		epilogue.position = Vector2(0, 0)
		Root.instance.add_child(epilogue)
	elif state == REALINIT:
		var prologue = load("res://scenes/proprolog.tscn").instantiate()
		prologue.z_index = 200
		prologue.position = Vector2(0, 0)
		Root.instance.add_child(prologue)
		await get_tree().create_timer(7.0).timeout
		insert_interrupt(INIT)
		await get_tree().create_timer(0.1).timeout
		prologue.queue_free()
		

func insert_interrupt(state) -> void:
	interrupt_state = state

## input detect
func handle_input(input_s: String) -> void:
	Main.instance.handle_input(input_s)
