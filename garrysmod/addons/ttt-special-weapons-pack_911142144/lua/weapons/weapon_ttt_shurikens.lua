SWEP.HoldType = "knife"
SWEP.PrintName                  = "Shuriken"    
 
if ( CLIENT ) then
		SWEP.Slot                               = 6
		SWEP.ViewModelFOV               = 86
		SWEP.ViewModelFlip      = false
else
	AddCSLuaFile()
	resource.AddFile("materials/vgui/ttt/icon_cyb_shuriken.png")
	resource.AddFile("models/jaanus/v_shuriken.mdl")
	resource.AddFile("models/jaanus/w_shuriken.mdl")
	resource.AddFile("models/jaanus/w_shuriken.mdl")
	resource.AddFile("models/jaanus/shuriken_small.mdl")
	resource.AddFile("weapons/shuriken/hit1.wav")
	resource.AddFile("weapons/shuriken/hit2.wav")
	resource.AddFile("weapons/shuriken/hit3.wav")
	resource.AddFile("weapons/shuriken/throw1.wav")
	resource.AddFile("weapons/shuriken/throw2.wav")
	resource.AddFile("weapons/shuriken/throw3.wav")
	resource.AddFile("weapons/shuriken/throw4.wav")
	resource.AddFile("materials/jaanus/brass.vmt")
	resource.AddFile("materials/jaanus/shuriken.vmt")
end
 
SWEP.Base = "weapon_tttbase"
SWEP.HeadshotMultiplier = 10
 
SWEP.Spawnable      = true
SWEP.AdminSpawnable  = true
 
 
 
SWEP.ViewModel    = Model("models/jaanus/v_shuriken.mdl")
SWEP.WorldModel   = Model("models/jaanus/w_shuriken.mdl")
 
 
 
SWEP.Kind = WEAPON_EQUIP
 
SWEP.Icon = "vgui/ttt/icon_cyb_shuriken.png"
 
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = false
SWEP.WeaponID = AMMO_SHURIKEN
 
SWEP.EquipMenuData = {
   type = "Silent Weapon",
   desc = "Sharp ninja star blades."
};
 
SWEP.IsSilent = true
SWEP.NoSights = true
SWEP.CanUseKey = true
 
 
SWEP.Primary.Delay                      = 0.9   --In seconds
SWEP.Primary.Recoil                     = 0             --Gun Kick
SWEP.Primary.Damage                     = 65    --Damage per Bullet
SWEP.Primary.NumShots           = 1             --Number of shots per one fire
SWEP.Primary.Cone                       = 0     --Bullet Spread
SWEP.Primary.ClipSize           = 1     --Use "-1 if there are no clips"
SWEP.Primary.ClipMax            = 1     --Use "-1 if there are no clips"
SWEP.Primary.DefaultClip        = 1     --Number of shots in next clip
SWEP.Primary.Automatic          = false --Pistol fire (false) or SMG fire (true)
SWEP.Primary.Ammo               = "Xbowbolt"    --Ammo Type
 
 
 
SWEP.Secondary.Delay            = 0.9
SWEP.Secondary.Recoil           = 0
SWEP.Secondary.Damage           = 65
SWEP.Secondary.NumShots         = 1
SWEP.Secondary.Cone                     = 0
SWEP.Secondary.ClipSize         = 1
SWEP.Secondary.DefaultClip      = 1
SWEP.Secondary.Automatic        = false
SWEP.Secondary.Ammo         = "none"
 
SWEP.TimesUsed = 0
 
 
if ( CLIENT ) then
		function SWEP:GetViewModelPosition( pos, ang )
				pos = pos + ang:Forward()*4
				return pos, ang
		end
end
 
function SWEP:WasBought(ply)
		ply:GiveAmmo(2, "Xbowbolt")
end
 
function SWEP:Initialize()
		self:SetWeaponHoldType( self.HoldType )
		util.PrecacheSound("weapons/shuriken/throw1.wav")
		util.PrecacheSound("weapons/shuriken/throw2.wav")
		util.PrecacheSound("weapons/shuriken/throw3.wav")
		util.PrecacheSound("weapons/shuriken/throw4.wav")
end
 
function SWEP:PrimaryAttack()
		if (self:CanPrimaryAttack()) then
				self.Weapon:EmitSound("weapons/shuriken/throw"..tostring( math.random( 1, 4 ) )..".wav")
				self.Weapon:SetNextPrimaryFire(CurTime() + 0.8)
				self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
				if SERVER then
						local shuriken = ents.Create("ent_shuriken")
						shuriken:SetAngles(self.Owner:EyeAngles())-- Angle(0,90,0))
						shuriken:SetPos(self.Owner:GetShootPos())
						shuriken:SetOwner(self.Owner)
						shuriken:SetPhysicsAttacker(self.Owner)
						shuriken:Spawn()
						shuriken:Activate()
						local phys = shuriken:GetPhysicsObject()
						phys:SetVelocity(self.Owner:GetAimVector()*7000)
						phys:AddAngleVelocity(Vector(0,0,90))
				end
				self:TakePrimaryAmmo(1)
				self:Reload()
		end
		if SERVER then
			if self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) == 0 then
				self.Owner:StripWeapon("weapon_ttt_shurikens")
			end
		end
end
 
function SWEP:UseOverride(activator)
		if ( activator:IsPlayer() ) then
				if activator:GetWeapon("weapon_ttt_shurikens") then
						activator:GiveAmmo(1, "XbowBolt")
				else
						activator:Give("weapon_ttt_shurikens")
				end
				self:Remove()
		end
end