
if SERVER then
	CreateConVar( "ttt_homerun_speedscale", "1.5", FCVAR_NOTIFY + FCVAR_ARCHIVE , "Adjust the speed a homerun player has. 1 is default, 0 none." )
	CreateConVar( "ttt_staminup_speedscale_t", "1.75", FCVAR_NOTIFY + FCVAR_ARCHIVE , "Adjust the speed a Staminuped Traitor player has. 1 is default, 0 none." )
	CreateConVar( "ttt_staminup_speedscale_d", "1.35", FCVAR_NOTIFY + FCVAR_ARCHIVE , "Adjust the speed a Staminuped Detective player has. 1 is default, 0 none." )
    CreateConVar( "ttt_minifier_speedscale", "0.55", FCVAR_NOTIFY + FCVAR_ARCHIVE , "Adjust the speed a minified player has. 1 is default, 0 none." )
	CreateConVar( "ttt_sparta_speedscale", "1.2", FCVAR_NOTIFY + FCVAR_ARCHIVE , "Adjust the speed a Spartan has. 1 is default, 0 none." )
	CreateConVar( "ttt_bluebull_speedscale", "1.2", FCVAR_NOTIFY + FCVAR_ARCHIVE , "Adjust the speed a BlueBull has. 1 is default, 0 none." )
	CreateConVar( "ttt_diamondsword_speedscale", "1.2", FCVAR_NOTIFY + FCVAR_ARCHIVE , "Adjust the speed a DiamondSword has. 1 is default, 0 none." )
	CreateConVar( "ttt_sparta_slowscale", "0.75", FCVAR_NOTIFY + FCVAR_ARCHIVE , "Adjust the initiial slow of Sparta." )
   
	--local homerunModifier = GetConVar( "ttt_homerun_speedscale" ):GetFloat()
	--local staminModifierTraitor = GetConVar( "ttt_staminup_speedscale_t" ):GetFloat()
	--local staminModifierDetective  = GetConVar( "ttt_staminup_speedscale_d" ):GetFloat() 
    --local minifierModifier = GetConVar( "ttt_minifier_speedscale" ):GetFloat()
	--local spartaModifier = GetConVar( "ttt_sparta_speedscale" ):GetFloat()
	--local bluebullModifier = GetConVar( "ttt_bluebull_speedscale" ):GetFloat()
	--local diamondSwordModifier = GetConVar( "ttt_diamondsword_speedscale" ):GetFloat()
	--local spartaSlowModifier = GetConVar( "ttt_sparta_slowscale" ):GetFloat()
	
	local function GetSpeedManagerModifier(ply, addonTable, currentModifier, addonModifier, debugName)
		addonTable = addonTable or {}
		
		if table.Count( addonTable ) == 0 then
			return currentModifier
		end
		
		for i=1, table.Count(addonTable) do
			if addonTable[i] == ply then
			--print("TTT_MISM - " .. debugName .. ": player found, addonModifier: " .. addonModifier .. ", currentModifier: " .. currentModifier .. " for ply " .. ply:Nick())
				if currentModifier == 1 then
					currentModifier = addonModifier
				else
					currentModifier = math.min(currentModifier, addonModifier)
				end
			end
		end
		
		return currentModifier
	end

	hook.Add("TTTPlayerSpeedModifier","TTTMenzekIlleSpeedManager", function(ply, slowed, mv)
		--print( "TTT_MISM: table count: " .. table.Count( GLOBAL_homerunTable ) )
		currentModifier = 1
		--apply all addons that modify speed
		--homerun bat
		currentModifier = GetSpeedManagerModifier(ply, GLOBAL_homerunTable, currentModifier, homerunModifier, "homerunBat")
		--staminUp
		if ply:IsDetective() then
			currentModifier = GetSpeedManagerModifier(ply, GLOBAL_staminupTable, currentModifier, staminModifierDetective, "staminup D")
		elseif ply:IsTraitor() then
			currentModifier = GetSpeedManagerModifier(ply, GLOBAL_staminupTable, currentModifier, staminModifierTraitor, "staminup T")
		end
		--minifier
		currentModifier = GetSpeedManagerModifier(ply, GLOBAL_minifierTable, currentModifier, minifierModifier, "minifer")
		
		--sparta
		currentModifier = GetSpeedManagerModifier(ply, GLOBAL_spartaTable, currentModifier, spartaModifier, "sparta")
		currentModifier = GetSpeedManagerModifier(ply, GLOBAL_spartaSlowTable, currentModifier, spartaSlowModifier, "spartaSlow")
		--diamondSword
		currentModifier = GetSpeedManagerModifier(ply, GLOBAL_diamondSwordTable, currentModifier, diamondSwordModifier, "diamondSword")
		--print( currentModifier )
		return currentModifier
	end)
end