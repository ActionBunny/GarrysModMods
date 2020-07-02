
AddCSLuaFile()

SWEP.HoldType = "ar2"

if CLIENT then

   SWEP.PrintName = "FG-42"
   SWEP.Slot = 2

   SWEP.Icon = "vgui/ttt/icon_mac"
end


SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_MAC10

SWEP.Primary.Damage      = 21
SWEP.Primary.Delay       = 0.1
SWEP.Primary.Cone        = 0.05
SWEP.Primary.ClipSize    = 20
SWEP.Primary.ClipMax     = 60
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic   = true
SWEP.Primary.Ammo        = "pistol"
SWEP.Primary.Recoil      = 1.15
SWEP.Primary.Sound       = Sound( "weapons/syndod/fg42_fire.wav" )
local ReloadSound				= Sound ("weapons/syndod/fg42_reload.wav");

SWEP.AutoSpawnable = true

SWEP.AmmoEnt = "item_ammo_pistol_ttt"

SWEP.UseHands			= false
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 45
SWEP.ViewModel  = "models/weapons/syndod/v_mp33.mdl"
SWEP.WorldModel = "models/weapons/syndod/w_mp33.mdl"

SWEP.IronSightsPos = Vector(-3.305, 0, 3.55)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.DeploySpeed = 3

SWEP.HeadshotMultiplier = 2.3

function SWEP:GetHeadshotMultiplier(victim, dmginfo)
   local att = dmginfo:GetAttacker()
   if not IsValid(att) then return 2 end

   local dist = victim:GetPos():Distance(att:GetPos())
   local d = math.max(0, dist - 150)

   -- decay from 3.2 to 1.7
   return 1.7 + math.max(0, (1.5 - 0.002 * (d ^ 1.25)))
end

function SWEP:Reload()
    if (self:Clip1() == self.Primary.ClipSize or
        self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0) then
       return
    end
	self.Weapon:EmitSound( ReloadSound )
    self:DefaultReload(ACT_VM_RELOAD)
    self:SetIronsights(false)
end