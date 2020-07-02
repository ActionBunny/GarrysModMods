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

"csimenu_1.res"
{
        "menuitem1"
        {
                "label"         "1"                   // name shown in game
                "command"       "csimenu1_1"          // command sent when button is pressed
                "custom"        "CSIMenu1_1"          // button background panel name
                "icon"          "CSIMenu1_1Icon"      // button icon panel name
        }
        "menuitem2"
        {
                "label"         "#Back"               // name shown in game
                "command"       "csimenu1back"        // command sent when button is pressed
                "custom"        "CSIMenu1_Center"     // button background panel name
                "icon"          "CSIMenu1_CenterIcon" // button icon panel name
        }
}
