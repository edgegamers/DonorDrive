
#define JUGGERNAUT_ROUNDS 1

static int g_AssaultSuitRounds[MAXPLAYERS + 1] = { 0, ... };
static char g_OldModel[MAXPLAYERS + 1][PLATFORM_MAX_PATH+1];

static void GiveSuitForRounds(int client, int rounds)
{
    g_AssaultSuitRounds[client] += rounds;
    GiveSuit(client);
}

static void GiveSuit(int client)
{
    //  Store old model
    if (g_OldModel[client][0] == '\0')
        GetClientModel(client, g_OldModel[client], sizeof(g_OldModel[]));

    GivePlayerItem(client, "item_heavyassaultsuit");

    LdEmptySlot(client, CS_SLOT_PRIMARY);
    int weapon = GivePlayerItem(client, "weapon_sawedoff");
    EquipPlayerWeapon(client, weapon);
}

static void RemoveSuit(int client)
{
    if (GetEntProp(client, Prop_Send, "m_bHasHeavyArmor"))
    {
        if (g_OldModel[client][0] != '\0')
            SetEntityModel(client, g_OldModel[client]);

        SetEntProp(client, Prop_Send, "m_bHasHelmet", false);
        SetEntProp(client, Prop_Send, "m_bHasHeavyArmor", false);
        SetEntProp(client, Prop_Send, "m_bWearingSuit", false);
        SetEntProp(client, Prop_Data, "m_ArmorValue", 0);
    }
}

void JgPrecache()
{
    //  Precache assault suit model for both teams
    //  Because the game doesn't do this itself...
    PrecacheModel("models/player/custom_player/legacy/tm_phoenix_heavy.mdl", true);
    PrecacheModel("models/player/custom_player/legacy/ctm_heavy.mdl", true);
}

void JgClear(int client)
{
    g_AssaultSuitRounds[client] = 0;
    g_OldModel[client][0] = '\0';
}

void JgRoundStart()
{
    for(int i = 0; i <= MaxClients; i++)
    {
        if (!IsValidClient(i))
            continue;

        if (!IsPlayerAlive(i))
            continue;

        RemoveSuit(i);

        if (g_AssaultSuitRounds[i] > 0)
        {
            g_AssaultSuitRounds[i]--;
            GiveSuit(i);

            if (g_AssaultSuitRounds[i] == 0)
            {
                CPrintToChatAll(CRAZY_PREFIX ... "This is %N's last round as a {orchid}Juggernaut{default}!", i);
                PrintCenterText(i, "This is your last round as a juggernaut!");
            }
            else
            {
                CPrintToChatAll(CRAZY_PREFIX ... "%N is a {orchid}Juggernaut{default} for %d more rounds!", i, g_AssaultSuitRounds[i]);
            }
        }
    }
}

bool JgRandomPlayerOnTeam(Get5Team team)
{
    int client = GetRandomPlayer(team);

    if (client == -1)
        return false;

    GiveSuitForRounds(client, JUGGERNAUT_ROUNDS);

    CPrintToChatAll(CRAZY_PREFIX ... "%N is now a {orchid}Juggernaut{default} for %d rounds!", client, g_AssaultSuitRounds[client]);
    PrintCenterText(client, "You are now a juggernaut!\nYou will walk slower but have significantly more health.");

    return true;
}