#!/bin/bash
# Module: Browsers (Chrome)

install_browsers() {
    log_step "Installing Google Chrome"
    
    if is_installed google-chrome; then
        log_info "Chrome already installed: $(google-chrome --version)"
        return 0
    fi
    
    log_info "Downloading Google Chrome..."
    
    # Download to /tmp
    cd /tmp || return 1
    
    # Check if already downloaded
    if [[ ! -f google-chrome-stable_current_amd64.deb ]]; then
        if [[ -n "$LOG_FILE" ]]; then
            wget -q --show-progress https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb 2>&1 | tee -a "$LOG_FILE"
        else
            wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        fi
    else
        log_info "Chrome package already downloaded"
    fi
    
    log_info "Installing Chrome..."
    if [[ -n "$LOG_FILE" ]]; then
        apt-get install -y ./google-chrome-stable_current_amd64.deb 2>&1 | tee -a "$LOG_FILE"
    else
        apt-get install -y ./google-chrome-stable_current_amd64.deb
    fi
    
    # Clean up
    rm -f google-chrome-stable_current_amd64.deb
    
    if is_installed google-chrome; then
        log_success "Chrome installed: $(google-chrome --version)"
    else
        log_error "Chrome installation failed"
        return 1
    fi
    
    echo ""
    log_success "Chrome installation complete"
}
