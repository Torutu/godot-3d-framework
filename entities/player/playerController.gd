extends CharacterBody3D

const MOUSE_SENSITIVITY = 0.003
const GRAVITY = 20.0
const PUSH_FORCE = 8.0

var move_speed: float = 5.0
var jump_force: float = 12.0

@onready var _camera: Camera3D = $Camera3D
@onready var _dialogue_session: DialogueSession = $DialogueSession
@onready var _class_handler: ClassHandler = $ClassHandler
@onready var _inventory_ui: Control = $InventoryUI
@onready var _anim_tree: AnimationTree = $AnimationTree
var _anim_player: AnimationPlayer
var _pitch := 0.0
var _jump_requested := false
var _mouse_x := 0.0
var _attack_held := false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	PauseManager.enable_pausing()
	if _anim_tree:
		_anim_player = _anim_tree.get_node_or_null(_anim_tree.anim_player) as AnimationPlayer
		_anim_tree.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
		if _anim_player:
			_anim_player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS

func _physics_process(delta: float) -> void:
	rotate_y(-_mouse_x * MOUSE_SENSITIVITY)
	_mouse_x = 0.0

	if _dialogue_session and _dialogue_session.is_in_dialogue:
		velocity.x = 0
		velocity.z = 0
		velocity.y -= GRAVITY * delta
		move_and_slide()
		return

	var move_dir := _getMovementDirection().normalized()
	velocity.x = move_dir.x * move_speed
	velocity.z = move_dir.z * move_speed

	if _jump_requested and is_on_floor():
		velocity.y = jump_force
	_jump_requested = false

	velocity.y -= GRAVITY * delta

	var pre_slide_velocity := velocity
	move_and_slide()
	_push_rigid_bodies(pre_slide_velocity)

	if _attack_held and not _anim_tree.get("parameters/OneShot/active"):
		_fire_swing()

func _push_rigid_bodies(intended_velocity: Vector3) -> void:
	if Vector2(intended_velocity.x, intended_velocity.z).length() < 0.1:
		return
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var body := col.get_collider()
		if body is RigidBody3D:
			var push_dir := -col.get_normal()
			body.apply_central_force(push_dir * PUSH_FORCE)
			DebugManager.log("[Push] body=%s force_dir=%s body_vel=%s" % [
				body.name, push_dir, body.linear_velocity
			])

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_x += event.relative.x
		_pitch -= event.relative.y * MOUSE_SENSITIVITY
		_pitch = clamp(_pitch, -PI / 2, PI / 2)
		_camera.rotation.x = _pitch
		return

	if event.is_action_pressed("p0_roll"):
		_jump_requested = true
		return

	if event.is_action_pressed("p0_attack"):
		_attack_held = true
		if not _anim_tree.get("parameters/OneShot/active"):
			_fire_swing()
		return

	if event.is_action_released("p0_attack"):
		_attack_held = false
		return

	for i in 5:
		if event.is_action_pressed("p0_skill_%d" % (i + 1), false, true):
			_class_handler.use_skill(i)
			return

	for i in 9:
		if event.is_action_pressed("p0_inv_%d" % (i + 1), false, true):
			_on_inventory_slot(i)
			return

func _fire_swing() -> void:
	_anim_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _on_inventory_slot(slot_index: int) -> void:
	DebugManager.log("[Player] inventory slot %d" % slot_index)
	if _inventory_ui:
		_inventory_ui.highlight_slot(slot_index)

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
