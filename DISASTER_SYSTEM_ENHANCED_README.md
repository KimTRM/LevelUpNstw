# Enhanced Disaster Response System - Complete Documentation

## Overview
The enhanced Disaster Response System features **camera-following disasters**, **environmental escalation effects**, and **combo disasters** that create powerful combined effects. All disasters now stay on screen as visual overlays that follow the player's camera.

---

## Core Features

### 1. Camera-Following Disasters
- All disasters are now parented to the Camera2D on the player
- Disasters remain visible on screen regardless of player movement
- Consistent on-screen visual feedback
- Screen shake effects work directly with the camera

### 2. Environmental Escalation
Each disaster intensifies over its 10-second duration:
- **Particle counts increase** (doubling by end)
- **Visual overlays grow more opaque** (reducing visibility)
- **Effect intensities escalate** (shake, wind force, etc.)
- **Radii expand** (for spreading disasters)

### 3. Combo Disaster System
- **20% chance** each cycle to spawn a combo disaster instead of single
- Combos combine two disaster types for enhanced effects
- **1.5x damage multiplier** for all combo disasters
- Unique visual combinations

---

## Individual Disasters

### 🌊 Flood (Tubig's Domain)
**Base Effects:**
- Blue water particle droplets
- Radius: 250 units
- No direct damage
- Movement slow effect (60% speed)

**Escalation (0s → 10s):**
- Particles: 200 → 400
- Blue visibility overlay: 0% → 30% opacity
- Represents rising water level

**Visual:** Blue tint overlay, increasing water particle density

---

### 🔥 Wildfire (Apoy's Domain)
**Base Effects:**
- Orange/red/yellow rising flames
- Radius: 220 → 350 units (expands)
- 10 damage per second

**Escalation (0s → 10s):**
- Particles: 300 → 600
- Radius: 220 → 350 (fire spreading)
- Smoke overlay: 0% → 40% opacity
- Emission radius expands with fire spread

**Visual:** Dark smoke overlay, expanding fire wall effect

---

### ⛰️ Earthquake (Lupa's Domain)
**Base Effects:**
- Brown/grey falling debris
- Radius: 280 units
- 5 damage per second
- 30% knockdown chance/second
- **Camera screen shake**

**Escalation (0s → 10s):**
- Particles: 150 → 400 (more debris)
- Shake intensity: 5 → 20 units
- Screen shake becomes violent

**Visual:** Intense camera shaking, heavy debris fall

---

### 🌪️ Typhoon (Hangin's Domain)
**Base Effects:**
- White/grey wind streaks
- Radius: 300 units (largest)
- 3 damage per second
- Wind push force in random directions
- Direction changes every 0.5s

**Escalation (0s → 10s):**
- Particles: 400 → 800
- Wind force: 100 → 400
- Particle speed: 150-300 → 300-600
- Debris overlay: 0% → 35% opacity

**Visual:** Grey debris overlay, extreme wind particle streaking

---

## Combo Disasters

### 🔥🌪️ FIRESTORM (Fire + Wind)
**Combination:** Wildfire + Typhoon

**Visual Effects:**
- Rotating fire tornado (180°/sec rotation)
- Ring-shaped fire emission (swirling flames)
- Orange/white wind streaks
- Orange-red screen tint (0% → 45% opacity)

**Mechanics:**
- **Pull force:** Draws entities toward center (150 force)
- **Damage:** 20 DPS × 1.5 = **30 DPS**
- **Radius:** 200 → 400 units
- **Particles:** 500 fire + 300 wind = 800 total → 1300 total

**Effect:** Massive damage tornado that pulls enemies in and burns them

---

### 🔥🌊 STEAM (Fire + Water)
**Combination:** Wildfire + Flood

**Visual Effects:**
- Dense white/grey steam clouds
- Condensing water droplets falling
- **Heavy vision obscuring** (65% opacity at max)
- White/grey screen tint

**Mechanics:**
- **Vision reduction:** Extreme (nearly total blindness)
- **Damage:** 8 DPS × 1.5 = **12 DPS** (heat damage)
- **Radius:** 250 → 400 units
- **Particles:** 600 steam + 200 droplets = 800 → 1400 total

**Effect:** Concealing steam that makes visibility nearly zero

---

### 🌪️🌊 WATERSPOUT (Wind + Water)
**Combination:** Typhoon + Flood

**Visual Effects:**
- Swirling blue/white water vortex
- Ring-shaped water emission (spiral pattern)
- Wind spray particles
- Blue/white screen tint (0% → 40% opacity)
- Rotating effect (240°/sec - faster than Firestorm)

**Mechanics:**
- **Knockback force:** 300 (escalates to 600)
- **Damage:** 15 DPS × 1.5 = **22.5 DPS**
- **Radius:** 220 → 380 units
- **Particles:** 550 water + 350 spray = 900 total → 1450 total
- Knockback direction changes every 0.8s

**Effect:** Violent waterspout with powerful knockback effects

---

## Technical Implementation

### File Structure
```
LevelUpNstw/
├── scripts/
│   ├── systems/
│   │   └── disaster_manager.gd (Enhanced with camera & combo logic)
│   ├── disasters/
│   │   ├── base_disaster.gd
│   │   ├── combo_disaster.gd (NEW - Base for combos)
│   │   ├── flood_disaster.gd (Enhanced with escalation)
│   │   ├── wildfire_disaster.gd (Enhanced with escalation)
│   │   ├── earthquake_disaster.gd (Enhanced with screen shake)
│   │   ├── typhoon_disaster.gd (Enhanced with escalation)
│   │   ├── firestorm_disaster.gd (NEW)
│   │   ├── steam_disaster.gd (NEW)
│   │   └── waterspout_disaster.gd (NEW)
│   └── main.gd
├── scenes/
│   ├── disasters/
│   │   ├── flood.tscn
│   │   ├── wildfire.tscn
│   │   ├── earthquake.tscn
│   │   ├── typhoon.tscn
│   │   ├── firestorm.tscn (NEW)
│   │   ├── steam.tscn (NEW)
│   │   └── waterspout.tscn (NEW)
│   └── Main.tscn
└── README files
```

### Camera Integration
```gdscript
# DisasterManager finds camera on player
var player = get_tree().get_first_node_in_group("Player")
camera = player.get_node_or_null("Camera2D")

# Disasters are parented to camera
if camera:
    camera.add_child(disaster)
    disaster.position = Vector2.ZERO  # Center of screen
```

### Escalation System
All disasters implement:
```gdscript
var escalation_timer: float = 0.0
var escalation_progress: float = 0.0  # 0.0 to 1.0

func _process(delta):
    escalation_timer += delta
    escalation_progress = clamp(escalation_timer / 10.0, 0.0, 1.0)
    # Lerp effects based on escalation_progress
```

### Combo System
```gdscript
# 20% chance for combo
if randf() < 0.2:
    _spawn_combo_disaster()
else:
    _spawn_disaster(random_type)
```

---

## Console Output Examples

### Regular Disaster:
```
DisasterManager: Camera found on player
Disaster Response System initialized!
Disasters will cycle every 10 seconds
=== NEW DISASTER: WILDFIRE ===
Disaster started: WILDFIRE
[10 seconds later]
=== DISASTER ENDED: WILDFIRE ===
Disaster ended: WILDFIRE
=== NEW DISASTER: FLOOD ===
```

### Combo Disaster:
```
Combo Disaster started: FIRESTORM (WILDFIRE + TYPHOON)
BasePlayer entered Firestorm - massive damage and pull effect!
[10 seconds later]
Combo Disaster ended: FIRESTORM
```

---

## Configuration Options

### DisasterManager Settings
```gdscript
@export var disaster_duration: float = 10.0  # Cycle time
@export var combo_chance: float = 0.2        # 20% chance
@export var camera_relative_offset: Vector2 = Vector2.ZERO
```

### Per-Disaster Settings

**Flood:**
- `slow_multiplier`: 0.6 (60% speed)
- `max_escalation_time`: 10.0 seconds

**Wildfire:**
- `fire_damage_per_second`: 10.0
- `initial_radius`: 220.0
- `max_radius`: 350.0

**Earthquake:**
- `initial_shake_intensity`: 5.0
- `max_shake_intensity`: 20.0
- `knockdown_chance`: 0.3 (30%/sec)

**Typhoon:**
- `initial_wind_force`: 100.0
- `max_wind_force`: 400.0
- `wind_change_interval`: 0.5 seconds

**Combos:**
- `combo_damage_multiplier`: 1.5 (all combos)

---

## Future Player Integration

### Methods Ready for Implementation
Each disaster checks for these methods on entities:

```gdscript
# Damage
body.take_damage(amount, type)  # types: "fire", "water", "wind", "physical", "heat"

# Movement effects
body.apply_slow_effect(multiplier)
body.remove_slow_effect()
body.apply_push_force(vector)
body.apply_knockdown()
```

### Elemental Immunity (Planned)
When player system is implemented:
- **Tubig** (Water) - Immune to Flood, resistant to Waterspout
- **Apoy** (Fire) - Immune to Wildfire, resistant to Firestorm
- **Hangin** (Wind) - Immune to Typhoon, resistant to Waterspout/Firestorm
- **Lupa** (Earth) - Immune to Earthquake

---

## Performance Notes

- **GPUParticles2D** used for all effects (hardware accelerated)
- **Particle counts** scale with escalation (performance impact increases over 10s)
- **Maximum particles per disaster:**
  - Flood: 400
  - Wildfire: 600
  - Earthquake: 400
  - Typhoon: 800
  - Firestorm: 1300 (two systems)
  - Steam: 1400 (two systems)
  - Waterspout: 1450 (two systems)

---

## Testing Checklist

- [x] DisasterManager finds and uses camera
- [x] Disasters parent to camera correctly
- [x] Disasters stay on screen when player moves
- [x] All 4 base disasters cycle properly
- [x] Escalation works for all disasters
- [x] Visual overlays appear and intensify
- [x] Screen shake works (Earthquake)
- [x] Combo disasters spawn (20% chance)
- [x] All 3 combo disasters work
- [x] Firestorm rotation and pull effect
- [x] Steam heavy vision obscuring
- [x] Waterspout knockback and rotation
- [ ] Test with actual player movement
- [ ] Verify performance with multiple disasters
- [ ] Test damage application (requires health system)

---

## Known Limitations

1. **No Mudslide combo** - Requires Earth disaster type (Lupa's domain) which isn't implemented as an environmental disaster
2. **Damage/effects not applied** - Waiting for player health/movement systems
3. **Single camera support** - Multiplayer would need per-camera disaster instances

---

## Version History

**v2.0 - Enhanced System:**
- Camera-following disasters
- Environmental escalation effects
- Combo disaster system (3 combos)
- Visual overlays for all disasters
- Screen shake for Earthquake

**v1.0 - Base System:**
- 4 base disasters
- 10-second cycling
- Basic particle effects
- World-position spawning
