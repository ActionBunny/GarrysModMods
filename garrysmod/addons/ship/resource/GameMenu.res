"GameMenu"
{
	"1"
	{
		"label" "#GameUI_GameMenu_ResumeGame"
		"command" "ResumeGame"
		"OnlyInGame" "1"
	}
	"2"
	{
		"label"			"#GameUI_GameMenu_Disconnect"
		"command"		"Disconnect"
		"NotSingle"		"1"
		"OnlyInGame"	"1"
	}
	"3"
	{
		"label" "#GameUI_GameMenu_ArcadeMode"
		"command" "OpenCreateArcadeModeGameDialog"
		"disabled" "0"
		"NotInGame" "1"
		"NotSingle" "1"
	}
	"4"
	{
		"label" "#GameUI_GameMenu_CreateServer"
		"command" "OpenCreateMultiplayerGameDialog"
		"disabled" "0"
		"NotInGame" "1"
		"NotSingle" "1"
	}	
	"5"
	{
		"label" "#GameUI_GameMenu_JoinServer"
		"command" "OpenServerBrowser"
		"disabled" "0"
		"NotSingle" "1"
	}
	"6"
	{
		"label" "#GameUI_GameMenu_NewGame"
		"command" "OpenNewGameDialog"
		"notmulti" "1"
		"nottutorial" "1"
	}
	"7"
	{
		"label" "#GameUI_GameMenu_StartTutorial"
		"command" "StartTutorial"
		"tutorialonly"	"1"
	}
	"8"
	{
		"label" "#GameUI_GameMenu_LoadGame"
		"command" "OpenLoadGameDialog"
		"notmulti" "1"
		"nottutorial" "1"
	}
	"9"
	{
		"label" "#GameUI_GameMenu_Options"
		"command" "OpenOptionsDialog"
	}
	"10"
	{
		"label" "#GameUI_GameMenu_Credits"
		"command" "OpenCreateCreditsDialog"
		"NotInGame" "1"
	}
	"11"
	{
		"label" "#GameUI_GameMenu_Quit"
		"command" "Quit"
	}	
}

