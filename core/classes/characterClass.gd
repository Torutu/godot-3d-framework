extends Resource
class_name CharacterClass

@export var display_name: String = "Class"
@export var max_health: float = 100.0
@export var move_speed: float = 5.0
@export var jump_force: float = 12.0
@export var skills: Array[SkillData] = []
@export var primary_attack: AttackData
