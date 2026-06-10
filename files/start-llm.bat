@echo off
title LLM Server - Starting...
color 0A

echo ========================================
echo   LLM Server Startup
echo ========================================
echo.

:: Kill any existing instances first
echo [1/4] Cleaning up old processes...
taskkill /F /IM ollama.exe >nul 2>&1
taskkill /F /IM ngrok.exe >nul 2>&1

:: Kill proxy on port 8000 if running
for /f "tokens=5" %%a in ('netstat -aon ^| find ":8000" ^| find "LISTENING"') do (
    taskkill /F /PID %%a >nul 2>&1
)

echo       Waiting for ports to free up...
timeout /t 5 >nul

:: Start Ollama
echo [2/4] Starting Ollama...
start "Ollama Server" cmd /k "set OLLAMA_HOST=0.0.0.0 && ollama serve"
echo       Waiting for Ollama to be ready...
timeout /t 5 >nul

:: Start Proxy
echo [3/4] Starting Proxy Server...
start "Proxy Server" cmd /k "cd /d C:\Users\sumet\OneDrive\Desktop\proxy-llm && python -m uvicorn proxy:app --port 8000"
echo       Waiting for Proxy to be ready...
timeout /t 3 >nul

:: Start ngrok
echo [4/4] Starting ngrok tunnel...
start "ngrok Tunnel" cmd /k "ngrok http 8000"

echo.
echo ========================================
echo   All services started!
echo   Check the ngrok window for your URL
echo ========================================
echo.
pause