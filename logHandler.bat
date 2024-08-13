@echo off
setlocal

:: Log dosyası ve klasörü
set "logFolder=%~dp0Logs"
set "logFile=%logFolder%\genel.log"

:: Log klasörünü oluştur
if not exist "%logFolder%" mkdir "%logFolder%"

:: Log yazma fonksiyonu
:writeLog
set "message=%1"
echo %date% %time% - %message% >> "%logFile%"
exit /b

:: Örnek kullanım
:: Log dosyasına mesaj yazmak için kullanın
call :writeLog "Sistem kontrolü başlatıldı."
call :writeLog "Sistem dosyaları taranıyor..."
:: Bu noktada başka işlemler yapılabilir
call :writeLog "Sistem dosyaları taraması tamamlandı."

endlocal
exit /b
