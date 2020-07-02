
AddCSLuaFile( "shared.lua" )

SWEP.Contact 		= "My Steam"
SWEP.Author			= "Shotz/LucyLu"
SWEP.Instructions	= "Left Click to attack"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
SWEP.ViewModelFOV 	= 70
SWEP.ViewModel			= "models/weapons/v_gold_mc_sword.mdl"
SWEP.WorldModel			= "models/weapons/w_gold_mc_sword.mdl"
SWEP.HoldType = "crowbar"


SWEP.FiresUnderwater = true
SWEP.Primary.Damage         = 50
SWEP.base					= "crowbar"
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay = 0.5


SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Category			= "Minecraft"
SWEP.PrintName			= "Golden Minecraft Sword"
SWEP.Slot				= 1
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true



function SWEP:SecondaryAttack()
	
end

function SWEP:ShouldDropOnDie()
	return false
end
-- function SWEP:Reload() --To do when reloading
-- end 
 
function SWEP:Think() -- Called every frame
end

function SWEP:Inizialize()
self:SetHoldType( "melee" )
end

function SWEP:PrimaryAttack()

   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )




   local spos = self.Owner:GetShootPos()
   local sdest = spos + (self.Owner:GetAimVector() * 70)

   local kmins = Vector(1,1,1) * -10
   local kmaxs = Vector(1,1,1) * 10

   local tr = util.TraceHull({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL, mins=kmins, maxs=kmaxs})

   -- Hull might hit environment stuff that line does not hit
   if not IsValid(tr.Entity) then
      tr = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL})
   end

   local hitEnt = tr.Entity

   -- effects
   if IsValid(hitEnt) then
      self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
	  

      local edata = EffectData()
      edata:SetStart(spos)
      edata:SetOrigin(tr.HitPos)
      edata:SetNormal(tr.Normal)
      edata:SetEntity(hitEnt)

      if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
         util.Effect("BloodImpact", edata)
      end
   else
      self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
   end

   if SERVER then
      self.Owner:SetAnimation( PLAYER_ATTACK1 )
   end
self.Weapon:SetNextPrimaryFire(CurTime() + .43)

local trace = self.Owner:GetEyeTrace()

if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 75 then

	bullet = {}
	bullet.Num    = 1
	bullet.Src    = self.Owner:GetShootPos()
	bullet.Dir    = self.Owner:GetAimVector()
	bullet.Spread = Vector(0, 0, 0)
	bullet.Tracer = 0
	bullet.Force  = 3
	bullet.Damage = 60
		self.Owner:DoAttackEvent()
self.Owner:FireBullets(bullet) 
self.Weapon:EmitSound("Weapon_Crowbar.Melee_Hit")
else
self.Weapon:EmitSound("Zombie.AttackMiss")

	self.Owner:DoAttackEvent()
end

end
 
function SWEP:Deploy()
return true;
end

function SWEP:Holster()
return true;
end