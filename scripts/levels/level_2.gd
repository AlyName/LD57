extends MonoLevel
class_name Level2

const BG_MOVE_SPEED: float = 0.1
const BG_MOVE_RANGE: float = 66
const STAIR_OFFSET: float = 435
const CHARACTER_INIT_POS: Vector2 = Vector2(-30,410)
var background: Sprite2D
var stair: Sprite2D
var character: AnimatedSprite2D
var bg_tween: Tween

var last_book_num: int = 0

var plane_collision: Array

func _init():
	level_id = 2
	level_name = "#2. The Library"
	level_desc = "How deeply can one delve into a human heart?"
	mission_num = 1
	mission_desc = ["Find all of the books"]
	mission_cnum = [7]

func level_init()-> void:
	Camera.instance.position = Vector2(0, 0)
	UI.instance.appear_ui()

	background = Sprite2D.new()
	background.texture = load("res://imgs/library_bg_1.png")
	background.z_index = -20
	background.scale = Vector2(1,1) * 2
	background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	background.modulate = Color("#382a49")
	Root.instance.get_node("Special").add_child(background)

	stair = Sprite2D.new()
	stair.texture = load("res://imgs/library_stair.png")
	stair.z_index = -10
	stair.modulate = Color(0,0,0,1)
	stair.position.y = STAIR_OFFSET
	stair.scale = Vector2(1,1) * 2
	stair.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	Root.instance.get_node("Special").add_child(stair)

	character = AnimatedSprite2D.new()
	character.sprite_frames = load("res://imgs/anims/albedo.tres")
	character.animation = "walk_stair_black"
	character.position = CHARACTER_INIT_POS
	character.modulate = Color(0,0,0,1)
	character.scale = Vector2(1,1) * 2
	character.z_index = -11
	character.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	Root.instance.get_node("Special").add_child(character)

	await Root.instance.get_tree().create_timer(8).timeout
	create_dialog("opening")

func background_control()-> void:
	if background == null:
		return
	background.position.x += BG_MOVE_SPEED
	if background.position.x > BG_MOVE_RANGE:
		background.position.x = 0

func after_operate()-> void:
	if len(plane_collision) > 0:
		var front = plane_collision[0]
		if front[1] == Main.instance.now_round:
			plane_collision.remove_at(0)
			plane_collide(front[0])
	if Main.instance.now_round % 17 == 0:
		make_broom()

func check_mission_clear() -> Array[int]:
	var book_num: int = 0
	for i in range(Main.instance.height):
		for j in range(Main.instance.width):
			if Main.instance.board[i][j].energy_num > 0 and Main.instance.board[i][j] is BlockBook:
				book_num += 1
	if book_num != last_book_num:
		last_book_num = book_num
		change_background(book_num)
		if book_num == 2:
			create_dialog("book2")
		elif book_num == 3:
			create_dialog("book3")
		elif book_num == 5:
			create_dialog("book5")
	return [book_num]

func level_complete_anim() -> void:
	for i in range(0,Main.instance.height):
		for j in range(0,Main.instance.width):
			var block = Main.instance.board[i][j]
			block.fly_out()
	UI.instance.fade_out_ui()

	character.animation = "default"
	character.modulate = Color(0,0,0,1)
	character.play("default")

	background.position.y = -7*5
	stair.position.y = STAIR_OFFSET - 7*10
	character.position = character.position

	var out_glow = Sprite2D.new()
	out_glow.texture = load("res://imgs/c1_glowout.png")
	out_glow.z_index = character.z_index -1
	out_glow.position = character.position
	out_glow.scale = Vector2(1,1) * 2
	out_glow.modulate = Color(1,1,1,0)
	Root.instance.get_node("Special").add_child(out_glow)

	var laqe = AnimatedSprite2D.new()
	laqe.sprite_frames = load("res://imgs/anims/laqe.tres")
	laqe.modulate = Color(0,0,0,1)
	laqe.play("2")
	laqe.scale = Vector2(1,1) * 2
	laqe.position = Vector2(-500, 540)
	laqe.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	Root.instance.get_node("Special").add_child(laqe)
	

	bg_tween = Root.instance.new_tween()
	bg_tween.tween_property(background, "position", Vector2(0, -60), 10)
	bg_tween.parallel().tween_property(background, "modulate", Color("#ac9ab8"), 10)
	bg_tween.parallel().tween_property(stair, "position", Vector2(0, STAIR_OFFSET - 120), 10)
	bg_tween.parallel().tween_property(stair, "modulate", Color("#393b6e"), 10)
	bg_tween.parallel().tween_property(character, "position", character.position + Vector2(0, -50), 10)
	bg_tween.parallel().tween_property(character, "modulate", Color(1,1,1,1), 10)
	bg_tween.parallel().tween_property(out_glow, "modulate", Color("#78719f"), 10)
	bg_tween.parallel().tween_property(out_glow, "position", character.position + Vector2(0, -50), 10)
	
	
	var cg_tween = Root.instance.new_tween()
	cg_tween.tween_interval(5)
	cg_tween.parallel().tween_property(laqe, "modulate", Color(1,1,1,1), 10)
	cg_tween.parallel().tween_property(laqe, "position", Vector2(-500, 0), 10)

	await bg_tween.finished
	create_dialog("final")
	await Root.instance.get_tree().create_timer(18).timeout
	await ParticleManager.instance.change_scene_in()
	character.queue_free()
	background.queue_free()
	stair.queue_free()
	laqe.queue_free()
	out_glow.queue_free()
	UI.instance.position = Vector2(0, 0)
	Main.instance.position = Vector2(0, 0)

func short_level_complete() -> void:
	character.queue_free()
	background.queue_free()
	stair.queue_free()
	UI.instance.position = Vector2(0, 0)
	Main.instance.position = Vector2(0, 0)

func character_move_upstair(abs_book_num: int) -> void:
	character.position = CHARACTER_INIT_POS + (abs_book_num-1) * Vector2(40,-50)
	character.play("walk_stair_black")
	await character.animation_finished
	
	

func change_background(book_num: int) -> void:
	if bg_tween != null and bg_tween.is_running():
		bg_tween.kill()
	bg_tween = Root.instance.new_tween()
	var new_color = background.modulate * 1.1
	bg_tween.tween_property(background, "modulate", new_color, 5)

	var main_pos = Vector2(0, -book_num * 25)
	bg_tween.parallel().tween_property(Main.instance, "position", main_pos, 5)

	var ui_pos = Vector2(0, -book_num * 10)
	bg_tween.parallel().tween_property(UI.instance, "position", ui_pos, 5)

	var bg_pos_y = -book_num * 5
	bg_tween.parallel().tween_property(background, "position", Vector2(background.position.x, bg_pos_y), 5)

	var stair_pos_y = STAIR_OFFSET - book_num * 10
	bg_tween.parallel().tween_property(stair, "position", Vector2(0, stair_pos_y), 5)
	await Root.instance.get_tree().create_timer(1).timeout
	if book_num >= 2 and book_num <= 6:
		character_move_upstair(book_num-1)

func add_collision(b_pos: Vector2, round: int) -> void:
	plane_collision.append([b_pos, round])

func plane_collide(b_pos: Vector2) -> void:
	Main.instance.lock_board()
	var victim = Main.instance.get_block_by_pos(b_pos)
	var plane = Sprite2D.new()
	plane.texture = load("res://imgs/paperplanefly.png")
	plane.z_index = victim.z_index + 1
	plane.position = victim.position + Vector2(-1000,150)
	plane.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	Main.instance.add_child(plane)
	
	var tween = Root.instance.create_tween()
	tween.tween_property(plane, "position", victim.position, 3)
	tween.tween_callback(func():
		plane.queue_free()
		ParticleManager.instance.create_particle("2", victim.get_global_position(), 64)
		if victim.energy_num > 0:
			victim.energy_num = 0
			victim.spark()
		victim.add_shake(5.0)
		AudioManager.instance.play_sfx("burst")
		)
		
	await tween.finished
	
	Main.instance.unlock_board()

func make_broom() -> void:
	var broom = load("res://scenes/small_thing.tscn").instantiate()
	broom.texture = load("res://imgs/broom.png")
	Root.instance.add_child(broom)
