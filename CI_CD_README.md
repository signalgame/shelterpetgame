# CI/CD Setup Guide - Pet Shelter Rush

This document explains how to set up automated Android builds using GitHub Actions.

## Overview

The CI/CD pipeline automatically:
- Builds **signed APK** and **AAB** files on every push
- Uses secure keystore credentials from GitHub Secrets
- Uploads build artifacts for download
- Cleans up sensitive files after build

## Security Guarantees

### What This Setup Does NOT Collect:
- ❌ System information
- ❌ IP addresses
- ❌ Location data
- ❌ Personal usernames
- ❌ Machine identifiers
- ❌ Any auto-filled data

### What This Setup DOES Protect:
- ✅ Keystore is decoded at runtime and deleted after build
- ✅ Passwords are never printed to logs
- ✅ All sensitive data stored only in GitHub Secrets
- ✅ Sensitive files are excluded via .gitignore

---

## Quick Start

### Step 1: Generate Keystore (One Time Only)

Run the keystore generation script **locally** on your machine:

**Windows (PowerShell):**
```powershell
cd scripts
.\generate-keystore.ps1
```

**macOS/Linux (Bash):**
```bash
cd scripts
chmod +x generate-keystore.sh
./generate-keystore.sh
```

The script will prompt you for:
1. Company/Developer Name
2. Organizational Unit
3. Organization
4. City
5. State/Province
6. Country Code (2 letters)
7. Key Alias
8. Keystore Password
9. Key Password

### Step 2: Add GitHub Secrets

Go to your GitHub repository:
1. Navigate to **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add these 4 secrets:

| Secret Name | Value |
|-------------|-------|
| `PETSHELTER_KEYSTORE_BASE64` | Contents of `petshelter-keystore-base64.txt` |
| `PETSHELTER_KEY_ALIAS` | The alias you entered (e.g., `petshelter-release`) |
| `PETSHELTER_KEY_PASSWORD` | The key password you entered |
| `PETSHELTER_STORE_PASSWORD` | The keystore password you entered |

### Step 3: Delete Local Sensitive Files

After adding secrets to GitHub:
```bash
# Delete the base64 file (IMPORTANT!)
rm petshelter-keystore-base64.txt

# Store the .jks file in a SECURE backup location
# (e.g., encrypted cloud storage, password manager)
```

### Step 4: Trigger the Build

The workflow runs automatically on:
- Push to `main` or `master` branch
- Push to any `release/*` branch
- Any tag starting with `v` (e.g., `v1.0.0`)
- Pull requests to `main` or `master`
- Manual trigger via GitHub Actions UI

To manually trigger:
1. Go to **Actions** tab in your repository
2. Select **Build Android Release**
3. Click **Run workflow**

### Step 5: Download Artifacts

After a successful build:
1. Go to **Actions** tab
2. Click on the completed workflow run
3. Scroll down to **Artifacts**
4. Download:
   - `pet-shelter-rush-apk-{commit}` - Signed APK
   - `pet-shelter-rush-aab-{commit}` - Signed AAB (for Play Store)

---

## File Structure

```
project/
├── .github/
│   └── workflows/
│       └── build-release.yml    # GitHub Actions workflow
├── android/
│   ├── app/
│   │   ├── build.gradle.kts     # Build config with signing
│   │   └── proguard-rules.pro   # R8/ProGuard rules
│   ├── key.properties           # Created by CI (not committed)
│   └── .gitignore
├── scripts/
│   ├── generate-keystore.ps1    # Windows script
│   └── generate-keystore.sh     # Unix/macOS script
├── .gitignore                   # Excludes sensitive files
└── CI_CD_README.md              # This file
```

---

## Secrets Reference

| Secret | Description | Example |
|--------|-------------|---------|
| `PETSHELTER_KEYSTORE_BASE64` | Base64-encoded JKS keystore | (long base64 string) |
| `PETSHELTER_KEY_ALIAS` | Alias for the signing key | `petshelter-release` |
| `PETSHELTER_KEY_PASSWORD` | Password for the key | (your password) |
| `PETSHELTER_STORE_PASSWORD` | Password for the keystore | (your password) |

---

## Troubleshooting

### Build fails with "keystore not found"
- Verify `PETSHELTER_KEYSTORE_BASE64` secret is correctly set
- Ensure the base64 content has no line breaks

### Build fails with "wrong password"
- Double-check `PETSHELTER_KEY_PASSWORD` and `PETSHELTER_STORE_PASSWORD`
- Passwords are case-sensitive

### Build fails with "Play Core classes not found"
- The `proguard-rules.pro` file includes `-dontwarn` rules for Play Core
- If you see new missing classes, add them to the proguard file

### APK/AAB not signed
- Ensure all 4 secrets are set correctly
- Check the workflow logs for signing errors

---

## Important Security Reminders

1. **NEVER commit the `.jks` keystore file**
2. **NEVER commit the base64 keystore file**
3. **NEVER share your passwords**
4. **ALWAYS backup your keystore securely**
5. **If you lose the keystore, you CANNOT update your app on Play Store**

---

## Workflow Triggers

| Trigger | When |
|---------|------|
| Push to `main`/`master` | Every commit |
| Push to `release/*` | Every commit to release branches |
| Tags `v*` | Version tags (v1.0.0, v2.0.0, etc.) |
| Pull Requests | To main/master branches |
| Manual | Via GitHub Actions UI |

---

## Build Modes

The workflow **ONLY** builds in **release mode**:
- APK: `flutter build apk --release`
- AAB: `flutter build appbundle --release`

Debug builds are NOT generated by the CI/CD pipeline.

---

## Contact

For issues with this CI/CD setup, check:
1. GitHub Actions logs for detailed error messages
2. The troubleshooting section above
3. Flutter documentation: https://docs.flutter.dev/deployment/android
