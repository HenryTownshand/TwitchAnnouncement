#include <csgo_colors>
#include <ripext>

public Plugin myinfo = 
{
	name = "Twitch Announcement", 
	description = "Twitch Announcement", 
	author = "HenryTownshand", 
	version = "1.0.0", 
	url = "https://tkofficial.ru"
};

char g_iUrl[256] = "<Ссылка на index.php>";

public void OnPluginStart()
{
	CreateTimer(180.0, TwitchAnnouncement, _, TIMER_REPEAT);
}

public Action TwitchAnnouncement(Handle timer)
{
	char iType[128];
	HTTPClient request = new HTTPClient(g_iUrl);
	request.Get(iType, OnOnlReceived);
	return Plugin_Continue;
}


public void OnOnlReceived(HTTPResponse response, any value)
{
	char sGameName[128];
	char sNickName[32];
	char sLogin[32];
	int iViewerCount;
	if (response.Status != HTTPStatus_OK) {
		PrintToServer("UNSUCCESSFULL REQUEST");
		return;
	}
	
	JSONObject data = view_as<JSONObject>(response.Data);
	data.GetString("game_name", sGameName, sizeof(sGameName));
	data.GetString("user_name", sNickName, sizeof(sNickName));
	data.GetString("user_login", sLogin, sizeof(sLogin));
	iViewerCount = data.GetInt("viewer_count");
	
	if (!StrEqual(sGameName, " ", true))
	{
		CGOPrintToChatAll("================== {LIGHTBLUE}ИНФОРМАЦИЯ {DEFAULT}================== ");
		CGOPrintToChatAll("{GREEN}✷ {DEFAULT}Ура, {LIGHTRED}%s {DEFAULT}снова стримит", sNickName);
		CGOPrintToChatAll("{GREEN}✷ {DEFAULT}Заходим все на стрим!");
		CGOPrintToChatAll("{GREEN}✷ {LIGHTPURPLE}Twitch{DEFAULT}: {DEFAULT}https://www.twitch.tv/%s", sNickName);
		CGOPrintToChatAll("{GREEN}✷ {BLUE}Игра{DEFAULT}: %s", sGameName);
		CGOPrintToChatAll("{GREEN}✷ {RED}Зрителей{DEFAULT}: %i", iViewerCount);
		CGOPrintToChatAll("================== {LIGHTBLUE}ИНФОРМАЦИЯ {DEFAULT}================== ");
	}
} 
