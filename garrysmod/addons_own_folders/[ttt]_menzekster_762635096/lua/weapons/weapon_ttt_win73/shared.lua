if SERVER then
   AddCSLuaFile( "shared.lua" )
   resource.AddFile( "materials/vgui/ttt/win73-icon.vmt" )
   resource.AddWorkshop( "420296513" )
end

if CLIENT then
   SWEP.PrintName			= "73 Menzekster"
   SWEP.Slot				= 2
   SWEP.Icon = "vgui/ttt/win73-icon"
end

--Sound file mapping
 if true then
sound.Add({
	name = 			"Weapon_WIN73.Single",
	channel = 		CHAN_USER_BASE+10,
	volume = 		1.0,
	sound = 			"weapons/winchester73/w73-1.wav"
})

sound.Add({
	name = 			"Weapon_WIN73.Hammer",
	channel = 		CHAN_ITEM,
	volume = 		1.0,
	sound = 			"weapons/winchester73/w73hammer.wav"
})

sound.Add({
	name = 			"Weapon_WIN73.Shell",
	channel = 		CHAN_ITEM,
	volume = 		10.0,
	sound = 			"weapons/winchester73/w73insertshell.wav"
})

sound.Add({
	name = 			"Weapon_WIN73.Pump",
	channel = 		CHAN_ITEM,
	volume = 		1.0,
	sound = 			"weapons/winchester73/w73pump.wav"
})
end
-- Always derive from weapon_tttbase
SWEP.Base				= "weapon_tttbase"

-- Standard GMod values
SWEP.Spawnable = true
SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_WIN73

SWEP.Primary.Delay			= 0.55
SWEP.Primary.Recoil			= 1.2
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "357"
SWEP.Primary.Damage = 45
SWEP.Primary.Cone = 0.01
SWEP.Primary.ClipSize = 10
SWEP.Primary.ClipMax = 10
SWEP.Primary.DefaultClip = 10
SWEP.AutoSpawnable      = true
SWEP.AmmoEnt = "item_ammo_357_ttt"
SWEP.HoldType			= "ar2"
SWEP.UseHands			= true
SWEP.ViewModelFlip		= true
SWEP.ViewModelFOV		= 64
SWEP.ViewModel			= "models/weapons/v_winchester1873.mdl"
SWEP.WorldModel			= "models/weapons/w_winchester_1873.mdl"

SWEP.Primary.Sound = Sound( "Weapon_WIN73.Single" )

SWEP.IronSightsPos = Vector(4.356, 8, 2.591)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.SightsPos = Vector(4.356, 0, 2.591)
SWEP.SightsAng = Vector(0, 0, 0)
SWEP.GSightsPos = Vector (0, 0, 0)
SWEP.GSightsAng = Vector (0, 0, 0)
SWEP.RunSightsPos = Vector (-2.3095, -3.0514, 2.3965)
SWEP.RunSightsAng = Vector (-19.8471, -33.9181, 10)

function SWEP:SetZoom(state)
   if CLIENT then return end
   if not (IsValid(self.Owner) and self.Owner:IsPlayer()) then return end
   if state then
      self.Owner:SetFOV(40, 0.3)
   else
      self.Owner:SetFOV(0, 0.2)
   end
end

function SWEP:SecondaryAttack()
   if self.NoSights or (not self.IronSightsPos) or self.dt.reloading then return end
   --if self:GetNextSecondaryFire() > CurTime() then return end

   self:SetIronsights(not self:GetIronsights())

   self:SetNextSecondaryFire(CurTime() + 0.3)
end

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
   if not self.IronSightsPos then return end
   if self:GetNextSecondaryFire() > CurTime() then return end

   local bIronsights = not self:GetIronsights()

   self:SetIronsights( bIronsights )

   if SERVER then
      self:SetZoom( bIronsights )
   end

   self:SetNextSecondaryFire( CurTime() + 0.3 )
end

SWEP.reloadtimer = 0

function SWEP:SetupDataTables()
   self:DTVar("Bool", 0, "reloading")

   return self.BaseClass.SetupDataTables(self)
end

function SWEP:Reload()

   --if self:GetNetworkedBool( "reloading", false ) then return end
   if self.dt.reloading then return end

   if not IsFirstTimePredicted() then return end

   if self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 then

      if self:StartReload() then
         return
      end
   end

end

function SWEP:StartReload()
   --if self:GetNWBool( "reloading", false ) then
   if self.dt.reloading then
      return false
   end

   self:SetIronsights( false )

   if not IsFirstTimePredicted() then return false end

   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   local ply = self.Owner

   if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then
      return false
   end

   local wep = self

   if wep:Clip1() >= self.Primary.ClipSize then
      return false
   end

   wep:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)

   self.reloadtimer =  CurTime() + wep:SequenceDuration()

   --wep:SetNWBool("reloading", true)
   self.dt.reloading = true

   return true
end

function SWEP:PerformReload()
   local ply = self.Owner

   -- prevent normal shooting in between reloads
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then return end

   if self:Clip1() >= self.Primary.ClipSize then return end

   self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
   self:SetClip1( self:Clip1() + 1 )
   self.Weapon:EmitSound("Weapon_WIN73.Shell")
   self:SendWeaponAnim(ACT_VM_RELOAD)

   self.reloadtimer = CurTime() + self:SequenceDuration()
end

function SWEP:FinishReload()
   self.dt.reloading = false
   self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
   self.Weapon:EmitSound("Weapon_WIN73.Shell")
   self.reloadtimer = CurTime() + self:SequenceDuration()
end

function SWEP:CanPrimaryAttack()
   if self:Clip1() <= 0 then
      self:EmitSound( "Weapon_Shotgun.Empty" )
      self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
      return false
   end
   return true
end

function SWEP:Think()
   if self.dt.reloading and IsFirstTimePredicted() then
      if self.Owner:KeyDown(IN_ATTACK) then
         self:FinishReload()
         return
      end

      if self.reloadtimer <= CurTime() then

         if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
            self:FinishReload()
         elseif self:Clip1() < self.Primary.ClipSize then
            self:PerformReload()
         else
            self:FinishReload()
         end
         return
      end
   end
end

function SWEP:Deploy()
   self.dt.reloading = false
   self.reloadtimer = 0
   return self.BaseClass.Deploy(self)
end

function SWEP:PreDrop()
   self:SetZoom(false)
   self:SetIronsights(false)
   return self.BaseClass.PreDrop(self)
end

function SWEP:Holster()
   self:SetIronsights(false)
   self:SetZoom(false)
   return true
end

local Time = CurTime()

function SWEP:AdjustMouseSensitivity()
	if self:GetIronsights() == false then
		return 1
	elseif self:GetIronsights() == true then
		return 0.3
	end
end

function SWEP:GetHeadshotMultiplier(victim, dmginfo)
   local att = dmginfo:GetAttacker()
   if not IsValid(att) then return 3 end

   local dist = victim:GetPos():Distance(att:GetPos())
   local d = math.max(0, dist - 350)

   -- decay from 3.1 to 1 slowly as distance increases
   return 1 + math.max(0, (1.5 - 0.002 * (d ^ 1.25)))
end
