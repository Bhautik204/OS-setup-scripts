#!/bin/bash
# Module: Browsers (Chrome)

install_browsers() {
    log_step "Installing Google Chrome"
    
    if is_installed google-chrome; then
        log_info "Chrome already installed"
    else
        cd /tmp
        wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        apt-get install -y ./google-chrome-stable_current_amd64.deb >> "$LOG_FILE" 2>&1
        rm -f google-chrome-stable_current_amd64.deb
        log_success "Chrome installed: $(google-chrome --version)"
    fi
}
