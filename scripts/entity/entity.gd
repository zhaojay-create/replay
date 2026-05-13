class_name Entity
extends CharacterBody2D

@export var max_health: float = 50
@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 980.0

var current_health: float
var current_anim: AnimationWrapper
var is_dead: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var _bullet_scene: PackedScene = preload("res://scenes/entity/bullet.tscn")

func _ready() -> void:
	current_health = max_health
	animated_sprite.animation_finished.connect(on_animation_finished)


func _exit_tree():
	animated_sprite.animation_finished.disconnect(on_animation_finished)

func apply_damage(damage: float) -> bool:
	if is_dead: return false
	
	current_health -= damage
	current_health = max(0, current_health)
	
	if current_health == 0:
		is_dead = true
		play_animation(AnimationWrapper.new("die", true))
	
	return true

func play_animation(anim: AnimationWrapper):
	if animated_sprite.animation == anim.name: return
	
	if (
		current_anim != null and current_anim.is_high_priority
		and not anim.is_high_priority
	): return
	
	current_anim = anim
	animated_sprite.play(anim.name)

func on_animation_finished():
	current_anim = null

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	if is_dead:
		velocity.x = 0
		move_and_slide()
		return
	_process_alive(delta)

func _process_alive(_delta: float) -> void:
	pass

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

func shoot(attack_layer: int, attack_mask: int) -> void:
	var bullet = _bullet_scene.instantiate()
	var dir := -1.0 if animated_sprite.flip_h else 1.0
	bullet.direction = Vector2(dir, 0)
	bullet.collision_layer = attack_layer
	bullet.collision_mask = attack_mask
	bullet.global_position = global_position
	get_tree().current_scene.add_child(bullet)
