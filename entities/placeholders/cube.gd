extends Node3D

func _ready() -> void:
	var interactable = Interactable.new()
	interactable.dialogue_resource = load("res://assets/dialogue/cubeDialogue.gd").new()
	add_child(interactable)
