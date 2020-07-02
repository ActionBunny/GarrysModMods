AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local explodeSound = Sound("drachenbomb/meddl5.ogg")

function ENT:Initialize()
    self:PhysicsInitSphere(25) 
	
	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:EnableCustomCollisions(true)
	self:PhysWake()
	self:DrawShadow(false)
	
	local explode = ents.Create("env_explosion")

	timer.Simple(2, 
		function()
			if(!IsValid(self.Entity)) then return end
			local explode = ents.Create("env_explosion")
			explode:SetPos( self:GetPos() )
			explode:Spawn()
			explode:SetKeyValue("0", "0")
			explode:Fire("Explode", 0, 0)
			self.Entity:EmitSound(explodeSound, 100, 100, 1)
			
			local ent = ents.Create( "weapon_ttt_drachenbomb")
			util.BlastDamage( ent, self:GetThrower(), self:GetPos(), 450, 250 )
			ent:Remove()
			
			self:Remove()
		end)
end
