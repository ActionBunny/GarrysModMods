// Variables that are used on both client and server


SWEP.Base 				= "weapon_tttbase"

SWEP.ViewModel				= "models/weapons/v_minigun.mdl"
SWEP.WorldModel				= "models/weapons/w_minigun.mdl"
SWEP.UseHands = false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Primary.Sound 		= Sound("weapons/minigun/mini-1.wav")
SWEP.Primary.Recoil		= 0.8
SWEP.Primary.Damage		= 10
SWEP.Primary.NumShots	= 1
SWEP.Primary.Cone		= 0.03
SWEP.Primary.Delay 		= 0.06
SWEP.HoldType				= "physgun"

SWEP.Primary.ClipSize = 200
SWEP.Primary.ClipMax = 200
SWEP.Primary.DefaultClip	= 200			// Default number of bullets in a clip
SWEP.Primary.Automatic		= true				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "AirboatGun"

SWEP.Secondary.ClipSize		= -1					// Size of a clip
SWEP.Secondary.DefaultClip	= -1					// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto
SWEP.Secondary.Ammo		= "none"
SWEP.Kind = WEAPON_EQUIP1
SWEP.ShellEffect			= "effect_mad_shell_rifle"	// "effect_mad_shell_pistol" or "effect_mad_shell_rifle" or "effect_mad_shell_shotgun"

SWEP.Pistol				= false
SWEP.Rifle				= true
SWEP.Shotgun			= false
SWEP.Sniper				= false

SWEP.IronSightsPos 		= Vector (-4.6804, -17.5719, 4.4145)
SWEP.IronSightsAng 		= Vector (-0.022, -1.8518, 0)
SWEP.RunArmOffset 		= Vector (1.1073, -19.625, -0.7316)
SWEP.RunArmAngle 			= Vector (25.9554, 34.4127, 0)
---------TTT STUF------------------
SWEP.AmmoEnt = "item_ammo_smg1_ttt"
SWEP.InLoadoutFor = nil
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = true
SWEP.AllowDrop = true
SWEP.AutoSpawnable = false
if CLIENT then
   -- Path to the icon material
   SWEP.Icon ="VGUI/entities/minigun"
   -- Name and desc in t menu
   SWEP.EquipMenuData = {
   type = "Minigun",
   desc = "Rambo's Choice of Weapon"
  };
   
end

if SERVER then
   resource.AddFile("materials/VGUI/entities/minigun.vmt")
   resource.AddFile("materials/VGUI/entities/minigun.vtf")
end   

/*---------------------------------------------------------
   Name: SWEP:Precache()
   Desc: Use this function to precache stuff.
---------------------------------------------------------*/
function SWEP:Precache()

    	util.PrecacheSound("weapons/minigun/mini-1.wav")
end