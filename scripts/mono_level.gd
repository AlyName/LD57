class_name MonoLevel

var level_id: int
var level_name: String
var level_desc: String

var mission_num: int
var mission_desc: Array[String]
var mission_cnum: Array[int]

var dialogs: Dictionary = {}

func level_init()-> void:
	pass

func background_control()-> void:
	pass

func after_operate()-> void:
	pass

func first_operate()-> void:
	pass

func check_mission_clear() -> Array[int]:
	# return the nnum of each mission 
	# if all mission (0~mission_num-1) 's nnum == cnum, level is complete
	return []

func level_complete_anim() -> void:
	pass

func short_level_complete() -> void:
	pass


func create_dialog(name: String, size: Vector2 = Vector2(512,512)):
	if Main.instance.played_dialogs.has(str(level_id) + "__" + name):
		return
	Main.instance.played_dialogs[str(level_id) + "__" + name] = true
	var dialog = dialogs[name]
	var dia_box = DiaBox.new()
	dia_box.position = dialog['pos']
	dia_box.custom_minimum_size = size
	Root.instance.add_child(dia_box)
	for d in dialog['dialog']:
		var d_tween = Root.instance.get_tree().create_tween()
		d_tween.tween_interval(d['time'])
		d_tween.tween_callback(func():
			if dia_box != null:
				dia_box.add_dialog(d['dialog'],d['character'])
		)
	await Root.instance.get_tree().create_timer(dialog['duration']).timeout
	dia_box.close()
