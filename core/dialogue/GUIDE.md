# Dialogue System Guide

## Overview
A modular dialogue system that can be attached to any entity. Supports branching dialogue, RichText formatting, and proximity-based interaction.

---

## Files
- `dialogueResource.gd` — Data structure for dialogue (lines, options, branching)
- Related autoload: `core/autoloads/dialogueManager.gd`
- Related UI: `ui/dialogue/dialogueUI.tscn`

---

## How to Add Dialogue to an Entity

### Step 1: Create Dialogue Data
Create a new script in `res://assets/dialogue/` extending `DialogueResource`:

```gdscript
# res://assets/dialogue/my_npc.gd
extends DialogueResource

func _init() -> void:
	super()
	npc_name = "Merchant"
	dialogue_title = "Trading"
	
	add_line("Merchant", "Welcome! What brings you here?")
	add_line("Merchant", "Excellent choice! You won't regret it.")
	add_line("Merchant", "Perhaps next time then.")
	
	add_option_to_line(0, "I want to trade", 1)
	add_option_to_line(0, "Just passing by", 2)
```

**Line format:**
```gdscript
add_line(speaker: String, text: String, sound_path: String = "", animation_trigger: String = "")
```

**Option format:**
```gdscript
add_option_to_line(from_line_index: int, option_text: String, next_line_index: int)
```

### Step 2: Attach Interactable Script to Entity
Add `entities/shared/interactable.gd` to your entity:

```gdscript
# In your entity's _ready() function:
func _ready() -> void:
	var interactable = Interactable.new()
	interactable.dialogue_resource = load("res://assets/dialogue/my_npc.gd").new()
	add_child(interactable)
```

Or manually in the editor:
1. Select entity root node
2. Attach script: `res://entities/shared/interactable.gd`
3. In `_ready()`, set the dialogue_resource

### Step 3: Add InteractionArea to Player (One-time)
In `entities/player/player.tscn`, add child to `CharacterBody3D`:

```
CharacterBody3D
├── Camera3D
├── CollisionShape3D
├── MeshInstance3D
└── InteractionArea (Area3D)  ← Add this
    └── CollisionShape3D (SphereShape3D, radius: 5.0)
```

---

## How to Edit Dialogue

### Change Dialogue Text
```gdscript
func _init() -> void:
	super()
	npc_name = "Updated Name"
	dialogue_lines.clear()
	add_line("Updated Name", "New dialogue text")
```

### Add More Lines
```gdscript
add_line("Speaker", "Line 3 text")
add_line("Speaker", "Line 4 text")
```

### Modify Branch Logic
```gdscript
# Line 0 has two options
add_option_to_line(0, "Yes option", 1)
add_option_to_line(0, "No option", 3)

# Line 1 and 3 are different branches
add_line("Speaker", "You chose yes")
add_line("Speaker", "You chose no")
```

### Use RichText Formatting
Text supports Godot RichTextLabel tags:

```gdscript
add_line("Speaker", "This is [b]bold[/b] and [color=red]red[/color]")
add_line("Speaker", "This is [i]italic[/i] and [u]underlined[/u]")
```

---

## Node Structure When Implemented

```
World
├── Player
│   └── CharacterBody3D
│       ├── Camera3D
│       ├── CollisionShape3D
│       └── InteractionArea (Area3D)
│           └── CollisionShape3D
│
└── MyNPC (Node3D or StaticBody3D)
    ├── Interactable (script)
    ├── MeshInstance3D / Model
    ├── CollisionShape3D
    └── InteractionArea (created by Interactable.gd)
        └── CollisionShape3D (SphereShape3D)
```

---

## How It Looks When Implemented

1. **Player approaches NPC** — walks within 5 units
2. **Player presses E** — DialogueUI appears at top of screen:
   ```
   ┌─────────────────────────────────────┐
   │ Merchant                            │
   │                                     │
   │ Welcome! What brings you here?      │
   │                                     │
   │ [I want to trade]                   │
   │ [Just passing by]                   │
   └─────────────────────────────────────┘
   ```
3. **Player selects option** — E key or clicks button
4. **Next line appears** — dialogue progresses
5. **Player walks away** — dialogue auto-closes
6. **No more options** — press E to close dialogue

---

## Example: Complete NPC Setup

```gdscript
# res://assets/dialogue/guard.gd
extends DialogueResource

func _init() -> void:
	super()
	npc_name = "Guard"
	dialogue_title = "Gate Guard"
	
	# Line 0: Welcome
	add_line("Guard", "Halt! State your business.")
	
	# Line 1: Path A - Friendly
	add_line("Guard", "Excellent! Welcome to the city.")
	add_line("Guard", "Stay safe out there.")
	
	# Line 2: Path B - Suspicious
	add_line("Guard", "Hmm, I don't recognize you...")
	add_line("Guard", "You'll have to convince me.")
	
	# Options for line 0
	add_option_to_line(0, "I'm just passing through", 1)
	add_option_to_line(0, "[color=red]I'm here to cause trouble[/color]", 2)
```

Then attach to a Guard entity:
```gdscript
# guard.gd (attached to Guard node)
extends Node3D

func _ready() -> void:
	var interactable = Interactable.new()
	interactable.dialogue_resource = load("res://assets/dialogue/guard.gd").new()
	add_child(interactable)
```

---

## Parameters Reference

| Parameter | Type | Example | Notes |
|-----------|------|---------|-------|
| `npc_name` | String | "Merchant" | Displayed as speaker in UI |
| `dialogue_title` | String | "Trading" | Internal identifier |
| `speaker` | String | "NPC Name" | Per-line speaker name |
| `text` | String | "Hello [b]there[/b]" | Supports RichText tags |
| `sound_path` | String | "res://assets/audio/sfx/greeting.ogg" | Optional, for future use |
| `animation_trigger` | String | "speak_friendly" | Optional, for animations |

---

## Troubleshooting

**No dialogue appears when pressing E:**
- Check Player has InteractionArea child in CharacterBody3D
- Check entity has Interactable script attached
- Check dialogue_resource is assigned and not null

**Dialogue text is blank:**
- Check dialogue_lines array is populated
- Check add_line() is being called in _init()

**Options don't appear:**
- Check add_option_to_line() is called after add_line()
- Check line index is correct (0-indexed)
