extends Node2D


func _ready():
	# load data/project.json
	var project_file := File.new()
	project_file.open("res://data/project.json", File.READ)
	var json = project_file.get_as_text()
	var project_data = JSON.parse(json).result
	
	# set window title based on project.json
	OS.set_window_title(project_data["title"])
	
	# set window size based on project.json
	var size = project_data["window-size"].split('x')
	var width = size[0]
	var height = size[1]
	OS.set_window_size(Vector2(width, height))
	
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, Vector2(width, height))
	get_tree().change_scene("res://logic/game_handler/Game.tscn")
