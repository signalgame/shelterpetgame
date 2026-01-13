#!/bin/bash

# =============================================================================
# Keystore Generation Script for Pet Shelter Rush (Unix/Linux/macOS)
# =============================================================================
#
# SECURITY GUARANTEES:
# - Does NOT read any system information
# - Does NOT read user information from OS
# - Does NOT read IP address or location
# - Does NOT auto-fill any values
# - All inputs are manually provided by the user
#
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  PET SHELTER RUSH - KEYSTORE GENERATION SCRIPT${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
echo -e "${YELLOW}SECURITY NOTICE:${NC}"
echo -e "${GREEN}  - This script does NOT collect any system information${NC}"
echo -e "${GREEN}  - This script does NOT read your username or IP address${NC}"
echo -e "${GREEN}  - This script does NOT auto-fill any values${NC}"
echo -e "${GREEN}  - ALL values must be manually entered by YOU${NC}"
echo ""
echo -e "${CYAN}============================================================${NC}"
echo ""

# =============================================================================
# CHECK FOR KEYTOOL
# =============================================================================
echo -e "${YELLOW}Checking for Java keytool...${NC}"

if ! command -v keytool &> /dev/null; then
    echo ""
    echo -e "${RED}ERROR: Java keytool not found!${NC}"
    echo ""
    echo -e "${YELLOW}Please ensure Java JDK is installed and in your PATH${NC}"
    echo ""
    exit 1
fi

echo -e "${GREEN}Found keytool at: $(which keytool)${NC}"
echo ""

# =============================================================================
# COLLECT COMPANY INFORMATION (MANUAL INPUT ONLY)
# =============================================================================
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  COMPANY INFORMATION (Required for Certificate)${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
echo "Enter your company/organization details below."
echo "These will be embedded in the signing certificate."
echo ""

# Company Name (CN - Common Name)
while true; do
    read -p "1. Company/Developer Name (e.g., 'Pet Shelter Games Inc'): " companyName
    if [ -n "$companyName" ]; then break; fi
    echo -e "${RED}   Company name is required!${NC}"
done

# Organizational Unit (OU)
while true; do
    read -p "2. Organizational Unit (e.g., 'Mobile Development'): " orgUnit
    if [ -n "$orgUnit" ]; then break; fi
    echo -e "${RED}   Organizational unit is required!${NC}"
done

# Organization (O)
while true; do
    read -p "3. Organization (e.g., 'Pet Shelter Games'): " organization
    if [ -n "$organization" ]; then break; fi
    echo -e "${RED}   Organization is required!${NC}"
done

# City/Locality (L)
while true; do
    read -p "4. City (e.g., 'San Francisco'): " city
    if [ -n "$city" ]; then break; fi
    echo -e "${RED}   City is required!${NC}"
done

# State/Province (ST)
while true; do
    read -p "5. State/Province (e.g., 'California'): " state
    if [ -n "$state" ]; then break; fi
    echo -e "${RED}   State/Province is required!${NC}"
done

# Country Code (C)
while true; do
    read -p "6. Country Code - 2 letters (e.g., 'US', 'UK', 'DE'): " country
    if [ -n "$country" ] && [ ${#country} -eq 2 ]; then break; fi
    echo -e "${RED}   Country code must be exactly 2 letters!${NC}"
done

echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  KEYSTORE CREDENTIALS (Create New Passwords)${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
echo "Create strong passwords for your keystore."
echo -e "${YELLOW}IMPORTANT: Save these passwords securely - you'll need them!${NC}"
echo ""

# Key Alias
while true; do
    read -p "7. Key Alias (e.g., 'petshelter-release' or 'upload'): " keyAlias
    if [ -n "$keyAlias" ]; then break; fi
    echo -e "${RED}   Key alias is required!${NC}"
done

# Keystore Password
while true; do
    read -s -p "8. Keystore Password (min 6 characters): " storePassword
    echo ""
    if [ ${#storePassword} -ge 6 ]; then break; fi
    echo -e "${RED}   Password must be at least 6 characters!${NC}"
done

# Key Password
while true; do
    read -s -p "9. Key Password (min 6 characters, can be same as keystore): " keyPassword
    echo ""
    if [ ${#keyPassword} -ge 6 ]; then break; fi
    echo -e "${RED}   Password must be at least 6 characters!${NC}"
done

keystoreFile="petshelter-release.jks"

echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  GENERATING KEYSTORE${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""

# Build the Distinguished Name (DN)
dname="CN=$companyName, OU=$orgUnit, O=$organization, L=$city, ST=$state, C=$country"

echo "Certificate DN: $dname"
echo ""

# Generate the keystore
keytool -genkeypair -v \
    -keystore "$keystoreFile" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias "$keyAlias" \
    -storepass "$storePassword" \
    -keypass "$keyPassword" \
    -dname "$dname"

if [ -f "$keystoreFile" ]; then
    echo -e "${GREEN}Keystore generated successfully!${NC}"
else
    echo -e "${RED}ERROR: Keystore generation failed!${NC}"
    exit 1
fi

# =============================================================================
# GENERATE BASE64 ENCODED KEYSTORE
# =============================================================================
echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  GENERATING BASE64 ENCODED KEYSTORE${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""

base64File="petshelter-keystore-base64.txt"
base64 -i "$keystoreFile" | tr -d '\n' > "$base64File"

echo -e "${GREEN}Base64 keystore saved to: $base64File${NC}"
echo ""

# =============================================================================
# OUTPUT GITHUB SECRETS INSTRUCTIONS
# =============================================================================
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}  GITHUB SECRETS SETUP INSTRUCTIONS${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo "Add the following secrets to your GitHub repository:"
echo ""
echo -e "${YELLOW}  Repository -> Settings -> Secrets and variables -> Actions${NC}"
echo ""
echo "------------------------------------------------------------"
echo ""
echo -e "${CYAN}Secret Name: PETSHELTER_KEYSTORE_BASE64${NC}"
echo "Value: (Copy contents of $base64File)"
echo ""
echo -e "${CYAN}Secret Name: PETSHELTER_KEY_ALIAS${NC}"
echo "Value: $keyAlias"
echo ""
echo -e "${CYAN}Secret Name: PETSHELTER_KEY_PASSWORD${NC}"
echo "Value: (The key password you entered)"
echo ""
echo -e "${CYAN}Secret Name: PETSHELTER_STORE_PASSWORD${NC}"
echo "Value: (The keystore password you entered)"
echo ""
echo "------------------------------------------------------------"
echo ""
echo -e "${RED}IMPORTANT SECURITY REMINDERS:${NC}"
echo ""
echo -e "${YELLOW}  1. NEVER commit the .jks file to Git${NC}"
echo -e "${YELLOW}  2. NEVER commit the base64 file to Git${NC}"
echo -e "${YELLOW}  3. NEVER share your passwords${NC}"
echo -e "${YELLOW}  4. Store a backup of the keystore in a secure location${NC}"
echo -e "${YELLOW}  5. If you lose the keystore, you CANNOT update your app${NC}"
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}  FILES GENERATED${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo "  1. $keystoreFile (Keep this safe, backup securely!)"
echo "  2. $base64File (Copy to GitHub Secrets, then delete)"
echo ""
echo -e "${YELLOW}After adding secrets to GitHub, DELETE the base64 file:${NC}"
echo "  rm $base64File"
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}  DONE!${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""

# Clear sensitive variables from memory
unset storePassword
unset keyPassword
