# Emoji.lua - a way to add emotions in your Gmod UI
<img alt="Visitors" src="https://visitor-badge.laobi.icu/badge?page_id=Be1zebub.Emoji.lua"/> 

#### Features:
> The entire library is in one short file you only need to download 1 lua file   
> Content downloading only on request (your players dont need to download a lot of useless emojis that they will never see)  
> Comfy receipt of emojis by name (as in discord / Twitter)  
> Synchronous and asynchronous functions  
> Any combination of skin tones  
> Various emoji providers with different sizes (Twitter, Facebook, Apple, Google)

#### How it looks in game:
![Preview](https://raw.githubusercontent.com/Be1zebub/Emoji.lua/main/preview/ingame.png)  

### Emoji.SetMaterial (Sync)

```lua
hook.Add("HUDPaint", "Emoji.lua/test/Emoji.SetMaterial", function()
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
    hook.Add("HUDPaint", "Emoji.lua/test/Emoji.GetMaterial", function()
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

### Skin-tones preview
![skin-tones Preview](https://raw.githubusercontent.com/Be1zebub/Emoji.lua/main/preview/skin_tones.png)  
*you can also mix skin-tones of some emojis*
*example:*
```lua
Emoji.SetMaterial("couple", "twitter", 64, 9)
```
![skin-tones mix preview](https://raw.githubusercontent.com/Be1zebub/Emoji.lua/main/emoji/twitter-64/1f469-1f3fb-200d-1f91d-200d-1f468-1f3fd.png)  

###### todo:
- [ ] zwj support
- [ ] noto emoji support
- [ ] joypixels (aka emojione) emoji support
- [ ] windows (10 & 11) emoji support
