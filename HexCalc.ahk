;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Card Information Calculator:                        ;;
;; Hexidecimal conversion tool with bit-mask extractor ;;
;; By Adam Margeson (digimystigi) v2.0.0               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


#SingleInstance force		; Automatically restart if relaunched
#NoTrayIcon
#NoEnv						; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%	; Ensures a consistent starting directory.

;; Import Scientific MATHS LIBRARY by by Avi Aryan http://aviaryan.in/ahk/
;; Availalble at https://github.com/avi-aryan/Avis-Autohotkey-Repo/blob/master/Functions/Maths.ahk
#Include %A_ScriptDir%\Maths.ahk

;; Import GroupBox creation function
#Include %A_ScriptDir%\GroupBox.ahk

If !A_IsCompiled ; If the program is compiled, skip some checks
{
	FileGetTime, ModTime, %A_ScriptFullPath%, M
	SetTimer, CheckTime, 1000

	SetTitleMatchMode, 3 ; Set to "Exact Match" so as to not close VSCode
	GroupAdd, er, %A_ScriptName%
	WinClose, ahk_group er
	SetTitleMatchMode, 1 ; return to default mode (Start With...)
}
Else
{
	;; Splash Screen
	HexCalcPng := LoadPicture("C:\Users\Adam\Code\Card-Information-Calculator\hexcalc.png")
	Gui, Splash:New, +ToolWindow, Card Format Tools
	Gui, Splash:Add, Picture, X12 Y9 W410 H508, HBITMAP:%HexCalcPng%
	Gui, Splash:Show, W432 H524
	Sleep 3000
	Gui, Splash:Destroy
}

;; void main(): // Start the program
GoTo HexCalcGui
Return


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start of GUI creation ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
HexCalcGui:
	;;;;; Create the window in memory ;;;;;
	/*
		Using CIC: as AutoHotKey does not pass
		window references to other GoSub labels well.
		Attaching a name allows it to reference properly.
	*/
	Gui, CIC:New, +MinimizeBox -MaximizeBox -Resize +Theme, Card Format Tools
	Gui, CIC:Default ; Set CIC as default to make furhter programming easier
	
	;;;; Create the tabs for the different functions ;;;;
	Gui, Add, Tab3, AltSubmit vCICTabs,Card Information Calculator|History|Format Calculator
	Gui, Tab, 1

	;;; Start the Card Information Calculator tab ;;;
	EditW := 48
	Padding := 16
	LabelSpace := EditW + Padding
	
	;; Raw Data field ;;
	Gui, Add, Text, Section y+11, Raw Data:
	Gui, Add, Edit, yp-4 xs+96 w238 r1 vRawData Uppercase,
	Gui, Add, Button, yp-1 x+1 w18 h23 gInvertRawData,!

	;; Format selection dropdown ;;
	Gui, Add, Text, yp+30 xs, Format:
	Gui, Add, DropDownList, yp-4 xs+96 w256 gSelFormat vCFormat AltSubmit, |

    ;; Card Length field ;;
	Gui, Add, Text, yp+30 xs, Card Length:
	Gui, Add, Edit, yP-3 xs+96 r1 w%EditW% Number vCLength
	Gui, Add, UpDown, Range20-200 vCardLength, 37

	;; Start Table ;;
	; Start/Length Labels ;
	Gui, Add, Text, yp+26 xs+96 vFStart, Start 
	Gui, Add, Text, yp  xp+%LabelSpace% vFLength, Length
	Gui, Add, Text, yp  xp+%LabelSpace% Disabled vFEnd, End

	; Card Number label and fields ;
	Gui, Add, Text, yp+20 xs vCN1, Card Number:
	Gui, Add, Edit, yp-3 xs+96 w%EditW% Number gUpdateTable vCNStart
	Gui, Add, Edit, yp x+%Padding% w%EditW% Number gUpdateTable vCNLength
	Gui, Add, Edit, yp x+%Padding% w%EditW% Number Disabled vCNEnd

	; Facility Code label and fields ;
	Gui, Add, Text, yp+28  xs vFC1, Facility Code:
	Gui, Add, Edit, yp-3  xs+96 w%EditW% Number gUpdateTable vFCStart
	Gui, Add, Edit, yp  x+%Padding% w%EditW% Number gUpdateTable vFCLength
	Gui, Add, Edit, yp x+%Padding% w%EditW% Number Disabled vFCEnd

	; Issue Code label and fields ;
	Gui, Add, Text, yp+28  xs vIC1, Issue Code:
	Gui, Add, Edit, yp-3 xs+96 w%EditW% Number gUpdateTable vICStart
	Gui, Add, Edit, yp x+%Padding% w%EditW% Number gUpdateTable vICLength
	Gui, Add, Edit, yp x+%Padding% w%EditW% Number Disabled vICEnd
	
	; Create the GroupBox around the Card Format table.  format_gb_items is the list of controls
	format_gb_items := "CN1|FC1|IC1|x_FStart|x_FLength|x_FEnd|x_CNStart|x_CNLength|x_FCStart|x_FCLength|x_ICStart|x_ICLength|x_CNEnd|x_FCEnd|x_ICEnd"
	GroupBox("FormatTable", "Card Format Options", format_gb_items)
	
	;; ToDo: Add Parity Checking

	; Button to calculate the data ;
	Gui, Add, Button, Default y+8 xs+95 W258 vCICSubmit, Extract Data

	; Results ;
	Gui, Add, Text, y+8 xs vCNr, Card Number:
	Gui, Add, Edit, yp-4 xs+96 w246 ReadOnly vCardNumber

	Gui, Add, Text, yp+28 xs vFCr, Facility Code:
	Gui, Add, Edit, yp-4 xs+96 w246 ReadOnly vFacilityCode

	Gui, Add, Text, yp+28 xs vICr, Issue Code:
	Gui, Add, Edit, yp-4 xs+96 w246 ReadOnly vIssueCode
	
	gb_results := "CNr|FCr|ICr|x_CardNumber|x_FacilityCode|x_IssueCode"
	GroupBox("Results", "Results", gb_results)

	;;; Start the History tab ;;;
	Gui, Tab, 2
	lv_columns := "Raw Data|Card Number|Facility Code|Issue Code|Format"
	
	Gui, Add, ListView, W350 H330 ReadOnly, %lv_columns%
	LV_ModifyCol(1,131)
	LV_ModifyCol(2,75)
	LV_ModifyCol(3,75)
	LV_ModifyCol(4,65)
	LV_ModifyCol(5, 0)

	; Add example history item (Initialize the tab)
	LV_Add(,"135E50540A",10757,40,"")


	;;; Start Format Calculator tab ;;;
	Gui, Tab, 3

	Gui, Font,, Courier New
	Gui, Font, S10 , Lucida Console
	Gui, Add, Text, y+11 Section,
	(
	Legend:
	P = Parity Bit
	F = Facility Code
	C = Card Format
	. = Unknown bit/Not used
	)
	Gui, Font
	Gui, Add, Text,, Field order, top to bottom: Format Bits, Even Parity, Odd Parity`nExample provided is HID's I10304 format.
	Gui, Font,, Courier New
	Gui, Font, S10 , Lucida Console
	GuiControlGet, CICTabs, POS

	; FCalcW := CICTabsW
	Gui, Add, Edit, y+8 vFCFormatD w350 -wrap UpperCase, P.............FFFFFFCCCCCCCCCCCCCCCCP
	Gui, Add, Edit, y+2 vFCEParity wp UpperCase, EPPPPPPPPPPPPPPPPPP..................
	Gui, Add, Edit, y+2 vFCOParity wp UpperCase, ..................PPPPPPPPPPPPPPPPPPO
	Gui, Font
	Gui, Add, Button, y+4 vCFSubmit, Calculate Format
	Gui, Add, Text, y+16 xs, Card Number:
	Gui, Add, Text, yp xs+96 vCNPos, Test
	Gui, Add, Text, xs, Facility Code:
	Gui, Add, Text, yp xs+96 vFCPos, Test
	Gui, Add, Text, xs, Issue Code:
	Gui, Add, Text, yp xs+96 vICPos, Test
	Gui, Add, Text, xs, Even Parity:
	Gui, Add, Text, yp xs+96 vEPPos, Test
	Gui, Add, Text, xs, Odd Parity:
	Gui, Add, Text, yp xs+96 vOPPos, Test

	GoSub InitializeCardFormats
	;; Now that the GUI is layed out in memory, show it to the user
	Gui, CIC:Show, AutoSize
	
	;~ OnMessage(0x200, "Help")

	; Initialize the Tabs and the History columns
	GuiControlGet, CICTabs, POS
	CICTabsW -= 24
	GuiControl, Move, FCFormatD, W%CICTabsW%
	GuiControl, Move, FCEParity, W%CICTabsW%
	GuiControl, Move, FCOParity, W%CICTabsW%
	GuiControl, Move, Submit2,   W%CICTabsW%

	; Initialize Tab1e
	GuiControl, Choose, CFormat, |12 ; 
	GuiControl,, RawData, 135E50540A
	GoSub, UpdateTable
	GuiControl, Focus, RawData
	Send {Home}+{End}
Return ; RealGui

Help(wParam, lParam, Msg) {
	static prevControl
	MouseGetPos,,,, OVC ; Originally named: OutputVarControl
	
	StringCaseSense, Off
	Switch OVC
	{
		Case "Button1":
			Help := "Binary Invert:`n`nCheck to see if your data wires are backwards...`nClick this to swap all the zeros and ones in your`nraw card data, as if you swapped data wires.  If the`nCard information calculated below doesn't match`nup with what you expect for your card, try this."
		Case "Edit1", "Static1":
			Help := "Please enter the raw card data in Hexidecimal format"
		Case "Edit3", "Edit6", "Edit9":
			Help := "This tool treats the first bit as 'Bit 0' instead of 'Bit 1'`nFor example, the default 37-bit format references bits 0 through 36.`nBe wary when coming from tools or systems that use 'Bit 1' as the first bit."
		Default:
			;Help := "Control: " . OVC  ; Debug code to show unused control names as ToolTips
	}

	If prevControl != %OVC% ; Display once and hold.  Prevents continuous refresh which causes multi-line ToolTips to flicker
	{
		If (Help = "")  ; To immediately clear the ToolTip when exiting the control
			ToolTip
		Sleep 250
		ToolTip % Help
	}
	prevControl := OVC
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialize the Card Formats ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
InitializeCardFormats:
	Gui, CIC:Default
	global Fmt := Object() ;; Initialize the Card Format array

	/* Fmt layout:
	
	CardLength:		Length of the overall Card Format
	CNStart:		Start bit of the Card Number
	CNLength:		Number of bits in the Card Number
	FCStart:		Start bit of the Facility Code
	FCLength:		Number of bits in the Facility Code
	ICStart:		Start bit of the Issue Code
	ICLength:		Number of bits in the Issue Code
	EPStart:		Start bit of the Even Parity Check
	EPLength:		Number of bits in the Even Parity Check
	EPBit:			Location of the Even Parity Check Bit
	OPStart:		Start bit of the Odd Parity Check
	OPLength:		Number of bits in the Odd Parity Check
	OPBit:			Location of the Odd Parity Check Bit

	*/
	
	formatFile := "Formats.ini"
	definedFields := ["CardLength", "CNStart", "CNLength", "FCStart", "FCLength", "ICStart", "ICLength", "EPStart", "EPLength", "EPBit", "OPStart", "OPLength", "OPBit"]

	if( FileExist(formatFile) ) {
		; Read the section names
		IniRead, sections, %formatFile%
		
		; If the file is not empty
		if( StrLen( sections ) ) {
			; Split up the section titles into an array
			secArray := StrSplit(sections, "`n")
			
			
			GuiControl,, CFormat, |Custom
			
			; For each section
			for i, format in secArray {
				; Add the format title to dropdown
				GuiControl,, CFormat, %format%
				structure := [] ; Initialize the temporary structure variable
				
				; For each field in the format...
				for j, fieldName in definedFields {
					; Read the value
					try {
						IniRead, fieldValue, %formatFile%, %format%, %fieldName%
						if (fieldValue = "ERROR") {
							throw {	what: "INIRead in InitializeCardFormats", message: "Invalid or missing format data:`nFormat: " . format . "`nField: " . fieldName, file: A_LineFile,line: A_LineNumber }
						}
					}
					catch, e
					{
						MsgBox % e.what
						MsgBox % e.message
						ExitApp
					}
					; ... and insert into the temporary structure variable
					structure.Insert(fieldValue)
				}
				; Add the new format into the list of formats
				Fmt.Insert(structure)
			}
		} else {
			MsgBox, Empty File!`nToDo: Create default file.
			GoSub, CreateDefaultConfigFile
		}
	} else {
		MsgBox, Doesn't Exist!  Creating.
		GoSub, CreateDefaultConfigFile
	}

Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; When Card Format is selected ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SelFormat:
	Gui, CIC:Default
	Gui, Submit, NoHide ;; Retrieve current Card Format selection

	fmtFields := StrSplit("CardLength, CNStart, CNLength, FCStart, FCLength, ICStart, ICLength", ", ")

	;; Set the form to the correct data for the new selection
	for index in fmtFields
	{
		vField := fmtFields[index]  ;; Select the field name
		vValue := Fmt[CFormat-1][index]  ;; Get the associated value for that field
		SetEnv, %vField%, Fmt[CFormat-1][index]  ;; Set the field name var to the associated value

		IfNotEqual, CFormat, 1 ;; If the format is not "Custom"
		{
			GuiControl, Disable, %vField%
			GuiControl,, %vField%, %vValue%  ;; Set the field itself to the associated value
		}
		Else	{
			GuiControl, Enable, %vField%
		}
	}
	; Disable editing of Card Length field for included formats
	GuiControl, % (CFormat-1 ? "Disable" : "Enable"), CLength
	GoSub UpdateTable
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set whether each "Start" field is enabled ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UpdateTable:
	Gui, CIC:Default
	Gui, Submit, NoHide

	IfEqual CFormat, 1 ;; Only if selected format == Custom
	{
		If CNLength = 0 ;; Card Number
		{
			GuiControl, Disable, CNStart
			GuiControl,, CNStart, 0
			GuiControl,, CNEnd, 0
		}
		Else If CNLength
			GuiControl, Enable, CNStart

		If FCLength = 0 ;; Facility Code
		{
			GuiControl, Disable, FCStart
			GuiControl,, FCStart, 0
			GuiControl,, FCEnd, 0
		}
		Else If FCLength
			GuiControl, Enable, FCStart

		If ICLength = 0 ;; Issue Code
		{
			GuiControl, Disable, ICStart
			GuiControl,, ICStart, 0
			GuiControl,, ICEnd, 0
		}
		Else If ICLength
			GuiControl, Enable, ICStart
	}
	CNEnd := CNLength > 0 ? CNStart + CNLength - 1 : 0
	FCEnd := FCLength > 0 ? FCStart + FCLength - 1 : 0
	ICEnd := ICLength > 0 ? ICStart + ICLength - 1 : 0
	
	GuiControl,, CNEnd, % CNEnd
	GuiControl,, FCEnd, % FCEnd
	GuiControl,, ICEnd, % ICEnd
Return

;;;;;;;;;;;;;;;;;;;;;;;
;; Calculate Results ;;
;;;;;;;;;;;;;;;;;;;;;;;
CICButtonExtractData:
	Gui, CIC:Default						; Set the "CIC" Gui as Default for the thread
	GuiControl, Disable, CICSubmit			; Disable the Submit button
	GuiControl,,CICSubmit, Processing...	; Change Submit button text to indicate calculation in progress
	Gui, Submit, NoHide						; Get data from the form

	; Check that all card fields have a length.  If not, set the Start to 0
	CNStart := CNLength ? CNStart : 0
	FCStart := FCLength ? FCStart : 0
	ICStart := ICLength ? ICStart : 0

/* 	No longer needed as the End fields have been added to a different point in programming
	CNEnd := CNStart+CNLength-1
	CNEnd := CNEnd < 0 ? "" : CNEnd

	FCEnd := FCStart+FCLength-1
	FCEnd := FCEnd < 0 ? "" : FCEnd

	ICEnd := ICStart+ICLength-1
	ICEnd := ICEnd < 0 ? "" : ICEnd
 */

	fmtValid = true	; Initialize fmtValid - assume the format is valid unless it fails below

	; Check that RawData has a valid value
	If(!RegExMatch(RawData, "^[0-9A-F]+$")) {
		MsgBox, Raw Data is invalid!`nPlease use only 0-9 and A-F!
		fmtValid := false
		GuiControl, Enable, CICSubmit
		GuiControl,,CICSubmit, Extract Data
		Return
	}
	Else {
		bData := fnHex2bin(RawData, CardLength)
		If (StrLen(bData) > CardLength)
			MsgBox % "Raw Data is too long!`nBits in Raw Data:`t" StrLen(bData) "`nConfigured length:`t" CardLength
	}

	; Validate card format information: Lengths, overlapping, etc
	If CNLength {
		;; Check that Card Number length is valid
		If (CNLength > 128)	{	;; Max valid CN Length is 128 bits
			fmtValid := false
			MsgBox, Card Number length must be between 0 and 128
		}

		;; Check that the Card Number doesn't go longer than the Card Length
		If (CNStart+CNLength > CardLength) {
			MsgBox, Card Number falls outside the bounds of the Card Length.
			fmtValid := false
		}
	}

	;; Check that the Facility Code length is valid and doesn't overlap the Card Number
	If FCLength	{
		If (FCLength <= 32)	{	;; Max valid FC length is 32 bits
			;; Does the Facility Code overlap the Card Number?
			If (CNLength && ( ((CNStart <= FCStart) && (FCStart <= CNEnd))	  ;; If FCStart in range of Card Number chunk
						 ||   ((CNStart <= FCEnd  ) && (FCEnd   <= CNEnd)) )) ;; Or if FCEnd in range of Card Number chunk
			{
				MsgBox, Card Number and Facility Code overlap.`nPlease correct the format and try again.
				fmtValid := false
			}
		}
		Else { ;; FC Length too long
			fmtValid := false
			MsgBox, Facility Code length must be between 0 and 32
		}

		;; Check that the Facility Code doesn't go longer than the Card Length
		If FCStart+FCLength > CardLength {
			MsgBox, Facility Code falls outside the bounds of the Card Length.
			fmtValid := false
		}
	}

	;; Check that the Issue Code length is valid and doesn't overlap the Facility Code or Card Number
	If ICLength	{
		If (ICLength <= 32) ;; Max valid IC length is 32 bits
		{
			If (CNLength && ( ((CNStart <= ICStart) && (ICStart <= CNEnd))	  ;; If ICStart in range of Card Number chunk
						 ||   ((CNStart <= ICEnd  ) && (ICEnd   <= CNEnd)) )) ;; Or if ICEnd in range of Card Number chunk
			{
				MsgBox, Card Number and Issue Code overlap.`nPlease correct the format and try again.
				fmtValid := false
			}
			If (FCLength && ( ((FCStart <= ICStart) && (ICStart <= FCEnd))    ;; If ICStart in range of Facility Code chunk
						 ||   ((FCStart <= ICEnd  ) && (ICEnd   <= FCEnd)) )) ;; Or if ICEnd in range of Facility Code chunk
			{
				MsgBox, Facility Code and Issue Code overlap.`nPlease correct the format and try again.
				fmtValid := false
			}
		}
		Else {  ;; If ICLength is greater than 32
			fmtValid := false
			MsgBox, Issue Code length must be between 0 and 32
		}

		If ICStart+ICLength > CardLength {
			MsgBox, Issue Code falls outside the bounds of the Card Length.
			fmtValid := false
		}
	}	; Format check complete


	If fmtValid	{
		GuiControl,,CardNumber,.
		GuiControl,,FacilityCode,.
		GuiControl,,IssueCode,.

		SetTimer, Calculating, 50 ; Simply for effect, a form of progress bar

		CN := SM_Base2Number(SubStr(bData,CNStart+1,CNLength),2)
		FC := SM_Base2Number(SubStr(bData,FCStart+1,FCLength),2)
		IC := SM_Base2Number(SubStr(bData,ICStart+1,ICLength),2)

		SetTimer, Calculating, Off

		GuiControl,,CardNumber,%CN%
		GuiControl,,FacilityCode,%FC%
		GuiControl,,IssueCode,%IC%
	}	Else	{
		GuiControl,,CardNumber,
		GuiControl,,FacilityCode,
		GuiControl,,IssueCode,

		CNStart := CNEnd < 0 ? "N/A" : CNStart
		FCStart := FCEnd < 0 ? "N/A" : FCStart
		ICStart := ICEnd < 0 ? "N/A" : ICStart

		MsgBox % "Card Number:`t" CNStart " - " CNEnd "`nFacility Code:`t" FCStart " - " FCEnd "`nIssue Code:`t" ICStart " - " ICEnd
	}

	GuiControl, Enable, CICSubmit
	GuiControl,,CICSubmit, Extract Data
Return

; TODO: Implement format calculator
CICButtonCalculateFormat:
	MsgBox, Calculating format... ; Not really
	MsgBox, Not really.  It hasn't been coded yet.
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Peform Binary inversion of Raw Data ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
InvertRawData:
	Gui, Submit, NoHide
	If(!RegExMatch(RawData, "^[0-9A-F]+$")) {
		MsgBox, Raw Data is invalid!`nPlease use only 0-9 and A-F!
		fmtValid := false
		GuiControl, Enable, CICSubmit
		GuiControl,,Submit, CICSubmit
		Return
	}
	Else {
		bData := fnHex2bin(RawData, CardLength)
		ibData :=
		Loop, Parse, bData
		{
			ibData := ibData (A_LoopField ? "0" : "1")
		}
		RawData := fnBin2hex(ibData)
		GuiControl,, RawData, %RawData%
	}
Return

Calculating:
	Critical
	Gui, CIC:Default

	GuiControlGet, CNfield,, CardNumber
	CNfield := CNfield . "."
	GuiControl,,CardNumber,%CNfield%
	GuiControl,,FacilityCode,%CNfield%
	GuiControl,,IssueCode,%CNfield%
Return


;;;;;;;;;;;;;;;;;;;;;
;; Closing the app ;;
;;;;;;;;;;;;;;;;;;;;;
SplashGuiClose:
CICGuiClose:
Gui, Destroy
ExitApp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Resetting the app to default values ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CICGuiEscape:
	GuiControl,,RawData,135E50540A
	GuiControl, Focus, RawData
	Send {Home}+{End}
	GuiControl, Choose, CFormat, |12
	GuiControl,,CardNumber,
	GuiControl,,FacilityCode,
	GuiControl,,IssueCode,
	;GoSub SelFormat

	LV_ModifyCol(1,131)
	LV_ModifyCol(2,75)
	LV_ModifyCol(3,75)
	LV_ModifyCol(4,65)
	LV_ModifyCol(5, 0)
Return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Convert Hex to Binary with optional padding ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fnHex2bin(hexnum,paddedlen=0)	{
	hexdigits = 0123456789abcdef
	binbits = 0000,0001,0010,0011,0100,0101,0110,0111,1000,1001,1010,1011,1100,1101,1110,1111
	StringSplit bin_array,binbits,`,

	hexnum := RegExReplace(hexnum,"i)0x")
	StringSplit,hexary,hexnum
	bintext =

	loop %hexary0% ;<-- loop through each of the input digits high to low
	{ 
		x := hexary%A_Index% ;<- get a hex digit
		pos := InStr(hexdigits,x) ;find it's pos in the string
		b := bin_array%pos% ;<- get the bin based on the position
		bintext = %bintext%%b% ;<- add the bin to the binary text string
	}
	;; Remove extra padding, no leading zeros unless padlen > bintext
	bintext := RegExReplace(bintext, "^[0]*", "")
	;; ... and then pad to the appropriate length
	pad := paddedlen - StrLen(bintext)
	If pad > 0
	{
		Loop, %pad%
			bintext := "0" . bintext
	}
	Return (bintext)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Convert Binary to Hex ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
fnBin2hex(binnum)	{
	; Converts a binary number to hexadecimal by use of dynamic variables
	b0000 = 0
	b0001 = 1
	b0010 = 2
	b0011 = 3
	b0100 = 4
	b0101 = 5
	b0110 = 6
	b0111 = 7
	b1000 = 8
	b1001 = 9
	b1010 = A
	b1011 = B
	b1100 = C
	b1101 = D
	b1110 = E
	b1111 = F

	hexnum :=

	; Add leading '0' padding to make total length of string a multiple of 4
	While (Mod(StrLen(binnum), 4)) { 
		binnum := "0" binnum
	}


	Loop, % StrLen(binnum)/4
	{
		bindigit := SubStr(binnum, 4*(A_Index-1)+1, 4)
		hexnum := hexnum b%bindigit%
	}
	Return hexnum
}




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Create the formats.ini file ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CreateDefaultConfigFile:
FileAppend,
(
[26 Bit Raw]
CardLength=26
CNStart=0
CNLength=26
FCStart=0
FCLength=0
ICStart=0
ICLength=0
EPStart=0
EPLength=0
EPBit=0
OPStart=0
OPLength=0
OPBit=0

[26 Bit Wiegand]
CardLength=26
CNStart=9
CNLength=16
FCStart=0
FCLength=0
ICStart=0
ICLength=0
EPStart=1
EPLength=12
EPBit=0
OPStart=13
OPLength=12
OPBit=25

[26 Bit (H10301) Wiegand with Facility Code]
CardLength=26
CNStart=9
CNLength=16
FCStart=1
FCLength=8
ICStart=0
ICLength=0
EPStart=1
EPLength=12
EPBit=0
OPStart=13
OPLength=12
OPBit=25

[32 Bit 14443 cascade 1]
CardLength=32
CNStart=0
CNLength=32
FCStart=0
FCLength=0
ICStart=0
ICLength=0
EPStart=0
EPLength=0
EPBit=0
OPStart=0
OPLength=0
OPBit=0

[35 Bit HID Corporate 1000]
CardLength=35
CNStart=14
CNLength=20
FCStart=2
FCLength=12
ICStart=0
ICLength=0
EPStart=0
EPLength=0
EPBit=1
OPStart=0
OPLength=0
OPBit=34

[36 Bit Lenel]
CardLength=36
CNStart=17
CNLength=18
FCStart=1
FCLength=16
ICStart=0
ICLength=0
EPStart=1
EPLength=16
EPBit=0
OPStart=17
OPLength=18
OPBit=35

[36 Bit Wiegand]
CardLength=36
CNStart=15
CNLength=20
FCStart=0
FCLength=0
ICStart=0
ICLength=0
EPStart=1
EPLength=18
EPBit=0
OPStart=17
OPLength=18
OPBit=35

[36 Bit Wiegand with Facility]
CardLength=36
CNStart=15
CNLength=20
FCStart=5
FCLength=10
ICStart=0
ICLength=0
EPStart=1
EPLength=18
EPBit=0
OPStart=17
OPLength=18
OPBit=35

[37 Bit HID (H10302)]
CardLength=37
CNStart=1
CNLength=35
FCStart=0
FCLength=0
ICStart=0
ICLength=0
EPStart=1
EPLength=18
EPBit=0
OPStart=18
OPLength=18
OPBit=36

[37 Bit (H10304) with Facility]
CardLength=37
CNStart=17
CNLength=19
FCStart=1
FCLength=16
ICStart=0
ICLength=0
EPStart=1
EPLength=18
EPBit=0
OPStart=18
OPLength=18
OPBit=36

[37 Bit (I10304) HID with Facility]
CardLength=37
CNStart=20
CNLength=16
FCStart=14
FCLength=6
ICStart=0
ICLength=0
EPStart=1
EPLength=18
EPBit=0
OPStart=18
OPLength=18
OPBit=36

[40 Bit CASI 4002]
CardLength=40
CNStart=1
CNLength=38
FCStart=0
FCLength=0
ICStart=0
ICLength=0
EPStart=1
EPLength=19
EPBit=0
OPStart=0
OPLength=39
OPBit=39

[40 Bit CASI 9002]
CardLength=40
CNStart=20
CNLength=19
FCStart=1
FCLength=19
ICStart=0
ICLength=0
EPStart=1
EPLength=19
EPBit=0
OPStart=0
OPLength=39
OPBit=39

[48 Bit 1443 cascade 2]
CardLength=48
CNStart=0
CNLength=48
FCStart=0
FCLength=0
ICStart=0
ICLength=0
EPStart=0
EPLength=0
EPBit=0
OPStart=0
OPLength=0
OPBit=0

[64 Bit Wiegand]
CardLength=64
CNStart=8
CNLength=48
FCStart=0
FCLength=0
ICStart=0
ICLength=0
EPStart=0
EPLength=0
EPBit=0
OPStart=0
OPLength=0
OPBit=0

[64 Bit Wiegand with Facility]
CardLength=64
CNStart=8
CNLength=48
FCStart=0
FCLength=8
ICStart=56
ICLength=8
EPStart=0
EPLength=0
EPBit=0
OPStart=0
OPLength=0
OPBit=0

[72 Bit Wiegand]
CardLength=72
CNStart=32
CNLength=32
FCStart=0
FCLength=0
ICStart=0
ICLength=0
EPStart=0
EPLength=0
EPBit=0
OPStart=0
OPLength=0
OPBit=0

[72 Bit Wiegand with Facility]
CardLength=72
CNStart=32
CNLength=32
FCStart=0
FCLength=32
ICStart=64
ICLength=8
EPStart=0
EPLength=0
EPBit=0
OPStart=0
OPLength=0
OPBit=0
), %formatFile%
If (ErrorLevel) {
	MsgBox, 0x15, Error, Error creating file.`nError: %A_LastError%`nRetry?
	IfMsgBox, Retry
		GoTo, CreateDefaultConfigFile
	Else
		ExitApp
} else {
	MsgBox, 0x24, Success, File Created!`nReload program?
	IfMsgBox, Yes
		Reload
	Else
		ExitApp
}
return





;;;;;;;;;;;;;;;;;
;; Auto Reload ;;
;;;;;;;;;;;;;;;;;
CheckTime:
	ListLines, Off
	FileGetTime, ModTime2, %A_ScriptFullPath%, M
	If (ModTime2 != ModTime) {
		Reload
		ModTime := ModTime2
	}
Return