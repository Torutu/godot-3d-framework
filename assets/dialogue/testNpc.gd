extends DialogueResource

func _init() -> void:
	super()
	npc_name = "TestNpc"

	add_conversation(["Test line 0."])       # conv 0
	add_conversation(["You picked A."])      # conv 1
	add_conversation(["You picked B."])      # conv 2

	add_option(0, "Option A", 1)
	add_option(0, "Option B", 2)
