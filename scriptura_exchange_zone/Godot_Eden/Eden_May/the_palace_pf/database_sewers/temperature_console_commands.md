# Temperature System Console Commands

This document outlines all available console commands for interacting with the Temperature System in Notepad3D.

## Temperature Core System Commands

### Basic Temperature Control

```
temperature set <value>
```
Sets the temperature to a specific value in Celsius.
- Example: `temperature set 100` - Sets temperature to 100°C

```
temperature get
```
Displays the current temperature value and state.

```
temperature increment <amount>
```
Increases the temperature by the specified amount.
- Example: `temperature increment 10` - Increases temperature by 10°C

```
temperature decrement <amount>
```
Decreases the temperature by the specified amount.
- Example: `temperature decrement 5` - Decreases temperature by 5°C

```
temperature state <statename>
```
Sets the temperature to match a specific state.
- Valid states: FROZEN, COLD, NORMAL, WARM, HOT, BOILING, PLASMA
- Example: `temperature state HOT` - Sets temperature to the HOT range

### Dimension Integration

```
temperature dimension <dimension>
```
Sets the temperature to match a specific dimension's base temperature.
- Example: `temperature dimension kappa` - Sets temperature to Kappa dimension's value (1500°C)

```
temperature auto_sync <on|off>
```
Toggles automatic temperature synchronization with dimension changes.
- Example: `temperature auto_sync on` - Temperature will automatically change with dimensions

### System Information

```
temperature info
```
Displays comprehensive information about the current temperature state and effects.

```
temperature states
```
Lists all temperature states with their threshold values and descriptions.

## Temperature Visual Effects Commands

```
temp_visual describe [state]
```
Provides a description of the current visual effects or for a specific state.
- Example: `temp_visual describe PLASMA` - Describes plasma state visual effects

```
temp_visual status
```
Shows the current active visual effects.

```
temp_visual refresh
```
Refreshes all temperature visual effects based on current temperature.

## Temperature Word Effects Commands

```
temp_effect list
```
Lists all active words with their current temperature states.

```
temp_effect history [word_id]
```
Displays transformation history for all words or a specific word.
- Example: `temp_effect history word_42` - Shows transformation history for word_42

```
temp_effect transform <word_id> <form>
```
Manually transforms a word to a specific state.
- Valid forms: normal, frozen, gas, plasma
- Example: `temp_effect transform word_42 plasma` - Transforms word_42 to plasma state

## Temperature UI Commands

```
temp_ui show
```
Shows the temperature UI.

```
temp_ui hide
```
Hides the temperature UI.

```
temp_ui toggle
```
Toggles the temperature UI visibility.

## Temperature Integration Commands

```
temp_integration status
```
Displays the current status of temperature system integrations.

```
temp_integration dimension
```
Shows the current dimension's temperature information.

```
temp_integration reconnect
```
Forces reconnection of all temperature-related systems.

## Example Console Sessions

### Freezing Words Example
```
> temperature set -10
Temperature set to -10°C (FROZEN)

> temp_visual describe
Words are crystallized in frozen state, glittering with ice particles.

> create_word "eternity"
Word "eternity" created in frozen state.

> temp_effect list
eternity: frozen (-10°C)
```

### Creating Temperature Cycle
```
> temperature set 20
Temperature set to 20°C (NORMAL)

> create_word "metamorphosis"
Word "metamorphosis" created in normal state.

> temperature increment 100
Temperature set to 120°C (BOILING)

> temp_effect history metamorphosis
Transformation history for word 'metamorphosis':
- normal → gas at 120°C

> temperature increment 1000
Temperature set to 1120°C (PLASMA)

> temp_effect history metamorphosis
Transformation history for word 'metamorphosis':
- normal → gas at 120°C
- gas → plasma at 1120°C
```

### Dimension Temperature Exploration
```
> temperature dimension alpha
Temperature set to 25°C (NORMAL) - Alpha dimension

> temperature dimension delta
Temperature set to -10°C (FROZEN) - Delta dimension

> temperature dimension kappa
Temperature set to 1500°C (PLASMA) - Kappa dimension
```