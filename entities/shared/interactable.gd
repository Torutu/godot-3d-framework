extends Node
class_name Interactable

@export var dialogue_resource: DialogueResource
@export var interaction_label: String = "Speak"

var display_name: String

func _ready() -> void:
	if dialogue_resource:
		display_name = dialogue_resource.npc_name
		dialogue_resource._build()
	else:
		display_name = get_parent().name
	add_to_group("interactable")
