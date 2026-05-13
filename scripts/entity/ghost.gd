class_name Ghost
extends Entity

var frames: Array[InputFrame] = []
var _frame_index: int = 0 # 当前播放的帧

func _ready() -> void:
	super._ready()
	add_to_group("ghost")
	modulate = Color(0.5, 0.7, 1.0, 0.6)

func _process_alive(_delta: float) -> void:
	# 帧序列播完，保持静止
	if _frame_index >= frames.size():
		velocity.x = 0
		move_and_slide()
		return

	var frame := frames[_frame_index]
	_frame_index += 1

	# 自杀
	if frame.suicide_pressed:
		apply_damage(max_health)
		move_and_slide()
		return

	# 攻击
	if frame.attack_pressed:
		shoot(16, 5)  # layer=GhostAttack(16), mask=Player(1)+Enemy(4)

	# 跳跃
	if frame.jump_pressed and is_on_floor():
		velocity.y = jump_velocity

	# 左右移动
	if frame.move_direction:
		velocity.x = frame.move_direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	_update_animation(frame.move_direction)
