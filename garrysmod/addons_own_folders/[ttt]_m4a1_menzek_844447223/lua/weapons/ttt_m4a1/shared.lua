resource.AddFile ("models/weapons/v_c4_m4a1.mdl")
resource.AddFile ("models/weapons/v_c4_m4a1.vvd")
resource.AddFile ("models/weapons/m4a1/w_m4a1.vvd")
resource.AddFile ("models/weapons/m4a1/w_m4a1.mdl")
resource.AddFile ("models/weapons/m4a1/w_m4a1.phy")
-- Variables that are used on both client and server
SWEP.Gun 					= ("ttt_m4a1") -- must be the name of your swep but NO CAPITALS!
SWEP.Category				= "Call Of Duty 4" --Category where you will find your weapons
SWEP.Author					= ""
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Instructions			= ""
SWEP.PrintName				= "M4A1 Menzek"	-- Weapon name (Shown on HUD)
SWEP.Slot					= 2			-- Slot in the weapon selection menu
SWEP.SlotPos				= 3			-- Position in the slot
SWEP.DrawAmmo				= true		-- Should draw the default HL2 ammo counter
SWEP.DrawWeaponInfoBox		= false		-- Should draw the weapon info box
SWEP.BounceWeaponIcon   	= false		-- Should the weapon icon bounce?
SWEP.DrawCrosshair			= false		-- set false if you want no crosshair
SWEP.Weight					= 30		-- rank relative ot other weapons. bigger is better
SWEP.AutoSwitchTo			= true		-- Auto switch to if we pick it up
SWEP.AutoSwitchFrom			= true		-- Auto switch from if you pick up a better weapon
SWEP.HoldType 				= "ar2"		-- how others view you carrying the weapon
-- normal melee melee2 fist knife smg ar2 pistol rpg physgun grenade shotgun crossbow slam passive
-- you're mostly going to use ar2, smg, shotgun or pistol. rpg makes for good sniper rifles

SWEP.ViewModelFOV			= 70
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/v_c4_m4a1.mdl"	-- Weapon view model
SWEP.WorldModel				= "models/weapons/m4a1/w_m4a1.mdl"	-- Weapon world model
SWEP.ShowWorldModel			= true
--SWEP.Base					= "mw_gun_base" --the Base this weapon will work on. PLEASE RENAME THE BASE!
SWEP.Spawnable				= true
SWEP.AdminOnly				= false
SWEP.FiresUnderwater 		= false

SWEP.Base 					= "weapon_tttbase"
SWEP.Kind 					= WEAPON_HEAVY
SWEP.AllowDrop 				= true
SWEP.IsSilent 				= false
SWEP.NoSights 				= false
SWEP.AutoSpawnable 			= true

SWEP.Icon = "vgui/ttt/m4icon.png"

if SERVER then
	resource.AddFile("materials/vgui/ttt/m4icon.png")
end

SWEP.Primary.Sound			= Sound( "Weapon_CM4.Single" )		-- Script that calls the primary fire sound
SWEP.Primary.RPM			= 700			-- This is in Rounds Per Minute
SWEP.Primary.ClipSize			= 30		-- Size of a clip
SWEP.Primary.ClipMax			= 90
SWEP.Primary.DefaultClip		= 30		-- Bullets you start with
SWEP.Primary.KickUp				= 0.08		-- Maximum up recoil (rise)
SWEP.Primary.KickDown			= 0.08		-- Maximum down recoil (skeet)
SWEP.Primary.KickHorizontal		= 0.08		-- Maximum up recoil (stock)
SWEP.Primary.Automatic			= true		-- Automatic = true; Semi Auto = false
SWEP.AmmoEnt 					= "item_ammo_smg1_ttt"
SWEP.Primary.Ammo				= "smg1"			-- pistol, 357, smg1, ar2, buckshot, slam, SniperPenetratedRound, AirboatGun
-- Pistol, buckshot, and slam always ricochet.
--Use AirboatGun for a light metal peircing shotgun pellets
SWEP.SelectiveFire		= true
SWEP.CanBeSilenced		= false

SWEP.Secondary.IronFOV			= 20		-- How much you 'zoom' in. Less is more!

SWEP.data 				= {}				--The starting firemode
SWEP.data.ironsights			= 1

SWEP.Primary.Damage		= 19	-- Base damage per bullet
SWEP.Primary.Spread		= .05	-- Define from-the-hip accuracy 1 is terrible, .0001 is exact)
SWEP.Primary.IronAccuracy = .005 -- Ironsight accuracy, should be the same for shotguns

-- Enter iron sight info and bone mod info below


SWEP.IronSightsPos = Vector(-7.55, 0, 4.6)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.SightsPos = Vector(-2.3655, 0, 0.7008)
SWEP.SightsAng = Vector(0, 0, 0)
SWEP.RunSightsPos = Vector(4.679, -1.441, 3.68)
SWEP.RunSightsAng = Vector(-12.101, 34.5, 0)

/*---------------------------------------------------------
Reload
---------------------------------------------------------*/
function SWEP:Reload()

if ( self.Weapon:Clip1() < self.Primary.ClipSize ) and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
self.Owner:SetFOV( 0, 0.15 )
self:SetIronsights(false, self.Owner)
if ( self.Weapon:Clip1() <= 0 ) then
self.Weapon:DefaultReload(ACT_VM_RELOAD_EMPTY)
else
self.Weapon:DefaultReload(ACT_VM_RELOAD)
end
end
end

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
      local bright = crosshair_brightness:GetFloat() or 1

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
   end