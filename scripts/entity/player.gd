class_name Player
extends Entity

@export var speed: float = 200.0
@export var jump_velocity: float = -350.0
@export var gravity: float = 980.0

func _ready():
	super._ready()
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# 自杀
	if Input.is_action_just_pressed("suicide"):
		apply_damage(max_health)
		return
	
	# 重力
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 跳跃
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	# 左右移动
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()
	_update_animation(direction)

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
