if SERVER then
	AddCSLuaFile( "shared.lua" )
	resource.AddFile( "materials/lks/icon_lks_gimnade.png" )
	resource.AddFile( "materials/models/weapons/v_models/gimbal/core.vmt" )
	resource.AddFile( "materials/models/weapons/v_models/gimbal/core.vtf" )
	resource.AddFile( "materials/models/weapons/v_models/gimbal/core_normal.vtf" )
	resource.AddFile( "materials/models/weapons/v_models/gimbal/glass.vmt" )
	resource.AddFile( "materials/models/weapons/v_models/gimbal/glass.vtf" )
	resource.AddFile( "materials/models/weapons/v_models/gimbal/glass_normal.vtf" )
	resource.AddFile( "materials/models/weapons/v_models/gimbal/metal.vmt" )
	resource.AddFile( "materials/models/weapons/v_models/gimbal/metal.vtf" )
	resource.AddFile( "materials/models/weapons/v_models/gimbal/metal_normal.vtf" )
	resource.AddFile( "materials/models/weapons/v_models/gimbal/phongwarp.vtf" )
	resource.AddFile( "materials/models/weapons/w_models/gimbal/core.vmt" )
	resource.AddFile( "materials/models/weapons/w_models/gimbal/glass.vmt" )
	resource.AddFile( "materials/models/weapons/w_models/gimbal/metal.vmt" )
	resource.AddFile( "materials/vgui/entities/weapon_gimnade.vmt" )
	resource.AddFile( "materials/vgui/entities/weapon_gimnade.vtf" )
	resource.AddFile( "models/weapons/v_eq_fraqgrenade.mdl" )
	resource.AddFile( "models/weapons/w_eq_fraqgrenade.mdl" )
	resource.AddFile( "models/weapons/w_eq_fraqgrenade_thrown.mdl" )
	resource.AddFile( "sound/weapons/gimnade/draw.wav" )
	resource.AddFile( "sound/weapons/hegrenade/explode4.wav" )
	resource.AddFile( "sound/weapons/hegrenade/he_bounce-1.wav" )
end
	
SWEP.HoldType			= "grenade"
SWEP.PrintName = "Grav Nade"

if CLIENT then
	SWEP.Slot = 6
	SWEP.SlotPos	= 0
	
	SWEP.Icon = "lks/icon_lks_gimnade.png"
	
	  SWEP.EquipMenuData = {
      type="Weapon",
      model="models/weapons/w_eq_fraqgrenade.mdl",
      desc="High-tech grenade from the future!"
   };
	
end

SWEP.Base				= "weapon_tttbasegrenade"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.MemberOnly = true
SWEP.LimitedStock = false

SWEP.ViewModel			= "models/weapons/v_eq_fraqgrenade.mdl"
SWEP.WorldModel			= "models/weapons/w_eq_fraqgrenade.mdl"
SWEP.Weight			= 5
SWEP.AutoSpawnable      = false
-- really the only difference between grenade weapons: the model and the thrown
-- ent.

function SWEP:GetGrenadeName()
	return "ttt_gimnade_proj"
end

