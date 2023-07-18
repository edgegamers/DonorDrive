
#if defined _dd_included
	#endinput
#endif
#define _dd_included

#include <ripext>

methodmap Donation < JSONObject
{

    //  A unique identifier for this donation
    public bool GetDonationID(char[] buffer, int maxlen) {
        return this.GetString("donationID", buffer, maxlen);
    }

    public bool GetCreatedTimeUTC(char[] buffer, int maxlen) {
        return this.GetString("createdDateUTC", buffer, maxlen);
    }

    //  ======
    //  Amount
    //  May be hidden by donor.
    //  ======
    property bool HasAmount {   
        public get() { return this.HasKey("amount"); }
    }

    property float Amount {
        public get(){ return this.GetFloat("amount"); }
    }

    //  =======
    //  Team ID
    //  Present if a team was selected for this donation.
    //  Teams are arbitrary numbers--See https://github.com/DonorDrive/PublicAPI/blob/master/resources/teams.md
    //  =======
    property bool HasTeamID {   
        public get() { return this.HasKey("teamID"); }
    }

    property int TeamID {
        public get(){ return this.GetFloat("teamID"); }
    }

    //  ============
    //  Incentive ID
    //  Present if this donation has an incentive attached
    //  ============
    property bool HasIncentiveID {   
        public get() { return this.HasKey("incentiveID"); }
    }

    public bool GetIncentiveID(char[] buffer, int maxlen) {
        return this.GetString("incentiveID", buffer, maxlen);
    }

    //  Returns true if this is an incentive with id "incentiveid".
    public bool IncentiveIs(char[] incentiveid)
    {
        if (!this.HasIncentiveID)
            return false;

        char id[64];
        this.GetIncentiveID(id, sizeof(id));

        return StrEqual(id, incentiveid);
    }

    public bool IncentiveIsVar(ConVar cvar)
    {
        char id[64];
        cvar.GetString(id, sizeof(id));

        return this.IncentiveIs(id);
    }

    //  =======
    //  Message
    //  Donor-supplied message. May be hidden by donor.
    //  =======
    property bool HasMessage {   
        public get() { return this.HasKey("message"); }
    }

    public bool GetMessage(char[] buffer, int maxlen) {
        return this.GetString("message", buffer, maxlen);
    }

    //  ============
    //  Display name
    //  Donor-supplied name. Can be anonymous.
    //  ============
    property bool IsAnonymous {   
        public get() { return this.HasKey("displayName"); }
    }

    public bool GetName(char[] buffer, int maxlen) {
        return this.GetString("displayName", buffer, maxlen);
    }
}

public SharedPlugin __pl_donordrive = 
{
    name = "donordrive",
    file = "donordrive.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void__pl_donordrive_SetNTVOptional()
{
}
#endif