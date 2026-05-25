extends Control

@onready var _debugLabel: RichTextLabel = $DebugLabel
@onready var _player: CharacterBody3D = $".."

func _process(delta: float) -> void:
	if _player == null:
		return

	var pos = _player.position
	var vel = _player.velocity
	var localVel = _player.global_transform.basis.inverse() * vel

	_debugLabel.text = "Pos: (X %.1f, Y %.1f, Z %.1f)\nVel: (X %.1f, Y %.1f, Z %.1f)" % [
		pos.x, pos.y, pos.z,
		localVel.x, localVel.y, -localVel.z + 0.0
	]
