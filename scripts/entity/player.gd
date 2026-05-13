class_name Player
extends Entity

signal player_died(player: Player)

var spawn_location: Vector2

func _ready():
	super._ready()
	add_to_group("player")
	player_died.connect(_on_player_died)

func _exit_tree():
	player_died.disconnect(_on_player_died)

func apply_damage(damage: float) -> bool:
	var was_alive := not is_dead
	var result := super.apply_damage(damage)
	if was_alive and is_dead:
		player_died.emit(self)
	return result

func _physics_process(delta: float) -> void:
	# 每帧录制输入（死亡后也要录制）
	ReplayManager.record_frame()
	super._physics_process(delta)

func _process_alive(_delta: float) -> void:
	# 自杀
	if Input.is_action_just_pressed("suicide"):
		apply_damage(max_health)
		move_and_slide()
		return
	
	# 跳跃
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	# 攻击
	if Input.is_action_just_pressed("attack"):
		print("asda")
		shoot(8, 6)  # layer=PlayerAttack(8), mask=Ghost(2)+Enemy(4)
	
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
