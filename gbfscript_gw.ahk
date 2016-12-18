; Testing environment
; Browser: Chromium 52
; Language: English
; Animation/Resolution Settings = [Animation Settings : "Standard", Resolution Settings : "Standard"]
; Browser Version Settings = [Automatic Resizing : "Off", Window Size : "Medium"]

#Include gbfscriptConfigUtilities.ahk

SetTimer, ForceExitApp, 3600000 ; 1h

CoordMode Pixel, Relative
CoordMode Mouse, Relative

global maxBattleNonActions := 20
global maxWaitCount := 7 ;Timeout for quest screen
global globalTimeoutMax := 80 ;Set to a bit more than what 1 cycle would take, it'll be considered a time out if we exceed this
global post_attack_button_delay := 5000

global searchURL := "http://game.granbluefantasy.jp/#event/teamraid026" ;This is the home URL, where we'll look for the quest to be started and where we'll return if lost

global summonIconType := misc_icon ;Summons shouldn't be broken by viramate's favourite summons settings. Probably.
global summonIconTypeSelected := misc_icon_selected 

global selectOne := "meat1.png"
global selectTwo := "meat2.png"
global selectOne_X := 0
global selectOne_Y := 0
global selectTwo_X := 0
global selectTwo_Y := 0

global genericActions := [selectOne, selectTwo, long_ok, drop_down]

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
			updateLog("Push sent, status: " . PB_PushNote(PB_Token, PB_Title, "Bot timed out"))
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
			battleActions := [attack_button, ok_button]
			searchResult := multiImageSearch(coordX, coordY, battleActions)

			if InStr(searchResult, attack_button)
			{
				if (attackTurns = 0)
				{
					;First turn actions
					updateLog("Battle sequence, battle turn count = " . attackTurns)

					attackTurns := attackTurns + 1

					;ClickSummon(6)

					ClickSkill(4,3)
					ClickSkill(3,1)
					ClickSkill(4,2)
					ClickSkill(2,2)
					ClickSkill(1,4)
					ClickSkill(1,3)
					ClickSkill(1,2)

					RandomClickWide(attack_button_X, attack_button_Y, clickVariance)
					
					Sleep, % post_attack_button_delay

					;RandomClick(auto_button_X, auto_button_Y, clickVariance)
				}

				else if (attackTurns >= 1)
				{
					;If we're autoing, we shouldn't be able to get here, but we'll just try to attack
					updateLog("Battle sequence, battle turn count = " . attackTurns)

					attackTurns := attackTurns + 1
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

			Send {WheelUp}
			
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

				Sleep, default_interval

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
			
			updateLog("Results Screen cycles: " . resultScreenCycles)		
			if(resultScreenCycles >= waitResultMax)
			{
				resultsScreenCycles := 0
				updateLog("Going to quest select page")
				GoToPage(searchURL)
			}
			continue
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
if (usePushBullet = True)
{
	updateLog("Push sent, status: " . PB_PushNote(PB_Token, PB_Title, "Time elapsed. Shutting down."))
}
ExitApp