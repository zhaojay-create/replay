class_name PlateTimerGroup
extends Node

# 踩一下开，N 秒后自动关（即使还踩着）
# 要重新激活需要离开按钮再踩一次

@export var buttons: Array[PressureButton] = []
@export var platform: TileMapLayer
@export var move_offset: Vector2 = Vector2(0, -64)
@export var duration: float = 1.0
# 限时（秒）：激活后自动关闭
@export var hold_duration: float = 3.0

var _pressed_buttons: Array[PressureButton] = []
var _initial_position: Vector2
var _tween: Tween
var _is_open: bool = false
# 防止过期的计时器误触发
var _timer_id: int = 0

func _ready() -> void:
	if platform:
		_initial_position = platform.position
	for btn in buttons:
		btn.pressed.connect(_on_button_pressed.bind(btn))
	var player = get_tree().get_first_node_in_group("player") as Player
	if player:
		player.player_died.connect(_on_player_died)

func _on_button_pressed(btn: PressureButton) -> void:
	if btn not in _pressed_buttons:
		_pressed_buttons.append(btn)
	if _pressed_buttons.size() >= buttons.size() and not _is_open:
		_activate()

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
	_timer_id += 1
	_start_hold_timer(_timer_id)

func _start_hold_timer(id: int) -> void:
	await get_tree().create_timer(hold_duration).timeout
	if id != _timer_id or not _is_open:
		return
	_pressed_buttons.clear()
	_deactivate()

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
	_timer_id += 1
	_kill_tween()
	platform.position = _initial_position
	for btn in buttons:
		btn.reset()

func _kill_tween() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
