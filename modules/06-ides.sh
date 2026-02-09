#!/bin/bash
# Module: IDEs (Eclipse, Postman)

install_ides() {
    log_step "Installing IDEs & Tools"
    
    # Postman
    log_info "Installing Postman..."
    if [ -d "/opt/Postman" ]; then
        rm -rf /opt/Postman
    fi
    
    cd /tmp
    wget -q https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
    tar -xzf postman.tar.gz -C /opt
    rm postman.tar.gz
    ln -sf /opt/Postman/Postman /usr/local/bin/postman
    
    # Postman desktop entry
    create_user_dir "$TARGET_HOME/.local/share/applications"
    cat > "$TARGET_HOME/.local/share/applications/postman.desktop" << EOF
[Desktop Entry]
Name=Postman
GenericName=API Client
Exec=/opt/Postman/Postman
Terminal=false
Type=Application
Icon=/opt/Postman/app/resources/app/assets/icon.png
Categories=Development;
EOF
    fix_ownership "$TARGET_HOME/.local"
    log_success "Postman installed"
    
    # Eclipse
    log_info "Installing Eclipse IDE..."
    if [ -d "/opt/eclipse" ]; then
        rm -rf /opt/eclipse
    fi
    
    # Eclipse version - update this for newer releases
    local ECLIPSE_VERSION="2025-12"
    local ECLIPSE_FILE="eclipse-jee-${ECLIPSE_VERSION}-R-linux-gtk-x86_64.tar.gz"
    local ECLIPSE_URL="https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/${ECLIPSE_VERSION}/R/${ECLIPSE_FILE}&r=1"
    
    cd /tmp
    log_info "Downloading Eclipse ${ECLIPSE_VERSION} (this may take a few minutes)..."
    
    # Use official eclipse.org redirect which auto-selects best mirror
    if wget --progress=bar:force -O eclipse.tar.gz "${ECLIPSE_URL}" 2>&1 | tee -a "$LOG_FILE"; then
        log_success "Eclipse downloaded successfully"
    else
        log_error "Eclipse download failed. Please check your internet connection."
        return 1
    fi
    
    # Extract to /opt
    log_info "Extracting Eclipse..."
    tar -xzf eclipse.tar.gz -C /opt
    rm eclipse.tar.gz
    ln -sf /opt/eclipse/eclipse /usr/local/bin/eclipse
    
    # Verify installation
    if [ -f "/opt/eclipse/eclipse" ]; then
        log_success "Eclipse extracted to /opt/eclipse"
    else
        log_error "Eclipse extraction failed"
        return 1
    fi
    
    # Eclipse desktop entry
    cat > "$TARGET_HOME/.local/share/applications/eclipse.desktop" << EOF
[Desktop Entry]
Name=Eclipse IDE
Type=Application
Exec=/opt/eclipse/eclipse
Icon=/opt/eclipse/icon.xpm
Comment=Integrated Development Environment
NoDisplay=false
Categories=Development;IDE;
EOF
    fix_ownership "$TARGET_HOME/.local"
    log_success "Eclipse IDE ${ECLIPSE_VERSION} installed"
}
