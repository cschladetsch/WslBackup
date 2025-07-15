# create_scheduled_task.ps1
# Creates a Windows Scheduled Task to run WSL backup every other day at 6pm

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "This script requires Administrator privileges. Please run as Administrator." -ForegroundColor Red
    exit 1
}

$taskName = "WSL Ubuntu Backup"
$taskPath = "\WSL Backups\"
$scriptPath = "C:\Users\chris\home\wsl_back.ps1"

# Check if script exists
if (-not (Test-Path $scriptPath)) {
    Write-Host "Error: Script not found at $scriptPath" -ForegroundColor Red
    Write-Host "Please ensure the backup script exists at this location." -ForegroundColor Yellow
    exit 1
}

# Create the scheduled task action
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""

# Create the trigger - every 2 days at 6:00 PM
$trigger = New-ScheduledTaskTrigger -Daily -DaysInterval 2 -At "6:00PM"

# Create settings to allow the task to run if missed
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable:$false `
    -ExecutionTimeLimit (New-TimeSpan -Hours 2) `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 5)

# Set the principal to run with highest privileges
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Highest

# Create the task
$task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "Automated backup of WSL Ubuntu installation every other day at 6:00 PM"

# Register the task
try {
    Register-ScheduledTask -TaskName $taskName -TaskPath $taskPath -InputObject $task -Force
    Write-Host "Scheduled task '$taskName' created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Task Details:" -ForegroundColor Cyan
    Write-Host "- Runs every 2 days at 6:00 PM" -ForegroundColor White
    Write-Host "- Will run when computer becomes available if missed" -ForegroundColor White
    Write-Host "- Script location: $scriptPath" -ForegroundColor White
    Write-Host ""
    Write-Host "To view or modify the task, open Task Scheduler and navigate to:" -ForegroundColor Yellow
    Write-Host "$taskPath$taskName" -ForegroundColor White
} catch {
    Write-Host "Error creating scheduled task: $_" -ForegroundColor Red
}