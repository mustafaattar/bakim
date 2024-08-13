@echo off
setlocal

:: Parametreleri al
set "startTime=%1"
set "endTime=%2"

:: Zaman dilimlerini saat, dakika, saniye ve milisaniye olarak ayırma
set "startHours=%startTime:~0,2%"
set "startMinutes=%startTime:~3,2%"
set "startSeconds=%startTime:~6,2%"
set "endHours=%endTime:~0,2%"
set "endMinutes=%endTime:~3,2%"
set "endSeconds=%endTime:~6,2%"

:: Zamanları saniye cinsine çevirme
set /a "startTotalSeconds=(startHours*3600)+(startMinutes*60)+startSeconds"
set /a "endTotalSeconds=(endHours*3600)+(endMinutes*60)+endSeconds"

:: Geçen süreyi hesaplama
set /a "elapsedSeconds=endTotalSeconds-startTotalSeconds"
if %elapsedSeconds% lss 0 set /a "elapsedSeconds+=86400"

set /a "elapsedMinutes=elapsedSeconds/60"
set /a "remainingSeconds=elapsedSeconds%%60"

echo Geçen Süre: %elapsedMinutes% dakika %remainingSeconds% saniye

endlocal
exit /b
