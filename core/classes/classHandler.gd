extends Node
class_name ClassHandler

const SLOT_COUNT: int = 5

@export_file("*.gd") var class_path: String = ""

signal skill_used(skill: SkillData)
signal attack_executed(attack: AttackData)
signal class_loaded
signal slot_changed(slot_index: int)

var character_class: CharacterClass
var loadout: Array[int] = [-1, -1, -1, -1, -1]  # slot → skill index, -1 = empty

var _body: CharacterBody3D
var _cooldowns: Dictionary = {}
var _attack_cooldown: float = 0.0

func _ready() -> void:
	_body = get_parent() as CharacterBody3D
	if class_path != "":
		character_class = load(class_path).new()
	if character_class:
		_apply_class()
		_fill_default_loadout()
		class_loaded.emit()

func _process(delta: float) -> void:
	_attack_cooldown = max(0.0, _attack_cooldown - delta)
	for id in _cooldowns:
		_cooldowns[id] = max(0.0, _cooldowns[id] - delta)

func _apply_class() -> void:
	_body.move_speed = character_class.move_speed
	_body.jump_force = character_class.jump_force

func _fill_default_loadout() -> void:
	loadout = [-1, -1, -1, -1, -1]
	for i in min(character_class.skills.size(), SLOT_COUNT):
		loadout[i] = i

# Assign a skill (by its index in character_class.skills) to a slot.
# Pass -1 to clear the slot.
func assign_skill(slot_index: int, skill_index: int) -> void:
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		return
	loadout[slot_index] = skill_index
	slot_changed.emit(slot_index)

func use_skill(slot_index: int) -> void:
	var skill := get_skill(slot_index)
	if not skill:
		return
	if _cooldowns.get(skill.skill_id, 0.0) > 0.0:
		DebugManager.log("[ClassHandler] %s on cooldown: %.1fs" % [skill.display_name, _cooldowns[skill.skill_id]])
		return
	_cooldowns[skill.skill_id] = skill.cooldown
	skill_used.emit(skill)
	DebugManager.log("[ClassHandler] used skill: %s" % skill.display_name)

func use_primary_attack() -> void:
	if not character_class or not character_class.primary_attack:
		return
	if _attack_cooldown > 0.0:
		return
	_attack_cooldown = 1.0 / character_class.primary_attack.speed
	attack_executed.emit(character_class.primary_attack)
	DebugManager.log("[ClassHandler] attack executed")

func get_skill(slot_index: int) -> SkillData:
	if not character_class or slot_index < 0 or slot_index >= SLOT_COUNT:
		return null
	var skill_index := loadout[slot_index]
	if skill_index < 0 or skill_index >= character_class.skills.size():
		return null
	return character_class.skills[skill_index]

func get_cooldown(slot_index: int) -> float:
	var skill := get_skill(slot_index)
	if not skill:
		return 0.0
	return _cooldowns.get(skill.skill_id, 0.0)

func get_skill_count() -> int:
	return character_class.skills.size() if character_class else 0
