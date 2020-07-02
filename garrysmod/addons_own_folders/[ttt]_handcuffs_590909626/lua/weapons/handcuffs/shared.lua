
if SERVER then

	AddCSLuaFile( "shared.lua" )
	
	resource.AddFile("materials/katharsmodels/handcuffs/handcuffs_body.vmt")
	resource.AddFile("materials/katharsmodels/handcuffs/handcuffs_body.vtf")
	resource.AddFile("materials/katharsmodels/handcuffs/handcuffs_claw.vmt")
	resource.AddFile("materials/katharsmodels/handcuffs/handcuffs_claw.vtf")
	resource.AddFile("models/katharsmodels/handcuffs/handcuffs-1.mdl")
	resource.AddFile("models/katharsmodels/handcuffs/handcuffs-3.mdl")
	resource.AddFile("materials/katharsmodels/handcuffs/handcuffs_extras.vmt")
	resource.AddFile("materials/katharsmodels/handcuffs/handcuffs_extras.vtf")
	resource.AddFile("materials/vgui/ttt/icon_handscuffs.png")

end


if CLIENT then
   SWEP.PrintName = "Handcuffs"
   SWEP.Slot = 7

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "To cuff someone ( Can disable Myatrophie )."
   };

   SWEP.Icon = "vgui/ttt/icon_handscuffs.png"

end

SWEP.Base 		= "weapon_tttbase"
SWEP.Author   	    	= "Converted by Porter"
SWEP.PrintName		= "Handcuffs"
SWEP.Purpose        	= "Therewith someone can't use Weapons"
SWEP.Instructions   	= "Left click to put cuffs on. Right click to take cuffs off."
SWEP.Spawnable      	= false
SWEP.AdminSpawnable 	= true
SWEP.HoldType 		= "normal"   
SWEP.UseHands		= true
SWEP.ViewModelFlip	= false
SWEP.ViewModelFOV	= 90
SWEP.ViewModel      	= "models/katharsmodels/handcuffs/handcuffs-1.mdl"
SWEP.WorldModel   	= "models/katharsmodels/handcuffs/handcuffs-1.mdl"
SWEP.Kind 		= WEAPON_EQUIP2
SWEP.CanBuy 		= { ROLE_DETECTIVE }
SWEP.InLoadOutFor = { ROLE_DETECTIVE }

SWEP.Primary.NumShots		= 1	
SWEP.Primary.Delay			= 0.9 	
SWEP.Primary.Recoil			= 0	
SWEP.Primary.Ammo         	= "none"	
SWEP.Primary.Damage			= 0	
SWEP.Primary.Cone			= 0 	
SWEP.Primary.ClipSize		= -1	
SWEP.Primary.DefaultClip	= -1	
SWEP.Primary.Automatic   	= false	


SWEP.Secondary.Delay		= 0.9
SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= 0
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= false
SWEP.Secondary.Ammo         = "none"
SWEP.Used = false

 function SWEP:Reload()
end 


 if ( CLIENT ) then
	function SWEP:GetViewModelPosition( pos, ang )
		ang:RotateAroundAxis( ang:Forward(), 90 ) 
		pos = pos + ang:Forward()*6
		return pos, ang
	end 
end


function SWEP:Think()
end


function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	if ( SERVER ) then
    self:SetWeaponHoldType(self.HoldType)
	end
end


function SWEP:PrimaryAttack(ply)
	local owner = self.Owner
	local trace = { }
	trace.start = self.Owner:EyePos();
	trace.endpos = trace.start + self.Owner:GetAimVector() * 95;
	trace.filter = self.Owner;
			
	local tr = util.TraceLine( trace );
	local ply = tr.Entity
	
	if not IsValid(self.Owner) then return end
	if not IsValid(ply) then return end
	if ply:IsPlayer() or ply:IsNPC() then else return end
	if ply:GetNWBool( "Cuffed", false ) then return end
	if self.Used == true then return end
	self.Used = true
	ply:SetNWBool( "Cuffed", true )
	
	timer.Simple( 30, function() 
		if IsValid(ply) and ply:GetNWBool( "Cuffed", false ) then
		ply:SetNWBool( "Cuffed", false )
			if ply:Alive() then
				if SERVER then
					ply:Give("weapon_zm_improvised")
					ply:Give("weapon_zm_carry")
					ply:Give("weapon_ttt_unarmed")
				end
				self:Remove()
			end		
		end
	end )
	
	self.Owner:PrintMessage	(HUD_PRINTCENTER,"Player was cuffed.")
	ply:PrintMessage (HUD_PRINTCENTER,"You were cuffed.")
	
	self.Owner:EmitSound("npc/metropolice/vo/dontmove.wav", 50, 100)
	ply:EmitSound("npc/metropolice/vo/dontmove.wav", 50, 100)	
	
	for k, v in pairs( ply:GetWeapons() ) do
		ply:DropWeapon( v )
	end
	if SERVER then
		ply:StripWeapons()
		ply:StripAmmo()
	end
end

function SWEP:SecondaryAttack(ply)
	local owner = self.Owner
	local trace = { }
	trace.start = self.Owner:EyePos();
	trace.endpos = trace.start + self.Owner:GetAimVector() * 95;
	trace.filter = self.Owner;
			
	local tr = util.TraceLine( trace );
	local ply = tr.Entity
	
	if not IsValid(self.Owner) then return end
	if not IsValid(ply) then return end
	if not ply:GetNWBool( "Cuffed", false ) then return end
	self.Used = false
	
	self.Owner:PrintMessage	(HUD_PRINTCENTER,"Player was uncuffed.")
	ply:PrintMessage (HUD_PRINTCENTER,"You were uncuffed.")
	
	ply:SetNWBool("Cuffed", false)
	
	self.Owner:EmitSound("npc/metropolice/vo/Isaidmovealong.wav", 50, 100)
	ply:EmitSound("npc/metropolice/vo/Isaidmovealong.wav", 50, 100)	
	
	if ply:Alive() then
		if SERVER then
			ply:Give("weapon_zm_improvised")
			ply:Give("weapon_zm_carry")
			ply:Give("weapon_ttt_unarmed")
		end
	end	
	self:Remove()	
end

local function up( ply, ent )
	if ply:GetNWBool("Cuffed") == true then
		return false
	end
end

hook.Add( "AllowPlayerPickup", "HandCuffsAllowPlayerPickup", up )
hook.Add( "PlayerCanPickupItem", "HandcuffsPlayerCanPickupItem", up )
hook.Add( "PlayerCanPickupWeapon", "noDoublePickup", up )



local function StopCantPickUp1()
	for k, v in pairs(player.GetAll) do
		ply:SetNWBool( "Cuffed", false )
	end
end
hook.Add("TTTEndRound", "CantPickUpEnd", StopCantPickUp)
hook.Add( "TTTBeginRound", "CantPickUpEnd2", StopCantPickUp )

local function StopCantPickUp2(ply)
	ply:SetNWBool( "Cuffed", false )
end
hook.Add( "PlayerDisconnected", "handcuffsplayerDisconnected", StopCantPickUp2 )