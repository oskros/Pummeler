# FeralHelper
Several LUA utility functions for Ferals in classic World of Warcraft (1.12.1). Used optimally together with WeakAuras.
Credit to Cernie at https://github.com/Cernie/Pummeler for functions used to scan the tooltip for getting MCP charges

Author: Oskros


# Installation
Download the repository, unzip the FeralHelper folder into WoW directory Interface/Addons folder. Remove "-master" from the folder name.

# Usage
You can use the following functions in macros and WeakAuras<br/><br/>

Get text printout of charges for a specific MCP. Leave arguments empty to get charges for current equipped MCP. Can be passed on to the example below to get an integer output
```lua
/run print(FH_PummelerChargesText{bag=0, slot=14})
/run print(FH_PummelerChargesNumber(FH_PummelerChargesText{bag=0, slot=14}))
```

<br/>Get all available MCP charges in bag and equipped
```lua
/run print(FH_AvailablePummelerCharges())
```

<br/>Get bag position of first encountered item by name. Set second argument to true if scanning for MCP and you only want to return a MCP with 3 charges
```lua
/run print(FH_ItemBagPosition("Manual Crowd Pummeler", false))
```

<br/>Check if the player has a specific buff active (test by SpellID) - example is for Clearcasting
```lua
/run print(FH_PlayerHasBuff(16870))
```

<br/>Determine SpellIconID of the next spell/ability to cast in the optimal feral DPS rotation during raids. Can be set-up with WeakAuras to show a dynamic changing icon
```lua
/run print(FH_GetNextSpell())
```