#NoEnv
SetWinDelay, -1
SetBatchLines, -1
#SingleInstance Force

; Variables globales
Global ScrcpyID := 0
Global HandleID := 0
Global OverlayActive := false
Global BarHeight := 25
Global CurrentTransPct := 60 ; Opacidad inicial al 60%

; Crear la barra de arrastre (GUI)
Gui, Handle: +AlwaysOnTop -Caption +ToolWindow +LastFound
Gui, Handle: Color, FF0000 ; Rojo brillante
HandleID := WinExist()
return

; Atajo: Ctrl + Shift + O (Toggle Overlay)
^+o::
    WinGet, ScrcpyID, ID, ahk_class SDL_app
    if (!ScrcpyID)
    {
        ToolTip, ERROR: No se encontró scrcpy
        Sleep, 1000
        ToolTip
        return
    }
    
    if (!OverlayActive)
    {
        ; Convertir porcentaje a valor de Windows (0-255)
        WindowsTrans := Round(CurrentTransPct * 2.55)
        
        ; Activar modo Overlay
        WinSet, Transparent, %WindowsTrans%, ahk_id %ScrcpyID%
        WinSet, ExStyle, +0x20, ahk_id %ScrcpyID%
        OverlayActive := true
        
        ; Posicionar barra justo encima de scrcpy
        WinGetPos, sX, sY, sW, sH, ahk_id %ScrcpyID%
        Gui, Handle: Show, % "x" sX " y" (sY - BarHeight) " w" sW " h" BarHeight " NoActivate"
        
        SetTimer, SyncHandle, 100
    }
    else
    {
        ; Desactivar modo Overlay
        WinSet, Transparent, OFF, ahk_id %ScrcpyID%
        WinSet, ExStyle, -0x20, ahk_id %ScrcpyID%
        OverlayActive := false
        Gui, Handle: Hide
        SetTimer, SyncHandle, Off
    }
return

; Lógica de opacidad con la rueda del ratón (Escala 0-100%)
~WheelUp::
~WheelDown::
    MouseGetPos,,, MouseWinID
    if (MouseWinID = HandleID && OverlayActive)
    {
        if (A_ThisHotkey = "~WheelUp")
            CurrentTransPct := (CurrentTransPct + 5 > 100) ? 100 : CurrentTransPct + 5
        else
            CurrentTransPct := (CurrentTransPct - 5 < 10) ? 10 : CurrentTransPct - 5
            
        ; Convertir porcentaje a valor de Windows (0-255)
        WindowsTrans := Round(CurrentTransPct * 2.55)
        
        WinSet, Transparent, %WindowsTrans%, ahk_id %ScrcpyID%
        ToolTip, Opacidad: %CurrentTransPct%`%
        SetTimer, RemoveToolTip, 1000
    }
return

RemoveToolTip:
    ToolTip
return

; Lógica de arrastre MANUAL y ROBUSTA
~LButton::
    MouseGetPos, mX, mY, MouseWinID
    if (MouseWinID = HandleID)
    {
        WinGetPos, wX, wY,,, ahk_id %HandleID%
        offX := mX - wX
        offY := mY - wY
        
        while GetKeyState("LButton", "P")
        {
            MouseGetPos, curX, curY
            newX := curX - offX
            newY := curY - offY
            
            WinMove, ahk_id %HandleID%,, %newX%, %newY%
            WinMove, ahk_id %ScrcpyID%,, %newX%, % (newY + BarHeight)
            Sleep, 10
        }
    }
return

SyncHandle:
    if (OverlayActive && !GetKeyState("LButton", "P"))
    {
        if (!WinExist("ahk_id " ScrcpyID))
        {
            Gui, Handle: Hide
            OverlayActive := false
            SetTimer, SyncHandle, Off
            return
        }
        
        WinGetPos, sX, sY, sW, sH, ahk_id %ScrcpyID%
        Gui, Handle: Show, % "x" sX " y" (sY - BarHeight) " w" sW " h" BarHeight " NoActivate"
    }
return
