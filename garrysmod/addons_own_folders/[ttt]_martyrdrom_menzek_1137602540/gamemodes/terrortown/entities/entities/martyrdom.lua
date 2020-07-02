AddCSLuaFile()
resource.AddFile("vgui/ttt/exho_martyrdom.png")

ENT.Type = "item_passive"
ENT.Base = "weapon_tttbase"

function perkIcon()
	local function perkIconHUD()
		if LocalPlayer():GetNetworkedString("martyrIsActive") == "true" then
			surface.SetMaterial(Material("vgui/ttt/exho_martyrdom.png"))
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawTexturedRect(50,(ScrH()/2)+100,38,38)
		end
	end
	hook.Add( "HUDPaint", "perkHUDPaintIconMartyrdom", perkIconHUD )
end
usermessage.Hook("perkHUDIconMartyrdom", perkIcon)

hook.Add( "InitPostEntity", "FindAMartyr", function()
	
	-- Just an absoulute fallback in case a server doesn't run that version
	EQUIP_MARTYR = ( GenerateNewEquipmentID and GenerateNewEquipmentID() ) or 2048

	local MartyrDumb = {
		  id = EQUIP_MARTYR,
		  loadout = false,
		  type = "item_passive",
		  material = "vgui/ttt/exho_martyrdom.png",
		  name = "Martyrdom",
		  desc = "Drops a live grenade upon your death!\n"
	}
	table.insert( EquipmentItems[ROLE_TRAITOR], MartyrDumb )
end)

hook.Add("TTTOrderedEquipment", "PraiseTheNade", function(ply)
	--print( ply:HasEquipmentItem(EQUIP_MARTYR)) -- HasEquipmentItem does not work in the Death hook, this works nicely
	if ply:HasEquipmentItem(EQUIP_MARTYR) then
		--ply.shouldmartyr = true -- So we set a boolean on the player
		ply:SetNetworkedString("martyrIsActive","true")
		umsg.Start( "perkHUDIconMartyrdom", ply )
		umsg.End()
	end
end)

local function GrenadeHandler(ply, infl, att)
	if ply:GetNetworkedString("martyrIsActive") == "true" then
		local proj = "ttt_martyr_proj" -- Create our grenade
		local martyr = ents.Create(proj)
		martyr:SetPos(ply:GetPos())
		martyr:SetAngles(ply:GetAngles())
		martyr:Spawn()
		martyr:SetThrower(ply) -- Someone has to be accountible for this tragedy!
		
		local spos = ply:GetPos()
		local tr = util.TraceLine({start=spos, endpos=spos + Vector(0,0,-32), mask=MASK_SHOT_HULL, filter=ply})
		timer.Simple(3, function()
			martyr:Explode(tr)
			--ply.shouldmartyr = false -- No need to explode again, you have fufilled your purposewa
			ply:SetNetworkedString("martyrIsActive","false")
			timer.Simple(1,function() hook.Remove( "HUDPaint", "perkHUDPaintIconMartyrdom" ) end)			
		end)
		--ply:SetNetworkedString("martyrIsActive","false")
	end
end

local function Resettin()
	for k,v in pairs(player.GetAll()) do
		--v.shouldmartyr = false
		v:SetNetworkedString("martyrIsActive","false")
		timer.Simple(1,function() hook.Remove( "HUDPaint", "perkHUDPaintIconMartyrdom" ) end)
	end
end

hook.Add( "TTTPrepareRound", "hoobalooba", Resettin )
hook.Add( "PlayerDeath", "hoobalooba", GrenadeHandler )


