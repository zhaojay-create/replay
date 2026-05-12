class_name PressureButton
extends Area2D

signal pressed
signal released

# 要移动的 TileMapLayer 节点
@export var platform: TileMapLayer
# 移动的偏移量（相对于初始位置）
@export var move_offset: Vector2 = Vector2(0, -64)
# 移动持续时间（秒）
@export var duration: float = 1.0

var _bodies_on_button: int = 0
var _initial_position: Vector2
var _tween: Tween

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if platform:
		_initial_position = platform.position
	var player = get_tree().get_first_node_in_group("player") as Player
	if player:
		player.player_died.connect(_on_player_died)

func _on_body_entered(_body: Node2D) -> void:
	_bodies_on_button += 1
	if _bodies_on_button == 1:
		pressed.emit()
		_activate()

func _on_body_exited(_body: Node2D) -> void:
	_bodies_on_button -= 1
	if _bodies_on_button == 0:
		released.emit()
		_deactivate()

func _on_player_died(_player: Player) -> void:
	_reset()

# 上升到目标位置
func _activate() -> void:
	if platform == null: return
	_kill_tween()
	_tween = create_tween()
	_tween.tween_property(
		platform,
		"position",
		_initial_position + move_offset,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# 回到初始位置
func _deactivate() -> void:
	if platform == null: return
	_kill_tween()
	_tween = create_tween()
	_tween.tween_property(
		platform,
		"position",
		_initial_position,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

# 立即重置到初始位置（不带动画）
func _reset() -> void:
	if platform == null: return
	_kill_tween()
	platform.position = _initial_position

func _kill_tween() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
