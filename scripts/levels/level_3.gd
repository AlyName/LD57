extends MonoLevel
class_name Level3

var rain: Node2D
var last_umbrella_num: int = 0
var last_top_umbrella_num: int = 0

var next_thunder_round: int = 0

func _init():
	level_id = 3
	level_name = "#3. The Rain"
	level_desc = "Some hearts stretch cloudless to the horizon, \nwhile others know only the drumbeat of rain."
	mission_num = 2
	mission_desc = ["Find at least 7 umbrellas", "Place all umbrellas in the top row."]
	mission_cnum = [7, 7]

func level_init()-> void:
	UI.instance.appear_ui()

	rain = load("res://scenes/rain.tscn").instantiate()
	rain.position = Vector2(0, 0)
	rain.z_index = 10
	rain.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	Main.instance.add_child(rain)

	rain.dest_amount_ratio = 0.125
	rain.dest_fog_strength = 10.0
	rain.dest_speed_scale = 1.0
	rain.dest_wave_alpha = 0.0

	await Root.instance.get_tree().create_timer(8).timeout
	create_dialog("opening")

func first_operate() -> void:
	rain.dest_amount_ratio = 0.125
	rain.dest_fog_strength = 10.0
	rain.dest_speed_scale = 1.0
	rain.dest_wave_alpha = 0.0

	rain.thunder_visible = false

func after_operate() -> void:
	if Main.instance.now_round >= next_thunder_round - 3 and Main.instance.now_round < next_thunder_round:
		rain.thunder_visible = true
	else:
		rain.thunder_visible = false

	if Main.instance.now_round == next_thunder_round:
		Main.instance.lock_board()
		thunders()
		next_thunder_round += 30
		Main.instance.unlock_board()
	if Main.instance.now_round % 17 == 0:
		make_laqe()

func check_mission_clear() -> Array[int]:
	var umbrella_num: int = 0
	var top_umbrella_num: int = 0
	for i in range(Main.instance.height):
		for j in range(Main.instance.width):
			if Main.instance.board[i][j] is BlockUmbrella and Main.instance.board[i][j].is_hidden == false:
				umbrella_num += 1
				if j == 0:
					top_umbrella_num += 1
	if last_umbrella_num != umbrella_num or last_top_umbrella_num != top_umbrella_num:
		if last_umbrella_num <= 6 and umbrella_num == 7:
			create_dialog("umbrella7")
			next_thunder_round = Main.instance.now_round + 3
		last_umbrella_num = umbrella_num
		last_top_umbrella_num = top_umbrella_num
		if umbrella_num == 3:
			medium_rain()
			create_dialog("umbrella3")
		elif umbrella_num == 7:
			
			if top_umbrella_num >= 4:
				huge_rain()
			else:
				heavy_rain()

	return [umbrella_num, top_umbrella_num]

func level_complete_anim() -> void:
	for i in range(0,Main.instance.height):
		for j in range(0,Main.instance.width):
			var block = Main.instance.board[i][j]
			block.fly_out()
	UI.instance.fade_out_ui()
	rain.dest_amount_ratio = 0.0
	rain.dest_fog_alpha = 100.0
	rain.dest_speed_scale = 1.0
	rain.dest_wave_alpha = 0.0
	rain.thunder_visible = false

	create_dialog("final")
	await Root.instance.get_tree().create_timer(15).timeout
	await ParticleManager.instance.change_scene_in()
	rain.queue_free()

func short_level_complete() -> void:
	rain.queue_free()

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
			if Main.instance.board[i][j] is BlockUmbrella:
				break
			if Main.instance.board[i][j].energy_num > 0:
				Main.instance.board[i][j].energy_num = 0
				Main.instance.board[i][j].spark()
				ParticleManager.instance.create_particle("2", Main.instance.board[i][j].position, 16)
			Main.instance.board[i][j].add_shake(5.0)
			
	# after
	var w_tween = Root.instance.new_tween().set_trans(Tween.TRANS_LINEAR)
	w_tween.tween_interval(0.25)
	w_tween.tween_property(white_bg, "modulate", Color(1, 1, 1, 0), 0.25)
	w_tween.tween_callback(white_bg.queue_free)

func medium_rain() -> void:
	rain.dest_amount_ratio = 0.4
	rain.dest_fog_alpha = 10.0
	rain.dest_speed_scale = 1.5
	rain.dest_wave_alpha = 0.02
	

func heavy_rain() -> void:
	rain.dest_amount_ratio = 1.0
	rain.dest_fog_alpha = 5.0
	rain.dest_speed_scale = 2.5
	rain.dest_wave_alpha = 0.1

func huge_rain() -> void:
	rain.dest_amount_ratio = 1.0
	rain.dest_fog_alpha = 3.0
	rain.dest_speed_scale = 4.5
	rain.dest_wave_alpha = 0.2


func make_laqe() -> void:
	var laqe = load("res://scenes/small_thing.tscn").instantiate()
	laqe.texture = load("res://imgs/laqe_bg.png")
	Root.instance.add_child(laqe)
