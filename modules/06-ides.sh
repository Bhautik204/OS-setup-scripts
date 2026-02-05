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
    
    cd /opt
    wget -q https://ftp2.osuosl.org/pub/eclipse/technology/epp/downloads/release/2023-12/R/eclipse-jee-2023-12-R-linux-gtk-x86_64.tar.gz -O eclipse.tar.gz
    tar -xzf eclipse.tar.gz
    rm eclipse.tar.gz
    ln -sf /opt/eclipse/eclipse /usr/local/bin/eclipse
    
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
    log_success "Eclipse IDE installed"
}
