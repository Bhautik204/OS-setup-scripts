#!/bin/bash
# Module: Base Tools

install_base_tools() {
    log_step "Installing Base Tools"
    
    # Run apt update only once (will be reused by other modules)
    log_info "Updating package lists..."
    if [[ -n "$LOG_FILE" ]]; then
        apt-get update 2>&1 | tee -a "$LOG_FILE"
    else
        apt-get update
    fi
    log_success "Package lists updated"
    
    echo ""
    log_info "Installing essential packages (batch mode)..."
    
    # Batch install all packages at once for efficiency
    local packages=(
        curl
        wget
        git
        unzip
        ca-certificates
        software-properties-common
        apt-transport-https
        gpg
    )
    
    if [[ -n "$LOG_FILE" ]]; then
        apt-get install -y "${packages[@]}" 2>&1 | tee -a "$LOG_FILE"
    else
        apt-get install -y "${packages[@]}"
    fi
    
    if [[ $? -eq 0 ]]; then
        log_success "All base tools installed successfully"
    else
        log_error "Some packages failed to install"
        return 1
    fi
    
    echo ""
    log_success "Base tools installation complete"
}
