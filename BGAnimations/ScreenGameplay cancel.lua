return Def.ActorFrame{
    Def.Quad{
        OnCommand=function(s) s:stretchto(SCREEN_WIDTH,SCREEN_HEIGHT/2,0,SCREEN_HEIGHT):diffuse(Color.
        Black):addy( SCREEN_HEIGHT/2 ):decelerate(0.2):addy( -SCREEN_HEIGHT/2 )
        end
    },
    Def.Quad{
        OnCommand=function(s) s:stretchto(SCREEN_WIDTH,SCREEN_HEIGHT/2,0,0):diffuse(Color.Black):addy( -SCREEN_HEIGHT/2 )
            :decelerate(0.2):addy( SCREEN_HEIGHT/2 )
        end
    },

    Def.Sprite{
        Texture=THEME:GetPathG("","Loading"),
        OnCommand=function(s)
            s:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y+70):diffusealpha(0):sleep(0.3):linear(0.2):diffusealpha(1)
        end,
    },

    Def.Sprite{
        Texture=THEME:GetPathG("","TransitionArrow"),
        OnCommand=function(s)
            s:xy(SCREEN_RIGHT+200,SCREEN_CENTER_Y):rotationz(-90):decelerate(0.2):x( SCREEN_CENTER_X )
            :linear(0.2):rotationz(0)
        end,
        StartTransitioningCommand=function(s)
            SOUND:PlayOnce( THEME:GetPathS("gnScreenTransition whoosh", "short") )
        end,
    },
}