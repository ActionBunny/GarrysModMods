
AddCSLuaFile()

SWEP.HoldType = "ar2"

if CLIENT then

   SWEP.PrintName = "M1919"
   SWEP.Slot = 2

   SWEP.Icon = "vgui/ttt/icon_mac"
end


SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_MAC10

SWEP.Primary.Damage      = 13
SWEP.Primary.Delay       = 0.1
SWEP.Primary.Cone        = 0.06
SWEP.Primary.ClipSize    = 250
SWEP.Primary.ClipMax     = 250
SWEP.Primary.DefaultClip = 250
SWEP.Primary.Automatic   = true
SWEP.Primary.Ammo        = "AirboatGun"
SWEP.Primary.Recoil      = 2	
SWEP.Primary.Sound       = Sound( "weapons/syndod/30cal_fire.wav" )
local ReloadSound				= Sound ("weapons/syndod/30cal_reload.wav");

SWEP.AutoSpawnable = true

SWEP.UseHands			= false
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 45
SWEP.ViewModel  = "models/weapons/syndod/v_30cal.mdl"
SWEP.WorldModel = "models/weapons/syndod/w_30cal.mdl"

SWEP.IronSightsPos = Vector(0, 0, 0)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.DeploySpeed = 3

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