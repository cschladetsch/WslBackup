# backup_wsl_ubuntu.ps1

param(
    [switch]$Restore
)

# Set backup location and parameters
$backupDir = "D:\wsl_backup"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "$backupDir\ubuntu_backup_$timestamp.tar"
$maxBackups = 5  # Keep last 5 backups

# Create backup directory if it doesn't exist
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Force -Path $backupDir
    Write-Host "Created backup directory: $backupDir" -ForegroundColor Green
}

if ($Restore) {
    # Restore mode
    Write-Host "=== WSL Ubuntu Restore Mode ===" -ForegroundColor Cyan
    
    # List available backups
    $backups = Get-ChildItem $backupDir -Filter "ubuntu_backup_*.tar" | Sort-Object CreationTime -Descending
    
    if ($backups.Count -eq 0) {
        Write-Host "No backups found in $backupDir" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "`nAvailable backups:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $backups.Count; $i++) {
        $size = ($backups[$i].Length / 1GB).ToString('0.00')
        Write-Host "$($i + 1). $($backups[$i].Name) - $size GB - Created: $($backups[$i].CreationTime)" -ForegroundColor White
    }
    
    # Get user selection
    $selection = Read-Host "`nSelect backup number to restore (1-$($backups.Count))"
    
    if ($selection -match '^\d+$' -and [int]$selection -ge 1 -and [int]$selection -le $backups.Count) {
        $selectedBackup = $backups[[int]$selection - 1]
        Write-Host "`nSelected: $($selectedBackup.Name)" -ForegroundColor Green
        
        # Confirm restore
        $confirm = Read-Host "WARNING: This will replace your current Ubuntu installation. Continue? (yes/no)"
        
        if ($confirm -eq "yes") {
            # Shutdown WSL
            Write-Host "Shutting down WSL..." -ForegroundColor Yellow
            wsl --shutdown
            
            # Unregister existing Ubuntu
            Write-Host "Unregistering existing Ubuntu installation..." -ForegroundColor Yellow
            wsl --unregister Ubuntu
            
            # Restore from backup
            Write-Host "Restoring from backup... This might take a while..." -ForegroundColor Yellow
            try {
                wsl --import Ubuntu "C:\Users\$env:USERNAME\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu_79rhkp1fndgsc\LocalState" $selectedBackup.FullName
                if ($?) {
                    Write-Host "Restore completed successfully!" -ForegroundColor Green
                    Write-Host "You can now start Ubuntu from the Start menu or by running 'wsl'" -ForegroundColor Cyan
                }
            } catch {
                Write-Host "Error during restore: $_" -ForegroundColor Red
            }
        } else {
            Write-Host "Restore cancelled." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Invalid selection." -ForegroundColor Red
        exit 1
    }
} else {
    # Backup mode (original functionality)
    Write-Host "=== WSL Ubuntu Backup Mode ===" -ForegroundColor Cyan
    
    # Shutdown WSL
    Write-Host "Shutting down WSL..." -ForegroundColor Yellow
    wsl --shutdown

    # Create backup
    Write-Host "Creating backup... This might take a while..." -ForegroundColor Yellow
    try {
        wsl --export Ubuntu $backupFile
        if ($?) {
            Write-Host "Backup completed successfully: $backupFile" -ForegroundColor Green

            # Cleanup old backups
            $oldBackups = Get-ChildItem $backupDir -Filter "ubuntu_backup_*.tar" |
                         Sort-Object CreationTime -Descending |
                         Select-Object -Skip $maxBackups

            foreach ($backup in $oldBackups) {
                Remove-Item $backup.FullName -Force
                Write-Host "Removed old backup: $($backup.Name)" -ForegroundColor Gray
            }
        }
    } catch {
        Write-Host "Error creating backup: $_" -ForegroundColor Red
    }

    # Display backup size
    if (Test-Path $backupFile) {
        $size = (Get-Item $backupFile).Length / 1GB
        Write-Host "Backup size: $($size.ToString('0.00')) GB" -ForegroundColor Cyan
    }
}