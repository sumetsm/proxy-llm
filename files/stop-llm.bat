@echo off
title LLM Server - Shutting Down...
color 0C

echo ========================================
echo   LLM Server Shutdown
echo ========================================
echo.

echo [1/3] Stopping Ollama...
taskkill /F /IM ollama.exe >nul 2>&1
echo       Done!

echo [2/3] Stopping ngrok...
taskkill /F /IM ngrok.exe >nul 2>&1
echo       Done!

echo [3/3] Stopping Proxy (uvicorn)...
for /f "tokens=5" %%a in ('netstat -aon ^| find ":8000" ^| find "LISTENING"') do (
    taskkill /F /PID %%a >nul 2>&1
)
echo       Done!

echo.
echo ========================================
echo   All services stopped! Happy gaming!
echo ========================================
echo.
pause