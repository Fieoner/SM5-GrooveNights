local t = Def.ActorFrame{}

t[#t+1] = Def.BitmapText{
    Font="Common Normal",
    Condition=LoadModule("Config.Load.lua")("ToggleSystemClock","Save/GrooveNightsPrefs.ini"),
    OnCommand=function(s)
        s:align(.5,1):xy( SCREEN_CENTER_X, (SCREENMAN:GetTopScreen():GetName() == "ScreenGameplay" or GAMESTATE:IsDemonstration()) and SCREEN_BOTTOM-17 or 26  ):zoom(0.5):diffusealpha( 0.8 ):vertspacing( -10 )
        :playcommand("Update")
    end,
    UpdateCommand=function(s)
        local Months = {"January","February","March","April","May","June","July","August","September","October","November","December"}
        local isPM = Hour() > 12
        local CurHour = isPM and (Hour()-12) or Hour()
        s:settext( DayOfMonth() .."/".. Months[MonthOfYear()+1] .."/".. Year() .."\n"..CurHour ..":".. string.format("%02i", Minute()).. (isPM and " PM" or " AM")  )
        :sleep(30/60):queuecommand("Update")
    end,
}

return t;