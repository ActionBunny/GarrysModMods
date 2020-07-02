-- burning nade projectile

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"
ENT.Model = Model("models/weapons/w_eq_flashbang_thrown.mdl")


AccessorFunc( ENT, "radius", "Radius", FORCE_NUMBER )
AccessorFunc( ENT, "dmg", "Dmg", FORCE_NUMBER )

function ENT:Initialize()
   if not self:GetRadius() then self:SetRadius(256) end
   if not self:GetDmg() then self:SetDmg(25) end

   return self.BaseClass.Initialize(self)
end

function ENT:Explode(tr)
   if SERVER then
      self:SetNoDraw(true)
      self:SetSolid(SOLID_NONE)
		 
		 placeholder = ents.Create( "weapon_ttt_incendiary" )
		placeholder:SetPos( self:GetPos() )
		placeholder:Spawn()
		placeholder:DrawShadow( false )
      -- pull out of the surface
      if tr.Fraction != 1.0 then
         self:SetPos(tr.HitPos + tr.HitNormal * 0.6)
      end

      local pos = self:GetPos()

      if util.PointContents(pos) == CONTENTS_WATER then
         self:Remove()
         return
      end

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

      StartFires(pos, tr, 10, 20, false, self:GetThrower(), placeholder)

      self:SetDetonateExact(0)

      self:Remove()
   else
      local spos = self:GetPos()
      local trs = util.TraceLine({start=spos + Vector(0,0,64), endpos=spos + Vector(0,0,-128), filter=self})
      util.Decal("Scorch", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)      

      self:SetDetonateExact(0)
   end
end

local ENT = {}
ENT.Type   = "anim"
ENT.Base                = "base_anim"
ENT.PrintName           = "weapon_ttt_incendiary"
ENT.RenderGroup         = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
end

function ENT:Draw()
end

function ENT:Think()
end
scripted_ents.Register(ENT, "weapon_ttt_incendiary", true)