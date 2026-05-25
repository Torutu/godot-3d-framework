extends Node
class_name Interactable

@export_file("*.gd") var dialogue_path: String = ""
@export var interaction_label: String = "Speak"

var dialogue_resource: DialogueResource
var display_name: String

func _ready() -> void:
	if dialogue_path != "":
		dialogue_resource = load(dialogue_path).new()
	if dialogue_resource:
		display_name = dialogue_resource.npc_name
	else:
		display_name = get_parent().name
	add_to_group("interactable")
