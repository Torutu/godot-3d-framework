extends DialogueScript

func get_conversations() -> Array:
	return [_start(), _details(), _buh()]

func _start() -> DialogueConversation:
	var c := DialogueConversation.new()
	c.id = &"start"
	c.lines = [
		"Helloo!",
		"What do you want?",
	]
	c.options = [
		DialogueOption.new("Tell me more", &"details"),
		DialogueOption.new("Goodbye", &""),
	]
	return c

func _details() -> DialogueConversation:
	var c := DialogueConversation.new()
	c.id = &"details"
	c.lines = [
		"Well, you see...",
		"It's complicated.",
	]
	c.options = [
		DialogueOption.new("Go back", &"start"),
		DialogueOption.new("You know what... F#%K YOU!", &"buh"),
		DialogueOption.new("I see. Bye.", &""),
	]
	return c

func _buh() -> DialogueConversation:
	var c := DialogueConversation.new()
	c.id = &"buh"
	c.lines = [
		"Wow, rude much?",
		"Whatever, bye.",
	]
	c.options = [
		DialogueOption.new("Goodbye", &""),
	]
	return c
	
