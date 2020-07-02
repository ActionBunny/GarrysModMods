
AddCSLuaFile()

SWEP.HoldType = "grenade"
resource.AddFile ("materials/vgui/ttt/superdiscomb.vmt")
resource.AddFile ("materials/vgui/ttt/superdiscomb.vtf")

--if SERVER then
--	resource.AddWorkshop("")
--end

if CLIENT then
   SWEP.PrintName = "Super Discombobulator"
   SWEP.Slot = 7

   SWEP.EquipMenuData = {
      type = "Super Discombobulator",
      desc = "If just need a litte bit more then 'a bit pushing'".."\n".."NOW EXTRA HUGE - Ikkou"
   };
   
   SWEP.Icon = "vgui/ttt/superdiscomb"
   SWEP.IconLetter = "h"
end

SWEP.Base				= "weapon_tttbasegrenade"

SWEP.WeaponID = WEAPON_EQUIP
SWEP.Kind = WEAPON_EQUIP2

SWEP.CanBuy = {ROLE_TRAITOR}

SWEP.Spawnable = false


SWEP.AutoSpawnable      = false

SWEP.UseHands			= true
SWEP.ViewModelFlip		= true
SWEP.ViewModelFOV		= 70
SWEP.ViewModel			= "models/weapons/v_eq_fraggrenade.mdl"
SWEP.WorldModel			= "models/weapons/w_eq_fraggrenade.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.Weight			= 5
SWEP.ViewModelBoneMods = {
	["v_weapon.Flashbang_Parent"] = { scale = Vector(2.548, 2.548, 2.548), pos = Vector(0.185, -2.408, 2.778), angle = Angle(0, 0, 0) }
}

-- really the only difference between grenade weapons: the model and the thrown
-- ent.
function SWEP:Initialize()
   self:SetModelScale(3,0)
   self:Activate()
end

function SWEP:OnDrop()
   self:Activate()
end


function SWEP:GetGrenadeName()
   return "ttt_confgrenade_proj_super"
end
