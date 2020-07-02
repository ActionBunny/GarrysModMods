util.AddNetworkString("RAM_MapVoteStart")
util.AddNetworkString("RAM_MapVoteUpdate")
util.AddNetworkString("RAM_MapVoteCancel")
util.AddNetworkString("RTV_Delay")
util.AddNetworkString("MapvoteMapInfo" )

MapVote.Continued = false

net.Receive("RAM_MapVoteUpdate", function(len, ply)
    if(MapVote.Allow) then
        if(IsValid(ply)) then
            local update_type = net.ReadUInt(3)
            
            if(update_type == MapVote.UPDATE_VOTE) then
                local map_id = net.ReadUInt(32)
                if(MapVote.CurrentMaps[map_id]) then
                    MapVote.Votes[ply:SteamID()] = map_id
                    
                    net.Start("RAM_MapVoteUpdate")
                        net.WriteUInt(MapVote.UPDATE_VOTE, 3)
                        net.WriteEntity(ply)
                        net.WriteUInt(map_id, 32)
                    net.Broadcast()
                end
            end
        end
    end
end)

--liest kürzlich gespielte karten aus
if file.Exists( "mapvote/recentmaps.txt", "DATA" ) then
    recentmaps = util.JSONToTable(file.Read("mapvote/recentmaps.txt", "DATA"))
else
    recentmaps = {}
end

--list config aus
if file.Exists( "mapvote/config.txt", "DATA" ) then
    MapVote.Config = util.JSONToTable(file.Read("mapvote/config.txt", "DATA"))
else
    MapVote.Config = {}
end

function CoolDownDoStuff()
    cooldownnum = MapVote.Config.MapsBeforeRevote or 30

    --while table.Count( recentmaps ) > cooldownnum do
    ---  table.remove(recentmaps)
    --end

	for i=cooldownnum, table.Count( recentmaps ) do
		table.remove(recentmaps)
	end
	
    local curmap = game.GetMap():lower()..".bsp"

    if not table.HasValue(recentmaps, curmap) then
        table.insert(recentmaps, 1, curmap)
    end
	file.Write("mapvote/recentmaps.txt", "")
    file.Write("mapvote/recentmaps.txt", util.TableToJSON(recentmaps))
end

function UpdateMapInfo( case, map, text)
	if not file.Exists( "mapvote/maps/" .. map .. "_desc.txt", "DATA" ) then
		file.Write( "mapvote/maps/" .. map .. "_desc.txt", "x" )
	end
	if not file.Exists( "mapvote/maps/" .. map .. "_lastplayed.txt", "DATA" ) then
		file.Write( "mapvote/maps/" .. map .. "_lastplayed.txt", "x" )			
	end
	if not file.Exists( "mapvote/maps/" .. map .. "_size.txt", "DATA" ) then
		file.Write( "mapvote/maps/" .. map .. "_size.txt", "x" )			
	end
	
	if case == "LastPlayed" then
		file.Write( "mapvote/maps/" .. map .. "_lastplayed.txt", text )
	elseif case == "Size" then
		file.Write( "mapvote/maps/" .. map .. "_size.txt", text )
	elseif case == "Desc" then
		file.Write( "mapvote/maps/" .. map .. "_desc.txt", text )
	end	
end

--start durch ulx
function MapVote.Start(length, current, limit, prefix)
    current = current or MapVote.Config.AllowCurrentMap or false
    --length = length or MapVote.Config.TimeLimit or 20
    length = 20
    limit = limit or MapVote.Config.MapLimit or 24
	cooldown = MapVote.Config.EnableCooldown or true
    --cooldown = true
    prefix = prefix or MapVote.Config.MapPrefixes

    local is_expression = false

    if not prefix then
        local info = file.Read(GAMEMODE.Folder.."/"..GAMEMODE.FolderName..".txt", "GAME")

        if(info) then
            local info = util.KeyValuesToTable(info)
            prefix = info.maps
        else
            error("MapVote Prefix can not be loaded from gamemode")
        end

        is_expression = true
    else
        if prefix and type(prefix) ~= "table" then
            prefix = {prefix}
        end
    end
    
    local maps = file.Find("maps/*.bsp", "GAME")
    --start festlegen mit "Random" map
    local vote_maps = {}
    
    local amt = 0

    for k, map in RandomPairs(maps) do
        local mapstr = map:sub(1, -5):lower()
        if(not current and game.GetMap():lower()..".bsp" == map) then continue end
        if(cooldown and table.HasValue(recentmaps, map)) then continue end

        if is_expression then
            if(string.find(map, prefix)) then -- This might work (from gamemode.txt)
                vote_maps[#vote_maps + 1] = map:sub(1, -5)
                amt = amt + 1
            end
        else
            for k, v in pairs(prefix) do
                if string.find(map, "^"..v) then
                    vote_maps[#vote_maps + 1] = map:sub(1, -5)
                    amt = amt + 1
                    break
                end
            end
        end

        if(limit and amt >= limit) then break end
    end
	local mapinfo ={}
	
	--if file.Exists( "mapvote/maps.txt", "DATA" ) then
	--	mapinfo = util.JSONToTable(file.Read("mapvote/maps.txt", "DATA"))
	--else
	--	file.Write( "mapvote/maps.txt", "" )
	--end

	table.insert( vote_maps, 1, "Random Map" )
	
	
	
   --mapliste schreiben
	net.Start("RAM_MapVoteStart")
        net.WriteUInt(#vote_maps, 32)
        
		local timeStamp = os.time(os.date("!*t"))
        timeStamp = timeStamp - 1000000
		for i = 1, #vote_maps do
            net.WriteString(vote_maps[i])
			local mapinfo = {}	
			
--für jede map 3 dateien: beschreibung, lastplayed, size			
			if not file.Exists( "mapvote/maps/" .. vote_maps[i] .. "_desc.txt", "DATA" ) then
				file.Write( "mapvote/maps/" .. vote_maps[i] .. "_desc.txt", "x" )
			end
			if not file.Exists( "mapvote/maps/" .. vote_maps[i] .. "_lastplayed.txt", "DATA" ) then
				file.Write( "mapvote/maps/" .. vote_maps[i] .. "_lastplayed.txt", timeStamp + i )			
			end
			if not file.Exists( "mapvote/maps/" .. vote_maps[i] .. "_size.txt", "DATA" ) then
				file.Write( "mapvote/maps/" .. vote_maps[i] .. "_size.txt", "x" )			
			end
			
			local lastplayed = file.Read("mapvote/maps/" .. vote_maps[i] .. "_lastplayed.txt", "DATA")
			local size = file.Read("mapvote/maps/" .. vote_maps[i] .. "_size.txt", "DATA")
			local desc = file.Read("mapvote/maps/" .. vote_maps[i] .. "_desc.txt", "DATA")
			
			net.WriteString( lastplayed )
			net.WriteString( size )
			net.WriteString( desc )
        end
        
        net.WriteUInt(length, 32)
    net.Broadcast()
    
    MapVote.Allow = true
    MapVote.CurrentMaps = vote_maps
    MapVote.Votes = {}
    
    timer.Create("RAM_MapVote", length, 1, function()
        MapVote.Allow = false
        local map_results = {}
        local new_map_results = {}
        for k, v in pairs(MapVote.Votes) do
           table.insert(new_map_results, v) 
        end
		--PrintTable( new_map_results )
        CoolDownDoStuff()

        local winner = table.Random( new_map_results ) or 1
	
        net.Start("RAM_MapVoteUpdate")
            net.WriteUInt(MapVote.UPDATE_WIN, 3)
            
            net.WriteUInt(winner, 32)
        net.Broadcast()
        
        local map = MapVote.CurrentMaps[winner]

		if map == "Random Map" then
			table.remove( vote_maps, 1 )
			map = table.Random( vote_maps )
		end
        
		timer.Simple(4, function()
            hook.Run("MapVoteChange", map)
            RunConsoleCommand("changelevel", map)
        end)
    end)
end

hook.Add("TTTEndRound", "TTTEndRoundMapVote", function()
	local map = game.GetMap():lower()
	local timeStamp = tostring( os.time(os.date("!*t")) )
	UpdateMapInfo( "LastPlayed", map, timeStamp )
end)

hook.Add( "PlayerSay", "mapvotechatcommand", function( ply, text, public )
	local infotext = ""
	local map = game.GetMap():lower()
	if (string.sub(text, 1, 8) == "!mapsize") then --if the first 4 letters are /die, kill him
		
		size = string.upper( string.sub(text, 10) )
		UpdateMapInfo( "Size", map, size )
		
		infotext = "Changed size of " .. map .. " to " .. size .. "."
		
    elseif (string.sub(text, 1, 8) == "!mapdesc") then --if the first 4 letters are /die, kill him
		
		desc = string.sub(text, 10)
		UpdateMapInfo( "Desc", map, desc )	
		
		infotext = "Changed description of " .. map .. " to " .. desc .. "."

	elseif (string.sub(text, 1) == "!mapinfo") or (string.sub(text, 1) == "!mi") then

		local currentsize = file.Read("mapvote/maps/" .. map .. "_size.txt", "DATA")
		local currentdesc = file.Read("mapvote/maps/" .. map .. "_desc.txt", "DATA")
		
		infotext = 					"      " .. map .. "\n"
		if string.lower(currentsize) == "x" then
			infotext = infotext .. "No size defined.\n"
		else
			infotext = infotext .. 	"Size:              " .. currentsize .. "\n"
		end
		if string.lower(currentdesc) == "x" then
			infotext = infotext .. "No description defined.\n"
		else
			infotext = infotext .. 	"Description:   " .. currentdesc .. "\n"
		end
		infotext = infotext .. "\nChange with '!mapsize (size)' and '!mapdesc (description)' "
	end
	
	if infotext ~= "" then
		net.Start( "MapvoteMapInfo")	
			net.WriteString( infotext )
		net.Broadcast()	
	end
end )

hook.Add( "Shutdown", "RemoveRecentMaps", function()
	if file.Exists( "mapvote/recentmaps.txt", "DATA" ) then
		--file.Delete( "mapvote/recentmaps.txt" )
	end
end )

function MapVote.Cancel()
    if MapVote.Allow then
        MapVote.Allow = false

        net.Start("RAM_MapVoteCancel")
        net.Broadcast()

        timer.Destroy("RAM_MapVote")
    end
end