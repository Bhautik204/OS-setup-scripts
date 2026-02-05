#!/bin/bash
# Common utility functions

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    if [[ -n "$LOG_FILE" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" >> "$LOG_FILE"
    fi
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
    if [[ -n "$LOG_FILE" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $1" >> "$LOG_FILE"
    fi
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    if [[ -n "$LOG_FILE" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $1" >> "$LOG_FILE"
    fi
}

log_error() {
    echo -e "${RED}✗${NC} $1"
    if [[ -n "$LOG_FILE" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >> "$LOG_FILE"
    fi
}

log_step() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD} $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    if [[ -n "$LOG_FILE" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [STEP] $1" >> "$LOG_FILE"
    fi
}

# Execute command with visible output and logging
execute_visible() {
    local description=$1
    shift
    local cmd="$@"
    
    log_info "$description"
    echo -e "${CYAN}Running: $cmd${NC}"
    
    if [[ -n "$LOG_FILE" ]]; then
        # Show output on screen AND log to file
        eval "$cmd" 2>&1 | tee -a "$LOG_FILE"
        local exit_code=${PIPESTATUS[0]}
    else
        eval "$cmd"
        local exit_code=$?
    fi
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "$description - completed"
        return 0
    else
        log_error "$description - failed (exit code: $exit_code)"
        return $exit_code
    fi
}

# Check if command exists
is_installed() {
    command -v "$1" &> /dev/null
}

# Install apt package with visible output
install_package() {
    local pkg=$1
    
    if dpkg -l | grep -q "^ii  $pkg "; then
        log_info "$pkg already installed"
        return 0
    fi
    
    log_info "Installing $pkg..."
    
    if [[ -n "$LOG_FILE" ]]; then
        apt-get install -y "$pkg" 2>&1 | tee -a "$LOG_FILE"
        local exit_code=${PIPESTATUS[0]}
    else
        apt-get install -y "$pkg"
        local exit_code=$?
    fi
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "$pkg installed"
        return 0
    else
        log_error "$pkg installation failed"
        return $exit_code
    fi
}

# Run command as target user
run_as_user() {
    local cmd=$1
    sudo -u "$TARGET_USER" bash -c "$cmd"
}

# Run command as target user with login shell (for NVM, etc.)
run_as_user_login() {
    local cmd=$1
    sudo -u "$TARGET_USER" bash -l -c "$cmd"
}

# Create directory as target user
create_user_dir() {
    local dir=$1
    mkdir -p "$dir"
    chown "$TARGET_USER:$TARGET_USER" "$dir"
}

# Fix ownership of path
fix_ownership() {
    local path=$1
    chown -R "$TARGET_USER:$TARGET_USER" "$path"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: This script must be run as root (use sudo)${NC}"
        exit 1
    fi
}

# Validate user exists
validate_user() {
    if ! id "$TARGET_USER" &>/dev/null; then
        return 1
    fi
    return 0
}

# Get user home directory
get_user_home() {
    eval echo "~$TARGET_USER"
}
