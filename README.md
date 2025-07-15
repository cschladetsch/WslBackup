# WslBackup

A PowerShell script to backup and restore WSL (Windows Subsystem for Linux) Ubuntu installations.

## Demo

![Demo](/Resources/CreateTask.png)

## Features

- **Automated Backups**: Creates timestamped backups of your WSL Ubuntu installation
- **Backup Management**: Automatically keeps only the last 5 backups to save disk space
- **Easy Restore**: Interactive restore process with backup selection
- **Size Information**: Shows backup sizes for better management

## Requirements

- Windows 10/11 with WSL 2 installed
- PowerShell 5.0 or higher
- WSL Ubuntu distribution installed
- Sufficient disk space in `D:\wsl_backup` (or modify the script to use a different location)

## Usage

### Creating a Backup

```powershell
.\backup_wsl.ps1
```

This will:
1. Shutdown WSL
2. Export your Ubuntu installation to a `.tar` file
3. Save it with a timestamp in `D:\wsl_backup`
4. Remove old backups (keeping only the last 5)

### Restoring from a Backup

```powershell
.\backup_wsl.ps1 -Restore
```

This will:
1. List all available backups with their creation dates and sizes
2. Let you select which backup to restore
3. Ask for confirmation before proceeding
4. Unregister the current Ubuntu installation
5. Import the selected backup

## Configuration

You can modify these variables in the script:
- `$backupDir`: Change the backup directory location (default: `D:\wsl_backup`)
- `$maxBackups`: Number of backups to keep (default: 5)

## Important Notes

- **Data Loss Warning**: The restore process will completely replace your current Ubuntu installation
- **Disk Space**: Backups can be large (several GB), ensure you have sufficient disk space
- **WSL Path**: The script assumes the default WSL Ubuntu installation path. Modify if you've installed Ubuntu from a different source

## Automated Backups

The repository includes scripts to set up automated backups using Windows Task Scheduler:

### Setting up Automated Backups

1. **Run PowerShell as Administrator**
2. **Run the setup script**:
   ```powershell
   .\create_scheduled_task.ps1
   ```

This creates a scheduled task that:
- Runs backups every 2 days at 6:00 PM
- Automatically runs later if the computer was off at the scheduled time
- Has built-in retry logic for failed backups
- Runs with elevated privileges for WSL access

### Removing Automated Backups

To remove the scheduled task:
```powershell
.\remove_scheduled_task.ps1
```

### Manual Task Management

You can also manage the task through Windows Task Scheduler:
1. Open Task Scheduler
2. Navigate to `Task Scheduler Library > WSL Backups`
3. Find "WSL Ubuntu Backup" task

## License

This project is provided as-is for personal use.
