
if SERVER then
   AddCSLuaFile("ttt_holyhandgrenade_proj.lua")
end

ENT.Icon = "VGUI/ttt/icon_cyb_holyhandgrenade.png"
ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"
ENT.Model = Model("models/weapons/w_eq_fraggrenade_thrown.mdl")

local ttt_allow_jump = CreateConVar("ttt_allow_discomb_jump", "0")
AccessorFunc( ENT, "radius", "Radius", FORCE_NUMBER )
AccessorFunc( ENT, "dmg", "Dmg", FORCE_NUMBER )

function ENT:Initialize()
   if not self:GetRadius() then self:SetRadius(512) end
   if not self:GetDmg() then self:SetDmg(100) end

   return self.BaseClass.Initialize(self)
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
   		self.Entity:EmitSound("holyhandgrenade.wav", 511)
	
		timer.Simple(1.5, function()
			self.Entity:SetNoDraw(true)
			self.Entity:SetSolid(SOLID_NONE)

			-- pull out of the surface
			if tr.Fraction != 1.0 then
				self.Entity:SetPos(tr.HitPos + tr.HitNormal * 0.6)
			end

			local pos = self.Entity:GetPos()

			-- make sure we are removed, even if errors occur later
				  
			local effect = EffectData()
			effect:SetStart(pos)
			effect:SetOrigin(pos)
			effect:SetScale(self:GetRadius() * 0.3)
			effect:SetRadius(self:GetRadius())
			effect:SetMagnitude(self.dmg)

			if tr.Fraction != 1.0 then
				effect:SetNormal(tr.HitNormal)
			end

			util.Effect("Explosion", effect, true, true)
			util.BlastDamage(self, self:GetThrower(), pos, self:GetRadius(), self:GetDmg())
			StartFires(pos, tr, 25, 15, false, self:GetThrower())
								  
			PushPullRadius(pos, self:GetThrower())
				
			self:Remove()
		end)
		self.called = true
	end
end