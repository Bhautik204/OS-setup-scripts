#!/bin/bash
# Module: PostgreSQL & pgAdmin

install_postgres() {
    log_step "Installing PostgreSQL & pgAdmin"
    
    # Check if PostgreSQL already installed
    if is_installed psql; then
        log_info "PostgreSQL already installed: $(psql --version)"
    else
        log_info "Installing PostgreSQL..."
        
        # Batch install PostgreSQL packages
        if [[ -n "$LOG_FILE" ]]; then
            apt-get install -y postgresql postgresql-contrib 2>&1 | tee -a "$LOG_FILE"
        else
            apt-get install -y postgresql postgresql-contrib
        fi
        
        if [[ $? -eq 0 ]]; then
            log_success "PostgreSQL installed: $(psql --version)"
        else
            log_error "PostgreSQL installation failed"
            return 1
        fi
    fi
    
    # Enable and start PostgreSQL
    log_info "Configuring PostgreSQL service..."
    systemctl enable postgresql >> "$LOG_FILE" 2>&1 || log_warn "Could not enable PostgreSQL (may not be available)"
    systemctl start postgresql >> "$LOG_FILE" 2>&1 || log_warn "Could not start PostgreSQL (may not be available)"
    
    # Create database for user
    if systemctl is-active --quiet postgresql 2>/dev/null; then
        if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "${TARGET_USER}_dev"; then
            log_info "Database ${TARGET_USER}_dev already exists"
        else
            log_info "Creating database for $TARGET_USER..."
            sudo -u postgres createuser --createdb "$TARGET_USER" 2>/dev/null || true
            sudo -u postgres createdb "${TARGET_USER}_dev" -O "$TARGET_USER" 2>/dev/null || true
            log_success "Created database: ${TARGET_USER}_dev"
        fi
    else
        log_warn "PostgreSQL service not running, skipping database creation"
    fi
    
    # pgAdmin installation
    if is_installed pgadmin4; then
        log_info "pgAdmin already installed"
    else
        log_info "Installing pgAdmin..."
        
        # Add pgAdmin repository
        if [[ ! -f /usr/share/keyrings/pgadmin.gpg ]]; then
            curl -fsSL https://www.pgadmin.org/static/packages_pgadmin_org.pub \
                | gpg --dearmor -o /usr/share/keyrings/pgadmin.gpg 2>/dev/null
        fi
        
        if [[ ! -f /etc/apt/sources.list.d/pgadmin4.list ]]; then
            echo "deb [signed-by=/usr/share/keyrings/pgadmin.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" \
                > /etc/apt/sources.list.d/pgadmin4.list
            
            # Update apt cache for new repository
            log_info "Updating package lists for pgAdmin..."
            apt-get update >> "$LOG_FILE" 2>&1
        fi
        
        # Install pgAdmin
        if [[ -n "$LOG_FILE" ]]; then
            apt-get install -y pgadmin4-desktop 2>&1 | tee -a "$LOG_FILE"
        else
            apt-get install -y pgadmin4-desktop
        fi
        
        if [[ $? -eq 0 ]]; then
            log_success "pgAdmin installed"
        else
            log_warn "pgAdmin installation failed (non-critical)"
        fi
    fi
    
    echo ""
    log_success "PostgreSQL installation complete"
}
