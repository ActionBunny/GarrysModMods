AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

util.AddNetworkString("TTT_SpringMineWarning")
include('shared.lua')
include('cl_init.lua')
if SERVER then
	AddCSLuaFile()
	resource.AddFile("sound/weapons/boing.wav")
	resource.AddFile("materials/vgui/ttt/icon_cyb_springmine.png")
end

local metaPly = FindMetaTable( "Player" )
AccessorFunc( metaPly, "wasspring", "WasSpring", FORCE_BOOL )
AccessorFunc( metaPly, "springattacker", "SpringAttacker" )

-- local metaEnt = FindMetaTable("Entity")
-- AccessorFunc( metaEnt, "defowner", "DefOwn" )

ENT.Icon = "vgui/ttt/icon_cyb_springmine.png"
ENT.Type = "anim"
ENT.Projectile = true
ENT.CanHavePrints = true

ENT.WarningSound = Sound("weapons/boing.wav")

ENT.SpringBoost = 1500 -- how far does it spring a player?

ENT.Model = Model("models/props_phx/smallwheel.mdl")
ENT.Material = Material("models/debug/debugwhite")
ENT.Color = Color(50,50,50,255)
ENT.touched = false

-- function ENT:Think()
	-- if (IsValid(self)) then
		-- for _, ent in ipairs(ents.FindInSphere(self:GetPos(), 30)) do
			-- Spectator Deathmatch support
			-- local isvalid
			-- isvalid = IsValid(ent) and ent:IsPlayer() and !ent:IsSpec()
			-- if (isvalid and specDM) then
				-- isvlid = !ent:IsGhost()
			-- end

			-- if (isvalid) then
				-- check if the target is visible
				-- local spos = self:GetPos() + Vector(0, 0, 10) -- let it work a bit better on steps, but then it doesn't work so good at ceilings
				-- local epos = ent:GetPos() + Vector(0, 0, 10) -- let it work a bit better on steps, but then it doesn't work so good at ceilings

				-- local tr = util.TraceLine({start=spos, endpos=epos, filter=self, mask=MASK_SOLID})
				-- if (!tr.HitWorld and IsValid(tr.Entity) and !table.HasValue(validDoors, tr.Entity:GetClass()) and ent:Alive()) then
					-- if ent == self.Owner then
					
					-- elseif self.touched == false then
						-- self.touched = true
						-- self:Boing(ent)
					-- end
				-- end
			-- end
		-- end

		-- self:NextThink(CurTime() + 0.05)
		-- return true
	-- end
-- end

function ENT:PhysicsCollide( data, phys )
	ent = data.HitEntity

	local isValid = IsValid(ent) and ent:IsPlayer() and !ent:IsSpec()
	
	if (isValid and specDM) then
		isValid = !ent:IsGhost()
	end

	if (isValid) then
		self:Boing(ent)
	end
end

function ENT:Boing( ply )
	if IsValid(ply) then
		if ply:Alive() then
			if not ply:IsSpec() then
					local pos = self.Entity:GetPos()
							
					--wheeee
					self:EmitSound(self.WarningSound, 500)

					ply:SetWasSpring( true )
					ply:SetSpringAttacker( self.Owner )
					
					self:LiftPlayer(ply)						

					timer.Create( ply:UniqueID() .. "SpringMineDamage", 0.1, 1, function() 
						ply:TakeDamage( 40, self.Owner , self )
						self:Remove()
					end)			
			end
		end
	end	
end

function ENT:LiftPlayer(ply)
	ply:SetVelocity(ply:GetVelocity() + Vector(0, 0, self.SpringBoost))
end


function ENT:Initialize()	

   self:SetModel(self.Model)
   self:SetMaterial(self.Material)
   self:SetColor(self.Color)
   self:SetModelScale( 0.4, 0 )
   self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS )
	self:SetMoveType (MOVETYPE_VPHYSICS)

   self:SetHealth(25)
   if SERVER then
		self:SendWarn(true)
	end
	
   return self.BaseClass.Initialize(self)
end

if SERVER then
	local zapsound = Sound("npc/assassin/ball_zap1.wav")
	function ENT:OnTakeDamage( dmginfo )
	  --################ if dmginfo:GetAttacker() == self:GetOwner() then return end

	   self:TakePhysicsDamage(dmginfo)

	   self:SetHealth(self:Health() - dmginfo:GetDamage())
	   if self:Health() < 0 then
		  self:Remove()

		  local effect = EffectData()
		  effect:SetOrigin(self:GetPos())
		  util.Effect("cball_explode", effect)
		  sound.Play(zapsound, self:GetPos())

		  -- if IsValid(self.Owner) then
			-- TraitorMsg(self.Owner, "YOUR SPRINGMINE HAS BEEN DESTROYED!")
		  -- end
	   end
	end
	
end

local function SpringMineGround( player, inWater, onFloater, speed )
	local tname = player:UniqueID() .. "SpringMineGround"
	timer.Create( tname, 0.2, 1, function() 
		player:SetWasSpring( false )
	end)
	
end

local function SpringMineDamage( target, dmg )
	if target:IsPlayer() and dmg:IsFallDamage() and target:GetWasSpring() then
		local ent = ents.Create( "ttt_spring_mine" )
		dmg:SetAttacker( target:GetSpringAttacker() )
		dmg:SetInflictor( ent )
		ent:Remove()
	end
end

hook.Add("EntityTakeDamage","SpringMineDamage", SpringMineDamage)
hook.Add("OnPlayerHitGround","SpringMineGround", SpringMineGround)

function ENT:OnRemove()
	self:SendWarn(false)
end

function ENT:SendWarn(armed)
		local owner = self.Owner
	if not TTT2 then	
		if (IsValid(owner) and owner:IsRole(ROLE_TRAITOR)) then
			net.Start("TTT_SpringMineWarning")
				net.WriteUInt(self:EntIndex(), 16)
				net.WriteBool(armed)
				net.WriteVector(self:GetPos())
			net.Send(GetTraitorFilter(true))
		elseif (IsValid(owner) and owner:IsRole(ROLE_DETECTIVE)) then
			net.Start("TTT_DSpringMineWarning")
				net.WriteUInt(self:EntIndex(), 16)
				net.WriteBool(armed)
				net.WriteVector(self:GetPos())
			net.Send(GetDetectiveFilter(true))
		end
	else
		if (IsValid(owner)) then
			net.Start("TTT_SpringMineWarning")
				net.WriteUInt(self:EntIndex(), 16)
				net.WriteBit(armed)
				if armed then
					net.WriteVector(self:GetPos())
					--net.WriteFloat(0)
					net.WriteString(owner:GetTeam())
				end
			net.Broadcast()
		end	
	end
end