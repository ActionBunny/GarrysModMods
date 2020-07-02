
if SERVER then
   AddCSLuaFile( "weapon_ttt_holyhandgrenade.lua" )
   resource.AddFile("materials/vgui/ttt/icon_cyb_holyhandgrenade.png")
   
   -- The model is temporary until my custom model is finished.

   resource.AddFile("sound/holyhandgrenade.wav")
end

SWEP.HoldType = "grenade"


if CLIENT then
   SWEP.PrintName = "Holy Hand Grenade"
   SWEP.Slot = 6
   SWEP.SlotPos	= 0

   SWEP.EquipMenuData = {
      type="Weapon",
      model="models/weapons/w_eq_fraggrenade_thrown.mdl",
      name="Holy Hand Grenade",
      desc="I think we all know what this does!"
   };

   SWEP.Icon = "vgui/ttt/icon_cyb_holyhandgrenade.png"
end

SWEP.Base				= "weapon_tttbasegrenade"

SWEP.WeaponID = AMMO_HOLY
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = true
SWEP.Kind = WEAPON_EQUIP

SWEP.Spawnable = true
SWEP.AdminSpawnable = true


SWEP.AutoSpawnable      = true

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 54
SWEP.ViewModel			= "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel			= "models/weapons/w_eq_fraggrenade.mdl"
SWEP.Weight			= 5

-- really the only difference between grenade weapons: the model and the thrown
-- ent.

function SWEP:GetGrenadeName()
   return "ttt_holyhandgrenade_proj"
end

