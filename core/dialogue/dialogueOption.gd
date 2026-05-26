class_name DialogueOption

var text: String = ""
var goto_id: StringName = &""

func _init(p_text: String = "", p_goto: StringName = &"") -> void:
	text = p_text
	goto_id = p_goto
