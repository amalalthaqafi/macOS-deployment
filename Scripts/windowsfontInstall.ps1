function Log {
    param(
        [string]$Message
    )
    $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss tt"
    Write-Output "$date - $Message"
}

$logPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\fontInstall.log"
Start-Transcript -Path $logPath -Force

$fontDir = "C:\Windows\Fonts"
$tempDir = Join-Path $env:TEMP "FontInstall"
$regPath = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

$fonts = @(
    @{ FileName = "Cairo-VariableFont_slnt,wght.ttf"; Url = "https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/Cairo-VariableFont_slnt,wght.ttf"; RegName = "Cairo Variable (TrueType)" },
    @{ FileName = "Inter-Italic-VariableFont_opsz,wght.ttf"; Url = "https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/Inter-Italic-VariableFont_opsz,wght.ttf"; RegName = "Inter Italic Variable (TrueType)" },
    @{ FileName = "Inter-VariableFont_opsz,wght.ttf"; Url = "https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/Inter-VariableFont_opsz,wght.ttf"; RegName = "Inter Variable (TrueType)" },
    @{ FileName = "SpaceGrotesk-VariableFont_wght.ttf"; Url = "https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/SpaceGrotesk-VariableFont_wght.ttf"; RegName = "Space Grotesk Variable (TrueType)" },
    @{ FileName = "Tajawal-Black.ttf"; Url = "https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/Tajawal-Black.ttf"; RegName = "Tajawal Black (TrueType)" },
    @{ FileName = "Tajawal-Bold.ttf"; Url = "https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/Tajawal-Bold.ttf"; RegName = "Tajawal Bold (TrueType)" },
    @{ FileName = "Tajawal-ExtraBold.ttf"; Url = "https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/Tajawal-ExtraBold.ttf"; RegName = "Tajawal ExtraBold (TrueType)" },
    @{ FileName = "Tajawal-ExtraLight.ttf"; Url = "https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/Tajawal-ExtraLight.ttf"; RegName = "Tajawal ExtraLight (TrueType)" },
    @{ FileName = "Tajawal-Light.ttf"; Url = "https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/Tajawal-Light.ttf"; RegName = "Tajawal Light (TrueType)" },
    @{ FileName = "Tajawal-Medium.ttf"; Url = "https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/Tajawal-Medium.ttf"; RegName = "Tajawal Medium (TrueType)" },
    @{ FileName = "Tajawal-Regular.ttf"; Url = "https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/Tajawal-Regular.ttf"; RegName = "Tajawal (TrueType)" }
)

foreach ($font in $fonts) {
    $fileName = $font.FileName
    $url = $font.Url
    $regName = $font.RegName
    $tempFile = Join-Path $tempDir $fileName
    $destFile = Join-Path $fontDir $fileName

    try {
        if (Test-Path $destFile) {
            Log "Font already exists: $fileName"
            continue
        }

        Log "Downloading $fileName from $url"
        Invoke-WebRequest -Uri $url -OutFile $tempFile -UseBasicParsing

        if (-not (Test-Path $tempFile)) {
            Log "Download failed: $fileName"
            continue
        }

        Copy-Item -Path $tempFile -Destination $destFile -Force
        Log "Copied $fileName to $fontDir"

        New-ItemProperty -Path "Registry::$regPath" -Name $regName -Value $fileName -PropertyType String -Force | Out-Null
        Log "Added registry entry: $regName -> $fileName"
    }
    catch {
        Log "Error processing $fileName : $($_.Exception.Message)"
    }
}

Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue

Stop-Transcript
exit 0