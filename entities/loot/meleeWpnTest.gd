extends Node3D

const HIT_IMPULSE := 8.0

@onready var _area: Area3D = $Area3D

func _ready() -> void:
	_area.monitoring = false
	_area.body_entered.connect(_on_body_entered)

func activate() -> void:
	_area.monitoring = true

func deactivate() -> void:
	_area.monitoring = false

func _on_body_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		var dir := (body.global_position - global_position).normalized()
		body.apply_central_impulse(dir * HIT_IMPULSE)
		DebugManager.log("[MeleeWep] hit %s" % body.name)
