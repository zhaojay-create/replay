class_name InputFrame
extends RefCounted

# 存储一帧的输入数据
var move_direction: float = 0.0  # -1.0 左, 0.0 无, 1.0 右
var jump_pressed: bool = false
var attack_pressed: bool = false
var suicide_pressed: bool = false

func _init():
	pass

# 快照当前帧的所有玩家输入状态
static func capture() -> InputFrame:
	var frame := InputFrame.new()
	frame.move_direction = Input.get_axis("move_left", "move_right")
	frame.jump_pressed = Input.is_action_just_pressed("jump")
	frame.attack_pressed = Input.is_action_just_pressed("attack")
	frame.suicide_pressed = Input.is_action_just_pressed("suicide")
	return frame

# 序列化 / 反序列化（用于存档）
func to_dict() -> Dictionary:
	return {
		"dir": move_direction,
		"jump": jump_pressed,
		"attack": attack_pressed,
		"suicide": suicide_pressed,
	}

static func from_dict(d: Dictionary) -> InputFrame:
	var frame := InputFrame.new()
	frame.move_direction = d.get("dir", 0.0)
	frame.jump_pressed = d.get("jump", false)
	frame.attack_pressed = d.get("attack", false)
	frame.suicide_pressed = d.get("suicide", false)
	return frame
