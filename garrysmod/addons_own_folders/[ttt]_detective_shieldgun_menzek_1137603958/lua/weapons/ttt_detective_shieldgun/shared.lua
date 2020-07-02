if SERVER then
   AddCSLuaFile( "shared.lua" )
end

if CLIENT then
   SWEP.PrintName		= "Improvised Shield Gun"
   SWEP.Slot      = 6 -- add 1 to get the slot number key

   SWEP.ViewModelFlip = false
end

SWEP.Base = "weapon_tttbase"

SWEP.HoldType		= "ar2"

SWEP.Primary.Ammo		= "slam"
SWEP.Primary.ClipSize	= 1
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic	= false
SWEP.Primary.Damage		= 3
SWEP.Primary.Tracer		= 1

SWEP.Secondary.Automatic	= true


SWEP.Category		= "XP_Static's SWEPs"
SWEP.SlotPos		= 1
SWEP.DrawAmmo		= false			
SWEP.DrawCrosshair		= true	
SWEP.ViewModel		= "models/weapons/c_shotgun.mdl"	
SWEP.WorldModel		= "models/weapons/w_shotgun.mdl"	
SWEP.UseHands		= true

SWEP.Weight		= 1			
SWEP.AutoSwitchTo		= true			
SWEP.Spawnable		= true
SWEP.AdminSpawnable = true	

--- TTT config values

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_EQUIP1

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2, then this gun can
-- be spawned as a random weapon. Of course this AK is special equipment so it won't,
-- but for the sake of example this is explicitly set to false anyway.
SWEP.AutoSpawnable = false

-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.
SWEP.CanBuy = { ROLE_DETECTIVE }

-- InLoadoutFor is a table of ROLE_* entries that specifies which roles should
-- receive this weapon as soon as the round starts. In this case, none.
SWEP.InLoadoutFor = nil

-- If LimitedStock is true, you can only buy one per round.
SWEP.LimitedStock = false

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = false

-- Equipment menu information is only needed on the client
if CLIENT then
   -- Path to the icon material
   SWEP.Icon = "VGUI/ttt/doctor_jew_shieldgun"

   -- Text shown in the equip menu
   SWEP.EquipMenuData = {
      type = "Weapon",
      desc = "A Detective's shield gun."
   };
end

-- Tell the server that it should download our icon to clients.
if SERVER then
   -- It's important to give your icon a unique name. GMod does NOT check for
   -- file differences, it only looks at the name. This means that if you have
   -- an icon_ak47, and another server also has one, then players might see the
   -- other server's dumb icon. Avoid this by using a unique name.
   resource.AddFile("materials/VGUI/ttt/icon_myserver_ak47.vmt")
end


SWEP.Author		= "Doctor Jew"		
SWEP.Contact		= "mciluziionz@gmail.com"		
SWEP.Purpose		= "Shielded attacks"	
SWEP.Instructions	= "Left click to charge an attack, right click to protect yourself"	

function SWEP:PrimaryAttack()
if !CLIENT then

timer.Create("powercount", 0.045, 25, 
	function()self.Owner:GiveAmmo(1, "slam", true)
end)
self:EmitSound("weapons/shotgun/shotgun_cock.wav", 50, 100, 1 , CHAN_SWEP)
self:SendWeaponAnim(ACT_SHOTGUN_PUMP)

end
end

function SWEP:Think()
if !CLIENT then




local amocnt = self.Owner:GetAmmoCount("slam")


	if self.Owner:KeyReleased(IN_ATTACK) then timer.Simple(0.1, function()self.Owner:RemoveAmmo(25, "slam")
	timer.Destroy("powercount")
	end)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)	
	self.Owner:ViewPunch(Angle(-math.random(-amocnt/2, amocnt/2), math.random(-amocnt/2, amocnt/2), math.random(-amocnt/2, amocnt/2)))
	
		local bullet = {}
		bullet.Num = amocnt	
		bullet.Src = self.Owner:GetShootPos()
		bullet.Dir = self.Owner:GetAimVector()
		bullet.Spread = Vector(amocnt, amocnt, amocnt)/150
		bullet.Tracer = self.Primary.Tracer		
		bullet.Force = amocnt
		bullet.Damage = self.Primary.Damage if amocnt ==25 then bullet.Damage = 4.5 end
		bullet.AmmoType = self.Primary.Ammo		
		
		bullet.Callback = function(att, tr, dmginfo)
			--print ("penis")
			dmginfo:SetDamageType(2)	
		end
		
		self.Owner:FireBullets( bullet )
	
	end
		if self.Owner:GetAmmoCount("slam") >25 then self.Owner:RemoveAmmo(1, "slam")
	end
	end
		if self.Owner:KeyReleased(IN_ATTACK) then 
		if self.Owner:GetAmmoCount("slam") <5 then self:EmitSound("Weapon_Pistol.Single", 50, 100, 1 , CHAN_SWEP)
		else self:EmitSound("Weapon_Shotgun.Double", 50, 100, 1 , CHAN_SWEP) end end
end

function SWEP:Reload()

end

function SWEP:SecondaryAttack()
if !CLIENT then
	local ent = ents.Create("prop_physics")
	ent:SetModel("models/hunter/tubes/tube1x1x2c.mdl")
	ent:SetPos(self.Owner:EyePos()+Vector(0, 0, 35))
	ent:SetAngles(self.Owner:EyeAngles()+Angle(160, 0, 0))
	ent:Spawn()
	ent:SetMaterial("models/effects/splodearc_sheet")
	ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	ent:SetMoveType(0) 

	
	undo.Create ("Shield")
	undo.AddEntity (ent)
	undo.Finish()
	timer.Simple(0.025, function()ent:Remove("Shield") end)

	timer.Destroy("powercount") 
	self.Owner:RemoveAmmo(25, "slam")
end

end

function SWEP:Initialize()
self:SetWeaponHoldType(self.HoldType)
end


function SWEP:Holster()
	self.Owner:RemoveAmmo(25, "slam")
	timer.Destroy("powercount")
return true
end