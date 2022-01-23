# Emoji.lua - a way to add emotions in your Gmod UI

### Emoji.GetMaterial
```lua
Emoji.GetMaterial("thumbsup", "twitter", 64, math.random(0, 6), function(mat)
    hook.Add("HUDPaint", "Thumbsup-emoji", function()
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(16, 16, 64, 64)
    end)
end)
```
`string`: emoji name  
>+1, thumbsup, joy, ok_hand, smile, e.t.c  
`string`: provider  
>twitter, google, apple, facebook  
`number`: size  
>64, 72, 96, e.t.c - use 64 if you didnt know whats sizes avaiable for this provider  
`number`: skinTone (optional)  
###### skin-tones preview will be here a bit later
`function(material)`: callback  
`number`: retryCount (optional)
