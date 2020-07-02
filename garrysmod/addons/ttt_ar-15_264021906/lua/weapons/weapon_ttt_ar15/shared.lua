

if SERVER then

   AddCSLuaFile( "shared.lua" )
end

SWEP.HoldType			= "ar2"


if CLIENT then

   SWEP.PrintName			= "AR-15"
   SWEP.Slot				= 2

   SWEP.Icon = "VGUI/ttt/icon_m16"
end


SWEP.Base				= "weapon_tttbase"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_M16

SWEP.Primary.Delay			= 0.19
SWEP.Primary.Recoil			= 1.6
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Damage = 23
SWEP.Primary.Cone = 0.018
SWEP.Primary.ClipSize = 20
SWEP.Primary.ClipMax = 60
SWEP.Primary.DefaultClip = 20
SWEP.AutoSpawnable      = true
SWEP.AmmoEnt = "item_ammo_pistol_ttt"

SWEP.UseHands			= true
SWEP.ViewModelFlip		= true
SWEP.ViewModelFOV		= 64
SWEP.ViewModel			= "models/weapons/v_rif_ar15.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_ar15.mdl"

--SWEP.Primary.Sound = Sound( "Weapon_AK47.Single" )

SWEP.IronSightsPos = Vector(2.635, 10.2, 2.26)
SWEP.IronSightsAng = Vector(2.599, -1.3, -3.6)

sound.Add{
    name="vomit",
    channel=CHAN_STATIC,
    volume=1,
    level=120,
    pitch=100,
    sound="Vomit_sounds.wav"
}

sound.Add{
    name="fart1",
    channel=CHAN_STATIC,
    volume=1,
    level=120,
    pitch=100,
    sound="furz1.wav"
}

sound.Add{
    name="fart1",
    channel=CHAN_STATIC,
    volume=1,
    level=120,
    pitch=100,
    sound="furz2.wav"
}

sound.Add{
    name="fart3",
    channel=CHAN_STATIC,
    volume=1,
    level=120,
    pitch=100,
    sound="furz3.wav"
}

fireSounds = {"fart1", "fart2", "fart3"}
local vomitChance = 0.01

function SWEP:SetZoom(state)
   if CLIENT then return end
   if not (IsValid(self.Owner) and self.Owner:IsPlayer()) then return end
   if state then
      self.Owner:SetFOV(35, 0.5)
   else
      self.Owner:SetFOV(0, 0.2)
   end
end

function SWEP:PrimaryAttack()
    wep = self.Weapon
    if(math.random() > (1 - vomitChance)) then
        wep:EmitSound("vomit")
    else
        wep:EmitSound(table.Random(fireSounds))
    end
   -- return self.BaseClass.PrimaryAttack()
end

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
   if not self.IronSightsPos then return end
   if self.Weapon:GetNextSecondaryFire() > CurTime() then return end

   bIronsights = not self:GetIronsights()

   self:SetIronsights( bIronsights )

   if SERVER then
      self:SetZoom(bIronsights)
   end

   self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:PreDrop()
   self:SetZoom(false)
   self:SetIronsights(false)
   return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
   self.Weapon:DefaultReload( ACT_VM_RELOAD );
   self:SetIronsights( false )
   self:SetZoom(false)
end


function SWEP:Holster()
   self:SetIronsights(false)
   self:SetZoom(false)
   return true
end


