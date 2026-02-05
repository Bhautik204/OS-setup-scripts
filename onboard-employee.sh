#!/bin/bash
#===============================================================================
#
#   Employee Onboarding Script
#   
#   Usage: sudo ./onboard-employee.sh <username> <role>
#   
#   Roles: developer, qa
#
#   Example: sudo ./onboard-employee.sh johnsmith developer
#
#===============================================================================

# Don't use set -e - we want to handle errors explicitly
# set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#===============================================================================
# INITIALIZATION
#===============================================================================

show_banner() {
    echo ""
    echo -e "\033[1;36m╔════════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[1;36m║       Employee Workstation Onboarding System               ║\033[0m"
    echo -e "\033[1;36m╚════════════════════════════════════════════════════════════╝\033[0m"
    echo ""
}

show_usage() {
    echo "Usage: sudo $0 <username> <role>"
    echo ""
    echo "Arguments:"
    echo "  username    Target employee username"
    echo "  role        Employee role: developer | qa"
    echo ""
    echo "Examples:"
    echo "  sudo $0 johnsmith developer"
    echo "  sudo $0 alice qa"
    echo ""
}

#===============================================================================
# VALIDATION
#===============================================================================

validate_inputs() {
    # Check root
    if [[ $EUID -ne 0 ]]; then
        echo -e "\033[0;31mError: This script must be run with sudo\033[0m"
        echo "Run: sudo $0 $*"
        exit 1
    fi
    
    # Check arguments
    if [[ -z "$1" ]] || [[ -z "$2" ]]; then
        echo -e "\033[0;31mError: Missing arguments\033[0m"
        echo ""
        show_usage
        exit 1
    fi
    
    TARGET_USER="$1"
    ROLE="$2"
    
    # Validate role
    if [[ "$ROLE" != "developer" ]] && [[ "$ROLE" != "qa" ]]; then
        echo -e "\033[0;31mError: Invalid role '$ROLE'\033[0m"
        echo "Valid roles: developer, qa"
        exit 1
    fi
    
    # Validate user exists or create
    if ! id "$TARGET_USER" &>/dev/null; then
        echo -e "\033[1;33mUser '$TARGET_USER' does not exist.\033[0m"
        read -p "Create user '$TARGET_USER'? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Use useradd (more universal than adduser)
            useradd -m -s /bin/bash "$TARGET_USER"
            
            # Set password
            echo -e "\033[1;33mSet password for $TARGET_USER:\033[0m"
            passwd "$TARGET_USER"
            
            echo -e "\033[0;32m✓ User '$TARGET_USER' created\033[0m"
        else
            echo "Aborted."
            exit 1
        fi
    fi
    
    # Get target user's home directory
    TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
    
    if [[ -z "$TARGET_HOME" ]] || [[ ! -d "$TARGET_HOME" ]]; then
        echo -e "\033[0;31mError: Could not determine home directory for $TARGET_USER\033[0m"
        exit 1
    fi
    
    # Check Ubuntu
    if ! grep -qi ubuntu /etc/os-release 2>/dev/null; then
        echo -e "\033[1;33mWarning: This script is designed for Ubuntu\033[0m"
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

#===============================================================================
# SETUP LOGGING
#===============================================================================

setup_logging() {
    LOG_DIR="/var/log/onboarding"
    mkdir -p "$LOG_DIR"
    
    TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
    LOG_FILE="$LOG_DIR/${TARGET_USER}-${TIMESTAMP}.log"
    
    echo "Onboarding Log - $TARGET_USER - $(date)" > "$LOG_FILE"
    echo "Role: $ROLE" >> "$LOG_FILE"
    echo "======================================" >> "$LOG_FILE"
}

#===============================================================================
# LOAD LIBRARIES & MODULES
#===============================================================================

load_libraries() {
    source "$SCRIPT_DIR/lib/common.sh"
}

load_role() {
    source "$SCRIPT_DIR/roles/${ROLE}.sh"
}

load_module() {
    local module=$1
    source "$SCRIPT_DIR/modules/${module}.sh"
}

#===============================================================================
# EXECUTION
#===============================================================================

run_installation() {
    log_info "Target User: $TARGET_USER"
    log_info "Role: $ROLE_NAME"
    log_info "Home: $TARGET_HOME"
    log_info "Log File: $LOG_FILE"
    
    # DEBUG: Show what modules will be installed
    echo ""
    echo "DEBUG: ROLE_MODULES = ${ROLE_MODULES[@]}"
    echo "DEBUG: Module count = ${#ROLE_MODULES[@]}"
    echo ""
    
    # Check if ROLE_MODULES is set
    if [[ -z "${ROLE_MODULES[@]}" ]]; then
        log_error "ROLE_MODULES array is empty! Role file may not have loaded correctly."
        log_error "Role file: $SCRIPT_DIR/roles/${ROLE}.sh"
        exit 1
    fi
    
    local total=${#ROLE_MODULES[@]}
    local current=0
    
    log_info "Total modules to install: $total"
    echo ""
    
    # Module to function name mapping
    declare -A MODULE_FUNCTIONS=(
        ["00-base-tools"]="install_base_tools"
        ["01-java"]="install_java"
        ["02-docker"]="install_docker"
        ["03-postgres"]="install_postgres"
        ["04-browsers"]="install_browsers"
        ["05-editors"]="install_editors"
        ["06-ides"]="install_ides"
        ["07-nodejs"]="install_nodejs"
        ["08-system-config"]="install_system_config"
    )
    
    for module in "${ROLE_MODULES[@]}"; do
        ((current++))
        
        local func_name="${MODULE_FUNCTIONS[$module]}"
        
        if [[ -z "$func_name" ]]; then
            log_warn "Unknown module: $module"
            continue
        fi
        
        log_step "[$current/$total] Installing: $module"
        
        # Source the module file
        if [[ ! -f "$SCRIPT_DIR/modules/${module}.sh" ]]; then
            log_error "Module file not found: $SCRIPT_DIR/modules/${module}.sh"
            continue
        fi
        
        source "$SCRIPT_DIR/modules/${module}.sh"
        
        # Call the install function
        if declare -f "$func_name" > /dev/null; then
            $func_name || log_error "Failed to execute $func_name"
        else
            log_error "Function $func_name not found in module $module"
        fi
    done
    
    # Apply role-specific configuration
    log_step "Applying role configuration: $ROLE"
    if declare -f "configure_${ROLE}" > /dev/null; then
        "configure_${ROLE}" || log_error "Failed to configure role: $ROLE"
    else
        log_error "Function configure_${ROLE} not found"
    fi
}

#===============================================================================
# VERIFICATION
#===============================================================================

run_verification() {
    log_step "Running Verification"
    
    local passed=0
    local failed=0
    
    # Check each tool
    declare -A checks=(
        ["curl"]="curl"
        ["wget"]="wget"
        ["git"]="git"
        ["java"]="java"
        ["mvn"]="mvn"
        ["docker"]="docker"
        ["code"]="code"
        ["subl"]="subl"
        ["eclipse"]="eclipse"
        ["postman"]="postman"
        ["google-chrome"]="google-chrome"
    )
    
    for name in "${!checks[@]}"; do
        cmd="${checks[$name]}"
        if is_installed "$cmd"; then
            log_success "$name installed"
            ((passed++))
        else
            log_warn "$name not found"
            ((failed++))
        fi
    done
    
    # Check PostgreSQL (if developer role)
    if [[ "$ROLE" == "developer" ]]; then
        if systemctl is-active --quiet postgresql; then
            log_success "PostgreSQL running"
            ((passed++))
        else
            log_warn "PostgreSQL not running"
            ((failed++))
        fi
    fi
    
    # Check NVM & Node
    if [ -d "$TARGET_HOME/.nvm" ]; then
        log_success "NVM installed"
        ((passed++))
        
        local node_ver=$(run_as_user_login "source ~/.nvm/nvm.sh && node --version" 2>/dev/null)
        if [[ -n "$node_ver" ]]; then
            log_success "Node.js: $node_ver"
            ((passed++))
        else
            log_warn "Node.js not found"
            ((failed++))
        fi
    else
        log_warn "NVM not installed"
        ((failed++))
    fi
    
    echo ""
    log_info "Verification: $passed passed, $failed failed"
    
    # Save verification to user's home
    {
        echo "Verification Report - $(date)"
        echo "=========================="
        echo "Passed: $passed"
        echo "Failed: $failed"
    } > "$TARGET_HOME/verify-report.txt"
    fix_ownership "$TARGET_HOME/verify-report.txt"
}

#===============================================================================
# WELCOME DOCUMENT
#===============================================================================

generate_welcome() {
    log_step "Generating Welcome Document"
    
    local template="$SCRIPT_DIR/templates/welcome-${ROLE}.md"
    local output="$TARGET_HOME/WELCOME.md"
    
    if [[ -f "$template" ]]; then
        sed -e "s/{{USERNAME}}/$TARGET_USER/g" \
            -e "s/{{DATE}}/$(date '+%B %d, %Y')/g" \
            "$template" > "$output"
        fix_ownership "$output"
        log_success "Welcome document created: $output"
    else
        log_warn "Template not found: $template"
    fi
}

#===============================================================================
# SUMMARY
#===============================================================================

show_summary() {
    echo ""
    echo -e "\033[1;32m╔════════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[1;32m║             Onboarding Complete! ✓                         ║\033[0m"
    echo -e "\033[1;32m╚════════════════════════════════════════════════════════════╝\033[0m"
    echo ""
    echo -e "\033[1mEmployee:\033[0m $TARGET_USER"
    echo -e "\033[1mRole:\033[0m     $ROLE_NAME"
    echo -e "\033[1mHome:\033[0m     $TARGET_HOME"
    echo ""
    echo -e "\033[1mDocuments:\033[0m"
    echo "  • Welcome Guide: $TARGET_HOME/WELCOME.md"
    echo "  • Verify Report: $TARGET_HOME/verify-report.txt"
    echo ""
    echo -e "\033[1mLog File:\033[0m $LOG_FILE"
    echo ""
    echo -e "\033[1;33m⚠️  Note: User must logout/login for Docker group to take effect\033[0m"
    echo ""
}

#===============================================================================
# MAIN
#===============================================================================

main() {
    show_banner
    validate_inputs "$@"
    setup_logging
    load_libraries
    load_role
    
    echo ""
    echo -e "\033[1mStarting onboarding for:\033[0m"
    echo "  User: $TARGET_USER"
    echo "  Role: $ROLE_NAME - $ROLE_DESCRIPTION"
    echo ""
    read -p "Continue? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    
    local start_time=$(date +%s)
    
    run_installation
    run_verification
    generate_welcome
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))
    
    show_summary
    
    echo -e "\033[1mTotal Time:\033[0m ${minutes}m ${seconds}s"
    echo ""
}

# Run main
main "$@"
