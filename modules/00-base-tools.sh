#!/bin/bash
# Module: Base Tools

install_base_tools() {
    log_step "Installing Base Tools"
    
    apt-get update >> "$LOG_FILE" 2>&1
    
    install_package curl
    install_package wget
    install_package git
    install_package unzip
    install_package ca-certificates
    install_package software-properties-common
    install_package apt-transport-https
    install_package gpg
    
    log_success "Base tools installation complete"
}
