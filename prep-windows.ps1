Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# Function to install a Windows feature
function Install-WindowsFeature {
    param (
        [string]$FeatureName,
        [string]$FeatureDescription
    )
    try {
        $RebootRequired = $false
        Write-Verbose "Checking for $FeatureDescription..." -Verbose
        $Feature = Get-WindowsOptionalFeature -Online -FeatureName $FeatureName
        if ($Feature.State -ne 'Enabled') {
            Write-Verbose " ...Installing $FeatureDescription." -Verbose
            $InstallResult = Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName $FeatureName
            if ($InstallResult.RestartNeeded -eq $true) {
                $RebootRequired = $true
            }
        } else {
            Write-Verbose " ...$FeatureDescription already installed." -Verbose
        }
    } catch {
        Write-Verbose "Error installing $FeatureDescription $_" -Verbose
    }
    $RebootRequired
}

# Install WSL if necessary
$WSLFeatureInstallResult = Install-WindowsFeature -FeatureName 'Microsoft-Windows-Subsystem-Linux' -FeatureDescription 'Windows Subsystem for Linux'

# Install Virtual Machine Platform if necessary
$VMPFeatureInstallResult = Install-WindowsFeature -FeatureName 'VirtualMachinePlatform' -FeatureDescription 'Virtual Machine Platform'

if (($VMPFeatureInstallResult -or $WSLFeatureInstallResult) -eq $true){
    Write-Warning "You must reboot before continuing to install and setup WSL. If you choose no, you must reboot manually before re-running this script."
    $CancelReboot = Read-Host 'Do you want to reboot now? [Y/N]'
    if ($CancelReboot -eq 'y'){
        shutdown /t 10 /r /c 'Reboot required to finish installing WSL2. After reboot run this script again elevated.'
    }
}

# Check for Kernel Update Package
Write-Host('Checking for Windows Subsystem for Linux Update...')
$uninstall64 = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' | ForEach-Object { Get-ItemProperty $_.PSPath } | Select-Object DisplayName, Publisher, DisplayVersion, InstallDate
if ($uninstall64.DisplayName -contains 'Windows Subsystem for Linux Update') {
    $CheckUpdate = $true
} else {
    $CheckUpdate = $false
}

if ($CheckUpdate -eq $false){
    try {
        Write-Host(' ...Downloading WSL2 Kernel Update.')
        $kernelURI = 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi'
        $kernelUpdate = ((Get-Location).Path) + '\wsl_update_x64.msi'
        (New-Object System.Net.WebClient).DownloadFile($kernelURI, $kernelUpdate)
        Write-Host(' ...Installing WSL2 Kernel Update.')
        msiexec /i $kernelUpdate /qn
        Start-Sleep -Seconds 5
        Write-Host(' ...Cleaning up Kernel Update installer.')
        Remove-Item -Path $kernelUpdate
    } catch {
        Write-Verbose "Error installing update failed $_" -Verbose
    }
}

try {
    Write-Verbose 'Installing WSL' -Verbose
    wsl --install -d Ubuntu
} catch {
    Write-Verbose "There was an error installing WSL $_" -Verbose
}

