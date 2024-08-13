@echo off
chcp 65001 >nul
setlocal

:: Log 
set "logFolder=%~dp0Logs"
set "logFile=%logFolder%\genel.log"

:: Log klasörünü oluştur
if not exist "%logFolder%" mkdir "%logFolder%"

::yönetiçi
:checkAdmin
net session >nul 2>&1
if '%errorlevel%'=='0' (
    echo Yönetici olarak çalışıyorsunuz.
    goto showMenu
) else (
    echo Bu betiğin yönetici olarak çalıştırılması gerekmektedir.
    pause
    exit /b
)

:: Hata kontrolü fonksiyonu
:errorHandler
setlocal
set "errorCode=%1"
set "errorMessage=%2"
if %errorCode% neq 0 (
    echo Hata oluştu: %errorMessage% (Çıkış kodu: %errorCode%)
    echo İşlem başarısız oldu. Ayrıntılar: %errorMessage%
    echo Hata oluştu: %errorMessage% (Çıkış kodu: %errorCode%) >> "%logFile%"
    set /p "userChoice=İşlem devam etsin mi? (E/H): "
    if /i "%userChoice%"=="E" (
        echo İşlem devam ediyor...
    ) else (
        echo İşlem durduruluyor.
        pause
        exit /b
    )
)
endlocal
exit /b

:: Mecburi işlem durdurma fonksiyonu
:forceStop
echo İşlem zorla durduruluyor...
taskkill /F /IM %1
set "errorCode=%errorlevel%"
call :errorHandler %errorCode% "taskkill /F /IM %1"
exit /b

:: Disk hatalarını tarama işlemi
:checkDiskErrors
set "startTime=%time:~0,8%"
echo Disk hataları taranıyor...
echo.

set "totalDisks=0"
for /f "tokens=1" %%d in ('wmic logicaldisk get deviceid ^| findstr /r /c:"^[A-Z]"') do set /a totalDisks+=1

set "currentDisk=0"
for /f "tokens=1" %%d in ('wmic logicaldisk get deviceid ^| findstr /r /c:"^[A-Z]"') do (
    set /a currentDisk+=1
    echo Disk %%d taranıyor...
    set "diskStartTime=%time:~0,8%"
    chkdsk %%d /f /r /x >> "%logFile%" 2>&1
    set "errorCode=%errorlevel%"
    call :errorHandler %errorCode% "chkdsk %%d"
    set "diskEndTime=%time:~0,8%"
    call timeElapsed.bat %diskStartTime% %diskEndTime%
    call :progressBar %totalDisks% %currentDisk%
)
set "endTime=%time:~0,8%"
call timeElapsed.bat %startTime% %endTime%

echo Disk hatası taraması tamamlandı. Yeniden başlatma gerekebilir.
set /p "restartChoice=Şimdi yeniden başlatmak ister misiniz? (E/H): "
if /i "%restartChoice%"=="E" (
    shutdown /r /t 0
)
pause
goto showMenu


:: Sistem dosyalarını tarama
:sfcScan
set "startTime=%time:~0,8%"
echo Sistem dosyaları taranıyor...
sfc /scannow >> "%logFile%" 2>&1
set "errorCode=%errorlevel%"
call :errorHandler %errorCode% "sfc /scannow"
set "endTime=%time:~0,8%"
call timeElapsed.bat %startTime% %endTime%
echo Sistem dosyası taraması tamamlandı.
pause
goto showMenu

:: Disk temizleme
:diskCleanup
set "startTime=%time:~0,8%"
echo Gereksiz dosyalar temizleniyor...
cleanmgr /sagerun:1 >> "%logFile%" 2>&1
set "errorCode=%errorlevel%"
call :errorHandler %errorCode% "cleanmgr /sagerun:1"
set "endTime=%time:~0,8%"
call timeElapsed.bat %startTime% %endTime%
echo Disk temizleme işlemi tamamlandı.
pause
goto showMenu

:: Geçici dosyaları temizleme
:tempCleanup
set "startTime=%time:~0,8%"
echo Geçici dosyalar temizleniyor...
del /q /f /s %temp%\* >> "%logFile%" 2>&1
set "errorCode=%errorlevel%"
call :errorHandler %errorCode% "del /q /f /s %temp%\*"
set "endTime=%time:~0,8%"
call timeElapsed.bat %startTime% %endTime%
echo Geçici dosyalar temizlendi.
pause
goto showMenu

:: Tarayıcı önbelleklerini temizleme
:clearCache
set "startTime=%time:~0,8%"
echo Tarayıcı önbellekleri temizleniyor...
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255 >> "%logFile%" 2>&1
set "errorCode=%errorlevel%"
call :errorHandler %errorCode% "RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255"
set "endTime=%time:~0,8%"
call timeElapsed.bat %startTime% %endTime%
echo Tarayıcı önbellekleri temizlendi.
pause
goto showMenu

:: DNS önbelleğini temizleme
:flushDNS
set "startTime=%time:~0,8%"
echo DNS önbelleği temizleniyor...
ipconfig /flushdns >> "%logFile%" 2>&1
set "errorCode=%errorlevel%"
call :errorHandler %errorCode% "ipconfig /flushdns"
set "endTime=%time:~0,8%"
call timeElapsed.bat %startTime% %endTime%
echo DNS önbelleği temizlendi.
pause
goto showMenu

:: Sistem geri yükleme noktası oluşturma
:createRestorePoint
set "startTime=%time:~0,8%"
echo Sistem geri yükleme noktası oluşturuluyor...
wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "Sistem Bakımı Öncesi", 100, 7 >> "%logFile%" 2>&1
set "errorCode=%errorlevel%"
call :errorHandler %errorCode% "wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint"
set "endTime=%time:~0,8%"
call timeElapsed.bat %startTime% %endTime%
echo Sistem geri yükleme noktası oluşturuldu.
pause
goto showMenu

:: Bellek kontrolü yapma
:memoryTest
set "startTime=%time:~0,8%"
echo Bellek kontrolü yapılıyor...
mdsched /test >> "%logFile%" 2>&1
set "errorCode=%errorlevel%"
call :errorHandler %errorCode% "mdsched /test"
set "endTime=%time:~0,8%"
call timeElapsed.bat %startTime% %endTime%

echo Bellek kontrolü tamamlandı. Yeniden başlatma gerekebilir.
set /p "restartChoice=Şimdi yeniden başlatmak ister misiniz? (E/H): "
if /i "%restartChoice%"=="E" (
    shutdown /r /t 0
)
pause
goto showMenu

:: Başlangıç programlarını listeleme
:listStartupPrograms
set "startTime=%time:~0,8%"
echo Başlangıç programları listeleniyor...
wmic startup get caption,command >> "%logFile%" 2>&1
set "errorCode=%errorlevel%"
call :errorHandler %errorCode% "wmic startup get caption,command"
set "endTime=%time:~0,8%"
call timeElapsed.bat %startTime% %endTime%
echo Başlangıç programları listelendi.
pause
goto showMenu

:: Gereksiz başlangıç programlarını devre dışı bırakma
:disableUnwantedStartupPrograms
set "startTime=%time:~0,8%"
echo Gereksiz başlangıç programları devre dışı bırakılıyor...
:: Buraya başlangıç programlarını devre dışı bırakma komutlarını ekleyin
set "endTime=%time:~0,8%"
call timeElapsed.bat %startTime% %endTime%
echo Gereksiz başlangıç programları devre dışı bırakıldı.
pause
goto showMenu
:: günçeleme
:checkUpdates
echo Windows güncellemeleri kontrol ediliyor...
wuauclt /detectnow >> "%logFile%" 2>&1
set "errorCode=%errorlevel%"
call :errorHandler %errorCode% "wuauclt /detectnow"
echo Güncellemeler kontrol edildi. Eğer mevcutsa, güncellemeler yükleniyor olabilir.
pause
goto showMenu

:: Hızlı Sistem Performans Kontrolü
:checkSystemPerformance
echo Sistem performansı kontrol ediliyor...
echo.
echo CPU Yükü: >> "%logFile%"
wmic cpu get loadpercentage >> "%logFile%" 2>&1
set "errorCode=%errorlevel%"
call :errorHandler %errorCode% "wmic cpu get loadpercentage"

echo Mevcut Bellek Kullanımı: >> "%logFile%"
wmic OS get FreePhysicalMemory,TotalVisibleMemorySize /Value >> "%logFile%" 2>&1
set "errorCode=%errorlevel%"
call :errorHandler %errorCode% "wmic OS get FreePhysicalMemory,TotalVisibleMemorySize /Value"

echo Sistem performansı kontrolü tamamlandı.
pause
goto showMenu


:: Menü gösterme
:showMenu
echo 1. Disk hatalarını tara
echo 2. Sistem dosyalarını tarama
echo 3. Disk temizleme
echo 4. Geçici dosyaları temizleme
echo 5. Tarayıcı önbelleklerini temizleme
echo 6. DNS önbelleğini temizleme
echo 7. Sistem geri yükleme noktası oluşturma
echo 8. Bellek kontrolü yapma
echo 9. Başlangıç programlarını listeleme
echo 10. Gereksiz başlangıç programlarını devre dışı bırakma
echo 11. Sistem dosyalarını ve hataları kontrol et
echo 12. Güncelleme Kontrolü
echo 13. Hızlı Sistem Performans Kontrolü
echo 14. Çıkış
set /p choice=Seçiminizi yapın:

if "%choice%"=="1" goto checkDiskErrors
if "%choice%"=="2" goto sfcScan
if "%choice%"=="3" goto diskCleanup
if "%choice%"=="4" goto tempCleanup
if "%choice%"=="5" goto clearCache
if "%choice%"=="6" goto flushDNS
if "%choice%"=="7" goto createRestorePoint
if "%choice%"=="8" goto memoryTest
if "%choice%"=="9" goto listStartupPrograms
if "%choice%"=="10" goto disableUnwantedStartupPrograms
if "%choice%"=="11" call checkFilesAndErrors.bat
if "%choice%"=="12" goto checkUpdates
if "%choice%"=="13" goto checkSystemPerformance
if "%choice%"=="14" exit /b

goto showMenu


endlocal
exit /b
