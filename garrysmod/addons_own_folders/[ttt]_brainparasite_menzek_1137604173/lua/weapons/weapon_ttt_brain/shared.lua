
if SERVER then
   AddCSLuaFile( "shared.lua" )
   resource.AddFile("materials/vgui/ttt/icon_brainp.png")
end

SWEP.HoldType			= "pistol"

   SWEP.PrintName = "Brain Parasite"
if CLIENT then
   SWEP.Slot = 6

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "1 dart.\n\nCauses victim to shoot randomly\nthen die from a heart attack\n20 seconds later."
   };

   SWEP.Icon = "vgui/ttt/icon_brainp.png"
end

SWEP.Cat = "Dart Guns"

SWEP.Base = "weapon_tttbase"
SWEP.Primary.Recoil	= 1.35
SWEP.Primary.Damage = 28
SWEP.Primary.Delay = 0.38
SWEP.Primary.Cone = 0.001
SWEP.Primary.ClipSize = 2
SWEP.Primary.Automatic = false
SWEP.Primary.DefaultClip = 2
SWEP.Primary.ClipMax = 2
SWEP.Primary.Ammo = "Dart"

SWEP.Kind = WEAPON_EQUIP1
SWEP.CanBuy = {ROLE_TRAITOR} -- only traitors can buy
SWEP.WeaponID = AMMO_DART
SWEP.LimitedStock = true

SWEP.AmmoEnt = "item_ammo_dart_ttt"

SWEP.IsSilent = true

SWEP.ViewModel			= "models/weapons/v_pist_usp.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_usp_silencer.mdl"

SWEP.Primary.Sound = Sound( "weapons/usp/usp1.wav" )
SWEP.Primary.SoundLevel = 50
SWEP.Primary.Delay = 1

SWEP.IronSightsPos = Vector( 4.48, -4.34, 2.75)
SWEP.IronSightsAng = Vector(-0.5, 0, 0)

SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK_SILENCED
SWEP.ReloadAnim = ACT_VM_RELOAD_SILENCED

SWEP.MuzzleEffect			= "rg_muzzle_silenced" -- This is an extra muzzleflash effect
-- Available muzzle effects: rg_muzzle_grenade, rg_muzzle_highcal, rg_muzzle_hmg, rg_muzzle_pistol, rg_muzzle_rifle, rg_muzzle_silenced, none

SWEP.ShellEffect			= "none" -- This is a shell ejection effect
-- Available shell eject effects: rg_shelleject, rg_shelleject_rifle, rg_shelleject_shotgun, none

SWEP.MissedShots = 0

local str = 'ambient/voices/cough'
local sou = {Sound(str..'1'..'.wav'),Sound(str..'2'..'.wav'),Sound(str..'3'..'.wav'),Sound(str..'4'..'.wav')}

function SWEP:Deploy()
   self.Weapon:SendWeaponAnim(ACT_VM_DRAW_SILENCED)
   return true
end

local function DoPoison(attacker,ply)
	if IsValid(ply) and ply:Alive() and ply.infected and IsValid(attacker) then
		local pos = ply:GetPos()
		local ang = ply:GetAngles()
		local dmg = DamageInfo()
		dmg:SetDamage(420)
		dmg:SetAttacker(attacker)
		local ent = ents.Create('weapon_ttt_brain')
		dmg:SetInflictor(ent)
		dmg:SetDamageType(DMG_GENERIC)
		--ply.noRag = true
		ply:TakeDamageInfo(dmg)
		ent:Remove()
	end
end

function SWEP:PrimaryAttack(worldsnd)
	if not self:CanPrimaryAttack() then return end
	if SERVER and self.Owner:GetNWBool('disguised',false) == true and string.len(self.Owner:GetNWString('disgas','')) > 0 then self.Owner:ConCommand('ttt_set_disguise 0') end
	if SERVER and _rdm then
		local stid = self.Owner:SteamID()
		if not _rdm.shotsFired[stid] then _rdm.shotsFired[stid] = {} end
		table.insert(_rdm.shotsFired[stid],CurTime())
	end
	if SERVER and ShootLog then ShootLog(Format("WEAPON:\t %s [%s] shot a %s", self.Owner:Nick(), self.Owner:GetRoleString(), self.Weapon:GetClass())) end
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:TakePrimaryAmmo(1)
   --sound.Play(self.Primary.Sound, self.Weapon:GetPos(), self.Primary.SoundLevel)
   self.Weapon:SendWeaponAnim(ACT_VM_IDLE)

   local cone = self.Primary.Cone or 0.1
   local num = 1

   local bullet = {}
   bullet.Num    = num
   bullet.Src    = self.Owner:GetShootPos()
   bullet.Dir    = self.Owner:GetAimVector()
   bullet.Spread = Vector( cone, cone, 0 )
   bullet.Tracer = 1
   bullet.Force  = 0
   bullet.Damage = 1
   bullet.TracerName = "Tracer"

   local owner = self.Owner
   bullet.Callback = function(att, tr, dmginfo)
		local ply = tr.Entity
		if SERVER and IsValid(ply) and (ply:IsPlayer() or ply:IsNPC()) then
			ply.infected = true
			self:TakePrimaryAmmo( 1 )
			ply:SetNWBool('infected',true)
			local attacker = self.Owner
			if ply:IsNPC() then timer.Simple(20,function() if IsValid(ply) then ply:Remove() end end)
			else
				timer.Simple(20,function() DoPoison(attacker,ply) end)
				timer.Create(self:EntIndex().."Poison",0.5,19,function()
					if IsValid(ply) and ply.infected and ply:Alive() then
						ply:ConCommand("+attack")
						timer.Simple(0.25,function() if IsValid(ply) then ply:ConCommand("-attack") end end)
					end
				end)
				DamageLog(Format("POISON:\t %s [%s] brain parasited %s [%s]", self.Owner:Nick(), self.Owner:GetRoleString(), ply:Nick(), ply:GetRoleString()))
			end
		elseif SERVER and IsValid( ply ) and ply:GetClass() == "ttt_health_station" then
			--hier ist ply eigentlich die station
			if ply:GetNWBool( "IsPoisoned", false ) == false then
				local attacker = self.Owner
				ply:SetNWBool( "IsPoisoned", true )
				ply:SetNWEntity( "PoisonAttacker", attacker )
				self:TakePrimaryAmmo( 1 )
			end
		end
		
	end
	self.Owner:FireBullets( bullet )
	local owner = self.Owner
    if not IsValid(owner) or owner:IsNPC() or (not owner.ViewPunch) then return end
    owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
end
-- We were bought as special equipment, and we have an extra to give
function SWEP:WasBought(buyer)
   if IsValid(buyer) then -- probably already self.Owner
      buyer:GiveAmmo( 2, "Dart" )
   end
end
