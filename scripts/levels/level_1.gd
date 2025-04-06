extends MonoLevel
class_name Level1

const CENTER_X = 200

func _init():
	level_id = 1
	level_name = "#1. The Mind Gate"
	level_desc = "Falling, falling down like stars..."
	mission_num = 1
	mission_desc = ["Fill the heart"]
	mission_cnum = [4]

func level_init()-> void:
	UI.instance.appear_ui()
	# await Root.instance.get_tree().create_timer(3.0).timeout
	# var dia_box = DiaBox.new()
	# dia_box.position = Vector2(100, 100)
	# Main.instance.add_child(dia_box)
	# dia_box.add_dialog("sample text")

func background_control()-> void:
	if randf() < 0.05:
		var star = Sprite2D.new()
		var init_x = randf() * (Root.instance.width/2-CENTER_X) + CENTER_X
		if randf() < 0.5:
			init_x = -init_x
		star.position = Vector2(init_x,  Root.instance.height/2 + 100)
		var coin = randf()
		if coin < 0.33:
			star.texture = load("res://imgs/dot.png")
		elif coin < 0.66:
			star.texture = load("res://imgs/small_particle.png")
		else:
			star.texture = load("res://imgs/star.png")
		star.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		star.z_index = 100
		var c = randf()
		star.modulate = Color(1,1,1,c)
		star.scale = Vector2(1,1) * (1-c) * 4
		var trans_t = randf()*0.3 + 0.7 + (1-c)
		var trans_tween = Root.instance.new_tween().set_trans(Tween.TRANS_LINEAR)
		trans_tween.tween_property(star, "position", Vector2(star.position.x, -Root.instance.height/2-100), trans_t)
		trans_tween.tween_callback(star.queue_free)
		Root.instance.add_child(star)

func first_operate()-> void:
	await Root.instance.get_tree().create_timer(0.1).timeout
	var init_block_pos = [Vector2(2,0), Vector2(2,1), Vector2(2,2)]
	for i in range(Main.instance.height):
		for j in range(Main.instance.width):
			if Vector2(i,j) in init_block_pos:
				continue
			var block = Main.instance.board[i][j]
			# TODO
	await Root.instance.get_tree().create_timer(2).timeout
	create_dialog("opening", Vector2(370, 400))
	await Root.instance.get_tree().create_timer(7).timeout
	create_dialog("opening2", Vector2(370, 400))

func after_operate()-> void:
	pass

func check_mission_clear() -> Array[int]:
	var board_center = Main.instance.board[2][2]
	return [board_center.energy_num]


func level_complete_anim() -> void:
	var center_block = Main.instance.board[2][2]
	var particle = ParticleManager.instance.create_particle("constant", center_block.position, 256)
	await Root.instance.get_tree().create_timer(0.5).timeout
	center_block.enlight()
	for i in range(0,Main.instance.height):
		for j in range(0,Main.instance.width):
			if i==2 && j==2:
				continue
			var block = Main.instance.board[i][j]
			block.fly_out()
	UI.instance.fade_out_ui()
	await Root.instance.get_tree().create_timer(2.0).timeout
	var white_background = Sprite2D.new()
	white_background.texture = load("res://imgs/dot.png")
	white_background.z_index = 100
	white_background.scale = Vector2(1,1) * 200
	white_background.modulate = Color(1,1,1,0)
	Root.instance.add_child(white_background)
	var camera = Camera.instance
	var n_tween = Root.instance.new_tween().set_trans(Tween.TRANS_QUAD)
	n_tween.tween_property(camera, "zoom", Vector2(2.5,2.5), 8)
	n_tween.parallel().tween_property(white_background, "modulate", Color(1,1,1,1), 6)
	await n_tween.finished
	
	camera.zoom = Vector2(1,1)
	white_background.queue_free()
	particle.queue_free()
	await start_prologue()

func start_prologue() -> void:
	var white_background = Sprite2D.new()
	white_background.texture = load("res://imgs/dot.png")
	white_background.z_index = 100
	white_background.scale = Vector2(1,1) * 600
	white_background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	Root.instance.add_child(white_background)
	var prolog_scene = load("res://scenes/prolog.tscn").instantiate()
	prolog_scene.z_index = 101
	Root.instance.add_child(prolog_scene)
	await Root.instance.get_tree().create_timer(10.0).timeout
	await ParticleManager.instance.change_scene_in()
	white_background.queue_free()
	prolog_scene.queue_free()
