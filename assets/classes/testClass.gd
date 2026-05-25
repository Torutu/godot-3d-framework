extends CharacterClass

func _init() -> void:
	display_name = "TestClass"
	max_health = 100.0
	move_speed = 5.0
	jump_force = 12.0

	var skill_1 := SkillData.new()
	skill_1.skill_id = &"test_skill_1"
	skill_1.display_name = "Skill One"
	skill_1.description = "First test skill."
	skill_1.cooldown = 3.0
	skill_1.range = 5.0

	var skill_2 := SkillData.new()
	skill_2.skill_id = &"test_skill_2"
	skill_2.display_name = "Skill Two"
	skill_2.description = "Second test skill."
	skill_2.cooldown = 5.0
	skill_2.range = 8.0

	var skill_3 := SkillData.new()
	skill_3.skill_id = &"test_skill_3"
	skill_3.display_name = "Skill Three"
	skill_3.description = "Third test skill."
	skill_3.cooldown = 8.0
	skill_3.range = 10.0

	var skill_4 := SkillData.new()
	skill_4.skill_id = &"test_skill_4"
	skill_4.display_name = "Skill Four"
	skill_4.description = "Fourth test skill."
	skill_4.cooldown = 12.0
	skill_4.range = 6.0

	var skill_5 := SkillData.new()
	skill_5.skill_id = &"test_skill_5"
	skill_5.display_name = "Skill Five"
	skill_5.description = "Fifth test skill."
	skill_5.cooldown = 15.0
	skill_5.range = 15.0

	skills = [skill_1, skill_2, skill_3, skill_4, skill_5]

	primary_attack = AttackData.new()
	primary_attack.damage = 10.0
	primary_attack.range = 2.0
	primary_attack.speed = 1.0
