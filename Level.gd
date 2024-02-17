extends Node2D

var initial_raudino = null
const Raudino = preload("res://Raudino.tscn")


func set_initial_raudino(new_position: Vector2, new_scale: Vector2):
	if initial_raudino == null:
		initial_raudino = {
			"position": new_position,
			"scale": new_scale
		}


func _on_raudino_tree_exited():
	spawn_player()


func spawn_player():
	var raudino = Raudino.instantiate()
	raudino.position = initial_raudino.position
	raudino.scale = initial_raudino.scale
	raudino.tree_exited.connect(_on_raudino_tree_exited)
	add_child(raudino)
