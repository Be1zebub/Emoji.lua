# Emoji.lua - a way to add emotions in your Gmod UI

#### Features:
> The entire library is in one short file  
> Content downloading only on request (your players dont need to download a lot of useless emojis that they will never see)  
> Comfy receipt of emojis by name (as in discord / Twitter)  
> Synchronous and asynchronous functions  
> Any combination of skin tones  
> Various emoji providers with different sizes (Twitter, Facebook, Apple, Google)

### Emoji.SetMaterial (Sync)

```lua
hook.Add("HUDPaint", "Emoji.png/test/Emoji.SetMaterial", function()
	surface.SetDrawColor(255, 255, 255)
	Emoji.SetMaterial("smile", "apple", 160)
	surface.DrawTexturedRect(16, 96, 160, 160)
end)
```
| Parameter | Type | Optional |
|-|-|:-:|
| name | string |  |
| provider | string |  |
| size | number |  |
| skinTone | number | ✔ |


### Emoji.GetMaterial (Async)

```lua
Emoji.GetMaterial("thumbsup", "twitter", 64, function(mat)
    hook.Add("HUDPaint", "Emoji.png/test/Emoji.GetMaterial", function()
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
