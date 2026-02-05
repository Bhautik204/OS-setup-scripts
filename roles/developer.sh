#!/bin/bash
# Role: Developer
# Full stack developer configuration

ROLE_NAME="Developer"
ROLE_DESCRIPTION="Full Stack Developer - Java/Spring Boot & Node.js"

# Modules to install for this role
ROLE_MODULES=(
    "00-base-tools"
    "01-java"
    "02-docker"
    "03-postgres"
    "04-browsers"
    "05-editors"
    "06-ides"
    "07-nodejs"
    "08-system-config"
)

configure_developer() {
    log_step "Configuring Developer Environment"
    
    # Create workspace directories
    create_user_dir "$TARGET_HOME/workspace"
    create_user_dir "$TARGET_HOME/projects"
    
    # Git default config
    run_as_user "git config --global init.defaultBranch main"
    run_as_user "git config --global core.editor 'code --wait'"
    
    # Install VS Code extensions
    log_info "Installing VS Code extensions..."
    run_as_user "code --install-extension vscjava.vscode-java-pack 2>/dev/null" || true
    run_as_user "code --install-extension dbaeumer.vscode-eslint 2>/dev/null" || true
    run_as_user "code --install-extension esbenp.prettier-vscode 2>/dev/null" || true
    run_as_user "code --install-extension ms-azuretools.vscode-docker 2>/dev/null" || true
    
    log_success "Developer environment configured"
    log_success "Workspace: $TARGET_HOME/workspace"
    log_success "Projects: $TARGET_HOME/projects"
}
