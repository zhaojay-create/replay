extends Node2D

var ghost_scene: PackedScene = preload("res://scenes/entity/ghost.tscn")

func spawn_ghosts() -> void:
	# 如果没有回放数据，直接返回
	if ReplayManager.get_run_count() <= 0:
		return

	clear_ghosts()
	for i in range(ReplayManager.get_run_count()):
		var run = ReplayManager.get_run_by_index(i)
		var ghost = ghost_scene.instantiate() as Ghost
		ghost.global_position = run["spawn_pos"]
		ghost.frames = run["frames"]
		add_child(ghost)

func clear_ghosts() -> void:
	for child in get_children():
		child.queue_free()
