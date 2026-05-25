extends Control

@onready var _newGameButton: Button = $PanelContainer/VBoxContainer/NewGameButton
@onready var _continueButton: Button = $PanelContainer/VBoxContainer/ContinueButton
@onready var _settingsButton: Button = $PanelContainer/VBoxContainer/SettingsButton
@onready var _quitButton: Button = $PanelContainer/VBoxContainer/QuitButton

func _ready() -> void:
	get_tree().paused = false

	_newGameButton.pressed.connect(_onNewGame)
	_continueButton.pressed.connect(_onContinue)
	_settingsButton.pressed.connect(_onSettings)
	_quitButton.pressed.connect(_onQuit)

func _onNewGame() -> void:
	get_tree().change_scene_to_file("res://levels/test/world.tscn")

func _onContinue() -> void:
	print("Continue game (not implemented)")

func _onSettings() -> void:
	print("Settings (not implemented)")

func _onQuit() -> void:
	get_tree().quit()
