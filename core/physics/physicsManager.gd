extends Node

var _bodies: Array[Node3D] = []

func registerBody(body: Node3D) -> void:
	if body not in _bodies:
		_bodies.append(body)

func unregisterBody(body: Node3D) -> void:
	_bodies.erase(body)
