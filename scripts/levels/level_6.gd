extends MonoLevel
class_name Level6

const CENTER_X = 200

var next_thunder_round: int = 0
var thunder: Sprite2D

var fake_center: Node2D

func _init() -> void:
	level_id = 6
	level_name = "#6. Finale"
	level_desc = "\nAt times I find myself unable to comprehend."
	mission_num = 3
	mission_desc = ["Fill the heart", "Find out 6 wings", "Fill all of the wings"]
	mission_cnum = [4, 6, 6]


func _ready() -> void:
	pass

func level_init()-> void:
	UI.instance.appear_ui()
	thunder = Sprite2D.new()
	thunder.texture = load("res://imgs/thunder.png")
	thunder.z_index = 200
	thunder.position = Vector2(0, -400)
	thunder.visible = false
	Main.instance.add_child(thunder)

	fake_center = Node2D.new()
	fake_center.name = "fake_center"
	Main.instance.add_child(fake_center)

	next_thunder_round = 30
	await Root.instance.get_tree().create_timer(8).timeout
	create_dialog("opening")

func first_operate() -> void:
	pass

func after_operate() -> void:
	for i in range(Main.instance.height):
		for j in range(Main.instance.width):
			if Main.instance.board[i][j] is BlockPawn:
				Main.instance.board[i][j].attack()
			elif Main.instance.board[i][j] is BlockRook:
				Main.instance.board[i][j].attack()
	
	if Main.instance.now_round >= next_thunder_round - 3 and Main.instance.now_round < next_thunder_round:
		thunder.visible = true
	else:
		thunder.visible = false

	if Main.instance.now_round == next_thunder_round:
		Main.instance.lock_board()
		thunders()
		next_thunder_round += 30
		Main.instance.unlock_board()

func level_complete_anim() -> void:
	for i in range(0,Main.instance.height):
		for j in range(0,Main.instance.width):
			var block = Main.instance.board[i][j]
			block.fly_out()
	UI.instance.fade_out_ui()
	var g_tween = Root.instance.new_tween()
	g_tween.tween_property(fake_center, "position", Vector2(0, 450), 10.0)
	await g_tween.finished
	create_dialog("final")
	await Root.instance.get_tree().create_timer(21).timeout
	g_tween = Root.instance.new_tween()
	g_tween.tween_property(fake_center, "position", Vector2(0, -1000), 3.0)
	await g_tween.finished
	await ParticleManager.instance.change_scene_in_white()

var history_max_heart_e_num = 0
func check_mission_clear() -> Array[int]:
	var heart_e_num = 0
	var wing_discover_num = 0
	var wing_full_num = 0
	for i in range(0,Main.instance.height):
		for j in range(0,Main.instance.width):
			var block = Main.instance.board[i][j]
			if block is BlockHeart:
				heart_e_num += block.last_energy_num_0
			if block is BlockWing and block.is_hidden == false:
				wing_discover_num += 1
			if block is BlockWing and block.is_hidden == false and block.pattern.visible == false:
				wing_full_num += 1
	if heart_e_num > history_max_heart_e_num:
		history_max_heart_e_num = heart_e_num
		if heart_e_num == 4:
			create_dialog("heart")
	return [heart_e_num, wing_discover_num, wing_full_num]

func thunders() -> void:
	# display
	var white_bg = Sprite2D.new()
	white_bg.texture = load("res://imgs/white_bg.png")
	white_bg.z_index = 200
	white_bg.position = Vector2(0, 0)
	Root.instance.add_child(white_bg)
	AudioManager.instance.play_sfx("burst")
	
	# effect
	for i in range(Main.instance.height):
		for j in range(Main.instance.width):
			if Main.instance.board[i][j] is BlockUmbrella and Main.instance.board[i][j].is_hidden == false:
				break
			if Main.instance.board[i][j].energy_num > 0:
				Main.instance.board[i][j].energy_num = 0
				ParticleManager.instance.create_particle("2", Main.instance.board[i][j].position, 16)
			Main.instance.board[i][j].add_shake(5.0)
			
	# after
	var w_tween = Root.instance.new_tween().set_trans(Tween.TRANS_LINEAR)
	w_tween.tween_interval(0.25)
	w_tween.tween_property(white_bg, "modulate", Color(1, 1, 1, 0), 0.25)
	w_tween.tween_callback(white_bg.queue_free)


func background_control()-> void:
	if randf() < 0.2:
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
		trans_tween.tween_property(star, "position", Vector2(star.position.x, -Root.instance.height/2-100), trans_t / 2.0)
		trans_tween.tween_callback(star.queue_free)
		Root.instance.add_child(star)
