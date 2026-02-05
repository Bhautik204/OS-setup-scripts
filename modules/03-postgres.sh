#!/bin/bash
# Module: PostgreSQL & pgAdmin

install_postgres() {
    log_step "Installing PostgreSQL & pgAdmin"
    
    # PostgreSQL
    install_package postgresql
    install_package postgresql-contrib
    
    systemctl enable postgresql >> "$LOG_FILE" 2>&1
    systemctl start postgresql >> "$LOG_FILE" 2>&1
    
    # Create database for user
    if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "${TARGET_USER}_dev"; then
        log_info "Database ${TARGET_USER}_dev already exists"
    else
        sudo -u postgres createuser --createdb "$TARGET_USER" 2>/dev/null || true
        sudo -u postgres createdb "${TARGET_USER}_dev" -O "$TARGET_USER" 2>/dev/null || true
        log_success "Created database: ${TARGET_USER}_dev"
    fi
    
    log_success "PostgreSQL installed: $(psql --version)"
    
    # pgAdmin
    log_info "Installing pgAdmin..."
    
    curl -fsSL https://www.pgadmin.org/static/packages_pgadmin_org.pub \
        | gpg --dearmor -o /usr/share/keyrings/pgadmin.gpg 2>/dev/null
    
    echo "deb [signed-by=/usr/share/keyrings/pgadmin.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" \
        > /etc/apt/sources.list.d/pgadmin4.list
    
    apt-get update >> "$LOG_FILE" 2>&1
    install_package pgadmin4-desktop
    
    log_success "pgAdmin installed"
}
