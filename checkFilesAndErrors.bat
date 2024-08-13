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

:: Log yazma
call :writeLog "Sistem dosyaları ve hatalar kontrol ediliyor..."

:: Sistem dosyalarını kontrol et
echo Sistem dosyaları taranıyor...
sfc /scannow >> "%logFile%" 2>&1

set "errorCode=%errorlevel%"

if %errorCode% neq 0 (
    call :writeLog "SFC taraması sırasında hata oluştu (Çıkış kodu: %errorCode%)"
    echo Hata bulundu. Ayrıntılar için log dosyasını kontrol edin.
) else (
    call :writeLog "Sistem dosyaları düzgün."
    echo Hata bulunmadı.
)

call :writeLog "İşlem tamamlandı. Log dosyasına bakabilirsiniz: %logFile%"

endlocal
exit /b
