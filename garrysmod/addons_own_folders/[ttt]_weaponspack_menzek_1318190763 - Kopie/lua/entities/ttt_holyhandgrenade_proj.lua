if SERVER then
	AddCSLuaFile("ttt_holyhandgrenade_proj.lua")
	resource.AddFile("sound/holyhandgrenade.wav")
	resource.AddFile( "models/weapons/v_eq_fraggrenad2.mdl" )
	resource.AddFile( "models/weapons/w_eq_fraggrenad2.mdl" )   
	resource.AddFile( "models/weapons/w_eq_fraggrenade_throw2.mdl" )	
	resource.AddFile( "sound/weapons/hhg/explosion1.wav" )
	resource.AddFile( "sound/weapons/hhg/explosion2.wav" )
	resource.AddFile( "sound/weapons/hhg/explosion3.wav" )
	resource.AddFile( "sound/weapons/hhg/Holy Water Bounce.wav" )
	resource.AddFile( "sound/weapons/hhg/Holy Water Deploy.wav" )
	resource.AddFile( "sound/weapons/hhg/Holy Water Pin.wav" )
	resource.AddFile( "sound/weapons/hhg/holygrenade.wav" )   
end
util.PrecacheSound( "weapons/hhg/holygrenade.wav" )
util.PrecacheSound( "sound/weapons/hhg/explosion1.wav" )
util.PrecacheSound( "sound/weapons/hhg/explosion2.wav" )
util.PrecacheSound( "sound/weapons/hhg/explosion3.wav" )
ENT.Icon = "VGUI/ttt/icon_cyb_holyhandgrenade.png"
ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"
ENT.Model = Model("models/weapons/w_eq_fraggrenade_throw2.mdl")
ENT.Radius = 700
ENT.Damage = 300

local ttt_allow_jump = CreateConVar("ttt_allow_discomb_jump", "0")
--AccessorFunc( ENT, "radius", "Radius", FORCE_NUMBER )
--AccessorFunc( ENT, "dmg", "Dmg", FORCE_NUMBER )


function ENT:PhysicsCollide(data, phys)

	if data.Speed > 70 then
		self.Entity:EmitSound("weapons/hhg/Holy Water Bounce.wav",70)	
	end
	
	local impulse = -data.Speed * data.HitNormal * 0.2 + (data.OurOldVelocity * -0.4)
	phys:ApplyForceCenter(impulse)
end

local function PushPullRadius(pos, pusher)
   local radius = 400
   local phys_force = 1500
   local push_force = 256

   -- pull physics objects and push players
   for k, target in pairs(ents.FindInSphere(pos, radius)) do
      if IsValid(target) then
         local tpos = target:LocalToWorld(target:OBBCenter())
         local dir = (tpos - pos):GetNormal()
         local phys = target:GetPhysicsObject()

         if target:IsPlayer() and (not target:IsFrozen()) and ((not target.was_pushed) or target.was_pushed.t != CurTime()) then

            -- always need an upwards push to prevent the ground's friction from
            -- stopping nearly all movement
            dir.z = math.abs(dir.z) + 1

            local push = dir * push_force

            -- try to prevent excessive upwards force
            local vel = target:GetVelocity() + push
            vel.z = math.min(vel.z, push_force)

            -- mess with discomb jumps
            if pusher == target and (not ttt_allow_jump:GetBool()) then
               vel = VectorRand() * vel:Length()
               vel.z = math.abs(vel.z)
            end

            target:SetVelocity(vel)

            target.was_pushed = {att=pusher, t=CurTime()}

         elseif IsValid(phys) then
            phys:ApplyForceCenter(dir * -1 * phys_force)
         end
      end
   end
end

ENT.called = false

function ENT:Explode(tr)
	if SERVER then
		
		if self.called then return end
   		self.Entity:EmitSound("weapons/hhg/holygrenade.wav", 511)
	
		timer.Simple(1.5, function()
			--self:SetNoDraw(true)
			--self:SetSolid(SOLID_NONE)

			-- pull out of the surface
			if tr.Fraction != 1.0 then
				self.Entity:SetPos(tr.HitPos + tr.HitNormal * 0.6)
			end

			local pos = self:GetPos()

			-- make sure we are removed, even if errors occur later
				  
			local effect = EffectData()
			effect:SetStart(pos)
			effect:SetOrigin(pos)
			effect:SetScale( (self.Radius * 0.3) )
			effect:SetRadius( self.Radius )
			effect:SetMagnitude( self.Damage )

			if tr.Fraction != 1.0 then
				effect:SetNormal(tr.HitNormal)
			end

			util.Effect("Explosion", effect, true, true)
			self:EmitSound( "weapons/hhg/explosion" .. math.random(1,3) ..".wav", 511 )
			util.BlastDamage( self, self:GetThrower(), pos, self.Radius, self.Damage )
			
			--local placeholder = ents.Create( "weapon_ttt_holyhandgrenade" )
			
			--StartFires(pos, tr, 50, 15, false, self:GetThrower(), placeholder)
								  
			PushPullRadius(pos, self:GetThrower())
			
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			util.Effect("hhg_explosion",effectdata)
			local num = 32
			for i=1,num do
				local effectdata2 = EffectData()
				effectdata2:SetOrigin(self:GetPos() + Vector(0,0,70))
				util.Effect("hhg_cloud",effectdata2)
			end
			
			local effectdata3 = EffectData()
			effectdata3:SetOrigin(self:GetPos() + Vector(0,0,10))
			
			if hitnormal != nil then
				effectdata3:SetNormal(hitnormal)
			end
			
			util.Effect("hhg_rings",effectdata3)
		
				
		self:Remove()
		end)
		self.called = true
	end
end

function ENT:Think()
   local etime = self:GetExplodeTime() or 0
   if etime != 0 and etime < CurTime() then
      -- if thrower disconnects before grenade explodes, just don't explode
      if SERVER and (not IsValid(self:GetThrower())) then
         self:Remove()
         etime = 0
         return
      end

      -- find the ground if it's near and pass it to the explosion
      local spos = self:GetPos()
      local tr = util.TraceLine({start=spos, endpos=spos + Vector(0,0,-32), mask=MASK_SHOT_HULL, filter=self.thrower})

      local success, err = pcall(self.Explode, self, tr)
      if not success then
         -- prevent effect spam on Lua error
         self:Remove()
         ErrorNoHalt("ERROR CAUGHT: ttt_basegrenade_proj: " .. err .. "\n")
      end
   end
	if SERVER then
		if not IsValid(self) then return end
			if !IsValid(self.HolyTrail) && !self.Spammed then	
			self.Spammed = true
			self.HolyTrail = ents.Create("env_smoketrail")
			self.HolyTrail:SetOwner(self.Owner)
			self.HolyTrail:SetPos(self:GetPos())
			self.HolyTrail:SetKeyValue("spawnradius", "1")
			self.HolyTrail:SetKeyValue("minspeed","5")
			self.HolyTrail:SetKeyValue("maxspeed","5")
			self.HolyTrail:SetKeyValue("startsize","4")
			self.HolyTrail:SetKeyValue("endsize", "4")
			self.HolyTrail:SetKeyValue("endcolor","255 215 0")
			self.HolyTrail:SetKeyValue("startcolor","255 215 0")
			self.HolyTrail:SetKeyValue("opacity","1")
			self.HolyTrail:SetKeyValue("spawnrate", "80" )
			self.HolyTrail:SetKeyValue("lifetime","3")
			self.HolyTrail:SetParent(self)
			self.HolyTrail:Spawn()
			self.HolyTrail:Activate()
			self.HolyTrail:Fire("turnon","", 0.1)
		end
	end      
end

if CLIENT then
local EFFECT={}
    
function EFFECT:Init( data )
        self.Origin = data:GetOrigin()
 

        self:SetModel("models/XQM/Rails/gumball_1.mdl")
		self:SetMaterial("lights/White002")
		self.LifeTime = CurTime() + 2
		self.Size = 4	
end
	
function EFFECT:Think( )
    if !(self.LifeTime < CurTime()) then
		if self.Size == 25 then 
	    self.Size = -1
	    self.Emitter = ParticleEmitter( self.Origin )
		for i=1,4 do
			
			local circle = self.Emitter:Add("particle/particle_ring_wave_additive", self.Origin)
			
			if (circle) then
			
				circle:SetColor(203, 150, 3)
				circle:SetVelocity(VectorRand():GetNormal()*math.random(10, 30))
				circle:SetRoll(math.Rand(0, 360))
				circle:SetDieTime(0.4)
				circle:SetLifeTime(0)
				circle:SetStartSize(600 - (i*40))
				circle:SetStartAlpha(255)
				circle:SetEndSize(200)
				circle:SetEndAlpha(200)
				circle:SetGravity(Vector(0,0,0))		
				
			end
		
		end
	    end
	return true 
	end
	return false 
end
   
function EFFECT:Render() 
self:SetPos(self.Origin)
if  self.Size > -1 then
self.Size = math.Clamp(self.Size + FrameTime()*75,4,25)
self:SetModelScale( self.Size, 0 )
end
if self.Size != 25 and self.Size != -1  then
self:DrawModel()
end
render.SetShadowColor( 255, 255, 255 )
end
	
effects.Register(EFFECT,"hhg_explosion")

local EFFECT2={}


function EFFECT2:Init(data)
    self.Origin = data:GetOrigin()
    self:SetModel("models/hunter/misc/sphere025x025.mdl")
    self:SetMaterial("lights/White002")
	local vec = VectorRand():GetNormal() * math.Rand(170,240)
    self:SetPos(self.Origin + vec)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self:SetCollisionBounds(Vector(-100,-100,-100), Vector(100,100,100))
    self:CreateShadow()
    self:DrawShadow(true)
    self.Size = math.random(4,8)
    self:SetModelScale(self.Size)
    if IsValid(self:GetPhysicsObject()) then
        self:GetPhysicsObject():Wake()
		self:GetPhysicsObject():EnableGravity( false )
        self:GetPhysicsObject():SetVelocity(vec)
    end
    self.LifeTime = CurTime() + 2
	
end


function EFFECT2:Think()
    if !(self.LifeTime < CurTime()) then   
	if !IsValid(self:GetPhysicsObject()) then
        self:PhysicsInit(SOLID_VPHYSICS)
    end
	return true 
	end

    return false
end

function EFFECT2:Render()
self:DrawModel()
self.Size = math.Clamp(self.Size - FrameTime()*4,0,8)
self:SetModelScale( self.Size, 0 )
end


effects.Register(EFFECT2,"hhg_cloud")

local EFFECT3={}


function EFFECT3:Init(data)
    self.Origin = data:GetOrigin()
	self.Normal = data:GetNormal() or Vector(0,0,0)
	self.Size = 100
    self.LifeTime = CurTime() + 0.8
end


function EFFECT3:Think()
    if !(self.LifeTime < CurTime()) then   
	if self.Size == 1200 then
	self.Size = -1
	end
	return true 
	end

    return false
end

function EFFECT3:Render()
if self.Size != -1 then
self.Size = math.Clamp(self.Size + FrameTime()*2000,100,1200)
end
render.SetMaterial(Material("particle/particle_ring_wave_additive"))
render.DrawQuadEasy(self.Origin,self.Normal,self.Size,self.Size,Color(127,159,255,255),0)
render.DrawQuadEasy(self.Origin,self.Normal*-1,self.Size,self.Size,Color(98,32,168,255),0)
end
effects.Register(EFFECT3,"hhg_rings")
end

local function ActivateCLPropPhysics()
    if CLIENT then return end
	local sphereprop = ents.Create("prop_physics")
	sphereprop:SetPos(Vector(-99999,-99999,-99999))
	sphereprop:SetModel("models/hunter/misc/sphere025x025.mdl")
	sphereprop:SetAngles(Angle(0,0,0))
	sphereprop:Spawn()
	sphereprop:Fire("kill",0,1)
end
