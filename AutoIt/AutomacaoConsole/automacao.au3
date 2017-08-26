; #UDF# =========================================================================================================================
; Name...........: automacao.au3
; Description ...: terminal para automacao de script de linha de comando
; Exemplo........:
; Author ........: Luigi (Luismar Chechelaky)
; Link ..........: https://github.com/chechelaky/GitHub/blob/master/AutoIt/AutomacaoConsole/automacao.au3
; AutoIt version.: 3.3.14.2
; ===============================================================================================================================

;~ #AutoIt3Wrapper_AU3Check_Parameters= -q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
;~ #Tidy_Parameters=/sf

; Autor: Luigi
; Agradecimentos:
;	@Elias (http://forum.autoitbrasil.com/index.php?/user/1384-elias/)
;	http://forum.autoitbrasil.com/index.php?/topic/1121-runstdio-executa-um-programa-dos-e-retorna-a-saida-da-console/#entry13419

#cs

Minha percepção de como funciona (se estou errado, por favor, compartilhe seu entendimento comigo).
No loop percepa as variáveis que leem as saídas do console, StdoutRead/$Normal e StderrRead/$error

	$normal = StdoutRead($PID, False, False)
	$error = StderrRead($PID, False, False)

Se o comando foi executado com sucesso, a saída se dará pelo $normal.
Se houve erro na execução, a saída se dará por $error.
Logicamente, isso ainda carece de testes, não tenho certeza de que toda a saída de console funciona desta forma.

No aplicativo command_line.exe, quando você digita um número de 1 até 9, a saída é sempre aleatória, isto é, pode vir por:
$normal (escrita por 'ConsoleWrite') ou
$error (escrita por 'ConsoleWriteError')

Ainda tenho dúvidas se o plink.exe ou sqlplus.exe funcionam da mesma forma.

Se as saídas forem por $normal e $error, é muito fácil tratar erros, se há saida em $error... há erro!
Agora se o alguma mensagem de erro vier por $normal, terá que ser analisado a string de retorno, procurando alguma string que
identifique este erro.
#ce

#include-once
#include <Array.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <ScrollBarsConstants.au3>

OnAutoItExitRegister("OnExit")

Opt("GUIOnEventMode", 1)
Opt("GUIEventOptions", 1)
Opt("MustDeclareVars", 1)

Global $APP_NAME = ""
Global $PID_RUN = False
Global $aGuiSize[2] = [800, 600]
Global $sGuiTitle = "PID[ 0 ]"
Global $hGui
Global $hOutput, $hInput
Global $buffer, $read

$hGui = GUICreate($sGuiTitle, $aGuiSize[0], $aGuiSize[1])
GUISetFont(9, 400, 0, "DOSLike", $hGui)
GUISetOnEvent($GUI_EVENT_CLOSE, "Quit")
$hOutput = GUICtrlCreateEdit("", 10, 10, $aGuiSize[0] - 20, $aGuiSize[1] - 200, $WS_VSCROLL + $ES_AUTOVSCROLL + $ES_READONLY)
$hInput = GUICtrlCreateInput("", 10, $aGuiSize[1] - 200 + 20, $aGuiSize[0] - 20, 170)

GUISetState(@SW_SHOW, $hGui)


Global $PID = COMMAND_LINE()
;~ Global $PID = DOS()
;~ Run(@ComSpec & " /c cmd.exe", @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD + $STDIN_CHILD)

WinSetTitle($hGui, "", "PID[" & $PID & "]")
Global $normal = "", $error = ""

GUIRegisterMsg($WM_ACTIVATE, "WM_ACTIVATE")
GUICtrlSetState($hInput, $GUI_FOCUS)
HotKeySet("{ENTER}", "Enter")

While Sleep(10)
	If ProcessExists($PID) And $PID_RUN Then
		$normal = StdoutRead($PID, False, False)
		If $normal Then
			Output("$normal: " & $normal)
			$normal = ""
		EndIf
		$error = StderrRead($PID, False, False)
		If $error Then
;~ 			$error = BinaryToString($error)
			Output(" $error: " & $error)
			$error = ""
		EndIf
	ElseIf Not ProcessExists($PID) And $PID_RUN Then
		$PID_RUN = False
		WinSetTitle($hGui, "", "PID[ 0 ]")
	ElseIf ProcessExists($PID) And Not $PID_RUN Then
		$PID_RUN = True
		WinSetTitle($hGui, "", "PID[ " & $PID & " ]")
	EndIf
WEnd

Func COMMAND_LINE()
	$APP_NAME = "command_line.exe"
	$PID = Run(@ComSpec & " /c " & $APP_NAME, @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD + $STDIN_CHILD)
	If @error Then Return SetError(1, 0, 0)
	$PID_RUN = True
	Return $PID
EndFunc   ;==>COMMAND_LINE

Func DOS()
	$APP_NAME = "cmd.exe"
	$PID = Run(@ComSpec & " /c " & $APP_NAME, @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD + $STDIN_CHILD)
	If @error Then Return SetError(1, 0, 0)
	$PID_RUN = True
	Return $PID
EndFunc   ;==>DOS

Func WM_ACTIVATE($hWnd, $Msg, $wParam, $lParam)
	If BitAND($wParam, 0xFFFF) Then
		HotKeySet("{ENTER}", "Enter")
	Else
		HotKeySet("{ENTER}")
	EndIf
EndFunc   ;==>WM_ACTIVATE

Func Enter()
	Local $input = GUICtrlRead($hInput)
	$input = StringRegExpReplace($input, "[\r\n]", "")
	If $input Then GUICtrlSetData($hInput, "")
	Local $num = StdinWrite($PID, $input & @CRLF)
;~ 	Output($input)
EndFunc   ;==>Enter

Func Output($input = "")
;~ 	https://unix.stackexchange.com/questions/208436/bell-and-escape-character-in-prompt-string
;~ ESC \
;~      String Terminator (ST  is 0x9c).
;~ ESC ]
;~      Operating System Command (OSC  is 0x9d).
;~ 	0 - ANSI code page
;~ 	1 - OEM code page
;~ 	2 - Macintosh code page
;~ 	3 - The Windows ANSI code page for the current thread
;~ 	42 - Symbol code page
;~ 	850
;~ 	65000 - UTF-7
;~ 	65001 - UTF-8
	$input = _WinAPI_MultiByteToWideChar($input, 850, 0, True)
	Trim($input)
	If Not $input Then Return
	ConsoleWrite($input & @LF)
	Local $output = GUICtrlRead($hOutput)
	Trim($output)
	GUICtrlSetData($hOutput, $output & @CRLF & $input)
	_GUICtrlEdit_Scroll($hOutput, $SB_SCROLLCARET)
EndFunc   ;==>Output

Func PID_Close()
	If Not $PID Then Return
	Local $aProccesList = ProcessList()
	Local $iSearch = _ArraySearch($aProccesList, $APP_NAME, 1, Default, 0, 0, 0, 0)
	If @error Then
		ConsoleWrite("Error to close!" & @LF)
	Else
		ProcessClose($aProccesList[$iSearch][1])
		ProcessClose($PID)
		$APP_NAME = ""
	EndIf
EndFunc   ;==>PID_Close

Func OnExit()
	PID_Close()
	GUISetState($hGui, @SW_HIDE)
	GUIDelete($hGui)
EndFunc   ;==>OnExit

Func Quit()
	Exit
EndFunc   ;==>Quit

Func Trim(ByRef $str)
	While StringLeft($str, 1) = @CRLF Or StringLeft($str, 1) = @LF Or StringLeft($str, 1) = @CR
		$str = StringTrimLeft($str, 1)
	WEnd

	While StringRight($str, 1) = @CRLF Or StringRight($str, 1) = @LF Or StringRight($str, 1) = @CR
		$str = StringTrimRight($str, 1)
	WEnd
EndFunc   ;==>Trim
