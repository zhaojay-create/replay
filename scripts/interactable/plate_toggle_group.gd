class_name PlateToggleGroup
extends Node

# 踩一下开，再踩一下关

@export var buttons: Array[PressureButton] = []
@export var platform: TileMapLayer
@export var move_offset: Vector2 = Vector2(0, -64)
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
	var player = get_tree().get_first_node_in_group("player") as Player
	if player:
		player.player_died.connect(_on_player_died)

func _on_button_pressed(btn: PressureButton) -> void:
	# 切换：在列表中则移除，不在则加入
	if btn in _pressed_buttons:
		_pressed_buttons.erase(btn)
	else:
		_pressed_buttons.append(btn)
	_check_state()

func _check_state() -> void:
	var all_pressed := _pressed_buttons.size() >= buttons.size()
	if all_pressed and not _is_open:
		_activate()
	elif not all_pressed and _is_open:
		_deactivate()

func _on_player_died(_player: Player) -> void:
	_reset()

func _activate() -> void:
	if platform == null: return
	_is_open = true
	_kill_tween()
	_tween = create_tween()
	_tween.tween_property(
		platform, "position",
		_initial_position + move_offset, duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _deactivate() -> void:
	if platform == null: return
	_is_open = false
	_kill_tween()
	_tween = create_tween()
	_tween.tween_property(
		platform, "position",
		_initial_position, duration
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
