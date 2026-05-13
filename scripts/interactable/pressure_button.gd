class_name PressureButton
extends Area2D

signal pressed
signal released

var _bodies_on_button: int = 0
var is_pressed: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(_body: Node2D) -> void:
	_bodies_on_button += 1
	if not is_pressed:
		is_pressed = true
		pressed.emit()

func _on_body_exited(_body: Node2D) -> void:
	_bodies_on_button -= 1
	if _bodies_on_button <= 0:
		_bodies_on_button = 0
		if is_pressed:
			is_pressed = false
			released.emit()

func reset() -> void:
	_bodies_on_button = 0
	is_pressed = false
