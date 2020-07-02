AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	
	self:SetModel( "models/jaanus/shuriken_small.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	util.PrecacheSound("physics/metal/sawblade_stick3.wav")
	util.PrecacheSound("physics/metal/sawblade_stick2.wav")
	util.PrecacheSound("physics/metal/sawblade_stick1.wav")
	util.PrecacheSound("weapons/shuriken/hit1.wav")
	util.PrecacheSound("weapons/shuriken/hit2.wav")
	util.PrecacheSound("weapons/shuriken/hit3.wav")
	self.Hit = { 
	Sound( "physics/metal/sawblade_stick1.wav" ),
	Sound( "physics/metal/sawblade_stick2.wav" ),
	Sound( "physics/metal/sawblade_stick3.wav" ) };
	self.FleshHit = { 
	Sound( "weapons/shuriken/hit1.wav" ),
	Sound( "weapons/shuriken/hit2.wav" ),
	Sound( "weapons/shuriken/hit3.wav" ) }
	self:GetPhysicsObject():SetMass( 2 )	
end

function ENT:Think()
	
	self.lifetime = self.lifetime or CurTime() + 20
	if CurTime() > self.lifetime then
		self:Remove()
	end
end

function ENT:Disable()
	self.PhysicsCollide = function()end
	self.lifetime = CurTime() + 30
end

function ENT:PhysicsCollide( data, phys )
	
	if self:GetVelocity():Length() < 250 then
		self:Disable()
		return
	end
	local Ent = data.HitEntity
	if !(IsValid( Ent ) || Ent:IsWorld()) then return end
	if Ent:IsWorld() then
		data.OurOldVelocity:Normalize()
		if data.OurOldVelocity:Dot( data.HitNormal ) > .5 then
			self:SetPos( data.HitPos )
			self:SetAngles( data.OurOldVelocity:Angle() )
			self:GetPhysicsObject():EnableMotion( false )
			util.Decal( "ManhackCut", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal )
			self:EmitSound( self.Hit[math.random(1,#self.Hit)] );
		end
		self:Disable()
	elseif Ent.Health then
		if not(Ent:IsPlayer() || Ent:IsNPC() || Ent:GetClass() == "prop_ragdoll") then 
			util.Decal( "ManhackCut", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal )
			self:EmitSound( self.Hit[math.random(1,#self.Hit)] );
		end
		
		local shurikenent = ents.Create( "weapon_ttt_shurikens")
		
		Ent:TakeDamage( 70, self:GetOwner(), shurikenent )
		
		shurikenent:Remove()
		
		self:SetPos( data.HitPos )
		self:SetParent( Ent )
		Ent:DeleteOnRemove( self )
		self:Disable()
		if (Ent:IsPlayer() || Ent:IsNPC() || Ent:GetClass() == "prop_ragdoll") then 
			local effectdata = EffectData()
			effectdata:SetStart( data.HitPos )
			effectdata:SetOrigin( data.HitPos )
			effectdata:SetScale( 1 )
			util.Effect( "BloodImpact", effectdata )
			self:EmitSound( self.FleshHit[math.random(1,#self.Hit)] );
			self:Remove() --Comment this line out if you want the shurikens to stick in ragdolls/npcs (shittily)
		end
	end
	
end
