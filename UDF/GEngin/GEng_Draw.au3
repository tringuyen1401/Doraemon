#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.6.1
 Author:         Matwachich

 Script Function:


#ce ----------------------------------------------------------------------------

;File: System

#Region ### Functions ###
#cs
- Main Functions
	_GEng_ScrFlush($iBkColor = 0xFFFFFFFF)
	_GEng_ScrUpdate()
	_GEng_FPS_Get($iDelay = 1000)
#ce
#EndRegion ###


; #FUNCTION# ;===============================================================================
; Name...........: _GEng_ScrFlush
; Description ...: Permet d'�ffacer l'�cran, en lui donnant une couleur
; Syntax.........: _GEng_ScrFlush($iBkColor = 0xFFFFFFFF)
; Parameters ....: $iBkColor = Couleur avec la quelle remplire l'�cran (Defaut = Blanc)
; Return values .: Succes - 1
;                  Echec - 0
; Author ........: Matwachich
; Remarks .......: Inutile et couteux en ressource si vous avez un sprite qui fait office de background
; ;==========================================================================================
#cs
Function: _GEng_ScrFlush
	Flush the screen with a bakcground color

Prototype:
	> _GEng_ScrFlush($iBkColor = 0xFFFFFFFF)

Parameters:
	$iBkColor - Background color (0xAARRGGBB)

Returns:
	Succes - 1
	Failed - 0 And @error = 1
#ce
Func _GEng_ScrFlush($iBkColor = 0xFFFFFFFF)
	Return _GDIPlus_GraphicsClear($__GEng_hBuffer, $iBkColor)
EndFunc

; #FUNCTION# ;===============================================================================
; Name...........: _GEng_ScrUpdate
; Description ...: Valider les op�ration de d�ssin (copie le hBitmap dans le hGraphic)
; Syntax.........: _GEng_ScrUpdate()
; Parameters ....:
; Return values .: Succes - 1
;                  Echec - 0
; Author ........: Matwachich
; Remarks .......: Inspir� par "Sinus Scroller By UEZ"
; ;==========================================================================================
#cs
Function: _GEng_ScrUpdate
	Validate all the drawings (Sprites, Text) and update the screen

Prototype:
	> _GEng_ScrUpdate()

Parameters:
	Nothing

Returns:
	Succes - 1
	Failed - 0 And @error = 1
#ce
Func _GEng_ScrUpdate()
	;Return _GDIPlus_GraphicsDrawImage($__GEng_hGraphic, $__GEng_hBitmap, 0, 0)
	; --- Fait gagner env. 2ms!
	Local $gdibitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($__GEng_hBitmap)
	_WinAPI_SelectObject($__GEng_hCompatibleDC, $gdibitmap)
	_WinAPI_DeleteObject($gdibitmap)
	Return _WinAPI_BitBlt($__GEng_hDC, 10, 0, $__GEng_WinW, $__GEng_WinH, $__GEng_hCompatibleDC, 0, 0, 0x00CC0020) ; 0x00CC0020 = $SRCCOPY
EndFunc

Func _GEng_ScrUpdatePNG()
	Local $gdibitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($__GEng_hBitmap)
	$hOld = _WinAPI_SelectObject($__GEng_hCompatibleDC, $gdibitmap)

	$tSize = DllStructCreate($tagSIZE)
	$pSize = DllStructGetPtr($tSize)
	DllStructSetData($tSize, "X", 70)
	DllStructSetData($tSize, "Y", 70)
	$tSource = DllStructCreate($tagPOINT)
	$pSource = DllStructGetPtr($tSource)
	$tBlend = DllStructCreate($tagBLENDFUNCTION)
	$pBlend = DllStructGetPtr($tBlend)
	DllStructSetData($tBlend, "Alpha", 255)
	DllStructSetData($tBlend, "Format", 1)

	_GDIPlus_GraphicsClear($__GEng_hBuffer,0)

	_WinAPI_UpdateLayeredWindow($__GEng_hGui, $__GEng_hDC, 0, $pSize, $__GEng_hCompatibleDC, $pSource, 0, $pBlend, $ULW_ALPHA)
	_WinAPI_ReleaseDC($__GEng_hGui, $__GEng_hDC)
	_WinAPI_SelectObject($__GEng_hCompatibleDC, $hOld)
	_WinAPI_DeleteObject($gdibitmap)
;~ 	_WinAPI_DeleteDC($__GEng_hCompatibleDC)


EndFunc

; #FUNCTION# ;===============================================================================
; Name...........: _GEng_FPS_Get
; Description ...:
; Syntax.........: _GEng_FPS_Get($iDelay = 1000)
; Parameters ....:
; Return values .: la valeur du FPS - @extended = temps de g�n�ration de la frame pass� (ms)
; Author ........: Matwachich
; Remarks .......:
; ;==========================================================================================
#cs
Function: _GEng_FPS_Get
	Returns the FPS

Prototype:
	> _GEng_FPS_Get($iDelay = 1000)

Parameters:
	$iDelay - Delay to return the FPS value (in ms) (see remarks)

Returns:
	If iDelay reached - FPS, @extended = Frame generation time, @error = 0
	If iDelay not reached yet - -1, @extended = 0, @error = 1

Remarks:
	The FPS value is calculated and returned every $iDelay ms.

Example:
	> $fps = _GEng_FPS_Get()
	> If $fps <> -1 Then
	> 	Update your FPS diplay here
	> EndIf
#ce
Func _GEng_FPS_Get($iDelay = 1000)
	Local $t, $ret, $err, $ext
	If TimerDiff($__GEng_FPSDisplayTimer) >= $iDelay Or $__GEng_FPSDisplayTimer = 0 Then
		$t = TimerDiff($__GEng_FPSTimer)
		$__GEng_FPSDisplayTimer = TimerInit()
		; ---
		$ret = 1000 / $t
		$ext = $t
		$err = 0
	Else
		$ret = -1
		$err = 1
		$ext = 0
	EndIf
	; ---
	$__GEng_FPSTimer = TimerInit()
	Return SetError($err, $ext, $ret)
EndFunc

