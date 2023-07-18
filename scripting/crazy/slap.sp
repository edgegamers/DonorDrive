
//  Slap command
static bool g_ForceJump[MAXPLAYERS] = { false, ... };

bool SpRandomPlayerOnTeam(Get5Team team)
{
    int client = GetRandomPlayer(team);

    if (client == -1)
        return false;

    g_ForceJump[client] = true;
    
    CPrintToChatAll(CRAZY_PREFIX ... "%N was {orange}flinged{default}!", client);

    return true;
}

void SpOnRunCmd(int client, int& buttons)
{
    if (g_ForceJump[client] && IsPlayerAlive(client))
    {
        //  Force jump to make slap go further
        buttons |= IN_JUMP;

        //  Slaps!
        int slapcount = GetRandomInt(1,4);
        for(int i = 0; i <= slapcount; i++)
            SlapPlayer(client, 0, true);

        g_ForceJump[client] = false;
    }
}