@echo off
REM This Windows batch script will clear all Windows event logs using WEVTUTIL
REM @AngryCaffeine https://github.com/AngryCaffeine
color 1f
REM BatchGotAdmin Ben Gripka https://stackoverflow.com/questions/1894967/how-to-request-administrator-access-inside-a-batch-file
:-------------------------------------
REM  Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )
REM Ask for Administrator rights
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
REM Change directory back and ask for confirmation
cd /d %~dp0
    call :_MsgBox "Delete All Event Logs?"  "VBYesNo+VBQuestion" "Continue ?"
    if errorlevel 7 (
        goto _end
    ) else if errorlevel 6 (
        goto _strt
    )
:_strt
echo Clearing Event Logs Please wait...
echo This might take a few minutes...
REM Delete old log file
if exist log.txt (
  del log.txt
)
REM Just in case the script exited prematurely 
if exist tmp.vbs (
  del tmp.vbs
)
REM WEVTUTIL EL lists the names of Windows event logs. WEVTUTIL CL Clears the Log
setlocal enabledelayedexpansion
set _log=log.txt
set _b=WEVTUTIL CL
for /f %%a in ('WEVTUTIL EL') do ( 
!_b! "%%a">>!_log! 2>&1
)
REM VB msgbox to signal the task is complete
cls
call :_okBox
goto _end
REM Yes or No Message Box
:_MsgBox
    setlocal enableextensions
    set "tempFile=%temp%\%~nx0.%random%%random%%random%vbs.tmp"
    >"%tempFile%" echo(WScript.Quit msgBox("%~1",%~2,"%~3") & cscript //nologo //e:vbscript "%tempFile%"
    set "exitCode=%errorlevel%" & del "%tempFile%" >nul 2>nul
    endlocal & exit /b %exitCode%
REM OK Message box
:_okBox
setlocal enableextensions
set "tempFile=%temp%\%~nx0.%random%%random%%random%vbs.tmp"
>"%tempFile%" echo(WScript.Quit msgBox("Check log.txt For Any Errors",vbOKOnly+vbInformation, "COMPLETE") & cscript //nologo //e:vbscript "%tempFile%"
del "%tempFile%" >nul 2>nul
endlocal & exit /b
REM Change terminal back to default Clear screen and exit program
:_end
color
cls
goto :EOF
