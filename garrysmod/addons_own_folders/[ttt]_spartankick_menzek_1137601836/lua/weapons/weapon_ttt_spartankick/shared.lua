if SERVER  then

	AddCSLuaFile( "shared.lua" )

	resource.AddFile("materials/models/hevsuit/hevsuit_sheet.vmt")
	resource.AddFile("materials/models/hevsuit/hevsuit_sheet_normal.vtf")
	resource.AddFile("models/weapons/v_kick.dx80.vtx")
	resource.AddFile("models/weapons/v_kick.dx90.vtx")
	resource.AddFile("models/weapons/v_kick.mdl")
	resource.AddFile("models/weapons/v_kick.sw.vtx")
	resource.AddFile("models/weapons/v_kick.vvd")
	resource.AddFile("sound/player/skick/foot_kickbody.wav")
	resource.AddFile("sound/player/skick/foot_kickwall.wav")
	resource.AddFile("sound/player/skick/foot_swing.wav")
	resource.AddFile("sound/player/skick/kick1.wav")
	resource.AddFile("sound/player/skick/kick2.wav")
	resource.AddFile("sound/player/skick/kick3.wav")
	resource.AddFile("sound/player/skick/kick4.wav")
	resource.AddFile("sound/player/skick/kick5.wav")
	resource.AddFile("sound/player/skick/kick6.wav")
	resource.AddFile("sound/player/skick/madness.mp3")
	resource.AddFile("sound/player/skick/sparta.mp3")
	resource.AddFile("sound/player/skick/spartakurz.mp3")
	resource.AddFile("materials/vgui/ttt/icon_sparta.png")
end

CreateConVar( "ttt_sparta_speedscale", "1.2", FCVAR_NOTIFY + FCVAR_ARCHIVE + FCVAR_REPLICATED, "Adjust the speed a minified player has. 1 is default, 0 none." )
minifierSpartan = GetConVar( "ttt_sparta_speedscale" ):GetFloat()


if CLIENT  then
	SWEP.Category = "Shot846"
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.PrintName = "Spartan Kick"
	SWEP.Slot = 7

   SWEP.EquipMenuData = {
	type = "item_weapon",
	desc = "Kick them out of their Life!"
   };

   SWEP.Icon = "vgui/ttt/icon_sparta.png"
end

SWEP.Base 		= "weapon_tttbase"
SWEP.PrintName			= "Spartan Kick"
SWEP.Author		= "Converted by Porter"
SWEP.Instructions	= "Spartan Kick!"
SWEP.Purpose		= "THIS IS SPARTAAAAAAA!"

SWEP.ViewModelFOV	= 75
SWEP.ViewModelFlip	= false

SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true

SWEP.NextStrike = 0;
  
SWEP.ViewModel     	= "models/weapons/v_kick.mdl"
SWEP.WorldModel   	= "models/props_lab/huladoll.mdl"
SWEP.Kind 		= WEAPON_EQUIP2
SWEP.CanBuy 		= {ROLE_TRAITOR}
SWEP.AllowDrop 		= false
SWEP.DestroyDoor	= 1

-------------Primary Fire Attributes----------------------------------------
SWEP.Primary.Delay		= 0.4 		--In seconds
SWEP.Primary.Recoil		= 0		--Gun Kick
SWEP.Primary.Damage		= 15		--Damage per Bullet
SWEP.Primary.NumShots		= 1		--Number of shots per one fire
SWEP.Primary.Cone		= 0 		--Bullet Spread
SWEP.Primary.ClipSize		= -1		--Use "-1 if there are no clips"
SWEP.Primary.DefaultClip	= -1		--Number of shots in next clip
SWEP.Primary.Automatic   	= true		--Pistol fire (false) or SMG fire (true)
SWEP.Primary.Ammo         	= "none"	--Ammo Type


util.PrecacheSound("player/skick/madness.mp3")
util.PrecacheSound("player/skick/foot_kickwall.wav")
util.PrecacheSound("player/skick/foot_kickbody.wav")
util.PrecacheSound("player/skick/sparta.mp3")
util.PrecacheSound("player/skick/spartakurz.mp3")
util.PrecacheSound("player/skick/kick1.wav")
util.PrecacheSound("player/skick/kick2.wav")
util.PrecacheSound("player/skick/kick3.wav")
util.PrecacheSound("player/skick/kick4.wav")
util.PrecacheSound("player/skick/kick5.wav")
util.PrecacheSound("player/skick/kick6.wav")

-- GLOBAL_spartaTable = {}
-- GLOBAL_spartaSlowTable = {}
--local swepSlowEnts = {}

-- local function AddToTable(tbl, ply)
	-- if ply == nil then
	-- else
		-- print ("minifier: " .. ply:Nick() .. " added to minifierTable")
		-- table.insert( tbl, ply )
	-- end
-- end

-- local function RemoveFromTable(tbl, ply)
	-- if ply == nil then
	-- else
		-- for i=1, table.Count(tbl) do
			-- if tbl[i] == ply then
				-- table.remove(tbl, i)
				-- print("minifier: " .. ply:Nick() .. " removed from minifierTable")
			-- end
		-- end
	-- end
-- end

function SWEP:Initialize()

	if( CLIENT ) then
		self:AddHUDHelp("MOUSE1 : Kick Like a Spartan", "MOUSE2 : Play Madness Sound", false)
	end
	if( SERVER ) then
			self:SetWeaponHoldType("normal");
	end
	self.Hit = { 
	Sound( "player/skick/foot_kickwall.wav" )};
	self.FleshHit = {
  	Sound( "player/skick/kick1.wav" ),
	Sound( "player/skick/kick2.wav" ),
	Sound( "player/skick/kick3.wav" ),
  	Sound( "player/skick/kick4.wav" ),
	Sound( "player/skick/kick5.wav" ),
	Sound( "player/skick/kick6.wav" ) } ;

end

function SWEP:Precache()
end

function SWEP:Deploy()
	-- AddToTable( GLOBAL_spartaTable, self.Owner )
	self.Weapon:SendWeaponAnim( ACT_VM_IDLE );
	return true;
end

function SWEP:OnRemove()
	-- RemoveFromTable( GLOBAL_spartaTable, self.Owner )
	-- table.Empty( GLOBAL_spartaSlowTable )
end

function SWEP:PreDrop()
	-- RemoveFromTable( GLOBAL_spartaTable, self.Owner )
	-- table.Empty( GLOBAL_spartaSlowTable )
   return self.BaseClass.PreDrop(self)
end


function SWEP:Holster()
	-- RemoveFromTable( GLOBAL_spartaTable, self.Owner )
	-- table.Empty( GLOBAL_spartaSlowTable )
   return true
end

function SWEP:CreateSlowField()
	local slowEnts = ents.FindInSphere( self.Owner:GetPos(), 200 )
	for _,v in pairs(slowEnts) do
		if v:IsPlayer() and not (v == self.Owner) then
			-- AddToTable(GLOBAL_spartaSlowTable, v)
			--AddToTable(swepSlowEnts, v)
		end
	end
	-- timer.Create("timer2", 2.25, 1, function() table.Empty( GLOBAL_spartaSlowTable ) end)
end

function SWEP:PrimaryAttack()

	 if( CurTime() < self.NextStrike ) then return; end
	 self.Weapon:EmitSound("player/skick/spartakurz.mp3")
	 self.NextStrike = ( CurTime() + 2.5 );
	self:CreateSlowField()
	 timer.Create("timer1", 1.65, 1, function() self.AttackAnim(self) end)
	 timer.Create("timer2", 2.25, 1, function() self.Weapon:SendWeaponAnim( ACT_VM_IDLE ) end)
     timer.Create("timer3", 1.85, 1,  function() self.ShootBullets (self) end)
	 self.Owner:SetAnimation( PLAYER_ATTACK1 );

	 local function StopKick1(ply)
		timer.Stop("timer1")
		timer.Stop("timer2")
		timer.Stop("timer3")
		timer.Stop("timer4")
		timer.Stop("timer5")
		timer.Stop("timer6")
	 end
	 hook.Add("TTTPrepareRound", "SpartanKickEnd1", StopKick1)

end	

function SWEP:ShootBullets()
	if not self.Owner:IsValid() then return end
	if not self.Owner:Alive() then return end
	self.Weapon:EmitSound("player/skick/foot_swing.wav");
 	local trace = self.Owner:GetEyeTrace();
	if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 110 then
		if( trace.Entity:IsPlayer() or trace.Entity:IsNPC() or trace.Entity:GetClass()=="prop_ragdoll" ) then	
			self.Owner:EmitSound( self.FleshHit[math.random(1,#self.FleshHit)] );
		else
			self.Owner:EmitSound( self.Hit[math.random(1,#self.Hit)] );
		end
				bullet = {}
				bullet.Num    = 40
				bullet.Src    = self.Owner:GetShootPos()
				bullet.Dir    = self.Owner:GetAimVector()
				bullet.Spread = Vector(0.14, 0.14, 0)
				bullet.Tracer = 0
				bullet.Force  = 450
				bullet.Damage = 1000000
			self.Owner:FireBullets(bullet)
	end
	
	local trace = self.Owner:GetEyeTrace();
	if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 110 then
		if trace.Entity:GetClass() == "prop_door_rotating" and (SERVER) then
			trace.Entity:Fire("open", "", 0.001)
			trace.Entity:Fire("unlock", "", 0.001)

			local pos = trace.Entity:GetPos()
			local ang = trace.Entity:GetAngles()
			local model = trace.Entity:GetModel()
			local skin = trace.Entity:GetSkin()

			local smoke = EffectData()
				smoke:SetOrigin(pos)
				util.Effect("effect_smokedoor", smoke)

			trace.Entity:SetNotSolid(true)
			trace.Entity:SetNoDraw(true)

			local function ResetDoor(door, fakedoor)
				door:SetNotSolid(false)
				door:SetNoDraw(false)
				fakedoor:Remove()
			end

			local norm = (pos - self.Owner:GetPos())
			norm:Normalize()
			local push = 1000 * norm
			local ent = ents.Create("prop_physics")

			ent:SetPos(pos)
			ent:SetAngles(Angle(10, 50, 0))
			ent:SetModel(model)

			if(skin) then
				ent:SetSkin(skin)
			end

			ent:Spawn()

			timer.Create("timer4", .01, 1, function() if ent and push then ent:GetPhysicsObject():SetVelocity(push) end end)              
			timer.Create("timer5", .01, 1, function() if ent and push then ent:GetPhysicsObject():SetVelocity(push) end end)
			timer.Create("timer6", 25, 1, function() ResetDoor( trace.Entity, ent, 10) end )
	end

     local function StopKick2(ply)
          timer.Stop("timer1")
          timer.Stop("timer2")
          timer.Stop("timer3")
          timer.Stop("timer4")
          timer.Stop("timer5")
          timer.Stop("timer6")
     end
     hook.Add("TTTPrepareRound", "SpartanKickEnd2", StopKick2)

end

end

function SWEP:SecondaryAttack()

if( CurTime() < self.NextStrike ) then return; end
	self.Weapon:EmitSound("player/skick/madness.mp3")
	self.NextStrike = ( CurTime() + 2.2 );
end

function SWEP:AttackAnim()
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
end 

hook.Add("TTTPlayerSpeedModifier", "SpartanSpeed", function(ply, _, _, refTbl)  
  if not IsValid(ply) or not ply:Alive() then return end
  if not IsValid(ply:GetActiveWeapon()) then return end
  if not (ply:GetActiveWeapon():GetClass() == "weapon_ttt_spartankick") then return end
		refTbl[1] = refTbl[1] * minifierSpartan  * (ply.speedrun_mul or 1)
end)