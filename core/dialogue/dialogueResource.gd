extends Resource
class_name DialogueResource

@export var npc_name: String = "Speaker"
@export var dialogue_script: Script

var _conversations: Array[DialogueConversation] = []
var _built: bool = false

func _build() -> void:
	if _built or not dialogue_script:
		return
	var instance: DialogueScript = dialogue_script.new()
	for conv in instance.get_conversations():
		_conversations.append(conv as DialogueConversation)
	_built = true

func get_start() -> DialogueConversation:
	_build()
	return _conversations[0] if not _conversations.is_empty() else null

func get_conversation(id: StringName) -> DialogueConversation:
	_build()
	for conv in _conversations:
		if conv.id == id:
			return conv
	return null

func has_conversations() -> bool:
	return dialogue_script != null
