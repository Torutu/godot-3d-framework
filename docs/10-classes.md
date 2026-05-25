# Classes System — Complete Guide

## SECTION 1: What Is This & Why Do You Need It?

### What It Does
The **class system** lets you define character archetypes — each with their own stats, skills, and attack profile. Assign a class to the player and their speed, health, jump, and abilities all update automatically.

### Real Example

```
Player is assigned Warrior class:
  → move_speed = 4.5 (slower, tankier)
  → max_health = 150
  → Skills: Shield Bash, War Cry, Whirlwind, Charge
  → Primary attack: 15 damage, melee range, 1.2 attacks/sec

Player switches to Rogue:
  → move_speed = 6.5 (fast)
  → max_health = 100
  → Skills: Stealth, Backstab, Smoke Bomb, Dash
  → Primary attack: 8 damage, fast (2.2 attacks/sec)
```

### Why This Exists
- One place to define all stats for a class — change a number once, affects everything
- New class = one new file, zero changes to any existing code
- Skills are data — no code required to define them, only to implement their effects
- Cooldowns tracked automatically per-player

---

## SECTION 2: Complete Guide (0 to 100%)

### Part A: Understanding the Files

| File | What It Does |
|------|-------------|
| `core/classes/characterClass.gd` | Base resource — defines all stats and skills a class can have |
| `core/classes/skillData.gd` | One skill's data (id, cooldown, range, cost) |
| `core/classes/attackData.gd` | Primary attack data (damage, range, speed) |
| `core/classes/classHandler.gd` | Node on the player — applies the class and tracks cooldowns |
| `assets/classes/*.gd` | The actual class definitions (warrior, mage, rogue, ranger) |

---

### Part B: Assign a Class to the Player

1. Open `entities/player/player.tscn` in Godot
2. Select `CharacterBody3D/ClassHandler` in the scene tree
3. In the **Inspector**, find **Character Class**
4. Click the field → **Load** → navigate to `assets/classes/`
5. Select `warrior.gd`, `mage.gd`, `rogue.gd`, or `ranger.gd`

The class is now active. When the game runs, `ClassHandler._ready()` calls `_apply_class()` which sets `move_speed` and `jump_force` on the player controller.

---

### Part C: Create a New Class

1. Create a new file in `assets/classes/` — e.g. `paladin.gd`
2. Use this template:

```gdscript
extends CharacterClass

func _init() -> void:
	display_name = "Paladin"
	max_health = 130.0
	move_speed = 4.8
	jump_force = 11.0

	var holy_strike := SkillData.new()
	holy_strike.skill_id = &"holy_strike"
	holy_strike.display_name = "Holy Strike"
	holy_strike.description = "A strike infused with holy light."
	holy_strike.cooldown = 5.0
	holy_strike.range = 2.5

	var divine_shield := SkillData.new()
	divine_shield.skill_id = &"divine_shield"
	divine_shield.display_name = "Divine Shield"
	divine_shield.description = "Become invulnerable briefly."
	divine_shield.cooldown = 20.0
	divine_shield.range = 0.0

	skills = [holy_strike, divine_shield]

	primary_attack = AttackData.new()
	primary_attack.damage = 12.0
	primary_attack.range = 2.0
	primary_attack.speed = 1.0
```

3. Assign it in the Inspector as shown in Part B.

---

### Part D: Add Skills to a Class

Each class holds up to any number of skills. Skills are plain data — no code needed to define them, only to implement their effects later.

```gdscript
var my_skill := SkillData.new()
my_skill.skill_id = &"my_skill"       # unique ID used for cooldown tracking
my_skill.display_name = "My Skill"
my_skill.description = "Does something."
my_skill.cooldown = 8.0               # seconds before it can be used again
my_skill.range = 10.0                 # how far it reaches (used by the effect)
my_skill.cost = 25.0                  # mana/stamina cost (your system decides what this means)

skills = [my_skill]
```

**skill_id must be unique across all skills** — it's the key used to track cooldowns.

---

### Part E: Trigger Skills and Attacks from Input

`ClassHandler` exposes two methods. Call them from wherever handles input (player controller, input manager):

```gdscript
# Trigger skill by slot index (0 = first skill, 1 = second, etc.)
_class_handler.use_skill(0)

# Trigger primary attack
_class_handler.use_primary_attack()
```

`ClassHandler` enforces cooldowns automatically — calling `use_skill()` while on cooldown does nothing.

---

### Part F: React to Skills and Attacks (Wire Up Effects)

Skills and attacks emit signals. Connect to them to implement the actual effect:

```gdscript
# In whatever system handles combat:
_class_handler.skill_used.connect(_on_skill_used)
_class_handler.attack_executed.connect(_on_attack_executed)

func _on_skill_used(skill: SkillData) -> void:
	match skill.skill_id:
		&"fireball":
			_launch_fireball(skill.range)
		&"blink":
			_teleport_forward(skill.range)

func _on_attack_executed(attack: AttackData) -> void:
	_deal_damage_in_range(attack.damage, attack.range)
```

This keeps the class data completely separate from the effect logic.

---

### Part G: Read Cooldown State (for UI)

```gdscript
# Get remaining cooldown for skill at index 0
var cd: float = _class_handler.get_cooldown(0)

# Get the SkillData at index 1
var skill: SkillData = _class_handler.get_skill(1)

# How many skills does this class have?
var count: int = _class_handler.get_skill_count()
```

---

## SECTION 3: Quick Reference

### The 4 Built-in Classes

| Class | HP | Speed | Attack Speed | Style |
|-------|----|-------|--------------|-------|
| Warrior | 150 | 4.5 | 1.2/sec | Melee tank |
| Mage | 80 | 5.0 | 0.8/sec | Ranged caster |
| Rogue | 100 | 6.5 | 2.2/sec | Fast melee |
| Ranger | 110 | 5.5 | 1.5/sec | Ranged physical |

### CharacterClass Properties

| Property | Type | What It Controls |
|----------|------|-----------------|
| `display_name` | String | Name shown in UI |
| `max_health` | float | Starting max health |
| `move_speed` | float | Applied to player controller |
| `jump_force` | float | Applied to player controller |
| `skills` | Array[SkillData] | All skills this class has |
| `primary_attack` | AttackData | The basic attack |

### SkillData Properties

| Property | Type | What It Controls |
|----------|------|-----------------|
| `skill_id` | StringName | Unique ID for cooldown tracking |
| `display_name` | String | Label in skill bar |
| `description` | String | Tooltip text |
| `cooldown` | float | Seconds between uses |
| `range` | float | Passed to effect handler |
| `cost` | float | Mana/stamina cost |

### AttackData Properties

| Property | Type | What It Controls |
|----------|------|-----------------|
| `damage` | float | Passed to damage handler |
| `range` | float | Passed to hit detection |
| `speed` | float | Attacks per second |

### New Class Checklist

| Step | Done |
|------|------|
| Created `.gd` file in `assets/classes/` | ✅ / ❌ |
| Extends `CharacterClass` | ✅ / ❌ |
| `_init()` sets all stats | ✅ / ❌ |
| Each skill has a unique `skill_id` | ✅ / ❌ |
| `primary_attack` is assigned | ✅ / ❌ |
| Assigned in Inspector → ClassHandler | ✅ / ❌ |
