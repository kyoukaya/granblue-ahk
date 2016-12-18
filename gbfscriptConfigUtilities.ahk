;----------------------------------------------
;Global Config
;----------------------------------------------

;Pushbullet config
usePushBullet := True
PB_Token := ""
PB_Title := "GBF Bot"

;Coordinates
global attack_button_X := 470
global attack_button_Y := 470

global auto_button_X := 122 
global auto_button_Y := 503

global first_summon_X := 310
global first_summon_Y := 465

global use_item_ok_X := 373
global use_item_ok_Y := 750

global GBF_winHeight := 1150
global GBF_winWidth := 580

;Viramate skill offsets
global skillX = 92
global skillXOffset = 20
global skillCharOffset = 82
global skillY = 700

;Time intervals
global default_button_delay := 150
global post_ready_button_delay := 3000
global post_attack_button_delay := 2500
global coop_delay := 4500

global short_interval := 500
global default_interval := 750
global long_interval := 1500

;Configs
global roomJoinClicks := 5
global clickVariance := 4
global clickVarianceSmall := 2
global waitResultMax := 3

;URL Strings
global ChromeBrowsers := "Chrome_WidgetWin_0,Chrome_WidgetWin_1"
global searchMypage := "#mypage"
global searchQuestExtra := "#quest/extra"
global searchCoop := "#coopraid"
global searchCoopRoom := "#coopraid/room"
global searchBattle := "#raid"
global searchStage := "stage"
global searchSelectSummon := "supporter"
global searchResults := "result"
global searchGuildWars := "teamraid"

global coopHomeURL := "http://game.granbluefantasy.jp/#coopraid"
global coopJoinURL := "http://game.granbluefantasy.jp/#coopraid/offer"
global questURL := "http://game.granbluefantasy.jp/#quest"
global guildWarsURL := "http://game.granbluefantasy.jp/#event/teamraid"

;Offsets
global ok_button_offset_X := -20
global ok_button_offset_Y := 5
global drop_down_offset_X := 171
global drop_down_offset_Y := 54
global drop_down_offset2_X := 54
global drop_down_offset2_Y := 14
global long_ok_offset_X := -5
global long_ok_offset_Y := 5
global select_party_auto_select_offset_X := 197
global select_party_auto_select_offset_Y := 170
global summonIconType_offset_X := 2
global summonIconType_offset_Y := 2

;Search Images
global image_path := "image/"

global attack_button := "attack_button.png"

global wind_icon := "wind_icon.png"
global wind_icon_selected := "wind_icon_selected.png"
global misc_icon := "misc_icon.png"
global misc_icon_selected := "misc_icon_selected.png"

global ok_button := "ok_button.png"

global drop_down := "dropdown.png"

global select_party_auto_select := "select_party_auto_select.png"

global not_enough_ap := "not_enough_ap.png"

global long_ok := "long_ok.png"

;init
global globalTimeout := 0
global attackTurns := 0
global resultScreenCycles := 0
global battleNonActions := 0
global waitCount := 0

;----------------------------------------------
;ImageSearch wrappers
;----------------------------------------------

ImageSearchWrapper(byref searchResultX, byref searchResultY, imageFileName)
{
	searchResultX := 0
	searchResultY := 0
	
	imagePath = %image_path%%imageFileName%
	ImageSearch, searchResultX, searchResultY, 0, 0, GBF_winWidth, GBF_winHeight, *40 %imagePath%
	
	if ErrorLevel = 2
	{
		updateLog("ImageSearch could not be completed")
		return false
	}
	else if ErrorLevel = 1
	{
		updateLog(imageFileName . " was not found.")
		return false
	}
	else 
	{
		updateLog(imageFileNAme . " found at: " . searchResultX . " , " . searchResultY)
		return true
	}
}

MultiImageSearch(byref searchResultX, byref searchResultY, imageFileArray)
{
	searchResultX := 0
	searchResultY := 0

	for index, imageFileName in imageFileArray
	{
		;updateLog("Searching " . imageFileName)
		if ImageSearchWrapper(singleSearchX, singleSearchY, imageFileName)
		{
			searchResultX := singleSearchX
			searchResultY := singleSearchY
			return imageFileName
		}
	}
	return "Not Found"
}

;----------------------------------------------
;Utilities
;----------------------------------------------

updateLog(LogString)
{
	global Logbox
	FormatTime, currentTime,, hh:mm:ss
	rownumber := LV_Add("", currentTime, LogString) 
	LV_Modify(rownumber, "Vis") 
}

ResizeWin(Width = 0,Height = 0)
{
  WinGetPos,X,Y,W,H,A
  Y := 0
  If %Width% = 0
	Width := W

  If %Height% = 0
	Height := H

  WinMove,A,,%X%,%Y%,%Width%,%Height%
}

GoToPage(pageURL)
{
	coopHomeCycles := 0
	resultScreenCycles := 0	
	battleNonActions := 0
	
	Sleep, default_interval
	Send, ^l 
	Sleep, 50
	Clipboard := pageURL
	Sleep, 50
	Send, ^v
	Sleep, 50
	Send, {ENTER}
	Sleep, default_interval
	Return
}

RandomClick(coordX, coordY, variance)
{
	Random, randX, 0 - variance, variance
	Random, randY, 0 - variance, variance
	
	MouseMove coordX + randX, coordY + randY
	Sleep, 100
	Click
}

RandomClickWide(coordX, coordY, variance)
{
	Random, randX, 0 - (variance*2), (variance*2)
	Random, randY, 0 - variance, variance
	
	MouseMove coordX + randX, coordY + randY
	Click down  ; Presses down the left mouse button and holds it.
	Sleep, 3
	Click up
}

ClickSkill(character, skillNum)
{
	offset1 := (character - 1) * skillCharOffset
	offset2 := (skillNum - 1) * skillXOffset
	
	skillCoordX := skillX + offset1 + offset2
	
	updateLog("Clicking skill: " . character . "," . skillNum . " at " . skillCoordX . "," . skillY)
	
	Sleep % default_button_delay
	RandomClick(skillCoordX, skillY, clickVarianceSmall)
	Sleep % default_button_delay
}

ClickSummon(summonNumber)
{
	summonX := (summonNumber - 1) * 77
	summonY := 618

	updateLog("Clicking summon: " . summonNumber . " at " . summonX . "," . summonY)

	RandomClick(456, 616, clickVariance)
	Sleep, % default_button_delay
	RandomClick((122 + summonX), summonY, clickVariance)
	Sleep, % default_button_delay
	RandomClick(420, 589, clickVariance)
	Sleep, % default_button_delay
}

FindElementInArray(ByRef foundIndex, inputArray, findThis)
{
	for index, element in inputArray
	{
		if InStr(element, findThis)
		{
			foundIndex := index
			return foundIndex
		}
	}
	return null
}

;Pushbullet sniplet by jNizM https://autohotkey.com/boards/viewtopic.php?t=4842

PB_PushNote(PB_Token, PB_Title, PB_Message)
{
	WinHTTP := ComObjCreate("WinHTTP.WinHttpRequest.5.1")
	WinHTTP.SetProxy(0)
	WinHTTP.Open("POST", "https://api.pushbullet.com/v2/pushes", 0)
	WinHTTP.SetCredentials(PB_Token, "", 0)
	WinHTTP.SetRequestHeader("Content-Type", "application/json")
	PB_Body := "{""type"": ""note"", ""title"": """ PB_Title """, ""body"": """ PB_Message """}"
	WinHTTP.Send(PB_Body)
	Result := WinHTTP.ResponseText
	Status := WinHTTP.Status
	return Status
}

;----------------------------------------------
;Browser URL Tools
;----------------------------------------------

GetActiveChromeURL(){
	global ChromeBrowsers
	WinGetClass, sClass, A
	If sClass In % ChromeBrowsers
		Return GetBrowserURL_ACC(sClass)
	Else
		Return ""
}
 
GetActiveBrowserURL() {
	global ModernBrowsers, LegacyBrowsers
	WinGetClass, sClass, A
	If sClass In % ModernBrowsers
		Return GetBrowserURL_ACC(sClass)
	Else If sClass In % LegacyBrowsers
		Return GetBrowserURL_DDE(sClass) ; empty string if DDE not supported (or not a browser)
	Else
		Return ""
}
 
; "GetBrowserURL_DDE" adapted from DDE code by Sean, (AHK_L version by maraskan_user)
; Found at http://autohotkey.com/board/topic/17633-/?p=434518
 
GetBrowserURL_DDE(sClass) {
	WinGet, sServer, ProcessName, % "ahk_class " sClass
	StringTrimRight, sServer, sServer, 4
	iCodePage := A_IsUnicode ? 0x04B0 : 0x03EC ; 0x04B0 = CP_WINUNICODE, 0x03EC = CP_WINANSI
	DllCall("DdeInitialize", "UPtrP", idInst, "Uint", 0, "Uint", 0, "Uint", 0)
	hServer := DllCall("DdeCreateStringHandle", "UPtr", idInst, "Str", sServer, "int", iCodePage)
	hTopic := DllCall("DdeCreateStringHandle", "UPtr", idInst, "Str", "WWW_GetWindowInfo", "int", iCodePage)
	hItem := DllCall("DdeCreateStringHandle", "UPtr", idInst, "Str", "0xFFFFFFFF", "int", iCodePage)
	hConv := DllCall("DdeConnect", "UPtr", idInst, "UPtr", hServer, "UPtr", hTopic, "Uint", 0)
	hData := DllCall("DdeClientTransaction", "Uint", 0, "Uint", 0, "UPtr", hConv, "UPtr", hItem, "UInt", 1, "Uint", 0x20B0, "Uint", 10000, "UPtrP", nResult) ; 0x20B0 = XTYP_REQUEST, 10000 = 10s timeout
	sData := DllCall("DdeAccessData", "Uint", hData, "Uint", 0, "Str")
	DllCall("DdeFreeStringHandle", "UPtr", idInst, "UPtr", hServer)
	DllCall("DdeFreeStringHandle", "UPtr", idInst, "UPtr", hTopic)
	DllCall("DdeFreeStringHandle", "UPtr", idInst, "UPtr", hItem)
	DllCall("DdeUnaccessData", "UPtr", hData)
	DllCall("DdeFreeDataHandle", "UPtr", hData)
	DllCall("DdeDisconnect", "UPtr", hConv)
	DllCall("DdeUninitialize", "UPtr", idInst)
	csvWindowInfo := StrGet(&sData, "CP0")
	StringSplit, sWindowInfo, csvWindowInfo, `" ;"; comment to avoid a syntax highlighting issue in autohotkey.com/boards
	Return sWindowInfo2
}
 
GetBrowserURL_ACC(sClass) {
	global nWindow, accAddressBar
	If (nWindow != WinExist("ahk_class " sClass)) ; reuses accAddressBar if it's the same window
	{
		nWindow := WinExist("ahk_class " sClass)
		accAddressBar := GetAddressBar(Acc_ObjectFromWindow(nWindow))
	}
	Try sURL := accAddressBar.accValue(0)
	If (sURL == "") {
		WinGet, nWindows, List, % "ahk_class " sClass ; In case of a nested browser window as in the old CoolNovo (TO DO: check if still needed)
		If (nWindows > 1) {
			accAddressBar := GetAddressBar(Acc_ObjectFromWindow(nWindows2))
			Try sURL := accAddressBar.accValue(0)
		}
	}
	If ((sURL != "") and (SubStr(sURL, 1, 4) != "http")) ; Modern browsers omit "http://"
		sURL := "http://" sURL
	If (sURL == "")
		nWindow := -1 ; Don't remember the window if there is no URL
	Return sURL
}
 
; "GetAddressBar" based in code by uname
; Found at http://autohotkey.com/board/topic/103178-/?p=637687
 
GetAddressBar(accObj) {
	Try If ((accObj.accRole(0) == 42) and IsURL(accObj.accValue(0)))
		Return accObj
	Try If ((accObj.accRole(0) == 42) and IsURL("http://" accObj.accValue(0))) ; Modern browsers omit "http://"
		Return accObj
	For nChild, accChild in Acc_Children(accObj)
		If IsObject(accAddressBar := GetAddressBar(accChild))
			Return accAddressBar
}
 
IsURL(sURL) {
	Return RegExMatch(sURL, "^(?<Protocol>https?|ftp)://(?<Domain>(?:[\w-]+\.)+\w\w+)(?::(?<Port>\d+))?/?(?<Path>(?:[^:/?# ]*/?)+)(?:\?(?<Query>[^#]+)?)?(?:\#(?<Hash>.+)?)?$")
}
 
; The code below is part of the Acc.ahk Standard Library by Sean (updated by jethrow)
; Found at http://autohotkey.com/board/topic/77303-/?p=491516
 
Acc_Init()
{
	static h
	If Not h
		h:=DllCall("LoadLibrary","Str","oleacc","Ptr")
}
Acc_ObjectFromWindow(hWnd, idObject = 0)
{
	Acc_Init()
	If DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject&=0xFFFFFFFF, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
	Return ComObjEnwrap(9,pacc,1)
}
Acc_Query(Acc) {
	Try Return ComObj(9, ComObjQuery(Acc,"{618736e0-3c3d-11cf-810c-00aa00389b71}"), 1)
}
Acc_Children(Acc) {
	If ComObjType(Acc,"Name") != "IAccessible"
		ErrorLevel := "Invalid IAccessible Object"
	Else {
		Acc_Init(), cChildren:=Acc.accChildCount, Children:=[]
		If DllCall("oleacc\AccessibleChildren", "Ptr",ComObjValue(Acc), "Int",0, "Int",cChildren, "Ptr",VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*",cChildren)=0 {
			Loop %cChildren%
				i:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,i), Children.Insert(NumGet(varChildren,i-8)=9?Acc_Query(child):child), NumGet(varChildren,i-8)=9?ObjRelease(child):
			Return Children.MaxIndex()?Children:
		} Else
			ErrorLevel := "AccessibleChildren DllCall Failed"
	}
}
