extends Node

const PAUSE_MENU_SCENE = "res://ui/pause_menu/pause_menu.tscn"

var _pauseMenuInstance: Control = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("p0_pause"):
		print(_pauseMenuInstance)
		if _pauseMenuInstance:
			_resumeGame()
		else:
			_showPauseMenu()
		get_tree().root.set_input_as_handled()

func _showPauseMenu() -> void:
	_pauseMenuInstance = load(PAUSE_MENU_SCENE).instantiate()
	get_tree().root.add_child(_pauseMenuInstance)
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _resumeGame() -> void:
	if _pauseMenuInstance:
		_pauseMenuInstance.queue_free()
		_pauseMenuInstance = null
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
