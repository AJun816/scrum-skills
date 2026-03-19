@echo off
:: Scrum Skills - Windows One-click Installer
:: 双击此文件自动安装技能组

set SCRIPT_DIR=%~dp0
set INSTALL_SH=%SCRIPT_DIR%install.sh

:: 查找 Git Bash
set GIT_BASH=
if exist "C:\Program Files\Git\bin\bash.exe" set GIT_BASH=C:\Program Files\Git\bin\bash.exe
if exist "C:\Program Files (x86)\Git\bin\bash.exe" set GIT_BASH=C:\Program Files (x86)\Git\bin\bash.exe

if "%GIT_BASH%"=="" (
  echo.
  echo [ERROR] 未找到 Git Bash，请先安装 Git for Windows
  echo   下载地址：https://git-scm.com/download/win
  echo.
  pause
  exit /b 1
)

echo.
echo 正在启动安装...
"%GIT_BASH%" -c "sh '%INSTALL_SH%'"

pause
