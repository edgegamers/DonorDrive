
//  The reset timers for each client's gravity
static Handle g_ResetTimers[MAXPLAYERS] = {INVALID_HANDLE, ...};

bool GvRandomPlayerOnTeam(Get5Team team)
{
    int client = GetRandomPlayer(team);

    if (client == -1)
        return false;

    CPrintToChatAll(CRAZY_PREFIX ... "%N was given {bluegrey}Moon Boots{default} for 30 seconds!", client);
    PrintCenterText(client, "You now have moon boots!\nHold space and crouch to jump farther.");
	SetEntProp(client, Prop_Send, "m_passiveItems", true, 1, 1);

    //  If the player already has moon boots, then just extend the duration
    //  and cancel the in-flight cancel.
    if (IsValidHandle(g_ResetTimers[client]))
        delete g_ResetTimers[client];
    
    //  Create a timer to remove the low-grav.
    g_ResetTimers[client] = CreateTimer(30.0, TimerReset, client);

    return true;
}

void GvReset(int client)
{
    if (IsValidHandle(g_ResetTimers[client]))
        delete g_ResetTimers[client];

    SetEntProp(client, Prop_Send, "m_passiveItems", false, 1, 1);
}

void GvResetAll()
{
    for(int i = 0; i <= MaxClients; i++)
    {
        if (!IsValidClient(i))
            continue;
            
        GvReset(i);
    }
}

public Action TimerReset(Handle timer, int client)
{
    //  Player left
    if (!IsValidClient(client))
        return Plugin_Stop;
    
    CPrintToChatAll(CRAZY_PREFIX ... "%N's {bluegrey}Moon Boots{default} broke :(", client);
    PrintCenterText(client, "Your moon boots broke!");
	SetEntProp(client, Prop_Send, "m_passiveItems", false, 1, 1);

    delete g_ResetTimers[client];
    return Plugin_Stop;
}