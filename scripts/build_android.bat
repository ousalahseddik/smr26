@echo off
setlocal enabledelayedexpansion

:: ============================================================
::  build_android.bat  <config_name>
::  Exemple : scripts\build_android.bat smr26
:: ============================================================

SET CONFIG=%1

IF "%CONFIG%"=="" (
    echo [ERREUR] Specifie un nom de config. Ex: scripts\build_android.bat smr26
    exit /b 1
)

SET CONFIG_FILE=configs\%CONFIG%.json
SET ICON_SRC=assets\icons\%CONFIG%.png
SET ICON_DST=assets\icon\app_icon.png

IF NOT EXIST "%CONFIG_FILE%" (
    echo [ERREUR] Fichier de config introuvable : %CONFIG_FILE%
    exit /b 1
)

echo.
echo =====================================================
echo  Build : %CONFIG%
echo =====================================================

:: ── 1. Icone ───────────────────────────────────────────────
IF EXIST "%ICON_SRC%" (
    echo [1/3] Icone trouvee : %ICON_SRC%
    copy /Y "%ICON_SRC%" "%ICON_DST%" >nul
    cmd /c dart run flutter_launcher_icons
    echo [1/3] Icones generees.
) ELSE (
    echo [1/3] Pas d'icone specifique, icone par defaut utilisee.
)

:: ── 2. Build APK ───────────────────────────────────────────
echo [2/3] Build APK en cours ^(peut prendre 3-5 minutes^)...
cmd /c flutter build apk --release --dart-define-from-file=%CONFIG_FILE%

IF %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] Build echoue.
    exit /b 1
)

:: ── 3. Renommer l'APK ──────────────────────────────────────
echo [3/3] Renommage de l'APK...
SET OUTPUT_DIR=build\app\outputs\flutter-apk
SET FINAL_APK=%OUTPUT_DIR%\%CONFIG%-release.apk

IF EXIST "%OUTPUT_DIR%\app-release.apk" (
    move /Y "%OUTPUT_DIR%\app-release.apk" "%FINAL_APK%" >nul
    echo.
    echo  APK genere : %FINAL_APK%
) ELSE (
    echo [AVERTISSEMENT] APK introuvable au chemin attendu.
)

echo.
echo  Build termine avec succes !
echo =====================================================
endlocal
