
AddCSLuaFile()

SWEP.HoldType			= "grenade"

if CLIENT then
   SWEP.PrintName = "HE Grenade"
   SWEP.Slot = 3

   SWEP.Icon = "VGUI/ttt/icon_nades"
end

SWEP.Base				= "weapon_tttbasegrenade"
SWEP.Kind				= WEAPON_NADE
SWEP.Spawnable = true

SWEP.UseHands			= true
SWEP.ViewModelFlip		= true
SWEP.ViewModelFOV		= 64
SWEP.ViewModel			= "models/weapons/v_nc_fraggrenade.mdl"
SWEP.WorldModel			= "models/weapons/w_nc_fraggrenade.mdl"
SWEP.Weight			= 5
SWEP.AutoSpawnable      = true
-- really the only difference between grenade weapons: the model and the thrown
-- ent.

function SWEP:GetGrenadeName()
   return "ttt_fraggrenade_proj"
end

