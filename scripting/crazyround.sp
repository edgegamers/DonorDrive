
#include <sourcemod>
#include <cstrike>

#include <sdktools>
#include <sdktools_functions>
#include <sdktools_entinput>
#include <entity_prop_stocks>

#include <colorlib>
#include <donordrive>

#include <charitystrike>

#pragma newdecls required
#pragma semicolon 1

#define CRAZY_PREFIX "[{red}C{orange}R{yellow}A{green}Z{blue}Y{orchid}!{default}] "

public Plugin myinfo = {
    name = "DonorDrive Crazy Rounds",
    author = "EdgeGamers Development",
    description = "Crazy Rounds for Donations!",
    version = "1.0",
    url = "https://edgegamers.com/"
};

bool IsValidClient(int client, bool nobots = true)
{ 
    if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
    {
        return false; 
    }
    return IsClientInGame(client); 
}  

int GetRandomPlayer(Get5Team team)
{
    //  List of eligible player ids
    int eligible[MAXPLAYERS];
    int eligiblecount = 0;

    int csteam = Get5_Get5TeamToCSTeam(team);

    for(int i = 0; i <= MaxClients; i++)
    {
        if (!IsValidClient(i))
            continue;

        if (GetClientTeam(i) != csteam)
            continue;

        //  Dead players should never be considered for abuse
        if (!IsPlayerAlive(i))
            continue;

        eligible[eligiblecount] = i;
        eligiblecount++;   
    }

    if (eligiblecount == 0)
    {
        PrintToServer("[DonorDrive] Error getting random player for team (%d get5; %d cs): 0 eligible", team, csteam);
        CPrintToChatAdmins( ADMFLAG_RCON, "{red}[DonorDrive] Error getting random player for team (%d get5; %d cs): 0 eligible", team, csteam);
        return -1;
    }
    return eligible[GetRandomInt(0, eligiblecount - 1)];
}

#include "crazy/loadout.sp"
#include "crazy/slap.sp"
#include "crazy/gravity.sp"
#include "crazy/loudsounds.sp"
#include "crazy/juggernaut.sp"

ConVar g_Enabled;

//  Incentive IDs
ConVar g_SilentRandomLoadout;
ConVar g_SilentRandomBuff;
ConVar g_SilentFling;
ConVar g_SilentGrav;
ConVar g_SilentLoudSounds;
ConVar g_SilentJuggernaut;

ConVar g_KioRandomLoadout;
ConVar g_KioRandomBuff;
ConVar g_KioFling;
ConVar g_KioGrav;
ConVar g_KioLoudSounds;
ConVar g_KioJuggernaut;


public void OnPluginStart()
{
    HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy); 

    g_Enabled = CreateConVar("sm_crazy_enabled", "0", "(1 = Enable, 0 = Disable) Crazy Rounds");

    g_SilentRandomLoadout =     CreateConVar("sm_crazy_silent_loadout",     "2818D2E4-EBB3-1288-FD92C02B3CFDCFEA", "DonorDrive Incentive ID");
    g_SilentRandomBuff =        CreateConVar("sm_crazy_silent_buff",        "3AB6CEBF-D7D1-6A7A-D8C68536A4F3383B", "DonorDrive Incentive ID");
    g_SilentFling =             CreateConVar("sm_crazy_silent_fling",       "3B054C3C-C25B-26D2-AE8F8A4A7297CC60", "DonorDrive Incentive ID");
    g_SilentGrav =              CreateConVar("sm_crazy_silent_grav",        "3B28F370-91F1-3EFD-B2602DE6B47244AC", "DonorDrive Incentive ID");
    g_SilentLoudSounds =        CreateConVar("sm_crazy_silent_loudsounds",  "3B3A0951-EA47-121E-180706E203AA1BF9", "DonorDrive Incentive ID");
    g_SilentJuggernaut =        CreateConVar("sm_crazy_silent_juggernaut",  "593749C6-06DA-9CE6-58CFFD23E1A40A55", "DonorDrive Incentive ID");

    g_KioRandomLoadout =     CreateConVar("sm_crazy_kio_loadout",     "59555F6F-ADA0-2963-70139FEE54CB2A90", "DonorDrive Incentive ID");
    g_KioRandomBuff =        CreateConVar("sm_crazy_kio_buff",        "5958DFEB-D3A2-163B-A11291E3BD4E23FC", "DonorDrive Incentive ID");
    g_KioFling =             CreateConVar("sm_crazy_kio_fling",       "595E7033-B289-EB02-5B7B739F57F05F25", "DonorDrive Incentive ID");
    g_KioGrav =              CreateConVar("sm_crazy_kio_grav",        "596319FF-AF0A-3D4B-2EBC93ABB7BD7473", "DonorDrive Incentive ID");
    g_KioLoudSounds =        CreateConVar("sm_crazy_kio_loudsounds",  "5965A207-0CA5-92DC-BD454AB46170FCFC", "DonorDrive Incentive ID");
    g_KioJuggernaut =        CreateConVar("sm_crazy_kio_juggernaut",  "596D8726-B24C-F0EC-963476C51A7834B2", "DonorDrive Incentive ID");
}

public void OnMapStart()
{
    //  Precache sounds
    LsPrecache();
    JgPrecache();
}

public void OnClientDisconnect(int client)
{
    JgClear(client);
}

public Action OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
    //  Give all players their juggernaut suits, if they have one
    JgRoundStart();

    //  Prevent moon boot break notifications from carrying over between rounds
    GvResetAll();

    return Plugin_Continue;
}  

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
    SpOnRunCmd(client, buttons);

    return Plugin_Continue;
}  

//  Return type is ignored
public bool OnDonation(Donation donation)
{
    if (!g_Enabled.BoolValue)
        return false;

    //  Team silent incentives

    if (donation.IncentiveIsVar(g_SilentRandomLoadout))
        return LdRandomPlayerOnTeam(TEAM_SILENT);

    if (donation.IncentiveIsVar(g_SilentRandomBuff))
        return LdBuffRandomPlayerOnTeam(TEAM_SILENT);

    if (donation.IncentiveIsVar(g_SilentFling))
        return SpRandomPlayerOnTeam(TEAM_SILENT);

    if (donation.IncentiveIsVar(g_SilentGrav))
        return GvRandomPlayerOnTeam(TEAM_SILENT);

    if (donation.IncentiveIsVar(g_SilentLoudSounds))
        return LsRandomPlayerOnTeam(TEAM_SILENT);

    if (donation.IncentiveIsVar(g_SilentJuggernaut))
        return JgRandomPlayerOnTeam(TEAM_SILENT);

    //  Team Kio incentives

    if (donation.IncentiveIsVar(g_KioRandomLoadout))
        return LdRandomPlayerOnTeam(TEAM_KIOSHIMA);

    if (donation.IncentiveIsVar(g_KioRandomBuff))
        return LdBuffRandomPlayerOnTeam(TEAM_KIOSHIMA);

    if (donation.IncentiveIsVar(g_KioFling))
        return SpRandomPlayerOnTeam(TEAM_KIOSHIMA);

    if (donation.IncentiveIsVar(g_KioGrav))
        return GvRandomPlayerOnTeam(TEAM_KIOSHIMA);

    if (donation.IncentiveIsVar(g_KioLoudSounds))
        return LsRandomPlayerOnTeam(TEAM_KIOSHIMA);

    if (donation.IncentiveIsVar(g_KioJuggernaut))
        return JgRandomPlayerOnTeam(TEAM_KIOSHIMA);

    return false;
}