extends Node2D

@onready var screen_transition: ColorRect = $CanvasLayer/ColorRect
@onready var ghost_container: Node2D = %GhostContainer
@onready var map_container: Node2D = $MapContainer

func _ready() -> void:
	_load_map()
	var player = get_tree().get_first_node_in_group("player") as Player
	# 从地图的 PlayerSpawn 标记设置出生点
	var spawn_marker = map_container.get_child(0).find_child("PlayerSpawn") as Marker2D
	if spawn_marker:
		player.global_position = spawn_marker.global_position
		player.spawn_location = spawn_marker.global_position
	player.player_died.connect(_handle_game_over)
	ReplayManager.start_recording(player.global_position)

func _load_map() -> void:
	# 清除旧地图
	for child in map_container.get_children():
		child.queue_free()
	# 加载当前关卡地图
	var map_scene = load(LevelManager.get_current_map())
	var map_instance = map_scene.instantiate()
	map_container.add_child(map_instance)

# 当玩家死亡时，先淡入，然后重置玩家位置，再淡出
func _handle_game_over(player: Player)-> void:
	var tween = fade_in_overlay()
	await tween.finished
	
	player.position = player.spawn_location
	
	tween = await fade_out_overlay()
	await tween.finished
	
	player.is_dead = false
	player.current_health = player.max_health
	player.current_anim = null
	player.play_animation(AnimationWrapper.new("idle"))
	ghost_container.spawn_ghosts()
	ReplayManager.start_recording(player.global_position)

# 玩家死亡时淡出
func fade_out_overlay():
	var tween = create_tween()
	tween.tween_property(
		screen_transition,
		"color:a",
		0.0,
		1.0	
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	return tween

# 游戏恢复时淡入	
func fade_in_overlay():
	var tween = create_tween()
	tween.tween_property(
		screen_transition,
		"color:a",
		1.0,
		1.0	
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	return tween
