# Emoji.lua - a way to add emotions in your Gmod UI

### Emoji.GetMaterial

| Parameter | Type | Example | Optional |
|-|-|:-:|
| name | string | "thumbsup" |  |
| provider | string | "twitter" |  |
| size | number | 64 |  |
| callback | function(material) |  |
| skinTone | number | 3 | ✔ |
| retryCount | number | 2 | ✔ |
```lua
Emoji.GetMaterial("thumbsup", "twitter", 64, function(mat)
    hook.Add("HUDPaint", "Thumbsup-emoji", function()
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(16, 16, 64, 64)
    end)
end, math.random(0, 6))
```
