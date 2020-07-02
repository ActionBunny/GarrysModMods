AddCSLuaFile( 'cl_init.lua' )
AddCSLuaFile( 'shared.lua' )
include( 'shared.lua' )


---------------------------------
-- Adjustable Variables  --
---------------------------------

local MAX_HEALTH = 60 -- Work it out...
local EXPLODE_DAMAGE = 40 -- Maximum damage to deal when exploding on death
local EXPLODE_RADIUS = 140 -- How far around in hammer units it should blast
local EXPLODE_DAMAGE2 = 90 -- Maximum damage to deal when exploding on anger
local EXPLODE_RADIUS2 = 360 -- How far around in hammer units it should blast
local JUMP_VERT_SPEED = 220 -- How high chicken should jump
local JUMP_HORIZ_SPEED = 400 -- How far he should he able to leap
local WADDLE_SPEED = 300 -- How fast it walks around
local TARGET_RADIUS = 600 -- The chicken only attacks entities if they are at least this close to it
local ATTACK_DIST = 150 -- The chicken must be at least this close to a target before attacking it
local ANGER_STARTATTACK = 15 -- Start attacking after anger level is greater than this
local ANGER_MAX = 255 -- Anger level at which the chicken should explode
local ANGER_RATE = 1 -- Added to the anger level every 0.2 seconds

-- I set it out like this so even Traitors are targetted, but the chickens wont target anyone for 3 seconds until their anger level goes over 15. (Aka, one shot)


----------------
-- Sounds  --
----------------

local sndTabAttack = 
{
	"chicken/attack1.wav",
	"chicken/attack2.wav"
}

local sndTabIdle = 
{
	"chicken/idle1.wav",
	"chicken/idle2.wav",
	"chicken/idle3.wav"
}

local sndTabPain = 
{
	"chicken/pain1.wav",
	"chicken/pain2.wav",
	"chicken/pain3.wav" 
}

local sndAngry = "chicken/alert.wav"
local sndDeath = "chicken/death.wav"
local sndCharge = "chicken/charge.wav"



--------------------------------
-- Initialize (no shit?)  --
--------------------------------

function ENT:Initialize()	

	-- Bok bok!
	self:SetModel( "models/lduke/chicken/chicken3.mdl" )
	
	-- Initiate  physics
	local mins = Vector( -7, -6, 0 )
	local maxs = Vector( 7, 6, 25 )
	
	self:PhysicsInit( SOLID_VPHYSICS )
	-- self:PhysicsInitBox( mins, maxs )
	self:SetCollisionBounds( mins, maxs )
	
	self:SetSolid( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	
	self.Phys = self:GetPhysicsObject()
	if self.Phys:IsValid() then 
		self.Phys:SetMass( 8 ) -- Chickens are light
		self.Phys:Wake()
	end
	
	-- How much health do we have right now?
	self.CurHealth = MAX_HEALTH
	
	self.reprotime = CurTime() + math.random(30,75)
	
	-- Are we attacking anything right now?
	self.Attacking = self.Attacking or false
	
	-- Who owns the chicken?
	self.Attacker = self.Attacker or NULL
	
	-- Are we about to die?
	self.Dieing = self.Dieing or false
	
	-- Cheap way to identify chickens
	self.IsChicken = true
	
	-- How angry are we?
	self.Anger = self.Anger or 0
	
	-- Target stuff
	self.Target = self.Target or NULL -- Who are attacking right now?
	self.TargetHasPhysics = self.TargetHasPhysics or false
	self.TargetPhys = self.TargetPhys or NULL
	
	-- Waddling stuff
	self.Waddling = self.Waddling or false -- Are we waddling?
	self.InitialWaddlePhase = math.Rand( 0, 2 * math.pi )
	self.LastAngleChange = self.LastAngleChange or 0
	self.NextEmitIdle = self.NextEmitIdle or CurTime()
	
	-- When can we jump again?
	self.NextJump = self.NextJump or CurTime()
	
	-- In what manner are we moving right now?
	self.CurrentMoveFunction = self.CurrentMoveFunction or self.Waddle 
	
	-- We need to do this or else PhysicsSimulate won't be called
	self:StartMotionController()
	
	-- Wake-up sound
	self:EmitSound( sndTabAttack[ math.random( 1, #sndTabAttack ) ], 100, 100 )

end


function ENT:SpawnFunction( ply, tr )

	if not tr.Hit then return end
	
	local ent = ents.Create( self.Classname )
	ent:SetPos( tr.HitPos + tr.HitNormal * 8 )
	ent:Spawn()
	ent:Activate()
	
	return ent

end


------------------------------
-- Decision Functions --
------------------------------
function ENT:Reproduce()
	local foundclucker = 0
	
	for k, v in pairs(ents.GetAll()) do 
		if v:GetClass() == "weapon_ttt_chickennade" then
			foundclucker = foundclucker + 1
		end
	end
	
	if foundclucker > 30 then return end
	
	if self.reprotime < CurTime() then
		self.reprotime = CurTime() + math.random(30,75)
		
		local ent = ents.Create( "weapon_ttt_chickennade" )
		ent:SetPos( self:GetPos() )
		ent:Spawn()
		ent:Activate()
	end
end


-- Decide what we should be doing right now
function ENT:Think()

	self:NextThink( CurTime() + 0.2 )

	-- Make sure the attacker is valid
	if not self.Attacker:IsValid() then
		self:SetAttacker( self )
	end
	
	local coloring = ANGER_MAX - self.Anger
	self:SetColor(Color(255, coloring, coloring, 255))

	-- Do waddling stuff
	if self.Waddling then
	
		-- Look for a target
		local target = self:FindTarget()
		if target:IsPlayer() then
			if target:IsValid() and not target:IsSpec() and not target:GetNWBool("stealthed", false) then -- We found a target!
			
				self.Anger = self.Anger + ANGER_RATE -- become angry
					
				if self.Anger >= ANGER_STARTATTACK then -- attack!
					
					if math.random() < 0.05 then
						self:EmitSound( sndCharge )
					end
				
					self:StopWaddling()
					self:SetTarget( target )
					
					return true
						
				end
			end
		else
			-- Calm down
			if self.Anger > 0 then 
				self.Anger = self.Anger - ANGER_RATE
				if self.Anger < 0 then self.Anger = 0 end				
			end
				
			if self.Anger < 50 then
				self:Reproduce()
			end
		end
		
		-- Hop if we're stuck upside-down
		if self:GetAngles():Up():Dot( Vector( 0, 0, -1) ) >= 0 and self:OnSomething() then
	
			self.Phys:AddVelocity( Vector( 0, 0, 200 ) )
			--self.Phys:AddAngleVelocity( VectorRand() * 350 )
	
		end
	
		-- Play idle sounds
		if CurTime() > self.NextEmitIdle then
		
			self.NextEmitIdle = CurTime() + 3
		
			-- 33 percent chance of emitting a sound every 3 seconds
			if math.random() < 0.33 then
				self:EmitSound( sndTabIdle[ math.random( 1, #sndTabIdle ) ] )
			end

		end
		
		return true
		
	end
	
	-- Do non-waddling stuff (ie, attacking stuff)
	
	-- Make sure we can see our target
	if not self:CanSeeTarget() then
	
		--self.Anger = math.Clamp( self.Anger, 0, ANGER_STARTATTACK )
		self:StartWaddling()
		return true

	end
	
	-- Become more angry
	self.Anger = self.Anger + ANGER_RATE
	if self.Anger > 200 and not self.Dieing then -- Explode if it's too angry
	
		self.Dieing = true
		
		self:DoDeath2()
		return true
		
	end
	
	-- Jump
	if CurTime() > self.NextJump then
		
		self.Attacking = false
		
		if not self:OnSomething() then
			self.NextJump = CurTime() + 0.6
			return true
		end
		
		self:JumpAtTarget()
		self.NextJump = CurTime() + 1.5
		
	end
		
	return true

end


-- Decide if we should do attack damage or take fall damage
function ENT:PhysicsCollide( data, phys )

	if data.Speed < 30 then return end
	
	-- Take fall damage
	if data.Speed > 900 then
	
		self:TakeDamage( 0.2 * ( data.Speed - 900 ), data.HitEntity, data.HitEntity )
	
	end

	-- Damage the badguys
	if self.Attacking and not ( data.HitEntity:IsWorld() or data.HitEntity.IsChicken ) then
	
		local dmg = 35
		if data.HitEntity:IsPlayer() then
			if data.HitEntity:GetActiveWeapon():GetClass() == "weapon_ttt_riot" then
				dmg = 5
			end
		end
		
		local dmginfo = DamageInfo()
        dmginfo:SetDamage(dmg)
        dmginfo:SetAttacker(self.Attacker)
        dmginfo:SetInflictor(self)
        dmginfo:SetDamageType(DMG_CLUB)
        dmginfo:SetDamageForce(self:GetPos() - data.HitEntity:GetPos())
        dmginfo:SetDamagePosition(data.HitEntity:GetPos())
		
		if self.IsPoisoned then
			if data.HitEntity:IsPlayer() then
				TakePoisonDamage(data.HitEntity, self.Attacker, self)
			end
		end

        data.HitEntity:TakeDamageInfo(dmginfo)
		self.Attacking = false
	end

end


-- Decide what our new health should be and if we should die
function ENT:OnTakeDamage( dmginfo )
	self.Anger = self.Anger + 25
	
	if dmginfo:GetAttacker():IsPlayer() and IsValid(dmginfo:GetAttacker():GetActiveWeapon()) and dmginfo:GetAttacker():GetActiveWeapon():GetClass() == "weapon_ttt_poisondart" then
		self.IsPoisoned = true
	else
		self.IsPoisoned = false
	end
	
	self:TakePhysicsDamage( dmginfo )
	
	if self.Dieing then return end
	
	self.CurHealth = self.CurHealth - dmginfo:GetDamage()
	if self.CurHealth <= 0 then

		self.Dieing = true
		if dmginfo:GetAttacker():IsWorld() then
			self:DoDeath()
		else
			timer.Simple( math.Rand( 0.05, 0.1 ), function() self:DoDeath() end )
		end
		
		return
		
	end
	
	-- Emit pain sounds
	self:EmitSound( sndTabPain[ math.random( 1, #sndTabPain ) ] )
	
	-- Emit feathers
	local dmgpos = dmginfo:GetDamagePosition()
	if dmgpos == Vector( 0, 0, 0 ) then 
		dmgpos = self:GetPos()
		dmgpos.z = dmgpos.z + 10
	end
	
	local fx = EffectData()
	fx:SetOrigin( dmgpos )
	util.Effect( "chicken_pain", fx )

end


---------------------------
-- Helper Functions --
---------------------------

-- Look for viable targets and return the closest one
function ENT:FindTarget()

	local target = NULL
	local shortest = TARGET_RADIUS
	local mypos = self:GetPos()

	-- Find the closest target
	for _,ent in pairs( ents.FindInSphere( mypos , TARGET_RADIUS ) ) do
	
		if ( ent:IsPlayer() and ent:Alive() and !ent:IsActiveTraitor()) then -- IF they are a NPC or a Player, and they are alive(sanity check with > 0hp) to attack.
		
			local dist = ent:GetPos():Distance( mypos )
		
			if dist < shortest then
			
				shortest = dist
				target = ent
			
			end
	
		end
	
	end

	return target

end


-- Makes the chicken start tracking the input entity
function ENT:SetTarget( ent )

	self.Target = ent
	self.TargetIsPlayer = self.Target:IsPlayer()
	
	local phys = self.Target:GetPhysicsObject()
	if phys:IsValid() then
		self.TargetHasPhysics = true
		self.TargetPhys = phys
	end
	
	self.CurrentMoveFunction = self.TrackTarget
	
	-- Make the feeling mutual
	if ent:IsNPC() then
		ent:AddEntityRelationship( self, D_HT, 99 ) -- This doesn't work : (
	end

end


-- Returns true if the target is alive and visible to the chicken
function ENT:CanSeeTarget()

	if not self.Target:IsValid() then return false end
	if self.TargetIsPlayer and not self.Target:Alive() then return false end
	if self.Target:Health() <= 0 then return false end
	
	if self:GetPos():Distance( self.Target:GetPos() ) > TARGET_RADIUS then return false end
	if not self:Visible( self.Target ) then return false end
	
	return true
	
end


-- Returns true if the chicken is on top of something
function ENT:OnSomething()

	local start = self:GetPos() + Vector( 0, 0, 20 )
	local endpos = Vector( start.x, start.y, start.z - 30 )

	local tr = util.TraceLine( 
	{
		start = start,
		endpos = endpos,
		filter = self,
		mask = bit.bor(MASK_SOLID, MASK_WATER)
	})
	
	return tr.Hit

end


function ENT:StartWaddling()

	self.Waddling = true
	self.CurrentMoveFunction = self.Waddle

end


function ENT:StopWaddling()

	self.Waddling = false

end


function ENT:SetAttacker( plr )

	self.Attacker = plr

end


-- Do explosion damage, emit sounds, play death effects, and remove the chicken
function ENT:DoDeath()

	local mypos = self:GetPos()
	
	-- Spawn blood and feathers
	local fx = EffectData()
	fx:SetOrigin( mypos )
	util.Effect( "chicken_death", fx )
	util.Effect( "Explosion", fx, true, true )
	
	self:Explode()
	
	-- Emit death sounds
	self:EmitSound( sndDeath )
	
	local kfc = ents.Create("ttt_kfc")
	kfc:SetPos(self:GetPos())
	kfc:SetAngles(self:GetAngles())
	kfc:Spawn()
	kfc:PhysWake()
	
	-- Die
	self:Remove()

end

function ENT:DoDeath2()

	if not self:IsValid() then return end -- Just in case
	local mypos = self:GetPos()
	
	-- Spawn blood and feathers
	local fx = EffectData()
	fx:SetOrigin( mypos )
	util.Effect( "chicken_death", fx )
	util.Effect( "Explosion", fx, true, true )
	
	self:Explode2()
	
	-- Emit death sounds
	self:EmitSound( sndDeath )
	
	-- Die
	self:Remove()

end

function ENT:Explode()

	local mypos = self:GetPos()
	local dmgmul = -EXPLODE_DAMAGE / EXPLODE_RADIUS
	for _,ent in pairs( ents.FindInSphere( self:GetPos(), EXPLODE_RADIUS ) ) do

		local dmg = dmgmul * mypos:Distance( ent:GetPos() ) + EXPLODE_DAMAGE
		if ent.Chicken then dmg = 0.5 * dmg end
		if ent:IsPlayer() then
			
			local dmginfo = DamageInfo()
			dmginfo:SetDamage(dmg)
			dmginfo:SetAttacker(self.Attacker)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamageType(DMG_BLAST)
			dmginfo:SetDamageForce(self:GetPos() - ent:GetPos())
			dmginfo:SetDamagePosition(ent:GetPos())

			ent:TakeDamageInfo(dmginfo)
			
		end
	end
end

function ENT:Explode2()

	local mypos = self:GetPos()
	local dmgmul = -EXPLODE_DAMAGE2 / EXPLODE_RADIUS2
	for _,ent in pairs( ents.FindInSphere( self:GetPos(), EXPLODE_RADIUS2 ) ) do

		local dmg = dmgmul * mypos:Distance( ent:GetPos() ) + EXPLODE_DAMAGE2
		if ent.Chicken then dmg = 0.5 * dmg end
		if ent:IsPlayer() then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage(dmg)
			dmginfo:SetAttacker(self.Attacker)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamageType(DMG_BLAST)
			dmginfo:SetDamageForce(self:GetPos() - ent:GetPos())
			dmginfo:SetDamagePosition(ent:GetPos())

			ent:TakeDamageInfo(dmginfo)
		end
	end
end


--------------------------------
-- Movement Functions --
--------------------------------

-- This just returns a call to our current move function
function ENT:PhysicsSimulate( phys, dt )

	phys:Wake()

	return self:CurrentMoveFunction( phys, dt )

end


-- Jumps toward the target, and attacks if we're close enough
function ENT:JumpAtTarget()

	-- Get the velocity of our target
	local vel
	if self.TargetHasPhysics then
		vel = self.TargetPhys:GetVelocity()
	else
		vel = self.Target:GetVelocity()
	end
	
	local mypos = self:GetPos()
	local targpos = self.Target:EyePos()
	local disp = targpos - mypos
	
	-- Get the vector orthogonal to the projection of vel onto disp
	local proj = vel - ( disp:Dot( vel ) / disp:Dot( disp ) ) * disp
	
	-- Try to predict where the target is going to be and jump there
	local dest = targpos + proj * 0.6
	local dist = mypos:Distance( dest )
	
	-- Vel is now the velocity the chicken is going to have (saves memory! :D)
	vel = ( dest - mypos ) * ( JUMP_HORIZ_SPEED / dist )
	vel.z = vel.z + JUMP_VERT_SPEED
	if vel.z < 20 then vel.z = 20 end
	
	if type(vel) != "userdata" then
	    self.Phys:AddVelocity( vel )
    end
	
	local ang = Vector( ( math.random( 0, 1 ) * 2 - 1 ) * math.Rand( 300, 600 ), math.Rand( -600, 200 ), ( math.random( 0, 1 ) * 2 - 1 ) * math.Rand( 300, 600 ) )
	if type(ang) == "Vector" then
	    self.Phys:AddAngleVelocity(ang)
	end
	
	-- Emit Sounds
	-- The pitch and volume increase with how angry we are
	local angerratio = ( self.Anger - ANGER_STARTATTACK ) / ( ANGER_MAX - ANGER_STARTATTACK )
	local vol = 100 + 50 * angerratio
	local pitch = 100 + 20 * angerratio

	if dist < ATTACK_DIST then -- Attack!
	
		self.Attacking = true
		self:EmitSound( sndTabAttack[ math.random( 1, #sndTabAttack ) ], vol, pitch )
	
	else
	
		self:EmitSound( sndAngry, vol, pitch )
		
	end
	
end


-- The main waddling move function
function ENT:Waddle( phys, dt )

	if not self:OnSomething() then return SIM_NOTHING end

	local TargetAng = self:GetAngles()
	local DeltaAng = math.Rand( -50, 50 ) * dt + self.LastAngleChange
	self.LastAngleChange = DeltaAng
	
	TargetAng.p = 0
	TargetAng.y = TargetAng.y + 30 * math.sin( 0.6 * CurTime() ) + DeltaAng -- turn randomly
	TargetAng.r = 60 * math.sin( 10 * CurTime() + self.InitialWaddlePhase ) -- waddle side-to side

	-- Increment the angle
	phys:ComputeShadowControl(
	{
		secondstoarrive		= 1,
		angle				= TargetAng,
		maxangular			= 400,
		maxangulardamp		= 60,
		dampfactor			= 0.8,
		deltatime			= dt
	})
	
	local linear = self:GetAngles():Forward() * WADDLE_SPEED - phys:GetVelocity()
	linear.z = linear.z + 250 -- Compensate for gravity/friction
	
	return Vector( 0, 0, 0 ), linear, SIM_GLOBAL_ACCELERATION

end


-- The main target tracking move function.  
-- This just makes the chicken face the target... jumping is handled on Think
function ENT:TrackTarget( phys, dt )

	local TargetAng

	if self.Target:IsValid() then
	
		local targpos = self.Target:GetPos()
		local mypos = phys:GetPos()
	
		TargetAng = ( targpos - mypos ):Angle()
		
	else
		
		TargetAng = phys:GetAngles()
		TargetAng.p = 0
		TargetAng.r = 0
		
	end
	
	-- Increment the angle
	phys:ComputeShadowControl(
	{
		secondstoarrive		= 1,
		angle				= TargetAng,
		maxangular			= 150,
		maxangulardamp		= 80,
		dampfactor			= 0.8,
		deltatime			= dt
	})

	return SIM_NOTHING

end

