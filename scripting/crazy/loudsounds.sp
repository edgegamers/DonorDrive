static char s_Sounds[][] = {
    "physics/metal/metal_vent_impact_01.wav",
    "physics/glass/glass_largesheet_break2.wav",
    "physics/glass/glass_sheet_break3.wav",
    "physics/concrete/boulder_impact_hard4.wav",
    "ambient/misc/brass_bell_e.wav",
    "survival/barrel_fall_03.wav",
    "ambient/misc/flush1.wav",
}

static char s_SoundMessages[][] = {
    "fell",
    "broke a window",
    "broke a window",
    "smashed through a wall",
    "bumped their head on a bell",
    "knocked over a barrel",
    "flushed the toilet"
}

//  Shamelessly stolen from MyJB
static int g_ExplosionSprite = -1;

void LsPrecache()
{
    g_ExplosionSprite = PrecacheModel("sprites/sprite_fire01.vmt");

    for(int i = 0; i < sizeof(s_Sounds); i++)
        PrecacheSound(s_Sounds[i], true);
}

bool LsRandomPlayerOnTeam(Get5Team team)
{
    int client = GetRandomPlayer(team);

    if (client == -1)
        return false;
    
    int random = GetRandomInt(0, sizeof(s_Sounds) - 1);

    float vec[3];
    GetClientEyePosition(client, vec);

    PrintToServer("Playing sound %s [Precached? %d] at %f %f %f for %N", s_Sounds[random], IsSoundPrecached(s_Sounds[random]), vec[0], vec[1], vec[2], client);

    EmitAmbientSound(s_Sounds[random], vec, client, 130);

    //  Set up a particle to happen at their location
    TE_SetupExplosion(vec, g_ExplosionSprite, 0.05, 1, 0, 1, 1);
    TE_SendToAll();
    
    CPrintToChatAll(CRAZY_PREFIX ... "%N {lime}%s{default}!", client, s_SoundMessages[random]);

    return true;
}