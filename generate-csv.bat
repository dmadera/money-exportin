@echo off
SETLOCAL
SET "ERROR=0"
SET "dir=%~dp0"
SET "dirsql=%dir%sql\"
SET "dircsv=%dir%csv\"
SET "ext=.txt"
SET "TMP1=%TEMP%\generatecsvbat1.tmp"
SET "TMP2=%TEMP%\generatecsvbat2.tmp"
SET "TMP3=%TEMP%\generatecsvbat3.tmp"

SET "DB=%1"

SET /P sqlserver=<%dir%..\Settings\db-server
SET /P sqluser=<%dir%..\Settings\db-user
SET /P sqlpass=<%dir%..\Settings\db-password

echo Deleting files in %dircsv%
del /S /Q /F "%dircsv%*" >nul 2>&1

for /f %%f IN ('dir /b %dirsql%*.sql') do (
	echo SET NOCOUNT ON > %TMP3%
	echo USE %DB% >> %TMP3%
	echo GO >> %TMP3%
	type "%dirsql%%%f" >> %TMP3%

	sqlcmd -S %sqlserver% -U %sqluser% -P %sqlpass% -i %TMP3% -o "%TMP1%" -h -1 -s";" -W -f 1250
	IF NOT "%ERRORLEVEL%" == "0" SET "ERROR=1" && GOTO :clean	
	more +1 "%TMP1%" > "%TMP2%"
	move /y "%TMP2%" "%dircsv%%%~nf%ext%" > nul
	echo Created - %dircsv%%%~nf%ext%
	del /F /Q %TMP1% >nul 2>&1
	del /F /Q %TMP2% >nul 2>&1
)

:clean
del /F /Q %TMP1% >nul 2>&1
del /F /Q %TMP2% >nul 2>&1
del /F /Q %TMP3% >nul 2>&1

IF %ERROR%==0 GOTO :exitsuccess
endlocal
exit /B 1

:exitsuccess
echo Success CSV files created
endlocal
exit /B 0