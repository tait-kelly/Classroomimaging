@echo off
REM Classroom Master Script
REM Replacing ClassroomAlerts.bat Version 2.0

REM Version 1.0

REM VERSION 1.1
REM Added in automatic update functionality into script. Files are updated via a pull from Github and will check it a new script is availible and then download and replace as needed.



REM Planning / impovements
REM 

for /f "delims=." %%a in ('wmic OS Get localdatetime ^| find "."') do set dt=%%a
set GITHUBKEY=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
set today=%dt%
set currhour=%dt:~8,2%
set currmin=%dt:~10,2%
set YEARMONTH=%dt:~0,6%
REM echo current extracted time is:%currhour%:%currmin%:
set targethour=88
set targetmin=88
if "%currmin%"=="55" set targetmin=00
if "%currmin%"=="56" set targetmin=01
if "%currmin%"=="57" set targetmin=02
if "%currmin%"=="58" set targetmin=03
if "%currmin%"=="59" set targetmin=04
if "%currmin%"=="00" set /a targethour=%currhour% + 1
if "%targethour%"=="88" set targethour=%currhour%
if "%targetmin%"=="88" set /a "targetmin=%currmin% + 5"

:BEGIN
REM This section will be the starting point for the script it will need to parse out the parameter passed and determine what it will be doing
REM Actions that could be taken from here:
REM 1. Going to Monitor to do a check of the system health
REM 2. Going to Startup to restore the browsers, set network config, and clear Documents, Downloads and Desktop\
REM 3. Shutting down the PC and sending an alert to MARRS2 for information
rem echo got to the beginning of the script with a %~1 parameter. >> c:\Windows\SJUClass\diag.txt
REM Part 2 Startup or boot
if /I "%~1"=="-b" (
	call:STARTUP
)
REM Part 3 Shutdown
if /I "%~1"=="-s" (
	call:SHUTDOWN
)
REM Part 1 Maintenance
call:MONITOR
GOTO END

:AUTOUPDATE
REM Curl an update file in the name format of %COMPUTERNAME%Update%YEARMONTH%.txt which YEARMONTH will be from the variable above
REM Once the file is downloaded a check via findstr "Page not found" %PCNAME%Update%YEARMONTH%.txt will verify if there was an update file or not.
REM If there is an update file the new file will need to be downloaded in the format of %PCNAME%SJUClassroom.bat
REM once the file is downloaded it will need to be renamed to SJUClassroom.bat after renaming the old script to SJUClassroom%DT%.bat
REM Lastly the new script will need to be copied to replace the script in all 3 locations
curl -LJOs  https://%GITHUBKEY%@github.com/tait-kelly/Classroomimaging/raw/main/%COMPUTERNAME%Update%YEARMONTH%.txt > NUL
findstr "Page not found" %COMPUTERNAME%Update%YEARMONTH%.txt
if "%errorlevel%"=="0" (
	REM Page not found in document was successful meaning that there was not an update file so the the download and replacement of the new script is not required.
) else (
	REM The document didn't contain Page not found so there should be a new script and it is now time to download it.
	
	rename c:\Widnows\SJUclass\SJUClassroom.bat c:\Windows\SJUClass\SJUClassroom%dt%.bat
	rename C:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\SJUClassroom.bat C:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\SJUClassroom%dt%.bat
	rename C:\Windows\System32\GroupPolicy\Machine\Scripts\Shutdown\SJUClassroom.bat C:\Windows\System32\GroupPolicy\Machine\Scripts\Shutdown\SJUClassroom%dt%.bat
	curl -LJOs  https://%GITHUBKEY%@github.com/tait-kelly/Classroomimaging/raw/main/SJUClassroom.bat > NUL
	copy SJUClassroom.bat c:\Widnows\SJUclass\SJUClassroom.bat
	copy SJUClassroom.bat C:\Windows\System32\GroupPolicy\Machine\Scripts\Shutdown\SJUClassroom.bat
)
EXIT /b

:STARTUP
call:RESTOREBROWSERS
call:CLEARDESKTOP
call:CLEARDOCUMENTS
call:CLEARDOWNLOADS
call:SETNETWORK
call:CHECKMONITORCONFIG
call:AUTOUPDATE
EXIT /b

:MONITOR
call:CHECKAUDIO
schtasks /Create /SC "ONCE" /TN "Recheck AV" /RU SYSTEM /F /TR "c:\Windows\SJUclass\SJUClassroom.bat" /ST %targethour%:%targetmin%
EXIT /b

:SHUTDOWN
REM This will only be called on a shutdown to update MARRS about the manual shutdown and then the Powershell script will be run for set a wake time in the bios.
GOTO END

REM This functions should be tested as separate batches first and then moved into master when tested and confirmed.
:CLEARDESKTOP
rmdir /Q /S C:\Users\Classroom\Desktop
mkdir C:\Users\Classroom\Desktop\
rmdir /Q /S C:\Users\Public\Desktop
mkdir C:\Users\Public\Desktop\
EXIT /b

:CLEARDOCUMENTS
rmdir /Q /S C:\Users\Classroom\Documents
mkdir C:\Users\Classroom\Documents\

rmdir /Q /S C:\Users\Public\Documents
mkdir C:\Users\Public\Documents\
EXIT /b

:CLEARDOWNLOADS
rmdir /Q /S C:\Users\Classroom\Downloads
mkdir C:\Users\Classroom\Downloads\

rmdir /Q /S C:\Users\Public\Downloads
mkdir C:\Users\Public\Downloads\
EXIT /b

:SETNETWORK
set IP_Addr=172.17.6.39
if %computername%==AB1002 set IP_Addr=172.17.6.48
if %computername%==AB1004a set IP_Addr=172.17.6.101
if %computername%==AB1004b (
	set IP_Addr=172.17.6.99
	echo I just set the IP 
)
if %computername%==SJ2-2001 set IP_Addr=172.17.6.88
if %computername%==SJ2-2002 set IP_Addr=172.17.6.58
if %computername%==SJ2-2003 set IP_Addr=172.17.6.78
if %computername%==SJ2-2007 set IP_Addr=172.17.6.68
if %computername%==SJ1-1036 set IP_Addr=172.17.6.200
if %computername%==SJ1-2009 set IP_Addr=172.17.6.148
if %computername%==SJ1-2011 set IP_Addr=172.17.6.168
if %computername%==SJ1-2017 set IP_Addr=172.17.6.178
if %computername%==SJ1-3012 set IP_Addr=172.17.6.188
if %computername%==SJ1-3013 set IP_Addr=172.17.6.198
if %computername%==SJ1-3014 set IP_Addr=172.17.6.208
if %computername%==SJ1-3015 set IP_Addr=172.17.6.218
if %computername%==SJ1-3016 set IP_Addr=172.17.6.228
if %computername%==SJ1-3020 set IP_Addr=172.17.6.238
if %computername%==SJ1-3027 set IP_Addr=172.17.6.248

if %computername%==SJUBOARD set IP_Addr=172.17.6.128
if %computername%==SJULIB01 set IP_Addr=172.17.6.10
if %computername%==SJULIB02 set IP_Addr=172.17.6.11
if %computername%==SJULIB03 set IP_Addr=172.17.6.12
if %computername%==SJULIB04 set IP_Addr=172.17.6.13
if %computername%==SJULIB05 set IP_Addr=172.17.6.14
if %computername%==SJULIB06 set IP_Addr=172.17.6.15
if %computername%==SJULIB07 set IP_Addr=172.17.6.16
if %computername%==SJULIB08 set IP_Addr=172.17.6.17
if %computername%==SJULIB09 set IP_Addr=172.17.6.18
if %computername%==SJULIB10 set IP_Addr=172.17.6.19
if %computername%==SJULIB11 set IP_Addr=172.17.6.20
if %computername%==SJULIB12 set IP_Addr=172.17.6.21
if %computername%==SJULIB13 set IP_Addr=172.17.6.22
if %computername%==SJULIB14 set IP_Addr=172.17.6.23

if %computername%==SJ1-LAB2023 set IP_Addr=172.17.6.178


REM echo "Setting Static IP Information" 
REM echo setting IP with netsh interface ip set address name="SJULAN" static %IP_Addr% 255.255.255.0 172.17.6.1 

netsh interface ipv4 set address name="SJULAN" static %IP_Addr% 255.255.255.0 172.17.6.1 
REM echo primary dns 
netsh interface ipv4 set dnsservers name="SJULAN" static 129.97.2.1 primary no 
REM echo secondary dns
netsh interface ipv4 add dnsservers name="SJULAN" 129.97.2.2 index=2 no
EXIT /b


:RESTOREBROWSERS
rem Set the backup location
set "backupLocation=C:\Windows\SJUClass\Browserconfigs\"
tskill Chrome
rmdir /Q /S "c:\Users\Classroom\AppData\Local\Google"

tskill firefox
rmdir /Q /S "c:\Users\Classroom\AppData\Roaming\Mozilla\"


tskill msedge
rmdir /Q /S "c:\Users\Classroom\AppData\Local\Microsoft\Edge"


rem Restore Chrome profiles
xcopy "%backupLocation%\Google\Google\*" "c:\Users\Classroom\AppData\Local\Google" /E /I /Q /Y

rem Restore Firefox profiles
xcopy "%backupLocation%\Mozilla\Mozilla\*" "c:\Users\Classroom\AppData\Roaming\Mozilla\" /E /I /Q /Y


rem Restore Edge profiles
xcopy "%backupLocation%\Edge\Edge\*" "c:\Users\Classroom\AppData\Local\Microsoft\Edge\" /E /I /Q /Y

EXIT /b

:RESTORETASKBAR
EXIT /b
:REMOVESOFTWARE
EXIT /b
:CHECKMONITORCONFIG
REM For the display switching the newest update to Windows broke displayswitch.exe so a manual copy needs to be used and copied to the system for usage
c:\windows\SJUClass\DisplaySwitch.exe /clone
EXIT /b


:CHECKAUDIO
c:\windows\SJUClass\svcl.exe /scomma | findstr "Crestron"
if "%errorlevel%"=="0" (
	REM echo looks like the Crestron device is active	
	c:\windows\SJUClass\svcl.exe /SetDefault "Crestron" >NUL
) else (
	REM echo looks like the Crestron device is missing or disabled
	REM echo this is where I should be sending a notification to MARRS
)
EXIT /b

:CREATEDESKTOPLINKS
EXIT /b
:HYBRIDCLASSROOMCONFIG
REM This will not be completed until later
EXIT /b

:END
EXIT