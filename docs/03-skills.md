# Skill Bar System — Complete Guide

## SECTION 1: What Is This & Why Do You Need It?

### What It Does
The **skill bar** is a row of 5 slots shown at the bottom-center of the screen. Each slot can hold an ability name. The player can equip abilities to these slots and see them at a glance.

### Real Example

```
Player has "testSkillA" equipped in slot 0 and "testSkillB" in slot 1.

Bottom center of screen:
┌────┬────┬────┬────┬────┐
│ 1  │ 2  │ 3  │ 4  │ 5  │   ← Slot numbers shown
├────┼────┼────┼────┼────┤
│SkA │SkB │    │    │    │   ← Ability names shown
└────┴────┴────┴────┴────┘

Player presses key 1 → "testSkillA" is used
Player presses key 2 → "testSkillB" is used
```

### Why This Exists
Without this system, you'd have to:
1. Build the visual slot layout from scratch
2. Track which ability is in which slot
3. Handle keyboard input for each slot separately
4. Update the display when abilities change

**With this system:** You call one function to put an ability in a slot, and one function to use it.

---

## SECTION 2: Complete Guide (0 to 100%)

### Part A: Understanding the Files

Two files make the skill bar work:

1. **`ui/skill/skillUI.gd`**
   - Controls the skill bar panel
   - Has two functions: `setSkillName()` and `getSkillName()`
   - You call these from other scripts

2. **`ui/skill/skillUI.tscn`**
   - The visual scene (the 5 slots you see at the bottom)
   - Already placed inside `levels/test/world.tscn`
   - You don't need to create this — it already exists

---

### Part B: How to Put a Skill in a Slot

This is the only thing you need to know to use the skill bar.

#### From any script:

```gdscript
# Get the skill bar
var skills = get_tree().root.get_node("World/SkillUI")

# Put "testSkillA" in slot 0 (first slot)
skills.setSkillName(0, "testSkillA")

# Put "testSkillB" in slot 1 (second slot)
skills.setSkillName(1, "testSkillB")

# Remove skill from slot 0
skills.setSkillName(0, "")
```

**Slot numbers (0 to 4):**
```
┌───┬───┬───┬───┬───┐
│ 0 │ 1 │ 2 │ 3 │ 4 │
└───┴───┴───┴───┴───┘
```

---

### Part C: Make Skills Actually Do Something

The skill bar only handles display. To make pressing a key execute an ability, you need a SkillManager.

#### Step 1: Create the SkillManager Script

1. In the file browser, go to `core/autoloads/`
2. Right-click → "Create New" → "Script"
3. Name it: `skillManager.gd`
4. Paste this code:

```gdscript
extends Node

var _skills: Array[String] = ["", "", "", "", ""]
var _ui: Control

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		_ui = get_tree().root.get_node_or_null("World/SkillUI")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: use_skill(0)
			KEY_2: use_skill(1)
			KEY_3: use_skill(2)
			KEY_4: use_skill(3)
			KEY_5: use_skill(4)

func equip_skill(slot: int, skill_name: String) -> void:
	if slot >= 0 and slot < 5:
		_skills[slot] = skill_name
		if _ui:
			_ui.setSkillName(slot, skill_name)

func use_skill(slot: int) -> void:
	if slot >= 0 and slot < 5 and _skills[slot] != "":
		print("Used skill: ", _skills[slot])
		# Add your skill logic here

func get_skill(slot: int) -> String:
	return _skills[slot]
```

**What each part does:**

| Code | What It Does |
|------|-------------|
| `process_mode = PROCESS_MODE_ALWAYS` | Keeps listening for keys even when game is paused |
| `_input(event)` | Runs every time a key is pressed |
| `equip_skill(0, "testSkillA")` | Puts "testSkillA" in slot 0 and updates the display |
| `use_skill(0)` | Executes whatever is in slot 0 |

#### Step 2: Register SkillManager in project.godot

1. Open `project.godot` in any text editor
2. Find the `[autoload]` section
3. Add this line:

```ini
[autoload]
SkillManager="*res://core/autoloads/skillManager.gd"
```

Save the file and reopen Godot.

#### Step 3: Equip Skills at Game Start

In your level script or player script:

```gdscript
func _ready() -> void:
	SkillManager.equip_skill(0, "testSkillA")
	SkillManager.equip_skill(1, "testSkillB")
	SkillManager.equip_skill(2, "testSkillC")
```

Now when the player presses **1**, it runs `use_skill(0)` which prints "Used skill: testSkillA".

---

### Part D: Add Real Skill Logic

The `use_skill()` function is where you put what actually happens. Replace the `print()` with real effects:

```gdscript
func use_skill(slot: int) -> void:
	if slot >= 0 and slot < 5 and _skills[slot] != "":
		var skill_name = _skills[slot]
		
		match skill_name:
			"testSkillA":
				_do_skill_a()
			"testSkillB":
				_do_skill_b()

func _do_skill_a() -> void:
	print("Skill A activated!")
	# Your effect code here

func _do_skill_b() -> void:
	print("Skill B activated!")
	# Your effect code here
```

---

### Part E: Add a Cooldown (Optional)

To prevent spamming skills too fast:

```gdscript
extends Node

var _skills: Array[String] = ["", "", "", "", ""]
var _cooldowns: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]
var _cooldown_duration: float = 2.0
var _ui: Control

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	for i in range(5):
		if _cooldowns[i] > 0:
			_cooldowns[i] -= delta

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: use_skill(0)
			KEY_2: use_skill(1)
			KEY_3: use_skill(2)
			KEY_4: use_skill(3)
			KEY_5: use_skill(4)

func equip_skill(slot: int, skill_name: String) -> void:
	if slot >= 0 and slot < 5:
		_skills[slot] = skill_name
		if _ui:
			_ui.setSkillName(slot, skill_name)

func use_skill(slot: int) -> void:
	if slot < 0 or slot >= 5:
		return
	if _skills[slot] == "":
		return
	if _cooldowns[slot] > 0:
		print("Skill on cooldown: ", _cooldowns[slot], "s remaining")
		return
	
	print("Used skill: ", _skills[slot])
	_cooldowns[slot] = _cooldown_duration
```

---

### Part F: Test It

1. Press **Play**
2. Press **1** — you should see "Used skill: testSkillA" in the output console
3. Look at the bottom of the screen — the skill bar should show the skill name in slot 0

**Nothing happened? Check:**
- Is `SkillManager` registered in `project.godot`?
- Did you call `SkillManager.equip_skill(0, "testSkillA")` somewhere?
- Is `SkillUI` visible in `world.tscn`?

---

## SECTION 3: Quick Reference

### The Two Functions

```gdscript
# Put a skill in a slot (0-4)
skillUI.setSkillName(slot: int, name: String) -> void

# Read what skill is in a slot
skillUI.getSkillName(slot: int) -> String
```

### Equip and Use

```gdscript
# Equip (updates both internal state and display)
SkillManager.equip_skill(0, "testSkillA")

# Use (execute the skill in a slot)
SkillManager.use_skill(0)

# Read
SkillManager.get_skill(0)  # → "testSkillA"
```

### Slot Numbers

```
┌───┬───┬───┬───┬───┐
│ 0 │ 1 │ 2 │ 3 │ 4 │
└───┴───┴───┴───┴───┘
Keys: 1   2   3   4   5
```

---

## See Also
- [07-ui.md](07-ui.md) — How UI works in general
- [06-autoloads.md](06-autoloads.md) — Creating global managers
