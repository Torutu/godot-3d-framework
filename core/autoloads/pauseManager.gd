extends Node

const PAUSE_MENU_SCENE = "res://ui/pause_menu/pause_menu.tscn"

var _pauseMenuInstance: Control = null
var _pausing_enabled: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func enable_pausing() -> void:
	_pausing_enabled = true

func disable_pausing() -> void:
	_pausing_enabled = false

func _input(event: InputEvent) -> void:
	if not _pausing_enabled:
		return
	if event.is_action_pressed("p0_pause"):
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

func quit_to_main_menu() -> void:
	if _pauseMenuInstance:
		_pauseMenuInstance.queue_free()
		_pauseMenuInstance = null
	_pausing_enabled = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://core/main_menu/mainMenu.tscn")
