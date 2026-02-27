# Valheim Backup Downloader
# Save as get_valheim_backup.ps1

# === CONFIGURATION - EDIT THESE VALUES ===
$ServerIP = "your-server-ip-here"
$ServerUser = "root"
$BackupPath = "/root/valheim-server/config/backups"
$LocalPath = "C:\ValheimBackups"
# =========================================

# Create local folder if it doesn't exist
if (-not (Test-Path $LocalPath)) {
    New-Item -ItemType Directory -Path $LocalPath -Force | Out-Null
    Write-Host "Created folder: $LocalPath"
}

Write-Host "Connecting to $ServerIP..."

# Find the newest backup file
$newestBackup = ssh $ServerUser@$ServerIP "ls -t $BackupPath/*.zip 2>/dev/null | head -1"

if ([string]::IsNullOrEmpty($newestBackup)) {
    Write-Host "ERROR: No backup files found in $BackupPath!"
    exit 1
}

$backupFileName = $newestBackup.Split('/')[-1]
$localFile = Join-Path $LocalPath $backupFileName

# Check if file already exists
$downloadNeeded = $true
if (Test-Path $localFile) {
    $existingFile = Get-Item $localFile
    
    # Get remote file size
    $remoteSize = ssh $ServerUser@$ServerIP "stat -c %s $newestBackup 2>/dev/null"
    if (-not $remoteSize) { $remoteSize = 0 }
    
    if ($existingFile.Length -eq [int]$remoteSize) {
        Write-Host "File already exists and is identical: $backupFileName"
        $downloadNeeded = $false
    }
}

if ($downloadNeeded) {
    Write-Host "Downloading: $backupFileName"
    
    # Download the file
    scp $ServerUser@$ServerIP`:"$newestBackup" $localFile
    
    if ($LASTEXITCODE -eq 0) {
        $fileInfo = Get-Item $localFile
        $sizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
        
        Write-Host "SUCCESS: Download completed!"
        Write-Host "Size: $sizeMB MB"
        Write-Host "Saved to: $localFile"
        
        # Keep only last 10 backups
        $backups = Get-ChildItem -Path $LocalPath -Filter "*.zip" | Sort-Object LastWriteTime -Descending
        if ($backups.Count -gt 10) {
            $backups | Select-Object -Skip 10 | ForEach-Object {
                Write-Host "Removing old backup: $($_.Name)"
                Remove-Item $_.FullName -Force
            }
        }
    } else {
        Write-Host "ERROR: Download failed with exit code $LASTEXITCODE"
        exit 1
    }
} else {
    Write-Host "No new backup needed - latest file already exists"
}
