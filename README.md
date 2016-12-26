# granblue-ahk

middle school coding project adapted from https://github.com/UmaiCake/gravel-things
**Needs viramate**

## Tested on:
* http://game.granbluefantasy.jp
* Monitor Resolution = 1080p/1440p DPI scaling 100% (Press F1 while the script is running to resize the window correctly)
* Browser = Chromium 52 (Bookmark toolbar turned off)
* Language = English
* Animation/Resolution Settings = [Animation Settings : "Standard", Resolution Settings : "High"]
* Browser Version Settings = [Automatic Resizing : "Off", Window Size : "Medium"]
* Viramate Settings = [Show skill cooldowns in main view : "Off", Show larger skill buttons : "Off", Show quick skill buttons : "On"]

## How it works:
1. Quest Selection Page - From the quest page, the script searches for images (selectOne,selectTwo) and then clicks on them or at an offset (selectOne_X / Y etc.).
2. Summon Selection Phase - Upon entering the summon selection page, it looks for the summon icon of your choosing if it's not activated (summonIconType) and clicks it so that it becomes activated (summonIconTypeSelected). Once the icon is activated it clicks on a coordinate (first_summon_X / Y) to choose the summon. Once the summon is chosen, it searches for the party auto select icon (selectSummonAutoSelect) and uses an offset (select_party_auto_select_offset_X / Y) to click the OK button.
3. Battle Phase - There's a number of ways to customize the battle phase, actions can however only be performed based on turns passed and if the result screen is skipped the turn counter gets messed up. See gbfscript_generic.ahk or gbfscript_explus.ahk on some examples.
4. Result Phase - The script counts up on the rounds completed and can stop based on maxRounds or when the timer (ForceExitApp) has elapsed

## Why doesn't it work:
If you have the exact same settings, CSS hacks, and resolution, it should work. But different versions of webkit and hence chrome tend to render images slightly different so you might need to recapture the images when the script can't find it. The offsets should be all the same unless you disable the black bar at the side, have Chrome's bookmark toolbar enabled, or are using Window's DPI scaling (its shitty anyway dont use it).
AHK is pretty simple so you should be able to fix it yourself.

## Todo
* Not use counters to timeout stuff that's pretty dumb
* Not use AHK
