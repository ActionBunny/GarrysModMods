if SERVER then
   AddCSLuaFile( "shared.lua" )
   resource.AddFile("materials/VGUI/ttt/lykrast/icon_minifier.vmt")
   CreateConVar( "ttt_minifier_dealtscale", "0.65", FCVAR_NOTIFY + FCVAR_ARCHIVE , "Adjust the damagescale a minified player deals. 1 is default, 0 none." )
   CreateConVar( "ttt_minifier_gotscale", "3.3", FCVAR_NOTIFY + FCVAR_ARCHIVE , "Adjust the damagescale a minified player gots. 1 is default, 0 none." )
   
end

CreateConVar( "ttt_minifier_speedscale", "0.55", FCVAR_NOTIFY + FCVAR_ARCHIVE + FCVAR_REPLICATED, "Adjust the speed a minified player has. 1 is default, 0 none." )
minifierModifier = GetConVar( "ttt_minifier_speedscale" ):GetFloat()


if( CLIENT ) then
    SWEP.PrintName = "Minifier Menzek";
    SWEP.Slot = 8;
    SWEP.DrawAmmo = false;
    SWEP.DrawCrosshair = false;
    SWEP.Icon = "VGUI/ttt/lykrast/icon_minifier";
 
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Activate it to become smaller\nbut more vulnerable. May drain some health from you. Removes on Drop."
   };

end

SWEP.Author= "Lykrast"

SWEP.Base = "weapon_tttbase"
SWEP.Spawnable= false
SWEP.AdminSpawnable= true
SWEP.HoldType = "slam"
 
SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = {ROLE_TRAITOR}
 
SWEP.ViewModelFOV= 60
SWEP.ViewModelFlip= false
SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"
SWEP.UseHands	= true
 
 --- PRIMARY FIRE ---
SWEP.Primary.Delay= 0.25
SWEP.Primary.Recoil= 0
SWEP.Primary.Damage= 0
SWEP.Primary.NumShots= 1
SWEP.Primary.Cone= 0
SWEP.Primary.ClipSize= -1
SWEP.Primary.DefaultClip= -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Delay= 1
SWEP.Secondary.Recoil= 0
SWEP.Secondary.Damage= 0
SWEP.Secondary.NumShots= 1
SWEP.Secondary.Cone= 0
SWEP.Secondary.ClipSize= -1
SWEP.Secondary.DefaultClip= -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.NoSights = true
SWEP.AllowDrop = true

psc = 0.35
zmin_stand = 64 * psc
zmin_duck = 28 * psc

function Minify( ply )
	if ply:GetModelScale() < 0.9 then return end
    ply:SetModelScale( psc, 1 )
    --if SERVER then ply:SetMaxHealth( 30 ) end --beevis said so
    --ply:SetHealth( math.floor(ply:Health( ) * 0.3 ))
    ply:SetGravity( 1 )
	ply:SetViewOffset(Vector(0,0,zmin_stand))
	ply:SetViewOffsetDucked(Vector(0,0,zmin_duck))
	--print ( ply:Nick() .. " minified" )
	--ply.minified = true
	ply:SetNWBool( "Minified", true )
	--timer.Simple(0.1, Minify( ply ))
	--AddToTable(GLOBAL_minifierTable, ply)
end

function UnMinify( ply )
    if ply:GetModelScale() > 0.9 then return end
	ply:SetModelScale( 1, 1 )
   -- if SERVER then ply:SetMaxHealth( 100 ) end --beevis said so
   -- ply:SetHealth( math.min( math.floor(ply:Health( ) * 3.333334 ), 100 ))
    ply:SetGravity( 1 )
	ply:SetViewOffset(Vector(0,0,64))
	ply:SetViewOffsetDucked(Vector(0,0,28))
	--print ( ply:Nick() .. " unminified" )
	--ply.minified = false
	ply:SetNWBool( "Minified", false )
	--RemoveFromTable(GLOBAL_minifierTable, ply)
end

function SWEP:PrimaryAttack()
--print( self.Owner:GetViewOffset() )
--print( self.Owner:GetViewOffsetDucked() )

--if self.Owner:GetViewOffset() == 0.000000 0.000000 64.000000 then
--print( (Vector(0,0,zmin_stand)) )
--end
--if self.Owner:GetModelScale() == psc then 
ply = self.Owner
if ply:GetNWBool( "Minified", false ) == true then
   --while ply.minified == true do
		
		UnMinify( ply )
		--RemoveFromTable(GLOBAL_minifierTable, ply)
	--end
--elseif self.Owner:GetModelScale() == 1 then
else
	--while ply.minified == false do
		
		Minify( ply)

end

self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

end
 
function SWEP:PreDrop()
--if self.Owner:GetModelScale() == psc then
ply = self.Owner
if ply:GetNWBool( "Minified", false ) == true then
    UnMinify( ply )
	--RemoveFromTable(GLOBAL_minifierTable, self.Owner)
end
 
end

function SWEP:OnDrop()
--if self.Owner:GetModelScale() == psc then
ply = self.Owner
if ply:GetNWBool( "Minified", false ) == true then
    UnMinify( ply )
	--RemoveFromTable(GLOBAL_minifierTable, self.Owner)
end

self:Remove()
end

function SWEP:Deploy()

--print(self:GetClass())

end

hook.Add("TTTBeginRound", "BeginUnMinifyAll",function()
    for _, ply in pairs(player.GetAll()) do
        --[[v:SetModelScale( 1, 1 )
        v:SetGravity( 1 )
		v:SetViewOffset(Vector(0,0,64))
		v:SetViewOffsetDucked(Vector(0,0,28))--]]
		--if ply:GetModelScale() == psc then
		if ply:GetNWBool( "Minified", false ) == true then
			UnMinify( ply )
			--RemoveFromTable(GLOBAL_minifierTable, self.Owner)
		end
    end
end
)

hook.Add("TTTPrepareRound", "PrepUnMinifyAll",function()
    for _, ply in pairs(player.GetAll()) do
        --[[v:SetModelScale( 1, 1 )
        v:SetGravity( 1 )
		v.minified = false
		v:SetViewOffset(Vector(0,0,64))
		v:SetViewOffsetDucked(Vector(0,0,28))--]]
		--if ply:GetModelScale() == psc then
		if ply:GetNWBool( "Minified", false ) == true then
			UnMinify( ply )
			--RemoveFromTable(GLOBAL_minifierTable, self.Owner)
		end
    end
end
)
--[[
hook.Add( "KeyPress", "KeyPressMini", function( ply, key )
	print ( "KeyPress" )
	
	if ply:GetModelScale() == psc then	
			if ( key == IN_JUMP ) then
				hook.Add("StartCommand","blockattack", function(ply, ucmd )
					ucmd:RemoveKey(4)
				end)
			end	
	
	end
end )

hook.Add( "OnPlayerHitGround", "MiniOnPlayerHitGround", function( ply, _inWater, _onFloater, _speed )
	print( "hitground" )
	hook.Add("StartCommand","blockattack", function(ply, ucmd )
	end)
end
)

--]]
if CLIENT then
--optimierbar wenn nur aufgerufen wenn minifier gekauft (hook.add / hook.remove)
	hook.Add ( "CreateMove","RemoveDuck",function( ucmd )
		if not LocalPlayer():HasWeapon("weapon_ttt_minifier") == true then return end
		
		if LocalPlayer():GetNWBool( "Minified", false ) and LocalPlayer():IsOnGround() == false then
			ucmd:RemoveKey( IN_DUCK )
		end
	end
	)
end

hook.Add( "EntityTakeDamage", "MiniDamage", function( ent, dmginfo )
	if SERVER then
	--print( "minidamage" )
		if ent:IsPlayer() and IsValid(dmginfo:GetInflictor()) then
			inflictor = dmginfo:GetAttacker()
			--print ( inflictor:Nick() )
			if inflictor:GetNWBool( "Minified", false ) == true then
				dealtscale = GetConVar( "ttt_minifier_dealtscale" ):GetFloat()
				dmginfo:ScaleDamage( dealtscale )
				--print( inflictor.Nick() .. " was minified and dealt " .. dmginfo:GetDamage() .. " damage to " .. ent.Nick() )
			return
			end
		end
		
		if ent:IsPlayer() and IsValid(dmginfo:GetInflictor()) then
			if ent:GetNWBool( "Minified", false ) == true then
				gotscale = GetConVar( "ttt_minifier_gotscale" ):GetFloat()
				dmginfo:ScaleDamage( gotscale )
				--print( ent.Nick() .. " was minified and got shot for " .. dmginfo:GetDamage() .. " damage by " .. inflictor.Nick() .. "." )
				return
			end
		end
	end
end
)

hook.Add("TTTPlayerSpeedModifier", "MinifierSpeed", function(ply, _, _, refTbl)  
  if not IsValid(ply) or not ply:GetNWBool("Minified",false) then return end
		refTbl[1] = refTbl[1] * minifierModifier  * (ply.speedrun_mul or 1)
end)