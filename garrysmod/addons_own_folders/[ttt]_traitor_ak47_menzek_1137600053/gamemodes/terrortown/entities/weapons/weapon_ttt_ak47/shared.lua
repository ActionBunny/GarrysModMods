--[[Author informations]]--
SWEP.Author = "Zaratusa"
SWEP.Contact = "http://steamcommunity.com/profiles/76561198032479768"

if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop("253736148")
else
	LANG.AddToLanguage("english", "ak47_name", "AK47")
	LANG.AddToLanguage("english", "ak47_desc", "Very high damage assault rifle.\n\nHas very high recoil.")

	SWEP.PrintName = "ak47_name"
	SWEP.Slot = 6
	SWEP.Icon = "vgui/ttt/icon_ak47"

	-- client side model settings
	SWEP.UseHands = true -- should the hands be displayed
	SWEP.ViewModelFlip = false -- should the weapon be hold with the left or the right hand
	SWEP.ViewModelFOV = 50

	-- equipment menu information is only needed on the client
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "ak47_desc"
	}
end

-- always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

--[[Default GMod values]]--
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Delay = 0.1
SWEP.Primary.Recoil = 1.3
SWEP.Primary.Cone = 0.025
SWEP.Primary.Damage = 23
SWEP.Primary.Automatic = true
SWEP.Primary.ClipSize = 30
SWEP.Primary.ClipMax = 60
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Sound = Sound("Weapon_AK47.Single")

--[[Model settings]]--
SWEP.HoldType = "ar2"
SWEP.ViewModel = Model("models/weapons/cstrike/c_rif_ak47.mdl")
SWEP.WorldModel = Model("models/weapons/w_rif_ak47.mdl")

SWEP.IronSightsPos = Vector(-6.56, -11, 2.4)
SWEP.IronSightsAng = Vector(2.4, 0, 0)

--[[TTT config values]]--

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_EQUIP1

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2,
-- then this gun can be spawned as a random weapon.
SWEP.AutoSpawnable = false

-- The AmmoEnt is the ammo entity that can be picked up when carrying this gun.
SWEP.AmmoEnt = "item_ammo_smg1_ttt"

-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.
SWEP.CanBuy = { ROLE_TRAITOR }

-- If LimitedStock is true, you can only buy one per round.
SWEP.LimitedStock = true

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = true

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = false

-- add some zoom to the scope for this gun
function SWEP:SecondaryAttack()
	if (self.IronSightsPos and self:GetNextSecondaryFire() <= CurTime()) then
		self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
		self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

		local bIronsights = not self:GetIronsights()
		self:SetIronsights(bIronsights)
		if SERVER then
			self:SetZoom(bIronsights)
		end
	end
end

function SWEP:SetZoom(state)
	if (SERVER and IsValid(self.Owner) and self.Owner:IsPlayer()) then
		if (state) then
			self.Owner:SetFOV(35, 0.5)
		else
			self.Owner:SetFOV(0, 0.2)
		end
	end
end

function SWEP:ResetIronSights()
	self:SetIronsights(false)
	self:SetZoom(false)
end

function SWEP:PreDrop()
	self:ResetIronSights()
	return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
	if (self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0) then
		self:DefaultReload(self.ReloadAnim)
		self:ResetIronSights()
	end
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW_SILENCED)
	self:ResetIronSights()
	return true
end

function SWEP:Holster()
	self:ResetIronSights()
	return true
end
