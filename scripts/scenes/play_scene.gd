extends Node2D

@export var screen_transition: ColorRect

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player") as Player
	player.player_died.connect(_handle_game_over)

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
