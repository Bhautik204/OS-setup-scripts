#!/bin/bash
# Module: Docker

install_docker() {
    log_step "Installing Docker"
    
    if is_installed docker; then
        log_info "Docker already installed"
    else
        curl -fsSL https://get.docker.com | sh >> "$LOG_FILE" 2>&1
        log_success "Docker installed"
    fi
    
    # Add user to docker group
    usermod -aG docker "$TARGET_USER"
    log_success "User $TARGET_USER added to docker group"
    
    # Enable Docker service
    systemctl enable docker >> "$LOG_FILE" 2>&1
    systemctl start docker >> "$LOG_FILE" 2>&1
    
    log_success "Docker installation complete: $(docker --version)"
}
