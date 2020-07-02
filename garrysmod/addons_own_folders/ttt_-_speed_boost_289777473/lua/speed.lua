-- Coder: Nat "Exho" Adams
-- Purpose: Make the player's walk speed faster for a short amount of time


AddCSLuaFile()

local SpeedTime = 15
local SpeedSpeed = 3

EQUIP_SPEED = 256

hook.Add( "InitPostEntity", "LoadEquipItemSpeed", function() 
       local speedBoost = {
              id = EQUIP_SPEED,
              loadout = false,
              type = "item_passive",
              material = "VGUI/ttt/exho_speed.png",
              name = "Speed Boost",
              desc = [[ Increase your speed for ]] ..(SpeedTime).. [[ seconds! ]]
      }
      table.insert( EquipmentItems[ROLE_TRAITOR], speedBoost )
end) 

local function CanBoost(ply)
	if ply:GetNWBool("CanSpeed") == true then
		return true
	else return false end
end

hook.Add("TTTOrderedEquipment", "BuyingSpeed", function(ply)
	if (ply:HasEquipmentItem(EQUIP_SPEED) and CanBoost(ply)) then
		ply:PrintMessage( HUD_PRINTTALK, Format("You have a speed boost for %d seconds!!" , SpeedTime))
		timer.Create( "SpeedRemover", SpeedTime, 1, function()
			ply:SetNWBool( "CanSpeed", false )
			ply:PrintMessage( HUD_PRINTTALK, "Your speed boost has worn off!!" )
		end)
	end

end )


hook.Add("TTTPlayerSpeed", "SonicSpeed", function(ply)
	if (ply:HasEquipmentItem(EQUIP_SPEED) and CanBoost(ply) ) then
		return SpeedSpeed 
	end
	if not CanBoost(ply) then
		return 1
	end
end)


hook.Add("TTTPrepareRound", "DisableSpeedHack",function()
    for k, v in pairs( player.GetAll() ) do
		v:SetNWBool("CanSpeed", true)
	end
end)
