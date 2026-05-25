extends CharacterBody3D

const MOVE_SPEED = 5.0
const MOUSE_SENSITIVITY = 0.003
const JUMP_FORCE = 12.0
const GRAVITY = 20.0

@onready var _camera: Camera3D = $Camera3D
@onready var _dialogue_session: DialogueSession = $DialogueSession

var _pitch := 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	if _dialogue_session and _dialogue_session.is_in_dialogue:
		velocity.x = 0
		velocity.z = 0
		velocity.y -= GRAVITY * delta
		move_and_slide()
		return

	var moveDir := _getMovementDirection().normalized()
	velocity.x = moveDir.x * MOVE_SPEED
	velocity.z = moveDir.z * MOVE_SPEED

	if Input.is_action_just_pressed("p0_roll") and is_on_floor():
		velocity.y = JUMP_FORCE

	velocity.y -= GRAVITY * delta

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_rotate(event.relative)

func _rotate(mouseDelta: Vector2) -> void:
	rotate_y(-mouseDelta.x * MOUSE_SENSITIVITY)

	_pitch -= mouseDelta.y * MOUSE_SENSITIVITY
	_pitch = clamp(_pitch, -PI / 2, PI / 2)
	_camera.rotation.x = _pitch

func _getMovementDirection() -> Vector3:
	var direction := Vector3.ZERO
	if Input.is_action_pressed("p0_move_forward"):
		direction -= global_transform.basis.z
	if Input.is_action_pressed("p0_move_back"):
		direction += global_transform.basis.z
	if Input.is_action_pressed("p0_move_left"):
		direction -= global_transform.basis.x
	if Input.is_action_pressed("p0_move_right"):
		direction += global_transform.basis.x
	return direction
