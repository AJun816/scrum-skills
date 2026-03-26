@echo off
:: Scrum Skills - Windows One-click Installer
:: 双击此文件自动安装技能组（PowerShell，无需 Git Bash）

set SCRIPT_DIR=%~dp0
set INSTALL_PS1=%SCRIPT_DIR%install.ps1

echo.
echo 正在启动安装...
powershell -NoProfile -ExecutionPolicy Bypass -File "%INSTALL_PS1%"
if errorlevel 1 (
  echo.
  echo [ERROR] 安装失败，请检查 PowerShell 输出日志。
)

pause
