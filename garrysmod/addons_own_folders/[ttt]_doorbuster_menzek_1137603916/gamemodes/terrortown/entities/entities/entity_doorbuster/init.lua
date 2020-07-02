AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

util.AddNetworkString("TTT_DoorBusterWarning")
include('shared.lua')
local metaEnts = FindMetaTable( "Entity")

AccessorFunc( metaEnts, "isdoorbuster", "IsDoorBuster", FORCE_BOOL )

ENT.Exploded = false

function ENT:Initialize()

	
  self:PhysicsInit( SOLID_VPHYSICS )
  self:SetMoveType( MOVETYPE_VPHYSICS )
  self:SetSolid( SOLID_VPHYSICS )
  self:SetModel("models/weapons/w_c4_planted.mdl")
  self:SetUseType(1)
  self:SetHealth(50)
  self:SetMaxHealth(50)
  local phys = self:GetPhysicsObject()
  if (phys:IsValid()) then
    phys:Wake()
    phys:EnableDrag(true)
    phys:EnableMotion(false)
  end

	if SERVER then
		--print( self.Owner:Nick() )
		self:SendWarn(true)
	end
end

function ENT:Explode()
  local effectdata = EffectData()
  effectdata:SetAngles(self:GetAngles())
  effectdata:SetOrigin(self:GetPos())
  local effectdata2 = EffectData()
  effectdata2:SetOrigin(self:GetPos())
  self:EmitSound("ambient/explosions/explode_4.wav",100,100)
  util.Effect("ThumperDust",effectdata)
  util.Effect("Explosion",effectdata2)
  
  local doorent = ents.Create ( "weapon_ttt_doorbuster" )
  util.BlastDamage(doorent, self.Owner, self:GetPos(), 280, 250 )
	doorent:Remove()
  
  self.Exploded = true
	
  for k, v in pairs(ents.FindInSphere(self:GetPos(),120)) do
    if v:GetClass() == "entity_doorbuster" and v != self and !v.Exploded then v:Explode() end
  end

end

function ENT:BlowDoor()
  self:Explode()

  for k, v in pairs(ents.FindInSphere(self:GetPos(),80)) do
    if IsValid(v) and (v:GetClass() == "prop_door" or v:GetClass() == "func_door" or v:GetClass() == "prop_door_rotating" or v:GetClass() == "func_door_rotating" ) and !v.DoorExploded then

      local door = ents.Create("prop_physics")
      door:SetModel(v:GetModel())
      local pos = v:GetPos()
      pos:Add(self:GetAngles():Up() * -13)

      door:SetPos(pos)
      door:SetAngles(v:GetAngles())

      if v:GetSkin() then
        door:SetSkin(v:GetSkin())
      end

      door:SetMaterial(v:GetMaterial())

      v:Fire("Open")
      v.DoorExploded = true
      v:Remove()
		door:SetIsDoorBuster( true )
      door:Spawn()
		
      if self:GetOwner() then
        door:SetPhysicsAttacker(self:GetOwner())
      end

      local phys = door:GetPhysicsObject()

      phys:ApplyForceOffset((self:GetAngles():Up() * -10000) * phys:GetMass(), self:GetPos())
    end
  end


  self:Remove()
end

hook.Add( "EntityTakeDamage", "DoorBusterDamagePropDamage", function( ent, dmginfo )
	
	local inflictor = dmginfo:GetInflictor()

	--if ent:IsPlayer() and inflictor:GetClass() == "prop_physics" and IsValid( inflictor:GetIsDoorBuster() ) and inflictor:GetIsDoorBuster() == true then
	if ent:IsPlayer() and inflictor:GetClass() == "prop_physics" and inflictor:GetIsDoorBuster() == true then
		--print( "test" )
		local doorent = ents.Create ( "weapon_ttt_doorbuster" )
		dmginfo:SetInflictor( doorent )
		dmginfo:SetDamageType( DMG_GENERIC )
		doorent:Remove()
	end
end
)

function ENT:OnTakeDamage(dmginfo)
  if dmginfo:IsBulletDamage() or dmginfo:GetDamageType() == DMG_CLUB then
    self:SetHealth(self:Health() - dmginfo:GetDamage())
    if self:Health() <= 0 then
      self:BlowDoor()
    end
  end
end

hook.Add( "AcceptInput", "DoorBusterExplode", function( ent, input, ply, caller, value )
    if (ent:GetClass() == "prop_door" or ent:GetClass() == "func_door" or ent:GetClass() == "prop_door_rotating" or ent:GetClass() == "func_door_rotating" ) and (input == "Open" or input == "Use" or input == "Toggle") then
        for k,v in pairs(ents.FindInSphere(ent:GetPos(),80)) do
            local owner = v.GetOwner and v:GetOwner()
            if v:GetClass() == "entity_doorbuster" and owner and ply != owner and !v.Exploded then
                v:BlowDoor()
                return true
            end
        end
    end
end)

function ENT:SendWarn(armed)
		local owner = self.Owner
	if not TTT2 then	
		if (IsValid(owner) and owner:IsRole(ROLE_TRAITOR)) then
			net.Start("TTT_DoorBusterWarning")
				net.WriteUInt(self:EntIndex(), 16)
				net.WriteBool(armed)
				net.WriteVector(self:GetPos())
			net.Send(GetTraitorFilter(true))
		elseif (IsValid(owner) and owner:IsRole(ROLE_DETECTIVE)) then
			net.Start("TTT_DoorBusterWarning")
				net.WriteUInt(self:EntIndex(), 16)
				net.WriteBool(armed)
				net.WriteVector(self:GetPos())
			net.Send(GetDetectiveFilter(true))
		end
	else
		if (IsValid(owner)) then
			net.Start("TTT_DoorBusterWarning")
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

function ENT:OnRemove()
	self:SendWarn(false)
end