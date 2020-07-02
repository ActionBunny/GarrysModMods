surface.CreateFont("RAM_VoteFont", {
    font = "Trebuchet MS",
    size = 19,
    weight = 700,
    antialias = true,
    shadow = true
})

surface.CreateFont("RAM_VoteFontCountdown", {
    font = "Tahoma",
    size = 32,
    weight = 700,
    antialias = true,
    shadow = true
})

surface.CreateFont("RAM_VoteSysButton", 
{    font = "Marlett",
    size = 13,
    weight = 0,
    symbol = true,
})

MapVote.EndTime = 0
MapVote.Panel = false

net.Receive("MapvoteMapInfo", function()	
	print("Mapinfotest")
	local text = net.ReadString()
	chat.AddText( Color(255,0,0), "Mapvote: ", Color(250,235,215), text )
end)

net.Receive("RAM_MapVoteStart", function()	
	MapVote.CurrentMaps = {}
	MapVote.CurrentLastPlayed = {}
	MapVote.CurrentSize = {}
	MapVote.CurrentDescription = {}
	MapVote.ID = {}
    MapVote.Allow = true
    MapVote.Votes = {}
    
    local amt = net.ReadUInt(32)
    
    for i = 1, amt do
        local i = #MapVote.CurrentMaps + 1
		local map = net.ReadString()
        MapVote.CurrentMaps[i] = map
		
		local lastplayed = net.ReadString()
		MapVote.CurrentLastPlayed[i] = lastplayed
		
		local size = net.ReadString()
		MapVote.CurrentSize[i] = size
		
		local desc = net.ReadString()
		MapVote.CurrentDescription[i] = desc
		
		MapVote.ID[i] = i
    end
    
    MapVote.EndTime = CurTime() + net.ReadUInt(32)
    
    if(IsValid(MapVote.Panel)) then
        MapVote.Panel:Remove()
    end

    MapVote.Panel = vgui.Create("VoteScreen")
    MapVote.Panel:SetMaps(MapVote.CurrentMaps, MapVote.CurrentLastPlayed, MapVote.CurrentSize, MapVote.CurrentDescription, MapVote.ID)
end)

net.Receive("RAM_MapVoteUpdate", function()
    local update_type = net.ReadUInt(3)
    
    if(update_type == MapVote.UPDATE_VOTE) then
        local ply = net.ReadEntity()
        
        if(IsValid(ply)) then
            local map_id = net.ReadUInt(32)
            MapVote.Votes[ply:SteamID()] = map_id
        
            if(IsValid(MapVote.Panel)) then
                MapVote.Panel:AddVoter(ply)
            end
        end
    elseif(update_type == MapVote.UPDATE_WIN) then      
        if(IsValid(MapVote.Panel)) then
            MapVote.Panel:Flash(net.ReadUInt(32))
        end
    end
end)

net.Receive("RAM_MapVoteCancel", function()
    if IsValid(MapVote.Panel) then
        MapVote.Panel:Remove()
    end
end)

net.Receive("RTV_Delay", function()
    chat.AddText(Color( 102,255,51 ), "[RTV]", Color( 255,255,255 ), " The vote has been rocked, map vote will begin on round end")
end)

local PANEL = {}

if ConVarExists( "cl_mapsorting" ) == false then
	print("created convar")
	CreateClientConVar( "cl_mapsorting", 0, true, false, "Stores sorting of mapvote over sessions." )
end

--PANEL.sorting = GetConVar( "cl_mapsorting" ):GetInt()

function PANEL:Init()
	self.Called = 0
	self.sorting = GetConVar( "cl_mapsorting" ):GetInt()

    self:ParentToHUD()
    
    self.Canvas = vgui.Create("Panel", self)
    self.Canvas:MakePopup()
    self.Canvas:SetKeyboardInputEnabled(false)
    
    self.countDown = vgui.Create("DLabel", self.Canvas)
    self.countDown:SetTextColor(color_white)
    self.countDown:SetFont("RAM_VoteFontCountdown")
    self.countDown:SetText("")
    self.countDown:SetPos(0, 14)
    
    self.mapList = vgui.Create("DPanelList", self.Canvas)
    self.mapList:SetDrawBackground(false)
    self.mapList:SetSpacing(4)
    self.mapList:SetPadding(4)
    self.mapList:EnableHorizontal(true)
    self.mapList:EnableVerticalScrollbar()
    
    self.closeButton = vgui.Create("DButton", self.Canvas)
    self.closeButton:SetText("")

    self.closeButton.Paint = function(panel, w, h)
        derma.SkinHook("Paint", "WindowCloseButton", panel, w, h)
    end

    self.closeButton.DoClick = function()
        self:SetVisible(false)
    end

    self.maximButton = vgui.Create("DButton", self.Canvas)
    self.maximButton:SetText("")
    self.maximButton:SetDisabled(true)

    self.maximButton.Paint = function(panel, w, h)
        derma.SkinHook("Paint", "WindowMaximizeButton", panel, w, h)
    end

    self.minimButton = vgui.Create("DButton", self.Canvas)
    self.minimButton:SetText("")
    self.minimButton:SetDisabled(true)

    self.minimButton.Paint = function(panel, w, h)
        derma.SkinHook("Paint", "WindowMinimizeButton", panel, w, h)
    end
	--multiple butons for sorting
	self.sortButtonStandard = vgui.Create("DButton", self.Canvas)
    self.sortButtonStandard:SetText("Default")
    self.sortButtonStandard:SetDisabled(false)
	
	self.sortButtonLastPlayed = vgui.Create("DButton", self.Canvas)
    self.sortButtonLastPlayed:SetText("Recently Played Last")
    self.sortButtonLastPlayed:SetDisabled(false)
	
	self.sortButtonName = vgui.Create("DButton", self.Canvas)
    self.sortButtonName:SetText("Name")
    self.sortButtonName:SetDisabled(false)
	
	self.sortButtonStandard.DoClick = function()
		self.sorting = 0
		GetConVar( "cl_mapsorting" ):SetInt(0)
		self:SortList()
	end
	
	self.sortButtonName.DoClick = function()
		self.sorting = 1
		GetConVar( "cl_mapsorting" ):SetInt(1)
		self:SortList()
	end
	
	self.sortButtonLastPlayed.DoClick = function()
		self.sorting = 2
		GetConVar( "cl_mapsorting" ):SetInt(2)
		self:SortList()
	end
	
	--self:SortList()

    self.Voters = {}
end

function PANEL:SortList()
	local defaultColor = Color(0,0,0)
	local redColor = Color(255,51,51)
	if self.sorting == 0 then
		self.sortButtonStandard:SetColor( redColor )
		self.sortButtonName:SetColor( defaultColor )
		self.sortButtonLastPlayed:SetColor( defaultColor )
	elseif self.sorting == 1 then
		self.sortButtonStandard:SetColor( defaultColor )
		self.sortButtonName:SetColor( redColor )
		self.sortButtonLastPlayed:SetColor( defaultColor )	
	elseif self.sorting == 2 then
		self.sortButtonStandard:SetColor( defaultColor )
		self.sortButtonName:SetColor( defaultColor )
		self.sortButtonLastPlayed:SetColor( redColor )
	end

	if self.sorting == 0 then --wie am anfang
		self:SetMaps(MapVote.CurrentMaps, MapVote.CurrentLastPlayed, MapVote.CurrentSize, MapVote.CurrentDescription, MapVote.ID)
			
	--MapVote.CurrentMaps
	elseif self.sorting == 1 then --alphabet
		local sort_func = function( a,b ) return a < b end
		
		local tempNameList = {}
		
		local newNameList = {}
		local newLastPlayedList = {}
		local newSiteList = {}
		local newDescList = {}
		local newIDList = {}
		
		table.Merge( tempNameList, MapVote.CurrentMaps )
		table.sort( tempNameList, sort_func )
		
		for i, record in ipairs( tempNameList ) do
			key = table.KeyFromValue( MapVote.CurrentMaps, record )
				--print(key)
			table.insert(newNameList, MapVote.CurrentMaps[key])
			table.insert(newLastPlayedList, MapVote.CurrentLastPlayed[key])
			table.insert(newSiteList, MapVote.CurrentSize[key])
			table.insert(newDescList, MapVote.CurrentDescription[key])
			table.insert(newIDList, MapVote.ID[key])
		end
		self:SetMaps(newNameList, newLastPlayedList, newSiteList, newDescList, newIDList)
		
	elseif self.sorting == 2 then --last played
	--MapVote.CurrentLastPlayed
		local sort_func = function( a,b ) return a < b end
		
		local tempDateList = {}
		
		local newNameList = {}
		local newLastPlayedList = {}
		local newSiteList = {}
		local newDescList = {}
		local newIDList = {}
		
		table.Merge( tempDateList, MapVote.CurrentLastPlayed )
		table.sort( tempDateList, sort_func )
		
		for i, record in ipairs( tempDateList ) do
				--print(record)
			key = table.KeyFromValue( MapVote.CurrentLastPlayed, record )
				--print(key)
			table.insert(newNameList, MapVote.CurrentMaps[key])
			table.insert(newLastPlayedList, MapVote.CurrentLastPlayed[key])
			table.insert(newSiteList, MapVote.CurrentSize[key])
			table.insert(newDescList, MapVote.CurrentDescription[key])
			table.insert(newIDList, MapVote.ID[key])
		end
		self:SetMaps(newNameList, newLastPlayedList, newSiteList, newDescList, newIDList)		
	end
end

function PANEL:PerformLayout()
    local cx, cy = chat.GetChatBoxPos()
    
    self:SetPos(0, 0)
    self:SetSize(ScrW(), ScrH())
    
    local extra = math.Clamp(300, 0, ScrW() - 640)
    self.Canvas:StretchToParent(0, 0, 0, 0)
    self.Canvas:SetWide(640 + extra)
    self.Canvas:SetTall(cy -60)
    self.Canvas:SetPos(0, 0)
    self.Canvas:CenterHorizontal()
    self.Canvas:SetZPos(0)
    
    self.mapList:StretchToParent(0, 90, 0, 0)

    local buttonPos = 640 + extra - 31 * 3

    self.closeButton:SetPos(buttonPos - 31 * 0, 4)
    self.closeButton:SetSize(31, 31)
    self.closeButton:SetVisible(false)

    self.maximButton:SetPos(buttonPos - 31 * 1, 4)
    self.maximButton:SetSize(31, 31)
    self.maximButton:SetVisible(false)

    self.minimButton:SetPos(buttonPos - 31 * 2, 4)
    self.minimButton:SetSize(31, 31)
    self.minimButton:SetVisible(false)
	
	self.sortButtonStandard:SetPos(buttonPos - 230, 50)
	self.sortButtonStandard:SetSize(100, 31)
	self.sortButtonStandard:SetVisible(true)
	
	self.sortButtonName:SetPos(buttonPos - 120, 50)
	self.sortButtonName:SetSize(100, 31)
	self.sortButtonName:SetVisible(true)
	
	self.sortButtonLastPlayed:SetPos(buttonPos - 10, 50)
	self.sortButtonLastPlayed:SetSize(100, 31)
	self.sortButtonLastPlayed:SetVisible(true)	
	--self.TextEntry:SetPos(buttonPos - 31 * 2, 70)
   --	self.sortButton:SetSize(100, 31)
	--self.sortButton:SetVisible(true)
end

local heart_mat = Material("icon16/heart.png")
local star_mat = Material("icon16/star.png")
local shield_mat = Material("icon16/shield.png")

function PANEL:AddVoter(voter)
    for k, v in pairs(self.Voters) do
        if(v.Player and v.Player == voter) then
            return false
        end
    end
    
    local icon_container = vgui.Create("Panel", self.mapList:GetCanvas())
    local icon = vgui.Create("AvatarImage", icon_container)
    icon:SetSize(16, 16)
    icon:SetZPos(1000)
    icon:SetTooltip(voter:Name())
    icon_container.Player = voter
    icon_container:SetTooltip(voter:Name())
    icon:SetPlayer(voter, 16)

   -- if MapVote.HasExtraVotePower(voter) then
    --    icon_container:SetSize(40, 20)
    --    icon:SetPos(21, 2)
   --     icon_container.img = star_mat
   -- else
        icon_container:SetSize(20, 20)
        icon:SetPos(2, 2)
   -- end
    
    icon_container.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(255, 0, 0, 80))
        
        if(icon_container.img) then
            surface.SetMaterial(icon_container.img)
            surface.SetDrawColor(Color(255, 255, 255))
            surface.DrawTexturedRect(2, 2, 16, 16)
        end
    end
    
    table.insert(self.Voters, icon_container)
end

		
function PANEL:Think()

	for k, v in pairs(self.mapList:GetItems()) do
        v.NumVotes = 0
    end
    
    for k, v in pairs(self.Voters) do
        if(not IsValid(v.Player)) then
            v:Remove()
        else
            if(not MapVote.Votes[v.Player:SteamID()]) then
                v:Remove()
            else
                local bar = self:GetMapButton(MapVote.Votes[v.Player:SteamID()])
                
               -- if(MapVote.HasExtraVotePower(v.Player)) then
               --     bar.NumVotes = bar.NumVotes + 2
               -- else
                    bar.NumVotes = bar.NumVotes + 1
               -- end
                
                if(IsValid(bar)) then
                    local CurrentPos = Vector(v.x, v.y, 0)
                    local NewPos = Vector((bar.x + bar:GetWide()) - 21 * bar.NumVotes - 2, bar.y + (bar:GetTall() * 0.5 - 10), 0)
                    
                    if(not v.CurPos or v.CurPos ~= NewPos) then
                        v:MoveTo(NewPos.x, NewPos.y, 0.3)
                        v.CurPos = NewPos
                    end
                end
            end
        end
        
    end
    
    local timeLeft = math.Round(math.Clamp(MapVote.EndTime - CurTime(), 0, math.huge))
    
    self.countDown:SetText(tostring(timeLeft or 0).." seconds")
    self.countDown:SizeToContents()
    self.countDown:CenterHorizontal()
end

SortFunc = function (myTable)
    local t = {}
    for title,value in pairsByKeys(myTable) do
        table.insert(t, { title = title, value = value })
    end
    myTable = t
    return myTable
end

function PANEL:SetMaps(maps, last, size, desc, id)
	self.mapList:Clear()
	--self.nameList = {}
	--self.dateList = {}
    for k, v in pairs(maps) do
        local button = vgui.Create("DButton", self.mapList)
        button.ID = id[k]

		if ( size[k] ~= "x") then
			button:SetText(v .. "   " .. size[k])
		else
			button:SetText(v)
		end
	
		button:SetMouseInputEnabled( true )
       
		local lastString = ""
		local descString = ""
		
		if (last[k] ~= "x") then
			lastString = tonumber(last[k])
			lastString = os.date('%d-%m-%Y', lastString)
		end			
		if (desc[k] ~= "x") then
			descString = desc[k]
		end	

		button.DoClick = function()
            net.Start("RAM_MapVoteUpdate")
                net.WriteUInt(MapVote.UPDATE_VOTE, 3)
                net.WriteUInt(button.ID, 32)
            net.SendToServer()
        end
     
        do
            local Paint = button.Paint
            button.Paint = function(s, w, h)
                local col = Color(255, 255, 255, 10)
                
                if(button.bgColor) then
                    col = button.bgColor
                end
                
                draw.RoundedBox(4, 0, 0, w, h, col)
                Paint(s, w, h)
            end
        end

       if v == "Random Map" then
			button:SetTextColor( Color(255,100,100,255) )
		else
			button:SetTextColor( color_white )
			button:SetTooltip("Last Played: " .. lastString .. "\n" .. descString)
		end		
        button:SetContentAlignment(4)
        button:SetTextInset(8, 0)
        button:SetFont("RAM_VoteFont")
        
        local extra = math.Clamp(300, 0, ScrW() - 640)
        
        button:SetDrawBackground(false)
        button:SetTall(24)
        button:SetWide(285 + (extra / 2))
        button.NumVotes = 0
           
		self.mapList:AddItem(button)
		--table.insert( self.nameList, v )
		--table.insert( self.dateList, tonumber( lastString ) )
    end
	--PrintTable( self.mapList )
	if self.Called == 0 then
		self.Called = 1
		self:SortList()
	end
end

function PANEL:GetMapButton(id)
    for k, v in pairs(self.mapList:GetItems()) do
        if(v.ID == id) then return v end
    end
    
    return false
end

function PANEL:Paint()
    --Derma_DrawBackgroundBlur(self)
    
    local CenterY = ScrH() / 2
    local CenterX = ScrW() / 2
    
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, ScrW(), ScrH())
end

function PANEL:Flash(id)
    self:SetVisible(true)

    local bar = self:GetMapButton(id)
    
    if(IsValid(bar)) then
        timer.Simple( 0.0, function() bar.bgColor = Color( 0, 255, 255 ) surface.PlaySound( "hl1/fvox/blip.wav" ) end )
        timer.Simple( 0.2, function() bar.bgColor = nil end )
        timer.Simple( 0.4, function() bar.bgColor = Color( 0, 255, 255 ) surface.PlaySound( "hl1/fvox/blip.wav" ) end )
        timer.Simple( 0.6, function() bar.bgColor = nil end )
        timer.Simple( 0.8, function() bar.bgColor = Color( 0, 255, 255 ) surface.PlaySound( "hl1/fvox/blip.wav" ) end )
        timer.Simple( 1.0, function() bar.bgColor = Color( 100, 100, 100 ) end )
    end
end

derma.DefineControl("VoteScreen", "", PANEL, "DPanel")