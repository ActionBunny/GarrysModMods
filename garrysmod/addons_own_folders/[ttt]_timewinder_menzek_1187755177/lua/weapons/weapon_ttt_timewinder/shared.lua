AddCSLuaFile()
if SERVER then
	util.AddNetworkString( "UpdateTimeWinderHUD" )
end
if CLIENT then
	
	SWEP.PrintName = "Time Winder"
	SWEP.Slot = 7

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Go back in time by up to thirty seconds. \nSecAtt shortens the delay, Reload prolongs \nand PrimAtt starts the Timer. \nYou'll restore a small amount of Health. \nThree uses only. Deals Blastdamage."
   };	

	SWEP.Icon = "vgui/ttt/icon_timewinder"
end

SWEP.LuaViewmodelRecoil = false
SWEP.CanRestOnObjects = false

SWEP.Base = "weapon_tttbase"

SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_watch.mdl"
SWEP.WorldModel		= "models/weapons/w_watch.mdl"

SWEP.DrawCrosshair      = false
SWEP.ViewModelFlip      = false
SWEP.Primary.ClipSize    = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.ClipMax     = 30
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "GaussEnergy"
SWEP.Primary.Delay = 0.5

SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 1.0

SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.WeaponID = AMMO_REWINDER

SWEP.AllowDrop = true
SWEP.NoSights = true
SWEP.CSMuzzleFlashes = false
SWEP.charges = 3
local delay_beamup = 0
local delay_beamdown = 0

function SWEP:Initialize()
	--self.charges = 3
	if CLIENT then
		
		  self:AddHUDHelp("PrimAtt starts the Timer.", "SecAtt shortens the delay, Reload prolongs.", false)

		  return self.BaseClass.Initialize(self)

	end
end

local function UpdateTWHUD( WEP )
	if SERVER then
		if IsValid(WEP:GetOwner()) then
			net.Start( "UpdateTimeWinderHUD" )
			net.WriteString( WEP.charges )
			net.WriteString( WEP:Clip1() )
			net.Send( WEP:GetOwner() )
		end
	end
end

function SWEP:OnDrop()
	UpdateTWHUD( self )
end

local function CanStoreTeleportPosClient(ply, pos)
   local g = ply:GetGroundEntity()
   if g != game.GetWorld() or (IsValid(g) and g:GetMoveType() != MOVETYPE_NONE) then
      return false
   elseif ply:Crouching() then
      return false
   end

   return true
end

function SWEP:SetTeleportMark(pos, ang, health)
   self.teleport = {pos = pos, ang = ang}
   self.health = health
end

function SWEP:GetTeleportMark() return self.teleport end
function SWEP:GetTeleportHealth() return self.health end

function SWEP:Reload()
	local ply = self.Owner
	if SERVER then
		if timer.Exists( ply:Nick() .. "_teleport" ) == false then
			if self:Clip1() < 26 then
				self:TakePrimaryAmmo(-5)
			end
		else
			--self:DryFire(self.SetNextSecondaryFire)
		end
	end
	UpdateTWHUD( self )
end

function SWEP:SecondaryAttack()
	local ply = self.Owner
	if SERVER then
		if timer.Exists( ply:Nick() .. "_teleport" ) == false then
			if self:Clip1() >= 6 then
				self:TakePrimaryAmmo(5)
			end
		else
			--self:DryFire(self.SetNextSecondaryFire)
		end
	end
	UpdateTWHUD( self )
end

function SWEP:PrimaryAttack()
	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

	if GetRoundState() == ROUND_POST then --self:DryFire(self.SetNextSecondaryFire) 
	return 
	end
   
    local ply = self.Owner
   
	local allow, msg = CanStoreTeleportPosClient(ply, self:GetPos())
   
	if not allow then
		if SERVER then self:TeleportStore() end
		--self:DryFire(self.SetNextSecondaryFire)
		return
	end
	
	if timer.Exists( ply:Nick() .. "_teleport" ) then
		--self:DryFire(self.SetNextSecondaryFire)
		return
	end
   
	if timer.Exists( ply:Nick() .. "_tock" ) then
		--self:DryFire(self.SetNextSecondaryFire)
		return
	end
   
	if SERVER then
	
		self:TeleportStore()
		
		timer.Create( ply:Nick() .. "_teleport", 1, 30, function()
			if ply:HasWeapon( self.ClassName ) and self:Clip1() > 1 then
				
			else
				local e = EffectData()
				e:SetOrigin(self:GetPos())
				e:SetRadius(64)
				e:SetMagnitude(0.5)
				e:SetScale(1.5)
				util.Effect("pulse_sphere", e)
			
				self:TeleportRecall()
				
				timer.Simple( 0.1, function() 
					ply:SelectWeapon( self.ClassName )
					self:SetClip1(30) end )
				timer.Destroy( ply:Nick() .. "_teleport" ) 
			end	
		end )
		
		timer.Create( ply:Nick() .. "_tick", 1, 30, function() 
			if ply:HasWeapon( self.ClassName ) and self:Clip1() > 1 then
				self:TakePrimaryAmmo(1)
				UpdateTWHUD( self )
			else
				timer.Destroy( ply:Nick() .. "_tick" ) 
			end	
		end )

	end
	
	if CLIENT then
		surface.PlaySound("ui/buttonrollover.wav")
		
		local loopingSound = CreateSound( self, "ambient/machines/ticktock.wav" )
		loopingSound:Play()
		--timer.Simple( 30, function() loopingSound:Stop() end )
		local pos = ply:GetPos()
		local ang = ply:EyeAngles()
		local seq = ply:GetSequence()
		local cyc = ply:GetCycle()
		local aim = ply:GetAimVector()
		timer.Create( ply:Nick() .. "_tock", 1, 30, function()
			if ply:HasWeapon( self.ClassName ) and self:Clip1() > 1 then
				local mark = self:GetTeleportMark()
				local e = EffectData()
				e:SetEntity(ply)
				e:SetOrigin(pos)
				e:SetAngles(ang)
				e:SetColor(seq)
				e:SetScale(cyc)
				e:SetStart(aim)
				e:SetRadius(2)
				util.Effect("crimescene_dummy", e)
			else
				loopingSound:Stop()
				timer.Destroy( ply:Nick() .. "_tock" ) 
			end
		end )
	end
	UpdateTWHUD( self )
end

local zap = Sound("ambient/levels/labs/electric_explosion4.wav")
local unzap = Sound("ambient/levels/labs/electric_explosion2.wav")

local function Telefrag(victim, attacker, weapon)
   if not IsValid(victim) then return end

   local dmginfo = DamageInfo()
   dmginfo:SetDamage(5000)
   dmginfo:SetDamageType(DMG_SONIC)
   dmginfo:SetAttacker(attacker)
   dmginfo:SetInflictor(weapon)
   dmginfo:SetDamageForce(Vector(0,0,10))
   dmginfo:SetDamagePosition( attacker:GetPos() )

   victim:TakeDamageInfo(dmginfo)
end
--[[
local function Telefail(victim, attacker, weapon)
   if not IsValid(victim) then return end

   local modifier = 1.25^victim:WaterLevel()
   print( modifier )
   local dmginfo = DamageInfo()
   dmginfo:SetDamage( math.random( 40, 45 ) )
   
   dmginfo:SetDamageType(DMG_SONIC)
   dmginfo:SetAttacker(attacker)
   dmginfo:SetInflictor(weapon)
   dmginfo:SetDamageForce(Vector(0,0,10))
   dmginfo:SetDamagePosition(attacker:GetPos())

   victim:TakeDamageInfo(dmginfo)
end
]]
local function ShouldCollide(ent)
   local g = ent:GetCollisionGroup()
   return (g != COLLISION_GROUP_WEAPON and
           g != COLLISION_GROUP_DEBRIS and
           g != COLLISION_GROUP_DEBRIS_TRIGGER and
           g != COLLISION_GROUP_INTERACTIVE_DEBRIS)
end



-- Teleport a player to a {pos, ang}
function TeleportPlayerTimeWinder(ply, teleport, weapon)
   local oldpos = ply:GetPos()
   local pos = teleport.pos
   local ang = teleport.ang
	weapon.charges = weapon.charges - 1
	UpdateTWHUD( weapon )
   -- print decal on destination
   --util.PaintDown(pos + Vector(0,0,25), "GlassBreak", ply)

   -- perform teleport
   ply:SetPos(pos)
   ply:SetEyeAngles(ang) -- ineffective due to freeze...

   timer.Simple(delay_beamdown, function ()
                                   if IsValid(ply) then
                                      ply:Freeze(false)
                                   end
                                end)

   sound.Play(zap, oldpos, 75, 100)
   sound.Play(unzap, pos, 90, 100)
	if weapon.charges < 1 then
		weapon:Remove()
	end
   -- print decal on source now that we're gone, because else it will refuse
   -- to draw for some reason
   --util.PaintDown(oldpos + Vector(0,0,25), "GlassBreak", ply)
end

-- Checks teleport destination. Returns bool and table, if bool is true then
-- location is blocked by world or prop. If table is non-nil it contains a list
-- of blocking players.
local function CanTeleportToPos(ply, pos)
   -- first check if we can teleport here at all, because any solid object or
   -- brush will make us stuck and therefore kills/blocks us instead, so the
   -- trace checks for anything solid to players that isn't a player
   local tr = nil
   local tres = {start=pos, endpos=pos, mask=MASK_PLAYERSOLID, filter=player.GetAll()}
   local collide = false

   -- This thing is unnecessary if we can supply a collision group to trace
   -- functions, like we can in source and sanity suggests we should be able
   -- to do so, but I have not found a way to do so yet. Until then, re-trace
   -- while extending our filter whenever we hit something we don't want to
   -- hit (like weapons or ragdolls).
   repeat
      tr = util.TraceEntity(tres, ply)

      if tr.HitWorld then
         collide = true
      elseif IsValid(tr.Entity) then
         if ShouldCollide(tr.Entity) then
            collide = true
         else
            table.insert(tres.filter, tr.Entity)
         end
      end
   until (not tr.Hit) or collide

   if collide then
      --Telefrag(ply, ply)
      return true, nil
   else

      -- find all players in the place where we will be and telefrag them
      local blockers = ents.FindInBox(pos + Vector(-16, -16, 0),
                                      pos + Vector(16, 16, 64))

      local blocking_plys = {}

      for _, block in pairs(blockers) do
         if IsValid(block) then
            if block:IsPlayer() and block != ply then
               if block:IsTerror() and block:Alive() then
                  table.insert(blocking_plys, block)
                  -- telefrag blocker
                  --Telefrag(block, ply)
               end
            end
         end
      end

      return false, blocking_plys
   end

   return false, nil
end

local function DoTeleport(ply, teleport, weapon)
   if IsValid(ply) and ply:IsTerror() and teleport then
      local fail = false

      local block_world, block_plys = CanTeleportToPos(ply, teleport.pos)

      if block_world then
         -- if blocked by prop/world, always fail
         fail = true
      elseif block_plys and #block_plys > 0 then
		--for _, p in pairs(block_plys) do
		 --  Telefrag(p, ply, weapon)
		--end
      end

      if not fail then
         TeleportPlayerTimeWinder(ply, teleport, weapon)
      else
         ply:Freeze(false)
         LANG.Msg(ply, "tele_failed")
      end
   elseif IsValid(ply) then
      -- should never happen, but at least unfreeze
      ply:Freeze(false)
      LANG.Msg(ply, "tele_failed")
   end
end

local function FragAoa(ply, teleport, weapon)
  
  util.BlastDamage(weapon, ply, teleport.pos, 400, 200 )
  --expl:EmitSound( "ambient/energy/zap1.wav", 400, 200 )
--[[
   local dmginfo = DamageInfo()
   dmginfo:SetDamage(5000)
   dmginfo:SetDamageType(DMG_SONIC)
   dmginfo:SetAttacker(attacker)
   dmginfo:SetInflictor(weapon)
   dmginfo:SetDamageForce(Vector(0,0,10))
   dmginfo:SetDamagePosition( attacker:GetPos() )

   victim:TakeDamageInfo(dmginfo)]]	
end

local function StartTeleport(ply, teleport, weapon)
   if (not IsValid(ply)) or (not ply:IsTerror()) or (not teleport) then
      return end

   --teleport.ang = ply:EyeAngles()
	FragAoa(ply, teleport, weapon)
	
   timer.Simple(delay_beamup, function() DoTeleport(ply, teleport, weapon) end)
end

function SWEP:TeleportRecall(ply)
   local ply = self.Owner
   if IsValid(ply) and ply:IsTerror() then
      local mark = self:GetTeleportMark()
	  local oldhealth = self:GetTeleportHealth()
	  local addhealth = ply:Health() + ( oldhealth - ply:Health() ) * math.random( 0.5, 0.75 )
      if mark then
         timer.Simple(0.2, function()
			StartTeleport(ply, mark, self)
			ply:SetHealth(  addhealth )
		 end)
      else
         LANG.Msg(ply, "tele_no_mark")
      end
	  
   end
end

local function CanStoreTeleportPos(ply, pos)
   local g = ply:GetGroundEntity()
   if g != game.GetWorld() or (IsValid(g) and g:GetMoveType() != MOVETYPE_NONE) then
      return false, "tele_no_mark_ground"
   elseif ply:Crouching() then
      return false, "tele_no_mark_crouch"
   end

   return true, nil
end

function SWEP:TeleportStore()
	local ply = self.Owner
	local mark = self:GetTeleportMark()
	if IsValid(ply) and ply:IsTerror() then

	  local allow, msg = CanStoreTeleportPos(ply, self:GetPos())

	  if not allow then
		 LANG.Msg(ply, msg)
		 return
	  end

	  self:SetTeleportMark(ply:GetPos(), ply:EyeAngles(), ply:Health())

	local pos = ply:GetPos()
	local ang = ply:GetAngles()
	  
	  LANG.Msg(ply, "tele_marked")
	  
	  		timer.Simple( 29, function()
			
			
			
			local edata_up = EffectData()
			edata_up:SetOrigin(pos)
			ang = Angle(0, ang.y, ang.r) -- deep copy
			edata_up:SetAngles(ang)
			edata_up:SetEntity(ply)
			edata_up:SetMagnitude(1)
			edata_up:SetRadius(1)

			util.Effect("teleport_beamup", edata_up)
		end )
	end
end

function SWEP:Deploy()
   if SERVER and IsValid(self.Owner) then
      self.Owner:DrawViewModel(false)
   end
	 UpdateTWHUD(self)
   return true
end

function SWEP:ShootEffects() end



if CLIENT then
	charges = 3
	timeLeft = 30
	
	net.Receive( "UpdateTimeWinderHUD", function()
		charges = net.ReadString()
		timeLeft = net.ReadString()
		equipped = net.ReadString()
	end)
	
	hook.Add( "HUDPaint", "TimeWinderHUD", function()
		local w = ScrW()
		local h = ScrH()
		local x = 250
		local y = 30
		local x_axis = w - x
		local y_axis = ( h / 2 )
		
		if LocalPlayer():HasWeapon( "weapon_ttt_timewinder" ) then
			draw.RoundedBox(2, x_axis, y_axis, x, y, Color(10,10,10,200))
			text = " TimeWinder --- Charges left: " .. charges .. " Time left: "
			draw.SimpleText(text, "Trebuchet18", x_axis, y_axis + (y/2), Color(0,255,0,255), 0, 1)
			
			y_axis = y_axis + y
			draw.RoundedBox(2, (w - x/2), y_axis, (x/2), (y*2), Color(10,10,10,200))
			text = " " .. timeLeft
			draw.SimpleText(text, "DermaLarge", (w - x/2), y_axis + (y), Color(255,10,10,255), 0, 1)
		else
		
		end
	end)
end