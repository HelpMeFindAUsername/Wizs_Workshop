extends CanvasLayer

@onready var start: Button = $Start

func _ready():
	start.pressed.connect(pressStart)

func pressStart():
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
