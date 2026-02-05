#!/bin/bash
# Module: Java & Maven

install_java() {
    log_step "Installing Java 17 & Maven"
    
    install_package openjdk-17-jdk
    install_package maven
    
    # Set JAVA_HOME for user
    local java_home=$(dirname $(dirname $(readlink -f $(which java))))
    
    if ! grep -q "JAVA_HOME" "$TARGET_HOME/.bashrc"; then
        run_as_user "echo '' >> ~/.bashrc"
        run_as_user "echo '# Java Configuration' >> ~/.bashrc"
        run_as_user "echo 'export JAVA_HOME=$java_home' >> ~/.bashrc"
        run_as_user "echo 'export PATH=\$JAVA_HOME/bin:\$PATH' >> ~/.bashrc"
    fi
    
    log_success "Java 17 installed: $(java -version 2>&1 | head -n1)"
    log_success "Maven installed: $(mvn -version 2>&1 | head -n1)"
}
