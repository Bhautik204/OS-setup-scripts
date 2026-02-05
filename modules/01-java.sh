#!/bin/bash
# Module: Java & Maven

install_java() {
    log_step "Installing Java 17 & Maven"
    
    # Check if already installed
    if is_installed java && is_installed mvn; then
        log_info "Java and Maven already installed"
        log_info "Java: $(java -version 2>&1 | head -n1)"
        log_info "Maven: $(mvn -version 2>&1 | head -n1)"
        return 0
    fi
    
    log_info "Installing OpenJDK 17 and Maven (batch mode)..."
    
    # Batch install Java and Maven
    if [[ -n "$LOG_FILE" ]]; then
        apt-get install -y openjdk-17-jdk maven 2>&1 | tee -a "$LOG_FILE"
    else
        apt-get install -y openjdk-17-jdk maven
    fi
    
    if [[ $? -ne 0 ]]; then
        log_error "Java/Maven installation failed"
        return 1
    fi
    
    log_success "Java installed: $(java -version 2>&1 | head -n1)"
    log_success "Maven installed: $(mvn -version 2>&1 | head -n1)"
    
    # Set JAVA_HOME for user
    local java_home=$(dirname $(dirname $(readlink -f $(which java))))
    
    if ! grep -q "JAVA_HOME" "$TARGET_HOME/.bashrc"; then
        log_info "Configuring JAVA_HOME in .bashrc..."
        run_as_user "echo '' >> ~/.bashrc"
        run_as_user "echo '# Java Configuration' >> ~/.bashrc"
        run_as_user "echo 'export JAVA_HOME=$java_home' >> ~/.bashrc"
        run_as_user "echo 'export PATH=\$JAVA_HOME/bin:\$PATH' >> ~/.bashrc"
        log_success "JAVA_HOME configured"
    else
        log_info "JAVA_HOME already configured"
    fi
    
    echo ""
    log_success "Java installation complete"
}
