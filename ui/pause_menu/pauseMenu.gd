extends Control

@onready var _resumeBtn: Button = $VBox/ResumeBtn
@onready var _saveBtn: Button = $VBox/SaveBtn
@onready var _settingsBtn: Button = $VBox/SettingsBtn
@onready var _quitBtn: Button = $VBox/QuitBtn
@onready var _testBtn: Button = $VBox/TestBtn

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	print("PauseMenu: Resume button = ", _resumeBtn)
	print("PauseMenu: Save button = ", _saveBtn)
	print("PauseMenu: Settings button = ", _settingsBtn)
	print("PauseMenu: Quit button = ", _quitBtn)
	print("PauseMenu: Test button = ", _testBtn)

	_resumeBtn.pressed.connect(_onResume)
	_saveBtn.pressed.connect(_onSave)
	_settingsBtn.pressed.connect(_onSettings)
	_quitBtn.pressed.connect(_onQuit)
	_testBtn.pressed.connect(_onTest)

	_resumeBtn.grab_focus()

func _onResume() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_free()

func _onSave() -> void:
	print("Save game (not implemented)")

func _onSettings() -> void:
	print("Settings (not implemented)")

func _onQuit() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://core/main_menu/mainMenu.tscn")
	
func _onTest() -> void:
	print("TEST BUTTON")
