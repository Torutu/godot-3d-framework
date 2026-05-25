extends Node

var enabled: bool = false

func _ready() -> void:
	if not OS.is_debug_build():
		process_mode = PROCESS_MODE_DISABLED

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F3:
			enabled = not enabled
			print("[Debug] %s" % ("ON" if enabled else "OFF"))

func log(message: String) -> void:
	if enabled:
		print(message)
