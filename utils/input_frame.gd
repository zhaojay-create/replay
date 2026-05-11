class_name InputFrame
extends RefCounted

# 存储一帧的输入数据
var move_direction: float = 0.0  # -1.0 左, 0.0 无, 1.0 右
var jump_pressed: bool = false
var action_pressed: bool = false
var suicide_pressed: bool = false

func _init():
	pass

static func capture() -> InputFrame:
	var frame := InputFrame.new()
	frame.move_direction = Input.get_axis("move_left", "move_right")
	frame.jump_pressed = Input.is_action_just_pressed("jump")
	frame.action_pressed = Input.is_action_just_pressed("attack")
	frame.suicide_pressed = Input.is_action_just_pressed("suicide")
	return frame
