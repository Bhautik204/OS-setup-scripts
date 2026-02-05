#!/bin/bash
# Module: System Configuration
# Configures GDM, display settings, and user groups

install_system_config() {
    log_step "Configuring System Settings"
    
    # ---------- Disable Wayland in GDM3 ----------
    log_info "Configuring GDM3 (disabling Wayland)..."
    
    local gdm_config="/etc/gdm3/custom.conf"
    
    if [[ -f "$gdm_config" ]]; then
        # Backup original config
        if [[ ! -f "${gdm_config}.backup" ]]; then
            cp "$gdm_config" "${gdm_config}.backup"
            log_info "Backup created: ${gdm_config}.backup"
        fi
        
        # Check if WaylandEnable line exists
        if grep -q "^WaylandEnable=" "$gdm_config"; then
            # Update existing line
            sed -i 's/^WaylandEnable=.*/WaylandEnable=false/' "$gdm_config"
            log_success "WaylandEnable set to false (updated existing)"
        elif grep -q "^#WaylandEnable=" "$gdm_config"; then
            # Uncomment and set to false
            sed -i 's/^#WaylandEnable=.*/WaylandEnable=false/' "$gdm_config"
            log_success "WaylandEnable set to false (uncommented)"
        else
            # Add under [daemon] section
            if grep -q "^\[daemon\]" "$gdm_config"; then
                sed -i '/^\[daemon\]/a WaylandEnable=false' "$gdm_config"
                log_success "WaylandEnable=false added under [daemon]"
            else
                # Add [daemon] section with WaylandEnable
                echo "" >> "$gdm_config"
                echo "[daemon]" >> "$gdm_config"
                echo "WaylandEnable=false" >> "$gdm_config"
                log_success "Added [daemon] section with WaylandEnable=false"
            fi
        fi
    else
        log_warn "GDM3 config not found at $gdm_config"
        log_info "Creating GDM3 config..."
        
        cat > "$gdm_config" << 'EOF'
# GDM configuration storage
#
# See /usr/share/gdm/gdm.schemas for a list of available options.

[daemon]
WaylandEnable=false

[security]

[xdmcp]

[chooser]

[debug]
EOF
        log_success "GDM3 config created with WaylandEnable=false"
    fi
    
    # ---------- Add user to netdev group ----------
    log_info "Adding $TARGET_USER to netdev group..."
    
    # Check if netdev group exists
    if getent group netdev > /dev/null 2>&1; then
        usermod -aG netdev "$TARGET_USER"
        log_success "User $TARGET_USER added to netdev group"
    else
        # Create netdev group if doesn't exist
        groupadd netdev
        usermod -aG netdev "$TARGET_USER"
        log_success "Created netdev group and added $TARGET_USER"
    fi
    
    # Show current groups for user
    log_info "User groups: $(groups $TARGET_USER)"
    
    log_success "System configuration complete"
}
