extends Control

@onready var _resumeBtn: Button = $VBox/ResumeBtn
@onready var _saveBtn: Button = $VBox/SaveBtn
@onready var _settingsBtn: Button = $VBox/SettingsBtn
@onready var _quitBtn: Button = $VBox/QuitBtn
@onready var _testBtn: Button = $VBox/TestBtn

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

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
	DebugManager.log("Save game (not implemented)")

func _onSettings() -> void:
	DebugManager.log("Settings (not implemented)")

func _onQuit() -> void:
	PauseManager.quit_to_main_menu()

func _onTest() -> void:
	DebugManager.log("TEST BUTTON")
