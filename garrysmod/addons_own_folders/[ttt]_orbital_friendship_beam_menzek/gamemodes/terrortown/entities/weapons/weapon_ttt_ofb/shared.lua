--This code be sloppy as hell son... ,Broly
--Notes([x] Means Done): 
--[X]Figure out why I am unable to remove the first laser if more then one are fired at the same time.
--[X]Get LTBCKI Sound to play at point of shot.
--[ ]Apply burnned ground texture under laser.
--[ ]

CreateConVar( "ttt_ofb_radius", "300", FCVAR_NOTIFY + FCVAR_ARCHIVE , "Adjust the damageradius of the blast. 300 is ok." )
CreateConVar( "ttt_ofb_laser_radius", "20", FCVAR_NOTIFY + FCVAR_ARCHIVE , "Adjust the damageradius of the laser. 20 is ok." )
local function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local ShootSound = Sound( "OFB/LTBCKI.wav" )
local FireSound = Sound ( "OFB/Shot.wav" )
local FailSound = Sound ( "OFB/Fail.wav" )
local SeconSound = Sound( "OFB/Secondary.wav" )

local function around( val )
   return math.Round( val * (10 ^ 3) ) / (10 ^ 3);
end

if SERVER then
	AddCSLuaFile( "shared.lua" )
	resource.AddFile("sound/OFB/LTBCKI.wav")
	resource.AddFile("sound/OFB/Shot.wav")
	resource.AddFile("sound/OFB/Fail.wav")
	resource.AddFile("sound/OFB/Secondary.wav")
	
	resource.AddFile("materials/rainbeam/rainbow1.vmt")
	resource.AddFile("materials/rainbeam/rainbow2d.vmt")
	
	resource.AddFile("materials/models/weapons/v_vikgun/energy.vmt")
	resource.AddFile("materials/models/weapons/v_vikgun/v_hand_sheet.vmt")
	resource.AddFile("materials/models/weapons/v_vikgun/vikgun.vmt")

	
	
	resource.AddFile("materials/VGUI/ttt/tttofb_icon.vmt")
	
	resource.AddFile("models/weapons/v_vikgun.mdl")
	
	SWEP.HoldType			= "shotgun"
end
local function ValidTarget(ent)

   return IsValid(ent) and ent:GetMoveType() == MOVETYPE_VPHYSICS and ent:GetPhysicsObject() and (not ent:IsWeapon()) and (not ent:GetNWBool("punched", false))
   -- NOTE: cannot check for motion disabled on client
end

-- Equipment menu information is only needed on the client
if CLIENT then

   -- Path to the icon material
   SWEP.Icon = "materials/VGUI/ttt/tttofb_icon"

   -- Text shown in the equip menu
   SWEP.EquipMenuData = {
      type = "Orbital Friendship Beam",
      desc = "Let the Magic of Friendship get 'em!"
   };
end
SWEP.Base = "weapon_tttbase"
SWEP.PrintName = "Orbital Friendship Beam"
SWEP.Icon = "VGUI/ttt/tttofb_icon.vmt"
SWEP.Category = "Conti's Weapons"
SWEP.Kind = WEAPON_EQUIP2
SWEP.AutoSpawnable = false
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.InLoadoutFor = nil
SWEP.LimitedStock = true
SWEP.AllowDrop = true 
SWEP.IsSilent = false
SWEP.NoSights = true

SWEP.Primary.Recoil			= 5
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize        = 1
SWEP.Primary.DefaultClip    = 1
SWEP.Primary.ClipMax = 1
SWEP.Primary.Automatic        = false
SWEP.Primary.Delay			= 30 

SWEP.ViewModel            = "models/weapons/v_vikgun.mdl"
SWEP.WorldModel  		 =			"models/weapons/w_irifle.mdl"

SWEP.Slot      = 8
SWEP.ViewModelFOV  = 65
SWEP.ViewModelFlip = false

SWEP.IsCharging = false
SWEP.NextCharge = 0

AccessorFuncDT(SWEP, "charge", "Charge")


local maxrange = 800

local math = math

function SWEP:SetupDataTables()
   self:DTVar("Float", 0, "charge")
end



function SWEP:Initialize()
   return self.BaseClass.Initialize(self)
end

function SWEP:PreDrop()
   self.IsCharging = false
   self:SetCharge(0)

   -- OnDrop does not happen on client
  
end

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


/*---------------------------------------------------------
   Think
---------------------------------------------------------*/



/*---------------------------------------------------------
    Reload
---------------------------------------------------------*/
function SWEP:Reload()
    self:EmitSound( FireSound )
end

/*---------------------------------------------------------
    PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
    local tr = self.Owner:GetEyeTrace()
    local tracedata = {}
	
    tracedata.start = tr.HitPos + Vector(0,0,0)
    tracedata.endpos = tr.HitPos + Vector(0,0,50000)
    tracedata.filter = ents.GetAll()
    local trace = util.TraceLine(tracedata)
	if trace.HitSky == true then
        hitsky = true	
    else
        hitsky = true
    end
    
    if hitsky == true then
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
        self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
        self:EmitSound( ShootSound )
		--self:EmitSound( FireSound )	
    else
        self:EmitSound( FailSound )
    end
    
    // The rest is only done on the server
    if (!SERVER) then return end
	
	if hitsky == true then
	--self:CreateHammer(tr.Entity, tr.HitPos)
		self:TakePrimaryAmmo(1)

		--sound.Play("OFB/LTBCKI.wav", tr.HitPos, 180, 100 )
        --sound.Play("OFB/LTBCKI.wav", trace.HitPos, 180, 100 )
        timer.Simple( 2.8, function() start(tr, trace, self) end)
        timer.Simple( 19.2, function() kill(self) end)
		
	end
end

/*---------------------------------------------------------
    SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()   
    self:EmitSound( SeconSound )
end


function start(tr, trace, self)
-------Slow Mo  
  --self.TimeScale = math.min(self.TimeScale and self.TimeScale + .25 or .1,1)
--game.SetTimeScale(self.TimeScale)
	--print( self.Owner )
    local tracedata2 = {}
    tracedata2.start = trace.HitPos
    tracedata2.endpos = trace.HitPos + Vector(0,0,-50000)
    tracedata2.filter = ents.GetAll()
    local trace2 = util.TraceLine(tracedata2)

    self.glow = ents.Create("env_lightglow")
	self.glow:SetKeyValue("rendercolor", "255 255 255")
    self.glow:SetKeyValue("VerticalGlowSize", "40")
    self.glow:SetKeyValue("HorizontalGlowSize", "40")
    self.glow:SetKeyValue("MaxDist", "500")
    self.glow:SetKeyValue("MinDist", "0")
    self.glow:SetKeyValue("HDRColorScale", "100")
    self.glow:SetPos(trace2.HitPos + Vector(0,0,32))
    self.glow:Spawn()
    
    self.glow2 = ents.Create("env_lightglow")
	self.glow2:SetKeyValue("rendercolor", "255 255 255")
    self.glow2:SetKeyValue("VerticalGlowSize", "40")
    self.glow2:SetKeyValue("HorizontalGlowSize", "40")
    self.glow2:SetKeyValue("MaxDist", "500")
    self.glow2:SetKeyValue("MinDist", "0")
    self.glow2:SetKeyValue("HDRColorScale", "100")
    self.glow2:SetPos(trace2.HitPos + Vector(0,0,32))
    self.glow2:Spawn()
    
    self.glow3 = ents.Create("env_lightglow")
	self.glow3:SetKeyValue("rendercolor", "255 255 255")
    self.glow3:SetKeyValue("VerticalGlowSize", "30")
    self.glow3:SetKeyValue("HorizontalGlowSize", "30")
    self.glow3:SetKeyValue("MaxDist", "500")
    self.glow3:SetKeyValue("MinDist", "0")
    self.glow3:SetKeyValue("HDRColorScale", "100")
    self.glow3:SetPos(trace2.HitPos + Vector(0,0,27000))
    self.glow3:Spawn()
    
    self.targ = ents.Create("info_target")
    self.targ:SetKeyValue("targetname", tostring(self.targ))
    self.targ:SetPos(tr.HitPos + Vector( 0, 0, -50000 ))
    self.targ:Spawn()
    
    self.laser = ents.Create("env_laser")
    self.laser:SetKeyValue("texture", "rainbeam/rainbow1.vmt")
    self.laser:SetKeyValue("TextureScroll", "100")
    self.laser:SetKeyValue("noiseamplitude", "0")
    self.laser:SetKeyValue("width", "512")
    self.laser:SetKeyValue("damage", "0")
    self.laser:SetKeyValue("rendercolor", "255 255 255")
    self.laser:SetKeyValue("renderamt", "255")
    self.laser:SetKeyValue("dissolvetype", "0")
    self.laser:SetKeyValue("lasertarget", tostring(self.targ))
    self.laser:SetPos(trace.HitPos)
    self.laser:Spawn()
    self.laser:Fire("turnon",0)
	--util.PaintDown(trace.hitpos, "GlassBreak", ply)
	
    self.laser:SetPos(trace.HitPos)
    self.laser:Spawn()
    self.laser:Fire("turnon",0)
	
    
    self.effects = ents.Create("effects")
    self.effects:SetPos(trace.HitPos)
    self.effects:Spawn()
    
    self.remover = ents.Create("remover")
    self.remover:SetPos(trace.HitPos)
    self.remover:Spawn()
    
    self.blastwave = ents.Create("blastwave")
		--verursacht Schaden
	self.blastwave:SetThrower( self.Owner )
	self.blastwave:SetBeamweapon( self )
    self.blastwave:SetPos(trace2.HitPos)
    self.blastwave:Spawn()
    
end

function kill(self)
	local ToDelete = {self.targ,self.effects,self.remover,self.blastwave,self.glow,self.glow2,self.glow3,self.laser}
	for k,v in pairs(ToDelete) do if v and v:IsValid() then v:Remove() self:Remove()  end end --
	
end

local ENT = {}
ENT.Type   = "anim"
ENT.Base                = "base_anim"
ENT.PrintName           = "effects"
ENT.RenderGroup         = RENDERGROUP_TRANSLUCENT
if (CLIENT) then
    
    local EFFECT={} 
    function EFFECT:Init( data )
        local Laser = Material( "rainbeam/rainbow2d.vmt" )
        local tracedata = {}
        tracedata.start = data:GetOrigin() + Vector(0,0,-10)
        tracedata.endpos = data:GetOrigin() + Vector(0,0,-50000)
        local trace = util.TraceLine(tracedata)
        
        local a = data:GetOrigin()
        local b = trace.HitPos + Vector(0,0,27000)

        render.SetMaterial( Laser )
        
        render.DrawBeam( b,a, 200, -1, -1, Color( 255, 255, 255, 255 ) )
    end
    function EFFECT:Think()
    end
    function EFFECT:Render()
    end
	
    effects.Register(EFFECT,"beam") 
end

function ENT:Initialize()	

end

 
function ENT:Draw( data )
    local d = EffectData()
    d:SetOrigin( self:GetPos() ) 
    util.Effect( "beam", d )
end 

scripted_ents.Register(ENT, "effects", true)

local ENT = {}
ENT.Type   = "anim"
ENT.Base                = "base_anim"
ENT.PrintName           = "remover"
ENT.RenderGroup         = RENDERGROUP_TRANSLUCENT
/*---------------------------------------------------------
     --Explosion effects
---------------------------------------------------------*/

if (CLIENT) then
    --Explosion effects
    local EFFECT={} 
    function EFFECT:Init( dat )
        local start = dat:GetOrigin()
        local emit = ParticleEmitter( start )
        for i=1, 256 do
            local par = emit:Add("particle/smokesprites_0009", start ) --Shockwave
            if par then
                
                par:SetVelocity(Vector(math.random(-10,10),math.random(-10,10),0):GetNormal() * math.random(1500,2000))
                par:SetColor(255,255,215,225)
                par:SetDieTime(math.random(2,3))
                par:SetLifeTime(math.random(0.3,0.5))
                par:SetStartSize(60)
                par:SetEndSize(60)
                par:SetAirResistance(140)
                par:SetRollDelta(math.random(-2,2))
           
            end
            local par1 = emit:Add("effects/fire_cloud2", start ) --Smoke cloud
       if par1 then
                par1:SetVelocity(Vector(math.random(-10,10),math.random(-10,10),math.random(-3,3)):GetNormal() * math.random(100,2000))
                par1:SetColor(255,255,255,255)
                par1:SetDieTime(math.random(2,3))
                par1:SetLifeTime(math.random(0.3,0.5))
                par1:SetStartSize(100)
                par1:SetEndSize(70)
                par1:SetAirResistance(300)
                par1:SetRollDelta(math.random(-2,2))
            end

        end
        emit:Finish()
    end
    function EFFECT:Think()
    end
    function EFFECT:Render()
    end
    effects.Register(EFFECT,"poof") 
end


function ENT:Draw()
end

function ENT:Think()
    
    local tracedata3 = {}
    tracedata3.start = self:GetPos()
    tracedata3.endpos = self:GetPos() + Vector(0,0,-50000)
    tracedata3.filter = ents.GetAll()
    local trace3 = util.TraceLine(tracedata3)

    if (!SERVER) then return end
    local targets = ents.FindInBox(trace3.HitPos + Vector(-16,-16,0), self:GetPos() + Vector(16,16,0))
    for k, v in pairs( targets ) do
        if (v:GetClass() != "prop_ragdoll" && v:GetMoveType() ==6 ) then
            v:Remove()
        end
        if (v:GetClass() == "prop_ragdoll") then
            local bones = v:GetPhysicsObjectCount()
            for bone = 0, bones-1 do
                local phys = v:GetPhysicsObjectNum(bone)
                if phys:IsValid()then
                    phys:SetPos(phys:GetPos() + Vector(100,0,0))
                    phys:Wake()
                end
            end
        end 
    end
end
scripted_ents.Register(ENT, "remover", true)

local ENT = {}
ENT.Type   = "anim"
ENT.Base                = "base_anim"
ENT.PrintName           = "blastwave"
ENT.RenderGroup         = RENDERGROUP_TRANSLUCENT

AccessorFunc(ENT, "thrower", "Thrower")
AccessorFunc(ENT, "beamweapon", "Beamweapon")

if (CLIENT) then

    local EFFECT={} 
    function EFFECT:Init( data )
        local start = data:GetOrigin()
        local em = ParticleEmitter( start )
        for i=1, 1024 do
            local part = em:Add("particle/smokesprites_0009", start ) --Shockwave
            if part then
                part:SetVelocity(Vector(math.random(-10,10),math.random(-10,10),0):GetNormal() * math.random(1700,2000))
                local rad = math.abs(math.atan2(part:GetVelocity().x,part:GetVelocity().y))
                local angle = (rad/math.pi*1536)
                if(angle < 255 && angle >= 0) then
                    part:SetColor(255,angle,0)
                end
                if(angle < 511 && angle >= 255) then
                    part:SetColor(511-angle,255,0)
                end   
                if(angle < 767 && angle >= 511) then
                    part:SetColor(0,255,angle-511)
                end
                if(angle < 1023 && angle >= 767) then
                    part:SetColor(0,1023-angle,255)
                end 
                if(angle < 1279 && angle >= 1023) then
                    part:SetColor(angle-1023,0,255)
                end
                if(angle < 1535 && angle >= 1279) then
                    part:SetColor(255,0,1535-angle)
                end 
                if(angle > 1535) then
                    part:SetColor(255,0,0)
                end

                part:SetDieTime(math.random(5,6))
                part:SetLifeTime(math.random(1,2))
                if (math.Dist(0,0,part:GetVelocity().x,part:GetVelocity().y) >= 1500) then    
            part:SetStartSize((math.Dist(0,0,part:GetVelocity().x,part:GetVelocity().y)-1600)/4)
                part:SetEndSize(math.Dist(0,0,part:GetVelocity().x,part:GetVelocity().y)-1600)
                else
                    part:SetStartSize(0)
                    part:SetEndSize(0)
                end
                part:SetAirResistance(5)
                part:SetRollDelta(math.random(-2,2))
           
            end
        end  
        for i=1,512 do
            local part1 = em:Add("particle/smokesprites_0010", start ) --Main Explosion
            if part1 then                                               part1:SetVelocity(Vector(math.random(-100,100),math.random(-100,100),math.random(-3,3)):GetNormal() * math.random(100,2400))
                part1:SetColor(255,255,255)
                part1:SetDieTime(math.random(5,6))
                part1:SetLifeTime(math.random(0.3,0.5))
                part1:SetStartSize(150 - (math.Dist(0,0,part1:GetVelocity().x,part1:GetVelocity().y))/16)
                part1:SetEndSize(600 - (math.Dist(0,0,part1:GetVelocity().x,part1:GetVelocity().y))/4) 
                part1:SetAirResistance(50)
                part1:SetRollDelta(math.random(-2,2))
            end
            local part2 = em:Add("particle/smokesprites_0010", start ) --Secondary Shockwave
            if part2 then
                part2:SetVelocity(Vector(math.random(-10,10),math.random(-10,10),0):GetNormal() * 2000)
                part2:SetColor(255,255,255)
                part2:SetDieTime(math.random(5,6))
                part2:SetLifeTime(math.random(0.5,1))
                part2:SetStartSize(10)
                part2:SetEndSize(math.random(80,120)) 
                part2:SetAirResistance(math.random(30,31))
                part2:SetRollDelta(math.random(-2,2))
            end
        end 
     
        em:Finish()
    end
	
	
    function EFFECT:Think()        
    end
	
	
    function EFFECT:Render() 
    end
	
	
    effects.Register(EFFECT,"wave") 
end

function ENT:Initialize()
	
	if not self:GetThrower() then self:SetThrower(nil) end
	if not self:GetBeamweapon() then self:SetBeamweapon(nil) end
	
    if (!SERVER) then return end
    local e = EffectData()
    e:SetOrigin( self:GetPos() + Vector(0,0,64) ) 
    util.Effect( "wave", e )
	--util.Decal("Scorch", worldpos1, worldpos2)
	--util.BlastDamage(0, 0, self:GetPos(), 200, 50000)
	
    util.ScreenShake( self:GetPos(), 50, 55, 15, 5000 )
end

function ENT:Draw()
end

function ENT:Think()

if (!SERVER) then return end

local ofb_blast_r = GetConVar( "ttt_ofb_radius" ):GetFloat()
local ofb_laser_r = GetConVar( "ttt_ofb_laser_radius" ):GetFloat()

	local beam_pos = self:GetPos()
	
	plys = ents.FindByClass("player")
	npc = ents.FindByClass("npc_*")
	
	for _, ply in pairs(plys) do
		if ply:Alive() then
			local dist1 = ply:GetPos():Distance( beam_pos )
			--x y z
			if dist1 < ofb_blast_r  then
				ply:TakeDamage(150, self:GetThrower(), self:GetBeamweapon()) 
			end
			--z richtung kann vernachlässigt werden, außer darunter
			local laser_vector = ply:GetPos() - beam_pos
			local dist2 = laser_vector:Length2D()
			
			if dist2 < ofb_laser_r and ply:GetPos().z > beam_pos.z then
				ply:TakeDamage(150, self:GetThrower(), self:GetBeamweapon()) 
			end
		end
	end
	
	for _, npc in pairs(npc) do
		--if npc:Alive() then
			local dist1 = npc:GetPos():Distance( beam_pos )
			
			if dist1 < ofb_blast_r then
				npc:TakeDamage(150, self:GetThrower(), self:GetBeamweapon()) 
			end
			
			local laser_vector = npc:GetPos() - beam_pos
			
			local dist2 = laser_vector:Length2D()
			if dist2 < ofb_laser_r and npc:GetPos().z > beam_pos.z  then
				npc:TakeDamage(150, self:GetThrower(), self:GetBeamweapon()) 
			end
		--end
	end
end

scripted_ents.Register(ENT, "blastwave", true)    

/*---------------------------------------------------------
   Name: ShouldDropOnDie
   Desc: Should this weapon be dropped when its owner dies?
---------------------------------------------------------*/
function SWEP:ShouldDropOnDie()
    return false
end