# Disaster Response System - Implementation Guide

## Overview
The Disaster Response System has been successfully implemented for "Bantay: Guardians of the Archipelago". This system creates dynamic, randomly cycling environmental disasters that affect the game world every 10 seconds using Godot's particle system.

## Architecture

### Core Components

1. **DisasterManager** (`scripts/systems/disaster_manager.gd`)
   - Central controller for the disaster system
   - Manages disaster cycling every 10 seconds
   - Randomly selects disasters from the available pool
   - Emits signals for disaster start/end events

2. **BaseDisaster** (`scripts/disasters/base_disaster.gd`)
   - Abstract base class for all disaster types
   - Provides common functionality:
     - Particle system management
     - Collision area detection
     - Entity tracking in disaster zones
     - Activate/deactivate methods

3. **Individual Disasters**
   - **FloodDisaster** (`scripts/disasters/flood_disaster.gd`)
   - **WildfireDisaster** (`scripts/disasters/wildfire_disaster.gd`)
   - **EarthquakeDisaster** (`scripts/disasters/earthquake_disaster.gd`)
   - **TyphoonDisaster** (`scripts/disasters/typhoon_disaster.gd`)

## Disaster Specifications

### 🌊 Flood (Tubig's Domain)
- **Visual Effects**: Blue water particle droplets falling, creating rising water effect
- **Particle Count**: 200
- **Radius**: 250 units
- **Mechanics**:
  - Slows movement to 60% for entities in zone
  - No direct damage
  - Water particles with downward gravity
  - Color gradient: Light blue to dark blue

### 🔥 Wildfire (Apoy's Domain)
- **Visual Effects**: Orange/red/yellow flames rising upward with smoke
- **Particle Count**: 300
- **Radius**: 220 units
- **Mechanics**:
  - Deals 10 damage per second to entities in zone
  - Flames rise with negative gravity
  - Color gradient: Yellow → Orange → Red → Dark red
  - Particles grow as they rise

### ⛰️ Earthquake (Lupa's Domain)
- **Visual Effects**: Brown/grey falling debris with screen shake
- **Particle Count**: 150
- **Radius**: 280 units
- **Mechanics**:
  - Deals 5 damage per second from falling debris
  - 30% chance per second to knock down entities
  - Visual screen shake effect (10 unit intensity)
  - Tumbling debris particles with angular velocity

### 🌪️ Typhoon (Hangin's Domain)
- **Visual Effects**: White/grey wind streaks with flying debris
- **Particle Count**: 400
- **Radius**: 300 units (largest disaster)
- **Mechanics**:
  - Pushes entities with 200 force in random directions
  - Wind direction changes every 0.5 seconds
  - Deals 3 damage per second from debris
  - Semi-transparent wind streaks

## Integration

The DisasterManager has been integrated into the Main scene at position (400, 300). To test:

1. **Run the game** - A disaster will spawn immediately
2. **Wait 10 seconds** - The disaster will automatically change
3. **Press Space/Enter** - Displays current disaster in console

## Console Output

When running, you'll see:
```
Disaster Response System initialized!
Disasters will cycle every 10 seconds
=== NEW DISASTER: FLOOD ===
Disaster started: FLOOD
[After 10 seconds]
=== DISASTER ENDED: FLOOD ===
Disaster ended: FLOOD
=== NEW DISASTER: EARTHQUAKE ===
Disaster started: EARTHQUAKE
```

## Future Integration Points

### Player Response (Not Yet Implemented)
Each disaster is designed to interact with future player abilities:

- **Flood**: Tubig players can create safe paths
- **Wildfire**: Apoy players are immune, Tubig can extinguish
- **Earthquake**: Lupa players can stabilize ground
- **Typhoon**: Hangin players can navigate freely

### Methods Ready for Player Integration

Each disaster supports these optional methods on entities:
- `take_damage(amount, type)` - Receive damage from disaster
- `apply_slow_effect(multiplier)` - Movement slowdown (Flood)
- `remove_slow_effect()` - Remove slowdown (Flood)
- `apply_knockdown()` - Knockdown effect (Earthquake)
- `apply_push_force(vector)` - Wind push (Typhoon)

## Configuration

All disasters have exported variables that can be adjusted:

**FloodDisaster**:
- `slow_multiplier`: Default 0.6 (60% movement speed)
- `water_rise_speed`: Default 10.0

**WildfireDisaster**:
- `fire_damage_per_second`: Default 10.0

**EarthquakeDisaster**:
- `shake_intensity`: Default 10.0
- `knockdown_chance`: Default 0.3 (30% per second)
- `debris_density`: Default 150

**TyphoonDisaster**:
- `wind_force`: Default 200.0
- `wind_change_interval`: Default 0.5 seconds

**DisasterManager**:
- `disaster_duration`: Default 10.0 seconds
- `disaster_spawn_position`: Default Vector2(400, 300)

## File Structure

```
LevelUpNstw/
├── scripts/
│   ├── systems/
│   │   └── disaster_manager.gd
│   ├── disasters/
│   │   ├── base_disaster.gd
│   │   ├── flood_disaster.gd
│   │   ├── wildfire_disaster.gd
│   │   ├── earthquake_disaster.gd
│   │   └── typhoon_disaster.gd
│   └── main.gd
├── scenes/
│   ├── disasters/
│   │   ├── flood.tscn
│   │   ├── wildfire.tscn
│   │   ├── earthquake.tscn
│   │   └── typhoon.tscn
│   └── Main.tscn
└── DISASTER_SYSTEM_README.md
```

## Testing Checklist

- [x] DisasterManager creates and destroys disasters
- [x] Disasters cycle every 10 seconds
- [x] Random disaster selection works
- [x] All 4 disaster types can spawn
- [x] Particle effects are visible
- [x] Collision zones are set up
- [ ] Test with player movement (requires player implementation)
- [ ] Test damage application (requires health system)
- [ ] Test elemental interactions (requires player abilities)

## Next Steps

1. **Implement Player Abilities**: Add the Bantay elemental system with player-specific responses to disasters
2. **Add Visual Feedback**: Create UI indicators for active disasters
3. **Implement Disaster Interactions**: Add the disaster interaction matrix (Fire + Wind = Firestorm, etc.)
4. **Add Sound Effects**: Integrate audio for each disaster type
5. **Test Performance**: Optimize particle counts for target platforms

## Notes

- All disasters use GPUParticles2D for better performance
- Particle systems are procedurally generated in code for easy tweaking
- The system is modular - new disasters can be added by extending BaseDisaster
- Signal-based architecture allows easy integration with other game systems
