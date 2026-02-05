#!/bin/bash
# Role: QA
# QA Engineer configuration

ROLE_NAME="QA Engineer"
ROLE_DESCRIPTION="Quality Assurance - Testing & Automation"

# Modules to install for this role (lighter than developer)
ROLE_MODULES=(
    "00-base-tools"
    "01-java"
    "02-docker"
    "04-browsers"
    "05-editors"
    "06-ides"
    "07-nodejs"
    "08-system-config"
)

configure_qa() {
    log_step "Configuring QA Environment"
    
    # Create test directories
    create_user_dir "$TARGET_HOME/test-projects"
    create_user_dir "$TARGET_HOME/test-results"
    
    # Git default config
    run_as_user "git config --global init.defaultBranch main"
    
    # Install testing tools via npm
    log_info "Installing testing tools..."
    run_as_user_login "source ~/.nvm/nvm.sh && npm install -g newman 2>/dev/null" || true
    
    # Install VS Code extensions for QA
    log_info "Installing VS Code extensions..."
    run_as_user "code --install-extension hbenl.vscode-test-explorer 2>/dev/null" || true
    run_as_user "code --install-extension Postman.postman-for-vscode 2>/dev/null" || true
    
    log_success "QA environment configured"
    log_success "Test Projects: $TARGET_HOME/test-projects"
    log_success "Test Results: $TARGET_HOME/test-results"
}
