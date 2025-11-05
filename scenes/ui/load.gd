extends Control

func _input(event):
	if event.is_pressed() and not event.is_echo():
		var scene_path := "res://scenes/ui/control.tscn"
		if ResourceLoader.exists(scene_path):
			get_tree().change_scene_to_file(scene_path)
