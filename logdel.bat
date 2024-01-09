@echo off
color 1f
:: BatchGotAdmin Ben Gripka https://stackoverflow.com/questions/1894967/how-to-request-administrator-access-inside-a-batch-file
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------  
set ch=%cd%
cd %ch%
    call :MsgBox "Delete All Event Logs?"  "VBYesNo+VBQuestion" "Continue ?"
    if errorlevel 7 (
        goto _end
    ) else if errorlevel 6 (
        goto _strt
    )
:_strt
echo Clearing Event Logs Please wait...
if exist log.txt (
  del log.txt
)
setlocal enabledelayedexpansion
set log=log.txt
set b=WEVTUTIL CL
for /f %%a in ('WEVTUTIL EL') do ( 
!b! "%%a">>!log! 2>&1
)
cls
> tmp.vbs ECHO WScript.Echo^( "COMPLETE" ^& vbCrLf ^& "Check log.txt For Any Errors" ^)
WSCRIPT.EXE tmp.vbs
DEL tmp.vbs
color
endlocal
goto :EOF
:MsgBox
    setlocal enableextensions
    set "tempFile=%temp%\%~nx0.%random%%random%%random%vbs.tmp"
    >"%tempFile%" echo(WScript.Quit msgBox("%~1",%~2,"%~3") & cscript //nologo //e:vbscript "%tempFile%"
    set "exitCode=%errorlevel%" & del "%tempFile%" >nul 2>nul
    endlocal & exit /b %exitCode%
:_end
color
cls
goto :EOF
