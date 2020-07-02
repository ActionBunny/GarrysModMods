if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	SWEP.AutoSwitchTo		= true
	SWEP.AutoSwitchFrom		= true
end


SWEP.VElements = {
	["raygun"] = { type = "Model", model = "models/raygun/ray_gun.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(13.77, -0.616, -2.32), angle = Angle(-86.367, 2.88, 93.068), size = Vector(1.062, 1.062, 1.062), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 1, bodygroup = {} }
}

SWEP.WElements = {
	["raygun"] = { type = "Model", model = "models/raygun/ray_gun.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(10.543, 0.607, -4.518), angle = Angle(-103.295, -7.159, 88.976), size = Vector(0.833, 0.833, 0.833), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

if ( CLIENT ) then
	SWEP.DrawAmmo			= true
	SWEP.PrintName			= "Raygun"
	SWEP.Author				= "ErrolLiamP"
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 50

	SWEP.BounceWeaponIcon = false
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/raygun.vtf") 
	
	SWEP.EquipMenuData = {
      type = "Weapon",
      desc = "Use your ray powers to murder\nall of those innocents!\nCANNOT BE DROPPED!"
   };
	
	SWEP.Icon = "pack/raygan.png"
end

SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.AllowDrop = true

game.AddAmmoType( {
 name = "raygun",
 dmgtype = DMG_BULLET,
 tracer = TRACER_LINE,
 plydmg = 0,
 npcdmg = 0,
 force = 2000,
 minsplash = 10,
 maxsplash = 5
} )

SWEP.Category				= "Call of Duty" 
SWEP.Slot					= 6
SWEP.SlotPos				= 1
SWEP.Weight					= 5
SWEP.Spawnable     			= false
SWEP.AdminSpawnable  		= true
 
SWEP.UseHands               = true
SWEP.WorldModel 			= ""

SWEP.ViewModelFOV = 45
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {
	["ValveBiped.base"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.clip"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}


SWEP.Range					= 2*GetConVarNumber( "sk_vortigaunt_zap_range",100)*12
SWEP.DamageForce			= 48000	
SWEP.HealSound				= Sound("NPC_Vortigaunt.SuitOn")
SWEP.HealLoop				= Sound("NPC_Vortigaunt.StartHealLoop")
SWEP.AttackLoop				= Sound("NPC_Vortigaunt.ZapPowerup" )
SWEP.AttackSound			= Sound("weapons/raygun/raygun_fire.wav")
SWEP.HealDelay				= 2.0		
SWEP.MaxArmor				= 18	
SWEP.MinArmor				= 12
SWEP.MinHealth				= 20
SWEP.MaxHealth				= 20
SWEP.HealthLimit			= 100
SWEP.ArmorLimit				= 50	
SWEP.BeamDamage				= 45
SWEP.BeamChargeTime			= 0.1
SWEP.Deny					= Sound("Buttons.snd19")			

SWEP.Primary.ClipSize		= 0
SWEP.Primary.AmmoPerUse     = 1
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.Ammo 			= "raygun"
SWEP.Primary.Automatic		= true


SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo 		= false
SWEP.Secondary.AmmoPerUse   = 4
SWEP.Secondary.Automatic 	= true


function SWEP:Initialize()
	self.Charging=false;//we are not charging!
	self.Healing=false;	//we are not healing!
	self.HealTime=CurTime();//we can heal
	self.ChargeTime=CurTime();//we can zap
	self:SetWeaponHoldType("pistol")//this is the better holdtype i could find,well,it fits its job
	if (CLIENT) then return end
	self:CreateSounds()			//create the looping sounds	
end 

function SWEP:Precache()
	PrecacheParticleSystem( "vortigaunt_beam" );		//the zap beam
--	PrecacheParticleSystem( "vortigaunt_beam_charge" );	//the glow particles
	util.PrecacheModel(self.ViewModel)					//the view model
 	util.PrecacheSound( "weapons/raygun/raygun_fire.wav" ) //the fire sound
end

function SWEP:CreateSounds()

	if (!self.ChargeSound) then
		self.ChargeSound = CreateSound( self.Weapon, self.AttackLoop );
	end
	if (!self.HealingSound) then
		self.HealingSound = CreateSound( self.Weapon, self.HealLoop );
	end
end

function SWEP:DispatchEffect(EFFECTSTR)
	local pPlayer=self.Owner;
	if !pPlayer then return end
	local view;
	if CLIENT then view=GetViewEntity() else view=pPlayer:GetViewEntity() end
		if ( !pPlayer:IsNPC() && view:IsPlayer() ) then
			ParticleEffectAttach( EFFECTSTR, PATTACH_POINT_FOLLOW, pPlayer:GetViewModel(), pPlayer:GetViewModel():LookupAttachment( "muzzle" ) );
		else
			ParticleEffectAttach( EFFECTSTR, PATTACH_POINT_FOLLOW, pPlayer, pPlayer:LookupAttachment( "anim_attachment_rh" ) );
		end
end

function SWEP:ShootEffect(EFFECTSTR,startpos,endpos)
	local pPlayer=self.Owner;
	if !pPlayer then return end
	local view;
	if CLIENT then view=GetViewEntity() else view=pPlayer:GetViewEntity() end
		if ( !pPlayer:IsNPC() && view:IsPlayer() ) then
			util.ParticleTracerEx( EFFECTSTR, self.Weapon:GetAttachment( self.Weapon:LookupAttachment( "muzzle" ) ).Pos,endpos, true, pPlayer:GetViewModel():EntIndex(), pPlayer:GetViewModel():LookupAttachment( "muzzle" ) );
		else
			util.ParticleTracerEx( EFFECTSTR, pPlayer:GetAttachment( pPlayer:LookupAttachment( "anim_attachment_rh" ) ).Pos,endpos, true,pPlayer:EntIndex(), pPlayer:LookupAttachment( "anim_attachment_rh" ) );
		end
end
	
function SWEP:ImpactEffect( traceHit )
	local data = EffectData();
	data:SetOrigin(traceHit.HitPos)
	data:SetNormal(traceHit.HitNormal)
	data:SetScale(20)
	util.Effect( "StunstickImpact", data );
	local rand=math.random(1,1.5);
	self:CreateBlast(rand,traceHit.HitPos)
	self:CreateBlast(rand,traceHit.HitPos)											
	self.Weapon:EmitSound(Sound("weapons/raygun/raygun_fire.wav"))
	if SERVER && traceHit.Entity && IsValid(traceHit.Entity) && string.find(traceHit.Entity:GetClass(),"ragdoll") then
		traceHit.Entity:Fire("StartRagdollBoogie");
		/*
		local boog=ents.Create("env_ragdoll_boogie")
		boog:SetPos(traceHit.Entity:GetPos())
		boog:SetParent(traceHit.Entity)
		boog:Spawn()
		boog:SetParent(traceHit.Entity)
		*/
	end
end

function SWEP:CreateBlast(scale,pos)
	if CLIENT then return end
	local blastspr = ents.Create("env_sprite");			//took me hours to understand how this damn
	blastspr:SetPos( pos );								//entity works
	blastspr:SetKeyValue( "model", "sprites/vortring1.vmt")//the damn vortigaunt beam ring
	blastspr:SetKeyValue( "scale",tostring(scale))
	blastspr:SetKeyValue( "framerate",60)
	blastspr:SetKeyValue( "spawnflags","1")
	blastspr:SetKeyValue( "brightness","255")
	blastspr:SetKeyValue( "angles","0 0 0")
	blastspr:SetKeyValue( "rendermode","9")
	blastspr:SetKeyValue( "renderamt","255")
	blastspr:Spawn()
	blastspr:Fire("kill","",0.45)							//remove it after 0.45 seconds
end						
function SWEP:Shoot(dmg,effect)
	local pPlayer=self.Owner
	if !pPlayer then return end
	//so you can't just snipe with the long range of 16384 game units
	local traceres=util.QuickTrace(self.Owner:EyePos(),self.Owner:GetAimVector()*self.Range,self.Owner)
	self:ShootEffect(effect or "vortigaunt_beam",pPlayer:EyePos(),traceres.HitPos)	//shoop da whoop
	if SERVER then
		if IsValid(traceres.Entity) then	//we hit something
		local DMG=DamageInfo()
		DMG:SetDamageType(DMG_DISSOLVE)		//it's called vortigaunt zap attack for a reason
		DMG:SetDamage(dmg or self.BeamDamage)
		DMG:SetAttacker(self.Owner)
		DMG:SetInflictor(self)
		DMG:SetDamagePosition(traceres.HitPos)
		DMG:SetDamageForce(pPlayer:GetAimVector()*self.DamageForce)
		traceres.Entity:TakeDamageInfo(DMG)
		end
	end
	--self.Owner:GetViewModel():EmitSound(self.AttackSound)
	self:ImpactEffect( traceres )
end

function SWEP:Holster( wep )
	self:StopEveryThing()
	return true
end

function SWEP:OnRemove()
	self:StopEveryThing()
end

function SWEP:StopEveryThing()
	self.Charging=false;
	if SERVER && self.ChargeSound then
		self.ChargeSound:Stop();
	end
	self.Healing=false;
	if SERVER && self.HealingSound then
		self.HealingSound:Stop();
	end
	
	local pPlayer = self.LastOwner;
	if (!pPlayer) then
		return;
	end
	local Weapon = self.Weapon
		if (!pPlayer) then return end
		if (!pPlayer:GetViewModel()) then return end
		if ( CLIENT ) then if ( pPlayer == LocalPlayer() ) then pPlayer:GetViewModel():StopParticles();end	end
		pPlayer:StopParticles();
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	--self:SetDeploySpeed( 1 )
	return true
end

function SWEP:Think()
	if self.Owner && IsValid(self.Owner)then self.LastOwner=self.Owner end //i hate doing this,whatever
	--i send the weapon animation before the actual shooting because the gravity gloves attack is delayed...
		--		  self.Weapon:EmitSound(Sound("weapons/raygun/raygun_fire.wav")) SPAMS SOUND
	if self.Charging && self.ChargeTime-0.1 < CurTime() && !self.attack then
		
		if self.Owner:GetAmmoCount(self.Primary.Ammo)>=self.Primary.AmmoPerUse then//check always if we have ammo
			self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		--	self:DispatchEffect("vortigaunt_charge_token")//this effect lags a lot,but we see it for 0.1 seconds,who cares

			//self.Owner:SetAnimation(PLAYER_ATTACK1)	//todo:sincronize the world model player attack
			//and,send the idle animation
			//timer.Simple(0.1,function()if !IsValid(self.Owner) || self.Owner:GetActiveWeapon()!=self || !IsValid(self)  then return end self.Weapon:SendWeaponAnim(ACT_VM_IDLE)end)
						--  self.Weapon:EmitSound(Sound("weapons/raygun/raygun_fire.wav"))
		end
		self.attack=true;
	end
	
	if self.Charging && self.ChargeTime < CurTime() then
		
		if self.Owner:GetAmmoCount(self.Primary.Ammo)<self.Primary.AmmoPerUse then 
			//what the hell? something stole my ammo!
			self.Weapon:EmitSound(self.Deny)
			self.Weapon:SetNextPrimaryFire(CurTime()+SoundDuration(self.Deny))
			self.Weapon:SetNextSecondaryFire(CurTime()+SoundDuration(self.Deny))
			if IsValid(self.Owner:GetViewModel())then self.Owner:GetViewModel():StopParticles() end
			self.Owner:StopParticles()
			self.Charging=false;
			self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
			if SERVER && self.ChargeSound then	self.ChargeSound:Stop();end
			return
		end
		
		self.Owner:RemoveAmmo(self.Primary.AmmoPerUse,self.Primary.Ammo);
		if IsValid(self.Owner:GetViewModel())then self.Owner:GetViewModel():StopParticles() end
		self.Owner:StopParticles()
		self:Shoot()
		self.Charging=false;
	
		self.attack=false;
		if SERVER && self.ChargeSound then	self.ChargeSound:Stop();end
		
		self.Weapon:SetNextPrimaryFire(CurTime()+0.25)
		self.Weapon:SetNextSecondaryFire(CurTime()+0.25)
	end
	
	if self.Healing && self.HealTime<CurTime() then
		if self.Owner:GetAmmoCount(self.Primary.Ammo)<self.Secondary.AmmoPerUse || self.Owner:Armor()>=self.ArmorLimit then 
		self.Weapon:EmitSound(self.Deny)
		self.Weapon:SetNextPrimaryFire(CurTime()+SoundDuration(self.Deny))
		self.Weapon:SetNextSecondaryFire(CurTime()+SoundDuration(self.Deny))
		if IsValid(self.Owner:GetViewModel())then self.Owner:GetViewModel():StopParticles() end
		self.Owner:StopParticles()
		self.Healing=false;
		self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
		if SERVER && self.HealingSound then	self.HealingSound:Stop();end
		return
		end
		self.Owner:RemoveAmmo(self.Secondary.AmmoPerUse,self.Primary.AmmoPerUse);
		if IsValid(self.Owner:GetViewModel())then self.Owner:GetViewModel():StopParticles() end
		self.Owner:StopParticles()
		self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
		self.Healing=false;
		self.Owner:EmitSound(self.HealSound)
		if SERVER && self.HealingSound then	self.HealingSound:Stop();end
		self:GiveArmor()
		self.Weapon:SetNextPrimaryFire(CurTime()+1)
		self.Weapon:SetNextSecondaryFire(CurTime()+1)
	end
end



function SWEP:PrimaryAttack()
	if self.Charging || self.Healing then return end
	
--	if self.Owner:GetAmmoCount(self.Primary.Ammo)<self.Primary.AmmoPerUse then 
--	self.Weapon:EmitSound(self.Deny)
--	self.Weapon:SetNextPrimaryFire(CurTime()+SoundDuration(self.Deny))
--	self.Weapon:SetNextSecondaryFire(CurTime()+SoundDuration(self.Deny))
--	return 
--	end
	
--	self:DispatchEffect("vortigaunt_charge_token_b")
--	self:DispatchEffect("vortigaunt_charge_token_c")
	self.ChargeTime=CurTime()+self.BeamChargeTime;
	self.attack=false;
	self.Charging=true
	--self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
	
	//commented because util.particletracer does not follow the attachment pos
	//and ParticleEffectAttach does not let you set the endpoint of an effect,or it does?
	/*
---	self:ShootEffect("vortigaunt_beam_charge",self.Owner:EyePos(),self.Owner:GetPos()+Vector(0,32,0))
---	self:ShootEffect("vortigaunt_beam_charge",self.Owner:EyePos(),self.Owner:GetPos()+Vector(0,-32,0))
--	self:ShootEffect("vortigaunt_beam_charge",self.Owner:EyePos(),self.Owner:GetPos()+Vector(32,0,0))
--	self:ShootEffect("vortigaunt_beam_charge",self.Owner:EyePos(),self.Owner:GetPos()+Vector(-32,0,0))
	*/
	if SERVER && self.ChargeSound then
	self.ChargeSound:PlayEx( 100, 150 );
	end
	self.Weapon:SetNextPrimaryFire(CurTime()+3)
	self.Weapon:SetNextSecondaryFire(CurTime()+3)
	
end


function SWEP:SecondaryAttack()

end

function SWEP:Reload()

	return true
end


/********************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378
	   
	   
	DESCRIPTION:
		This script is meant for experienced scripters 
		that KNOW WHAT THEY ARE DOING. Don't come to me 
		with basic Lua questions.
		
		Just copy into your SWEP or SWEP base of choice
		and merge with your own code.
		
		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
********************************************************/

function SWEP:Initialize()

	// other initialize code goes here

	if CLIENT then
	
		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
	end

end

function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )

		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end































--by ErrolLiamP

