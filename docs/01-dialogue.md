# Dialogue System — Complete Guide

## SECTION 1: What Is This & Why Do You Need It?

### What It Does
The **dialogue system** lets you make any entity talk to the player. When the player presses E near an entity, a conversation box appears with:
- What the entity says
- Multiple choice options the player can pick
- Different responses depending on which option was chosen

### Real Example

```
Player: [walks near testNpc, presses E]

testNpc says: "Test line 0."

Options appear:
  [Option A] "Option text A"
  [Option B] "Option text B"

Player picks [Option A]:

testNpc says: "You picked A."

Player walks away, conversation closes automatically.
```

### Why This Exists
Without this system, you'd have to:
1. Create custom input handling code for every entity
2. Manually wire up option buttons
3. Write code to show and hide the UI
4. Track which line you're on

**With this system:** You write the dialogue data once, attach one script, and it all works automatically.

---

## SECTION 2: Complete Guide (0 to 100%)

### Part A: Understanding the Files

Three files work together. You don't edit them. You just use them.

1. **`core/dialogue/dialogueResource.gd`**
   - The data structure that stores dialogue
   - You extend this to write your dialogue
   - Holds lines, options, and branches

2. **`entities/shared/interactable.gd`**
   - Attach this to any entity you want to be talkable
   - Automatically creates a detection zone around the entity
   - Holds a reference to your dialogue data

3. **`core/autoloads/dialogueManager.gd`**
   - Always running in the background
   - Listens for the E key globally
   - Finds the nearest entity with dialogue
   - Shows and hides the dialogue UI

---

### Part B: Create Your First Dialogue File

#### Step 1: Create the Dialogue File

1. In Godot's file browser, right-click on `assets/dialogue/`
2. Select "Create New" → "Script"
3. Name it: `testNpc.gd`
4. Copy this exact code into it:

```gdscript
extends DialogueResource

func _init() -> void:
	super()
	npc_name = "TestNpc"

	add_conversation(["Test line 0."])    # conv 0 — opening
	add_conversation(["You picked A."])   # conv 1 — branch A
	add_conversation(["You picked B."])   # conv 2 — branch B

	add_option(0, "Option text A", 1)  # at end of conv 0 → go to conv 1
	add_option(0, "Option text B", 2)  # at end of conv 0 → go to conv 2
```

**What each part means:**

| Code | What It Does |
|------|-------------|
| `npc_name = "TestNpc"` | Name shown in the dialogue box header |
| `add_conversation(["line 1", "line 2"])` | Adds a sequence of lines as one conversation |
| `add_option(0, "text", 1)` | At the end of conv 0, show a button that jumps to conv 1 |

**Conversations are numbered starting from 0:**
```
add_conversation([...])  ← this is conv 0
add_conversation([...])  ← this is conv 1
add_conversation([...])  ← this is conv 2
```

**Each conversation can have multiple lines** — the player presses E to advance through them:
```gdscript
add_conversation([
    "Welcome, traveler.",
    "I've been here a long time.",
    "What brings you to this place?"   # options appear on this last line
])
```

---

### Part C: Create the NPC Scene

NPCs live in their own scene files and get imported into levels. This keeps them reusable.

#### Step 1: Create the Folder and Scene

1. In the file browser, right-click `entities/`
2. Create folder: `npcs`
3. Inside that, create folder: `testNpc`
4. Right-click inside `entities/npcs/testNpc/` → "New Scene"
5. When asked for root node type, choose: **Node3D**
6. Name the root node: `TestNpc`
7. Save as: `entities/npcs/testNpc/testNpc.tscn`

You now have an empty NPC scene open.

#### Step 2: Add a Visible Body (Cube)

The NPC needs something visible. We use a cube as a placeholder:

1. In the scene tree, right-click `TestNpc` → "Create Child Node"
2. Type "MeshInstance3D" and create it
3. Select `MeshInstance3D` in the scene tree
4. In the **Inspector** (right panel), find "Mesh"
5. Click the dropdown next to Mesh → "New BoxMesh"

You should now see a white cube in the viewport.

#### Step 3: Attach the Interactable Script

1. In the scene tree, click `TestNpc` (the root Node3D)
2. In the **Inspector**, look for "Script" at the bottom
3. Click the folder icon next to Script
4. Navigate to: `res://entities/shared/interactable.gd`
5. Select it and click "Open"

The script is now attached.

#### Step 4: Set the Dialogue Path and Interaction Label

After attaching the script, its properties appear in the Inspector.

1. Make sure `TestNpc` (root) is selected in the scene tree
2. In the Inspector, find the **"Interactable"** section and expand it
3. Set **Dialogue Path** — click the folder icon and navigate to `res://assets/dialogue/testNpc.gd`
4. Set **Interaction Label** — this is the verb shown in the proximity prompt (default: `"Speak"`)

**Where to look:**
```
Inspector Panel
├── Transform
├── Visibility
├── ▼ Interactable
│   ├── Dialogue Path        ← click folder icon → select testNpc.gd
│   └── Interaction Label    ← type "Speak", "Take", "Steal", "Read", etc.
└── Script
```

**Interaction label examples:**

| Entity Type | Label |
|-------------|-------|
| NPC | `Speak` |
| Chest / item on ground | `Take` |
| Enemy's pocket | `Steal` |
| Sign / book | `Read` |
| Door / lever | `Use` |

#### Step 5: Save the NPC Scene

Press **Ctrl+S** to save `testNpc.tscn`.

---

### Part D: Add the NPC to the Level

#### Step 1: Open the Level

1. Open `levels/test/world.tscn` in Godot

#### Step 2: Import the NPC Scene

1. In the file browser at the bottom, navigate to `entities/npcs/testNpc/`
2. Find `testNpc.tscn`
3. **Drag it** from the file browser and **drop it** onto the "World" node in the scene tree

The TestNpc appears in the level.

#### Step 3: Position the NPC

1. Select the `TestNpc` node in the scene tree
2. In the Inspector, change Transform → Position
3. Set values so it's near where the player spawns, example:
   - X: 5, Y: 2, Z: 0

---

### Part E: Test It

1. Press **Play**
2. Walk toward the TestNpc
3. When you get within ~8 units, a prompt appears at the center of the screen:
   ```
   [ E ]   Speak   ·   TestNpc
   ```
4. Press **E** — the dialogue box opens
5. Scroll the mouse wheel or use arrow keys to navigate options
6. Press **E** or **Enter** to confirm the focused option, or press a **number key**
7. Walk away — dialogue closes automatically and the prompt reappears if still in range

**Nothing happened? Check:**
- Is `interactable.gd` attached to `TestNpc`? (Inspector → Script)
- Is the Dialogue Path set in Inspector → Interactable?
- Is the dialogue `.gd` file in `assets/dialogue/` and starts with `extends DialogueResource`?

---

### Part G: Add Branching Dialogue

Here is a complete branching example. Create `assets/dialogue/testNpcBranch.gd`:

```gdscript
extends DialogueResource

func _init() -> void:
	super()
	npc_name = "TestNpc"

	add_conversation(["Test opening line."])              # conv 0 — opening
	add_conversation(["Branch A: line 1.", "Branch A: line 2."])  # conv 1
	add_conversation(["Branch B: line 1.", "Branch B: line 2."])  # conv 2
	add_conversation(["Branch C: line 1.", "Branch C: line 2."])  # conv 3

	add_option(0, "Go to branch A", 1)
	add_option(0, "Go to branch B", 2)
	add_option(0, "Go to branch C", 3)
```

**What this looks like when playing:**
```
TestNpc: "Test opening line."
  → [Go to branch A]
  → [Go to branch B]
  → [Go to branch C]

Player picks "Go to branch B":

TestNpc: "Branch B: line 1."  (press E)
TestNpc: "Branch B: line 2."  (press E → dialogue closes)
```

---

### Part H: Text Formatting

The dialogue text supports RichText tags inside any line string:

```gdscript
extends DialogueResource

func _init() -> void:
	super()
	npc_name = "TestNpc"

	add_conversation([
		"Normal text.",
		"[b]Bold text.[/b]",
		"[i]Italic text.[/i]",
		"[color=red]Red text.[/color]",
		"[color=green]Green text.[/color]",
		"[color=gold]Gold text.[/color]",
		"[b][color=red]Bold and red.[/color][/b]",
	])
```

---

### Part I: Multiple NPCs in One Level

#### Create dialogue files for each:

`assets/dialogue/testNpc1.gd`:
```gdscript
extends DialogueResource

func _init() -> void:
	super()
	npc_name = "TestNpc1"

	add_conversation(["I am testNpc1."])           # conv 0
	add_conversation(["TestNpc1 response A."])     # conv 1
	add_conversation(["TestNpc1 response B."])     # conv 2

	add_option(0, "Option A", 1)
	add_option(0, "Option B", 2)
```

`assets/dialogue/testNpc2.gd`:
```gdscript
extends DialogueResource

func _init() -> void:
	super()
	npc_name = "TestNpc2"

	add_conversation(["I am testNpc2."])           # conv 0
	add_conversation(["TestNpc2 response A."])     # conv 1

	add_option(0, "Option A", 1)
```

`assets/dialogue/testNpc3.gd`:
```gdscript
extends DialogueResource

func _init() -> void:
	super()
	npc_name = "TestNpc3"

	add_conversation([
		"I am testNpc3. No choices here.",
		"Press E to continue.",
		"Press E again to close."
	])  # conv 0 — no options, just press E through it
```

#### Create a separate scene for each:

- `entities/npcs/testNpc1/testNpc1.tscn` → attach `interactable.gd` → set `testNpc1.gd`
- `entities/npcs/testNpc2/testNpc2.tscn` → attach `interactable.gd` → set `testNpc2.gd`
- `entities/npcs/testNpc3/testNpc3.tscn` → attach `interactable.gd` → set `testNpc3.gd`

#### Drag all three into world.tscn at different positions.

---

### Part J: Understanding Conversation Numbers (Important)

Every `add_conversation()` call gets a number, starting from 0:

```gdscript
add_conversation(["Opening line."])           # ← conv 0
add_conversation(["Response A."])             # ← conv 1
add_conversation(["Response B."])             # ← conv 2
add_conversation(["A longer branch.",
                  "Second line of it."])      # ← conv 3
```

Options use these numbers to jump between conversations:
```gdscript
add_option(0, "Choose A", 1)   # at end of conv 0 → go to conv 1
add_option(0, "Choose B", 2)   # at end of conv 0 → go to conv 2
```

**Common mistake — pointing to a conversation that doesn't exist:**
```gdscript
add_conversation(["Only one conversation."])  # conv 0

add_option(0, "What?", 5)  # ← WRONG: conv 5 doesn't exist
```

Always count your `add_conversation()` calls to know the numbers.

---

### Part K: Troubleshooting

**E key does nothing:**
- Are you within 5 units of the NPC?
- Is `interactable.gd` attached to the NPC's root node?
- Is a dialogue `.gd` file set in the Dialogue Path property?

**Dialogue box appears but is empty:**
- Check `add_line()` is called in `_init()`
- Check the dialogue file is assigned to the entity

**No options showing:**
- Check `add_option()` is called after `add_line()`
- Check the first argument (from_line) matches a line that exists (starts at 0)

**Wrong text shows after choosing option:**
- Check the third argument in `add_option()` (the goto line index)
- Count your `add_line()` calls to confirm the line numbers

**Dialogue file not showing up when trying to assign it:**
- File must be in `assets/dialogue/` folder
- File must start with `extends DialogueResource`
- Try restarting Godot

---

## SECTION 3: Quick Reference

### File Structure Per NPC

```
assets/
└── dialogue/
    └── testNpc.gd        ← dialogue data

entities/
└── npcs/
    └── testNpc/
        └── testNpc.tscn  ← NPC scene (Node3D root, cube, interactable.gd)
```

### Dialogue File Template

```gdscript
extends DialogueResource

func _init() -> void:
	super()
	npc_name = "DisplayName"   # shown in UI

	add_conversation(["Opening line.", "Second line."])  # conv 0
	add_conversation(["Response A."])                    # conv 1
	add_conversation(["Response B."])                    # conv 2

	add_option(0, "Button text A", 1)  # end of conv 0 → go to conv 1
	add_option(0, "Button text B", 2)  # end of conv 0 → go to conv 2
```

### NPC Scene Checklist

| What | Where | Status |
|------|-------|--------|
| Root node is Node3D | `testNpc.tscn` | ✅ / ❌ |
| Has MeshInstance3D child | Scene tree | ✅ / ❌ |
| `interactable.gd` attached | Inspector → Script | ✅ / ❌ |
| Dialogue Path set | Inspector → Interactable → Dialogue Path | ✅ / ❌ |
| Interaction Label set | Inspector → Interactable → Interaction Label | ✅ / ❌ |
| Scene instanced in world.tscn | Scene tree | ✅ / ❌ |

### Proximity Prompt

When the player walks within 8 units of an interactable, a prompt appears on screen:
```
[ E ]   Speak   ·   TestNpc
```
- The verb (`Speak`, `Take`, `Steal`, etc.) comes from **Interaction Label** in the Inspector
- The name comes from `npc_name` in the dialogue file
- The prompt disappears automatically when out of range or when dialogue opens

### Controls During Dialogue

| Input | Action |
|-------|--------|
| **E** | Advance line, or confirm focused option |
| **Scroll wheel** | Navigate up / down through options |
| **Up / Down arrow** | Navigate up / down through options |
| **1, 2, 3…** | Directly select option by number |
| **Enter** | Confirm focused option |
| Walk away | Closes dialogue automatically |

### Text Formatting Tags

| Tag | Result |
|-----|--------|
| `[b]text[/b]` | **bold** |
| `[i]text[/i]` | *italic* |
| `[color=red]text[/color]` | red text |
| `[color=green]text[/color]` | green text |
| `[color=gold]text[/color]` | gold text |
| `[b][color=red]text[/color][/b]` | bold red |

---

## Summary

1. ✅ Create `assets/dialogue/testNpc.gd` — write conversations and options
2. ✅ Create `entities/npcs/testNpc/testNpc.tscn` — Node3D root + mesh + `interactable.gd` as script
3. ✅ Set **Dialogue Path** in Inspector → select `testNpc.gd`
4. ✅ Set **Interaction Label** in Inspector → e.g. `"Speak"`
5. ✅ Drag `testNpc.tscn` into `levels/test/world.tscn`
6. ✅ Press Play → walk near NPC → prompt appears → press E → dialogue opens
