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

"csimenu_6.res"
{
        "menuitem1"
        {
                "label"         "1"                   // name shown in game
                "command"       "csimenu6_1"          // command sent when button is pressed
                "custom"        "CSIMenu6_1"          // button background panel name
                "icon"          "CSIMenu6_1Icon"      // button icon panel name
        }
        "menuitem2"
        {
                "label"         "2"                   // name shown in game
                "command"       "csimenu6_2"          // command sent when button is pressed
                "custom"        "CSIMenu6_2"          // button background panel name
                "icon"          "CSIMenu6_2Icon"      // button icon panel name
        }
        "menuitem3"
        {
                "label"         "3"                   // name shown in game
                "command"       "csimenu6_3"          // command sent when button is pressed
                "custom"        "CSIMenu6_3"          // button background panel name
                "icon"          "CSIMenu6_3Icon"      // button icon panel name
        }
        "menuitem4"
        {
                "label"         "4"                   // name shown in game
                "command"       "csimenu6_4"          // command sent when button is pressed
                "custom"        "CSIMenu6_4"          // button background panel name
                "icon"          "CSIMenu6_4Icon"      // button icon panel name
        }
        "menuitem5"
        {
                "label"         "5"                   // name shown in game
                "command"       "csimenu6_5"          // command sent when button is pressed
                "custom"        "CSIMenu6_5"          // button background panel name
                "icon"          "CSIMenu6_5Icon"      // button icon panel name
        }
        "menuitem6"
        {
                "label"         "6"                   // name shown in game
                "command"       "csimenu6_6"          // command sent when button is pressed
                "custom"        "CSIMenu6_6"          // button background panel name
                "icon"          "CSIMenu6_6Icon"      // button icon panel name
        }
        "menuitem7"
        {
                "label"         "#Back"               // name shown in game
                "command"       "csimenu6back"        // command sent when button is pressed
                "custom"        "CSIMenu6_Center"     // button background panel name
                "icon"          "CSIMenu6_CenterIcon" // button icon panel name
        }
}
