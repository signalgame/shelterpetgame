<#
.SYNOPSIS
    Keystore Generation Script for Pet Shelter Rush
    
.DESCRIPTION
    This script generates a JKS keystore for Android app signing.
    It ONLY uses manually entered company information.
    
    SECURITY GUARANTEES:
    - Does NOT read any system information
    - Does NOT read user information from OS
    - Does NOT read IP address or location
    - Does NOT auto-fill any values
    - All inputs are manually provided by the user
    
.NOTES
    Run this script LOCALLY on your machine.
    Keep the generated keystore and passwords SECURE.
    Never commit the keystore or passwords to version control.
#>

# =============================================================================
# SECURITY CHECK - Ensure we're not collecting system data
# =============================================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  PET SHELTER RUSH - KEYSTORE GENERATION SCRIPT" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "SECURITY NOTICE:" -ForegroundColor Yellow
Write-Host "  - This script does NOT collect any system information" -ForegroundColor Green
Write-Host "  - This script does NOT read your username or IP address" -ForegroundColor Green
Write-Host "  - This script does NOT auto-fill any values" -ForegroundColor Green
Write-Host "  - ALL values must be manually entered by YOU" -ForegroundColor Green
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# GET SCRIPT DIRECTORY (files will be created here)
# =============================================================================
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$keystoreFile = Join-Path $scriptDir "petshelter-release.jks"
$base64File = Join-Path $scriptDir "petshelter-keystore-base64.txt"

# =============================================================================
# CHECK FOR KEYTOOL
# =============================================================================
Write-Host "Checking for Java keytool..." -ForegroundColor Yellow

$keytoolPath = $null

# Check common locations
$possiblePaths = @(
    "$env:JAVA_HOME\bin\keytool.exe",
    "$env:ANDROID_HOME\jbr\bin\keytool.exe",
    "C:\Program Files\Java\jdk-17\bin\keytool.exe",
    "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $keytoolPath = $path
        break
    }
}

# Try to find keytool in PATH
if (-not $keytoolPath) {
    try {
        $keytoolPath = (Get-Command keytool -ErrorAction SilentlyContinue).Source
    } catch {
        # Ignore
    }
}

if (-not $keytoolPath) {
    Write-Host ""
    Write-Host "ERROR: Java keytool not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please ensure Java JDK is installed and either:" -ForegroundColor Yellow
    Write-Host "  1. Add Java bin folder to your PATH" -ForegroundColor Yellow
    Write-Host "  2. Set JAVA_HOME environment variable" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "Found keytool at: $keytoolPath" -ForegroundColor Green
Write-Host ""

# =============================================================================
# COLLECT COMPANY INFORMATION (MANUAL INPUT ONLY)
# =============================================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  COMPANY INFORMATION (Required for Certificate)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Enter your company/organization details below." -ForegroundColor White
Write-Host "These will be embedded in the signing certificate." -ForegroundColor White
Write-Host ""

# Company Name (CN - Common Name)
do {
    $companyName = Read-Host "1. Company/Developer Name (e.g., 'Pet Shelter Games Inc')"
    if ([string]::IsNullOrWhiteSpace($companyName)) {
        Write-Host "   Company name is required!" -ForegroundColor Red
    }
} while ([string]::IsNullOrWhiteSpace($companyName))

# Organizational Unit (OU)
do {
    $orgUnit = Read-Host "2. Organizational Unit (e.g., 'Mobile Development')"
    if ([string]::IsNullOrWhiteSpace($orgUnit)) {
        Write-Host "   Organizational unit is required!" -ForegroundColor Red
    }
} while ([string]::IsNullOrWhiteSpace($orgUnit))

# Organization (O)
do {
    $organization = Read-Host "3. Organization (e.g., 'Pet Shelter Games')"
    if ([string]::IsNullOrWhiteSpace($organization)) {
        Write-Host "   Organization is required!" -ForegroundColor Red
    }
} while ([string]::IsNullOrWhiteSpace($organization))

# City/Locality (L)
do {
    $city = Read-Host "4. City (e.g., 'San Francisco')"
    if ([string]::IsNullOrWhiteSpace($city)) {
        Write-Host "   City is required!" -ForegroundColor Red
    }
} while ([string]::IsNullOrWhiteSpace($city))

# State/Province (ST)
do {
    $state = Read-Host "5. State/Province (e.g., 'California')"
    if ([string]::IsNullOrWhiteSpace($state)) {
        Write-Host "   State/Province is required!" -ForegroundColor Red
    }
} while ([string]::IsNullOrWhiteSpace($state))

# Country Code (C)
do {
    $country = Read-Host "6. Country Code - 2 letters (e.g., 'US', 'UK', 'DE')"
    if ([string]::IsNullOrWhiteSpace($country) -or $country.Length -ne 2) {
        Write-Host "   Country code must be exactly 2 letters!" -ForegroundColor Red
        $country = ""
    }
} while ([string]::IsNullOrWhiteSpace($country))

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  KEYSTORE CREDENTIALS (Create New Passwords)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Create strong passwords for your keystore." -ForegroundColor White
Write-Host "IMPORTANT: Save these passwords securely - you'll need them!" -ForegroundColor Yellow
Write-Host ""

# Key Alias
do {
    $keyAlias = Read-Host "7. Key Alias (e.g., 'petshelter-release' or 'upload')"
    if ([string]::IsNullOrWhiteSpace($keyAlias)) {
        Write-Host "   Key alias is required!" -ForegroundColor Red
    }
} while ([string]::IsNullOrWhiteSpace($keyAlias))

# Keystore Password
do {
    $storePassword = Read-Host "8. Keystore Password (min 6 characters)" -AsSecureString
    $storePasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePassword))
    if ($storePasswordPlain.Length -lt 6) {
        Write-Host "   Password must be at least 6 characters!" -ForegroundColor Red
        $storePasswordPlain = ""
    }
} while ([string]::IsNullOrWhiteSpace($storePasswordPlain))

# Key Password
do {
    $keyPassword = Read-Host "9. Key Password (min 6 characters, can be same as keystore)" -AsSecureString
    $keyPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPassword))
    if ($keyPasswordPlain.Length -lt 6) {
        Write-Host "   Password must be at least 6 characters!" -ForegroundColor Red
        $keyPasswordPlain = ""
    }
} while ([string]::IsNullOrWhiteSpace($keyPasswordPlain))

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  GENERATING KEYSTORE" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Build the Distinguished Name (DN)
$dname = "CN=$companyName, OU=$orgUnit, O=$organization, L=$city, ST=$state, C=$country"

Write-Host "Certificate DN: $dname" -ForegroundColor Gray
Write-Host "Output file: $keystoreFile" -ForegroundColor Gray
Write-Host ""

# Remove existing keystore if present
if (Test-Path $keystoreFile) {
    Remove-Item $keystoreFile -Force
    Write-Host "Removed existing keystore file." -ForegroundColor Yellow
}

# Generate the keystore using direct command execution with proper quoting
try {
    # Use the call operator with properly escaped arguments
    & "$keytoolPath" `
        -genkeypair `
        -v `
        -keystore "$keystoreFile" `
        -keyalg RSA `
        -keysize 2048 `
        -validity 10000 `
        -alias "$keyAlias" `
        -storepass "$storePasswordPlain" `
        -keypass "$keyPasswordPlain" `
        -dname "$dname"
    
    if ($LASTEXITCODE -eq 0 -and (Test-Path $keystoreFile)) {
        Write-Host ""
        Write-Host "Keystore generated successfully!" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Keystore generation failed with exit code $LASTEXITCODE!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Verify keystore was created
if (-not (Test-Path $keystoreFile)) {
    Write-Host "ERROR: Keystore file was not created!" -ForegroundColor Red
    exit 1
}

Write-Host "Keystore file size: $((Get-Item $keystoreFile).Length) bytes" -ForegroundColor Gray

# =============================================================================
# GENERATE BASE64 ENCODED KEYSTORE
# =============================================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  GENERATING BASE64 ENCODED KEYSTORE" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

try {
    $keystoreBytes = [System.IO.File]::ReadAllBytes($keystoreFile)
    $keystoreBase64 = [System.Convert]::ToBase64String($keystoreBytes)

    # Save base64 to file
    $keystoreBase64 | Out-File -FilePath $base64File -Encoding ASCII -NoNewline

    Write-Host "Base64 keystore saved to: $base64File" -ForegroundColor Green
    Write-Host "Base64 length: $($keystoreBase64.Length) characters" -ForegroundColor Gray
} catch {
    Write-Host "ERROR generating base64: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# =============================================================================
# OUTPUT GITHUB SECRETS INSTRUCTIONS
# =============================================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  GITHUB SECRETS SETUP INSTRUCTIONS" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Add the following secrets to your GitHub repository:" -ForegroundColor White
Write-Host ""
Write-Host "  Repository -> Settings -> Secrets and variables -> Actions" -ForegroundColor Yellow
Write-Host ""
Write-Host "------------------------------------------------------------" -ForegroundColor Gray
Write-Host ""
Write-Host "Secret Name: PETSHELTER_KEYSTORE_BASE64" -ForegroundColor Cyan
Write-Host "Value: (Copy contents of $base64File)" -ForegroundColor White
Write-Host ""
Write-Host "Secret Name: PETSHELTER_KEY_ALIAS" -ForegroundColor Cyan
Write-Host "Value: $keyAlias" -ForegroundColor White
Write-Host ""
Write-Host "Secret Name: PETSHELTER_KEY_PASSWORD" -ForegroundColor Cyan
Write-Host "Value: (The key password you entered)" -ForegroundColor White
Write-Host ""
Write-Host "Secret Name: PETSHELTER_STORE_PASSWORD" -ForegroundColor Cyan
Write-Host "Value: (The keystore password you entered)" -ForegroundColor White
Write-Host ""
Write-Host "------------------------------------------------------------" -ForegroundColor Gray
Write-Host ""
Write-Host "IMPORTANT SECURITY REMINDERS:" -ForegroundColor Red
Write-Host ""
Write-Host "  1. NEVER commit the .jks file to Git" -ForegroundColor Yellow
Write-Host "  2. NEVER commit the base64 file to Git" -ForegroundColor Yellow
Write-Host "  3. NEVER share your passwords" -ForegroundColor Yellow
Write-Host "  4. Store a backup of the keystore in a secure location" -ForegroundColor Yellow
Write-Host "  5. If you lose the keystore, you CANNOT update your app" -ForegroundColor Yellow
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  FILES GENERATED" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  1. $keystoreFile" -ForegroundColor White
Write-Host "     (Keep this safe, backup securely!)" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. $base64File" -ForegroundColor White
Write-Host "     (Copy to GitHub Secrets, then delete)" -ForegroundColor Gray
Write-Host ""
Write-Host "After adding secrets to GitHub, DELETE the base64 file:" -ForegroundColor Yellow
Write-Host "  Remove-Item '$base64File'" -ForegroundColor Gray
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  DONE!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""

# Clear sensitive variables from memory
$storePasswordPlain = $null
$keyPasswordPlain = $null
[System.GC]::Collect()
