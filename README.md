# Emoji.lua - a way to add emotions in your Gmod UI

### Example

```lua
local Emoji = include("lib/emoji.lua")
Emoji.GetMaterial("thumbsup", "twitter", 64, function(mat)
    hook.Add("HUDPaint", "Thumbsup-emoji", function()
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(16, 16, 64, 64)
    end)
end, math.random(0, 6))
```
| Parameter | Type | Optional |
|-|-|:-:|
| name | string |  |
| provider | string |  |
| size | number |  |
| callback | function |  |
| skinTone | number | ✔ |
| retryCount | number | ✔ |
