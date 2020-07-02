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

"csimenu_7.res"
{
        "menuitem1"
        {
                "label"         "1"                   // name shown in game
                "command"       "csimenu7_1"          // command sent when button is pressed
                "custom"        "CSIMenu7_1"          // button background panel name
                "icon"          "CSIMenu7_1Icon"      // button icon panel name
        }
        "menuitem2"
        {
                "label"         "2"                   // name shown in game
                "command"       "csimenu7_2"          // command sent when button is pressed
                "custom"        "CSIMenu7_2"          // button background panel name
                "icon"          "CSIMenu7_2Icon"      // button icon panel name
        }
        "menuitem3"
        {
                "label"         "3"                   // name shown in game
                "command"       "csimenu7_3"          // command sent when button is pressed
                "custom"        "CSIMenu7_3"          // button background panel name
                "icon"          "CSIMenu7_3Icon"      // button icon panel name
        }
        "menuitem4"
        {
                "label"         "4"                   // name shown in game
                "command"       "csimenu7_4"          // command sent when button is pressed
                "custom"        "CSIMenu7_4"          // button background panel name
                "icon"          "CSIMenu7_4Icon"      // button icon panel name
        }
        "menuitem5"
        {
                "label"         "5"                   // name shown in game
                "command"       "csimenu7_5"          // command sent when button is pressed
                "custom"        "CSIMenu7_5"          // button background panel name
                "icon"          "CSIMenu7_5Icon"      // button icon panel name
        }
        "menuitem6"
        {
                "label"         "6"                   // name shown in game
                "command"       "csimenu7_6"          // command sent when button is pressed
                "custom"        "CSIMenu7_6"          // button background panel name
                "icon"          "CSIMenu7_6Icon"      // button icon panel name
        }
        "menuitem7"
        {
                "label"         "7"                   // name shown in game
                "command"       "csimenu7_7"          // command sent when button is pressed
                "custom"        "CSIMenu7_7"          // button background panel name
                "icon"          "CSIMenu7_7Icon"      // button icon panel name
        }
        "menuitem8"
        {
                "label"         "#Back"               // name shown in game
                "command"       "csimenu7back"        // command sent when button is pressed
                "custom"        "CSIMenu7_Center"     // button background panel name
                "icon"          "CSIMenu7_CenterIcon" // button icon panel name
        }
}
