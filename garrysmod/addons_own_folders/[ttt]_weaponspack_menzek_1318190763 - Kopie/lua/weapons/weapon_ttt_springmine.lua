
if SERVER then
   AddCSLuaFile()
	AddCSLuaFile( "weapon_ttt_springmine.lua" )
	AddCSLuaFile( "entities/ttt_spring_mine/cl_init.lua" )
	AddCSLuaFile( "entities/ttt_spring_mine/init.lua" )
	AddCSLuaFile( "entities/ttt_spring_mine/shared.lua" )
   util.AddNetworkString("TTT_SpringMineWarning")
end

local metaEnt = FindMetaTable("Entity")
AccessorFunc( metaEnt, "defowner", "DefOwn" )

if CLIENT then
   SWEP.PrintName = "Spring Mine"
   SWEP.Slot = 6

   SWEP.ViewModelFOV = 10

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "BOIINNNNNG!"
   };

   SWEP.Icon = "VGUI/ttt/icon_cyb_springmine.png"
end

SWEP.Base = "weapon_tttbase"

SWEP.ViewModel          = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel         = "models/props/cs_office/microwave.mdl" --tochange

SWEP.HoldType = "normal"

SWEP.DrawCrosshair      = false
SWEP.Primary.ClipSize       = 2
SWEP.Primary.DefaultClip    = 2
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo       = "none"
SWEP.Primary.Delay = 0.1

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo     = "none"
SWEP.Secondary.Delay = 1.0

-- This is special equipment


SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR} -- only detectives can buy
SWEP.LimitedStock = true -- only buyable once
SWEP.WeaponID = AMMO_JUMPMINE

SWEP.AllowDrop = false

SWEP.NoSights = true

function SWEP:PrimaryAttack()
   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   self:MineDrop()
end
function SWEP:SecondaryAttack()
   --self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
   --self:MineDrop()
end

local throwsound = Sound( "Weapon_SLAM.SatchelThrow" )
function SWEP:MineDrop()
   if SERVER then
      local ply = self.Owner
	  
      if not IsValid(ply) then return end

     -- if self.Planted then return end

      local vsrc = ply:GetShootPos()
      local vang = ply:GetAimVector()
      local vvel = ply:GetVelocity()
      
      local vthrow = vvel + vang * 200

      local mine = ents.Create("ttt_spring_mine")

	  mine:SetDefOwn( self.Owner )
      if IsValid(mine) then
         mine:SetPos(vsrc + vang * 10)

		 mine:Spawn()
		
         mine:PhysWake()
         local phys = mine:GetPhysicsObject()
         if IsValid(phys) then
            phys:SetVelocity(vthrow)
         end
		 
		 
		self:TakePrimaryAmmo(1)
		--self:Reload()

		if SERVER then
			if self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) < 1 then
				self.Owner:StripWeapon("weapon_ttt_springmine")
			end
		end

        -- self.Planted = true
      end
   end
	
   self.Weapon:EmitSound(throwsound)
   
end


function SWEP:Reload()
   return false
end

function SWEP:OnRemove()
   if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
      RunConsoleCommand("lastinv")
   end
end

if CLIENT then
   function SWEP:Initialize()
      LANG.AddToLanguage("english", "springmine_help", "Press {primaryfire} to deploy the Spring Mine.")
      self:AddHUDHelp("springmine_help", nil, true)

      return self.BaseClass.Initialize(self)
   end
end

function SWEP:Deploy()
   if SERVER and IsValid(self.Owner) then
      self.Owner:DrawViewModel(false)
   end
   return true
end

function SWEP:DrawWorldModel()
end

function SWEP:DrawWorldModelTranslucent()
end

