
AddCSLuaFile()

SWEP.HoldType = "ar2"

if CLIENT then

   SWEP.PrintName = "Gewehr 43"
   SWEP.Slot = 2

   SWEP.Icon = "vgui/entities/icon_gewehr"
end


SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_MAC10

SWEP.Primary.Damage      = 29
SWEP.Primary.Delay       = 0.14
SWEP.Primary.Cone        = 0.01
SWEP.Primary.ClipSize    = 12
SWEP.Primary.ClipMax     = 36
SWEP.Primary.DefaultClip = 12
SWEP.Primary.Automatic   = false
SWEP.Primary.Ammo        = "pistol"
SWEP.Primary.Recoil      = 0.8
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

SWEP.DeploySpeed = 1

function SWEP:GetHeadshotMultiplier(victim, dmginfo)
   local att = dmginfo:GetAttacker()
   if not IsValid(att) then return 2 end

   local dist = victim:GetPos():Distance(att:GetPos())
   local d = math.max(0, dist - 150)

   -- decay from 3.2 to 1.7
   return 1.7 + math.max(0, (1.1 - 0.002 * (d ^ 1.25)))
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
--[[
function SWEP:DrawHUD()
      if self.HUDHelp then
         self:DrawHelp()
      end

      local client = LocalPlayer()
      if (not IsValid(client)) or ( self.Weapon:GetNetworkedBool( "Ironsights" ) ) then return end

      local sights = (not self.NoSights) and self:GetIronsights()

      local x = math.floor(ScrW() / 2.0)
      local y = math.floor(ScrH() / 2.0)
      local scale = math.max(0.2,  10 * self:GetPrimaryCone())

      local LastShootTime = self:LastShootTime()
      scale = scale * (2 - math.Clamp( (CurTime() - LastShootTime) * 5, 0.0, 1.0 ))

      local alpha = sights and sights_opacity:GetFloat() or 1
      local bright = 1

      -- somehow it seems this can be called before my player metatable
      -- additions have loaded
      if client.IsTraitor and client:IsTraitor() then
         surface.SetDrawColor(255 * bright,
                              50 * bright,
                              50 * bright,
                              255 * alpha)
      else
         surface.SetDrawColor(0,
                              255 * bright,
                              0,
                              255 * alpha)
      end

      local gap = math.floor(20 * scale * (sights and 0.8 or 1))
      local length = math.floor(gap + (25 * crosshair_size:GetFloat()) * scale)
      surface.DrawLine( x - length, y, x - gap, y )
      surface.DrawLine( x + length, y, x + gap, y )
      surface.DrawLine( x, y - length, x, y - gap )
      surface.DrawLine( x, y + length, x, y + gap )
end--]]
if CLIENT then
	function SWEP:DrawHUD()
		if self:GetIronsights() and (GetConVar("ww2_crosshair"):GetInt() == 1)  then
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

function SWEP:AdjustMouseSensitivity()
	if self:GetIronsights() == false then
		return 1
	elseif self:GetIronsights() == true then
		return 0.6
	end
end