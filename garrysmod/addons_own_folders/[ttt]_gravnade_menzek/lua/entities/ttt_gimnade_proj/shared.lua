
if SERVER then
	AddCSLuaFile("shared.lua")
end

ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"
ENT.Model = Model("models/weapons/w_eq_fraqgrenade_thrown.mdl")

local FreezeTime = 25
local BlastRadius = 500


AccessorFunc( ENT, "radius", "Radius", FORCE_NUMBER )

local plymeta = FindMetaTable( "Player" )
AccessorFunc( plymeta, "wasgrav", "WasGrav", FORCE_BOOL )
AccessorFunc( plymeta, "gravthrower", "GravThrower" )

function ENT:Initialize()
	if not self:GetRadius() then self:SetRadius(20) end

	return self.BaseClass.Initialize(self)
end

local FloatingEntities = {}
local function Float(ent,enabled,velocity)
	if not ent:IsValid() then return end
	local phys_obj = ent:GetPhysicsObject()
	if not phys_obj then return end
	phys_obj:EnableGravity( enabled )
	local j = 1
	while true do
		local phys_obj = ent:GetPhysicsObjectNum( j )
		if phys_obj then
			phys_obj:EnableGravity( enabled )
			if velocity then
				phys_obj:SetVelocity( velocity )
			end
			j = j + 1
		else
			break
		end
	end
end
local function MakeRagdoll(player,velocity, thrower)
	if not player:IsValid() then return end
	local active = player:GetActiveWeapon()
	local weapons = player:GetWeapons()

	if active:IsValid() and active:IsWeapon() then
		if active.AllowDrop == true then
			WEPS.DropNotifiedWeapon(player, active)
		else
			active = nil
		end
	end

	local weps = {}
	for _, weapon in ipairs( weapons ) do
		if weapon == active then continue end
		printname = weapon:GetClass()
		weps[ printname ] = {}
		weps[ printname ].clip1 = weapon:Clip1()
		weps[ printname ].clip2 = weapon:Clip2()
		weps[ printname ].ammo1 = player:GetAmmoCount( weapon:GetPrimaryAmmoType() )
		weps[ printname ].ammo2 = player:GetAmmoCount( weapon:GetSecondaryAmmoType() )
	end

	local ragdoll = ents.Create( "prop_ragdoll" )
	local GIMNade = {}
	GIMNade.Weapons = weps
	GIMNade.Player = player
	GIMNade.Health = player:Health()
	GIMNade.Credits = player:GetCredits()
	GIMNade.UnfreezeTime = CurTime() + FreezeTime
	FloatingEntities[ragdoll] = GIMNade

	ragdoll:SetPos( player:GetPos() )
	ragdoll:SetAngles( player:GetAngles() )
	ragdoll:SetModel( player:GetModel() )
	ragdoll:SetCollisionGroup( COLLISION_GROUP_WORLD )
	ragdoll:Spawn()
	ragdoll:Activate()
	player:SetParent( ragdoll )

	Float(ragdoll,false,velocity)

	player:Spectate( OBS_MODE_CHASE )
	player:SpectateEntity( ragdoll )
	player:StripWeapons()
	player:SetGravThrower( thrower )
	return active
end
local function CheckEntities()
	for ent,t in pairs(FloatingEntities) do
		if not IsValid(ent) then FloatingEntities[ent] = nil continue end
		local player = t.Player
		if player then
			if not player then ent:Remove() FloatingEntities[ent] = nil continue end
			player:SetHealth(t.Health)
			if t.Health <= 0 or t.UnfreezeTime <= CurTime() then
				player:SetParent()
				player:UnSpectate()
				local pos = ent:GetPos()
				pos.z = pos.z + 10
				player:Spawn()
				player:SetHealth(t.Health)
				player:SetPos( pos )
				player:SetVelocity( ent:GetVelocity() )
				local yaw = player:GetAngles().yaw
				player:SetAngles( Angle( 0, yaw, 0 ) )
				ent:Remove()
				if t.Health <= 0 then
					timer.Simple(.1,function()
						if player:IsValid() then
							if t.LastDamage then
								player:TakeDamageInfo(t.LastDamage)
							else
								player:Kill()
							end
						end
					end)
				else
					if t.Weapons then
						timer.Simple(.1,function()
							if player:IsValid() then
								player:StripAmmo()
								player:StripWeapons()

								for printname, data in pairs( t.Weapons ) do
									player:Give( printname )
									local weapon = player:GetWeapon( printname )
									weapon:SetClip1( data.clip1 )
									weapon:SetClip2( data.clip2 )
									player:SetAmmo( data.ammo1, weapon:GetPrimaryAmmoType() )
									player:SetAmmo( data.ammo2, weapon:GetSecondaryAmmoType() )
								end

								player:SelectWeapon("weapon_ttt_unarmed")
							end
						end)
					end
				end
				player:AddCredits(t.Credits)
				
				player:SetWasGrav( true )
				
				FloatingEntities[ent] = nil
			end
		else
			local prop_phys = ent:GetPhysicsObject()
			if not t or not prop_phys:IsValid() then ent:Remove() FloatingEntities[ent] = nil continue end
			if t.UnfreezeTime <= CurTime() then
				Float(ent,true)
				FloatingEntities[ent] = nil
			end
		end
	end
end

hook.Add("Think","TTTGIMNade",CheckEntities)
local function DamageRagdoll(entity,dmg)
	local t = FloatingEntities[entity]
	if t then
		if IsValid( t.Health ) then
			t.Health = t.Health - dmg:GetDamage()
			
			local _dmg = DamageInfo()
			_dmg:SetAttacker(dmg:GetAttacker())
			_dmg:SetDamage(dmg:GetDamage())
			_dmg:SetDamageForce(dmg:GetDamageForce())
			_dmg:SetDamagePosition(dmg:GetDamagePosition())
			_dmg:SetDamageType(dmg:GetDamageType())
			_dmg:SetInflictor(dmg:GetInflictor())
			_dmg:SetMaxDamage(dmg:GetMaxDamage())
			t.LastDamage = _dmg
		end
	end
end
hook.Add("EntityTakeDamage","TTTGIMNade",DamageRagdoll)

function ENT:Explode(trace)
	if CLIENT then return end
	local Normal = trace.HitNormal

	self.Scale = 140
	self.EffectScale = self.Scale ^ 1.65

	local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
	util.Effect("gimsplode", effectdata)

	self:EmitSound("weapons/hegrenade/explode4.wav",90,85)
	
	local shake = ents.Create("env_shake")
		shake:SetOwner(self.Owner)
		shake:SetPos(self.Entity:GetPos())
		shake:SetKeyValue("amplitude", "20")   // Power of the shake
		shake:SetKeyValue("radius", "15")      // Radius of the shake
		shake:SetKeyValue("duration", "2.5")   // Time of shake
		shake:SetKeyValue("frequency", "255")  // How har should the screenshake be
		shake:SetKeyValue("spawnflags", "4")   // Spawnflags(In Air)
		shake:Spawn()
		shake:Activate()
		shake:Fire("StartShake", "", 0)

	

	local en = ents.FindInSphere(self.Entity:GetPos(), BlastRadius)

	local un
	for k, v in pairs( en ) do
		local velocity = (Vector(BlastRadius,BlastRadius,BlastRadius)-(v:GetPos()-self:GetPos()))*0.2
		local phys_obj = v:GetPhysicsObject()
		if FloatingEntities[v] then
			FloatingEntities[v].UnfreezeTime = CurTime() + FreezeTime
		elseif v:IsPlayer() and v:Alive() then
			if v:InVehicle() then
				local vehicle = v:GetParent()
				v:ExitVehicle()
			end
			local weapon = MakeRagdoll(v,velocity, self:GetThrower() )
			if weapon and weapon:IsValid() then
				table.insert(en,weapon)
			end
		elseif (phys_obj:IsValid() and not v.GIMNade) then
			GIMNade = {}
			GIMNade.GravityDisabled = not phys_obj:IsGravityEnabled()
			GIMNade.UnfreezeTime = CurTime() + FreezeTime
			Float(v,false,velocity)
			FloatingEntities[v] = GIMNade
		end
	end
	
	self.Entity:Remove()
end

function ENT:PhysicsCollide(data, phys)

	if data.Speed > 70 then
		self:EmitSound(Sound("weapons/hegrenade/he_bounce-1.wav"))
	end
	
	local impulse = -data.Speed * data.HitNormal * 0.2 + (data.OurOldVelocity * -0.4)
	phys:ApplyForceCenter(impulse)
end

function ENT.GetSpawnInfo(ply)
	if ULib and ULib.getSpawnInfo then
		ULib.getSpawnInfo( ply )
		return ply.ULibSpawnInfo
	end

	local t = {}
	t.health = player:Health()
	t.armor = player:Armor()
	t.credits = player:GetCredits()
	if player:GetActiveWeapon():IsValid() then
		t.curweapon = player:GetActiveWeapon():GetClass()
	end

	local weapons = player:GetWeapons()
	local data = {}
	for _, weapon in ipairs( weapons ) do
		printname = weapon:GetClass()
		data[ printname ] = {}
		data[ printname ].clip1 = weapon:Clip1()
		data[ printname ].clip2 = weapon:Clip2()
		data[ printname ].ammo1 = player:GetAmmoCount( weapon:GetPrimaryAmmoType() )
		data[ printname ].ammo2 = player:GetAmmoCount( weapon:GetSecondaryAmmoType() )
	end
	t.data = data

	return t
end

//gimsplode effect
if CLIENT then
	local EFFECT = {}

	function EFFECT:Init(ed)

		local vOrig = ed:GetOrigin()
		self.Emitter = ParticleEmitter(vOrig)
		
		for i=1,24 do

			local smoke = self.Emitter:Add("particle/particle_smokegrenade", vOrig)

			if (smoke) then

				smoke:SetColor(25, 125, 200)
				smoke:SetVelocity(VectorRand():GetNormal()*math.random(100, 300))
				smoke:SetRoll(math.Rand(0, 360))
				smoke:SetRollDelta(math.Rand(-2, 2))
				smoke:SetDieTime(1)
				smoke:SetLifeTime(0)
				smoke:SetStartSize(50)
				smoke:SetStartAlpha(255)
				smoke:SetEndSize(100)
				smoke:SetEndAlpha(0)
				smoke:SetGravity(Vector(0,0,0))

			end
			
			local smoke2 = self.Emitter:Add("particle/particle_smokegrenade", vOrig)
			
			if (smoke2) then

				smoke2:SetColor(25, 125, 200)
				smoke2:SetVelocity(VectorRand():GetNormal()*math.random(50, 100))
				smoke2:SetRoll(math.Rand(0, 360))
				smoke2:SetRollDelta(math.Rand(-2, 2))
				smoke2:SetDieTime(5)
				smoke2:SetLifeTime(0)
				smoke2:SetStartSize(50)
				smoke2:SetStartAlpha(255)
				smoke2:SetEndSize(100)
				smoke2:SetEndAlpha(0)
				smoke2:SetGravity(Vector(0,0,0))

			end
			
			local smoke3 = self.Emitter:Add("particle/particle_smokegrenade", vOrig+Vector(math.random(-150,150),math.random(-150,150),0))
			
			if (smoke3) then

				smoke3:SetColor(0, 25, 50)
				smoke3:SetVelocity(VectorRand():GetNormal()*math.random(50, 100))
				smoke3:SetRoll(math.Rand(0, 360))
				smoke3:SetRollDelta(math.Rand(-2, 2))
				smoke3:SetDieTime(5)
				smoke3:SetLifeTime(0)
				smoke3:SetStartSize(50)
				smoke3:SetStartAlpha(255)
				smoke3:SetEndSize(100)
				smoke3:SetEndAlpha(0)
				smoke3:SetGravity(Vector(0,0,0))

			end
			
			local heat = self.Emitter:Add("sprites/heatwave", vOrig+Vector(math.random(-150,150),math.random(-150,150),0))
			
			if (heat) then

				heat:SetColor(0, 25, 50)
				heat:SetVelocity(VectorRand():GetNormal()*math.random(50, 100))
				heat:SetRoll(math.Rand(0, 360))
				heat:SetRollDelta(math.Rand(-2, 2))
				heat:SetDieTime(3)
				heat:SetLifeTime(0)
				heat:SetStartSize(100)
				heat:SetStartAlpha(255)
				heat:SetEndSize(0)
				heat:SetEndAlpha(0)
				heat:SetGravity(Vector(0,0,0))

			end
			
		end
		
		for i=1,72 do
		
			local sparks = self.Emitter:Add("effects/spark", vOrig)
			
			if (sparks) then

				sparks:SetColor(0, 200, 255)
				sparks:SetVelocity(VectorRand():GetNormal()*math.random(300, 500))
				sparks:SetRoll(math.Rand(0, 360))
				sparks:SetRollDelta(math.Rand(-2, 2))
				sparks:SetDieTime(2)
				sparks:SetLifeTime(0)
				sparks:SetStartSize(3)
				sparks:SetStartAlpha(255)
				sparks:SetStartLength(15)
				sparks:SetEndLength(3)
				sparks:SetEndSize(3)
				sparks:SetEndAlpha(255)
				sparks:SetGravity(Vector(0,0,-800))
				
			end
			
			local sparks2 = self.Emitter:Add("effects/spark", vOrig)
			
			if (sparks2) then

				sparks2:SetColor(0, 200, 255)
				sparks2:SetVelocity(VectorRand():GetNormal()*math.random(400, 800))
				sparks2:SetRoll(math.Rand(0, 360))
				sparks2:SetRollDelta(math.Rand(-2, 2))
				sparks2:SetDieTime(0.4)
				sparks2:SetLifeTime(0)
				sparks2:SetStartSize(5)
				sparks2:SetStartAlpha(255)
				sparks2:SetStartLength(80)
				sparks2:SetEndLength(0)
				sparks2:SetEndSize(5)
				sparks2:SetEndAlpha(0)
				sparks2:SetGravity(Vector(0,0,0))
				
			end
		
		end
		
		for i=1,8 do
		
			local flash = self.Emitter:Add("effects/combinemuzzle2_dark", vOrig)
			
			if (flash) then
			
				flash:SetColor(255, 255, 255)
				flash:SetVelocity(VectorRand():GetNormal()*math.random(10, 30))
				flash:SetRoll(math.Rand(0, 360))
				flash:SetDieTime(0.10)
				flash:SetLifeTime(0)
				flash:SetStartSize(150)
				flash:SetStartAlpha(255)
				flash:SetEndSize(240)
				flash:SetEndAlpha(0)
				flash:SetGravity(Vector(0,0,0))		
				
			end
			
			local quake = self.Emitter:Add("effects/splashwake3", vOrig)
			
			if (quake) then
			
				quake:SetColor(0, 175, 255)
				quake:SetVelocity(VectorRand():GetNormal()*math.random(10, 30))
				quake:SetRoll(math.Rand(0, 360))
				quake:SetDieTime(1)
				quake:SetLifeTime(0)
				quake:SetStartSize(160)
				quake:SetStartAlpha(200)
				quake:SetEndSize(270)
				quake:SetEndAlpha(0)
				quake:SetGravity(Vector(0,0,0))		
				
			end
			
			local wave = self.Emitter:Add("sprites/heatwave", vOrig)
			
			if (wave) then
			
				wave:SetColor(0, 175, 255)
				wave:SetVelocity(VectorRand():GetNormal()*math.random(10, 30))
				wave:SetRoll(math.Rand(0, 360))
				wave:SetDieTime(0.25)
				wave:SetLifeTime(0)
				wave:SetStartSize(160)
				wave:SetStartAlpha(255)
				wave:SetEndSize(270)
				wave:SetEndAlpha(0)
				wave:SetGravity(Vector(0,0,0))
				
			end
		
		end

		self.Emitter:Finish()
		
	end

	function EFFECT:Think()
		return false
	end

	function EFFECT:Render()
	end

	effects.Register( EFFECT, "gimsplode", true )
end

local function GravGrenGround( player, inWater, onFloater, speed )
	local tname = Format("WasGrav_%d_%d", player:EntIndex(), math.ceil(CurTime()))
	timer.Create( tname, 1, 1, function() 
		player:SetWasGrav(false)
	end)
	
end

local function GravGrenDamage( target, dmg )
	if target:IsPlayer() and target:Alive() then
		if dmg:IsFallDamage() then
			--if IsValid( target:GetSuperPush() ) then
				if target:GetWasGrav() == true then
					--print( "penis" )
					local ent = ents.Create( "weapon_ttt_gravnade" )
					dmg:SetAttacker( target:GetGravThrower() ) ---hier muss was geschehen
					dmg:SetInflictor( ent )
					--print( dmg:GetInflictor():GetClass() )
					ent:Remove()
				end
			--end
		end
	end
end

hook.Add("EntityTakeDamage","GravGrenDamage", GravGrenDamage)
hook.Add("OnPlayerHitGround","GravGrenGround", GravGrenGround)


local ENT = {}
ENT.Type   = "anim"
ENT.Base                = "base_anim"
ENT.PrintName           = "weapon_ttt_gravnade"
ENT.RenderGroup         = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
end

function ENT:Draw()
end

function ENT:Think()
end
scripted_ents.Register(ENT, "weapon_ttt_gravnade", true)
