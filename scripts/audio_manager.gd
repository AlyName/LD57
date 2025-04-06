class_name AudioManager
extends Node

# 单例实例
static var instance: AudioManager

var bgm_volume_int: int = 10 # 0~10
var sfx_volume_int: int = 10 # 0~10
# 音量控制
var bgm_volume: float = 1.0:
	set(value):
		bgm_volume = clamp(value, 0.0, 1.0)
		update_bgm_volume()
var sfx_volume: float = 1.0:
	set(value):
		sfx_volume = clamp(value, 0.0, 1.0)

# 音频资源
var bgm_player: AudioStreamPlayer
var current_bgm: String = ""
var sfx_pool: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE = 5

# 路径配置
const BGM_PATH = "res://audio/bgm/"
const SFX_PATH = "res://audio/sfx/"

func _init():
	instance = self

func _ready():
	var player = AudioStreamPlayer.new()
	player.bus = "BGM"
	bgm_player = player
	add_child(player)
	player.finished.connect(_bgm_player_finished)
	
	# 初始化SFX对象池
	for i in SFX_POOL_SIZE:
		var sfx = AudioStreamPlayer.new()
		sfx.bus = "SFX"
		sfx.finished.connect(_recycle_sfx_player.bind(sfx))
		sfx_pool.append(sfx)
		add_child(sfx)

func play_bgm(name: String, fade_time: float = 0.0):
	if current_bgm == name and bgm_player.playing:
		return
	
	
	# 加载音频资源
	var path = BGM_PATH + name + ".ogg"
	if not ResourceLoader.exists(path):
		push_warning("BGM not found: ", path)
		var alt_path = BGM_PATH + name + ".mp3"
		if not ResourceLoader.exists(alt_path):
			push_warning("BGM not found: ", alt_path)
			return
		path = alt_path

	# 淡出旧BGM
	if bgm_player.playing:
		# create_tween().tween_property(old_player, "volume_db", -80.0, fade_time)
		# await get_tree().create_timer(fade_time).timeout
		bgm_player.stop()
	
	# 播放新BGM
	bgm_player.stream = load(path)
	bgm_player.volume_db = linear_to_db(bgm_volume)
	bgm_player.play()
	current_bgm = name

func stop_bgm(fade_time: float = 0.0):
	if fade_time > 0.0:
		create_tween().tween_property(bgm_player, "volume_db", -80.0, fade_time)
		await get_tree().create_timer(fade_time).timeout
		if bgm_player.playing:
			bgm_player.stop()
		bgm_player.volume_db = linear_to_db(0.0)
	else:
		if bgm_player.playing:
			bgm_player.stop()
	current_bgm = ""

func play_sfx(name: String):
	var player = _get_available_sfx_player()
	if not player:
		return
	
	var path = SFX_PATH + name + ".ogg"
	if not ResourceLoader.exists(path):
		push_warning("SFX not found: ", path)
		var alt_path = SFX_PATH + name + ".wav"
		if not ResourceLoader.exists(alt_path):
			push_warning("SFX not found: ", alt_path)
			return
		path = alt_path
	
	player.stream = load(path)
	player.volume_db = linear_to_db(sfx_volume)
	player.play()

func update_bgm_volume():
	if bgm_player.playing:
		bgm_player.volume_db = linear_to_db(bgm_volume)

func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_pool:
		if not player.playing:
			return player
	return null

func _recycle_sfx_player(player: AudioStreamPlayer):
	if not sfx_pool.has(player):
		player.queue_free()

func _bgm_player_finished():
	play_bgm(current_bgm, 1)

# 新增立即切换BGM函数
func play_bgm_cut(name: String):
	play_bgm(name, 0)

## DANGEROUS FUNCTION !
func fade_out_bgm(fade_time: float=3.0):
	create_tween().tween_property(bgm_player, "volume_db", -80.0, fade_time)
	await get_tree().create_timer(fade_time).timeout
	bgm_player.stop()
