#!/bin/bash
# Role: QA
# QA Engineer configuration
# Installs: VS Code, Google Chrome, Postman (matching qa_setup.sh)

ROLE_NAME="QA Engineer"
ROLE_DESCRIPTION="Quality Assurance - Testing & Automation"

# Modules to install for this role=
ROLE_MODULES=(
    "00-base-tools"      # Prerequisites (curl, wget, gpg, etc.)
    "04-browsers"        # Google Chrome
    "05-editors"         # VS Code
    "06-ides"            # Postman
    "08-system-config"   # System configuration (Wayland, netdev)
)

configure_qa() {
    log_step "Configuring QA Environment"
    
    # Create test directories
    create_user_dir "$TARGET_HOME/test-projects"
    create_user_dir "$TARGET_HOME/test-results"
    create_user_dir "$TARGET_HOME/test-data"
    
    # Git default config
    log_info "Configuring Git..."
    run_as_user "git config --global init.defaultBranch main"
    run_as_user "git config --global user.name '$TARGET_USER'"
    
    # Install VS Code extensions for QA
    log_info "Installing VS Code extensions for QA..."
    run_as_user "code --install-extension hbenl.vscode-test-explorer 2>/dev/null" || true
    run_as_user "code --install-extension Postman.postman-for-vscode 2>/dev/null" || true
    run_as_user "code --install-extension ms-vscode.test-adapter-converter 2>/dev/null" || true
    
    echo ""
    log_success "QA environment configured"
    log_success "Test Projects: $TARGET_HOME/test-projects"
    log_success "Test Results: $TARGET_HOME/test-results"
    log_success "Test Data: $TARGET_HOME/test-data"
    
    echo ""
    log_info "Installed Tools:"
    log_info "  - VS Code (code)"
    log_info "  - Google Chrome (google-chrome)"
    log_info "  - Postman (postman)"
}
