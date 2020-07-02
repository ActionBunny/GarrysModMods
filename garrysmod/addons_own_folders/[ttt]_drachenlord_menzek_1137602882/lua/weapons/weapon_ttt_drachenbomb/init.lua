AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

metaEnts = FindMetaTable( "Entity")
AccessorFunc( metaEnts, "thrower", "Thrower" )


local wepSwitchSound = Sound("drachenbomb/meddl.ogg")
local shootSound = Sound("drachenbomb/meddl0.ogg")
local secSound = Sound("drachenbomb/meddl3.ogg")


function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 5.0)
	local melon = ents.Create("ent_drachenbullet")
	melon:SetPos(self.Owner:EyePos())
	melon:Spawn()
	melon:SetThrower( self.Owner )
	
	local p = melon:GetPhysicsObject()
	if(!IsValid(p)) then return end

	local velocity = self.Owner:GetAimVector()
	p:ApplyForceCenter(velocity*50000)
	self.Owner:EmitSound(shootSound, 100, 100, 1)
	self.Owner:StripWeapon("weapon_ttt_drachenbomb")
end


function SWEP:SecondaryAttack()
	self.Owner:EmitSound(secSound, 75, 100, 1)
end

function SWEP:Deploy()
	self.Owner:EmitSound(wepSwitchSound, 75, 100, 1 )
end