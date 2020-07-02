// Variables that are used on both client and server

SWEP.Author			= "Stingwraith"
SWEP.Contact		= "stingwraith123@yahoo.com"
SWEP.Purpose		= "Sacrifice yourself for Allah."
SWEP.Instructions	= "Left Click to make yourself EXPLODE. Right click to taunt."
SWEP.DrawCrosshair		= false


SWEP.EquipMenuData = {
      type="Weapon",
      model="models/weapons/v_jb.mdl",
      desc="Kills yourself and others around you."
   };

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true		// Spawnable in singleplayer or by server admins
SWEP.ViewModel			= "models/weapons/v_jb.mdl"
SWEP.WorldModel			= "models/weapons/w_jb.mdl"
SWEP.AllowDrop = false

SWEP.Base			= "weapon_tttbase"

SWEP.Slot = 7
SWEP.Kind                       = WEAPON_ROLE
SWEP.CanBuy                     = { ROLE_TRAITOR }
SWEP.GroupOnly = true;
SWEP.Groups = {"vip", "admin", "ducklord", "superadmin"};
SWEP.Icon                       = "vgui/entities/weapon_jihadbomb"
SWEP.Spawnable			= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay			= 3

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:OnRemove()
   if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
      RunConsoleCommand("lastinv")
   end
end

function SWEP:OnDrop()
self:Remove()
end

/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
end   

function SWEP:Initialize()
    util.PrecacheSound("siege/big_explosion.wav")
    util.PrecacheSound("siege/jihad.wav")
end


/*---------------------------------------------------------
   Think does nothing
---------------------------------------------------------*/
function SWEP:Think()	
end


/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
self.Weapon:SetNextPrimaryFire(CurTime() + 3)

	
	local effectdata = EffectData()
		effectdata:SetOrigin( self.Owner:GetPos() )
		effectdata:SetNormal( self.Owner:GetPos() )
		effectdata:SetMagnitude( 8 )
		effectdata:SetScale( 1 )
		effectdata:SetRadius( 16 )
	util.Effect( "Sparks", effectdata )
	
	self.BaseClass.ShootEffects( self )
	
	
	// The rest is only done on the server
	if (SERVER) then
		timer.Simple(2, function() self:Asplode() end )
		self.Owner:EmitSound( "siege/jihad.wav" )
	end

end

--The asplode function
function SWEP:Asplode()
local k, v
	-- Make an explosion at your position
	local ent = ents.Create( "env_explosion" )
		ent:SetPos( self.Owner:GetPos() )
		ent:SetOwner( self.Owner )
		ent:Spawn()
		ent:SetKeyValue( "iMagnitude", "0" )
		ent:Fire( "Explode", 0, 0 )
		util.BlastDamage( self, self.Owner, self.Owner:GetPos(), 500, 500 )
		ent:EmitSound( "siege/big_explosion.wav", 500, 100 )
		
		--[[
		self.Owner:Kill( )
		
		local expl = ents.Create( "env_explosion" )
		expl:SetPos( pos )
		expl:Spawn()
		expl:SetOwner( self:GetThrower() )
		expl:SetKeyValue( "iMagnitude", "0" )
		expl:Fire( "Explode", 0, 0 )
		util.BlastDamage( self, self:GetThrower(), pos, 400, 200 )
		expl:EmitSound( "siege/big_explosion.wav", 400, 200 )
		]]
		
		
		
		for k, v in pairs( player.GetAll( ) ) do
		  v:ConCommand( "play siege/big_explosion.wav\n" )
		end

end


/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()	
	
	self.Weapon:SetNextSecondaryFire( CurTime() + 1 )
	
	local TauntSound = Sound( "vo/npc/male01/overhere01.wav", 500, 100 )

	self.Weapon:EmitSound( TauntSound )
	
	// The rest is only done on the server
	if (!SERVER) then return end
	
	self.Weapon:EmitSound( TauntSound )


end
