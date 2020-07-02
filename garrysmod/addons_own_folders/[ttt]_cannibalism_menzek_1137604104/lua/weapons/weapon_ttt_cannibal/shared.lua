-- Fixed by Giygas. Also, get out of here! There's nothing else to fix!
CreateConVar( "ttt_cannibal_health", "6", FCVAR_NOTIFY + FCVAR_ARCHIVE , "Adjust the Health a Player gets if he eats others." )

if SERVER then
AddCSLuaFile( "shared.lua" )
resource.AddFile("materials/vgui/ttt/ttt_cannibalism.vmt")
resource.AddFile("materials/vgui/ttt/ttt_cannibalism.vtf")
resource.AddFile("materials/vgui/ttt/ttt_cannibalism.png")
resource.AddFile( "materials/effects/vampiresplatter.vtf" )
resource.AddFile( "materials/effects/vampiresplatter.vmt" )
resource.AddFile( "materials/vgui/ttt/vampire.png" )
resource.AddFile( "sound/cannibalism/laugh.mp3" )
end

if SERVER then
	util.AddNetworkString("VampireStart")
	util.AddNetworkString("VampireMessage")
end

util.PrecacheSound("cannibalism/laugh.mp3")
local sound_single = Sound("Weapon_Crowbar.Single")

if CLIENT then
SWEP.PrintName = "Cannibalism"
SWEP.Slot      = 7 -- add 1 to get the slot number key

SWEP.ViewModelFOV  = 72
SWEP.ViewModelFlip = true
end

-- Always derive from weapon_tttbase.
SWEP.Base				= "weapon_tttbase"

--- Standard GMod values

SWEP.HoldType			= "knife"

SWEP.Primary.Damage         = 0
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo           = "none"
SWEP.Primary.Delay = 0.5

SWEP.IronSightsPos = Vector( 6.05, -5, 2.4 )
SWEP.IronSightsAng = Vector( 2.2, -0.1, 0 )

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel             = "models/weapons/w_knife_t.mdl"

SWEP.Kind = WEAPON_EQUIP2
SWEP.AutoSpawnable = false
SWEP.AmmoEnt = ""
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.InLoadoutFor = nil
SWEP.LimitedStock = true
SWEP.AllowDrop = true
SWEP.IsSilent = true
SWEP.NoSights = true
SWEP.Icon = "vgui/ttt/ttt_cannibalism.png"

SWEP.MaxHealth = 200
SWEP.RagdollTicks = 10
SWEP.RagdollHealthPerTick = 3
SWEP.RagdollFreq = 0.5

SWEP.VampireDelay = 25
SWEP.VampireHealth = 25
if CLIENT then
-- Text shown in the equip menu
SWEP.EquipMenuData = {
	type = "Weapon",
	desc = "CANNIBALISM! GET RID OF EVIDENCE AND GAIN HEALTH!"
};
end

function SWEP:PrimaryAttack()
	if not IsValid(self:GetOwner()) then return end
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
   local spos = self:GetOwner():GetShootPos()
   local sdest = spos + (self:GetOwner():GetAimVector() * 70)

   local tr = util.TraceLine({start=spos, endpos=sdest, filter=self:GetOwner(), mask=MASK_SHOT_HULL})
   local hitEnt = tr.Entity

   --self.Weapon:EmitSound(sound_single)
	
	  self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
   if IsValid(hitEnt) or tr.HitWorld then
      self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
		if tr.Entity.player_ragdoll then --:GetClass() == "prop_ragdoll"
			self:EatRagdoll(tr)
			
			net.Start("VampireMessage")
				net.WriteString("A huge feast.")
			net.Send(self.Owner)
			
		elseif tr.Entity:IsPlayer() and tr.Entity:Alive() and (self.Owner:Health() < self.MaxHealth) and ( tr.Entity:GetNWBool("BittenByVampire", false) == false )then
			self:EatPlayer(tr)
			net.Start("VampireMessage")
				net.WriteString( "Nibble at " .. tr.Entity:Nick() ..".")
			net.Send(self.Owner)
		end
   else
      self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
   end
   
end

function SWEP:EatRagdoll(tr)
	ply = self.Owner
	victim = tr.Entity
	local effect = EffectData()
	effect:SetStart( self.Owner:GetShootPos() )
	effect:SetOrigin( tr.HitPos )
	effect:SetNormal( tr.Normal )
	effect:SetEntity( victim )
	
	util.Effect("BloodImpact", effect)
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.1 + (self.RagdollFreq*self.RagdollTicks) )
	
	if ply:HasEquipmentItem(EQUIP_RADAR) then
		ply:SetNWBool("Cannibalism_HadRadar", true)
	else
		ply:SetNWBool("Cannibalism_HadRadar", false)
	end

	ply:Freeze(true) 
						
	
	timer.Create("GivePlyHealth_"..self.Owner:UniqueID(), self.RagdollFreq, self.RagdollTicks,function() 
		self.Owner:SetHealth(self.Owner:Health() + self.RagdollHealthPerTick)			
		if self.Owner:Health() > self.MaxHealth then
			self.Owner:SetHealth( self.MaxHealth )
		end 

	end)
				
	timer.Simple((self.RagdollFreq*self.RagdollTicks) + 0.1, function() 
		ply:Freeze(false)
		if IsValid(tr.Entity) then
			tr.Entity:Remove()
		end
		if ply:GetNWBool("Cannibalism_HadRadar", false) then 
			ply:GiveEquipmentItem(EQUIP_RADAR)
		end
	end)
end 

function SWEP:EatPlayer(tr)
	ply = self.Owner
	victim = tr.Entity
	local effect = EffectData()
	effect:SetStart( self.Owner:GetShootPos() )
	effect:SetOrigin( tr.HitPos )
	effect:SetNormal( tr.Normal )
	effect:SetEntity( victim )
	
	util.Effect("BloodImpact", effect)
	

	victim:SetNWBool("BittenByVampire", true)
	--victim:SetNWFloat( "EndBittenByVampire", CurTime() + self.VampireDelay)
	
	timer.Simple( self.VampireDelay, function() 
		if SERVER then
			if not  IsValid(victim) then return end
			
			local dmginfo = DamageInfo()
			dmginfo:SetDamage( self.VampireHealth )
			dmginfo:SetDamageType( DMG_SLASH )
			if IsValid( self.Owner ) then
				--victim:SetNWString("Vampire", self.Owner:SteamID() )
				dmginfo:SetAttacker( self.Owner ) 
			else
				dmginfo:SetAttacker( self )
			end
			dmginfo:SetInflictor( self )
			victim:TakeDamageInfo( dmginfo )
			self.Owner:SetHealth( self.Owner:Health() + self.VampireHealth )
			if self.Owner:Health() > self.MaxHealth then
				self.Owner:SetHealth( self.MaxHealth )
			end
			
			if IsValid(ply) then
				net.Start("VampireStart")
					net.WriteString( ply:SteamID() )
				net.Send( victim )	
			end
			victim:SetNWBool("BittenByVampire", false)
			--zeige victim 2 s lang umrandung und sound + bildeffekt
		end
		
	end)
end

hook.Add( "PreDrawHalos", "CannibalismAddHalos", function()
	--aktiver part: wenn man Cannibalismus hat!
	local pos = LocalPlayer():GetPos()
	
	local ragdollTable = {}
	local currentRagdoll = currentRagdoll or nil
	local currentRagdollDistance = 650*650
	local ragdollFound = ragdollFound or false

	local playerTable = {}
	currentPlayer = currentPlayer or nil
	local currentPlayerDistance = 650*650
	playerFound = playerFound or false	
	--print(nextCannibalismScan)
	nextCannibalismScan = nextCannibalismScan or 0
	
	
	if (LocalPlayer():Health() > 139) and (LocalPlayer():HasWeapon("weapon_ttt_cannibal")) then
		--print("VampStart")
		for k, v in pairs( ents.FindByClass( "prop_ragdoll" ) ) do
			if pos:DistToSqr( v:GetPos() ) < currentRagdollDistance then
				currentRagdollDistance = pos:DistToSqr( v:GetPos() )
				currentRagdoll = v
				ragdollFound = true
			end
		end
	end	
	if (LocalPlayer():Health() > 159) and (LocalPlayer():HasWeapon("weapon_ttt_cannibal")) and CurTime() > nextCannibalismScan then			
		for k, v in pairs( player.GetAll() ) do
			if v:Alive() then --noch rolle prüfen?
				if v:SteamID() ~= LocalPlayer():SteamID() then
					if not v:IsSpec() then
						if LocalPlayer():GetRole() == ROLE_TRAITOR then
							if v:GetRole() ~= ROLE_TRAITOR then
								if pos:DistToSqr( v:GetPos() ) < currentPlayerDistance then
									currentPlayerDistance = pos:DistToSqr( v:GetPos() )
									currentPlayer = v
									playerFound = true
									--print( currentPlayer:Nick() )
								end
							end	
						else
							if pos:DistToSqr( v:GetPos() ) < currentPlayerDistance then
								currentPlayerDistance = pos:DistToSqr( v:GetPos() )
								currentPlayer = v
								playerFound = true
								--print( currentPlayer:Nick() )
							end
						end
					end
				end
			end
		end	
		
		nextCannibalismScan = CurTime() + 5
		--print(nextCannibalismScan)
	end	
	
	if ragdollFound == true then
		table.insert(ragdollTable, currentRagdoll)
		halo.Add(ragdollTable, Color( 255, 0, 0 ), 2, 2, 1, true, true)
	end
	
	if playerFound == true then
		--print("PlayerHalo" .. currentPlayer:Nick())
		table.insert(playerTable, currentPlayer)
		halo.Add(playerTable, Color( 255, 0, 0 ), 2, 2, 1, true, true)
	end
	
--[[	
	if radollFound == true then
		if not ( timer.Exists( "ragdollTimer" ) ) then
			timer.Create( "ragdollTimer", 5, 0, function() 
				radollFound = false
				timer.Remove( "ragdollTimer" )
			end )
		end
	end
	]]
	if playerFound == true then
		if not ( timer.Exists( "playerTimer" ) ) then
			timer.Create( "playerTimer", 1, 0, function() 
				print("ResetPlayerFound")
				playerFound = false
				timer.Remove( "playerTimer" )
				currentPlayer = nil
			end )
		end
	end
	
	LocalPlayer().Vampire = LocalPlayer().Vampire or nil
	LocalPlayer().StartTime = LocalPlayer().StartTime or 0
	LocalPlayer().EndTime = LocalPlayer().EndTime or 0
	local vampireTable = {}

	if ( CurTime() < LocalPlayer().EndTime ) then
		table.insert(vampireTable, LocalPlayer().Vampire)
		halo.Add(vampireTable, Color( 255, 0, 0 ), 2, 2, 1, true, true)
	end
end)

hook.Add( "HUDPaint", "CannibalismOverlay", function()
	LocalPlayer().Vampire = LocalPlayer().Vampire or nil
	LocalPlayer().StartTime = LocalPlayer().StartTime or 0
	LocalPlayer().EndTime = LocalPlayer().EndTime or 0

	if ( CurTime() < LocalPlayer().EndTime ) then
		local Overlay = Material( "Effects/combine_binocoverlay" )
			surface.SetMaterial( Overlay )
			surface.SetDrawColor( 255, 255, 255, 150 )
			surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
	end
end )

net.Receive("VampireStart", function(len, ply)
	LocalPlayer().Vampire = player.GetBySteamID( net.ReadString() )
	LocalPlayer().EndTime = CurTime() + 1.5
	LocalPlayer():EmitSound("cannibalism/laugh.mp3")
end)
net.Receive("VampireMessage", function(len, ply)
	chat.AddText( Color(255,0,0), "Cannibalism: ", Color(255,255,255), net.ReadString())
end)