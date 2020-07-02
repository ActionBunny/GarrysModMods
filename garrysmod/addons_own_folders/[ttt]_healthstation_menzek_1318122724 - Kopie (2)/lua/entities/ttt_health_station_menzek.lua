---- Health dispenser
--hook.Run("TTT2ModifyFiles", TTTFiles)

if SERVER then
	util.AddNetworkString("HS2Message")
--	AddCSLuaFile()
end
if CLIENT then
   -- this entity can be DNA-sampled so we need some display info
   ENT.Icon = "vgui/ttt/icon_health"
   ENT.PrintName = "HealthStation_Menzek"

   local GetPTranslation = LANG.GetParamTranslation

   ENT.TargetIDHint = {
      name = "HealthStation_Menzek",
      hint = "HealthStation_Menzek",
      fmt  = function(ent, txt)
                return GetPTranslation(txt,
                                       { usekey = Key("+use", "USE"),
                                         num    = ent:GetStoredHealth() or 0 } )
             end
   };
	net.Receive("HS2Message", function()
		local text = net.ReadString()
		chat.AddText( Color(255,0,0), text )
	end)
end

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Model = Model("models/props/cs_office/microwave.mdl")

--ENT.CanUseKey = true
ENT.CanHavePrints = true
ENT.MaxHeal = 25
ENT.MaxStored = 100
ENT.RechargeRate = 1
ENT.RechargeFreq = 2 -- in seconds

ENT.NextHeal = 0
ENT.HealRate = 1
ENT.HealFreq = 0.2

AccessorFuncDT(ENT, "StoredHealth", "StoredHealth")

AccessorFunc(ENT, "Placer", "Placer")

local poisonTimers = {}

function ENT:SetupDataTables()
   self:DTVar("Int", 0, "StoredHealth")
end

function ENT:Initialize()
   self:SetModel(self.Model)
	if SERVER then
	self:PhysicsInit(SOLID_VPHYSICS)
	end
   self:SetMoveType(MOVETYPE_VPHYSICS)
   self:SetSolid(SOLID_BBOX)

   self:SetCollisionGroup(COLLISION_GROUP_NONE)
   if SERVER then
      self:SetMaxHealth(100)

      local phys = self:GetPhysicsObject()
      if IsValid(phys) then
         phys:SetMass(40)
      end

      self:SetUseType(CONTINUOUS_USE)
   end
   self:SetHealth(100)

   self:SetColor(Color(180, 180, 250, 255))

   self:SetStoredHealth(100)

   self:SetPlacer(nil)

   self.NextHeal = 0

   self.fingerprints = {}
end


function ENT:AddToStorage(amount)
   self:SetStoredHealth(math.min(self.MaxStored, self:GetStoredHealth() + amount))
end

function ENT:TakeFromStorage(amount)
   -- if we only have 5 healthpts in store, that is the amount we heal
   amount = math.min(amount, self:GetStoredHealth())
   self:SetStoredHealth(math.max(0, self:GetStoredHealth() - amount))
   return amount
end

local healsound = Sound("items/medshot4.wav")
local failsound = Sound("items/medshotno1.wav")

local last_sound_time = 0
function ENT:GiveHealth(ply, max_heal)
   if self:GetStoredHealth() > 0 then
      max_heal = max_heal or self.MaxHeal
      local dmg = ply:GetMaxHealth() - ply:Health()
      if dmg > 0 then
         -- constant clamping, no risks
         local healed = self:TakeFromStorage(math.min(max_heal, dmg))
         local new = math.min(ply:GetMaxHealth(), ply:Health() + healed)

         ply:SetHealth(new)
         hook.Run("TTTPlayerUsedHealthStation", ply, self, healed)

         if last_sound_time + 2 < CurTime() then
            self:EmitSound(healsound)
            last_sound_time = CurTime()
         end

         if not table.HasValue(self.fingerprints, ply) then
            table.insert(self.fingerprints, ply)
         end

         return true
      else
         self:EmitSound(failsound)
      end
   else
      self:EmitSound(failsound)
   end

   return false
end

function ENT:Use(ply)
   if IsValid(ply) and ply:IsPlayer() and ply:IsActive() then
      local t = CurTime()
	  
	  ply.isPoisoned = ply.isPoisoned or false
	  		
	  if self:GetNWBool( "IsPoisoned", false ) then	
		attacker = self:GetNWEntity( "PoisonAttacker" )
		if ply.isPoisoned == false then
			ply.isPoisoned = true
			local uni = ply:UniqueID()
			ply:EmitSound("ambient/voices/citizen_beaten" .. math.random(1,5) .. ".wav",500,100)
			
			list.Add( poisonTimers, uni.."poisonhealth" )
			timer.Create(uni .. "poisonhealth", 1, 0, function()
				
				local ent = ents.Create('ttt_health_station_menzek')
				
				if IsValid(ply) and ply:Alive() then
					if IsValid(attacker)then
						local dmg = DamageInfo()
						dmg:SetDamage(5)
						dmg:SetAttacker(attacker)
						dmg:SetInflictor(ent)
						dmg:SetDamageType(DMG_POISON)
						ply:TakeDamageInfo(dmg)
						DamageLog("POISON:\t " .. attacker:Nick() .. " [" .. attacker:GetRoleString() .. "]" .. " poisoned " .. (IsValid(ply) and ply:Nick() or "<disconnected>") .." [" .. ply:GetRoleString() .. "]" .. " with a Poisoned Health Station.")
					else
						local dmg = DamageInfo()
						dmg:SetDamage(5)
						dmg:SetAttacker(ent)
						dmg:SetInflictor(ent)
						dmg:SetDamageType(DMG_POISON)
						ply:TakeDamageInfo(dmg)
						DamageLog("POISON:\t " .. (IsValid(ply) and ply:Nick() or "<disconnected>") .." [" .. ply:GetRoleString() .. "]" .. " was poisoned by a Poisoned Health Station.")
					end
				else
					timer.Stop(uni .. "poisonhealth")
				end
				
				ent:Remove()
			end)
		end
			
      elseif t > self.NextHeal then
         local healed = self:GiveHealth(ply, self.HealRate)

         self.NextHeal = t + (self.HealFreq * (healed and 1 or 2))
      end
   end
end

if SERVER then
   -- recharge
   local nextcharge = 0
   function ENT:Think()
      if nextcharge < CurTime() then
         self:AddToStorage(self.RechargeRate)

         nextcharge = CurTime() + self.RechargeFreq
      end
   end

   local ttt_damage_own_healthstation = CreateConVar("ttt_damage_own_healthstation", "0") -- 0 as detective cannot damage their own health station
	
   -- traditional equipment destruction effects
   function ENT:OnTakeDamage(dmginfo)
      if dmginfo:GetAttacker() == self:GetPlacer() and not ttt_damage_own_healthstation:GetBool() then return end
		local att = dmginfo:GetAttacker()
		local inf = dmginfo:GetInflictor()
		
		if att:GetRole() == ROLE_TRAITOR and inf == "weapon_zm_improvised" then
			if self:GetNWBool( "IsPoisoned", false ) then	
				self:SetNWEntity( "PoisonAttacker", att )
				self:SetNWBool( "IsPoisoned", true )
				
				net.Start( "MapvoteMapInfo")	
					net.WriteString( "You poisoned Healthsation" )
				net.Send( att )
			else
				self:SetNWEntity( "PoisonAttacker", att )
				self:SetNWBool( "IsPoisoned", false )
				
				net.Start( "MapvoteMapInfo")	
					net.WriteString( "You unpoisoned Healthsation" )
				net.Send( att )			
			end
		end
      self:TakePhysicsDamage(dmginfo)

      self:SetHealth(self:Health() - dmginfo:GetDamage())

      local att = dmginfo:GetAttacker()
      local placer = self:GetPlacer()
      if IsPlayer(att) then
         DamageLog(Format("DMG: \t %s [%s] damaged health station [%s] for %d dmg", att:Nick(), att:GetRoleString(),  (IsPlayer(placer) and placer:Nick() or "<disconnected>"), dmginfo:GetDamage()))
      end

      if self:Health() < 0 then
         self:Remove()

         util.EquipmentDestroyed(self:GetPos())

         if IsValid(self:GetPlacer()) then
            LANG.Msg(self:GetPlacer(), "hstation_broken")
         end
      end
   end
end

hook.Add("DoPlayerDeath", "DoPlayerDeathHealthstation_Menzek", function( ply, attacker, dmg )
	if ply.isPoisoned then
		timer.Stop(ply:UniqueID() .. "poisonhealth" )
		ply.isPoisoned = false
	end
end)
hook.Add("TTTPrepareRound", "TTTPrepareRoundHealthStation_Menzek", function()
	for _,v in pairs( player.GetAll() ) do
		v.isPoisoned = false
		timer.Stop( v:UniqueID() .. "poisonhealth" )
	end
end)