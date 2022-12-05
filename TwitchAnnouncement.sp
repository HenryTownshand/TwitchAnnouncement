#include <csgo_colors>
#include <ripext>

public Plugin myinfo = 
{
	name = "[TK] Twitch Announcement", 
	description = "Оповещение о запущеном стриме", 
	author = "HenryTownshand", 
	version = "1.0.1", 
	url = "https://tkofficial.ru"
};

Handle g_hTimer;

char g_sUrl[256];

float g_fTimer;

public void OnPluginStart()
{
	ConVar cvar;
	
	cvar = CreateConVar("sm_tw_url", "", "Ссылка для запроса на файл twitch.php");
	cvar.AddChangeHook(CVarChange_Url);
	cvar.GetString(g_sUrl, sizeof(g_sUrl));
	
	cvar = CreateConVar("sm_tw_timer", "180.0", "Время между проверкой запущенного стрима", _, true, 1.0);
	cvar.AddChangeHook(CVarChange_Timer);
	g_fTimer = cvar.FloatValue;
	
	if(!StrEqual(g_sUrl, "#empty") && !StrEqual(g_sUrl, ""))
	{
		g_hTimer = CreateTimer(g_fTimer, TwitchAnnouncement);
		PrintToServer("[TA] [INFO] Ссылка на API: %s\n[TA] [INFO] Время таймера: %f", g_sUrl, g_fTimer);
	}else{
		PrintToServer("[TA] [ERROR] Ссылка на API пустая");
	}
	
	AutoExecConfig(true, "TK_TwitchAnnouncement");
}

public void OnMapEnd()
{
	if(g_hTimer)
	{
	    KillTimer(g_hTimer);
	}
}

public void CVarChange_Url(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	cvar.GetString(g_sUrl, sizeof(g_sUrl));
	if(!StrEqual(g_sUrl, "#empty") && !StrEqual(g_sUrl, ""))
	{
		if(g_hTimer)
		{
		    KillTimer(g_hTimer);
		    g_hTimer = CreateTimer(g_fTimer, TwitchAnnouncement);
		}
		PrintToServer("[TA] [INFO] Ссылка на API изменилась\n%s", g_sUrl);
	}else{
		PrintToServer("[TA] [ERROR] Ссылка на API пустая");
	}
}

public void CVarChange_Timer(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	g_fTimer = cvar.FloatValue;
	if(g_hTimer)
	{
	    KillTimer(g_hTimer);
	    g_hTimer = CreateTimer(g_fTimer, TwitchAnnouncement);
	}
	PrintToServer("[TA] [INFO] Время таймера изменилось на %f", g_fTimer);
}

public Action TwitchAnnouncement(Handle timer)
{
	HTTPRequest request = new HTTPRequest(g_sUrl);
	request.Get(OnOnlReceived);
	return Plugin_Continue;
}

public void OnOnlReceived(HTTPResponse response, any value)
{
	char sGameName[128], sNickName[32], sLogin[32];
	int iViewerCount;
	if (response.Status != HTTPStatus_OK) {
		PrintToServer("[TA] [ERROR] Неудачный запрос. Проверьте правильность и доступность ссылки на API.");
		return;
	}
	
	JSONObject data = view_as<JSONObject>(response.Data);
	data.GetString("user_login", sLogin, sizeof(sLogin));
	if (!StrEqual(sLogin, " ", true))
	{
		data.GetString("game_name", sGameName, sizeof(sGameName));
		data.GetString("user_name", sNickName, sizeof(sNickName));
		iViewerCount = data.GetInt("viewer_count");
		
		CGOPrintToChatAll("================== {LIGHTBLUE}TWITCH {DEFAULT}================== ");
		CGOPrintToChatAll("{GREEN}✷ {DEFAULT}Ура, {LIGHTRED}%s {DEFAULT}снова стримит", sNickName);
		CGOPrintToChatAll("{GREEN}✷ {DEFAULT}Заходим все на стрим!");
		CGOPrintToChatAll("{GREEN}✷ {LIGHTPURPLE}Twitch{DEFAULT}: {DEFAULT}https://www.twitch.tv/%s", sNickName);
		CGOPrintToChatAll("{GREEN}✷ {BLUE}Игра{DEFAULT}: %s", sGameName);
		CGOPrintToChatAll("{GREEN}✷ {RED}Зрителей{DEFAULT}: %i", iViewerCount);
		CGOPrintToChatAll("================== {LIGHTBLUE}TWITCH {DEFAULT}================== ");
	}
	g_hTimer = CreateTimer(g_fTimer, TwitchAnnouncement);
} 