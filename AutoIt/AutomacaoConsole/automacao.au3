#cs
	TODO
	https://stackoverflow.com/questions/22028592/testing-using-plink-exe-to-connect-to-ssh-in-c-sharp

#CE


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
	No loop perceba as variáveis que leem as saídas do console, StdoutRead/$Normal e StderrRead/$error

	$normal = StdoutRead($__PID, False, False)
	$error = StderrRead($__PID, False, False)

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
#include <GuiRichEdit.au3>
#include <Tools.au3>

OnAutoItExitRegister("OnExit")

Opt("GUIOnEventMode", 1)
Opt("GUIEventOptions", 1)
Opt("MustDeclareVars", 1)

Global $aFONT[5] = ["DOSLike", 8]
Global $APP_NAME = ""
Global $PID_RUN = False
Global $aGuiSize[2] = [800, 600]
Global $sGuiTitle = "PID[ 0 ]"
Global $hGui
Global $hOutput, $hInput
Global $buffer, $read
Global Enum $PID, $NAME, $TYPE, $EXIT, $OPT
Global $aPID[1][4]
Global $LF = 0

$hGui = GUICreate($sGuiTitle, $aGuiSize[0], $aGuiSize[1], -1, 0)
GUISetFont(9, 400, 0, "DOSLike", $hGui)
GUISetOnEvent($GUI_EVENT_CLOSE, "Quit")
;~ $hOutput = GUICtrlCreateEdit("", 10, 10, $aGuiSize[0] - 20, $aGuiSize[1] - 200, $WS_VSCROLL + $ES_AUTOVSCROLL + $ES_READONLY)

$hOutput = _GUICtrlRichEdit_Create($hGui, "", 10, 10, $aGuiSize[0] - 20, $aGuiSize[1] - 200, BitOR($ES_MULTILINE, $WS_VSCROLL, $ES_AUTOVSCROLL, $ES_READONLY))
;~ GUICtrlSetFont($hOutput, $aFONT[1], 400, 0, $aFONT[0])

$hInput = GUICtrlCreateInput("", 10, $aGuiSize[1] - 200 + 20, $aGuiSize[0] - 20, 170)

GUISetState(@SW_SHOW, $hGui)


;~ Global $__PID = COMMAND_LINE()
Global $__PID = PLINK()
;~ Global $__PID = DOS()
;~ Run(@ComSpec & " /c cmd.exe", @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD + $STDIN_CHILD)

WinSetTitle($hGui, "", "PID[" & $__PID & "]")
Global $normal = "", $error = ""

GUIRegisterMsg($WM_ACTIVATE, "WM_ACTIVATE")
GUICtrlSetState($hInput, $GUI_FOCUS)
HotKeySet("{ENTER}", "Enter")

While Sleep(10)
	If ProcessExists($__PID) And $PID_RUN Then
		$normal = StdoutRead($__PID, False, False)
		If $normal Then
			Output($normal)
			$normal = ""
		EndIf
		$error = StderrRead($__PID, False, False)
		If $error Then
			Output($error, 0, 0xFF0000)
			$error = ""
		EndIf
	ElseIf Not ProcessExists($__PID) And $PID_RUN Then
		$PID_RUN = False
		WinSetTitle($hGui, "", "PID[ 0 ]")
	ElseIf ProcessExists($__PID) And Not $PID_RUN Then
		$PID_RUN = True
		WinSetTitle($hGui, "", "PID[ " & $__PID & " ]")
	EndIf
WEnd

Func COMMAND_LINE()
	$APP_NAME = "command_line.exe"
	$__PID = Run(@ComSpec & " /c " & $APP_NAME, @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD + $STDIN_CHILD)
	If @error Then Return SetError(1, 0, 0)
	$PID_RUN = True
	Return $__PID
EndFunc   ;==>COMMAND_LINE

Func PLINK()
;~ 	https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html
;~ https://the.earth.li/~sgtatham/putty/latest/w32/plink.exe
;~ https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe

;~ C:\>plink root@192.168.101.1 -pw SecretRootPwd (date;hostname;ls -l)

	$APP_NAME = "plink.exe -ssh master@192.168.100.4 -pw MyPassword"
	$__PID = Run(@ComSpec & " /c " & $APP_NAME, @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD + $STDIN_CHILD)
	If @error Then Return SetError(1, 0, 0)
	$PID_RUN = True
	Return $__PID
EndFunc   ;==>PLINK

Func DOS()
	$APP_NAME = "cmd.exe"
	$__PID = Run(@ComSpec & " /c " & $APP_NAME, @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD + $STDIN_CHILD)
	If @error Then Return SetError(1, 0, 0)
	$PID_RUN = True
	Return $__PID
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
	GUICtrlSetData($hInput, "")
	StdinWrite($__PID, $input & @LF)
	$LF = True
EndFunc   ;==>Enter

Func Output2($input = "", $mode = 0)
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
	Switch $mode
		Case 1 ; $MS_DOS
			$input = _WinAPI_MultiByteToWideChar($input, 850, 0, True)
			Trim($input)
			If Not $input Then Return
			ConsoleWrite($input & @LF)
			Local $output = GUICtrlRead($hOutput)
			Trim($output)
			GUICtrlSetData($hOutput, $output & @CRLF & $input)
			_GUICtrlEdit_Scroll($hOutput, $SB_SCROLLCARET)
		Case 2 ; $LINUX
		Case 3 ; $SQL_LUS
	EndSwitch



EndFunc   ;==>Output2

Func Output($input, $sAttrib = "", $iColor = "")
	$input = _WinAPI_MultiByteToWideChar($input, 65001, 0, True)

	StringRegExpReplace(_GUICtrlRichEdit_GetText($hOutput, True), "[\r\n]", "")
	Local $iEndPoint = _GUICtrlRichEdit_GetTextLength($hOutput, True, True) - @extended

	$input = StringRegExpReplace($input, "\e\[[0-9]m", "")
	$input = StringRegExpReplace($input, "\e\[[0-9]{2};[0-9]{2}m", "")

	$input = StringRegExpReplace($input, "\e\][0-9];(.*?)\a", "")

	_GUICtrlRichEdit_AppendText($hOutput, ($LF ? "" : @LF) & $input)

	ConsoleWrite(">>>" & @LF & $input & @LF & "<<<" & @LF)
	_GUICtrlRichEdit_SetSel($hOutput, $iEndPoint, -1)
	$iColor = Hex($iColor, 6)
	$iColor = "0x" & StringMid($iColor, 5, 2) & StringMid($iColor, 3, 2) & StringMid($iColor, 1, 2)
	_GUICtrlRichEdit_SetCharColor($hOutput, $iColor ? $iColor : 0x000000)
	If Not ($sAttrib == "") Then _GUICtrlRichEdit_SetCharAttributes($hOutput, $sAttrib)
	_GUICtrlRichEdit_SetFont($hOutput, $aFONT[1], $aFONT[0])
	_GUICtrlRichEdit_Deselect($hOutput)
	GUICtrlSetState($hInput, $GUI_FOCUS)
	If $LF Then $LF = False

EndFunc   ;==>Output


Func PID_Close()
	If Not $__PID Then Return
	Local $aProccesList = ProcessList()
	Local $iSearch = _ArraySearch($aProccesList, $APP_NAME, 1, Default, 0, 0, 0, 0)
	If @error Then
		ConsoleWrite("Error to close!" & @LF)
	Else
		ProcessClose($aProccesList[$iSearch][1])
		ProcessClose($__PID)
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




#cs
	WEBGRAFIA
	instalar client ssh
	https://askubuntu.com/questions/30080/how-to-solve-connection-refused-errors-in-ssh-connection

	auto aceitar chave ssh
	http://blog.immanuelnoel.com/2015/07/11/plink-auto-accept-hostkeys/

	cmd.exe /c echo y | plink.exe -v ssh 192.168.1.10 -P 22 -l root -pw P@$$w0rd "/usr/local/python3.4 run.py -this script -does -something -AWESOME"
	echo y | plink.exe -ssh $line.Server -l $Username -pw $Password exit






	Func Output($input, $sAttrib = "", $iColor = "")
	;~ 	https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
	;~ Black        0;30     Dark Gray     1;30
	;~ Red          0;31     Light Red     1;31
	;~ Green        0;32     Light Green   1;32
	;~ Brown/Orange 0;33     Yellow        1;33
	;~ Blue         0;34     Light Blue    1;34
	;~ Purple       0;35     Light Purple  1;35
	;~ Cyan         0;36     Light Cyan    1;36
	;~ Light Gray   0;37     White         1;37
	;~ 	https://github.com/aziz/SublimeANSI
	;~ 	$input = _WinAPI_MultiByteToWideChar($input, 850, 0, True)
	$input = _WinAPI_MultiByteToWideChar($input, 65001, 0, True)
	;	http://www.autoitscript.com/forum/topic/121728-richedit-not-working/
	Local $Comprimento = StringLen($input), $Passo = 100, $Temp = ""
	;	Count the @CRLFs
	StringReplace(_GUICtrlRichEdit_GetText($hOutput, True), @CRLF, "")
	Local $iLines = @extended
	;	Adjust the text char count to account for the @CRLFs
	Local $iEndPoint = _GUICtrlRichEdit_GetTextLength($hOutput, True, True) - $iLines
	;	Add new text
	;_GUICtrlRichEdit_AppendText($h_RichEdit, $input & @CRLF)

	;~ 	\a BEL Chr(7)
	;~ 	\e ESC Chr(27)
	;~ ]0;master@debian: ~ master@debian:~$
	;~  \e]0;master@debian: ~\amaster@debian:~$
	;~ ]0;master@debian: ~master@debian:~$
	;~ total 32
	;~ drwxr-xr-x 2 master master 4096 ago 27 11:18 [0m[01;34mÁrea de trabalho[0m
	;~ drwxr-xr-x 2 master master 4096 ago 27 11:18 [01;34mDocumentos[0m
	;~ drwxr-xr-x 2 master master 4096 ago 27 11:18 [01;34mDownloads[0m
	;~ drwxr-xr-x 2 master master 4096 ago 27 11:18 [01;34mImagens[0m
	;~ drwxr-xr-x 2 master master 4096 ago 27 11:18 [01;34mModelos[0m
	;~ drwxr-xr-x 2 master master 4096 ago 27 11:18 [01;34mMúsica[0m
	;~ drwxr-xr-x 2 master master 4096 ago 27 11:18 [01;34mPúblico[0m
	;~ drwxr-xr-x 2 master master 4096 ago 27 11:18 [01;34mVídeos[0m
	;~ ]0;master@debian: ~master@debian:~$
	;~ ]0;master@debian: ~master@debian:~$


	$input = StringRegExpReplace($input, "\e\[[0-9]m", "")
	$input = StringRegExpReplace($input, "\e\[[0-9]{2};[0-9]{2}m", "")
	;~ 	$input = StringRegExpReplace($input, "((?=\e)(.*)(?<=\a))", "")
	$input = StringRegExpReplace($input, "(?i)\e.*?\a", "")
	;~ str = str.replaceAll("(?s)<ref>.*?</ref>", "");

	_GUICtrlRichEdit_AppendText($hOutput, $input & @CRLF)


	ConsoleWrite(">>>" & @LF & $input & @LF & "<<<" & @LF)
	;~ 	Explode($input)
	_GUICtrlRichEdit_SetSel($hOutput, $iEndPoint, -1)
	;	Convert colour from RGB to BGR
	$iColor = Hex($iColor, 6)
	$iColor = '0x' & StringMid($iColor, 5, 2) & StringMid($iColor, 3, 2) & StringMid($iColor, 1, 2)
	_GUICtrlRichEdit_SetCharColor($hOutput, $iColor ? $iColor : 0x000000)
	If Not ($sAttrib == "") Then _GUICtrlRichEdit_SetCharAttributes($hOutput, $sAttrib)
	_GUICtrlRichEdit_SetFont($hOutput, $aFONT[1], $aFONT[0])
	_GUICtrlRichEdit_Deselect($hOutput)
	GUICtrlSetState($hInput, $GUI_FOCUS)
	EndFunc   ;==>Output

#ce

