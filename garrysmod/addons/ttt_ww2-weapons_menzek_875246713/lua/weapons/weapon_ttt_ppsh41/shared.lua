
AddCSLuaFile()

SWEP.HoldType = "ar2"

if CLIENT then

   SWEP.PrintName = "PPSH-41"
   SWEP.Slot = 2

   SWEP.Icon = "vgui/entities/icon_ppsh"
end


SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_MAC10

SWEP.Primary.Damage      = 20
SWEP.Primary.Delay       = 0.09
SWEP.Primary.Cone        = 0.03
SWEP.Primary.ClipSize    = 51
SWEP.Primary.ClipMax     = 51
SWEP.Primary.DefaultClip = 51
SWEP.Primary.Automatic   = true
SWEP.Primary.Ammo        = "smg1"
SWEP.Primary.Recoil      = 1
SWEP.Primary.Sound       = Sound( "weapons/syndod/ppsh_fire.wav" )
local ReloadSound				= Sound ("weapons/syndod/ppsh_reload.wav");

SWEP.AutoSpawnable = true

SWEP.AmmoEnt = "item_ammo_smg1_ttt"

SWEP.UseHands			= false
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 45
SWEP.ViewModel  = "models/weapons/syndod/v_thompsoh.mdl"
SWEP.WorldModel = "models/weapons/syndod/w_ppsh1941.mdl"

SWEP.IronSightsPos = Vector(-4.53, -10, 4.1)
SWEP.IronSightsAng = Vector(.1, 0, 0)

SWEP.DeploySpeed = 2

--SWEP.HeadshotMultiplier = 2

function SWEP:GetHeadshotMultiplier(victim, dmginfo)
   local att = dmginfo:GetAttacker()
   if not IsValid(att) then return 2 end

   local dist = victim:GetPos():Distance(att:GetPos())
   local d = math.max(0, dist - 150)

   -- decay from 3.2 to 1.7
   return 1.9 + math.max(0, (0.5 - 0.002 * (d ^ 1.25)))
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

if CLIENT then
	function SWEP:DrawHUD()
		if self:GetIronsights()  and (GetConVar("ww2_crosshair"):GetInt() == 1) then
			local x = math.floor(ScrW() / 2.0)
			local y = math.floor(ScrH() / 2.0)
			
			if self.Owner:IsTraitor() then
				surface.SetDrawColor(255, 50, 50, 255)
			else
				surface.SetDrawColor(0, 255, 0, 255)
			end
			
			local r = 1
			if self.Owner:IsTraitor() then
				surface.DrawCircle( x, y, r, 255, 50, 50, 255 )
			else
				surface.DrawCircle( x, y, r, 0, 255, 0, 255 )
			end
		else
			return self.BaseClass.DrawHUD(self)
		end
	end
end