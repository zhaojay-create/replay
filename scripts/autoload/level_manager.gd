extends Node

signal level_changed

# 地图场景路径列表，按顺序排列
@export var maps: Array[String] = [
	"res://scenes/maps/map_01.tscn",
	"res://scenes/maps/map_02.tscn",
]
@export var fade_duration: float = 0.5

const PLAY_SCENE_PATH := "res://scenes/play_scene.tscn"

var current_level_index: int = 0
var _is_transitioning: bool = false

@onready var _overlay: ColorRect = $CanvasLayer/Overlay

func get_current_map() -> String:
	return maps[current_level_index]

func go_to_next_level() -> void:
	if _is_transitioning:
		return
	current_level_index += 1
	print("通关了! 当前关卡", current_level_index)
	if current_level_index >= maps.size():
		current_level_index = 0
	_transition_to(PLAY_SCENE_PATH)

func restart_level() -> void:
	if _is_transitioning:
		return
	_transition_to(PLAY_SCENE_PATH)

func _transition_to(scene_path: String) -> void:
	_is_transitioning = true
	get_tree().paused = true

	# 淡入黑屏
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_overlay, "color:a", 1.0, fade_duration)
	await tween.finished

	level_changed.emit()
	get_tree().change_scene_to_file(scene_path)

	# 等一帧让新场景初始化
	await get_tree().process_frame

	# 淡出黑屏
	tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_overlay, "color:a", 0.0, fade_duration)
	await tween.finished

	get_tree().paused = false
	_is_transitioning = false
