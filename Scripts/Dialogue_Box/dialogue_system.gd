extends CanvasLayer

@export_file("*.json") var d_file

var dialogue = []
var current_dialogue_id = 0
var d_active = false

var total_characters = 0
var text_speed = 1
var is_typing = false

func _ready():
	visible = false
	

func _process(_delta):
	if Global.is_talking:
		start()
		start_typing()
	if !Global.is_talking:
		current_dialogue_id = -1
	
	if is_typing:
		if $NinePatchRect/DialogueLabel.visible_characters < total_characters:
			$NinePatchRect/DialogueLabel.visible_characters += text_speed

func start_typing():
	is_typing = true

func start():
	if d_active:
		return
	d_active = true
	visible = true
	dialogue = load_dialogue()
	current_dialogue_id = -1
	next_script()
	

func _input(_event):
	if not d_active:
		return
	if Input.is_action_just_pressed("LMB") and current_dialogue_id < len(dialogue):
		next_script()

func load_dialogue():
	var file = FileAccess.open(Global.dialogue_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open dialogue file at path: " + str(Global.dialogue_path))
		return []
	var content = JSON.parse_string(file.get_as_text())
	if typeof(content) != TYPE_ARRAY:
		push_error("Dialogue file format invalid. Expected an array.")
		return []
	return content


func next_script():
	current_dialogue_id += 1
	
	if current_dialogue_id >= len(dialogue):
		$Timer.start()
		visible = false
		print("dialogue ended")
		return
	
	$NinePatchRect/SpeakerLabel.text = "[center]%s[/center]" % dialogue[current_dialogue_id]["name"]
	$NinePatchRect/DialogueLabel.text = "[center]%s[/center]" % dialogue[current_dialogue_id]["text"]
	
	# count numbers of characters in text
	total_characters = $NinePatchRect/DialogueLabel.text.length()
	# initially no text displayed
	$NinePatchRect/DialogueLabel.visible_characters = 0


func _on_timer_timeout():
	Global.dialogue_check()
	Global.is_talking = false
	d_active = false
