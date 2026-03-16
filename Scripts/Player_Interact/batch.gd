extends Node

func _input(event):
	if Input.is_action_just_pressed("Confirm"):
		next_batch()

func next_batch():
	if Global.current_batch == 1:
		Global.base = Global.best_match
		print("Base is:", Global.base)
	
	if Global.current_batch == 2:
		Global.qual1 = Global.best_match
		print("Qual1 is:", Global.qual1)
	
	Global.current_batch += 1
	print ("Current batch", Global.current_batch)
