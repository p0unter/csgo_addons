#pragma semicolon 1
#include <sourcemod>
#include <admin>

public Plugin myinfo = {
    name = "Online Staff",
    author = "pounter",
    description = "Learn active staff(admins)",
    version = "1.0",
    url = "https://trycatch.network"
};

public void OnPluginStart() {
    RegConsoleCmd("sm_admins", Command_ShowFlags, "Shows client flags in a popup");
}

public Action Command_ShowFlags(int client, int args) {
    if (client == 0) {
        ReplyToCommand(client, "This command can only be used in-game");
        return Plugin_Handled;
    }
    
    ShowMainMenu(client);
    return Plugin_Handled;
}

void ShowMainMenu(int client) {
    Menu menu = new Menu(MenuHandler_Main);
    menu.SetTitle("Client Admin Flags");
    
    for (int i = 1; i <= MaxClients; i++) {
        if (!IsClientInGame(i) || IsFakeClient(i)) continue;
        
        char name[MAX_NAME_LENGTH];
        GetClientName(i, name, sizeof(name));
        
        char info[16];
        IntToString(i, info, sizeof(info));
        
        char display[MAX_NAME_LENGTH + 16];
        if (GetUserAdmin(i) != INVALID_ADMIN_ID) {
            Format(display, sizeof(display), "%s \x04[ADMIN]", name);
        } else {
            strcopy(display, sizeof(display), name);
        }
        
        menu.AddItem(info, display);
    }
    
    if (!menu.ItemCount) {
        menu.AddItem("", "No players found", ITEMDRAW_DISABLED);
    }
    
    menu.ExitButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Main(Menu menu, MenuAction action, int client, int param2) {
    if (action == MenuAction_Select) {
        char info[32];
        menu.GetItem(param2, info, sizeof(info));
        
        int target = StringToInt(info);
        if (IsClientInGame(target)) {
            ShowClientDetails(client, target);
        } else {
            PrintToChat(client, "[\x04FlagPopup\x01] Player is no longer available");
            ShowMainMenu(client);
        }
    } else if (action == MenuAction_End) {
        delete menu;
    }
    return 0;
}

void ShowClientDetails(int client, int target) {
    char name[MAX_NAME_LENGTH];
    char steamId[32];
    char flags[32] = "NONE";
    
    GetClientName(target, name, sizeof(name));
    
    // Get SteamID
    if (GetClientAuthId(target, AuthId_Steam2, steamId, sizeof(steamId), false)) {
        // Success
    } else {
        strcopy(steamId, sizeof(steamId), "Unknown");
    }
    
    // Alternative method to get admin flags
    AdminId admin = GetUserAdmin(target);
    if (admin != INVALID_ADMIN_ID) {
        int flagBits = GetAdminFlags(admin, Access_Effective);
        flags[0] = '\0'; // Clear the string
        
        // Build flags string manually
        if (flagBits & ADMFLAG_RESERVATION) StrCat(flags, sizeof(flags), "a");
        if (flagBits & ADMFLAG_GENERIC) StrCat(flags, sizeof(flags), "b");
        if (flagBits & ADMFLAG_KICK) StrCat(flags, sizeof(flags), "c");
        if (flagBits & ADMFLAG_BAN) StrCat(flags, sizeof(flags), "d");
        if (flagBits & ADMFLAG_UNBAN) StrCat(flags, sizeof(flags), "e");
        if (flagBits & ADMFLAG_SLAY) StrCat(flags, sizeof(flags), "f");
        if (flagBits & ADMFLAG_CHANGEMAP) StrCat(flags, sizeof(flags), "g");
        if (flagBits & ADMFLAG_CONVARS) StrCat(flags, sizeof(flags), "h");
        if (flagBits & ADMFLAG_CONFIG) StrCat(flags, sizeof(flags), "i");
        if (flagBits & ADMFLAG_CHAT) StrCat(flags, sizeof(flags), "j");
        if (flagBits & ADMFLAG_VOTE) StrCat(flags, sizeof(flags), "k");
        if (flagBits & ADMFLAG_PASSWORD) StrCat(flags, sizeof(flags), "l");
        if (flagBits & ADMFLAG_RCON) StrCat(flags, sizeof(flags), "m");
        if (flagBits & ADMFLAG_ROOT) StrCat(flags, sizeof(flags), "z");
        
        // If no flags were added, set to "NONE"
        if (StrEqual(flags, "")) {
            strcopy(flags, sizeof(flags), "NONE");
        }
    }
    
    Menu menu = new Menu(MenuHandler_Details);
    menu.SetTitle("Client Details\n \nName: %s\nSteamID: %s\nFlags: %s", name, steamId, flags);
    
    // Flag legend
    menu.AddItem("", "Flag Legend:", ITEMDRAW_DISABLED);
    menu.AddItem("", "a=reserve, b=generic, c=kick", ITEMDRAW_DISABLED);
    menu.AddItem("", "d=ban, e=unban, f=slay, g=map", ITEMDRAW_DISABLED);
    menu.AddItem("", "h=cvars, i=config, j=chat, k=vote", ITEMDRAW_DISABLED);
    menu.AddItem("", "l=password, m=rcon, z=root", ITEMDRAW_DISABLED);
    
    menu.AddItem("back", "Back to Player List");
    menu.ExitButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Details(Menu menu, MenuAction action, int client, int param2) {
    if (action == MenuAction_Select) {
        char info[32];
        menu.GetItem(param2, info, sizeof(info));
        
        if (StrEqual(info, "back")) {
            ShowMainMenu(client);
        }
    } else if (action == MenuAction_End) {
        delete menu;
    }
    return 0;
}