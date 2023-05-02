#include <sourcemod>

#define REQUIRE_EXTENSIONS
#include <dhooks>

#define GAMEDATA_FILE	"preferred_tank_spawn_direction"

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

enum ZombieClassType
{
	Zombie_Common = 0,
	Zombie_Smoker,
	Zombie_Boomer,
	Zombie_Hunter,
	Zombie_Spitter,
	Zombie_Jockey,
	Zombie_Charger,
	Zombie_Witch,
	Zombie_Tank,
	Zombie_Survivor,
};

Handle g_hSDKCall_CDirector_GetScriptValueInt = null;

Address g_addrTheDirector = Address_Null;

ConVar director_preferred_tank_direction = null;

int CDirector_GetScriptValueInt( const char[] szKey, int nDefaultValue )
{
	return SDKCall( g_hSDKCall_CDirector_GetScriptValueInt, g_addrTheDirector, szKey, nDefaultValue );
}

public MRESReturn DDetour_ZombieManager_CollectSpawnAreas( Address addrZombieManager, DHookReturn hReturn, DHookParam hParams )
{
	ZombieClassType eZombieClass = hParams.Get( 2 );

	if ( eZombieClass != Zombie_Tank )
	{
		return MRES_Ignored;
	}

	MobLocationType eMobLocation = view_as< MobLocationType >( CDirector_GetScriptValueInt( "PreferredTankDirection", director_preferred_tank_direction.IntValue ) );

	if ( eMobLocation != SPAWN_NO_PREFERENCE )
	{
		hParams.Set( 1, eMobLocation );

		return MRES_ChangedHandled;
	}

	return MRES_Ignored;
}

public void OnPluginStart()
{
	GameData hGameData = new GameData( GAMEDATA_FILE );

	if ( hGameData == null )
	{
		SetFailState( "Unable to load gamedata file \"" ... GAMEDATA_FILE ... "\"" );
	}

	g_addrTheDirector = hGameData.GetAddress( "CDirector" );

	if ( g_addrTheDirector == Address_Null )
	{
		delete hGameData;

		SetFailState( "Unable to find address entry or address in binary for \"CDirector\"" );
	}

	StartPrepSDKCall( SDKCall_Raw );
	if ( !PrepSDKCall_SetFromConf( hGameData, SDKConf_Signature, "CDirector::GetScriptValueInt" ) )
	{
		delete hGameData;

		SetFailState( "Unable to find gamedata signature entry or signature in binary for \"CDirector::GetScriptValueInt\"" );
	}

	PrepSDKCall_SetReturnInfo( SDKType_PlainOldData, SDKPass_Plain );
	PrepSDKCall_AddParameter( SDKType_String, SDKPass_Pointer );
	PrepSDKCall_AddParameter( SDKType_PlainOldData, SDKPass_Plain );
	g_hSDKCall_CDirector_GetScriptValueInt = EndPrepSDKCall();

	DynamicDetour hDDetour_ZombieManager_CollectSpawnAreas = new DynamicDetour( Address_Null, CallConv_THISCALL, ReturnType_Int, ThisPointer_Address );

	if ( !hDDetour_ZombieManager_CollectSpawnAreas.SetFromConf( hGameData, SDKConf_Signature, "ZombieManager::CollectSpawnAreas" ) )
	{
		delete hGameData;

		SetFailState( "Unable to find gamedata signature entry for \"ZombieManager::CollectSpawnAreas\"" );
	}

	delete hGameData;

	hDDetour_ZombieManager_CollectSpawnAreas.AddParam( HookParamType_Int );
	hDDetour_ZombieManager_CollectSpawnAreas.AddParam( HookParamType_Int );
	hDDetour_ZombieManager_CollectSpawnAreas.Enable( Hook_Pre, DDetour_ZombieManager_CollectSpawnAreas );

	director_preferred_tank_direction = CreateConVar( "director_preferred_tank_direction", "-1",
		"SPAWN_NO_PREFERENCE = -1, \
		SPAWN_ANYWHERE = 0, \
		SPAWN_BEHIND_SURVIVORS = 1, \
		SPAWN_NEAR_IT_VICTIM = 2, \
		SPAWN_SPECIALS_IN_FRONT_OF_SURVIVORS = 3, \
		SPAWN_SPECIALS_ANYWHERE = 4, \
		SPAWN_FAR_AWAY_FROM_SURVIVORS = 5, \
		SPAWN_ABOVE_SURVIVORS = 6, \
		SPAWN_IN_FRONT_OF_SURVIVORS = 7, \
		SPAWN_VERSUS_FINALE_DISTANCE = 8, \
		SPAWN_LARGE_VOLUME = 9" );
}

public Plugin myinfo =
{
	name = "[L4D/2] Preferred Tank Spawn Direction",
	author = "Justin \"Sir Jay\" Chellah",
	description = "Allows developers to specify spawn direction for tanks separately from other Special Infected through the AI Director",
	version = "1.0.0",
	url = "https://justin-chellah.com"
};