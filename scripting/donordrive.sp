
//  DonorDrive Incentives API
//  Docs:       https://github.com/DonorDrive/PublicAPI/tree/master
//  Requires:   https://github.com/ErikMinekus/sm-ripext

#include <sourcemod>
#include <functions>

#include <colorlib>
#include <ripext>
#include <donordrive>

public Plugin myinfo = {
    name = "DonorDrive",
    author = "EdgeGamers Development",
    description = "DonorDrive Incentives & Donations Feed API",
    version = "1.0",
    url = "https://edgegamers.com/"
};

bool g_EnableForward;
ConVar g_DonationFeedURL;
StringMap g_HandledDonations;

GlobalForward g_OnDonation;

//  Entity tag used for caching.
//  304 responses are sent when the request has not changed it's entity ID.
char g_EntityTag[256];

public void OnPluginStart()
{
    RegAdminCmd("sm_dd_reset", CommandReset, ADMFLAG_RCON, "Wipes the internal entity cache, and replays donations.");
    g_DonationFeedURL = CreateConVar("sm_dd_apiurl", "https://lanfest.donordrive.com/api/events/575/donations", "API endpoint to get all donations for an event");
    g_HandledDonations = new StringMap();

    //  Disable forwards for the first DD api fetch
    g_EnableForward = false;

    //  public void OnDonation(Donation donation);
    g_OnDonation = new GlobalForward("OnDonation", ET_Ignore, Param_Cell);

    //  Before anything else, pull donations to get all donations that happened
    //  before the plugin started out of the way.
    TimerPullDonations( view_as<Handle>(0) );

    //  Timer to pull data from DonorDrive
    CreateTimer(5.0, TimerPullDonations, 0, TIMER_REPEAT);

    g_EnableForward = true;
}

public Action CommandReset(int client, int args)
{
    g_EntityTag[0] = '\0';
    g_HandledDonations.Clear();

    CPrintToChatAdmins( ADMFLAG_RCON, "{red}[DonorDrive] Reset entity cache");

    return Plugin_Handled;
}

//  Inform SourceMod that we are, in fact, present.
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    RegPluginLibrary("donordrive");
 
    return APLRes_Success;
}

public Action TimerPullDonations(Handle timer)
{
    //  Construct API request from endpoint convar
    char endpoint[256];
    g_DonationFeedURL.GetString(endpoint, sizeof(endpoint));
    HTTPRequest request = new HTTPRequest(endpoint);

    //  If we have an entity tag, then use it to improve caching
    if (g_EntityTag[0] != '\0')
        request.SetHeader("If-None-Match", g_EntityTag);

    request.SetHeader("User-Agent","SourceMod DonorDrive API 1.0 - LIVE - twitch.tv/lanfest")

    PrintToServer("[DonorDrive] Pulling donations.... '%s'", endpoint)


    //  Send request
    request.Get(OnDonorDriveResponse);

    return Plugin_Continue;
}

//  Invoked when the HTTPRequest sent in Timer_PullDonations completes.
public void OnDonorDriveResponse(HTTPResponse result, any value, const char[] error)
{
    if (result.Status >= 400 || result.Status == HTTPStatus_Invalid)
    {
        PrintToServer("[DonorDrive] Error getting donations list (status %d): %s", result.Status, error);
        CPrintToChatAdmins( ADMFLAG_RCON, "{red}[DonorDrive] Error on donation feed (status %d): %s", result.Status, error);
        return;
    }

    PrintToServer("Got status code %d", result.Status);

    if (result.Status == HTTPStatus_NotModified)
    {
        //  304 not-changed    
        //  This means the etag is still up to date.
        return;
    }

    //  Update entity tag if the value has changed
    result.GetHeader("ETag", g_EntityTag, sizeof(g_EntityTag))
    
    JSONArray response = view_as<JSONArray>(result.Data);
    ArrayStack new_donations = new ArrayStack();

    //  Error counts
    int error_count = 0;
    int error_count_nodid = 0;

    for(int i = 0; i < response.Length; i++)
    {
        Donation donation = response.Get(i);
        char id[64];

        if (!donation.GetDonationID(id, sizeof(id)))
        {
            error_count++;
            error_count_nodid++;
            continue;
        }

        //  Key is not set on the global trie
        any unused;
        if (!g_HandledDonations.GetValue(id, unused))
        {
            new_donations.Push(donation);
        }

        //  Mark the donation as handled
        g_HandledDonations.SetValue(id, true);
    }

    delete response;

    //  When the plugin first loads,
    //  we pull from DD to get all donations
    //  However, we do not want this passed on to other plugins.
    int count = -1;
    if (g_EnableForward)
        count = StackInvoke(g_OnDonation, new_donations, true);

    if (error_count != 0)
    {
        PrintToServer("[DonorDrive] Errors (%d): %d NO DONATION ID;", error_count, error_count_nodid);
        CPrintToChatAdmins(ADMFLAG_RCON, "{red}[DonorDrive] Errors (%d): %d NO DONATION ID;", error_count, error_count_nodid);
    }

    delete new_donations;
    
    PrintToServer("[DonorDrive] Finished with %d new donations", count);
}

//  Invoke a specified forward with a list of values.
//  Each value is passed as the only argument.
//  Supports handles when 3rd arg (close) is passed as "true".
static int StackInvoke(Handle func, ArrayStack invocation_values, bool close = false)
{
    int count;
    //  Pop all new donations and call their global forwards
    while (!invocation_values.Empty)
    {
        any next = invocation_values.Pop();

        Call_StartForward(func);
        Call_PushCell(next);
        Call_Finish();

        //  We have also been requested to close the handle once done.
        if (close)
            CloseHandle(next);

        count++;
    }

    return count;
}