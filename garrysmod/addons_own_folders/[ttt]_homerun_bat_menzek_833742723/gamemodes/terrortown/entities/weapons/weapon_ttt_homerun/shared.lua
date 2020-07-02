local metaPly = FindMetaTable( "Player" )
AccessorFunc( metaPly, "homerunpush", "HomeRunPush", FORCE_BOOL )
AccessorFunc( metaPly, "homerunattacker", "HomeRunAttacker" )
AccessorFunc( metaPly, "homerunbat", "HomeRunBat" )

CreateConVar( "ttt_homerun_speedscale", "1.5", FCVAR_NOTIFY + FCVAR_ARCHIVE + FCVAR_REPLICATED, "Adjust the speed a homerun player has. 1 is default, 0 none." )
homerunModifier = GetConVar( "ttt_homerun_speedscale" ):GetFloat()

if SERVER then
  AddCSLuaFile()
  util.AddNetworkString("Bat Primary Hit") 
	resource.AddWorkshop("648957314")
	
else
  SWEP.PrintName="Homerun Bat"
  SWEP.Author="Gamefreak"
  SWEP.Slot=7

  SWEP.ViewModelFOV=70
  SWEP.ViewModelFlip=false

  SWEP.Icon="VGUI/ttt/icon_homebat"
  SWEP.EquipMenuData={
    type="Melee Weapon",
    desc="Left click to hit a homerun!\nHas 2 uses.\nYou will run 50% faster with it in your Hands."
  }

  sound.Add{
    name="Bat.Swing",
    channel=CHAN_STATIC,
    volume=1,
    level=40,
    pitch=100,
    sound="weapons/iceaxe/iceaxe_swing1.wav"
  }

  sound.Add{
    name="Bat.Sound",
    channel=CHAN_STATIC,
    volume=1,
    level=65,
    pitch=100,
    sound="nessbat/gamefreak/bat_sound.wav"
  }

  sound.Add{
    name="Bat.HomeRun",
    channel=CHAN_STATIC,
    volume=1,
    level=120,
    pitch=100,
    sound="nessbat/gamefreak/homerun.wav"
  }
end

SWEP.Base="weapon_tttbase"

SWEP.ViewModel=Model("models/weapons/gamefreak/v_nessbat.mdl")
SWEP.WorldModel=Model("models/weapons/gamefreak/w_nessbat.mdl")

SWEP.HoldType="melee"

SWEP.Primary.Damage=30
SWEP.Primary.Delay=.5
SWEP.Primary.ClipSize=2
SWEP.Primary.DefaultClip=2
SWEP.Primary.Automatic=true
SWEP.Primary.Ammo="none"

SWEP.AutoSpawnable=false
SWEP.Kind=WEAPON_EQUIP2
SWEP.CanBuy={ROLE_TRAITOR,ROLE_DETECTIVE}
SWEP.LimitedStock=false

SWEP.DeployDelay=.7
SWEP.Range=150
SWEP.VelocityBoostAmount=500
SWEP.DeploySpeed = 10
SWEP.AllowDrop = true

--GLOBAL_homerunTable = {}

-- local function AddToTable(tbl, ply)
	-- if ply == nil then 
	
	-- else
		--print ("HomeRun: " .. ply:Nick() .. " added to Homeruntable")
		-- table.insert( tbl, ply )
	-- end
-- end

-- local function RemoveFromTable(tbl, ply)
	-- if ply == nil then  
	-- else
		-- for i=1, table.Count(tbl) do
			-- if tbl[i] == ply then
				-- table.remove(tbl, i)
				--print("HomeRun: " .. ply:Nick() .. " removed from Homeruntable")
			-- end
		-- end
	-- end
-- end

function SWEP:Deploy()
  self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
  self:SetNextPrimaryFire(CurTime()+self.DeployDelay)
  --AddToTable( GLOBAL_homerunTable, self.Owner )
  return self.BaseClass.Deploy(self)
end

function SWEP:OnRemove()
  --RemoveFromTable( GLOBAL_homerunTable, self.Owner )
  if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
    RunConsoleCommand("lastinv")
  end
end

function SWEP:PreDrop()
	--RemoveFromTable( GLOBAL_homerunTable, self.Owner )
   return self.BaseClass.PreDrop(self)
end

function SWEP:Holster()
	--RemoveFromTable( GLOBAL_homerunTable, self.Owner )
   return true
end

function SWEP:OnDrop()

end

function SWEP:PrimaryAttack()
  local ply,wep=self.Owner,self.Weapon
  wep:SetNextPrimaryFire(CurTime()+self.Primary.Delay)

  if !IsValid(ply) or wep:Clip1()<=0 then return end

  ply:SetAnimation(PLAYER_ATTACK1)
  wep:SendWeaponAnim(ACT_VM_MISSCENTER)
  wep:EmitSound("Bat.Swing")

  local av,spos,tr=ply:GetAimVector(),ply:GetShootPos()
  local epos=spos+av*self.Range
  local kmins = Vector(1,1,1) * -10
  local kmaxs = Vector(1,1,1) * 10

  self.Owner:LagCompensation( true )
	
  local tr = util.TraceHull({start=spos, endpos=epos, filter=ply, mask=MASK_SHOT_HULL, mins=kmins, maxs=kmaxs})

  -- Hull might hit environment stuff that line does not hit
  if not IsValid(tr.Entity) then
    tr = util.TraceLine({start=spos, endpos=epos, filter=ply, mask=MASK_SHOT_HULL})
  end

  self.Owner:LagCompensation( false )

  local ent=tr.Entity

  if !tr.Hit or !(tr.HitWorld or IsValid(ent)) then return end

  if ent:GetClass()=="prop_ragdoll" then
    ply:FireBullets{Src=spos,Dir=av,Tracer=0,Damage=0}
  end

  if CLIENT then return end

  net.Start("Bat Primary Hit")
  net.WriteTable(tr)
  net.WriteEntity(ply)
  net.WriteEntity(wep)
  net.Broadcast()

  local isply=ent:IsPlayer()

  if isply then
    

    wep:SetNextPrimaryFire(CurTime()+wep.Primary.Delay*3)

    if ent:GetMoveType()==MOVETYPE_LADDER then ent:SetMoveType(MOVETYPE_WALK) end

    local boost=wep.VelocityBoostAmount
    ent:SetVelocity(ply:GetVelocity()+Vector(av.x,av.y,math.max(1,av.z+.35))*math.Rand(boost*.8,boost*1.2)*2)
  elseif ent:GetClass()=="prop_physics" then
    local phys=ent:GetPhysicsObject()
    if IsValid(phys) then
      local boost=wep.VelocityBoostAmount
      phys:ApplyForceOffset(ply:GetVelocity()+Vector(av.x,av.y,math.max(1,av.z+.35))*math.Rand(boost*4,boost*8),tr.HitPos)
    end
  end

  do
    local dmg=DamageInfo()
    dmg:SetDamage(isply and self.Primary.Damage or self.Primary.Damage*.5)
    dmg:SetAttacker(ply)
    dmg:SetInflictor(wep)
    dmg:SetDamageForce(av*2000)
    dmg:SetDamagePosition(ply:GetPos())
    dmg:SetDamageType(DMG_CLUB)
    ent:DispatchTraceAttack(dmg,tr)
  end
  
	ent:SetHomeRunPush( true )
	ent:SetHomeRunAttacker( self.Owner )
	ent:SetHomeRunBat( self )
  if wep:Clip1()<=0 then
    timer.Simple(0.49,function() if IsValid(self) then self:Remove() RunConsoleCommand("lastinv") end end)
  end
  self:TakePrimaryAmmo(1)
end



if CLIENT then
  net.Receive("Bat Primary Hit",function()
      local tr,ply,wep=net.ReadTable(),net.ReadEntity(),net.ReadEntity()
      local ent=tr.Entity

      local edata=EffectData()
      edata:SetStart(tr.StartPos)
      edata:SetOrigin(tr.HitPos)
      edata:SetNormal(tr.Normal)
      edata:SetSurfaceProp(tr.SurfaceProps)
      edata:SetHitBox(tr.HitBox)
      edata:SetEntity(ent)

      local isply=ent:IsPlayer()

      if isply or ent:GetClass()=="prop_ragdoll" then
        if isply then
          wep:EmitSound("Bat.Sound")
          timer.Simple(.48,function()
              if IsValid(ent) and IsValid(wep) then
                if ent:Alive() then
                  wep:EmitSound("Bat.HomeRun")
                end
              end
            end)
        end
        util.Effect("BloodImpact", edata)
      else
        util.Effect("Impact",edata)
      end
    end)
end	

-- hook.Add("TTTPrepareRound","HomerunClearGlobalTable", function()
	--print ( "Homerun: Table cleared")
	-- GLOBAL_homerunTable = {}
-- end)

local function HomeRunGround( player, inWater, onFloater, speed )
	local tname = Format("SuperPush_%d_%d", player:EntIndex(), math.ceil(CurTime()))
	timer.Create( tname, 1, 1, function() 
		player:SetHomeRunPush(false)
	end)
	
end

local function HomeRunDamage( target, dmg )
	if target:IsPlayer() then
		if dmg:IsFallDamage() then
			--if IsValid( target:GetSuperPush() ) then
				if target:GetHomeRunPush() == true then
					dmg:SetAttacker( target:GetHomeRunAttacker() )
					hrbent = ents.Create("weapon_ttt_homerun")
					dmg:SetInflictor( hrbent )
					hrbent:Remove()
					--print( dmg:GetInflictor():GetClass() )
				end
			--end
		end
	end
end

hook.Add("EntityTakeDamage","HomeRunDamage", HomeRunDamage)
hook.Add("OnPlayerHitGround","HomeRunGround", HomeRunGround)

hook.Add("TTTPlayerSpeedModifier", "HomeRunSpeed", function(ply, _, _, refTbl) 
  if not IsValid(ply) or not ply:Alive() then return end
  if not IsValid(ply:GetActiveWeapon()) then return end
  if not (ply:GetActiveWeapon():GetClass() == "weapon_ttt_homerun") then return end
		refTbl[1] = refTbl[1] * homerunModifier  * (ply.speedrun_mul or 1)
end)