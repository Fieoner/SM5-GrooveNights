local player = ...
assert(player)

local function side(pn)
	local s = 1
	if pn == PLAYER_1 then return s end
	return s*(-1)
end
if not GAMESTATE:Env()[player.."gnCalculation"] then
	GAMESTATE:Env()[player.."gnCalculation"] = LoadModule("GrooveNights.LevelCalculator.lua")(player)
end
local ach = GAMESTATE:Env()[player.."gnCalculation"]
local t = Def.ActorFrame{
    OnCommand=function(s)
        local ymargin = player == PLAYER_1 and 30 or 130
        s:xy( SCREEN_CENTER_X-160*side(player)-8, SCREEN_CENTER_Y+154 )
        :diffusealpha( GAMESTATE:IsPlayerEnabled(player) and 1 or 0 )
    end,
	PlayerJoinedMessageCommand=function(s,param)
		if param.Player == player then
			s:linear(0.2):diffusealpha( GAMESTATE:IsPlayerEnabled(player) and 1 or 0 )
			s:sleep(0.1):queuecommand("BeginLoad")
		end
	end,
	-- Perform Load
	BeginLoadCommand=function(s,param)
		ach = LoadModule("GrooveNights.LevelCalculator.lua")(player)
		MESSAGEMAN:Broadcast("UpdateInfoPlayer",{pn=player})
	end,
	SelectMenuOpenedMessageCommand=function(s,param) if param.Player == player then s:playcommand("LVBarOn") end end,
	SelectMenuClosedMessageCommand=function(s,param) if param.Player == player then s:playcommand("LVBarOff") end end,
}

local BI = Def.ActorFrame{
	OnCommand=function(s)
		s:y( LoadModule("Options.GetProfileData.lua")(player)["Name"] ~= "No Card"  and 0 or 30 )
	end,
	UpdateInfoPlayerMessageCommand=function(s)
		s:sleep(1.8):decelerate(0.3):y( LoadModule("Options.GetProfileData.lua")(player)["Name"] ~= "No Card"  and 0 or 30 )
	end,
}

	BI[#BI+1] = Def.Sprite{ Texture="PaneDisplay under.png", OnCommand=function(s) s:diffuse( color("#060A0E") ):zoom(0.8):xy(-28,-33) end }
	BI[#BI+1] = Def.Sprite{ Texture="PaneDisplay B", OnCommand=function(s) s:diffuse( color("#060A0E") ):zoom(0.8):xy(-28,-33) end }

	-- Achievement Icons
	local Achievements = {
		5, -- SongCount
		8, -- ExpCount
		11, -- DeadCount
		14, -- StarCount
	}
	for _,v in pairs(Achievements) do
		BI[#BI+1] = Def.Sprite{
			Texture=THEME:GetPathG("",ach.Achievements[_] > 0 and "achievements/achievement".. string.format("%04i",(v-1)+ach.Achievements[_]) or "achievements/achievement".. string.format("%04i",(v)) ),
			OnCommand=function(s)
				s:xy( -130 + (24 * (_-1)), -53 ):zoom(0.8)
				s:diffuse( ach.Achievements[_] > 0 and Color.White or color("#555555") )
			end,
			LVBarOnCommand=function(s) s:stoptweening():bounceend(0.2):rotationx(90) end,
			LVBarOffCommand=function(s) s:stoptweening():decelerate(0.2):rotationx(0) end,
			UpdateInfoPlayerMessageCommand=function(s,param)
				if param.pn == player then
					s:Load( THEME:GetPathG("",ach.Achievements[_] > 0 and "achievements/achievement".. string.format("%04i",(v-1)+ach.Achievements[_]) or "achievements/achievement".. string.format("%04i",(v)) ) )
					s:diffuse( ach.Achievements[_] > 0 and Color.White or color("#555555") )
				end
			end,
		}
	end

	for i=1,4 do
		local total = ach[5]["Grade_Tier0"..i]
		BI[#BI+1] = Def.ActorFrame{
			OnCommand=function(s)
				s:xy( -106+(34*(i-1)), -53 ):rotationx(90)
			end,
			LVBarOnCommand=function(s) s:stoptweening():decelerate(0.2):rotationx(0) end,
			LVBarOffCommand=function(s) s:stoptweening():bounceend(0.2):rotationx(90) end,
			Def.Sprite{
				Texture=THEME:GetPathG("","achievements/achievement".. string.format( "%04i", i )),
				OnCommand=function(s) s:x( -26 ):zoom(0.6) end,
			},
			Def.BitmapText{ Font="_eurostile normal", Text=total, OnCommand=function(s) s:x(-8):zoom(0.5) end,
			UpdateInfoPlayerMessageCommand=function(s,param)
				if param.pn == player then
					local total = ach[5]["Grade_Tier0"..i]
					s:settext( total )
				end
			end,
		}
	}
	end

	-- Level & Progress Stats --
	BI[#BI+1] = Def.ActorFrame{
		OnCommand=function(s)
			s:xy( 40, -46 )
		end,
		-- Level Indicator
		Def.BitmapText{
			Font="Common Normal",
			OnCommand=function(s)
				s:halign(0):xy( -38, -11 ):zoom(0.4)
				s:settext( "Level ".. ach[3] )
			end,
			UpdateInfoPlayerMessageCommand=function(s,param)
				if param.pn == player then
					s:settext( "Level ".. ach[3] )
				end
			end,
		},
		Def.BitmapText{
			Condition=LoadModule("Config.Load.lua")("ToggleEXPCounter","Save/GrooveNightsPrefs.ini"),
			Font="Common Normal",
			OnCommand=function(s)
				s:halign(1):xy( 48, -11 ):zoom(0.3)
				s:settext( "(".. math.floor(ach[2]).."/".. math.floor(ach[4]) ..")" )
			end,
			UpdateInfoPlayerMessageCommand=function(s,param)
				if param.pn == player then
					s:settext( "(".. math.floor(ach[2]).."/".. math.floor(ach[4]) ..")" )
				end
			end,
		},
		Def.Quad{ OnCommand=function(s) s:diffuse( color("0.1,0.1,0.1,1") ):zoomto(90,4):xy(4,-2) end, },
		Def.Quad{ OnCommand=function(s) s:diffuse( color("0.6,0.8,0.9,1") ):zoomto(90,4):xy(4,-2)
			:cropright( (100-ach[1])/100 ) end,
			UpdateInfoPlayerMessageCommand=function(s,param)
				if param.pn == player then
					s:cropright( (100-ach[1])/100 )
				end
			end,
		},
		Def.Sprite{ Texture=THEME:GetPathG("","EXP/expBar") },
	}

	BI[#BI+1] = Def.Sprite{ Texture="PaneDisplay F", OnCommand=function(s) s:diffuse( color("#1C2C3C") ):zoom(0.8):xy(-28,-33):cropleft(0.02) end }

t[#t+1] = BI

-- Begin by drawing the overlay
t[#t+1] = Def.Sprite{ Texture="PaneDisplay under.png", OnCommand=function(s) s:diffuse( color("#060A0E") ) end }
t[#t+1] = Def.Sprite{ Texture="PaneDisplay B", OnCommand=function(s) s:diffuse( color("#060A0E") ) end }
t[#t+1] = Def.Sprite{ Texture="PaneDisplay under under.png", OnCommand=function(s) s:diffuse( color("#333333") ) end }
-- Ok, base drawing done, time for profile picture.
t[#t+1] = Def.Sprite {
    Texture=LoadModule("Options.GetProfileData.lua")(player)["Image"];
    OnCommand=function(s)
        s:xy(-114,-2)
		:setsize(64,64)
		if LoadModule("Options.GetProfileData.lua")(player)["Name"] == "No Card" then
			s:diffuse( PlayerColor(player) )
		end
	end,
	UpdateInfoPlayerMessageCommand=function(s,param)
		if param.pn == player then
			s:sleep(1.3):linear(0.3):diffusealpha(0):sleep(0.01):queuecommand("UpdateIcon")
		end
	end,
	UpdateIconCommand=function(s)
		s:Load( LoadModule("Options.GetProfileData.lua")(player)["Image"] )
		:setsize(64,64)
		if LoadModule("Options.GetProfileData.lua")(player)["Name"] ~= "No Card" then
			s:linear(0.3):diffuse(Color.White)
		end
	end,
};
if PROFILEMAN:GetProfile(player):GetDisplayName() ~= "" then
	t[#t+1] = Def.Quad {
		OnCommand=function(s) s:zoomto(64,64):xy(-114,-2):croptop(0.7):fadetop(0.1):diffuse(Color.Black) end,
	}
end
t[#t+1] = Def.Sprite {
    Texture=THEME:GetPathG("","AvatarFrame");
    OnCommand=function(s)
        s:xy(-114,-2):diffuse( color("#1C2C3C") )
	end,
};
t[#t+1] = Def.BitmapText {
	Font="_eurostile normal",
	Text=PROFILEMAN:GetProfile(player):GetDisplayName(),
    OnCommand=function(s)
        s:xy(-114,22):zoom(0.5):diffuse( PlayerColor(player) )
	end,
	PlayerJoinedMessageCommand=function(s,param)
		if param.Player == player then s:settext("Loading...") end
	end,
	UpdateInfoPlayerMessageCommand=function(s)
		s:settext( PROFILEMAN:GetProfile(player):GetDisplayName() )
	end,
};

t[#t+1] = Def.Sprite{ Texture="PaneDisplay F", OnCommand=function(s) s:diffuse( color("#1C2C3C") ) end }

	local StepsOrCourse = function() return GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player) end
	local ColorGradients = { color("#FFFFFF"), color("#FF9898"), color("#FF6262"), color("#FF3838") }
	local ObtainData = {
		--LEFT SIDE
		{
			{"Steps", function() return StepsOrCourse() and LoadModule("Pane.RadarValue.lua")(player, 5) or 0 end, {1,200,350,550} },
			{"Holds", function() return StepsOrCourse() and LoadModule("Pane.RadarValue.lua")(player, 8) or 0 end, {1,75,150,300} },
			{function() return LoadModule("Pane.PercentScore.lua")(player)[2] end, function() return LoadModule("Pane.PercentScore.lua")(player)[1] end },
			{"Card", function() return LoadModule("Pane.PercentScore.lua")(player)[1] end },
			xpos = {-75,0},
		},
		--RIGHT SIDE
		{
			{"Jumps", function() return StepsOrCourse() and LoadModule("Pane.RadarValue.lua")(player, 7) or 0 end, {1,25,50,75} },
			{"Mines", function() return StepsOrCourse() and LoadModule("Pane.RadarValue.lua")(player, 9) or 0 end, {1,50,100,150} },
			{"Hands", function() return StepsOrCourse() and LoadModule("Pane.RadarValue.lua")(player, 10) or 0 end, {1,10,35,75} },
			{"Rolls", function() return StepsOrCourse() and LoadModule("Pane.RadarValue.lua")(player, 11) or 0 end, {1,10,35,75} },
			xpos = {10,80},
		},
		DiffPlacement = 120
	}
	for ind,content in ipairs(ObtainData) do
		for vind,val in ipairs( ObtainData[ind] ) do
			t[#t+1] = Def.BitmapText{
				Font="_eurostile normal",
				Text=val[1],
				InitCommand=function(s)
					s:zoom(0.5):xy(
						ObtainData[ind].xpos[1] + 0
						,-24+14*(vind-1)):halign(0)
				end;
				["CurrentSteps"..ToEnumShortString(player).."ChangedMessageCommand"]=function(s)
                    -- replace
					if GAMESTATE:GetCurrentSteps(player) and val[1] and type(val[1]) == "function" then
						s:settext( val[1]() )
					end
				end;
			};
			t[#t+1] = Def.BitmapText{
				Font="_eurostile normal",
				Text=val[2],
				InitCommand=function(s)
					s:zoom(0.5):xy(
						ObtainData[ind].xpos[2] + 0
                        ,-24+14*(vind-1)
                    ):halign(1)
                end,
				CurrentSongChangedMessageCommand=function(s)
					s:diffuse(Color.White)
                    if not GAMESTATE:GetCurrentSong() then
                        s:settext("?")
                    end
                end,
				["CurrentSteps"..ToEnumShortString(player).."ChangedMessageCommand"]=function(s)
					if GAMESTATE:GetCurrentSteps(player) and val[2] then
						s:settext( val[2]() )
						if val[3] then
							for _,vae in pairs( val[3] ) do
								if val[2]() > vae then
									s:diffuse( ColorGradients[_] )
								end
							end
						end
					end
				end,
			};
		end
    end
    t[#t+1] = Def.BitmapText{
		Font="_eurostile normal",
		InitCommand=function(self) self:x(ObtainData.DiffPlacement):y(12):maxwidth(90):zoom(0.6) end;
		["CurrentSteps"..ToEnumShortString(player).."ChangedMessageCommand"]=function(s)
		if StepsOrCourse() then
			s:settext(
				LoadModule("Gameplay.DifficultyName.lua")( "Steps", player )
			)
			:diffuse( DifficultyColor( StepsOrCourse():GetDifficulty() ) )
		end
	end
    };

    t[#t+1] = Def.BitmapText{
        Font="_eurostile normal",
        Text="Step Artist",
		InitCommand=function(self) self:x(ObtainData.DiffPlacement):y(-24):maxwidth(120):zoom(0.53):diffuse( color("#FFA314") ) end;
	};
    
    t[#t+1] = Def.BitmapText{
		Font="_eurostile normal",
		InitCommand=function(self) self:x(ObtainData.DiffPlacement):y(-9):maxwidth(110):zoom(0.56) end;
		["CurrentSteps"..ToEnumShortString(player).."ChangedMessageCommand"]=function(s)
        if StepsOrCourse() then
            s:settext(
                GAMESTATE:GetCurrentSteps(player):GetAuthorCredit() and GAMESTATE:GetCurrentSteps(player):GetAuthorCredit()
                or GAMESTATE:GetCurrentSteps(player):GetDescription()
            )
		end
	end
	};

return t;