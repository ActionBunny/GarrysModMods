// Command Menu Definition
// 
// "filename.res"
// {
//    "menuitem1"
//    {
//      "label"		"#GoToB"          // lable name shown in game, # = localized string
//      "command"	"echo hallo"      // a command string
//      "toggle"	"sv_cheats" 	  // a 0/1 toggle cvar 
//      "rule"		"map"             // visibility rules : "none", "team", "map","class"	
//      "ruledata"	"de_dust"	  // rule data, eg map name or team number
//    }
//   
//   "menuitem2"
//   {
//	...
//   }
//
//   ...
//
// }
//
//--------------------------------------------------------

"csimenu_4.res"
{
        "menuitem1"
        {
                "label"         "1"                   // name shown in game
                "command"       "csimenu4_1"          // command sent when button is pressed
                "custom"        "CSIMenu4_1"          // button background panel name
                "icon"          "CSIMenu4_1Icon"      // button icon panel name
        }
        "menuitem2"
        {
                "label"         "2"                   // name shown in game
                "command"       "csimenu4_2"          // command sent when button is pressed
                "custom"        "CSIMenu4_2"          // button background panel name
                "icon"          "CSIMenu4_2Icon"      // button icon panel name
        }
        "menuitem3"
        {
                "label"         "3"                   // name shown in game
                "command"       "csimenu4_3"          // command sent when button is pressed
                "custom"        "CSIMenu4_3"          // button background panel name
                "icon"          "CSIMenu4_3Icon"      // button icon panel name
        }
        "menuitem4"
        {
                "label"         "4"                   // name shown in game
                "command"       "csimenu4_4"          // command sent when button is pressed
                "custom"        "CSIMenu4_4"          // button background panel name
                "icon"          "CSIMenu4_4Icon"      // button icon panel name
        }
        "menuitem5"
        {
                "label"         "#Back"               // name shown in game
                "command"       "csimenu4back"        // command sent when button is pressed
                "custom"        "CSIMenu4_Center"     // button background panel name
                "icon"          "CSIMenu4_CenterIcon" // button icon panel name
        }
}
