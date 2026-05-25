# Skill/Ability System Guide

## Overview
A 5-slot ability bar positioned at the bottom-center of the screen. Displays equipped skills/abilities with numbered slots (1-5) for quick access.

---

## Files
- `skillUI.gd` — Script managing skill slots and display
- `skillUI.tscn` — UI scene (5 horizontal slots)

---

## How to Add Skills

### Method 1: Direct Access
```gdscript
# Get reference to skill UI
var skill_ui = get_tree().root.get_node("World/SkillUI")

# Set skill name in slot (0-4)
skill_ui.setSkillName(0, "Fireball")
skill_ui.setSkillName(1, "Heal")
skill_ui.setSkillName(2, "Shield")
skill_ui.setSkillName(3, "Dash")
skill_ui.setSkillName(4, "Summon")
```

### Method 2: Create a SkillManager Autoload
```gdscript
# res://core/autoloads/skillManager.gd
extends Node

var _skill_ui: Control
var _skills: Array[String] = ["", "", "", "", ""]

func _ready() -> void:
	_skill_ui = get_tree().root.get_node_or_null("World/SkillUI")
	process_mode = PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	# Detect number keys 1-5 for skill activation
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: activate_skill(0)
			KEY_2: activate_skill(1)
			KEY_3: activate_skill(2)
			KEY_4: activate_skill(3)
			KEY_5: activate_skill(4)

func equip_skill(slot: int, skill_name: String) -> void:
	if slot >= 0 and slot < 5:
		_skills[slot] = skill_name
		if _skill_ui:
			_skill_ui.setSkillName(slot, skill_name)

func activate_skill(slot: int) -> void:
	if _skills[slot] != "":
		print("Activating skill: ", _skills[slot])
		# TODO: Implement skill logic here

func get_skill(slot: int) -> String:
	return _skills[slot]
```

Then register in `project.godot`:
```ini
[autoload]
SkillManager="*res://core/autoloads/skillManager.gd"
```

---

## How to Edit Skills

### Change Slot Count
Edit `skillUI.tscn` → SkillPanel → HBoxContainer:
- Delete or add Slot nodes to change from 5 slots
- Update `skillUI.gd` arrays to match new size:

```gdscript
@onready var _slots: Array[PanelContainer] = [
	$SkillPanel/HBoxContainer/Slot1,
	$SkillPanel/HBoxContainer/Slot2,
	$SkillPanel/HBoxContainer/Slot3,
]  # Only 3 slots now
```

### Change Slot Size
Edit each Slot in `skillUI.tscn`:
```
SkillPanel/HBoxContainer/Slot1 → custom_minimum_size = Vector2(80, 80)  # Larger
```

### Change Position
Edit `skillUI.tscn` → SkillPanel (anchored bottom-center):
```
anchors_preset = 7  # Bottom center
offset_left = -256.0   # Move left/right (-256 centers 5×50px slots)
offset_top = -88.0     # Distance from bottom (align with inventory)
offset_right = 256.0
offset_bottom = -8.0
```

### Add Skill Icons
Replace text with icons (similar to inventory):

```gdscript
# skillUI.gd - Modify _ready()
func _ready() -> void:
	for i in range(5):
		var texture_rect = TextureRect.new()
		texture_rect.texture = load("res://assets/sprites/skills/skill_%d.png" % i)
		_slots[i].get_node("Label").queue_free()  # Remove text label
		_slots[i].add_child(texture_rect)
```

---

## Node Structure

```
World (Node3D)
├── ... other nodes
└── SkillUI (Control, bottom-center)
    └── SkillPanel (PanelContainer, dark bg, centered)
        └── HBoxContainer (horizontal, 5 slots)
            ├── Slot1 (PanelContainer, 50×50)
            │   └── Label (RichTextLabel, text "1")
            ├── Slot2 (PanelContainer, 50×50)
            │   └── Label (RichTextLabel, text "2")
            ... (Slot3-5 follow same pattern)
```

---

## How It Looks When Implemented

**Bottom-center:**
```
┌────┬────┬────┬────┬────┐
│ 1  │ 2  │ 3  │ 4  │ 5  │
├────┼────┼────┼────┼────┤
│Fire│Heal│Shd │Dash│Smn │
└────┴────┴────┴────┴────┘
```

Each slot displays skill abbreviation or icon. Press number keys (1-5) to activate.

---

## API Reference

### skillUI.gd

```gdscript
# Set skill name in slot (0-4)
func setSkillName(slotIndex: int, name: String) -> void

# Get skill name from slot
func getSkillName(slotIndex: int) -> String

# Example:
setSkillName(0, "Fireball")
var skill = getSkillName(0)  # Returns "Fireball"
```

---

## Complete Example: Equip Skill System

```gdscript
# res://core/skills/skillData.gd
class_name SkillData

var name: String
var description: String
var cooldown: float
var mana_cost: int

func _init(p_name: String, p_desc: String, p_cooldown: float, p_mana: int):
	name = p_name
	description = p_desc
	cooldown = p_cooldown
	mana_cost = p_mana

# res://core/autoloads/skillManager.gd
extends Node

var _skill_ui: Control
var _equipped_skills: Array[SkillData] = [null, null, null, null, null]
var _cooldowns: Array[float] = [0, 0, 0, 0, 0]

func _ready() -> void:
	_skill_ui = get_tree().root.get_node_or_null("World/SkillUI")
	process_mode = PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	# Reduce cooldowns
	for i in range(5):
		if _cooldowns[i] > 0:
			_cooldowns[i] -= delta

func equip_skill(slot: int, skill: SkillData) -> void:
	_equipped_skills[slot] = skill
	_skill_ui.setSkillName(slot, skill.name)

func activate_skill(slot: int) -> bool:
	if _equipped_skills[slot] == null:
		return false
	if _cooldowns[slot] > 0:
		print("Skill on cooldown for %.1f seconds" % _cooldowns[slot])
		return false
	
	var skill = _equipped_skills[slot]
	print("Using skill: ", skill.name)
	_cooldowns[slot] = skill.cooldown
	return true

func get_cooldown_remaining(slot: int) -> float:
	return max(0, _cooldowns[slot])
```

Then use in player input:
```gdscript
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("p0_attack"):
		SkillManager.activate_skill(0)  # Use first skill
```

---

## Skill Name Length Tips

Keep skill names short to fit in slots:
- "Fireball" ✓
- "Fire Strike" ✓
- "Summon Elemental Golem" ✗ (too long)

Use abbreviations if needed:
- "Fireball" → "Fire"
- "Heal" → "Heal"
- "Shield Spell" → "Shld"

---

## Troubleshooting

**Slots showing wrong numbers:**
- Check each Slot's Label text property (should be "1"-"5")

**Skills not displaying:**
- Ensure SkillUI is added to world scene
- Check setSkillName() is being called with correct slot index (0-4)

**Hotkeys not working:**
- Make sure SkillManager process_mode is PROCESS_MODE_ALWAYS
- Check input action names match (p0_attack, etc.)
