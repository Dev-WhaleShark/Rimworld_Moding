@echo off
setlocal

REM === 설정 부분: 네 환경에 맞게 수정 ===
REM 작업(백업) 폴더 (이 스크립트가 있는 폴더를 기준으로 자동 설정)
set "SRC=%~dp0"

REM RimWorld 설치 경로의 모드 폴더
set "DST=C:\Program Files (x86)\Steam\steamapps\common\RimWorld\Mods\MyTestMod"


REM DLL 이름 (csproj에서 설정한 AssemblyName과 같아야 함)
set "DLL_NAME=MyTestMode"

REM 타깃 프레임워크 (빌드 결과 폴더 이름, 예: net48)
set "TFM=net48"

REM === 1) C# 빌드 ===
echo [Build] dotnet build .vscode\mod.csproj -c Release
dotnet build "%SRC%.vscode\mod.csproj" -c Release
if errorlevel 1 (
    echo Build failed.
    exit /b 1
)

REM === 2) RimWorld 모드 폴더 준비 ===
if not exist "%DST%" mkdir "%DST%"
if not exist "%DST%\Assemblies" mkdir "%DST%\Assemblies"

REM === 3) DLL 복사 ===
echo [Copy] DLL to Assemblies
copy /Y "%SRC%bin\Release\%TFM%\%DLL_NAME%.dll" "%DST%\Assemblies\%DLL_NAME%.dll"

REM === 4) XML / Textures 동기화 ===
echo [Sync] About
if exist "%SRC%About" robocopy "%SRC%About" "%DST%\About" /MIR

echo [Sync] Defs
if exist "%SRC%Defs" robocopy "%SRC%Defs" "%DST%\Defs" /MIR

echo [Sync] Textures
if exist "%SRC%Textures" robocopy "%SRC%Textures" "%DST%\Textures" /MIR

echo Done.
endlocal