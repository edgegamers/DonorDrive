
#include <sourcemod>
#include <cstrike>

#include <colorlib>
#include <donordrive>

public Plugin myinfo = {
    name = "DonorDrive Donor Log",
    author = "EdgeGamers Development",
    description = "Logs all donations received to the text chat",
    version = "1.0",
    url = "https://edgegamers.com/"
};

ConVar g_MinDonation;
ConVar g_GoldDonation;

public void OnPluginStart()
{
    g_MinDonation = CreateConVar("sm_dd_minimum", "10.0", "Minimum donation to be shown in chat");
    g_GoldDonation = CreateConVar("sm_dd_gold", "100.0", "Minimum donation to appear in gold")
}

public void OnDonation(Donation donation)
{
    //  Do not show if donation amount is private
    if (!donation.HasAmount)
        return;

    if (donation.Amount < g_MinDonation.FloatValue)
        return;

    //  Get the sender name
    char sender[32];
    if (!donation.GetName(sender, sizeof(sender)))
        strcopy(sender, sizeof(sender), "Anonymous");

    //  If the name goes off the end of the buffer,
    //  then we'll put ... at the end.
    //  Yes, this is awful.
    if (sender[sizeof(sender)-2] != '\0')
    {
        sender[sizeof(sender)-2] = '.';
        sender[sizeof(sender)-3] = '.';
        sender[sizeof(sender)-4] = '.';
    }

    if (donation.Amount < g_GoldDonation.FloatValue)
    {
        //  Normal donation.
        CPrintToChatTeam(CS_TEAM_SPECTATOR, "{lightgreen}[Donation] {default}%s{grey} donated {lightgreen}$%.2f!", sender, donation.Amount);
        return;
    }

    //  Gold donation!
    CPrintToChatTeam(CS_TEAM_SPECTATOR, "{gold}[Donation] {yellow}%s{gold} DONATED $%.2f!!!", sender, donation.Amount);
}