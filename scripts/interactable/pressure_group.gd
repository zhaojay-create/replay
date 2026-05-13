class_name PressureGroup
extends Node

# 需要踩下的按钮（1个或多个，全部踩下才激活）
@export var buttons: Array[PressureButton] = []
# 要移动的平台
@export var platform: TileMapLayer
# 移动的偏移量（相对于初始位置）
@export var move_offset: Vector2 = Vector2(0, -64)
# 移动持续时间（秒）
@export var duration: float = 1.0

var _pressed_buttons: Array[PressureButton] = []
var _initial_position: Vector2
var _tween: Tween
var _is_open: bool = false

func _ready() -> void:
	if platform:
		_initial_position = platform.position
	for btn in buttons:
		btn.pressed.connect(_on_button_pressed.bind(btn))
		btn.released.connect(_on_button_released.bind(btn))
	var player = get_tree().get_first_node_in_group("player") as Player
	if player:
		player.player_died.connect(_on_player_died)

func _on_button_pressed(btn: PressureButton) -> void:
	if btn not in _pressed_buttons:
		_pressed_buttons.append(btn)
	if _pressed_buttons.size() >= buttons.size() and not _is_open:
		_activate()

func _on_button_released(btn: PressureButton) -> void:
	_pressed_buttons.erase(btn)
	if _pressed_buttons.size() < buttons.size() and _is_open:
		_deactivate()

func _on_player_died(_player: Player) -> void:
	_reset()

func _activate() -> void:
	if platform == null: return
	_is_open = true
	_kill_tween()
	_tween = create_tween()
	_tween.tween_property(
		platform,
		"position",
		_initial_position + move_offset,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _deactivate() -> void:
	if platform == null: return
	_is_open = false
	_kill_tween()
	_tween = create_tween()
	_tween.tween_property(
		platform,
		"position",
		_initial_position,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _reset() -> void:
	if platform == null: return
	_is_open = false
	_pressed_buttons.clear()
	_kill_tween()
	platform.position = _initial_position
	for btn in buttons:
		btn.reset()

func _kill_tween() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
