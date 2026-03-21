extends Node2D

var all_base : Array = ["PROJECTILE", "MIST", "IMPACT", "AREA", "MOVEMENT", "WHIRL"]
var all_ink : Array = ["IS", "TURNS", "REMOVES"]
var all_qual : Array = ["FIRE", "WATER", "PAIN", "LOVE", "FAST", "SLOW", "BIG", "SMALL", "MULTI", "THIN"]

func _ready():
	randomize_order()

func randomize_order():
	#Asks for base
	var asked_base = randi_range(0, all_base.size() -1)
	var asked_ink = randi_range(0, all_ink.size() -1)
	var asked_qual1 =randi_range(0, all_qual.size() -1)
	
	print(all_base.get(asked_base) +" "+ all_ink.get(asked_ink) +" "+ all_qual.get(asked_qual1))
