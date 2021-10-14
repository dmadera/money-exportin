@echo off
setlocal
chcp 1250

SET "ERROR=0"
SET "dir=%~dp0"
SET "LOG=%dir%export.log"
SET "wget=%dir%\wget.exe"
SET "winscp=%dir%\WinSCP.exe"
SET "pathcsv=%dir%..\csv\"
SET "TMP=%dir%tmp"
SET "server=pemalbc.savana-hosting.cz"
SET "db=%1"

ECHO ****** EXPORT IN ******
ECHO %DATE% %TIME%
call %dir%lowercase.bat %db:~-4% > %TMP%
SET /p firma=<%TMP%

echo Processing: %firma%
IF "%firma%" neq "pema" OR "%firma%" neq "lipa" SET "ERROR=1" && GOTO :clean

ECHO ****** SQL TO CSV ******
del /S /Q /F "%pathcsv%*" >nul 2>&1
CALL %dir%\generate-csv.bat %db%
IF NOT "%ERRORLEVEL%" == "0" SET "ERROR=1" && GOTO :clean

IF NOT exist "%dir%..\..\Settings\pass%firma%sklad" ECHO "No password file: %dir%..\..\Settings\pass%firma%sklad" && SET "ERROR=1" && GOTO :clean

SET "user=%firma%sklad"
SET /p pass=<%dir%..\..\Settings\pass%firma%sklad

SET "url=http://velkoobchoddrogerie.cz/loaddata.php"
IF %firma%==lipa (SET "url=http://velkoobchodpapirem.cz/loaddata.php")

(
@echo open ftp://%user%:%pass%@%server%
@echo binary
@echo lcd %pathcsv%
@echo put kody.txt ./
@echo put subkody.txt ./
@echo put zbozi.txt ./
@echo put extraceny.txt ./
@echo put odberatele.txt ./
@echo put dodavatele.txt ./
@echo put prijemci.txt ./
@echo put doprava.txt ./
@echo bye
) > %TMP%

%winscp% /script=%TMP% /log=%TMP%.log  /loglevel=0
SET "tmpexitcode=%ERRORLEVEL%"
echo ****** FTP LOG ******
type %TMP%.log
del %TMP% /Q/F >nul 2>&1
del %TMP%.log /Q/F >nul 2>&1

IF NOT "%tmpexitcode%" == "0" SET "ERROR=1" && GOTO :clean

echo ****** WGET LOG ******
%wget% %url% -o %TMP%.log
SET "tmpexitcode=%ERRORLEVEL%"
type %TMP%.log
type loaddata.php
IF NOT "%tmpexitcode%" == "0" SET "ERROR=1" && GOTO :clean

:clean
del loaddata.php /Q/F 2>nul
del %TMP% /Q/F >nul 2>&1
del %TMP%.log /Q/F >nul 2>&1

IF %ERROR%==0 GOTO :exitsuccess

echo ****** ERROR ******
endlocal
exit /B 1

:exitsuccess
echo ****** SUCCESS ******
endlocal
exit /B 0