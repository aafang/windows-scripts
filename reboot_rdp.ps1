try {
    Write-Host "正在强制重启 Remote Desktop Services 服务..."

    # 获取 TermService 的 PID
    Write-Host "正在获取 TermService 的 PID..."
    $serviceInfo = sc queryex TermService
    if (-not $serviceInfo) {
        throw "无法获取 TermService 的信息，请检查服务是否存在。"
    }

    $pidLine = $serviceInfo -match "PID"
    if (-not $pidLine) {
        throw "未找到 TermService 的 PID，请检查服务是否正在运行。"
    }

    $pid = $pidLine -replace "\D+", ""
    Write-Host "找到 TermService 的 PID: $pid"

    # 强制终止服务
    Write-Host "正在强制终止 TermService..."
    taskkill /f /pid $pid
    if ($LASTEXITCODE -ne 0) {
        throw "终止 TermService 失败，请检查权限或 PID 是否正确。"
    }

    # 启动服务
    Write-Host "正在启动 TermService..."
    Start-Service -Name TermService -ErrorAction Stop
    Write-Host "Remote Desktop Services 服务已强制重启。"
}
catch {
    Write-Host "发生错误: $_"
}
finally {
    pause
}
