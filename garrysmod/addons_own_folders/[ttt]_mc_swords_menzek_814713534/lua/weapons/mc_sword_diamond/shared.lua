AddCSLuaFile( "shared.lua" )

SWEP.Contact 		= "My Steam"
SWEP.Author			= "Shotz/LucyLu"
SWEP.Instructions	= "Left Click to attack"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
SWEP.AutoSpawnable = true

SWEP.ViewModel			= "models/weapons/v_diamond_mc_sword.mdl"
SWEP.WorldModel			= "models/weapons/w_diamond_mc_sword.mdl"
SWEP.HoldType = "melee"
SWEP.Kind = WEAPON_PISTOL

--SWEP.FiresUnderwater = true
SWEP.Primary.Damage         = 40
SWEP.Base                    = "weapon_tttbase" -- vorher nur "crowbar"
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay = 0.35


SWEP.Weight				= 5
--SWEP.AutoSwitchTo		= false
--SWEP.AutoSwitchFrom		= false

SWEP.Category			= "Minecraft"
SWEP.Slot				= 1
SWEP.SlotPos			= 1
--SWEP.DrawAmmo			= true
--SWEP.DrawCrosshair		= true
SWEP.IsSilent			= true
SWEP.AllowDrop			= true

CreateConVar( "ttt_diamondsword_speedscale", "1.2", FCVAR_NOTIFY + FCVAR_ARCHIVE + FCVAR_REPLICATED, "Adjust the speed a DiamondSword has. 1 is default, 0 none." )
diamondSwordModifier = GetConVar( "ttt_diamondsword_speedscale" ):GetFloat()

-- GLOBAL_diamondSwordTable = {}

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
				-- print("HomeRun: " .. ply:Nick() .. " removed from Homeruntable")
			-- end
		-- end
	-- end
-- end

if CLIENT then
  SWEP.PrintName			= "Diamond Sword"

   SWEP.DrawCrosshair        = false
   SWEP.ViewModelFlip        = false
   SWEP.ViewModelFOV         = 70
end


local sound_single = Sound("Weapon_Crowbar.Single")
local sound_open = Sound("DoorHandles.Unlocked3")

if SERVER then
   CreateConVar("ttt_crowbar_unlocks", "1", FCVAR_ARCHIVE)
   CreateConVar("ttt_crowbar_pushforce", "395", FCVAR_NOTIFY)
end

-- only open things that have a name (and are therefore likely to be meant to
-- open) and are the right class. Opening behaviour also differs per class, so
-- return one of the OPEN_ values

function SWEP:Deploy()
  -- AddToTable( GLOBAL_diamondSwordTable, self.Owner )
end

function SWEP:OnRemove()
   -- RemoveFromTable( GLOBAL_diamondSwordTable, self.Owner )
end

function SWEP:PreDrop()
	-- RemoveFromTable( GLOBAL_diamondSwordTable, self.Owner )
end
 
 function SWEP:Holster()
	-- RemoveFromTable( GLOBAL_diamondSwordTable, self.Owner )
   --return true
end
local function OpenableEnt(ent)
   local cls = ent:GetClass()
   if ent:GetName() == "" then
      return OPEN_NO
   elseif cls == "prop_door_rotating" then
      return OPEN_ROT
   elseif cls == "func_door" or cls == "func_door_rotating" then
      return OPEN_DOOR
   elseif cls == "func_button" then
      return OPEN_BUT
   elseif cls == "func_movelinear" then
      return OPEN_NOTOGGLE
   else
      return OPEN_NO
   end
end


local function CrowbarCanUnlock(t)
   return not GAMEMODE.crowbar_unlocks or GAMEMODE.crowbar_unlocks[t]
end

-- will open door AND return what it did
function SWEP:OpenEnt(hitEnt)
   -- Get ready for some prototype-quality code, all ye who read this
   if SERVER and GetConVar("ttt_crowbar_unlocks"):GetBool() then
      local openable = OpenableEnt(hitEnt)

      if openable == OPEN_DOOR or openable == OPEN_ROT then
         local unlock = CrowbarCanUnlock(openable)
         if unlock then
            hitEnt:Fire("Unlock", nil, 0)
         end

         if unlock or hitEnt:HasSpawnFlags(256) then
            if openable == OPEN_ROT then
               hitEnt:Fire("OpenAwayFrom", self.Owner, 0)
            end
            hitEnt:Fire("Toggle", nil, 0)
         else
            return OPEN_NO
         end
      elseif openable == OPEN_BUT then
         if CrowbarCanUnlock(openable) then
            hitEnt:Fire("Unlock", nil, 0)
            hitEnt:Fire("Press", nil, 0)
         else
            return OPEN_NO
         end
      elseif openable == OPEN_NOTOGGLE then
         if CrowbarCanUnlock(openable) then
            hitEnt:Fire("Open", nil, 0)
         else
            return OPEN_NO
         end
      end
      return openable
   else
      return OPEN_NO
   end
end


function SWEP:PrimaryAttack()
 if self.Weapon:Clip1() == 0 then return end
 
   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:TakePrimaryAmmo( 1 )
   if not IsValid(self.Owner) then return end

   if self.Owner.LagCompensation then -- for some reason not always true
      self.Owner:LagCompensation(true)
   end

   local spos = self.Owner:GetShootPos()
   local sdest = spos + (self.Owner:GetAimVector() * 70)

   local tr_main = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL})
   local hitEnt = tr_main.Entity

   self.Weapon:EmitSound(sound_single)

   if IsValid(hitEnt) or tr_main.HitWorld then
      self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )

      if not (CLIENT and (not IsFirstTimePredicted())) then
         local edata = EffectData()
         edata:SetStart(spos)
         edata:SetOrigin(tr_main.HitPos)
         edata:SetNormal(tr_main.Normal)
         edata:SetSurfaceProp(tr_main.SurfaceProps)
         edata:SetHitBox(tr_main.HitBox)
         --edata:SetDamageType(DMG_CLUB)
         edata:SetEntity(hitEnt)

         if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
            util.Effect("BloodImpact", edata)

            -- does not work on players rah
            --util.Decal("Blood", tr_main.HitPos + tr_main.HitNormal, tr_main.HitPos - tr_main.HitNormal)

            -- do a bullet just to make blood decals work sanely
            -- need to disable lagcomp because firebullets does its own
            self.Owner:LagCompensation(false)
            self.Owner:FireBullets({Num=1, Src=spos, Dir=self.Owner:GetAimVector(), Spread=Vector(0,0,0), Tracer=0, Force=1, Damage=0})
         else
            util.Effect("Impact", edata)
         end
      end
   else
      self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
   end


   if CLIENT then
      -- used to be some shit here
   else -- SERVER

      -- Do another trace that sees nodraw stuff like func_button
      local tr_all = nil
      tr_all = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner})
      
      self.Owner:SetAnimation( PLAYER_ATTACK1 )

      if hitEnt and hitEnt:IsValid() then
         if self:OpenEnt(hitEnt) == OPEN_NO and tr_all.Entity and tr_all.Entity:IsValid() then
            -- See if there's a nodraw thing we should open
            self:OpenEnt(tr_all.Entity)
         end

         local dmg = DamageInfo()
         dmg:SetDamage(self.Primary.Damage)
         dmg:SetAttacker(self.Owner)
         dmg:SetInflictor(self.Weapon)
         dmg:SetDamageForce(self.Owner:GetAimVector() * 1500)
         dmg:SetDamagePosition(self.Owner:GetPos())
         dmg:SetDamageType(DMG_CLUB)

         hitEnt:DispatchTraceAttack(dmg, spos + (self.Owner:GetAimVector() * 3), sdest)

--         self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )         

--         self.Owner:TraceHullAttack(spos, sdest, Vector(-16,-16,-16), Vector(16,16,16), 30, DMG_CLUB, 11, true)
--         self.Owner:FireBullets({Num=1, Src=spos, Dir=self.Owner:GetAimVector(), Spread=Vector(0,0,0), Tracer=0, Force=1, Damage=20})
      
      else
--         if tr_main.HitWorld then
--            self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
--         else
--            self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
--         end

         -- See if our nodraw trace got the goods
         if tr_all.Entity and tr_all.Entity:IsValid() then
            self:OpenEnt(tr_all.Entity)
         end
      end
   end

   if self.Owner.LagCompensation then
      self.Owner:LagCompensation(false)
   end
end

function SWEP:SecondaryAttack()
   
end


function SWEP:OnDrop()

end

hook.Add("TTTPrepareRound","DiamondSwordClearGlobalTable", function()
	--print ( "Homerun: Table cleared")
	-- GLOBAL_diamondSwordTable = {}
end)

hook.Add("TTTPlayerSpeedModifier", "MCSWORDSpeed", function(ply, _, _, refTbl)  
  if not IsValid(ply) or not ply:Alive() then return end
  if not IsValid(ply:GetActiveWeapon()) then return end
  if not (ply:GetActiveWeapon():GetClass() == "mc_sword_diamond") then return end
		refTbl[1] = refTbl[1] * diamondSwordModifier  * (ply.speedrun_mul or 1)
end)