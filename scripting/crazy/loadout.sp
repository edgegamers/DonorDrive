
static char s_PrimaryIds[][] = {
    "weapon_aug",

    //  Awp: 3x chance
    "weapon_awp",
    "weapon_awp",
    "weapon_awp",

    "weapon_ak47",
    "weapon_bizon",
    "weapon_famas",
    "weapon_g3sg1",
    "weapon_galilar",
    "weapon_m249",
    "weapon_m4a1",
    "weapon_m4a1_silencer",
    "weapon_mac10",
    "weapon_mag7",
    "weapon_mp5sd",
    "weapon_mp7",
    "weapon_mp9",

    //  Negev: 3x chance
    "weapon_negev",
    "weapon_negev",
    "weapon_negev",

    "weapon_nova",
    "weapon_p90",
    "weapon_sawedoff",
    "weapon_scar20",
    "weapon_sg556",
    "weapon_ssg08",
    "weapon_ump45",
    "weapon_xm1014"
};

static char s_SecondaryIds[][] = {
    "weapon_cz75a",

    //  Deagle: 2x chance
    "weapon_deagle",
    "weapon_deagle",

    "weapon_glock",
    "weapon_fiveseven",

    //  Duelies: 2x chance
    "weapon_elite",
    "weapon_elite",

    "weapon_p250",
    "weapon_hkp2000",
    "weapon_tec9",

    //  Revolver: 2x chance
    "weapon_revolver",
    "weapon_revolver",

    "weapon_usp_silencer",
};

static char s_MeleeIds[][] = {

    //  Throwables
    //  Removed due to issues
    //  "weapon_axe",
    //  "weapon_hammer",
    //  "weapon_spanner",
    //  "weapon_melee",

    //  Fists: 2x chance
    //  Also has issues :-(
    //  "weapon_fists",
    //  "weapon_fists",

    "weapon_knife",
    "weapon_knife_t",
    "weapon_knifegg",
};

static char s_UtilIds[][] = {
    "weapon_incgrenade",
    "weapon_molotov",
    "weapon_decoy",
    "weapon_flashbang",
    "weapon_healthshot",
    "weapon_smokegrenade",
    "weapon_snowball",
}

static char s_BuffIds[][] = {
    //  Satchel grenades
    "weapon_breachcharge",

    //  God shield
    "weapon_shield",

    //  Tactical awareness grenade
    "weapon_tagrenade",

    //  Bumpmine
    "weapon_bumpmine",
}

static int s_Slots[] = {
    CS_SLOT_BOOST,
    //  Never strip C4
    //  CS_SLOT_C4,
    CS_SLOT_GRENADE,
    CS_SLOT_KNIFE,
    CS_SLOT_PRIMARY,
    CS_SLOT_SECONDARY,
    CS_SLOT_UTILITY,
}

void LdEmptySlot(int client, int slot)
{
    for (int i = 0; i <= 10; i++)
    {
        int contents = GetPlayerWeaponSlot(client, slot);

        if (!IsValidEntity(contents))
            return;

        bool success = RemovePlayerItem(client, contents)
		AcceptEntityInput(contents, "Kill")
    }
}

static int LdGiveRandom(int client, char[][] ids, int idcount)
{
    int random = GetRandomInt(0, idcount - 1);
    int weapon = GivePlayerItem(client, ids[random]);

    //  Extra handling for shields
    if (StrEqual(ids[random], "weapon_shield"))
    {
        if (FindEntityByClassname(-1, "func_hostage_rescue") == -1)
            CreateEntityByName("func_hostage_rescue"); // Allow players to pickup shields
        
        EquipPlayerWeapon(client, weapon);
    }
    
    return weapon;
}

void LdStripPlayer(int client)
{
    for(int i = 0; i < sizeof(s_Slots); i++)
        LdEmptySlot(client, s_Slots[i])
}

bool LdRandomPlayerOnTeam(Get5Team team)
{
    int client = GetRandomPlayer(team);

    if (client == -1)
        return false;

    CPrintToChatAll(CRAZY_PREFIX ... "%N had their loadout {red}scrambled{default}!", client);
    PrintCenterText(client, "Your inventory was scrambled!");

    LdStripPlayer(client);

    LdGiveRandom(client, s_PrimaryIds, sizeof(s_PrimaryIds));
    LdGiveRandom(client, s_SecondaryIds, sizeof(s_SecondaryIds));
    LdGiveRandom(client, s_MeleeIds, sizeof(s_MeleeIds));

    int utilcount = GetRandomInt(0,4);
    for(int i = 0; i <= utilcount; i++)
        LdGiveRandom(client, s_UtilIds, sizeof(s_UtilIds));

    return true;
}

bool LdBuffRandomPlayerOnTeam(Get5Team team)
{
    int client = GetRandomPlayer(team);

    if (client == -1)
        return false;

    CPrintToChatAll(CRAZY_PREFIX ... "%N had their loadout {darkred}buffed{default}!", client);
    PrintCenterText(client, "You were given a random overpowered item!");

    //  Give a random util
    LdGiveRandom(client, s_UtilIds, sizeof(s_UtilIds));
    LdGiveRandom(client, s_BuffIds, sizeof(s_BuffIds));

    return true;
}