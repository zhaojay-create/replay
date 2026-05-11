class_name PressureButton
extends Area2D

@export var platform: MovingPlatform

var _bodies_on_button: int = 0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(_body: Node2D) -> void:
	_bodies_on_button += 1
	if _bodies_on_button == 1:
		if platform == null: return
		platform.activate()

func _on_body_exited(_body: Node2D) -> void:
	_bodies_on_button -= 1
	if _bodies_on_button == 0:
		if platform == null: return
		platform.deactivate()
