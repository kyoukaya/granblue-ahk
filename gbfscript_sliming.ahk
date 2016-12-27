; Testing environment
; Browser: Chromium 52
; Language: English
; Animation/Resolution Settings = [Animation Settings : "Standard", Resolution Settings : "High"]
; Browser Version Settings = [Automatic Resizing : "Off", Window Size : "Medium"]

; Needs stylish to disable the button animations with css to use this script
; .btn-quest-start.multi.se-quest-start,.btn-execute-ready.se-ok{-webkit-animation:normal!important;}

; Automates most of the sliming process, you'll need to select a summon first
; Uses viramate's last hosted to select the quest
; The script starts paused to allow some time for setting up, just press F12 to start it up when you're ready to go
; F2 can can be used to forcefully toggle between hosting and not-hosting

#Include gbfscriptConfigUtilities.ahk

SetTimer, ForceExitApp, 3600000 ; 1h
SetTimer, CoopPhase, 1000

CoordMode Pixel, Relative
CoordMode Mouse, Relative

;In mins, in order :[leech,host,leech] i.e. [0,15,45] if you're hosting first
;You can just set the first value to 60+ if you want to manually toggle host/leech mode
;Good to set a bit more than 60 so it doesn't flipflop between host/leech
global host_order := [0,0,45] 

global maxBattleNonActions := 10
global maxWaitCount := 7 ;Timeout for quest screen
global globalTimeoutMax := 60 ;Set to a bit more than what 1 cycle would take, it'll be considered a time out if we exceed this
global maxRounds := 0 ;Set to 0 to disable maxround shutdown

global searchURL := "http://game.granbluefantasy.jp/#coopraid" ;This is the home URL, where we'll look for the quest to be started and where we'll return if lost

global summonIconType := misc_icon ;You'll need to change the .pngs if you're not using viramate's favourites. Somehow using it makes the icons render differently.
global summonIconTypeSelected := misc_icon_selected 

;init
global is_hosting := 1

global selectOne := "coop_lasthosted.png"
global selectTwo := "coop_start.png" 
global selectThree := "coop_ready.png"
global selectOne_X := -15
global selectOne_Y := 0
global selectTwo_X := 0
global selectTwo_Y := 0
global selectThree_X := 0
global selectThree_Y := 2

global genericActions := [selectOne, selectTwo, selectThree, long_ok, drop_down]
global battleActions := [attack_button, ok_button]

Gui, Add, ListView, x6 y6 w400 h500 vLogbox LVS_REPORT, %A_Now%|Activity
	LV_ModifyCol(1, 60)
	GuiControl, -Hdr, Logbox
	Gui, Show, w410 h505, GBF Bot Log

updateLog("[F1] Resize window [F2] Start/Pause [Esc] Exit")
updateLog("[F3] Switch between hosting hosting/leeching ")
Pause

;----------------------------------------------
;Main Loop
;----------------------------------------------

Loop
{
	Sleep, % default_interval
	globalTimeout := globalTimeout + 1

	if (globalTimeout >= globalTimeoutMax)
	{
		updateLog("Timed out. Refreshing page.")

		if (usePushBullet = True)
		{
			updateLog("Push sent, status: " . PB_PushNote("Warning, bot timed out"))
		}

		globalTimeout := 0
		Send, {F5}
		Continue
	}

	sURL := GetActiveChromeURL()
	WinGetClass, sClass, A

	If (sURL != "")
	{
		if InStr(sURL, searchBattle)
		{
			updateLog("-----In Battle-----")
			searchResult := multiImageSearch(coordX, coordY, battleActions)

			if InStr(searchResult, attack_button)
			{
				if (attackTurns = 0)
				{
					;First turn actions
					updateLog("Battle sequence, battle turn count = " . attackTurns)

					attackTurns := attackTurns + 1
					battleNonActions := 0

					;ClickSummon(6)

					ClickSkill(11) ;ClickSkill now takes a 2/3 digit integer, or an array of them!

					UseSticker(phalanx_sticker) ;Phalanx!

					Sleep, default_interval

					CheckSkill(11) 

					Send, {F5}
				}

				else if (attackTurns >= 1)
				{
					updateLog("Battle sequence, battle turn count = " . attackTurns)			

					Sleep, default_interval
					CheckSkill(11) 
					Send, {F5}
				}

				else
				{
					;Fallback action for our turn
					Send, {F5}
				}
			}
			
			else if InStr(searchResult, ok_button)
			{
				;Try to handle network errors etc.
				updateLog("Wild OK button has appeared, clicking")
				RandomClick(coordX + ok_button_offset_X, coordY + ok_button_offset_Y, 0)
			}

			else
			{
				updateLog("Battle action not taken, battle non action count = " . battleNonActions)
				
				if (battleNonActions >= maxBattleNonActions) ; Comment out this statement if you're autoing
				{
					Send, {F5} ;It's been awhile since we could see our attack button so we're refreshing
					battleNonActions := 0
				}
				else
				{
					battleNonActions := battleNonActions + 1
				}
			}
			continue
		}

		else if InStr(sURL, searchSelectSummon)
		{
			updateLog("-----In Select Summon-----")			
			waitCount = 0			
			selectSummonAutoSelect := [select_party_auto_select, summonIconType, summonIconTypeSelected]
			searchResult := multiImageSearch(coordX, coordY, selectSummonAutoSelect)
			
			if InStr(searchResult, select_party_auto_select)
			{
				updateLog("Party Confirm detected, clicking OK button")
				RandomClick(coordX + select_party_auto_select_offset_X, coordY + select_party_auto_select_offset_Y, clickVariance) 
				continue
			}

			else if InStr(searchResult, summonIconType)
			{
				updateLog("Clicking on summon icon")
				RandomClick(coordX + summonIconType_offset_X, coordY + summonIconType_offset_Y, clickVariance)
			}

			else if InStr(searchResult, summonIconTypeSelected)
			{
				updateLog("Clicking on first summon")
				RandomClick(first_summon_X, first_summon_Y, clickVariance)
			}
			continue
		}
		
		else if InStr(sURL, searchURL)
		{
			updateLog("-----In Quest Select Screen-----")
			Sleep, % default_interval			
			searchResult := multiImageSearch(coordX, coordY, genericActions)

			if InStr(searchResult, selectOne) and (is_hosting = 1)
			{
				updateLog("Clicking last hosted")
				waitCount := 0
				RandomClick(coordX + selectOne_X, coordY + selectOne_Y, clickVariance)
			}

			else if InStr(searchResult, selectTwo)
			{
				updateLog("Clicking start")
				waitCount := 0
				RandomClick(coordX + selectTwo_X, coordY + selectTwo_Y, clickVariance)
			}

			else if InStr(searchResult, selectThree)
			{
				updateLog("Clicking ready")
				waitCount := 0
				RandomClick(coordX + selectThree_X, coordY + selectThree_Y, clickVariance)
			}

			else if InStr(searchResult, drop_down)
			{ 
				updateLog("Not Enough AP dialog found, clicking Use button")
				waitCount := 0
				RandomClick(coordX + drop_down_offset_X, coordY + drop_down_offset_Y, clickVariance)

				Sleep, long_interval

				RandomClick(coordX + drop_down_offset2_X, coordY + drop_down_offset2_Y, clickVariance)
			}

			else if InStr(searchResult, ok_button)
			{
				updateLog("Wild OK button has appeared, clicking")
				RandomClick(coordX + ok_button_offset_X, coordY + ok_button_offset_Y, 0)
			}

			else 
			{
				if(waitCount >= maxWaitCount)
				{
					updateLog("Waited long enough, lets reload")
					Sleep, % default_delay
					waitCount := 0
					GoToPage(searchURL)
				}
				else
				{
					updateLog("Nothing was found")
					
					waitCount := waitCount + 1
				}
			}

			continue
		}
		else if InStr(sURL, searchResults)
		{
			updateLog("-----In Results Screen-----")
			attackTurns := 0
			globalTimeout := 0
			battleNonActions := 0
			
			resultScreenCycles := resultScreenCycles + 1
			curRound += 1

			if (maxRounds > 0) and (curRound >= maxRounds)
			{
				if (usePushBullet = True)
				{
					updateLog("Push sent, status: " . PB_PushNote("Target of " . maxRounds . " reached. Shutting down."))
				}				
				Sleep, 10000
				ExitApp
			}

			else if (timerElapsed = 1)
			{
				if (usePushBullet = True)
				{
					updateLog("Push sent, status: " . PB_PushNote("Time elapsed. " . curRound . " rounds completed. Shutting down."))
				}
				Sleep, long_interval
				ExitApp
			}
			
			Sleep, results_delay
			updateLog("Going to quest select page")
			GoToPage(searchURL)
			continue
		}

		else if InStr(sURL, topPage)
		{
			;Probably have to resize the screen with f1 to get this to work in this state
			updateLog("We're at top page, clicking continue")
			Sleep, short_interval
			RandomClick(207, 195, clickVariance)
		}
		
		else if InStr(sURL, authPage)
		{
			;Primitive routine for clicking the mobage icon
			updateLog("We're at auth page, clicking the mobage button")
			Sleep, short_interval			
			RandomClick(199, 197, clickVariance)
		}

		else
		{
			updateLog("Huh? We're at " . sURL)
			GoToPage(searchURL)
			continue
		}
	}
	Else
		updateLog("Chrome not detected (" . sClass . ")")
}
Return

;----------------------------------------------
;Keybinds
;----------------------------------------------

F1::
updateLog("Resizing window to " . GBF_winWidth . " x " . GBF_winHeight)
ResizeWin(GBF_winWidth, GBF_winHeight)
Return

F2::
if (is_hosting = 0)
{
	is_hosting := 1
}
else if (is_hosting = 1)
{
	is_hosting := 0 
}
Return

F12::Pause

GuiClose:
ExitApp

Esc::
ExitApp

ForceExitApp:
SetTimer,  ForceExitApp, Off
timerElapsed := 1
Return

CoopPhase:
if (is_hosting = 0)
{
	is_hosting := 1
}
else if (is_hosting = 1)
{
	is_hosting := 0 
}
next_phase_length := host_order.RemoveAt(1) * 1000 * 60
updateLog("Next phase length " . next_phase_length . ". Is hosting " . is_hosting)
SetTimer, CoopPhase, % next_phase_length
Return
