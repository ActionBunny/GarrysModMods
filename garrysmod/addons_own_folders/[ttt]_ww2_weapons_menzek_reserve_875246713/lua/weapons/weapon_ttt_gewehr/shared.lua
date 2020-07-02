
AddCSLuaFile()

SWEP.HoldType = "ar2"

if CLIENT then

   SWEP.PrintName = "Gewehr 43"
   SWEP.Slot = 2

   SWEP.Icon = "vgui/ttt/icon_mac"
end


SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_MAC10

SWEP.Primary.Damage      = 30
SWEP.Primary.Delay       = 0.12
SWEP.Primary.Cone        = 0.02
SWEP.Primary.ClipSize    = 10
SWEP.Primary.ClipMax     = 40
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic   = false
SWEP.Primary.Ammo        = "pistol"
SWEP.Primary.Recoil      = 1.15
SWEP.Primary.Sound       = Sound( "weapons/syndod/gewehr43_fire.wav" )
local ReloadSound				= Sound ("weapons/syndod/gewehr43_reload.wav");

SWEP.AutoSpawnable = true

SWEP.AmmoEnt = "item_ammo_pistol_ttt"

SWEP.UseHands			= false
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 45
SWEP.ViewModel  = "models/weapons/syndod/v_k9g.mdl"
SWEP.WorldModel = "models/weapons/syndod/w_k9g.mdl"

SWEP.IronSightsPos = Vector(-6.66, -10, 5.7)
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