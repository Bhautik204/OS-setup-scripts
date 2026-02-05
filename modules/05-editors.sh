#!/bin/bash
# Module: Code Editors (VS Code, Sublime)

install_editors() {
    log_step "Installing Code Editors"
    
    # VS Code
    if is_installed code; then
        log_info "VS Code already installed"
    else
        log_info "Installing VS Code..."
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
        install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
            > /etc/apt/sources.list.d/vscode.list
        rm -f /tmp/packages.microsoft.gpg
        
        apt-get update >> "$LOG_FILE" 2>&1
        install_package code
        log_success "VS Code installed: $(code --version | head -n1)"
    fi
    
    # Sublime Text
    if is_installed subl; then
        log_info "Sublime Text already installed"
    else
        log_info "Installing Sublime Text..."
        wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg \
            | gpg --dearmor -o /usr/share/keyrings/sublime.gpg 2>/dev/null
        
        echo "deb [signed-by=/usr/share/keyrings/sublime.gpg] https://download.sublimetext.com/ apt/stable/" \
            > /etc/apt/sources.list.d/sublime.list
        
        apt-get update >> "$LOG_FILE" 2>&1
        install_package sublime-text
        log_success "Sublime Text installed"
    fi
}
