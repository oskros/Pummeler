# FeralHelper
Several LUA utility functions for Ferals in classic World of Warcraft (1.12.1). Used optimally together with WeakAuras
Credit to Cernie at https://github.com/Cernie/Pummeler for functions used to scan the tooltip for getting MCP charges

Author: Oskros


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

<br/>Determine SpellIconID of the next spell/ability to cast in the optimal feral DPS rotation during raids. Can be set-up with WeakAuras to show a dynamic changing icon
```lua
/run print(GetNextSpell())
```