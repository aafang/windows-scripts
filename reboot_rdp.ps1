cmd
@echo off
echo 正在强制重启 Remote Desktop Services 服务...

REM 获取 TermService 的 PID
for /f "tokens=2 delims=:" %%a in ('sc queryex TermService ^| findstr PID') do (
    set PID=%%a
)

REM 去除 PID 中的空格
set PID=%PID: =%

REM 检查 PID 是否有效
if "%PID%"=="" (
    echo 未找到 TermService 的 PID，请检查服务是否正在运行。
    pause
    exit /b
)

echo 找到 TermService 的 PID: %PID%

REM 强制终止服务
taskkill /f /pid %PID%

REM 启动服务
net start TermService

echo Remote Desktop Services 服务已强制重启。
pause
