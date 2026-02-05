#!/bin/bash
# Module: Code Editors (VS Code, Sublime)

install_editors() {
    log_step "Installing Code Editors"
    
    # ========== VS Code ==========
    if is_installed code; then
        log_info "VS Code already installed: $(code --version | head -n1)"
    else
        log_info "Installing VS Code..."
        
        # Add Microsoft repository (only if not already added)
        if [[ ! -f /etc/apt/keyrings/packages.microsoft.gpg ]]; then
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
            install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
            rm -f /tmp/packages.microsoft.gpg
        fi
        
        if [[ ! -f /etc/apt/sources.list.d/vscode.list ]]; then
            echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
                > /etc/apt/sources.list.d/vscode.list
            
            # Update apt cache for new repository
            log_info "Updating package lists for VS Code..."
            apt-get update >> "$LOG_FILE" 2>&1
        fi
        
        # Install VS Code
        if [[ -n "$LOG_FILE" ]]; then
            apt-get install -y code 2>&1 | tee -a "$LOG_FILE"
        else
            apt-get install -y code
        fi
        
        if is_installed code; then
            log_success "VS Code installed: $(code --version | head -n1)"
        else
            log_error "VS Code installation failed"
        fi
    fi
    
    echo ""
    
    # ========== Sublime Text ==========
    if is_installed subl; then
        log_info "Sublime Text already installed"
    else
        log_info "Installing Sublime Text..."
        
        # Add Sublime repository (only if not already added)
        if [[ ! -f /usr/share/keyrings/sublime.gpg ]]; then
            wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg \
                | gpg --dearmor -o /usr/share/keyrings/sublime.gpg 2>/dev/null
        fi
        
        if [[ ! -f /etc/apt/sources.list.d/sublime.list ]]; then
            echo "deb [signed-by=/usr/share/keyrings/sublime.gpg] https://download.sublimetext.com/ apt/stable/" \
                > /etc/apt/sources.list.d/sublime.list
            
            # Update apt cache for new repository
            log_info "Updating package lists for Sublime..."
            apt-get update >> "$LOG_FILE" 2>&1
        fi
        
        # Install Sublime
        if [[ -n "$LOG_FILE" ]]; then
            apt-get install -y sublime-text 2>&1 | tee -a "$LOG_FILE"
        else
            apt-get install -y sublime-text
        fi
        
        if is_installed subl; then
            log_success "Sublime Text installed"
        else
            log_warn "Sublime Text installation failed (non-critical)"
        fi
    fi
    
    echo ""
    log_success "Code editors installation complete"
}
