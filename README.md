# Pummeler
One button for equipping and using Manual Crowd Pummeler(s) in vanilla World of Warcraft (1.12.1).

Author: Cernie (fixed for classic by Oskros)


# Installation

Unzip the FeralHelper folder into WoW directory Interface/Addons folder. Remove the -master from the folder name.

# Usage
You can use the following functions in macros and WeakAuras<br/><br/>

Get text printout of charges for a specific MCP. Leave arguments empty to get charges for current equipped MCP
```lua
/run print(Pummeler_getCharges{bag=0, slot=14})
```

<br/>Get all available MCP charges in bag and equipped
```lua
/run print(Pummeler_availableCharges())
```

<br/>Get bag position of first encountered MCP. Set second argument to true for only returning MCP with 3 charges
```lua
/run print(Pummeler_isPummelerInBag("Manual Crowd Pummeler", false))
```

<br/>Check if the player has a specific buff active (test by SpellID) - example is for Clearcasting
```lua
/run print(PlayerHasBuff(16870))
```

<br/>Determine SpellIconID of the optimal next spell/ability to cast in the feral rotation. Usable in WeakAura dynamic icons
```lua
/run print(GetNextSpell())
```