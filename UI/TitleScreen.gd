extends Control

func _unhandled_key_input(_event):
	var key_event := _event as InputEventKey
	if key_event.is_pressed() and key_event.keycode != KEY_ESCAPE:
		get_tree().change_scene_to_file("res://Main.tscn")
