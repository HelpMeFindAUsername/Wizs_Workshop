extends Node

#GESTURE RECOGNITION STUFF DO NOT TOUCH
#----------------------------------------------
var shapes_folder_path := "res://Gestures/"
var best_match := ""

var base := ""
var ink := ""
var qual1 := ""
var qual2 := ""

#Checks what batch is currently undergoing player inspection, 0 = base, 1 = quality, 2 = and quality
var current_batch := 0

func batch_overflow():
	if current_batch >= 3:
		current_batch = 2

#----------------------------------------------

var settingsStatus : bool
