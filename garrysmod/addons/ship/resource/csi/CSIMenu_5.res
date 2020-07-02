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

"csimenu_5.res"
{
        "menuitem1"
        {
                "label"         "1"                   // name shown in game
                "command"       "csimenu5_1"          // command sent when button is pressed
                "custom"        "CSIMenu5_1"          // button background panel name
                "icon"          "CSIMenu5_1Icon"      // button icon panel name
        }
        "menuitem2"
        {
                "label"         "2"                   // name shown in game
                "command"       "csimenu5_2"          // command sent when button is pressed
                "custom"        "CSIMenu5_2"          // button background panel name
                "icon"          "CSIMenu5_2Icon"      // button icon panel name
        }
        "menuitem3"
        {
                "label"         "3"                   // name shown in game
                "command"       "csimenu5_3"          // command sent when button is pressed
                "custom"        "CSIMenu5_3"          // button background panel name
                "icon"          "CSIMenu5_3Icon"      // button icon panel name
        }
        "menuitem4"
        {
                "label"         "4"                   // name shown in game
                "command"       "csimenu5_4"          // command sent when button is pressed
                "custom"        "CSIMenu5_4"          // button background panel name
                "icon"          "CSIMenu5_4Icon"      // button icon panel name
        }
        "menuitem5"
        {
                "label"         "5"                   // name shown in game
                "command"       "csimenu5_5"          // command sent when button is pressed
                "custom"        "CSIMenu5_5"          // button background panel name
                "icon"          "CSIMenu5_5Icon"      // button icon panel name
        }
        "menuitem6"
        {
                "label"         "#Back"               // name shown in game
                "command"       "csimenu5back"        // command sent when button is pressed
                "custom"        "CSIMenu5_Center"     // button background panel name
                "icon"          "CSIMenu5_CenterIcon" // button icon panel name
        }
}
