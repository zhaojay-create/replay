class_name MovingPlatform
extends Node2D

# 要移动的 TileMapLayer 节点
@export var tile_map_layer: TileMapLayer
# 移动的偏移量（相对于初始位置）
@export var move_offset: Vector2 = Vector2(0, -64)
# 移动持续时间（秒）
@export var duration: float = 1.0

var _initial_position: Vector2
var _tween: Tween

func _ready() -> void:
	_initial_position = tile_map_layer.position
	var player = get_tree().get_first_node_in_group("player") as Player
	if player:
		player.player_died.connect(_on_player_died)

func _on_player_died(_player: Player) -> void:
	reset()

# 上升到目标位置
func activate() -> void:
	_kill_tween()
	_tween = create_tween()
	_tween.tween_property(
		tile_map_layer,
		"position",
		_initial_position + move_offset,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# 回到初始位置
func deactivate() -> void:
	_kill_tween()
	_tween = create_tween()
	_tween.tween_property(
		tile_map_layer,
		"position",
		_initial_position,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

# 立即重置到初始位置（不带动画）
func reset() -> void:
	_kill_tween()
	tile_map_layer.position = _initial_position

func _kill_tween() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
