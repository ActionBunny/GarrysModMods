
if SERVER then
	AddCSLuaFile( "weapon_ttt_holyhandgrenade.lua" )
	resource.AddFile("materials/vgui/ttt/icon_cyb_holyhandgrenade.png")

	-- The model is temporary until my custom model is finished.

	resource.AddFile("sound/holyhandgrenade.wav")
	resource.AddFile( "models/weapons/v_eq_fraggrenad2.mdl" )
	resource.AddFile( "models/weapons/w_eq_fraggrenad2.mdl" )   
	resource.AddFile( "models/weapons/w_eq_fraggrenade_throw2.mdl" )	
	resource.AddFile( "sound/weapons/hhg/Explosion1.wav" )
	resource.AddFile( "sound/weapons/hhg/Explosion2.wav" )
	resource.AddFile( "sound/weapons/hhg/Explosion3.wav" )
	resource.AddFile( "sound/weapons/hhg/Holy Water Bounce.wav" )
	resource.AddFile( "sound/weapons/hhg/Holy Water Deploy.wav" )
	resource.AddFile( "sound/weapons/hhg/Holy Water Pin.wav" )
	resource.AddFile( "sound/weapons/hhg/holygrenade.wav" )
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
SWEP.ViewModel       = "models/weapons/v_eq_fraggrenad2.mdl"
SWEP.ViewModelFOV        = 64
SWEP.ViewModelFlip        = false
SWEP.WorldModel = "models/weapons/w_eq_fraggrenad2.mdl"
SWEP.Weight			= 5

-- really the only difference between grenade weapons: the model and the thrown
-- ent.

function SWEP:GetGrenadeName()
   return "ttt_holyhandgrenade_proj"
end

function SWEP:Deploy()
	self.Owner:EmitSound("weapons/hhg/holy water deploy.wav", 40)
end

