extends Node

# 记录当前的操作
var current_recording: Array[InputFrame] = []
# 历史记录，每个元素是一次完整的 run（平行时空）
var histories: Array = []  # Array of { spawn_pos: Vector2, frames: Array[InputFrame] }
# 是否正在记录
var is_recording: bool = false
# 当前 run 的出生点
var _spawn_position: Vector2 = Vector2.ZERO


# 开始记录
func start_recording(spawn_pos: Vector2) -> void:
	current_recording.clear()
	_spawn_position = spawn_pos
	is_recording = true

func _ready() -> void:
	LevelManager.level_changed.connect(_on_level_changed)

func _on_level_changed() -> void:
	current_recording.clear()
	histories.clear()
	is_recording = false

# 记录当前帧
func record_frame() -> void:
	if is_recording:
		current_recording.append(InputFrame.capture())

# 停止记录并保存
func stop_and_save() -> void:
	if not is_recording:
		return
	is_recording = false
	histories.append({
		"spawn_pos": _spawn_position,
		"frames": current_recording.duplicate(),
	})
	current_recording.clear()

# 获取指定索引的 run
func get_run_by_index(index: int) -> Dictionary:
	if index < 0 or index >= histories.size():
		return {}
	return histories[index]

# 获取 run 的数量
func get_run_count() -> int:
	return histories.size()
