#include <csgo_colors>
#include <ripext>

public Plugin myinfo = 
{
	name = "[TK] Twitch Announcement", 
	description = "Оповещение о запущеном стриме", 
	author = "HenryTownshand", 
	version = "2.0.0", 
	url = "https://tkofficial.ru"
};

Handle g_hTimer;

char g_sUrl[256];

float g_fTimer;

int g_iCount = 0;

ArrayList g_sStreamerNames;

public void OnPluginStart()
{
	ConVar cvar;
	
	cvar = CreateConVar("sm_tw_url", "twitch.php", "Ссылка для запроса на файл twitch.php");
	cvar.AddChangeHook(CVarChange_Url);
	cvar.GetString(g_sUrl, sizeof(g_sUrl));
	
	cvar = CreateConVar("sm_tw_timer", "180.0", "Время между проверкой запущенного стрима", _, true, 1.0);
	cvar.AddChangeHook(CVarChange_Timer);
	g_fTimer = cvar.FloatValue;
	
	g_sStreamerNames = CreateArray(1024);
	ParseStreamNames();
	
	if (!StrEqual(g_sUrl, "#empty") && !StrEqual(g_sUrl, ""))
	{
		g_hTimer = CreateTimer(g_fTimer, TwitchAnnouncement, TIMER_DATA_HNDL_CLOSE);
		PrintToServer("[TA] [INFO] Ссылка на API: %s\n[TA] [INFO] Время таймера: %f", g_sUrl, g_fTimer);
	} else {
		PrintToServer("[TA] [ERROR] Ссылка на API пустая");
	}
	
	AutoExecConfig(true, "TK_TwitchAnnouncement");
}

/*public void OnMapEnd()
{
	if (g_hTimer)
	{
		KillTimer(g_hTimer);
	}
}*/

public void CVarChange_Url(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	cvar.GetString(g_sUrl, sizeof(g_sUrl));
	if (!StrEqual(g_sUrl, "#empty") && !StrEqual(g_sUrl, ""))
	{
		if (g_hTimer)
		{
			KillTimer(g_hTimer);
			g_hTimer = CreateTimer(g_fTimer, TwitchAnnouncement, TIMER_DATA_HNDL_CLOSE);
		}
		PrintToServer("[TA] [INFO] Ссылка на API изменилась\n%s", g_sUrl);
	} else {
		PrintToServer("[TA] [ERROR] Ссылка на API пустая");
	}
}

public void CVarChange_Timer(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	g_fTimer = cvar.FloatValue;
	if (g_hTimer)
	{
		KillTimer(g_hTimer);
		g_hTimer = CreateTimer(g_fTimer, TwitchAnnouncement, TIMER_DATA_HNDL_CLOSE);
	}
	PrintToServer("[TA] [INFO] Время таймера изменилось на %f", g_fTimer);
}

void ParseStreamNames() {
	File hFile = OpenFile("addons/sourcemod/data/streamers.txt", "r");
	
	if ((hFile == null)) {
		return;
	}
	
	char sLine[1024];
	while (hFile.ReadLine(sLine, sizeof(sLine)) && !hFile.EndOfFile()) {
		if (StrContains(sLine, "//") != -1) {
			SplitString(sLine, "//", sLine, sizeof(sLine));
		}
		
		TrimString(sLine);
		
		g_sStreamerNames.PushString(sLine);
	}
	g_iCount = g_sStreamerNames.Length - 1;
	
	delete hFile;
}

public Action TwitchAnnouncement(Handle hTimer)
{
	char sName[128];
	char szBuffer[128];
	if (g_iCount < 0)
	{
		g_iCount = g_sStreamerNames.Length - 1;
		g_hTimer = CreateTimer(0.1, TwitchAnnouncement, TIMER_DATA_HNDL_CLOSE);
	} else {
		g_sStreamerNames.GetString((g_sStreamerNames.Length - g_iCount - 1), sName, 128);
		Format(szBuffer, sizeof(szBuffer), "%s?id=%s", g_sUrl, sName);
		HTTPRequest hRequest = new HTTPRequest(szBuffer);
		hRequest.Get(OnOnlReceived);
	}
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
	//PrintToServer("Count = %i, Length = %i", g_iCount, g_sStreamerNames.Length);
	g_iCount--;
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
		g_hTimer = CreateTimer(g_fTimer, TwitchAnnouncement, TIMER_DATA_HNDL_CLOSE);
	} else {
		g_hTimer = CreateTimer(0.1, TwitchAnnouncement, TIMER_DATA_HNDL_CLOSE);
	}
} 