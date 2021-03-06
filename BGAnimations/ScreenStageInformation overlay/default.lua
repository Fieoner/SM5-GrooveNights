local t = Def.ActorFrame{	
	Def.Quad{
	InitCommand=function(self)
		self:diffuse(0,0,0,1)
	end,
	OnCommand=function(self)
		self:x(SCREEN_CENTER_X):y(SCREEN_CENTER_Y):FullScreen()
	end
	},
};

GAMESTATE:Env()["gnNextScreen"] = "ScreenPlayerOptions"
PREFSMAN:SetPreference( "GlobalOffsetSeconds", GAMESTATE:Env()["NewOffset"] )
t[#t+1] = Def.ActorFrame{
		Condition=not GAMESTATE:IsCourseMode(),
		InitCommand=function(s) s:hibernate(0.199):xy( SCREEN_CENTER_X,SCREEN_BOTTOM+100 ):bounceend(0.5):y( SCREEN_CENTER_Y ) end,
		Def.Sprite{ Texture=THEME:GetPathG("Stages/ScreenGameplay","stage ".. ToEnumShortString(GAMESTATE:GetCurrentStage())) },
};
t[#t+1] = Def.ActorFrame{
	Condition=GAMESTATE:IsCourseMode(),
	InitCommand=function(s) s:hibernate(0.199):xy( SCREEN_CENTER_X,SCREEN_BOTTOM+100 ):bounceend(0.5):y( SCREEN_CENTER_Y ) end,
	Def.Sprite{ Texture=THEME:GetPathG("Stages/ScreenGameplay course","song 1") },
};

t[#t+1] = Def.Sprite{
    Texture=THEME:GetPathG("","TransitionArrow"),
    OnCommand=function(s)
		s:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y):accelerate(0.2):y(-60)
		SOUND:PlayOnce( THEME:GetPathS("gnScreenTransition whoosh", "long") )
    end,
}

return t;