AddCSLuaFile()
--[[
hook.Add( "ShouldCollide", "FuckOnTouch", function( a, b )
  if !IsValid(a) or !IsValid(b) then return end
  if !a.ttte and !b.ttte then return end
  if a:IsPlayer() or a:IsNPC() then return true end
  if b:IsPlayer() or b:IsNPC() then return true end
end )
]]

if Server then
resource.AddFile( "/thomas/black_emty.vmt" )
resource.AddFile( "/thomas/black_emty.vtf" )
resource.AddFile( "/thomas/blue_emty.vmt" )
resource.AddFile( "/thomas/blue_emty.vtf" )
resource.AddFile( "/thomas/blue_wheel.vmt" )
resource.AddFile( "/thomas/blue_wheel.vtf" )
resource.AddFile( "/thomas/face.vmt" )
resource.AddFile( "/thomas/face.vtf" )
resource.AddFile( "/thomas/logoa.vmt" )
resource.AddFile( "/thomas/logoa.vtf" )
resource.AddFile( "/thomas/red_emty.vmt" )
resource.AddFile( "/thomas/red_emty.vtf" )
resource.AddFile( "/thomas/red_trima.vmt" )
resource.AddFile( "/thomas/red_trima.vtf" )
resource.AddFile( "/thomas/red_trimb.vmt" )
resource.AddFile( "/thomas/red_trimb.vtf" )
resource.AddFile( "/thomas/red_trimc.vmt" )
resource.AddFile( "/thomas/red_trimc.vtf" )
resource.AddFile( "/thomas/window_round.vmt" )
resource.AddFile( "/thomas/window_round.vtf" )
resource.AddFile( "/ttte/ttte_ttt_icon.png" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_nowheels/black_emty.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_nowheels/blue_emty.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_nowheels/citadel_metalwall072c.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_nowheels/combine_lightpanel001.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_nowheels/concretetrim001a.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_nowheels/face.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_nowheels/logoa.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_nowheels/metalgrate011a.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_nowheels/metalhull003a.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_nowheels/metalhull010b.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_nowheels/metalwall006b.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_nowheels/red_emty.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_nowheels/red_trima.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_nowheels/red_trimc.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_nowheels/rockcliff02b.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_nowheels/sprite_fire01.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_nowheels/window_round.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_wheels/black_emty.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_wheels/blue_emty.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_wheels/blue_wheel.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_wheels/citadel_metalwall072c.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_wheels/citadel_metalwall101b.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_wheels/combine_lightpanel001.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_wheels/concretetrim001a.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_wheels/face.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_wheels/logoa.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_wheels/metalgrate011a.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_wheels/metalhull003a.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_wheels/metalhull010b.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_wheels/metalwall006b.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_wheels/red_emty.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_wheels/red_trima.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_wheels/red_trimc.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_wheels/rockcliff02b.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_wheels/sprite_fire01.vmt" )
resource.AddFile( "/models/thomasandfriends/thomas_v1_wheels/window_round.vmt" )
end


sound.Add( {
	name = "thomas_bell",
	channel = 19,
	volume = 1.0,
	level = 90,
	pitch = { 95, 110 },
	sound = "ttte/thomas_bell.wav"
} )

sound.Add( {
	name = "thomas_trump_01",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 150,
	sound = "ttte/thomas_trump_01.mp3"
} )

sound.Add( {
	name = "thomas_trump_02",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 150,
	sound = "ttte/thomas_trump_02.mp3"
} )

sound.Add( {
	name = "thomas_trump_03",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 150,
	sound = "ttte/thomas_trump_03.mp3"
} )

sound.Add( {
	name = "thomas_trump_04",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 150,
	sound = "ttte/thomas_trump_04.mp3"
} )

sound.Add( {
	name = "thomas_trump_05",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 150,
	sound = "ttte/thomas_trump_05.mp3"
} )
