extends Control

func _unhandled_key_input(event):
	get_tree().change_scene_to_file("res://Main.tscn")
