# 生成有效随机端口（排除默认3389）
do {
    $portvalue = Get-Random -Minimum 49152 -Maximum 65535
} until ($portvalue -ne 3389)

# 删除旧防火墙规则（如果存在）
$rules = @('RDPPORT-TCP-In','RDPPORT-UDP-In')
foreach ($rule in $rules) {
    if (Get-NetFirewallRule -DisplayName $rule -ErrorAction SilentlyContinue) {
        Remove-NetFirewallRule -DisplayName $rule
    }
}

try {
    # 修改注册表设置
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "PortNumber" -Value $portvalue -Force
    
    # 创建新防火墙规则
    $params = @{
        DisplayName = 'RDPPORT-TCP-In'
        Direction   = 'Inbound'
        Protocol    = 'TCP'
        LocalPort   = $portvalue
        Action      = 'Allow'
        Profile     = 'Any'
        Enabled     = 'True'
    }
    New-NetFirewallRule @params
    
    $params.DisplayName = 'RDPPORT-UDP-In'
    $params.Protocol = 'UDP'
    New-NetFirewallRule @params

    # 验证设置
    $registry = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "PortNumber"
    
    Write-Host "`n修改成功！" -ForegroundColor Green
    Write-Host "新RDP端口: $($registry.PortNumber)"
    Write-Host "防火墙规则已创建:"
    Get-NetFirewallRule -DisplayName 'RDPPORT-*' | Select-Object DisplayName,Protocol,LocalPort
    
    Write-Warning "请重启远程桌面服务或计算机使更改生效"
    Write-Host "立即重启远程桌面服务？ (y/n)" -ForegroundColor Cyan -NoNewline
    $choice = Read-Host
    if ($choice -eq 'y') {
        Restart-Service TermService -Force
        Write-Host "服务已重启" -ForegroundColor Green
    }
}
catch {
    Write-Error "配置失败: $_"
    exit 1
}
