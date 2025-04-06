extends MonoLevel
class_name Level4

var cat

func _init():
	level_id = 4
	level_name = "#4. The Guardian"
	level_desc = "Some run shallow, bright as mountain streams; others plunge into unknowable depths."
	mission_num = 2
	mission_desc = ["Activate the Guardian", "Feed her with some... (maybe) fish?"]
	mission_cnum = [1, 2]

func level_init()-> void:
	UI.instance.appear_ui()

	var bg_carpet = load("res://scenes/carpet.tscn").instantiate()
	bg_carpet.position = Vector2(-800, -450)
	bg_carpet.z_index = -100
	Main.instance.add_child(bg_carpet)
	await Root.instance.get_tree().create_timer(8).timeout
	create_dialog("opening")

func first_operate() -> void:
	pass

func after_operate() -> void:
	cat = null
	for i in range(Main.instance.height):
		for j in range(Main.instance.width):
			if Main.instance.board[i][j] is BlockCat:
				cat = Main.instance.board[i][j]
				break
	if cat != null and cat is BlockCat and cat.energy_num > 0:
		Main.instance.lock_board()
		await try_eat()
		Main.instance.unlock_board()
	for i in range(Main.instance.height):
		for j in range(Main.instance.width):
			if Main.instance.board[i][j] is BlockPawn:
				Main.instance.board[i][j].attack()
			elif Main.instance.board[i][j] is BlockRook:
				Main.instance.board[i][j].attack()

var last_first_mission = 0
func check_mission_clear() -> Array[int]:
	var first_mission = 0
	if cat != null and cat is BlockCat and cat.energy_num > 0:
		first_mission = 1
		if last_first_mission != first_mission:
			last_first_mission = first_mission
			create_dialog("kitty")
	var second_mission = 2
	for i in range(Main.instance.height):
		for j in range(Main.instance.width):
			if Main.instance.board[i][j] is BlockFish and Main.instance.board[i][j].eaten == false:
				second_mission -= 1
	return [first_mission, second_mission]

func level_complete_anim() -> void:
	for i in range(0,Main.instance.height):
		for j in range(0,Main.instance.width):
			var block = Main.instance.board[i][j]
			block.fly_out()
	UI.instance.fade_out_ui()
	
	await ParticleManager.instance.change_scene_in()

func try_eat() -> void:
	var tx = [1, -1 ,0 ,0]
	var ty = [0, 0 ,1 ,-1]
	var poses = []
	for i in range(4):
		poses.append(cat.b_pos + Vector2(tx[i], ty[i]))
	for pos in poses:
		var block = Main.instance.get_block_by_pos(pos)
		if block != null and block is BlockFish and block.eaten == false:
			var n_tween = Root.instance.new_tween()
			n_tween.tween_property(cat.pattern, "position", 60 * (pos - cat.b_pos), 0.5)
			n_tween.tween_interval(0.5)
			n_tween.tween_callback(func():
				block.eat()
				ParticleManager.instance.create_particle("2", block.position, 32)
					)
			n_tween.tween_interval(0.5)
			n_tween.tween_property(cat.pattern, "position", Vector2(0, 0), 0.5)
			await n_tween.finished
