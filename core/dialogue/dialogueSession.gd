extends Node
class_name DialogueSession

@export var player_index: int = 0
@export var raycast: RayCast3D

var is_in_dialogue: bool = false

var _body: CharacterBody3D
var _ui: Control
var _prompt: Control
var _dialogue: DialogueResource
var _conv: StringName = &""
var _conv_line: int = 0
var _active_npc: Node3D

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	_body = get_parent() as CharacterBody3D
	if not raycast and _body:
		raycast = _body.get_node_or_null("Camera3D/InteractionRay") as RayCast3D
	if raycast and _body:
		raycast.add_exception(_body)
	_ui = load("res://ui/dialogue/dialogueUI.tscn").instantiate()
	_ui.option_confirmed.connect(select_option)
	_ui.hide()
	get_tree().root.add_child(_ui)
	PauseManager.game_paused.connect(_on_paused)
	PauseManager.game_resumed.connect(_on_resumed)

func _process(_delta: float) -> void:
	if get_tree().paused:
		return
	if is_in_dialogue and _ui and _ui.visible and _active_npc:
		var ray_length := (raycast.target_position.length() if raycast else 3.0) + 1.0
		if _body and _body.global_position.distance_to(_active_npc.global_position) > ray_length:
			close_dialogue()
		return
	_update_prompt()

func _input(event: InputEvent) -> void:
	if get_tree().paused:
		return
	var interact := "p%d_interact" % player_index

	if not is_in_dialogue:
		if event.is_action_pressed(interact):
			get_viewport().set_input_as_handled()
			_find_and_start()
		return

	if event.is_action_pressed(interact):
		get_viewport().set_input_as_handled()
		var conv := _dialogue.get_conversation(_conv) if _dialogue else null
		var is_last_line := _conv_line >= conv.lines.size() - 1 if conv else false
		if conv and is_last_line and not conv.options.is_empty():
			_ui.confirm()
		else:
			_try_advance()

	if event.is_action_pressed("ui_up"):
		get_viewport().set_input_as_handled()
		_ui.navigate(-1)

	if event.is_action_pressed("ui_down"):
		get_viewport().set_input_as_handled()
		_ui.navigate(1)

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			get_viewport().set_input_as_handled()
			_ui.navigate(-1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			get_viewport().set_input_as_handled()
			_ui.navigate(1)

	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_ui.confirm()

	if event is InputEventKey and event.pressed:
		var num: int = event.keycode - KEY_1
		if num >= 0 and num <= 8:
			var conv2 := _dialogue.get_conversation(_conv) if _dialogue else null
			var on_last := _conv_line >= conv2.lines.size() - 1 if conv2 else false
			if on_last:
				get_viewport().set_input_as_handled()
				select_option(num)

func _update_prompt() -> void:
	var nearest := _raycast_interactable()
	if nearest:
		if not _prompt:
			_prompt = load("res://ui/interaction_prompt/interactionPrompt.tscn").instantiate()
			get_tree().root.add_child(_prompt)
		_prompt.set_prompt(nearest.interaction_label, nearest.display_name)
		_prompt.show()
	else:
		if _prompt:
			_prompt.hide()

func _find_and_start() -> void:
	var best := _raycast_interactable()
	if best:
		start_dialogue(best)

func _raycast_interactable() -> Interactable:
	if not raycast:
		DebugManager.log("[DialogueSession] raycast is null")
		return null
	if not raycast.is_colliding():
		return null
	var collider := raycast.get_collider()
	DebugManager.log("[DialogueSession] ray hit: %s" % (collider.name if collider else "null"))
	return _interactable_in_parents(collider)

func _interactable_in_parents(node: Node) -> Interactable:
	var current := node
	while current:
		DebugManager.log("[DialogueSession] checking: %s | Interactable: %s" % [current.name, current is Interactable])
		var interactable := current as Interactable
		if interactable:
			DebugManager.log("[DialogueSession] found Interactable, dialogue_resource: %s" % str(interactable.dialogue_resource))
			if interactable.dialogue_resource:
				return interactable
		current = current.get_parent()
	return null

func start_dialogue(interactable: Interactable) -> void:
	var dialogue := interactable.dialogue_resource
	if not dialogue or not dialogue.has_conversations():
		return

	_dialogue = dialogue
	_conv_line = 0
	is_in_dialogue = true

	var start := dialogue.get_start()
	_conv = start.id if start else &""

	var raw: Node = interactable
	_active_npc = raw as Node3D

	if _prompt:
		_prompt.hide()
	_ui.show()
	_show_line()
	DialogueManager.dialogue_started.emit(player_index)

func _show_line() -> void:
	var conv := _dialogue.get_conversation(_conv)
	if not conv or conv.lines.is_empty():
		close_dialogue()
		return
	var text := conv.lines[_conv_line]
	var is_last_line := _conv_line >= conv.lines.size() - 1
	var options: Array = conv.options if is_last_line else []
	_ui.display(_dialogue.npc_name, text, options)

func _try_advance() -> void:
	var conv := _dialogue.get_conversation(_conv)
	if not conv:
		close_dialogue()
		return
	var is_last_line := _conv_line >= conv.lines.size() - 1
	if is_last_line and not conv.options.is_empty():
		return
	_conv_line += 1
	if _conv_line >= conv.lines.size():
		close_dialogue()
	else:
		_show_line()

func select_option(option_index: int) -> void:
	var conv := _dialogue.get_conversation(_conv)
	if not conv or option_index < 0 or option_index >= conv.options.size():
		return
	var option: DialogueOption = conv.options[option_index]
	if option.goto_id == &"":
		close_dialogue()
	else:
		_conv = option.goto_id
		_conv_line = 0
		_show_line()
	DialogueManager.option_selected.emit(player_index, option_index)

func close_dialogue() -> void:
	if _ui:
		_ui.hide()
	_dialogue = null
	_conv = &""
	_conv_line = 0
	is_in_dialogue = false
	_active_npc = null
	DialogueManager.dialogue_ended.emit(player_index)

func _on_paused() -> void:
	if is_in_dialogue and _ui:
		_ui.hide()

func _on_resumed() -> void:
	if not is_in_dialogue:
		return
	var ray_length := (raycast.target_position.length() if raycast else 3.0) + 1.0
	if _body and _active_npc and _body.global_position.distance_to(_active_npc.global_position) > ray_length:
		close_dialogue()
	else:
		_ui.show()
