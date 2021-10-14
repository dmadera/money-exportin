SET "dir=%~dp0"

%dir%assets\upload-loaddata.bat S4_Agenda_PEMA > %dir%exportin_PEMA.log
type %dir%exportin_PEMA.log

:: %dir%assets\upload-loaddata.bat S4_Agenda_LIPA > %dir%exportin_LIPA.log
:: type %dir%exportin_LIPA.log

exit /B 0