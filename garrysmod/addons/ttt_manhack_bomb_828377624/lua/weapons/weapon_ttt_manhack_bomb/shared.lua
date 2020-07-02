if SERVER then
	AddCSLuaFile( "shared.lua" )
end
if CLIENT then
	SWEP.PrintName			= "Manhack bomb"
	SWEP.Slot				= 6
	SWEP.EquipMenuData = {
		type  = "Weapon",
		name  = "Manhack bomb",
		desc  = [[Works like C4 but spawns manhacks]]
	};
	SWEP.Icon = "VGUI/ttt/icon_c4"
end
SWEP.HoldType = "slam"
SWEP.Base = "weapon_tttbase"
SWEP.ViewModel  = "models/weapons/cstrike/c_c4.mdl"
SWEP.WorldModel = "models/weapons/w_c4.mdl"
SWEP.Weight = 5
SWEP.AutoSwitchTo  = true
SWEP.AutoSwitchFrom = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.ClipMax = -1
SWEP.Primary.Delay = 5.0
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.ClipMax = -1
SWEP.Secondary.Delay = 1.0
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.UseHands = true
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.AutoSpawnable = false
SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock = false
SWEP.AllowDrop = true
SWEP.IsSilent = false
SWEP.NoSights = true

--[[
SWEP.WeaponID = AMMO_C4
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 54
SWEP.DrawCrosshair	  = false
SWEP.ViewModelFlip	  = false
--]]

local throwsound = Sound( "Weapon_SLAM.SatchelThrow" )

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:BombDrop()
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	self:BombStick()
end

function SWEP:BombDrop()
	if SERVER then
		local ply = self.Owner
		if not IsValid(ply) then
			return
		end
		if self.Planted then
			return
		end
		local vsrc = ply:GetShootPos()
		local vang = ply:GetAimVector()
		local vvel = ply:GetVelocity()
		local vthrow = vvel + vang * 200
		local bomb = ents.Create("weapon_ttt_manhack_bomb_entity")
		if IsValid(bomb) then
			bomb:SetPos(vsrc + vang * 10)
			bomb:SetOwner(ply)
			-- bomb:SetThrower(ply)
			bomb:Spawn()
			bomb:PointAtEntity(ply)
			local ang = bomb:GetAngles()
			ang:RotateAroundAxis(ang:Up(), 180)
			bomb:SetAngles(ang)
			bomb.fingerprints = self.fingerprints
			bomb:PhysWake()
			local phys = bomb:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(vthrow)
			end	
			self:Remove()
			self.Planted = true
		end
		ply:SetAnimation( PLAYER_ATTACK1 )
	end
	self.Weapon:EmitSound(throwsound)
	self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
end

function SWEP:BombStick()
	if SERVER then
		local ply = self.Owner
		if not IsValid(ply) then
			return
		end
		if self.Planted then
			return
		end
		local ignore = {ply, self.Weapon}
		local spos = ply:GetShootPos()
		local epos = spos + ply:GetAimVector() * 80
		local tr = util.TraceLine({start=spos, endpos=epos, filter=ignore, mask=MASK_SOLID})
		if tr.HitWorld then
			local bomb = ents.Create("weapon_ttt_manhack_bomb_entity")
			if IsValid(bomb) then
				bomb:PointAtEntity(ply)
				local tr_ent = util.TraceEntity({start=spos, endpos=epos, filter=ignore, mask=MASK_SOLID}, bomb)
				if tr_ent.HitWorld then
					local ang = tr_ent.HitNormal:Angle()
					ang:RotateAroundAxis(ang:Right(), -90)
					ang:RotateAroundAxis(ang:Up(), 180)
					bomb:SetPos(tr_ent.HitPos)
					bomb:SetAngles(ang)
					bomb:SetOwner(ply)
					-- bomb:SetThrower(ply)
					bomb:Spawn()
					bomb.fingerprints = self.fingerprints
					local phys = bomb:GetPhysicsObject()
					if IsValid(phys) then
						phys:EnableMotion(false)
					end
					bomb.IsOnWall = true
					self:Remove()
					self.Planted = true
				end
			end
			ply:SetAnimation(PLAYER_ATTACK1)		 
		end
	end
end

function SWEP:Reload()
	return false
end

function SWEP:OnRemove()
	if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
	  RunConsoleCommand("lastinv")
	end
end
