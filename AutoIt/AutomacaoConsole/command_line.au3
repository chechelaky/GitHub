; #UDF# =========================================================================================================================
; Name...........: command_line.exe
; Description ...: script de linha de comando
; Exemplo........:
; Author ........: Luigi (Luismar Chechelaky)
; Link ..........: https://github.com/chechelaky/GitHub/blob/master/AutoIt/AutomacaoConsole/command_line.au3
; Source.........: https://msdn.microsoft.com/en-us/library/aa387258(v=vs.85).aspx
; AutoIt version.: 3.3.14.2
; ===============================================================================================================================


#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile=command_line.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Change2CUI=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

ConsoleWrite(@ScriptName & @CRLF)
If $cmdline[0] Then
	If Random(0, 1, 1) Then
		Local $num = Random(1000, 1999, 1)
		Sleep($num)
		ConsoleWriteError("@error: " & $num & @CRLF)
	Else
		Local $num = Random(2000, 2999, 1)
		Sleep($num)
		ConsoleWriteError("@ok: " & $num & @CRLF)
	EndIf
Else
	If Random(0, 1, 1) Then
		Local $num = Random(3000, 3999, 1)
		Sleep($num)
		ConsoleWriteError("@error: " & $num & @CRLF)
	Else
		Local $num = Random(4000, 4999, 1)
		Sleep($num)
		ConsoleWriteError("@ok: " & $num & @CRLF)
	EndIf
EndIf

Global $read = ""


While Sleep(10)
	$read = ConsoleRead()
	If $read Then Executa( StringRegExpReplace($read, "[\r\n]", "") )
WEnd

Func Executa($input)
	Switch StringLower($input)
		Case 1
			Retorno("um", 2)
		Case 2
			Retorno("dois", 2)
		Case 3
			Retorno("tres", 2)
		Case 4
			Retorno("quatro", 2)
		Case 5
			Retorno("cincod", 2)
		Case 6
			Retorno("seis", 2)
		Case 7
			Retorno("sete", 2)
		Case 8
			Retorno("oito", 2)
		Case 9
			Retorno("nove", 2)
		Case "exit", "quit", "bye"
			Quit()
		Case Else
			Retorno("unknow command <" & $input & ">", 1)
	EndSwitch
EndFunc

Func Retorno($input, $mode = 0)
	Switch $mode
		Case 0
			Local $num = Random(0, 999, 1)
			Sleep($num)
			ConsoleWrite(">Ok: " & $input & " $num[ " & $num & " ]" & @CRLF)
		Case 1
			Local $num = Random(1000, 1999, 1)
			Sleep($num)
			ConsoleWriteError(">Error: " & $input & " $num[ " & $num & " ]" & @CRLF)
		Case Else
			Retorno($input, Random(0, 1, 1))
	EndSwitch
EndFunc   ;==>Retorno

Func Quit()
	Retorno("Exit", 0)
	Exit
EndFunc   ;==>Quit

