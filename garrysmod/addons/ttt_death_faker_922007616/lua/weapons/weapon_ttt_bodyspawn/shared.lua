if SERVER then
  AddCSLuaFile( "shared.lua" )
  AddCSLuaFile( "cl_menu.lua" )
  AddCSLuaFile( "hooks.lua" )
  resource.AddFile("materials/vgui/ttt/icon_deathfaker.png")
  resource.AddWorkshop("922007616")
end

include("hooks.lua")

if CLIENT then

   SWEP.PrintName = "Death Faker"
   SWEP.Slot				= 6

   SWEP.EquipMenuData = {
      type  = "item_weapon",
      name  = "Death Faker",
      desc  = [[
Left-Click: Spawns a dead body
Right-Click to place blood]]
   };

   SWEP.Icon = "vgui/ttt/icon_deathfaker.png"
   
	include("cl_menu.lua")
end

SWEP.HoldType = "slam"
SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.WeaponID = AMMO_BODYSPAWNER

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 54
SWEP.ViewModel  = Model("models/weapons/cstrike/c_c4.mdl")
SWEP.WorldModel = Model("models/weapons/w_c4.mdl")

SWEP.DrawCrosshair      = false
SWEP.ViewModelFlip      = false
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo       = "none"
SWEP.Primary.Delay = 0.1

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo     = "none"
SWEP.Secondary.Delay = 0.1

SWEP.NoSights = true

local throwsound = Sound( "Weapon_SLAM.SatchelThrow" )

function SWEP:PrimaryAttack()	
	if SERVER then
		self:BodyDrop()
	end
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	
	local tr = self.Owner:GetEyeTrace()
	local Pos1 = tr.HitPos + tr.HitNormal
	local Pos2 = tr.HitPos - tr.HitNormal
	util.Decal( "Blood", Pos1, Pos2 )

end

function SWEP:BodyDrop()
	local dmg = DamageInfo()
	
	local ply = self.Owner
	local dead
	if ply.df_bodyname then
		dead = player.GetByUniqueID( ply.df_bodyname )
	end
	if not dead then
		dead = ply
	end
	
	dmg:SetAttacker(ply)
	dmg:SetDamage(10)
	
	if ply.df_weapon == "-1" then
		dmg:SetDamageType( DMG_FALL ) 
    elseif ply.df_weapon == "-2" then
		dmg:SetDamageType( DMG_BLAST ) 
    elseif ply.df_weapon == "-3" then
		dmg:SetDamageType( DMG_CRUSH ) 
    elseif ply.df_weapon == "-4" then
		dmg:SetDamageType( DMG_BURN ) 
    elseif ply.df_weapon == "-5" then
		dmg:SetDamageType( DMG_DROWN ) 
	else
		dmg:SetDamageType( DMG_BULLET ) 
	end
	dead:SetNWBool("FakedDeath", true)
	
	local rag = CORPSE.Create(ply, ply, dmg)
	CORPSE.SetCredits(rag, 0)
	CORPSE.SetPlayerNick(rag, dead)
	
	rag.uqid = ply.df_bodyname
	
    if not ply.df_weapon then		
		rag.dmgwep = "weapon_ttt_m16"
		rag.was_headshot = ply.df_headshot
	elseif weapons.Get(ply.df_weapon) then		
		rag.dmgwep = ply.df_weapon	
		rag.was_headshot = ply.df_headshot
	else
		rag.dmgwep = ""
	end
	
	if ply.df_role then
		rag.was_role = ply.df_role
	else
		rag.was_role = 1
	end
	rag.killer_sample = nil

	self.Weapon:EmitSound(throwsound)
	self:Remove()
end

function SWEP:Reload()
	if CLIENT then
		RunConsoleCommand("ttt_cl_traitorpopup")
	end
end

function SWEP:OnRemove()
   if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
      RunConsoleCommand("lastinv")
   end
end

if SERVER then
	function ChangeBloodMode(ply, cmd, args)
		if #args != 1 then return end
		
		if not ply:IsActiveTraitor() then return end
		
		if (args[1] == "0") then
		    print("Bloodmode disabled")
			ply.bloodmode = false
		else
			print("Bloodmode activated")
			ply.bloodmode = true
		end
	end
	concommand.Add("ttt_df_bloodmode", ChangeBloodMode)
	
	function SelectHeadshot(ply, cmd, args)
		if #args != 1 then return end
		
		if not ply:IsActiveTraitor() then return end
		
		if (args[1] == "0") then
			ply.df_headshot = false
		else
			ply.df_headshot = true
		end
	end
	concommand.Add("ttt_df_headshot", SelectHeadshot)
	
	function SelectWeapon(ply, cmd, args)
		if #args != 1 then return end
		
		if not ply:IsActiveTraitor() then return end
		
		ply.df_weapon = args[1]
	end
	concommand.Add("ttt_df_select_weapon", SelectWeapon)
	
	function SelectRole(ply, cmd, args)
		if #args != 1 then return end
		
		if not ply:IsActiveTraitor() then return end
		ply.df_role = args[1]
	end
	concommand.Add("ttt_df_select_role", SelectRole)
	
	function  SelectPlayer(ply, cmd, args)
		if #args != 1 then return end
		
		if not ply:IsActiveTraitor() then return end
		
		ply.df_bodyname = args[1]
	end
	concommand.Add("ttt_df_select_player", SelectPlayer)
end