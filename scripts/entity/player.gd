class_name Player
extends Entity

signal player_died(player: Player)

var spawn_location: Vector2

@export var speed: float = 200.0
@export var jump_velocity: float = -350.0
@export var gravity: float = 980.0

func _ready():
	super._ready()
	add_to_group("player")
	player_died.connect(_on_player_died)
	spawn_location = global_position
	ReplayManager.start_recording(global_position)

func _exit_tree():
	player_died.disconnect(_on_player_died)

func apply_damage(damage: float) -> bool:
	var was_alive := not is_dead
	var result := super.apply_damage(damage)
	if was_alive and is_dead:
		player_died.emit(self)
	return result

func _physics_process(delta: float) -> void:
	# 重力（死亡后也继续落下）
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 每帧录制输入
	ReplayManager.record_frame()
	
	# 死亡后不再处理输入，但仍执行物理移动
	if is_dead:
		velocity.x = 0
		move_and_slide()
		return
	
	# 自杀
	if Input.is_action_just_pressed("suicide"):
		apply_damage(max_health)
		move_and_slide()
		return
	
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

func _on_player_died(_entity: Entity) -> void:
	ReplayManager.stop_and_save()

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
