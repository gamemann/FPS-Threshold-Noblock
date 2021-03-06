#include <sourcemod>
#include <fps-threshold>

#define MAXSTORE 256

public Plugin myinfo =
{
    name = "FPS Threshold - Forces Noblock",
    author = "Roy (Christian Deacon)",
    description = "Forces noblock after average FPS goes under a certain threshold via FPS Threshold plugin.",
    version = "1.0.0",
    url = "https://github.com/gamemann"
};

int g_collisionoff;
bool g_insequence = false;

ConVar g_cvNoblockTime = null;
ConVar g_cvNotify = null;
ConVar g_cvDebug = null;

public void OnPluginStart()
{
    g_cvNoblockTime = CreateConVar("sm_nol_time", "5", "How long to force noblock on all players for.");
    g_cvNotify = CreateConVar("sm_nol_notify", "1", "Print to chat all when the server is lagging.");
    g_cvDebug = CreateConVar("sm_nol_debug", "0", "Debug calculations or not.");

    g_collisionoff = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");

    if (g_collisionoff == -1)
    {
        SetFailState("Could not find offset for => CBaseEntity::m_CollisionGroup. Plugin failed.");
    }
}

public Action Timer_Block(Handle timer)
{
    g_insequence = false;

    ForceCollision(true);
}

public void OnDetect(int avgfps)
{
    if  (g_insequence)
    {
        return;
    }
    
    if (g_cvNotify.BoolValue)
    {
        PrintToChatAll("[NOL] Forcing noblock on all players.");
    }

    if (g_cvDebug.BoolValue)
    {
        PrintToServer("[NOL] Server FPS threshold exceeded. Average server FPS => %d", avgfps);
    }

    g_insequence = true;

    ForceCollision(false);

    CreateTimer(g_cvNoblockTime.FloatValue, Timer_Block, _, TIMER_FLAG_NO_MAPCHANGE);
}

stock void ForceCollision(bool block)
{   
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsValidEntity(i))
        {
            continue;
        }

        if (block)
        {
            SetEntData(i, g_collisionoff, 5, 4, true);
        }
        else
        {
            SetEntData(i, g_collisionoff, 2, 4, true);
        }
    }
}