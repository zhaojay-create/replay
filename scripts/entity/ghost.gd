class_name Ghost
extends Entity

var frames: Array[InputFrame] = []
var _frame_index: int = 0 # 当前播放的帧

@export var speed: float = 200.0
@export var jump_velocity: float = -350.0
@export var gravity: float = 980.0

func _ready() -> void:
	super._ready()
	add_to_group("ghost")
	modulate = Color(0.5, 0.7, 1.0, 0.6)

func _physics_process(delta: float) -> void:
	# 重力
	if not is_on_floor():
		velocity.y += gravity * delta

	# 死亡后停止回放
	if is_dead:
		velocity.x = 0
		move_and_slide()
		return

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

func _update_animation(direction: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		play_animation(AnimationWrapper.new("jump"))
	elif direction != 0:
		play_animation(AnimationWrapper.new("run"))
		animated_sprite.flip_h = direction < 0
	else:
		play_animation(AnimationWrapper.new("idle"))
