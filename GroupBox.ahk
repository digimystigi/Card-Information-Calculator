;************************** GroupBox *******************************
;
;	Adds and wraps a GroupBox around a group of controls in
;	the default Gui. Use the Gui Default command if needed.
;	For instance:
;
;		Gui, 2:Default
;
;	sets the default Gui to Gui 2.
;
;	Add the controls you want in the GroupBox to the Gui using
;	the "v" option to assign a variable name to each control. *
;	To prevent a control from being shifted right, for, say,
;	table layouts, add "x_" to the control name in the fn call.
;	Then immediately after the last control for the group
;	is added call this function. It will add a GroupBox and
;	wrap it around the controls.
;
;	Example:
;
;	Gui, Add, Text, vControl1, This is Control 1
;	Gui, Add, Text, vControl2 x+30, This is Control 2
;	GroupBox("GB1", "Testing", "Control1|Control2, 10, 20")
;	Gui, Add, Text, Section xMargin, This is Control 3
;	GroupBox("GB2", "Another Test", "This is Control 3", 10, 20)
;	Gui, Add, Text, yS, This is Control 4
;	GroupBox("GB3", "Third Test", "Static4", 10, 20)
;	Gui, Show, , GroupBox Test
;
;	* The "v" option to assign Control ID is not mandatory. You
;	may also use the ClassNN name or text of the control.
;
;	Author: dmatch @ AHK forum
;	Date: Sept. 5, 2011
;
;	Additions and modifications by: digimystigi
;
;********************************************************************

IfInString A_ScriptName, GroupBox.ahk
	ExitApp

GroupBox(GBvName			;Name for GroupBox control variable
		,Title				;Title for GroupBox
		,Piped_CtrlvNames	;Pipe (|) delimited list of Controls
		,Margin=10			;Margin in pixels around the controls
		,TitleHeight=10		;Height in pixels to allow for the Title
		,FixedWidth=""		;Optional fixed width
		,FixedHeight="")		;Optional fixed height
{
	Local PCtrlGB, PCNInclude, maxX, maxY, minX, minY, xPos, yPos ;all else assumed Global
	minX:=99999, minY:=99999, maxX:=0, maxY:=0


	static GBArray := Object()
	GBArray.Insert(GBvName)
	; GBArray%GBvName% := Piped_CtrlvNames
	;;; Parse Piped_CtrlvNames
	PCNInsert :=
	Loop, Parse, Piped_CtrlvNames, |, %A_Space%
	{
		GuiControlGet, nameExists, Name, %A_LoopField%
		If nameExists
			PCNInsert := PCNInsert "|" A_LoopField
		Else
			PCNInsert := PCNInsert "|" RegExReplace(A_LoopField, "^x_(?P<cntrl>.*)$", "${cntrl}")
	}
	GBArray%GBvName% := LTrim(PCNInsert, "|")
	;MsgBox % GBArray%GBvName%

	; Expand the string to include children of any GroupBoxes in the list
	Loop
	{
		doneExpanding := True
		PCNInclude =
		Loop, Parse, Piped_CtrlvNames, |, %A_Space%
		{
			cntrl		:= A_LoopField ; Get the next item in the list for processing
			nameValid	:=
			nameExists	:= 

			If RegExMatch(cntrl, "^\w+$") ; Is valid control name?
			{
				If % GBArray%cntrl% ; If cntrl is an existing GroupBox
				{
					;PCNInclude := (PCNInclude) ? PCNInclude "|" GBArray%cntrl% : GBArray%cntrl%
					/*
					GuiControlGet, nameExists, Name, %cntrl%
					If !nameExists
					{
						GuiControlGet, nameExists, Name, %cntrl%
						If nameExists
					}
					;*/
					cntrl := RegExReplace(A_LoopField, "^x_(?P<cntrl>.*)$", "${cntrl}") ; and it starts with x_
					IfNotEqual cntrl, %A_LoopField% ; and an existing control starting with x_ does not exist
					{
					*/
					PCtrlGB := (PCtrlGB) ? PCtrlGB "|" cntrl : cntrl
					PCNInclude := (PCNInclude) ? PCNInclude "|" GBArray%cntrl% : GBArray%cntrl%
					doneExpanding := False ; Lets go through another time to make sure everything is expanded.
					Continue ; If valid control name is an existing groupbox, skip adding it to PCNInclude
				}
			} ;Else is not a valid control name.  Obviously not an existing GroupBox.  Let's skip it. }
			PCNInclude := (PCNInclude) ? PCNInclude "|" cntrl : cntrl
		}
		Piped_CtrlvNames := PCNInclude ; Override the incoming parameter data with parsed data
	} Until doneExpanding ; Once the list is fully expanded, let's get to moving the controls and GroupBoxes

	; If there are any GroupBoxes in the list, add their control names to the elements to move
	If PCtrlGB
		Piped_CtrlvNames := Piped_CtrlvNames "|" PCtrlGB

	Loop, Parse, Piped_CtrlvNames, |, %A_Space%
	{
		; Check whether we're holding the X value - prevent horizontal shifting, for example, when making table-like layouts
		moveX := True
		cntrl := RegExReplace(A_LoopField, "^x_(?P<cntrl>.*)$", "${cntrl}") ; If control name starts with x_
		IfNotEqual cntrl, %A_LoopField% ; and an existing control starting with x_ does not exist
			moveX := False ; then make sure we don't move the X of the control.

		;Get position and size of each control in list.
		GuiControlGet, GB, Pos, %cntrl%
		GuiControl, MoveDraw, %cntrl%, x%GBX% y%GBY% ; Move control to its existing coordinates to check for sub-client
		GuiControlGet, GB2, Pos, %cntrl% ; Get the control's position again

		; Check whether we're in a Tab control or other coordinate modifying client
		Local xOff := GBX - GB2X
		Local yOff := GBY - GB2Y
		; }

		GBX := (moveX ? GBX : GBX - Margin)

		;creates GBX, GBY, GBW, GBH
		minX := GBX<minX ? GBX : minX ;check for minimum X
		minY := GBY<minY ? GBY : minY ;Check for minimum Y
		maxX := GBX+GBW>maxX ? GBX+GBW : maxX ;Check for maximum X
		maxY := GBY+GBH>maxY ? GBY+GBH : maxY ;Check for maximum Y

		;Move the control to make room for the GroupBox
		xPos:= GBX+Margin+xOff
		yPos:=GBY+TitleHeight+Margin+yOff ;fixed margin
		GuiControl, MoveDraw, %cntrl%, x%xPos% y%yPos%
	}
	;re-purpose the GBW and GBH variables
	GBW := FixedWidth ? FixedWidth : maxX-minX+2*Margin ;calculate width for GroupBox
	GBH := FixedHeight ? FixedHeight : maxY-MinY+TitleHeight+2*Margin ;calculate height for GroupBox ;fixed 2*margin

	;Add the GroupBox
	Gui, Add, GroupBox, v%GBvName% x%minX% y%minY% w%GBW% h%GBH%, %Title%
	return
}