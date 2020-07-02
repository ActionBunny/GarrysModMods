"Resource/HudLayout.res"
{
	//The Ship hud BEGIN
	
	HudCompass
	{
		"fieldName" "HudCompass"
		"visible" "1"
		"enabled" "1"
		"xpos" "0"
		"ypos" "0"
		"zpos" "1"
		"wide"	"640"
		"tall"	"480"
		
		"UnscaledX"	"64"
		"UnscaledY"	"138"
		"RingX"	"200"
		"RingY"	"200"		
	}
	
	HudJustice
	{
		"fieldName" "HudJustice"
		"visible" "1"
		"enabled" "1"
		"xpos" "120"
		"ypos" "200"
		"zpos" "1"
		"wide"	"640"
		"tall"	"480"
		
		"PaintBackgroundType"	"0"
	}
	
	ShipInventory
	{
		"fieldName" "ShipInventory"
		"visible" "1"
		"enabled" "1"
		"xpos" "202"
		"ypos" "105"
		"wide"	"512"
		"tall"	"512"
		
		"PaintBackgroundType"	"0"
	}
	
	ShipInventoryBackground
	{
		"fieldName" "ShipInventoryBackground"
		"visible" "1"
		"enabled" "1"
		"xpos" "202"
		"ypos" "105"
		"wide"	"512"
		"tall"	"512"
		
		"PaintBackgroundType"	"0"
	}
	
	HudHelp
	{
		"fieldName" "HudHelp"
		"visible" "1"
		"enabled" "1"
		//"xpos" "r575"
		//"ypos" "r430"
		"xpos" "0"
		"ypos" "0"

		"wide"	"1024"
		"tall"	"768"
		
		"PaintBackgroundType"	"0"
	}

	HudMission
	{
		"fieldName" "HudMission"
		"visible" "1"
		"enabled" "1"
		"xpos" "0"
		"ypos" "160"

		"wide"	"1024"
		"tall"	"256"
		
		"PaintBackgroundType"	"0"
	}

	HudEndMission
	{
		"fieldName" "HudEndMission"
		"visible" "1"
		"enabled" "1"
		"xpos" "0"
		"ypos" "160"

		"wide"	"1024"
		"tall"	"256"
		
		"PaintBackgroundType"	"0"
	}
	
	HudClothing
	{
		"fieldName" "HudClothing"
		"visible" "1"
		"enabled" "1"
		"xpos" "r190"
		"ypos" "r175"
		"wide"	"150"
		"tall"	"130"
		
		"PaintBackgroundType"	"0"
	}

	HudActiveObjects
	{
		"fieldName" "HudActiveObjects"
		"visible" "1"
		"enabled" "1"
		"xpos" "0"
		"ypos" "r180"
		"wide"	"80"
		"tall"	"80"
		
		"PaintBackgroundType"	"0"
	}

	HudInfoBar
	{
		"fieldName" "HudInfoBar"
		"visible" "1"
		"enabled" "1"
		"xpos" "0"
		"ypos" "r220"
		"wide" "640"
		"tall" "65"
		
		"PaintBackgroundType"	"0"
		
		"FriendlyTeamColour"	"50 255 50 255"
		"OpposingTeamColour"	"255 0 0 255"
	}

	HudSecurity
	{
		"fieldName" "HudSecurity"
		"visible" "1"
		"enabled" "1"
		"xpos" "0"
		"ypos" "0"

		"wide"	"640"
		"tall"	"480"
		
		"UnscaledX"	"140"
		"UnscaledY"	"320"
		
		
		"PaintBackgroundType"		"0"
		"BrigTimerColour"			"135 211 219 255"
		"DefaultColour"				"255 255 255 255"
	}


	HudSecurityGuard
	{
		"fieldName" "HudSecurityGuard"
		"visible" "1"
		"enabled" "1"
		"xpos" "0"
		"ypos" "0"

		"wide"	"640"
		"tall"	"480"
		
		"UnscaledXPos"	"200"
		"UnscaledYPos"	"240"
		"PaintBackgroundType"	"0"
		"ImageDiameter"		"64"
		"AlertColour"		"255 255 0 255"
		"HighlightColour"		"255 255 255 255"
	}



	HudSecurityTrespass
	{
		"fieldName" "HudSecurityTrespass"
		"visible" "1"
		"enabled" "1"
		"xpos" "0"
		"ypos" "0"

		"wide"	"640"
		"tall"	"480"		
		
		"UnscaledXPos"	"100"
		"UnscaledYPos"	"392"
		"PaintBackgroundType"	"0"
		"ImageDiameter"		"64"
		"AlertColour"		"255 255 0 255"
		"HighlightColour"		"255 255 255 255"
	}



	HudSecurityCamera
	{
		"fieldName" "HudSecurityCamera"
		"visible" "1"
		"enabled" "1"
		"xpos" "0"
		"ypos" "0"

		"wide"	"640"
		"tall"	"480"		
		
		"UnscaledXPos"	"210"
		"UnscaledYPos"	"312"
		"PaintBackgroundType"	"0"
		"ImageDiameter"		"64"
		"AlertColour"		"255 255 0 255"
		"HighlightColour"		"255 255 255 255"
	}



	HudSecurityPassenger
	{
		"fieldName" "HudSecurityPassenger"
		"visible" "1"
		"enabled" "1"
		"xpos" "0"
		"ypos" "0"

		"wide"	"640"
		"tall"	"480"
		
		"UnscaledXPos"	"170"
		"UnscaledYPos"	"372"
		"PaintBackgroundType"	"0"
		"ImageDiameter"		"64"
		"AlertColour"		"255 0 0 255"
		"HighlightColour"		"255 255 255 255"
		"ForceOn"	"0"
	}

	HudIdentity
	{
		"fieldName" "HudIdentity"
		"visible" "1"
		"enabled" "1"
		"xpos" "0"
		"ypos" "0"
		"zpos" "1"
		"wide"	"640"
		"tall"	"480"
		
		"PaintBackgroundType"	"0"
		"ForcePictureDiameter"	"96"
		
		"ModelWidth"		"96"
		"ModelHeight"		"128"
		"ModelX"			"42"
		"ModelY"			"25"
		
		"BGImageX"			"20"
		"BGImageY"			"20"
		
		"RingX"				"10"
		"RingY"				"10"
		
		"NameTextX"			"150"
		"NameTextY"			"15"
		"CentreName"		"0"
		
		"LocTextX"			"165"
		"LocTextY"			"35"
		
		"CashTextX"			"175"
		"CashTextY"			"55"
		
		"BankTextX"			"180"
		"BankTextY"			"75"
		
		"TeamNameX"			"180"
		"TeamNameY"			"95"
	}

	HudAmmo
	{	
		"fieldName" "HudAmmo"
		"visible" "1"
		"enabled" "1"
		"xpos" "0"
		"ypos" "0"
		"wide" "640"
		"tall" "480"
		
		"UnscaledX"	"170"
		"UnscaledY" "115"
		
		"IconX"		"170"
		"IconY"		"115"
		"AmmoX"		"202"
		"AmmoY"		"150"		
	}

	HudSprint
	{	
		"fieldName" "HudSprint"
		"visible" "1"
		"enabled" "1"
		"xpos" "0"
		"ypos" "0"
		"wide" "640"
		"tall" "480"
		
		"UnscaledX"	"120"
		"UnscaledY" "170"	
		
		"IconX"	"120"
		"IconY"	"170"	
	}

	HudMrXSpecial
	{	
		"fieldName" "HudMrXSpecial"
		"visible" "1"
		"enabled" "1"
		"xpos" "0"
		"ypos" "0"
		"wide" "640"
		"tall" "480"
		
		"UnscaledX"	"80"
		"UnscaledY" "460"	
		
		"IconX"	"80"
		"IconY"	"460"
		
		"LabelX"	"85"
		"LabelY"	"448"
		
		"LocationX"	"85"
		"LocationY" "428"
		
		"ForceOn" "0"
		"ForceOff" "0"
	}

	HudNeedBars
	{
		"fieldName" "HudNeedBars"
		"visible" "1"
		"enabled" "1"
		"xpos"	"0"
		"ypos"	"0"
		"wide"	"640"
		"tall"	"480"
		
		"UnscaledX"	"10"
		"UnscaledY" "160"
		
		"ArrowX"		"80"
		"ExtremeTimerX"	"-2"
		
		"NeedSafeColour" "65 209 61 192"
		"NeedAlertColour" "242 250 100 192"
		"NeedUrgentColour" "220 31 31 192"
		"NeedExtremeColour" "150 50 150 192"
		"NeedDisabledAlpha" "70"

		"PaintBackgroundType"	"0"		
	}

	HudQuarry
	{
		"fieldName" "HudQuarry"
		"visible" "1"
		"enabled" "1"
		"xpos" "0"
		"ypos" "0"
		"wide"	"640"
		"tall"	"480"
		
		"PaintBackgroundType"	"0"
		"PieDiameter"		"190"
		"ModelWidth"		"96"
		"ModelHeight"		"128"
		
		"ModelX"			"50"
		"ModelY"			"38"
		
		"BGImageX"			"163"
		"BGImageY"			"163"
		
		"PieX"				"195"
		"PieY"				"195"
		
		"RingX"				"180"
		"RingY"				"180"
		
		"NameTextX"			"195"
		"NameTextY"			"80"
	
		"LocHeaderX"		"185"
		"LocHeaderY"		"60"
	
		"LocTextX"			"175"
		"LocTextY"			"40"
		
		"TeamNameX"			"200"
		"TeamNameY"			"100"
	}

	HudWinner
	{
		"fieldName" "HudWinner"
		"visible" "1"
		"enabled" "1"
		"xpos" "0"
		"ypos" "0"
		"wide"	"640"
		"tall"	"480"
		
		"PaintBackgroundType"	"0"
		
		"ModelWidth"		"96"
		"ModelHeight"		"128"
		
		"ModelX"			"-48"
		"ModelY"			"48"
		
		"BGImageX"			"73"
		"BGImageY"			"183"
		
		"RingX"				"90"
		"RingY"				"200"
		
		"HeaderX"			"-100"
		"FieldsX"			"-180"
		"TitleY"			"170"
		"NameY"				"150"
		"IdentityY"			"130"
		"MoneyY"			"110"
		"MurdersY"			"90"
	}

	HudRoundSummary
	{
		"fieldName"	"HudRoundSummary"
		"visible"	"1"
		"enabled"	"1"
		"xpos"		"0"
		"ypos"		"0"
		"zpos"		"1"
		"wide"		"640"
		"tall"		"480"
		
		"ImageY"	"362"
		"Line1Y"	"325"
		"Line2Y"	"295"
		"Line3Y"	"265"
		"Line4Y"	"235"
		"Line5Y"	"205"
		"Line6Y"	"175"
		"LineSpacing"	"30"
	}

	HudMrX
	{
		"fieldName" "HudMrX"
		"visible" "1"
		"enabled" "1"
		"xpos" "100"
		"ypos" "r70"
		"wide"	"60"
		"tall"	"60"
		
		"PaintBackgroundType"	"0"
	}

	HudMessageSecondary
	{
		"fieldName" "HudMessageSecondary"
		"visible" "1"
		"enabled" "1"
		"xpos" "170"
		"ypos" "-10"
		"wide"	"500"
		"tall"	"80"
		
		"PaintBackgroundType"	"0"
	}


	HudMessagePrimary
	{
		"fieldName" "HudMessagePrimary"
		"visible" "1"
		"enabled" "1"
		"xpos" "0"
		"ypos" "0"
		"wide"	"640"
		"tall"	"480"
		
		"BGImageY"				"200"
		"BGImageHeight"			"100"
		"TextY"					"240"
	}

	HudEquipment
	{
		"fieldName" "HudEquipment"
		"visible" "0"
		"enabled" "0"
		"xpos" "0"
		"ypos" "r256"
		"wide"	"256"
		"tall"	"256"
		
		"PaintBackgroundType"	"0"
	}



	//The Ship hud END

	HudHealth
	{
		"fieldName"		"HudHealth"
		"xpos"	"16"
		"ypos"	"432"
		"wide"	"102"
		"tall"  "36"
		"visible" "1"
		"enabled" "1"

		"PaintBackgroundType"	"2"
		
		"text_xpos" "8"
		"text_ypos" "20"
		"digit_xpos" "50"
		"digit_ypos" "2"
	}
	
	HudSuit
	{
		"fieldName"		"HudSuit"
		"xpos"	"140"
		"ypos"	"432"
		"wide"	"108"
		"tall"  "36"
		"visible" "1"
		"enabled" "1"

		"PaintBackgroundType"	"2"

		
		"text_xpos" "8"
		"text_ypos" "20"
		"digit_xpos" "50"
		"digit_ypos" "2"
	}
	
	HudSuitPower
	{
		"fieldName" "HudSuitPower"
		"visible" "1"
		"enabled" "1"
		"xpos"	"16"
		"ypos"	"396"
		"wide"	"102"
		"tall"	"26"
		
		"AuxPowerLowColor" "255 0 0 220"
		"AuxPowerHighColor" "255 220 0 220"
		"AuxPowerDisabledAlpha" "70"

		"BarInsetX" "8"
		"BarInsetY" "15"
		"BarWidth" "92"
		"BarHeight" "4"
		"BarChunkWidth" "6"
		"BarChunkGap" "3"

		"text_xpos" "8"
		"text_ypos" "4"
		"text2_xpos" "8"
		"text2_ypos" "22"
		"text2_gap" "10"

		"PaintBackgroundType"	"2"
	}
	
	HudFlashlight
	{
		"fieldName" "HudFlashlight"
		"visible" "0"
		"enabled" "1"
		"xpos"	"16"
		"ypos"	"370"
		"wide"	"102"
		"tall"	"20"
		
		"text_xpos" "8"
		"text_ypos" "6"
		"TextColor"	"255 170 0 220"

		"PaintBackgroundType"	"2"
	}
	
	HudDamageIndicator
	{
		"fieldName" "HudDamageIndicator"
		"visible" "1"
		"enabled" "1"
		"DmgColorLeft" "255 0 0 0"
		"DmgColorRight" "255 0 0 0"
		
		"dmg_xpos" "30"
		"dmg_ypos" "100"
		"dmg_wide" "36"
		"dmg_tall1" "240"
		"dmg_tall2" "200"
	}

	HudZoom
	{
		"fieldName" "HudZoom"
		"visible" "1"
		"enabled" "1"
		"Circle1Radius" "66"
		"Circle2Radius"	"74"
		"DashGap"	"16"
		"DashHeight" "4"
		"BorderThickness" "88"
	}

	HudWeaponSelection
	{
		"fieldName" "HudWeaponSelection"
		"ypos" 	"0"
		"xpos"	"0"
		"wide"	"0"
		"tall"	"0"
		"visible" "0"
		"enabled" "0"
		"SmallBoxSize" "32"
		"LargeBoxWide" "112"
		"LargeBoxTall" "80"
		"BoxGap" "8"
		"SelectionNumberXPos" "4"
		"SelectionNumberYPos" "4"
		"SelectionGrowTime"	"0.4"
		"TextYPos" "64"
	}

	HudCrosshair
	{
		"fieldName" "HudCrosshair"
		"visible" "1"
		"enabled" "1"
		"wide"	 "640"
		"tall"	 "480"
	}

	HudDeathNotice
	{
		"fieldName" "HudDeathNotice"
		"visible" "1"
		"enabled" "1"
		"wide"	 "640"
		"tall"	 "480"
	}

	HudVehicle
	{
		"fieldName" "HudVehicle"
		"visible" "1"
		"enabled" "1"
		"wide"	 "640"
		"tall"	 "480"
	}

	ScorePanel
	{
		"fieldName" "ScorePanel"
		"visible" "1"
		"enabled" "1"
		"wide"	 "640"
		"tall"	 "480"
	}

	HudTrain
	{
		"fieldName" "HudTrain"
		"visible" "1"
		"enabled" "1"
		"wide"	 "640"
		"tall"	 "480"
	}

	HudMOTD
	{
		"fieldName" "HudMOTD"
		"visible" "1"
		"enabled" "1"
		"wide"	 "640"
		"tall"	 "480"
	}

	HudMessage
	{
		"fieldName" "HudMessage"
		"visible" "1"
		"enabled" "1"
		"wide"	 "640"
		"tall"	 "480"
	}

	HudMenu
	{
		"fieldName" "HudMenu"
		"visible" "1"
		"enabled" "1"
		"wide"	 "640"
		"tall"	 "480"
	}

	HudCloseCaption
	{
		"fieldName" "HudCloseCaption"
		"visible"	"1"
		"enabled"	"1"
		"xpos"		"160"
		"ypos"		"r162"
		"wide"		"370"
		"tall"		"160"

		"BgAlpha"	"96"

		"GrowTime"		"0.25"
		"ItemHiddenTime"	"0.2"  // Nearly same as grow time so that the item doesn't start to show until growth is finished
		"ItemFadeInTime"	"0.15"	// Once ItemHiddenTime is finished, takes this much longer to fade in
		"ItemFadeOutTime"	"0.3"

	}

	HudVoiceStatus
	{
		"fieldName" "HudVoiceStatus"
		"visible"	"0"
		"enabled"	"0"
		"xpos"		"0"
		"ypos"		"0"
		"wide"		"0"
		"tall"		"0"
	}

	HudChat
	{
		"fieldName" "HudChat"
		"visible" "1"
		"enabled" "1"
		"xpos"	"70"
		"ypos"	"r105"
		"wide"	 "200"
		"tall"	 "100"
		
		"ChatColour"			"155 142 126 255"
		"FriendlyChatColour"	"64 200 0 255"
		"EnemyChatColour"		"200 64 0 255"
	}

	HudHistoryResource
	{
		"fieldName" "HudHistoryResource"
		"visible" "1"
		"enabled" "1"
		"xpos"	"r252"
		"ypos"	"40"
		"wide"	 "248"
		"tall"	 "320"

		"history_gap"	"56"
		"icon_inset"	"28"
		"text_inset"	"26"
		"NumberFont"	"HudNumbersSmall"
	}

	HudGeiger
	{
		"fieldName" "HudGeiger"
		"visible" "1"
		"enabled" "1"
		"wide"	 "640"
		"tall"	 "480"
	}

	HUDQuickInfo
	{
		"fieldName" "HUDQuickInfo"
		"visible" "1"
		"enabled" "1"
		"wide"	 "640"
		"tall"	 "480"
	}

	HudWeapon
	{
		"fieldName" "HudWeapon"
		"visible" "1"
		"enabled" "1"
		"wide"	 "0"
		"tall"	 "0"
	}
	HudAnimationInfo
	{
		"fieldName" "HudAnimationInfo"
		"visible" "1"
		"enabled" "1"
		"wide"	 "640"
		"tall"	 "480"
	}

	HudPredictionDump
	{
		"fieldName" "HudPredictionDump"
		"visible" "1"
		"enabled" "1"
		"wide"	 "640"
		"tall"	 "480"
	}

	HudHintDisplay
	{
		"fieldName"	"HudHintDisplay"
		"visible"	"0"
		"enabled" "1"
		"xpos"	"r120"
		"ypos"	"r340"
		"wide"	"100"
		"tall"	"200"
		"text_xpos"	"8"
		"text_ypos"	"8"
		"text_xgap"	"8"
		"text_ygap"	"8"
		"TextColor"	"255 170 0 220"

		"PaintBackgroundType"	"2"
	}

	HudSquadStatus
	{
		"fieldName"	"HudSquadStatus"
		"visible"	"1"
		"enabled" "1"
		"xpos"	"r120"
		"ypos"	"380"
		"wide"	"104"
		"tall"	"46"
		"text_xpos"	"8"
		"text_ypos"	"34"
		"SquadIconColor"	"255 220 0 160"
		"IconInsetX"	"8"
		"IconInsetY"	"0"
		"IconGap"		"24"

		"PaintBackgroundType"	"2"
	}

	HudPoisonDamageIndicator
	{
		"fieldName"	"HudPoisonDamageIndicator"
		"visible"	"0"
		"enabled" "1"
		"xpos"	"16"
		"ypos"	"346"
		"wide"	"136"
		"tall"	"38"
		"text_xpos"	"8"
		"text_ypos"	"8"
		"text_ygap" "14"
		"TextColor"	"255 170 0 220"
		"PaintBackgroundType"	"2"
	}
	HudCredits
	{
		"fieldName"	"HudCredits"
		"TextFont"	"Default"
		"visible"	"1"
		"xpos"	"0"
		"ypos"	"0"
		"wide"	"640"
		"tall"	"480"
		"TextColor"	"255 255 255 192"

	}
	
	HUDAutoAim
	{
		"fieldName" "HUDAutoAim"
		"visible" "1"
		"enabled" "1"
		"wide"	 "640"
		"tall"	 "480"
	}

}