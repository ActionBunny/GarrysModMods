AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.SeizeReward = 350

function ENT:Initialize()
	self:SetModel("models/raygun/ray_gun_battery.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	self.CanUse = true
	self.ShareGravgun = true
end

function ENT:Use(activator,caller)
	player.GetByID( 1 ):GiveAmmo( 20, "raygun", false )
	self:Remove()
end
