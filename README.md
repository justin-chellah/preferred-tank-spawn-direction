# [L4D/2] Preferred Tank Spawn Direction
This is a SourceMod Plugin that allows developers to specify the tank spawn direction separately from other Special Infected through the AI Director. For example, this can be very handy if you need to have Special Infected spawn close and the Tank far away.

# CVar
- `director_preferred_tank_direction` (set to `-1` by default)
   - This is the default value. If you're specifying it through a Director VScript, it'll be overriden

You can use the values from the `MobLocationType` enum to change where a Tank should spawn:
```
enum MobLocationType
{
	SPAWN_NO_PREFERENCE = -1,
	SPAWN_ANYWHERE,
	SPAWN_BEHIND_SURVIVORS,
	SPAWN_NEAR_IT_VICTIM,
	SPAWN_SPECIALS_IN_FRONT_OF_SURVIVORS,
	SPAWN_SPECIALS_ANYWHERE,
	SPAWN_FAR_AWAY_FROM_SURVIVORS,
	SPAWN_ABOVE_SURVIVORS,
	SPAWN_IN_FRONT_OF_SURVIVORS,
	SPAWN_VERSUS_FINALE_DISTANCE,
	SPAWN_LARGE_VOLUME,
	SPAWN_NEAR_POSITION,
};
```

# Example VScript Code
```
DirectorOptions <-
{
	PreferredTankDirection = SPAWN_BEHIND_SURVIVORS
}
```

# Requirements
- [SourceMod 1.11+](https://www.sourcemod.net/downloads.php?branch=stable)

# Docs
- [L4D2 Director Scripts](https://developer.valvesoftware.com/wiki/L4D2_Director_Scripts)

# Supported Platforms
- Windows
- Linux

# Supported Games
- Left 4 Dead 2
- Left 4 Dead (soon; requires gamedata)
