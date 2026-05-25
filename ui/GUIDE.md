# UI Systems Guide

## Overview
All user interface elements: dialogue system, inventory, skills, pause menu, main menu, and HUD. Each is independently designed and can be extended.

---

## UI Systems

| System | Location | Purpose |
|--------|----------|---------|
| Dialogue | `dialogue/` | NPC conversations and interactions |
| Inventory | `inventory/` | Item management (3×3 grid) |
| Skills | `skill/` | Ability quick-bar (5 slots, bottom-center) |
| HUD | `hud/` | Debug information, health bar (future) |
| Pause Menu | `pause_menu/` | Game pause and menu options |
| Main Menu | `main_menu/` | Game startup and navigation |

---

## How to Create a New UI Panel

### Step 1: Create Scene Structure
Create a new scene in `res://ui/mySystem/`:

```
MyPanel (Control)
├── Panel (PanelContainer)
│   └── VBoxContainer
│       ├── Title (Label)
│       ├── Content (Control)
│       └── Buttons (HBoxContainer)
│           ├── Button1 (Button)
│           └── Button2 (Button)
```

### Step 2: Create Script
```gdscript
# res://ui/mySystem/myPanel.gd
extends Control

@onready var _title: Label = $Panel/VBoxContainer/Title
@onready var _content: Control = $Panel/VBoxContainer/Content
@onready var _button1: Button = $Panel/VBoxContainer/Buttons/Button1
@onready var _button2: Button = $Panel/VBoxContainer/Buttons/Button2

signal button1_pressed
signal button2_pressed

func _ready() -> void:
	_button1.pressed.connect(_on_button1)
	_button2.pressed.connect(_on_button2)

func set_title(text: String) -> void:
	_title.text = text

func _on_button1() -> void:
	button1_pressed.emit()

func _on_button2() -> void:
	button2_pressed.emit()
```

### Step 3: Add to Scene
Instantiate in your level or autoload:

```gdscript
var panel = load("res://ui/mySystem/myPanel.tscn").instantiate()
panel.button1_pressed.connect(_on_action)
get_tree().root.add_child(panel)
```

---

## Common UI Patterns

### Buttons with Signal
```gdscript
@onready var _button = $Panel/VBoxContainer/Button

func _ready() -> void:
	_button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	print("Button was pressed!")
```

### Toggle UI Visibility
```gdscript
func toggle() -> void:
	visible = not visible

func show_ui() -> void:
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func hide_ui() -> void:
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
```

### Animated UI Appearance
```gdscript
func _show_with_animation() -> void:
	var tween = create_tween()
	modulate.a = 0
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

func _hide_with_animation() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	hide()
```

---

## UI Positioning Presets

Common anchor presets in Godot:

| Preset | Position | Use |
|--------|----------|-----|
| 0 | Top-Left | Corner UI |
| 1 | Top-Center | Titles, notifications |
| 2 | Top-Right | Corner UI |
| 5 | Center | Modal dialogs |
| 7 | Bottom-Center | Health bars, skill bars |
| 8 | Bottom-Right | Inventory, mini-map |

Example (bottom-center like skill UI):
```gdscript
# In .tscn file
anchors_preset = 7
anchor_left = 0.5
anchor_top = 1.0
anchor_right = 0.5
anchor_bottom = 1.0
offset_left = -128  # Center horizontally
offset_top = -88    # Distance from bottom
offset_right = 128
offset_bottom = -8
```

---

## Mouse Mode Handling

Control mouse visibility based on UI state:

```gdscript
# When UI opens
func _on_ui_open() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# When UI closes
func _on_ui_close() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
```

---

## UI Layer System

Use CanvasLayer to control UI stacking:

```gdscript
# Create UI layer
var ui_layer = CanvasLayer.new()
ui_layer.layer = 10  # Higher = appears on top
add_child(ui_layer)

# Add UI to layer
var panel = load("res://ui/myPanel/myPanel.tscn").instantiate()
ui_layer.add_child(panel)
```

Layer values:
- 0-5: World UI (health bars, floating text)
- 10-15: HUD (inventory, skills, debug info)
- 20+: Menus (pause, settings)

---

## Complete Example: Custom Settings Panel

```gdscript
# res://ui/settings/settingsPanel.gd
extends Control

@onready var _volume_slider = $Panel/VBoxContainer/VolumeSlider
@onready var _brightness_slider = $Panel/VBoxContainer/BrightnessSlider
@onready var _close_button = $Panel/VBoxContainer/CloseButton

signal closed

func _ready() -> void:
	_volume_slider.value_changed.connect(_on_volume_changed)
	_brightness_slider.value_changed.connect(_on_brightness_changed)
	_close_button.pressed.connect(_on_close)

func _on_volume_changed(value: float) -> void:
	AudioServer.master_bus_mute = (value == 0)
	print("Volume: %.1f" % value)

func _on_brightness_changed(value: float) -> void:
	var env = get_viewport().get_world_3d().environment
	env.ambient_light_energy = value
	print("Brightness: %.1f" % value)

func _on_close() -> void:
	closed.emit()
	queue_free()
```

And the scene:
```
SettingsPanel (Control)
├── Panel (PanelContainer)
│   └── VBoxContainer
│       ├── Title (Label) = "Settings"
│       ├── VolumeLabel (Label)
│       ├── VolumeSlider (HSlider)
│       ├── BrightnessLabel (Label)
│       ├── BrightnessSlider (HSlider)
│       └── CloseButton (Button) = "Close"
```

---

## Responsive UI

Make UI adapt to different screen sizes:

```gdscript
# In your UI script
func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()

func _on_viewport_resized() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	
	# Adjust UI based on screen size
	if screen_size.x < 800:
		# Mobile or small screen
		_adjust_for_small_screen()
	else:
		# Desktop
		_adjust_for_large_screen()
```

---

## Troubleshooting

**UI appears behind world:**
- Check CanvasLayer layer property (should be 10+ for HUD)
- Ensure UI node is in CanvasLayer, not in 3D scene

**Buttons not clickable:**
- Check mouse_filter on all parent nodes (should be STOP or allow inherited)
- Ensure Control node has layout_mode = 1 or 3

**UI not showing:**
- Check visible property is true
- Check parent node is in scene tree
- Check modulate.a is not 0 (transparent)

**Text is cut off:**
- Check Label size (custom_minimum_size or anchors)
- Enable text wrapping: autowrap_mode = 2

**Mouse not visible:**
- Check Input.mouse_mode is MOUSE_MODE_VISIBLE
- Ensure _ready() is called before setting mode
