class_name Entity
extends CharacterBody2D

@export var max_health: float = 50

var current_health: float
var current_anim: AnimationWrapper
var is_dead: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

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
