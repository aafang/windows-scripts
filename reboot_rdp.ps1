try {
    Write-Host "正在强制重启 Remote Desktop Services 服务..."
    # 获取 TermService 的 PID
    Write-Host "正在获取 TermService 的 PID..."
    $serviceInfo = sc.exe queryex TermService
    if (-not $serviceInfo) {
        throw "无法获取 TermService 的信息，请检查服务是否存在。"
    }
    # 提取包含 PID 的行
    $pidLine = $serviceInfo | Where-Object { $_ -match "PID" }
    if (-not $pidLine) {
        throw "未找到 TermService 的 PID，请检查服务是否正在运行。"
    }
    # 从 PID 行中提取数字
    $ServicePID = ($pidLine -replace '\D+') -as [int]
    if (-not $ServicePID) {
        throw "无法解析 TermService 的 PID。"
    }
    Write-Host "找到 TermService 的 PID: $ServicePID"
    # 强制终止服务
    Write-Host "正在强制终止 TermService..."
    taskkill /f /pid $ServicePID
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
