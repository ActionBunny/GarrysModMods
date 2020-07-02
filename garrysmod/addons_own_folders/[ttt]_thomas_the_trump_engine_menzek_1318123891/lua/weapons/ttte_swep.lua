AddCSLuaFile()

SWEP.PrintName				= "Thomas The Trump Engine"
SWEP.Author					= "Thendon.exe, edited by Conner"
SWEP.Instructions			= "Obamacare."
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Slot				= 6
SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_EQUIP1
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.InLoadoutFor = nil
SWEP.LimitedStock = true

SWEP.AllowDrop = true
SWEP.IsSilent = false
SWEP.NoSights = false
SWEP.AutoSpawnable = false
SWEP.HoldType = "pistol"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Weight					= 7
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false
SWEP.Used = false
SWEP.ViewModel				= "models/weapons/v_pist_deagle.mdl"
SWEP.WorldModel				= "models/weapons/w_pist_deagle.mdl"

if CLIENT then
   SWEP.Icon = "ttte/ttte_ttt_icon.png"
   SWEP.EquipMenuData = {
	   type = "Thomas The Trump Engine",
	   desc = "Obamacare."
   };
end

function SWEP:Precache()
	util.PrecacheSound( "thomas_bell" )
  for i = 1, 5 do
	   util.PrecacheSound( "thomas_trump_0"..i )
  end
end

function SWEP:PrimaryAttack()
	if self.Used == true then return end
	self.Used = true
	
	self:EmitSound( "thomas_bell" )

	if ( CLIENT ) then return end

	local ent = ents.Create( "ttte_ent" )
	if !IsValid( ent ) then return end

	ent:SetPos( self.Owner:EyePos() + self.Owner:GetAimVector() * 200 )
	ent:SetAngles( self.Owner:EyeAngles() )
  ent:SetOwner( self.Owner )
  ent.SWEP = self
  math.randomseed(CurTime())
  ent.Sound = "thomas_trump_0"..tostring(math.random(1, 5))
	ent:Spawn()
  --self:Remove()
end
