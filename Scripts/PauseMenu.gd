extends CanvasLayer

@onready var panel = $Panel

@onready var res: Button = $Panel/Res
@onready var settings: Button = $Panel/Settings
@onready var btt: Button = $Panel/BTT

func _ready():
	panel.visible = 0
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	
	#L'if della smisurata infelicità e solitudine
	var unhappyness = randi_range(0, 1)
	if unhappyness == 1:
		print("Provo estreme infelicità e solitudine")
	else:
		print("Boh ci sta")
	
	res.pressed.connect(resume)
	settings.pressed.connect(sett)
	
	
func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		togglePause()

func togglePause():
	get_tree().paused = !get_tree().paused
	panel.visible = !panel.visible


func resume():
	togglePause()
	
func sett():
	global.settingsStatus = 1
	get_tree().change_scene_to_file("res://Scenes/UI/setting.tscn")
