#cs ----------------------------------------------------------------------------

  glide - Transfer code from a text editor to a statistical software GUI

  v 1.0.0

  CTilley 20201108

  AutoIt v 3.3.14.5

#ce ----------------------------------------------------------------------------

#include <MsgBoxConstants.au3>

; declarations
Local $copyWait, $extArray, $ext, $behavior, $ini
Local $native, $nativePath, $nativeTitle, $nativeLaunch, $nativeCommand, $nativeText, $nativeHandle
Local $origClip, $copyClip, $tempFile, $tempHandle, $stataHandle

; wait 5 milliseconds between key strokes
Opt("SendKeyDelay", 5)

; wait 250 milliseconds after successful windows-related operation
Opt("WinWaitDelay", 250)

; wait 100 milliseconds after copy operations
$copyWait = 100

; advanced window matching
Opt("WinTitleMatchMode", 4)

; get file extension from command line
$extArray = StringSplit($CmdLine[1], ".")
$ext = $extArray[UBound($extArray)-1]

; get behavior from command line
$behavior = StringLower($CmdLine[2])
If Not (($behavior == "text") Or ($behavior == "script")) Then
  MsgBox(16, "Error", "Behavior [" & $behavior & "] not allowed. Update command line call.")
  Exit
EndIf

; Path to INI file
$ini = @ScriptDir & "\glide.ini"

; use extension to determine section of INI file
$native = IniRead($ini, "extensions", $ext, "MISSING")
If ($native == "MISSING") Then
  MsgBox(16, "Error", "Extension [" & $ext & "] not declared under [extensions] in INI file.")
  Exit
EndIf

; path to executable
$nativePath = IniRead($ini, $native, "path", "MISSING")
If ($nativePath == "MISSING") Then
  MsgBox(16, "Error", "Path to executable not declared under [" & $native & "] in INI file.")
  Exit
EndIf

; title of native window
$nativeTitle = IniRead($ini, $native, "wintitle", "MISSING")
If ($nativeTitle == "MISSING") Then
  MsgBox(16, "Error", "Title of window not declared under [" & $native & "] in INI file.")
  Exit
EndIf

; wait time if launching executable (milliseconds)
$nativeLaunch = IniRead($ini, $native, "wait", "2500")

; command to send to native window
$nativeCommand = IniRead($ini, $native, "command", "MISSING")
If ($nativeCommand == "MISSING") Then
  MsgBox(16, "Error", "Command to send to window not declared under [" & $native & "] in INI file.")
  Exit
EndIf

; text to send to native window
$nativeText = IniRead($ini, $native, "text", "MISSING")
If ($nativeText == "MISSING") Then
  MsgBox(16, "Error", "Text to send to window not declared under [" & $native & "] in INI file.")
  Exit
EndIf

; preserve contents of clipboard
$origClip = ClipGet()

; clear off clipboard
ClipPut("")

; copy selected text from editor to clipboard
If $behavior == "script" Then
  Send("^a")
EndIf
Send("^c")
Sleep($copyWait)
$copyClip = ClipGet()

; if no text is selected, copy current line to clipboard
If $copyClip == "" And $behavior == "text" Then
  Send("{HOME}+{END}^c")
  Sleep($copyWait)
  $copyClip = ClipGet()
EndIf

; if no text in editor, exit
If $copyClip == "" Then
  Exit
EndIf

; define file in temp directory
$tempFile = EnvGet("TEMP") & "/" & $behavior & "glide." & $ext
$tempFile = StringReplace($tempFile, "\", "/")

; create file, verify it exists
$tempHandle = FileOpen($tempFile, 2)
If $tempHandle = -1 Then
  MsgBox(16, "Error", "Cannot open temporary file " & $behavior & "glide." & $ext & " in temporary directory " & EnvGet("TEMP") & ".")
  Exit
EndIf

; write to handle
FileWrite($tempHandle, $copyClip & @CRLF)
FileClose($tempHandle)

; include file name in native window text
$nativeText = StringReplace($nativeText, "%%scriptname%%", Chr(34) & $tempFile & Chr(34))

; native window text to clipboard
ClipPut($nativeText)

; send command to native window
$nativeHandle = WinGetHandle("[REGEXPTITLE:" & $nativeTitle & "]")
If Not @error Then
    If StringLower($native) == "stata" Then
      While 1
        $stataHandle = WinGetHandle("[REGEXPTITLE:Data Editor.*(Browse|Edit).*]")
        If @error Then ExitLoop
        WinClose($stataHandle)
	 WEnd
	 While 1
        $stataHandle = WinGetHandle("[REGEXPTITLE:Viewer - (help|search).*]")
        If @error Then ExitLoop
        WinClose($stataHandle)
      WEnd
    EndIf
    WinActivate($nativeHandle)
    WinWaitActive($nativeHandle)
    Send($nativeCommand)
    Send("^v{ENTER}")
Else
  Run($nativePath)
  Sleep($nativeLaunch)
  $nativeHandle = WinGetHandle("[REGEXPTITLE:" & $nativeTitle & "]")
  WinActivate($nativeHandle)
  WinWaitActive($nativeHandle)
  Send($nativeCommand)
  Send("^v{ENTER}")
EndIf

; restore clipboard
ClipPut($origClip)

