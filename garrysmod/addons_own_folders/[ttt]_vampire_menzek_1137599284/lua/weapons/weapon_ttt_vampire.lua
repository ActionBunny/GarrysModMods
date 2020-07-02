if SERVER then 
	AddCSLuaFile()
	resource.AddFile( "materials/effects/vampiresplatter.vtf" )
	resource.AddFile( "materials/effects/vampiresplatter.vmt" )
	resource.AddFile( "materials/vgui/ttt/vampire.png" )
end

local stealAmount = CreateConVar( "vp_stealamount", 15, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "How much health is taken from the victim")
local maxHealth = CreateConVar( "vp_maxhealth", 175, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Maximum amount of health the traitor can have")

SWEP.HoldType = "knife"

if CLIENT then

   SWEP.PrintName    = "Vampire"
   SWEP.Slot         = 6
  
   SWEP.ViewModelFlip = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[Steal the life out of any one unfortunate
	enough to be close to you.]]
   };

   SWEP.Icon = "vgui/ttt/vampire.png"
end

SWEP.Base               = "weapon_tttbase"

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 54
SWEP.ViewModel          = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel         = "models/weapons/w_knife_t.mdl"

SWEP.DrawCrosshair     	    = false
SWEP.Primary.Damage         = 0
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo           = "none"
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo         = "none"
SWEP.DeploySpeed            = 2

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = true 

-- These are used for the delay times in between healing and giving
SWEP.Primary.Delay = 0.4
SWEP.Secondary.Delay = 0.4

SWEP.VampRange = 400 -- How many units from the player's eyes that you can do the vampirism thingy

if CLIENT then
   local linex = 0
   local liney = 0
   local laser = Material("trails/laser")
   function SWEP:ViewModelDrawn()
      local client = LocalPlayer()
      local vm = client:GetViewModel()
      if not IsValid(vm) then return end

      local plytr = client:GetEyeTrace(MASK_SHOT)

      local muzzle_angpos = vm:GetAttachment(1)
      local spos = muzzle_angpos.Pos + muzzle_angpos.Ang:Forward() * 10
      local epos = client:GetShootPos() + client:GetAimVector() * maxrange

      -- Painting beam
      local tr = util.TraceLine({start=spos, endpos=epos, filter=client, mask=MASK_ALL})

      local c = COLOR_WHITE
      local a = 255
	  
	      if LocalPlayer():IsTraitor() then
                      
              c = COLOR_WHITE
               a = 255
        else
                 c = COLOR_RED
        end
     -- local d = (plytr.StartPos - plytr.HitPos):Length()
        -- if trace.HitSky == true then
            
          --     c = COLOR_GREEN
          --     a = 255
          --  else
           --    c = COLOR_YELLOW
          
       --  end
     


      render.SetMaterial(laser)
      render.DrawBeam(spos, tr.HitPos, 5, 0, 0, c)

      -- Charge indicator
      local vm_ang = muzzle_angpos.Ang
      local cpos = muzzle_angpos.Pos + (vm_ang:Up() * -4) + (vm_ang:Forward() * -18) + (vm_ang:Right() * -7)
      local cang = vm:GetAngles()
      cang:RotateAroundAxis(cang:Forward(), 90)
      cang:RotateAroundAxis(cang:Right(), 90)
      cang:RotateAroundAxis(cang:Up(), 90)

      cam.Start3D2D(cpos, cang, 0.05)

      surface.SetDrawColor(255, 55, 55, 50)
      surface.DrawOutlinedRect(0, 0, 50, 15)

      local sz = 48
      local next = self.Weapon:GetNextPrimaryFire()
      local ready = (next - CurTime()) <= 0
      local frac = 1.0
      if not ready then
         frac = 1 - ((next - CurTime()) / 5)
         sz = sz * math.max(0, frac)
      end

      surface.SetDrawColor(255, 10, 10, 170)
      surface.DrawRect(1, 1, sz, 13)

      surface.SetTextColor(255,255,255,15)
      surface.SetFont("Default")
      surface.SetTextPos(10,0)
      surface.DrawText("Target")

      surface.SetDrawColor(0,0,0, 80)
      surface.DrawRect(linex, 1, 3, 13)

      surface.DrawLine(1, liney, 48, liney)

      linex = linex + 3 > 48 and 0 or linex + 1
      liney = liney > 13 and 0 or liney + 1

      cam.End3D2D()

   end

   local draw = draw

end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	
	-- Traces a line from the players shoot position to 100 units
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos+( ang * self.VampRange)
	tracedata.filter = self.Owner
	local trace = util.TraceLine(tracedata)

	local target = trace.Entity
	if ( (not trace.HitWorld) and IsValid(target) and target:IsPlayer() ) then 
		local selfH = self.Owner:Health()
		local targetH = target:Health()
		
		local rate = stealAmount:GetFloat()
		local amount = math.random(rate - 2, rate + 2) -- A random value just cause
		
		local effect = EffectData()
        effect:SetStart( pos )
        effect:SetOrigin( trace.HitPos )
        effect:SetNormal( trace.Normal )
        effect:SetEntity( target )
		
		util.Effect("BloodImpact", effect)
		
		--self:EmitSound( "Weapon_Knife.Hit" )
		
		-- In order to show up in dmg logs, this actually hurts the player
		if SERVER then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage( amount )
			dmginfo:SetDamageType( DMG_SLASH ) 
			dmginfo:SetAttacker(self.Owner ) 
			dmginfo:SetInflictor(self)
			dmginfo:SetDamagePosition(self:GetPos())
	
			target:TakeDamageInfo(dmginfo)
		end
		
		-- Gives health to the player who held the Vampire up to the max limit
		if selfH ~= maxHealth:GetInt() then 
			self.Owner:SetHealth( math.Clamp(self.Owner:Health() + amount, 0, maxHealth:GetInt()) )
		end
	end
end

-- Does the same thing as the Primary attack except this time it allows you to give health
function SWEP:SecondaryAttack()
	--[[self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	
	-- Traces a line from the players shoot position to 100 units
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos+( ang * self.VampRange)
	tracedata.filter = self.Owner
	local trace = util.TraceLine(tracedata)

	local target = trace.Entity
	if ( (not trace.HitWorld) and IsValid(target) and target:IsPlayer() ) then
		self.Draining = true
		local selfH = self.Owner:Health()
		local targetH = target:Health()
			
		if targetH ~= self.MaxHealth then
			local rate = self.HealthRate
			local amount = math.random(rate - 2, rate + 2) -- A random value just cause
		-- Slightly modified from the Primary attack to give health 
			target:SetHealth(math.Clamp(target:Health() + amount, 0, self.MaxHealth))
			self.Owner:SetHealth(selfH - amount)
		else
			self.Owner:ChatPrint("Your friend has reached the max amount of health!")
		end
	else
		self.Draining = false
	end]]
end

function SWEP:DrawHUD()
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos+( ang * self.VampRange)
	tracedata.filter = self.Owner
	local trace = util.TraceLine(tracedata)
	local target = trace.Entity

	if ( (not trace.HitWorld) and IsValid(target) and target:IsPlayer() ) then
		local selfH = self.Owner:Health()
		local targetH = target:Health()
		-- Making sure the health box doesn't go out of the bounds of the regular box
		if targetH > 100 then
			targetH = 100
		end

		-- Health bar
		local w = ScrW()
		local h = ScrH()
		local x_axis, y_axis, width, height = w/2-w/21, h/2.8, w/11, h/20
		draw.RoundedBox(2, x_axis, y_axis, width, height, Color(10,10,10,200))
		draw.RoundedBox(2, x_axis, y_axis, width * (targetH / 100), height, Color(192,57,43,200))
		draw.SimpleText(target:Health(), "Trebuchet24", w/2, h/2.8 + height/2, Color(255,255,255,255), 1, 1)
		
		-- Blood splatter stuff
		local splatter = surface.GetTextureID( "effects/vampiresplatter" );

		local BoxSize = 128
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetTexture( splatter )
		surface.DrawTexturedRect( x_axis - 60, y_axis - 50, BoxSize, BoxSize )
	end
end


function SWEP:Equip()
   self.Weapon:SetNextPrimaryFire( CurTime() + (self.Primary.Delay * 1.5) )
   self.Weapon:SetNextSecondaryFire( CurTime() + (self.Secondary.Delay * 1.5) )
end

function SWEP:OnRemove()
   if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
      RunConsoleCommand("lastinv")
   end
end


if SERVER then 
	AddCSLuaFile()
	resource.AddFile( "materials/effects/vampiresplatter.vtf" )
	resource.AddFile( "materials/effects/vampiresplatter.vmt" )
	resource.AddFile( "materials/vgui/ttt/vampire.png" )
end

local stealAmount = CreateConVar( "vp_stealamount", 5, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "How much health is taken from the victim")
local maxHealth = CreateConVar( "vp_maxhealth", 150, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Maximum amount of health the traitor can have")

SWEP.HoldType = "knife"

if CLIENT then

   SWEP.PrintName    = "Vampire"
   SWEP.Slot         = 6
  
   SWEP.ViewModelFlip = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[Steal the life out of any one unfortunate
	enough to be close to you.]]
   };

   SWEP.Icon = "vgui/ttt/vampire.png"
end

SWEP.Base               = "weapon_tttbase"

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 54
SWEP.ViewModel          = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel         = "models/weapons/w_knife_t.mdl"

SWEP.DrawCrosshair     	    = false
SWEP.Primary.Damage         = 0
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo           = "none"
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo         = "none"
SWEP.DeploySpeed            = 2

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = true 

-- These are used for the delay times in between healing and giving
SWEP.Primary.Delay = 0.4
SWEP.Secondary.Delay = 0.4

SWEP.VampRange = 100 -- How many units from the player's eyes that you can do the vampirism thingy


function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	
	-- Traces a line from the players shoot position to 100 units
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos+( ang * self.VampRange)
	tracedata.filter = self.Owner
	local trace = util.TraceLine(tracedata)

	local target = trace.Entity
	if ( (not trace.HitWorld) and IsValid(target) and target:IsPlayer() ) then 
		local selfH = self.Owner:Health()
		local targetH = target:Health()
		
		local rate = stealAmount:GetFloat()
		local amount = math.random(rate - 2, rate + 2) -- A random value just cause
		
		local effect = EffectData()
        effect:SetStart( pos )
        effect:SetOrigin( trace.HitPos )
        effect:SetNormal( trace.Normal )
        effect:SetEntity( target )
		
		util.Effect("BloodImpact", effect)
		
		self:EmitSound( "Weapon_Knife.Hit" )
		
		-- In order to show up in dmg logs, this actually hurts the player
		if SERVER then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage( amount )
			dmginfo:SetDamageType( DMG_SLASH ) 
			dmginfo:SetAttacker(self.Owner ) 
			dmginfo:SetInflictor(self)
			dmginfo:SetDamagePosition(self:GetPos())
	
			target:TakeDamageInfo(dmginfo)
		end
		
		-- Gives health to the player who held the Vampire up to the max limit
		if selfH ~= maxHealth:GetInt() then 
			self.Owner:SetHealth( math.Clamp(self.Owner:Health() + amount, 0, maxHealth:GetInt()) )
		end
	end
end

-- Does the same thing as the Primary attack except this time it allows you to give health
function SWEP:SecondaryAttack()
	--[[self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	
	-- Traces a line from the players shoot position to 100 units
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos+( ang * self.VampRange)
	tracedata.filter = self.Owner
	local trace = util.TraceLine(tracedata)

	local target = trace.Entity
	if ( (not trace.HitWorld) and IsValid(target) and target:IsPlayer() ) then
		self.Draining = true
		local selfH = self.Owner:Health()
		local targetH = target:Health()
			
		if targetH ~= self.MaxHealth then
			local rate = self.HealthRate
			local amount = math.random(rate - 2, rate + 2) -- A random value just cause
		-- Slightly modified from the Primary attack to give health 
			target:SetHealth(math.Clamp(target:Health() + amount, 0, self.MaxHealth))
			self.Owner:SetHealth(selfH - amount)
		else
			self.Owner:ChatPrint("Your friend has reached the max amount of health!")
		end
	else
		self.Draining = false
	end]]
end

function SWEP:DrawHUD()
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos+( ang * self.VampRange)
	tracedata.filter = self.Owner
	local trace = util.TraceLine(tracedata)
	local target = trace.Entity

	if ( (not trace.HitWorld) and IsValid(target) and target:IsPlayer() ) then
		local selfH = self.Owner:Health()
		local targetH = target:Health()
		-- Making sure the health box doesn't go out of the bounds of the regular box
		if targetH > 100 then
			targetH = 100
		end

		-- Health bar
		local w = ScrW()
		local h = ScrH()
		local x_axis, y_axis, width, height = w/2-w/21, h/2.8, w/11, h/20
		draw.RoundedBox(2, x_axis, y_axis, width, height, Color(10,10,10,200))
		draw.RoundedBox(2, x_axis, y_axis, width * (targetH / 100), height, Color(192,57,43,200))
		draw.SimpleText(target:Health(), "Trebuchet24", w/2, h/2.8 + height/2, Color(255,255,255,255), 1, 1)
		
		-- Blood splatter stuff
		local splatter = surface.GetTextureID( "effects/vampiresplatter" );

		local BoxSize = 128
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetTexture( splatter )
		surface.DrawTexturedRect( x_axis - 60, y_axis - 50, BoxSize, BoxSize )
	end
end


function SWEP:Equip()
   self.Weapon:SetNextPrimaryFire( CurTime() + (self.Primary.Delay * 1.5) )
   self.Weapon:SetNextSecondaryFire( CurTime() + (self.Secondary.Delay * 1.5) )
end

function SWEP:OnRemove()
   if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
      RunConsoleCommand("lastinv")
   end
end


