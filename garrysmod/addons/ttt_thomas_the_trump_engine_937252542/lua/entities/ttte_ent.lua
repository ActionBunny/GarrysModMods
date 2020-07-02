AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Thomas"
ENT.Author = "Thendon.exe, edited by Conner"
ENT.AutomaticFrameAdvance = true
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.ttte = true

function ENT:Initialize()
  self:SetModel( "models/thomasandfriends/thomas_v1_wheels.mdl" )
  self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
  self:SetSolid( SOLID_BBOX )

  if SERVER then
    self:SetTrigger( true )
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Up(), -90)
    self:SetAngles(ang)
    self:EmitSound( self.Sound )
  end
end

function ENT:Think()
  local time = CurTime()
  self.time = self.time or time
  local deltaTime = time - self.time
  self.time = time
  self.runTime = self.runTime or 0 + deltaTime

  local pos = self:GetPos()
  local ang = self:GetAngles()
  ang:RotateAroundAxis(ang:Up(), 90)
  local forward = ang:Forward() * 400 * deltaTime

  self.startPos = self.startPos or pos
  local dist = self.startPos:Distance( pos )
  if dist > 4000 then
    if CLIENT then return end
    self:StopSound( self.Sound )
    self:Remove()
    return
  end

  local set = pos + forward
  self:SetPos( set )
end

function ENT:StartTouch( entity )
  if entity == self.Owner then return end
  entity:TakeDamage( 1000, self, self.SWEP)
	self:EmitSound( "thomas_bell" )
end

if SERVER then
  function ENT:OnRemove()
    self:EmitSound( "ambient/explosions/explode_" .. math.random( 1, 9 ) .. ".wav" )
    local explode = ents.Create("env_explosion")
    explode:SetPos(self:GetPos())
    explode:SetOwner(self.Owner)
		explode:SetKeyValue( "iMagnitude", 256 )
		explode:SetKeyValue( "iRadiusOverride", 512 )
    explode:Spawn()
  	explode:Fire( "Explode", 0, 0 )
  end
end
