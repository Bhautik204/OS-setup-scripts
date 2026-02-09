#!/bin/bash
# Module: NVM & Node.js

install_nodejs() {
    log_step "Installing NVM & Node.js"
    
    local NVM_DIR="$TARGET_HOME/.nvm"
    
    # Install NVM as target user
    if [ -d "$NVM_DIR" ]; then
        log_info "NVM already installed"
    else
        log_info "Installing NVM..."
        run_as_user "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash"
        log_success "NVM installed"
    fi
    
    # Add NVM to bashrc if not present
    if ! grep -q "NVM_DIR" "$TARGET_HOME/.bashrc"; then
        run_as_user "echo '' >> ~/.bashrc"
        run_as_user "echo '# NVM Configuration' >> ~/.bashrc"
        run_as_user 'echo "export NVM_DIR=\"\$HOME/.nvm\"" >> ~/.bashrc'
        run_as_user 'echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\"" >> ~/.bashrc'
        run_as_user 'echo "[ -s \"\$NVM_DIR/bash_completion\" ] && \\. \"\$NVM_DIR/bash_completion\"" >> ~/.bashrc'
    fi
    
    # Install Node.js LTS
    log_info "Installing Node.js LTS..."
    run_as_user_login "source ~/.nvm/nvm.sh && nvm install --lts && nvm use --lts && nvm alias default 'lts/*'"
    
    local node_version=$(run_as_user_login "source ~/.nvm/nvm.sh && node --version" 2>/dev/null)
    local npm_version=$(run_as_user_login "source ~/.nvm/nvm.sh && npm --version" 2>/dev/null)
    
    log_success "Node.js installed: $node_version"
    log_success "npm installed: $npm_version"
}
