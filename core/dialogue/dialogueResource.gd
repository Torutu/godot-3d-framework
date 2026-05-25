extends Resource
class_name DialogueResource

class Conversation:
	var lines: Array[String] = []
	var options: Array = []

class Option:
	var text: String
	var goto_conv: int

	func _init(p_text: String, p_goto: int) -> void:
		text = p_text
		goto_conv = p_goto

var npc_name: String = "Speaker"
var conversations: Array = []

func _init() -> void:
	resource_path = ""

# Adds a sequence of lines as one conversation. Returns the conversation index.
func add_conversation(lines: Array[String]) -> int:
	var conv = Conversation.new()
	conv.lines = lines
	conversations.append(conv)
	return conversations.size() - 1

# Adds a choice button at the end of from_conv that jumps to to_conv.
func add_option(from_conv: int, text: String, to_conv: int) -> void:
	if from_conv >= 0 and from_conv < conversations.size():
		conversations[from_conv].options.append(Option.new(text, to_conv))

func get_conversation(index: int) -> Conversation:
	if index >= 0 and index < conversations.size():
		return conversations[index]
	return null

func conversation_count() -> int:
	return conversations.size()
