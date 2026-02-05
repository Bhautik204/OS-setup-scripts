# Enterprise Employee Onboarding System - Design Document

## 📋 Executive Summary

**Purpose:** Automated workstation setup for new employees  
**Target:** IT Administrators in corporate environments  
**Goal:** One command to fully configure a developer/QA workstation  
**Runtime:** ~20-30 minutes (depending on internet speed)

---

## 🎯 Use Case

```bash
# IT Admin receives new Ubuntu laptop
# New employee: John Smith (Developer)

sudo ./onboard-employee.sh johnsmith developer

# 30 minutes later...
# John Smith can login and start coding immediately
```

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     onboard-employee.sh                     │
│                   (Main Orchestrator)                       │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│   lib/       │   │   modules/   │   │   roles/     │
│  (Utilities) │   │ (Components) │   │  (Profiles)  │
└──────────────┘   └──────────────┘   └──────────────┘
        │                   │                   │
        └───────────────────┴───────────────────┘
                            │
                            ▼
        ┌────────────────────────────────────┐
        │     Installation Complete          │
        │  - Logs generated                  │
        │  - Verification report             │
        │  - Welcome document                │
        └────────────────────────────────────┘
```

---

## 📁 Directory Structure

```
OS-setup-script/
├── onboard-employee.sh          # Main entry point
│
├── lib/                         # Reusable utility functions
│   ├── logger.sh               # Logging system
│   ├── user-utils.sh           # User management
│   ├── validators.sh           # Input validation
│   └── common.sh               # Common functions
│
├── modules/                     # Installation modules
│   ├── 00-base-tools.sh        # curl, wget, git, etc.
│   ├── 01-java.sh              # Java 17 & Maven
│   ├── 02-docker.sh            # Docker Engine
│   ├── 03-postgres.sh          # PostgreSQL & pgAdmin
│   ├── 04-browsers.sh          # Chrome
│   ├── 05-editors.sh           # VS Code, Sublime
│   ├── 06-ides.sh              # Eclipse, Postman
│   └── 07-nodejs.sh            # NVM & Node.js
│
├── roles/                       # Role-specific configs
│   ├── developer.sh            # Full stack developer
│   └── qa.sh                   # QA engineer
│
├── templates/                   # Template files
│   ├── welcome-developer.md    # Welcome doc for developers
│   ├── welcome-qa.md           # Welcome doc for QA
│   └── desktop-entries/        # .desktop file templates
│       ├── postman.desktop.tpl
│       └── eclipse.desktop.tpl
│
├── config/                      # Configuration files
│   └── settings.conf           # Global settings
│
├── logs/                        # Generated logs (created at runtime)
│   └── .gitkeep
│
├── verify-installation.sh       # Enhanced verification script
├── uninstall.sh                # Rollback script
│
└── docs/                        # Documentation
    ├── TESTING_GUIDE.md        # (existing)
    ├── ADMIN_GUIDE.md          # IT Admin manual
    └── TROUBLESHOOTING.md      # Common issues
```

---

## 🔧 Core Components

### 1. **Main Script: `onboard-employee.sh`**

**Responsibilities:**
- Entry point validation
- User verification/creation
- Module orchestration
- Role-based installation
- Final reporting

**Flow:**
```bash
1. Validate sudo/root access
2. Parse arguments (username, role)
3. Validate user exists (or offer to create)
4. Initialize logging system
5. Create backup/restore point
6. Load required libraries
7. Execute installation modules (in order)
8. Apply role-specific configurations
9. Run verification checks
10. Generate handoff documentation
11. Display summary report
```

**Arguments:**
```bash
Usage: sudo ./onboard-employee.sh <username> <role> [options]

Arguments:
  username          Target employee username (required)
  role              developer|qa (required)

Options:
  --skip-verify     Skip final verification
  --log-dir PATH    Custom log directory
  --dry-run         Show what would be installed
  --quiet           Minimal output
  --verbose         Detailed output
  -h, --help        Show help

Examples:
  sudo ./onboard-employee.sh johnsmith developer
  sudo ./onboard-employee.sh alice qa --verbose
  sudo ./onboard-employee.sh bob developer --dry-run
```

---

### 2. **Library Functions: `lib/`**

#### **lib/logger.sh**
```bash
Functions:
- log_init()           # Initialize logging system
- log_info()           # Info message (green)
- log_warn()           # Warning message (yellow)
- log_error()          # Error message (red)
- log_success()        # Success message (green ✓)
- log_step()           # Installation step header
- log_audit()          # Audit trail entry
- generate_report()    # Final HTML/MD report
```

**Features:**
- Colored console output
- Timestamped log file
- Audit trail (separate file for compliance)
- Progress indicators
- Error tracking

#### **lib/user-utils.sh**
```bash
Functions:
- validate_user()          # Check if user exists
- create_user_interactive() # Create new user with prompts
- get_user_home()          # Get home directory path
- run_as_user()            # Execute command as target user
- set_user_ownership()     # Fix file ownership
- add_user_to_group()      # Add to docker, sudo, etc.
```

#### **lib/validators.sh**
```bash
Functions:
- validate_root()          # Check sudo/root access
- validate_ubuntu()        # Check OS is Ubuntu
- validate_internet()      # Check internet connectivity
- validate_disk_space()    # Check minimum disk space (10GB)
- validate_role()          # Check role is valid
- check_port_available()   # Check if port is free
```

#### **lib/common.sh**
```bash
Functions:
- is_installed()           # Check if package/command exists
- install_package()        # Install apt package with retry
- download_file()          # Download with progress bar
- extract_archive()        # Extract tar.gz, zip, etc.
- create_desktop_entry()   # Generate .desktop file
- add_to_path()            # Add directory to PATH
- backup_file()            # Create backup before modification
```

---

### 3. **Installation Modules: `modules/`**

Each module is **self-contained** and follows this structure:

```bash
#!/bin/bash
# Module: Java Installation
# Description: Installs OpenJDK 17 and Maven

# Module metadata
MODULE_NAME="Java Development Kit"
MODULE_CATEGORY="Development"
MODULE_REQUIRED=true

# Check if already installed
is_java_installed() {
    is_installed "java" && is_installed "mvn"
}

# Pre-installation checks
pre_install_java() {
    log_info "Checking Java prerequisites..."
    validate_disk_space 500 # 500MB minimum
}

# Main installation
install_java() {
    log_step "Installing Java 17 and Maven"
    
    install_package openjdk-17-jdk
    install_package maven
    
    log_success "Java installed: $(java -version 2>&1 | head -n1)"
}

# Post-installation configuration
post_install_java() {
    # Set JAVA_HOME for target user
    local java_home=$(dirname $(dirname $(readlink -f $(which java))))
    
    run_as_user "$TARGET_USER" << EOF
        echo 'export JAVA_HOME=$java_home' >> ~/.bashrc
        echo 'export PATH=\$JAVA_HOME/bin:\$PATH' >> ~/.bashrc
EOF
}

# Verification
verify_java() {
    log_info "Verifying Java installation..."
    
    if run_as_user "$TARGET_USER" "java -version" >/dev/null 2>&1; then
        log_success "Java verified"
        return 0
    else
        log_error "Java verification failed"
        return 1
    fi
}

# Uninstall function (for rollback)
uninstall_java() {
    apt remove -y openjdk-17-jdk maven
}
```

**Module Execution Pattern:**
```bash
for module in modules/*.sh; do
    source $module
    
    if is_${module}_installed; then
        log_info "${MODULE_NAME} already installed, skipping"
        continue
    fi
    
    pre_install_${module}
    install_${module}
    post_install_${module}
    verify_${module} || log_warn "Verification failed for ${MODULE_NAME}"
done
```

---

### 4. **Role Configurations: `roles/`**

#### **roles/developer.sh**
```bash
# Developer role configuration

ROLE_NAME="Full Stack Developer"
ROLE_DESCRIPTION="Java/Spring Boot and Node.js developer"

# Modules required for this role
REQUIRED_MODULES=(
    "00-base-tools"
    "01-java"
    "02-docker"
    "03-postgres"
    "04-browsers"
    "05-editors"
    "06-ides"
    "07-nodejs"
)

# Role-specific configurations
configure_developer() {
    log_step "Applying developer-specific configurations"
    
    # Git config
    run_as_user "$TARGET_USER" << 'EOF'
        git config --global init.defaultBranch main
        git config --global core.editor "code --wait"
EOF
    
    # Create project directories
    mkdir -p "$TARGET_HOME/workspace"
    mkdir -p "$TARGET_HOME/projects"
    chown -R $TARGET_USER:$TARGET_USER "$TARGET_HOME/workspace"
    chown -R $TARGET_USER:$TARGET_USER "$TARGET_HOME/projects"
    
    # Install VS Code extensions
    run_as_user "$TARGET_USER" << 'EOF'
        code --install-extension vscjava.vscode-java-pack
        code --install-extension dbaeumer.vscode-eslint
        code --install-extension esbenp.prettier-vscode
        code --install-extension ms-azuretools.vscode-docker
EOF
    
    log_success "Developer configuration complete"
}
```

#### **roles/qa.sh**
```bash
# QA Engineer role configuration

ROLE_NAME="QA Engineer"
ROLE_DESCRIPTION="Quality Assurance and Testing"

REQUIRED_MODULES=(
    "00-base-tools"
    "01-java"        # For Selenium
    "02-docker"      # For test environments
    "04-browsers"    # Chrome for testing
    "05-editors"     # VS Code for test scripts
    "06-ides"        # Postman for API testing
    "07-nodejs"      # For JavaScript test frameworks
)

configure_qa() {
    log_step "Applying QA-specific configurations"
    
    # Install testing tools
    run_as_user "$TARGET_USER" << 'EOF'
        # Install global npm packages for testing
        npm install -g @playwright/test
        npm install -g cypress
        npm install -g newman  # Postman CLI
EOF
    
    # Create test directories
    mkdir -p "$TARGET_HOME/test-projects"
    mkdir -p "$TARGET_HOME/test-results"
    chown -R $TARGET_USER:$TARGET_USER "$TARGET_HOME/test-projects"
    chown -R $TARGET_USER:$TARGET_USER "$TARGET_HOME/test-results"
    
    # Install VS Code extensions for QA
    run_as_user "$TARGET_USER" << 'EOF'
        code --install-extension hbenl.vscode-test-explorer
        code --install-extension Postman.postman-for-vscode
EOF
    
    log_success "QA configuration complete"
}
```

---

## 🎨 Features

### Feature 1: **Comprehensive Logging**

**Console Output:**
```
╔════════════════════════════════════════════════════════════╗
║     Employee Onboarding - Developer Workstation Setup     ║
╚════════════════════════════════════════════════════════════╝

[11:30:45] ℹ️  Target User: johnsmith
[11:30:45] ℹ️  Role: Full Stack Developer
[11:30:45] ℹ️  Log File: /var/log/onboarding/johnsmith-20260205-113045.log

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Step 1/8: Installing Base Tools
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[11:30:50] ✓ curl installed
[11:30:52] ✓ wget installed
[11:30:55] ✓ git installed
[11:30:57] ✓ Base tools installation complete

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Step 2/8: Installing Java 17 & Maven
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[11:31:15] ✓ OpenJDK 17 installed
[11:31:25] ✓ Maven installed
[11:31:26] ✓ Java configured for user: johnsmith

...
```

**Log File Structure:**
```
/var/log/onboarding/
├── johnsmith-20260205-113045.log         # Detailed execution log
├── johnsmith-20260205-113045-audit.log   # Audit trail (compliance)
└── johnsmith-20260205-113045-report.html # Visual report
```

### Feature 2: **Dry Run Mode**

```bash
sudo ./onboard-employee.sh johnsmith developer --dry-run

# Output:
[DRY RUN] Would install:
  ✓ Base Tools: curl, wget, git, unzip
  ✓ Java 17 and Maven
  ✓ Docker Engine
  ✓ PostgreSQL 14
  ✓ pgAdmin 4
  ✓ Google Chrome
  ✓ VS Code
  ✓ Sublime Text
  ✓ Postman
  ✓ Eclipse IDE
  ✓ NVM + Node.js LTS

[DRY RUN] Would configure:
  ✓ Add johnsmith to docker group
  ✓ Create PostgreSQL database: johnsmith_dev
  ✓ Install VS Code extensions (Java Pack, ESLint, Docker)
  ✓ Create workspace directories

[DRY RUN] Estimated disk space: 8.5 GB
[DRY RUN] Estimated time: 25-30 minutes
```

### Feature 3: **Automatic Verification**

```bash
# After installation completes
Running verification checks...

✓ Java 17.0.9        [OK]
✓ Maven 3.8.7        [OK]
✓ Docker 29.2.0      [OK]
✓ PostgreSQL 14.10   [OK]
✓ Chrome 131.0       [OK]
✓ VS Code 1.108.2    [OK]
✓ Sublime Text 4     [OK]
✓ Postman            [OK]
✓ Eclipse 2023-12    [OK]
✓ Node.js v20.19.6   [OK]
✓ npm 10.8.2         [OK]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Verification: 11/11 passed ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Feature 4: **Welcome Document Generation**

```markdown
# 📄 /home/johnsmith/WELCOME.md

# Welcome to Your Development Workstation! 🚀

**Employee:** John Smith  
**Role:** Full Stack Developer  
**Setup Date:** February 5, 2026  
**Workstation ID:** DEV-WS-1234

---

## 🛠️ Installed Software

### Development Tools
- **Java:** OpenJDK 17.0.9 (`java -version`)
- **Maven:** 3.8.7 (`mvn -version`)
- **Node.js:** v20.19.6 (`node --version`)
- **npm:** 10.8.2 (`npm --version`)

### IDEs & Editors
- **Eclipse IDE**: `/usr/local/bin/eclipse`
- **VS Code**: `code` command
- **Sublime Text**: `subl` command

### Tools
- **Docker**: `docker --version`
- **Postman**: Launch from Applications menu
- **Chrome**: Default browser

### Database
- **PostgreSQL 14**
  - Database: `johnsmith_dev`
  - Connect: `psql -d johnsmith_dev`

---

## 🚀 Getting Started

### 1. Verify Everything Works
```bash
cd ~ && cat verify-report.txt
```

### 2. Set Up Git
```bash
git config --global user.name "John Smith"
git config --global user.email "johnsmith@company.com"
```

### 3. Your Workspace
- Projects: `~/projects/`
- Workspace: `~/workspace/`

### 4. First Spring Boot App
```bash
cd ~/projects
mvn archetype:generate -DgroupId=com.company \
    -DartifactId=my-first-app \
    -DarchetypeArtifactId=maven-archetype-quickstart
```

---

## 📞 Need Help?

- IT Support: it-support@company.com
- Setup Issues: Check `~/onboarding-log.txt`

---

**Note:** You may need to logout/login for Docker group changes to take effect.
```

### Feature 5: **Error Handling & Rollback**

```bash
# If installation fails at any point
[ERROR] Docker installation failed!

Options:
  1. Retry this step
  2. Skip and continue
  3. Rollback and exit

Choice: 3

[INFO] Rolling back changes...
✓ Removed Docker packages
✓ Restored package lists
✓ Cleaned up temporary files

[INFO] System restored to pre-installation state
[INFO] Log saved: /var/log/onboarding/johnsmith-FAILED-20260205-113045.log
```

---

## 🔐 Security Considerations

### 1. **Package Verification**
- All packages from official Ubuntu repositories
- GPG keys verified for third-party repos (Chrome, VS Code, etc.)
- Checksums verified for downloaded binaries

### 2. **Audit Trail**
```
Every action logged with:
- Timestamp
- User executing (root/target user)
- Command executed
- Exit code
- Output/errors
```

### 3. **Sudo Usage**
- Script requires sudo
- Clearly shows when running as root vs target user
- No password stored or logged

### 4. **Network Security**
- All downloads over HTTPS
- Verified sources only
- No arbitrary script execution from internet

---

## ⚙️ Configuration File

**config/settings.conf**
```bash
# Global Configuration

# Installation Settings
INSTALL_TIMEOUT=300              # Timeout for each module (seconds)
RETRY_COUNT=3                    # Retry failed downloads
PARALLEL_DOWNLOADS=false         # Download sequentially for reliability

# Logging
LOG_DIR="/var/log/onboarding"
LOG_LEVEL="INFO"                 # DEBUG, INFO, WARN, ERROR
KEEP_LOGS_DAYS=90               # Audit requirement

# User Settings
CREATE_WORKSPACE=true
WORKSPACE_DIR="workspace"
PROJECTS_DIR="projects"

# Database
POSTGRES_CREATE_DB=true
POSTGRES_DB_SUFFIX="_dev"

# Node.js
NODE_VERSION="--lts"            # Can specify version: "20.19.6"

# Java
JAVA_VERSION="17"

# Verification
RUN_VERIFICATION=true
FAIL_ON_VERIFICATION_ERROR=false

# Role-specific
DEVELOPER_VSCODE_EXTENSIONS=(
    "vscjava.vscode-java-pack"
    "dbaeumer.vscode-eslint"
    "esbenp.prettier-vscode"
    "ms-azuretools.vscode-docker"
)

QA_VSCODE_EXTENSIONS=(
    "hbenl.vscode-test-explorer"
    "Postman.postman-for-vscode"
)
```

---

## 📊 Success Metrics

### What Gets Measured:
1. **Installation Time**
   - Total time
   - Per-module time
   - Network download time

2. **Success Rate**
   - % of successful installations
   - % of verification passes
   - Common failure points

3. **Resource Usage**
   - Disk space used
   - Network bandwidth used
   - Check against company policies

4. **Audit Compliance**
   - All installations logged
   - User actions traceable
   - Change management documentation

---

## 🧪 Testing Strategy

### 1. **Unit Tests** (per module)
```bash
# Test individual module
./test-module.sh java

# Verify:
- Pre-checks work
- Installation succeeds
- Post-config applied
- Verification passes
- Uninstall works
```

### 2. **Integration Tests** (full flow)
```bash
# Test complete onboarding
./test-onboarding.sh

# Scenarios:
- Fresh Ubuntu install
- Partial installation (some tools already present)
- Failed installation (test rollback)
- Different roles (developer, QA)
```

### 3. **Acceptance Tests**
- Real employee onboarding
- Timed execution
- All tools functional
- Documentation accurate

---

## 📋 Deliverables

### Scripts
1. ✅ `onboard-employee.sh` - Main orchestrator
2. ✅ `lib/*.sh` - Utility libraries
3. ✅ `modules/*.sh` - Installation modules
4. ✅ `roles/*.sh` - Role configurations
5. ✅ `verify-installation.sh` - Enhanced verification
6. ✅ `uninstall.sh` - Rollback script

### Documentation
1. ✅ `DESIGN.md` - This document
2. ✅ `ADMIN_GUIDE.md` - IT admin manual
3. ✅ `TROUBLESHOOTING.md` - Common issues
4. ✅ Template welcome documents

### Configuration
1. ✅ `config/settings.conf` - Global settings
2. ✅ Desktop entry templates
3. ✅ Role configurations

---

## 🎯 Implementation Phases

### Phase 1: Core Framework ✓ (You are here)
- Design document
- Directory structure
- Main script skeleton
- Logging system

### Phase 2: Basic Modules
- 00-base-tools
- 01-java
- 02-docker
- 07-nodejs

### Phase 3: Additional Modules
- 03-postgres
- 04-browsers
- 05-editors
- 06-ides

### Phase 4: Role System
- Developer role
- QA role
- Role-specific configs

### Phase 5: Polish & Testing
- Verification script
- Welcome documents
- Error handling
- Documentation

---

## 🔄 Maintenance Plan

### Regular Updates
- Ubuntu package updates (monthly)
- Third-party tool versions (quarterly)
- Security patches (as needed)

### Version Control
```
Git tags for each release:
v1.0.0 - Initial release
v1.1.0 - Added QA role
v1.2.0 - Added verification improvements
```

### Change Log
All changes documented in `CHANGELOG.md`

---

## ⏱️ Estimated Implementation Time

| Phase | Time | Status |
|-------|------|--------|
| Design & Planning | 2-3 hours | ✅ Complete |
| Core Framework | 3-4 hours | 🔄 Next |
| Basic Modules | 4-5 hours | ⏳ Pending |
| Additional Modules | 3-4 hours | ⏳ Pending |
| Role System | 2-3 hours | ⏳ Pending |
| Testing & Polish | 3-4 hours | ⏳ Pending |
| Documentation | 2-3 hours | ⏳ Pending |
| **Total** | **19-26 hours** | |

---

## 🚦 Next Steps

**For Review:**
1. ✅ Approve directory structure
2. ✅ Approve module breakdown
3. ✅ Approve logging approach
4. ✅ Approve role definitions

**After Approval:**
1. Create directory structure
2. Implement core framework (main script + lib/)
3. Implement modules one by one
4. Add role configurations
5. Create documentation
6. Test in VM environment

---

## ❓ Questions for Clarification

Before I start implementation:

1. **Company Specifics:**
   - Company name for branding in welcome docs?
   - IT support email/contact?
   - Any company-specific tools to add?

2. **Policies:**
   - Password requirements for new users?
   - Disk quotas?
   - Network proxy settings?

3. **Preferences:**
   - Preferred Java version (currently 17)?
   - Preferred Node.js version (currently LTS)?
   - Eclipse version preferences?

4. **Extensions:**
   - Any additional VS Code extensions?
   - Company-specific git repositories to clone?
   - Custom scripts to include?

---

## 🎉 Benefits

### For IT Admins:
- ✅ **Save 4-6 hours** per employee onboarding
- ✅ **Consistent** setups across all developers
- ✅ **Auditable** with complete logs
- ✅ **Maintainable** modular structure

### For Employees:
- ✅ **Ready to work** on day 1
- ✅ **No missing tools** - everything needed
- ✅ **Documentation** included
- ✅ **Verified** working installation

### For Company:
- ✅ **Faster onboarding** = productivity sooner
- ✅ **Compliance** with audit requirements
- ✅ **Standardization** across teams
- ✅ **Reduced IT tickets**

---

**Ready to implement?** 🚀

Let me know if you want any changes to this design, or if I should proceed with implementation!

