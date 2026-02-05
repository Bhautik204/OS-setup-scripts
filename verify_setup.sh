#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "Developer Workstation Setup Verification"
echo "========================================="
echo ""

# Counter for pass/fail
PASSED=0
FAILED=0

# Helper function to check command
check_command() {
    local cmd=$1
    local name=$2
    
    if command -v $cmd &> /dev/null; then
        echo -e "${GREEN}✓${NC} $name is installed"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $name is NOT installed"
        ((FAILED++))
        return 1
    fi
}

# Helper function to check service
check_service() {
    local service=$1
    local name=$2
    
    if systemctl is-active --quiet $service; then
        echo -e "${GREEN}✓${NC} $name service is running"
        ((PASSED++))
        return 0
    elif systemctl is-enabled --quiet $service 2>/dev/null; then
        echo -e "${YELLOW}⚠${NC} $name service is enabled but not running"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $name service is NOT enabled"
        ((FAILED++))
        return 1
    fi
}

# Helper function to check file/directory
check_path() {
    local path=$1
    local name=$2
    
    if [ -e "$path" ]; then
        echo -e "${GREEN}✓${NC} $name exists at $path"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $name does NOT exist at $path"
        ((FAILED++))
        return 1
    fi
}

# Helper function to get version
check_version() {
    local cmd=$1
    local name=$2
    
    if command -v $cmd &> /dev/null; then
        version=$($cmd 2>&1 | head -n1)
        echo -e "${GREEN}✓${NC} $name: $version"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $name is NOT installed"
        ((FAILED++))
        return 1
    fi
}

echo "--- Base Tools ---"
check_command curl "curl"
check_command wget "wget"
check_command git "git"
check_command unzip "unzip"
echo ""

echo "--- Java & Maven ---"
check_command java "Java"
if command -v java &> /dev/null; then
    java_version=$(java -version 2>&1 | head -n1)
    echo "  Version: $java_version"
fi
check_command javac "Java Compiler"
check_command mvn "Maven"
if command -v mvn &> /dev/null; then
    mvn_version=$(mvn -version | head -n1)
    echo "  Version: $mvn_version"
fi
echo ""

echo "--- Docker ---"
check_command docker "Docker"
if command -v docker &> /dev/null; then
    docker_version=$(docker --version)
    echo "  Version: $docker_version"
    
    # Check if user is in docker group
    if groups $USER | grep -q docker; then
        echo -e "${GREEN}✓${NC} User is in docker group"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠${NC} User is NOT in docker group (logout/login required)"
        ((FAILED++))
    fi
fi
echo ""

echo "--- PostgreSQL ---"
check_command psql "PostgreSQL Client"
if command -v psql &> /dev/null; then
    psql_version=$(psql --version)
    echo "  Version: $psql_version"
fi
check_service postgresql "PostgreSQL"
echo ""

echo "--- pgAdmin ---"
check_command pgadmin4 "pgAdmin 4"
echo ""

echo "--- Chrome ---"
check_command google-chrome "Google Chrome"
if command -v google-chrome &> /dev/null; then
    chrome_version=$(google-chrome --version)
    echo "  Version: $chrome_version"
fi
echo ""

echo "--- VS Code ---"
check_command code "Visual Studio Code"
if command -v code &> /dev/null; then
    code_version=$(code --version | head -n1)
    echo "  Version: $code_version"
fi
echo ""

echo "--- Sublime Text ---"
check_command subl "Sublime Text"
if command -v subl &> /dev/null; then
    subl_version=$(subl --version)
    echo "  Version: $subl_version"
fi
echo ""

echo "--- Postman ---"
check_path "/opt/Postman" "Postman installation"
check_command postman "Postman command"
check_path "$HOME/.local/share/applications/postman.desktop" "Postman desktop entry"
echo ""

echo "--- Eclipse ---"
check_path "/opt/eclipse" "Eclipse installation"
check_command eclipse "Eclipse command"
check_path "$HOME/.local/share/applications/eclipse.desktop" "Eclipse desktop entry"
echo ""

echo "--- NVM & Node.js ---"
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    echo -e "${GREEN}✓${NC} NVM is installed"
    ((PASSED++))
    
    # Source nvm
    \. "$NVM_DIR/nvm.sh"
    
    if command -v nvm &> /dev/null; then
        nvm_version=$(nvm --version)
        echo "  NVM Version: $nvm_version"
    fi
    
    if command -v node &> /dev/null; then
        node_version=$(node --version)
        npm_version=$(npm --version)
        echo -e "${GREEN}✓${NC} Node.js: $node_version"
        echo -e "${GREEN}✓${NC} npm: $npm_version"
        ((PASSED+=2))
    else
        echo -e "${RED}✗${NC} Node.js is NOT installed via NVM"
        ((FAILED++))
    fi
    
    # Check bashrc integration
    if grep -q "export NVM_DIR" ~/.bashrc; then
        echo -e "${GREEN}✓${NC} NVM is configured in ~/.bashrc"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} NVM is NOT configured in ~/.bashrc"
        ((FAILED++))
    fi
else
    echo -e "${RED}✗${NC} NVM is NOT installed"
    ((FAILED++))
fi
echo ""

echo "========================================="
echo "Verification Summary"
echo "========================================="
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${RED}Failed:${NC} $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All components verified successfully!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠ Some components failed verification. Please review above.${NC}"
    exit 1
fi
