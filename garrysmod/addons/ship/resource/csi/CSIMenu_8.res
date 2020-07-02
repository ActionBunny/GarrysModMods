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

"csimenu_8.res"
{
        "menuitem1"
        {
                "label"         "1"                   // name shown in game
                "command"       "csimenu8_1"          // command sent when button is pressed
                "custom"        "CSIMenu8_1"          // button background panel name
                "icon"          "CSIMenu8_1Icon"      // button icon panel name
        }
        "menuitem2"
        {
                "label"         "2"                   // name shown in game
                "command"       "csimenu8_2"          // command sent when button is pressed
                "custom"        "CSIMenu8_2"          // button background panel name
                "icon"          "CSIMenu8_2Icon"      // button icon panel name
        }
        "menuitem3"
        {
                "label"         "3"                   // name shown in game
                "command"       "csimenu8_3"          // command sent when button is pressed
                "custom"        "CSIMenu8_3"          // button background panel name
                "icon"          "CSIMenu8_3Icon"      // button icon panel name
        }
        "menuitem4"
        {
                "label"         "4"                   // name shown in game
                "command"       "csimenu8_4"          // command sent when button is pressed
                "custom"        "CSIMenu8_4"          // button background panel name
                "icon"          "CSIMenu8_4Icon"      // button icon panel name
        }
        "menuitem5"
        {
                "label"         "5"                   // name shown in game
                "command"       "csimenu8_5"          // command sent when button is pressed
                "custom"        "CSIMenu8_5"          // button background panel name
                "icon"          "CSIMenu8_5Icon"      // button icon panel name
        }
        "menuitem6"
        {
                "label"         "6"                   // name shown in game
                "command"       "csimenu8_6"          // command sent when button is pressed
                "custom"        "CSIMenu8_6"          // button background panel name
                "icon"          "CSIMenu8_6Icon"      // button icon panel name
        }
        "menuitem7"
        {
                "label"         "7"                   // name shown in game
                "command"       "csimenu8_7"          // command sent when button is pressed
                "custom"        "CSIMenu8_7"          // button background panel name
                "icon"          "CSIMenu8_7Icon"      // button icon panel name
        }
        "menuitem8"
        {
                "label"         "8"                   // name shown in game
                "command"       "csimenu8_8"          // command sent when button is pressed
                "custom"        "CSIMenu8_8"          // button background panel name
                "icon"          "CSIMenu8_8Icon"      // button icon panel name
        }
        "menuitem9"
        {
                "label"         "#Back"               // name shown in game
                "command"       "csimenu8back"        // command sent when button is pressed
                "custom"        "CSIMenu8_Center"     // button background panel name
                "icon"          "CSIMenu8_CenterIcon" // button icon panel name
        }
}
