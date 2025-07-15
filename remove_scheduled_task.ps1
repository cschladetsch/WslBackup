# remove_scheduled_task.ps1
# Removes the WSL backup scheduled task

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "This script requires Administrator privileges. Please run as Administrator." -ForegroundColor Red
    exit 1
}

$taskName = "WSL Ubuntu Backup"
$taskPath = "\WSL Backups\"

try {
    # Check if task exists
    $task = Get-ScheduledTask -TaskName $taskName -TaskPath $taskPath -ErrorAction SilentlyContinue
    
    if ($task) {
        # Remove the task
        Unregister-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Confirm:$false
        Write-Host "Scheduled task '$taskName' removed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Scheduled task '$taskName' not found." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error removing scheduled task: $_" -ForegroundColor Red
}