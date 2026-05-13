class_name Bullet
extends Area2D

@export var bullet_speed: float = 600.0
@export var max_bounces: int = 3
@export var lifetime: float = 5.0
@export var damage: float = 50.0

var direction: Vector2 = Vector2.RIGHT
var _bounces_left: int = 0
var _age: float = 0.0

@onready var _ray: RayCast2D = $RayCast2D

func _ready() -> void:
	_bounces_left = max_bounces
	body_entered.connect(_on_body_entered)
	_update_ray()

func _physics_process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		queue_free()
		return

	# 检测墙壁反弹
	if _ray.is_colliding():
		var normal := _ray.get_collision_normal()
		direction = direction.bounce(normal)
		_bounces_left -= 1
		_update_ray()
		if _bounces_left <= 0:
			queue_free()
			return

	position += direction * bullet_speed * delta

func _update_ray() -> void:
	_ray.target_position = direction * 20.0

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("apply_damage"):
		body.apply_damage(damage)
	queue_free()
