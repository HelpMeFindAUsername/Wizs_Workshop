extends CanvasLayer

@onready var start: Button = $Start
@onready var settings: Button = $Settings

func _ready():
	start.pressed.connect(pressStart)
	settings.pressed.connect(pressSet)

func pressStart():
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func pressSet():
	global.settingsStatus = 0
	get_tree().change_scene_to_file("res://Scenes/UI/setting.tscn")
