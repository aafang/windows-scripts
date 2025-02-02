Write-Host "正在强制重启 Remote Desktop Services 服务..."

# 获取 TermService 的 PID
$serviceInfo = sc queryex TermService
$pidLine = $serviceInfo -match "PID"
$pid = $pidLine -replace "\D+", ""

# 检查 PID 是否有效
if (-not $pid) {
    Write-Host "未找到 TermService 的 PID，请检查服务是否正在运行。"
    pause
    exit
}

Write-Host "找到 TermService 的 PID: $pid"

# 强制终止服务
taskkill /f /pid $pid

# 启动服务
Start-Service -Name TermService

Write-Host "Remote Desktop Services 服务已强制重启。"
pause
