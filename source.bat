@echo off
setlocal EnableExtensions EnableDelayedExpansion
rem [ SETTINGS ]==========================================================
set AppName=Steam Account Manager
set AppAuthor=kpuc313
set AppVersion=v1.0
set AppHomePage=https://github.com/kpuc313
set AppDescription=Allows you to manage multiple steam accounts
set AppCopyright=(C) %AppAuthor%. All Rights Reserved!
set AppExtName=sam
set AppDBName=accounts.db
set AppTextColor=1
rem ======================================================================

rem [ REGISTER ]==========================================================
title %AppName%

set MODE=NULL
set MESSAGE=NULL
set account=NULL
set sc_Name=NULL
set sc_Args=NULL
set sc_Desc=NULL
set sc_Icon=NULL

rem // Set Color Cvars
set c_BLUE=09
set c_GREEN=0A
set c_AQUA=0B
set c_RED=0C
set c_PURPLE=0D
set c_YELLOW=0E
set c_WHITE=0F
rem ======================================================================

rem [ STEAM ]=============================================================
if "%AppTextColor%" == "1" color %c_RED%
if not exist "Steam.exe" (
	echo [ERROR]: Cannot find "Steam.exe"!
	echo [ERROR]: Please, move "%~n0%~x0" to "Steam.exe" directory!
	echo.
	pause
	exit
)
rem ======================================================================

rem [ RUN ]===============================================================
if not "%1" == "-account" goto MENU_TOOLS_HOME
if "%2" == "switcher" goto MENU_SWITCHER
set account=%2

:RUN
if not exist "!account!.%AppExtName%" (
	del "*.%AppExtName%"
	type nul > "!account!.%AppExtName%"
	taskkill /F /IM Steam.exe > nul
	reg add "HKCU\Software\Valve\Steam" /v AutoLoginUser /t REG_SZ /d !account! /f > nul
	reg add "HKCU\Software\Valve\Steam" /v RememberPassword /t REG_DWORD /d 1 /f > nul
)

start steam://open/main
exit
rem ======================================================================

rem [ MENUS ]=============================================================
:MENU_SWITCHER
if "%AppTextColor%" == "1" color %c_WHITE%
for /r %%i in (*.%AppExtName%) do (
	if exist %%~ni.%AppExtName% (
		title Steam Switcher [Account: %%~ni]
	)
)

rem // Check if database exists
if not exist "%AppDBName%" type nul > "%AppDBName%"

rem // Show Account Names
set /a count=1
set /a buttons=0
for /F %%i in (%AppDBName%) do (
	echo !count!.%%i
	set /a buttons = !buttons!!count!
	set /a count += 1
)

rem // Show Empty DB Message
if %buttons% EQU 0 (
	echo You need to add accounts through "%AppName%.exe"^^^!
	pause > nul
	exit
)

choice /C %buttons% /N /M "" > nul

set /a bnumber=1
for /F %%i in (%AppDBName%) do (
	set account2=%%~ni
	set account=!account2!
	if %ERRORLEVEL% EQU !bnumber! goto RUN
	set /a bnumber += 1
)

:MENU_TOOLS_HOME
if "%AppTextColor%" == "1" color %c_WHITE%
if %MESSAGE% NEQ NULL ( 
	echo - %MESSAGE%
	echo.
	set MESSAGE=NULL
)
echo 1.Add account
echo 2.Delete account
echo 3.Create shortcut
echo 4.Create shortcut [Switcher]
echo.
echo 7.Clear database
echo.
echo 9.About
choice /C 123456789 /N /M "9.About" > nul
cls
if %ERRORLEVEL% EQU 1 goto ACTION_HOME_ADD_ACCOUNT
if %ERRORLEVEL% EQU 2 goto ACTION_HOME_DELETE_ACCOUNT
if %ERRORLEVEL% EQU 3 goto ACTION_HOME_CREATE_SHORTCUT_ACCOUNT
if %ERRORLEVEL% EQU 4 goto ACTION_HOME_CREATE_SHORTCUT_SWITCHER
if %ERRORLEVEL% EQU 5 goto MENU_TOOLS_HOME
if %ERRORLEVEL% EQU 6 goto MENU_TOOLS_HOME
if %ERRORLEVEL% EQU 7 goto ACTION_HOME_DEL_DATABASE
if %ERRORLEVEL% EQU 8 goto MENU_TOOLS_HOME
if %ERRORLEVEL% EQU 9 goto MENU_ABOUT

:MENU_ABOUT
if "%AppTextColor%" == "1" color %c_YELLOW%
echo Homepage: %AppHomePage%
echo.
echo Description: %AppDescription%
echo Version: %AppVersion%
echo Author: %AppAuthor%
echo.
echo %AppCopyright%^^^!
echo.
echo This application is not affiliated with Steam(R) or (C) Valve Corporation.
echo.
echo Steam(R), Steam(R) Logo and all related elements are trademarks of
echo and (C) Valve Corporation.
echo.
echo 9.Back
choice /C 9 /N /M "" > nul
cls
if %ERRORLEVEL% EQU 9 goto MENU_TOOLS_HOME
goto MENU_TOOLS_HOME
rem ======================================================================

rem [ ACTIONS ]===========================================================
:ACTION_HOME_ADD_ACCOUNT
if "%AppTextColor%" == "1" color %c_GREEN%
echo Database:
echo.

rem // Check if database exists
if not exist "%AppDBName%" type nul > "%AppDBName%"

rem // Show database
set /a list = 1
for /F %%i in (%AppDBName%) do (
	echo !list!.%%i
	if !list! GTR 8 (
		set MESSAGE="You can add only 9 accounts^^^!"
		cls
		goto MENU_TOOLS_HOME
	)
	set /a list += 1
)
echo.
set /P add_account=Add new account: 

rem // Check for space
if "%add_account%" == " " (
	cls
	goto MENU_TOOLS_HOME
)

rem // Check for empty
if [%add_account%] == [] ( 
	cls
	goto MENU_TOOLS_HOME
)

rem // Check if account exists
findstr /I /c:"%add_account%" %AppDBName%
if %ERRORLEVEL% EQU 0 (
	set MESSAGE="Account '%add_account%' already exists in database^^^!"
)
if %ERRORLEVEL% EQU 1 (
	echo %add_account% >> "%AppDBName%"
	set MESSAGE="Account '%add_account%' was added to database^^^!"
	set add_account=
)
cls
goto MENU_TOOLS_HOME

:ACTION_HOME_DELETE_ACCOUNT
if "%AppTextColor%" == "1" color %c_RED%
echo Database:
echo.

rem // Check if database exists
if not exist "%AppDBName%" type nul > "%AppDBName%"

rem // Show database
set /a list = 1
for /F %%i in (%AppDBName%) do (
	echo !list!.%%i
	if !list! GTR 9 (
		set MESSAGE="You can add only 9 accounts^^^!"
		goto MENU_TOOLS_HOME
	)
	set /a list += 1
)
echo.
set /P del_account=Delete account: 

rem // Check for space
if "%del_account%" == " " (
	cls
	goto MENU_TOOLS_HOME
)

rem // Check for empty
if [%del_account%] == [] ( 
	cls
	goto MENU_TOOLS_HOME
)

rem // Check if account exists
findstr /I /c:"%del_account%" %AppDBName%
if %ERRORLEVEL% EQU 1 (
	set MESSAGE="Account '%del_account%' doesn't exists in database^^^!"
)
if %ERRORLEVEL% EQU 0 (
	ren %AppDBName% %AppDBName%.old
	findstr /v /b /c:"%del_account%" %AppDBName%.old > %AppDBName%
	del %AppDBName%.old
	set MESSAGE="Account '%del_account%' was deleted from database^^^!"
	set del_account=
)
cls
goto MENU_TOOLS_HOME

:ACTION_HOME_CREATE_SHORTCUT_ACCOUNT
if "%AppTextColor%" == "1" color %c_GREEN%
set /P create_sa=Create new shortcut to account: 

rem // Check for space
if "%create_sa%" == " " (
	cls
	goto MENU_TOOLS_HOME
)

rem // Check for empty
if [%create_sa%] == [] ( 
	cls
	goto MENU_TOOLS_HOME
)

set MODE=MENU_TOOLS_HOME
set "sc_Name=Steam [%create_sa%]"
set "sc_Args=%create_sa%"
set "sc_Desc=Steam [%create_sa%] Launcher"
set "sc_Icon=Steam.exe"
set MESSAGE="Shortcut to '%create_sa%' was created on your desktop^^^!"
set create_sa=
goto TOOL_CREATE_SHORTCUT

:ACTION_HOME_CREATE_SHORTCUT_SWITCHER
set MODE=MENU_TOOLS_HOME
set "sc_Name=Steam Switcher"
set "sc_Args=switcher"
set "sc_Desc=Steam Switcher Launcher"
set "sc_Icon=Steam.exe"
set MESSAGE="Shortcut to 'Switcher' was created on your desktop^^^!"
goto TOOL_CREATE_SHORTCUT

:ACTION_HOME_DEL_DATABASE
type nul > %AppDBName%
set MESSAGE="Database was cleared^^^!"
cls
goto MENU_TOOLS_HOME
rem ======================================================================

rem [ TOOLS ]=============================================================
:TOOL_CREATE_SHORTCUT
echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateShortcut.vbs
echo sLinkFile = "%HOMEDRIVE%%HOMEPATH%\Desktop\%sc_Name%.lnk" >> CreateShortcut.vbs
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateShortcut.vbs
echo oLink.TargetPath = "%~f0" >> CreateShortcut.vbs
echo oLink.Arguments = "-account %sc_Args%" >> CreateShortcut.vbs
echo oLink.Description = "%sc_Desc%" >> CreateShortcut.vbs
echo oLink.HotKey = "" >> CreateShortcut.vbs
echo oLink.IconLocation = "%cd%\%sc_Icon%" >> CreateShortcut.vbs
echo oLink.WindowStyle = "1" >> CreateShortcut.vbs
echo oLink.WorkingDirectory = "%cd%" >> CreateShortcut.vbs
echo oLink.Save >> CreateShortcut.vbs
cscript CreateShortcut.vbs
del CreateShortcut.vbs
cls
goto %MODE%
rem ======================================================================
