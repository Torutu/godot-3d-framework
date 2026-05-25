# Autoloads (Global Systems) — Complete Guide

## SECTION 1: What Is This & Why Do You Need It?

### What It Does
An **autoload** (also called a singleton) is a script that Godot loads once when the game starts and keeps running forever — across levels, menus, and pauses. Every script in your entire game can talk to it directly by name.

### Real Example

```
Any script in the game can do this:
    ScoreManager.add_score(100)

And it always works, no matter:
  - Which level you're on
  - Whether the game is paused
  - Which script is calling it
```

Without autoloads, you would need to find and store references to shared objects yourself, which breaks when levels change or objects are freed.

### Existing Autoloads in This Project

| Name | File | What It Does |
|------|------|--------------|
| `PhysicsManager` | `core/physics/physicsManager.gd` | Manages gravity |
| `PauseManager` | `core/autoloads/pauseManager.gd` | ESC key, pause menu |
| `DialogueManager` | `core/autoloads/dialogueManager.gd` | E key, NPC conversations |

---

## SECTION 2: Complete Guide (0 to 100%)

### Part A: How Autoloads Work

When `project.godot` contains this:

```ini
[autoload]
ScoreManager="*res://core/autoloads/scoreManager.gd"
```

Godot will:
1. Load `scoreManager.gd` before any level or menu
2. Create it as a node at the root of the scene tree
3. Give it the name `ScoreManager`
4. Keep it alive forever, even when scenes change

Then any script anywhere in the game can call:
```gdscript
ScoreManager.add_score(100)
```

---

### Part B: Create Your First Autoload (testManager)

This example creates a simple manager that tracks a number.

#### Step 1: Create the Script

1. In the file browser, go to `core/autoloads/`
2. Right-click → "Create New" → "Script"
3. Name it: `testManager.gd`
4. Paste this code:

```gdscript
extends Node
class_name TestManager

var count: int = 0

signal count_changed(new_count: int)

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func increment() -> void:
	count += 1
	count_changed.emit(count)

func reset() -> void:
	count = 0
	count_changed.emit(0)

func get_count() -> int:
	return count
```

**What each part does:**

| Code | What It Does |
|------|-------------|
| `extends Node` | This is a plain node — no physics, no visuals |
| `class_name TestManager` | Optional, but good for clarity |
| `process_mode = PROCESS_MODE_ALWAYS` | Keeps running even when game is paused |
| `signal count_changed(new_count)` | Other scripts can listen for this event |

#### Step 2: Register in project.godot

1. Open `project.godot` in any text editor (or the Godot Project Settings UI)
2. Find the `[autoload]` section
3. Add this line:

```ini
[autoload]
TestManager="*res://core/autoloads/testManager.gd"
```

The `*` at the start means "this is a script, not a scene."

4. Save the file
5. Go back to Godot — it will re-import automatically

#### Step 3: Use It from Any Script

```gdscript
# From anywhere in the game:
TestManager.increment()
TestManager.increment()
print(TestManager.get_count())  # → 2

TestManager.reset()
print(TestManager.get_count())  # → 0
```

#### Step 4: Listen for Changes

Another script can react when the count changes:

```gdscript
func _ready() -> void:
	TestManager.count_changed.connect(_on_count_changed)

func _on_count_changed(new_count: int) -> void:
	print("Count is now: ", new_count)
```

---

### Part C: A More Complete Example (ScoreManager)

This is a full score manager you can use in a real game.

#### The Script

Create `core/autoloads/scoreManager.gd`:

```gdscript
extends Node

var score: int = 0
var high_score: int = 0

signal score_changed(new_score: int)
signal high_score_beaten(new_high: int)

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)
	
	if score > high_score:
		high_score = score
		high_score_beaten.emit(score)

func reset() -> void:
	score = 0
	score_changed.emit(0)

func get_score() -> int:
	return score

func get_high_score() -> int:
	return high_score
```

Register it:
```ini
[autoload]
ScoreManager="*res://core/autoloads/scoreManager.gd"
```

Use it:
```gdscript
# When player defeats enemy:
ScoreManager.add_score(100)

# From HUD script — update display whenever score changes:
func _ready() -> void:
	ScoreManager.score_changed.connect(_on_score_changed)

func _on_score_changed(new_score: int) -> void:
	$ScoreLabel.text = "Score: " + str(new_score)
```

---

### Part D: Important Rules

#### Load Order
Autoloads load in the order listed in `project.godot`. If one autoload needs another, list the dependency first:

```ini
[autoload]
ConfigManager="*res://core/autoloads/configManager.gd"   # loads first
GameManager="*res://core/autoloads/gameManager.gd"       # can use ConfigManager
```

#### process_mode
```gdscript
# Continues running when game is paused (ESC pressed):
process_mode = PROCESS_MODE_ALWAYS

# Pauses when game is paused (default):
process_mode = PROCESS_MODE_INHERIT
```

Almost all autoloads should use `PROCESS_MODE_ALWAYS`.

#### Don't Store Scene References Permanently
Level nodes get freed when changing scenes. Don't store references to them in autoloads across scene changes:

```gdscript
# BAD — _player becomes invalid after scene change
var _player: Node3D

func _ready() -> void:
	_player = get_tree().root.get_node("World/Player")

# GOOD — look it up each time you need it
func get_player() -> Node3D:
	return get_tree().root.get_node_or_null("World/Player")
```

---

## SECTION 3: Quick Reference

### Template

```gdscript
extends Node

signal something_happened

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func do_something() -> void:
	something_happened.emit()
```

### Register in project.godot

```ini
[autoload]
MyManager="*res://core/autoloads/myManager.gd"
```

### Call from Anywhere

```gdscript
MyManager.do_something()
MyManager.something_happened.connect(_on_something)
```

### Autoload Load Order (current)

```ini
[autoload]
PhysicsManager="*res://core/physics/physicsManager.gd"
PauseManager="*res://core/autoloads/pauseManager.gd"
DialogueManager="*res://core/autoloads/dialogueManager.gd"
```

Add new ones after `DialogueManager` unless they need to load before it.

---

## Troubleshooting

**"Identifier not found" error when calling MyManager:**
- Check spelling matches exactly (case-sensitive)
- Confirm it's registered in `project.godot`
- Confirm the script file exists at that path

**Autoload not receiving input:**
- Set `process_mode = PROCESS_MODE_ALWAYS` in `_ready()`

**Autoload exists but behaves wrong on scene change:**
- The autoload instance doesn't change — but scene nodes it referenced are freed
- Use `get_node_or_null()` every time instead of caching references

---

## See Also
- [01-dialogue.md](01-dialogue.md) — DialogueManager as an autoload example
- [07-ui.md](07-ui.md) — UIManager for UI-related globals
