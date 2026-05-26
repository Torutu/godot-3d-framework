# Dialogue System — Complete Guide

## SECTION 1: What Is This?

The dialogue system lets any entity talk to the player. Walk near it, press E, a conversation box appears. Options branch to more dialogue. Walk away and it closes.

**Partial-inspector design**: the NPC holds a `DialogueResource` (Inspector) that lists conversation `.gd` files. Each `.gd` file is a struct — it defines its own lines and options in code.

```
Player walks near NPC, presses E

NPC: "Hello there. What do you want?"

  → [Tell me more]   goto_id: "details"
  → [Goodbye]        goto_id: (empty = end)

Player picks "Tell me more"

NPC: "Well, you see..."
(no options — press E to close)
```

---

## SECTION 2: Writing a Dialogue File

Create one `.gd` file per NPC under `assets/dialogue/`. It holds all that NPC's conversations.

```gdscript
# assets/dialogue/myNpc/myNpc.gd
extends DialogueScript

func get_conversations() -> Array:
    return [_start(), _details()]

func _start() -> DialogueConversation:
    var c := DialogueConversation.new()
    c.id = &"start"
    c.lines = [
        "Hello there.",
        "What do you want?",  # player presses E to advance between lines
    ]
    c.options = [
        DialogueOption.new("Tell me more", &"details"),  # (button text, goto_id)
        DialogueOption.new("Goodbye", &""),               # empty goto_id = end dialogue
    ]
    return c

func _details() -> DialogueConversation:
    var c := DialogueConversation.new()
    c.id = &"details"
    c.lines = [
        "Well, you see...",
        "It's complicated.",
    ]
    c.options = [
        DialogueOption.new("Go back", &"start"),
        DialogueOption.new("I see. Bye.", &""),
    ]
    return c
```

Rules:
- `id` is a StringName (`&"start"` not `"start"`) — must match the `goto_id` used to reach it
- First entry returned by `get_conversations()` is always the opening conversation
- `goto_id` empty (`&""`) = dialogue ends when that option is chosen
- Conversations can point back to each other — loops work fine
- Add as many private functions as needed — one per conversation branch

---

## SECTION 3: Setting Up an NPC

### Step 1 — Create the NPC Scene

1. In the file browser, right-click `entities/npcs/` → **New Folder** → name it `myNpc`
2. Right-click the folder → **New Scene**
3. Root node type: **Node3D** — name it `MyNpc`
4. Save as `entities/npcs/myNpc/myNpc.tscn`

### Step 2 — Add a Mesh

1. Right-click `MyNpc` → **Add Child Node** → `MeshInstance3D`
2. Inspector → **Mesh** → **New CapsuleMesh**

### Step 3 — Add a Collision Shape

The player's raycast needs something to hit.

1. Right-click `MyNpc` → **Add Child Node** → `StaticBody3D`
2. Right-click `StaticBody3D` → **Add Child Node** → `CollisionShape3D`
3. Inspector → **Shape** → **New CapsuleShape3D**

### Step 4 — Attach the Interactable Script

1. Select `MyNpc` (root node)
2. Inspector → **Script** → folder icon → `res://entities/shared/interactable.gd`

### Step 5 — Assign the Dialogue Resource

1. Select `MyNpc` (root node)
2. Inspector → **Interactable** section → **Dialogue Resource** → **New DialogueResource**
3. Click the **DialogueResource** that appears — it expands
4. Set **Npc Name**: whatever shows in the dialogue box
5. Click **Dialogue Script** → drag `myNpc.gd` from the file browser into the field

### Step 6 — Set the Interaction Label

Inspector → **Interaction Label**: `Speak`, `Read`, `Take`, `Use`, etc.

### Step 7 — Save and Add to Level

1. **Ctrl+S** to save
2. Open `levels/test/world.tscn`
3. Drag `myNpc.tscn` into the **World** node

### Step 8 — Test

**Play** → walk toward the NPC → press **E**

---

## SECTION 4: Controls During Dialogue

| Input | Action |
|-------|--------|
| **E** | Advance line, or confirm focused option |
| **Scroll wheel** | Navigate options up / down |
| **Up / Down arrow** | Navigate options up / down |
| **1, 2, 3…** | Select option directly by number |
| **Enter** | Confirm focused option |
| Walk away | Closes dialogue automatically |

---

## SECTION 5: Quick Checklist

|     | What                                                      | Where                          |
| --- | --------------------------------------------------------- | ------------------------------ |
| ☐   | Root node is Node3D                                       | Scene tree                     |
| ☐   | Has MeshInstance3D                                        | Scene tree                     |
| ☐   | Has StaticBody3D + CollisionShape3D                       | Scene tree                     |
| ☐   | `interactable.gd` attached to root                        | Inspector → Script             |
| ☐   | DialogueResource created and expanded                     | Inspector → Interactable       |
| ☐   | Npc Name set                                              | Inside DialogueResource        |
| ☐   | Dialogue Script assigned (a `.gd` extending DialogueScript) | Inside DialogueResource      |
| ☐   | First conversation in `get_conversations()` is the opener | Inside the .gd file            |
| ☐   | Every `goto_id` matches an `id` in the same file          | Inside the .gd file            |
| ☐   | Scene saved and added to world.tscn                       | File browser                   |
