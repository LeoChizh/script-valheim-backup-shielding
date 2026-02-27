# Valheim Windows Backup Tool

Simple, straightforward scripts to automatically download your Valheim server backups from a remote Linux server to your Windows machine.

## Overview

This repository contains two scripts that work together to:
- Find the newest backup file on your Valheim server
- Download it to your Windows PC
- Maintain a reverse-order log file (newest entries first)
- Automatically clean up old backups (keeps last 10)

Works with Windows Task Scheduler for automatic daily backups.

## Files

| File | Purpose |
|------|---------|
| `run_valheim_backup.bat` | Batch wrapper that handles logging and timestamp |
| `get_valheim_backup.ps1` | PowerShell script that does the actual backup download |

## Configuration

### 1. Edit `get_valheim_backup.ps1`

Change these values at the top of the script:

```powershell
# === CONFIGURATION - EDIT THESE VALUES ===
$ServerIP = "your-server-ip-here"     # Your Valheim server IP
$ServerUser = "root"                   # SSH username (usually root)
$BackupPath = "/root/valheim-server/config/backups"  # Remote backup path
$LocalPath = "C:\ValheimBackups"       # Where to save on your PC
# =========================================
```

### 2. Edit `run_valheim_backup.bat`

Update the paths to match your setup:

```batch
set SCRIPT_PATH=C:\Path\To\get_valheim_backup.ps1
set LOG_FILE=C:\ValheimBackups\backup.log
```

## How It Works

### The Batch File (`run_valheim_backup.bat`)
- Creates a timestamp entry (`===== date time =====`)
- Runs the PowerShell script
- **Smart logging**: New entries go at the TOP of the log file
- Old log content is appended after the new entry

### The PowerShell Script (`get_valheim_backup.ps1`)
1. Connects to your server via SSH
2. Finds the newest `.zip` backup file
3. Checks if you already have that exact file (compares file sizes)
4. Downloads only if it's new/different
5. Shows download progress and file size
6. Keeps only the last 10 backups (auto-cleanup)

## Log File Format

The log file (`backup.log`) shows newest entries first:

```
===== Mon 03/01/2024 15:00:01 =====
Connecting to 192.168.1.100...
Found: worlds_local-20240301-143022.zip
Downloading: worlds_local-20240301-143022.zip
SUCCESS: Download completed!
Size: 15.23 MB
Saved to: C:\ValheimBackups\worlds_local-20240301-143022.zip
Removing old backup: worlds_local-20240228-103022.zip

===== Sun 02/29/2024 15:00:01 =====
File already exists and is identical: worlds_local-20240229-143022.zip
No new backup needed - latest file already exists
```

## Scheduling with Windows Task Scheduler

1. Open **Task Scheduler**
2. Click **"Create Task"**
3. **General tab**: 
   - Name: "Valheim Daily Backup"
   - Check "Run whether user is logged on or not"
4. **Triggers tab**:
   - New → Daily → Set time (e.g., 3:00 PM)
5. **Actions tab**:
   - New → Start a program
   - Program: `C:\Path\To\run_valheim_backup.bat`
6. Click **OK** and enter your password

## Requirements

- Windows 10/11 with **OpenSSH Client** installed
  - Settings → Apps → Optional Features → Add "OpenSSH Client"
- SSH access to your Valheim server (password or key-based)
- Valheim server running the [lloesche/valheim-server](https://github.com/lloesche/valheim-server-docker) Docker image with backups enabled

## Checking Your Backups

View the log:
```batch
type C:\ValheimBackups\backup.log
```

See just the last few entries:
```batch
powershell -Command "Get-Content C:\ValheimBackups\backup.log -Tail 20"
```

## Notes

- The script keeps only the **last 10 backups** automatically
- It won't re-download files you already have (saves bandwidth)
- Log shows timestamps and success/failure for each run
- Newest log entries appear at the **top** of the file

## Troubleshooting

**"No backup files found!"**
- Check that backups are enabled on your Valheim server (`BACKUPS=true`)
- Verify the remote path: SSH in and run `ls -la /root/valheim-server/config/backups/`

**SSH connection fails**
- Test manually: `ssh root@your-server-ip`
- Make sure OpenSSH Client is installed on Windows

**Permission denied**
- You might need to set up SSH key authentication
- Or the script will prompt for password each time (not ideal for scheduling)

## License 

MIT - Feel free to use and modify!
