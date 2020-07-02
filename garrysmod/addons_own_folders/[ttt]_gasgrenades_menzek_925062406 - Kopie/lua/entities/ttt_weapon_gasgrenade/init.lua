// this was a cse flashbang.
CreateConVar( "ttt_gasgrenade_radius", "800", FCVAR_NOTIFY + FCVAR_ARCHIVE , "Adjust the radius of Gas." )
CreateConVar( "ttt_gasgrenade_damage", "10", FCVAR_NOTIFY + FCVAR_ARCHIVE , "Adjust the damage of Gas." )
local damage = GetConVar("ttt_gasgrenade_damage"):GetFloat()
local radius = GetConVar("ttt_gasgrenade_radius"):GetFloat()


AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()

	self.Entity:SetModel("models/weapons/w_eq_smokegrenade.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( false )
	
	-- Don't collide with the player
	-- too bad this doesn't actually work.
	self.Entity:SetCollisionGroup( COLLISION_GROUP_NONE )
	
	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Sleep()
	end
	
	self.timer = CurTime() + 6
	self.solidify = CurTime() + 1
	self.Bastardgas = nil
	self.Spammed = false
end

function GasGrenadePoison(ent, Owner, nade)
	if (ent:Health() > 0) then
		ent:TakeDamage(damage, Owner, nade)
		ent:ViewPunch( Angle( math.random( -5, 5 ), math.random( -5, 5 ), math.random( -5, 5 ) ) )
	end
end
					
function ENT:Think()
	if (IsValid(self.Owner)==false) then
		self.Entity:Remove()
	end
	if (self.solidify<CurTime()) then
		self.SetOwner(self.Entity)
	end
	if self.timer < CurTime() then
		
		if !IsValid(self.Bastardgas) && !self.Spammed then
			self.Spammed = true
			self.Bastardgas = ents.Create("env_smoketrail")
			self.Bastardgas:SetOwner(self.Owner)
			self.Bastardgas:SetPos(self.Entity:GetPos())
			self.Bastardgas:SetKeyValue("spawnradius", radius + 30)
			self.Bastardgas:SetKeyValue("minspeed","15")
			self.Bastardgas:SetKeyValue("maxspeed","20")
			self.Bastardgas:SetKeyValue("startsize", radius + 30)
			self.Bastardgas:SetKeyValue("endsize", radius + 30)
			self.Bastardgas:SetKeyValue("endcolor","170 205 70")
			self.Bastardgas:SetKeyValue("startcolor","150 205 70")
			self.Bastardgas:SetKeyValue("opacity","1")
			self.Bastardgas:SetKeyValue("spawnrate", "180" )
			self.Bastardgas:SetKeyValue("lifetime","10")
			self.Bastardgas:SetParent(self.Entity)
			self.Bastardgas:Spawn()
			self.Bastardgas:Activate()
			self.Bastardgas:Fire("turnon","", 0.1)
			
			local exp = ents.Create("env_explosion")
			exp:SetKeyValue("spawnflags",461)
			exp:SetPos(self.Entity:GetPos())
			exp:Spawn()
			exp:Fire("explode","",0)
			self.Entity:EmitSound(Sound("BaseSmokeEffect.Sound"))
		end

		local pos = self.Entity:GetPos()
		local maxrange = radius
		local maxstun = 10
		for k,v in pairs(ents.GetAll()) do
			if v:IsPlayer() == true then
				local plpos = v:GetPos()
				local dist = pos:Distance(plpos)
				if ( dist < maxrange) then
					--GasGrenadePoison(v, self.Owner, self)--, self.Owner, "weapon_ttt_shortgasgrenade")
				end
			end	
		end
		if (self.timer+60<CurTime()) then
			if IsValid(self.Bastardgas) then
				self.Bastardgas:Remove()
			end
		end
		if (self.timer+65<CurTime()) then
			self.Entity:Remove()
		end
		self.Entity:NextThink(CurTime()+0.5)
		return true
	end
end

