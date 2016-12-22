; Testing environment
; Browser: Chromium 52
; Language: English
; Animation/Resolution Settings = [Animation Settings : "Standard", Resolution Settings : "High"]
; Browser Version Settings = [Automatic Resizing : "Off", Window Size : "Medium"]

#Include gbfscriptConfigUtilities.ahk

SetTimer, ForceExitApp, 3600000 ; 1h

CoordMode Pixel, Relative
CoordMode Mouse, Relative

global maxBattleNonActions := 20
global maxWaitCount := 5 ;Timeout for quest screen
global globalTimeoutMax := 80 ;Set to a bit more than what 1 cycle would take, it'll be considered a time out if we exceed this
global maxRounds := 0 ;Set to 0 to disable maxround shutdown

global searchURL := "" ;This is the home URL, where we'll look for the quest to be started and where we'll return if lost

global summonIconType := misc_icon ;You'll need to change the summon icons if you're not using viramate's favourites. Somehow using it makes the icons render differently.
global summonIconTypeSelected := misc_icon_selected 

global selectOne := ""
global selectTwo := ""
global selectOne_X :=
global selectOne_Y :=
global selectTwo_X :=
global selectTwo_Y :=

global genericActions := [selectOne, selectTwo, long_ok, drop_down]
global battleActions := [attack_button, ok_button]

Gui, Add, ListView, x6 y6 w400 h500 vLogbox LVS_REPORT, %A_Now%|Activity
	LV_ModifyCol(1, 60)
	GuiControl, -Hdr, Logbox
	Gui, Show, w410 h505, GBF Bot Log

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
			updateLog("Push sent, status: " . PB_PushNote(PB_Token, PB_Title, "Warning, bot timed out"))
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
					;SetOugi(bool) ;True for ougi False for nah
					;UsePot(int) ;0 for blue, 1-4 for green pots on characters

					;ClickSummon(int)

					;ClickSkill([11,12,123]) ;ClickSkill now takes a 2/3 digit integer, or an array of them!

					;UseSticker(phalanx_sticker) ;Phalanx!

					RandomClickWide(attack_button_X, attack_button_Y, clickVariance)
					
					Sleep, % post_attack_button_delay

					;RandomClick(auto_button_X, auto_button_Y, clickVariance)

					;Sleep, post_ougi_delay
					;Send, {F5}
				}

				else if (attackTurns >= 1)
				{
					;If we're autoing, we shouldn't be able to get here, but we'll just try to attack
					updateLog("Battle sequence, battle turn count = " . attackTurns)

					attackTurns := attackTurns + 1
					battleNonActions := 0
					
					RandomClickWide(attack_button_X, attack_button_Y, clickVariance)

					Sleep, % post_attack_button_delay
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

			if InStr(searchResult, selectOne)
			{
				updateLog("Quest icon detected, clicking")
				waitCount := 0
				RandomClick(coordX + selectOne_X, coordY + selectOne_Y, clickVariance)
			}

			else if InStr(searchResult, selectTwo)
			{
				updateLog("Clicking quest")
				waitCount := 0
				RandomClick(coordX + selectTwo_X, coordY + selectTwo_Y, clickVariance)
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
					PB_Message := "Target of " . maxRounds . " reached. Shutting down."
					updateLog("Push sent, status: " . PB_PushNote(PB_Token, PB_Title, PB_Message))
				}				
				Sleep, 10000
				ExitApp
			}

			else if (timerElapsed = 1)
			{
				if (usePushBullet = True)
				{
					updateLog("Push sent, status: " . PB_PushNote(PB_Token, PB_Title, "Time elapsed. " . curRound . " rounds completed. Shutting down."))
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

F12::Pause

GuiClose:
ExitApp

Esc::
ExitApp

ForceExitApp:
SetTimer,  ForceExitApp, Off
timerElapsed := 1
Return