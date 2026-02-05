# Execution Flow - Employee Onboarding Script

## Quick Reference

```bash
# Developer onboarding
sudo ./onboard-employee.sh johnsmith developer

# QA onboarding  
sudo ./onboard-employee.sh alice qa
```

---

## Complete Execution Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    START: sudo ./onboard-employee.sh        │
│                         <username> <role>                   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 1: show_banner()                                      │
│  Display welcome banner                                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 2: validate_inputs()                                  │
│  ├── Check running as root (sudo)                           │
│  ├── Validate username & role arguments                     │
│  ├── Check if user exists                                   │
│  │   └── If not: Create user with useradd                   │
│  │       └── passwd to set password                         │
│  ├── Get TARGET_HOME directory                              │
│  └── Check if Ubuntu (warn if not)                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 3: setup_logging()                                    │
│  ├── Create /var/log/onboarding/ directory                  │
│  └── Initialize log file: {user}-{timestamp}.log            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 4: load_libraries()                                   │
│  └── source lib/common.sh                                   │
│      ├── log_info(), log_success(), log_error()             │
│      ├── is_installed(), install_package()                  │
│      ├── run_as_user(), run_as_user_login()                 │
│      └── create_user_dir(), fix_ownership()                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 5: load_role()                                        │
│  └── source roles/{role}.sh                                 │
│      ├── Sets ROLE_NAME, ROLE_DESCRIPTION                   │
│      ├── Defines ROLE_MODULES[] array                       │
│      └── Defines configure_{role}() function                │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 6: Confirmation prompt                                │
│  "Continue? (y/n)"                                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 7: run_installation()                                 │
│  ├── For each module in ROLE_MODULES[]:                     │
│  │   ├── source modules/{module}.sh                         │
│  │   └── Call install_{name}() function                     │
│  └── Call configure_{role}() for role-specific setup        │
└─────────────────────────────────────────────────────────────┘
                              │
    ┌─────────────────────────┴─────────────────────────┐
    │                                                   │
    ▼                                                   ▼
┌─────────────────────────────┐     ┌─────────────────────────────┐
│  DEVELOPER Role Modules:    │     │  QA Role Modules:           │
│  ├── 00-base-tools          │     │  ├── 00-base-tools          │
│  ├── 01-java                │     │  ├── 01-java                │
│  ├── 02-docker              │     │  ├── 02-docker              │
│  ├── 03-postgres ◄──────────┼─────┼──┤ (NOT included)           │
│  ├── 04-browsers            │     │  ├── 04-browsers            │
│  ├── 05-editors             │     │  ├── 05-editors             │
│  ├── 06-ides                │     │  ├── 06-ides                │
│  ├── 07-nodejs              │     │  ├── 07-nodejs              │
│  └── 08-system-config       │     │  └── 08-system-config       │
└─────────────────────────────┘     └─────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Module Details                                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  00-base-tools:                                             │
│  └── apt install: curl, wget, git, unzip, ca-certificates  │
│                                                             │
│  01-java:                                                   │
│  └── apt install: openjdk-17-jdk, maven                     │
│  └── Configure JAVA_HOME in user's .bashrc                  │
│                                                             │
│  02-docker:                                                 │
│  └── Install Docker via get.docker.com                      │
│  └── Add user to docker group                               │
│                                                             │
│  03-postgres (Developer only):                              │
│  └── apt install: postgresql, postgresql-contrib            │
│  └── Create database: {username}_dev                        │
│  └── Install pgAdmin4                                       │
│                                                             │
│  04-browsers:                                               │
│  └── Download & install Google Chrome .deb                  │
│                                                             │
│  05-editors:                                                │
│  └── Install VS Code (via Microsoft repo)                   │
│  └── Install Sublime Text (via repo)                        │
│                                                             │
│  06-ides:                                                   │
│  └── Download & install Postman                             │
│  └── Download & install Eclipse IDE                         │
│  └── Create desktop entries                                 │
│                                                             │
│  07-nodejs:                                                 │
│  └── Install NVM to user's home                             │
│  └── Install Node.js LTS via NVM                            │
│  └── Configure NVM in user's .bashrc                        │
│                                                             │
│  08-system-config:                                          │
│  └── Disable Wayland in /etc/gdm3/custom.conf               │
│  └── Add user to netdev group                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 8: run_verification()                                 │
│  ├── Check all installed commands exist                     │
│  ├── Check PostgreSQL service (developer only)              │
│  ├── Check NVM and Node.js                                  │
│  └── Save verify-report.txt to user's home                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 9: generate_welcome()                                 │
│  └── Copy template from templates/welcome-{role}.md         │
│  └── Replace {{USERNAME}}, {{DATE}} placeholders            │
│  └── Save as ~/WELCOME.md                                   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 10: show_summary()                                    │
│  ├── Display completion banner                              │
│  ├── Show document locations                                │
│  ├── Show log file location                                 │
│  └── Remind about Docker group (logout/login)               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                           [END]
```

---

## File Structure

```
OS-setup-script/
├── onboard-employee.sh        # Main entry point
│
├── lib/
│   └── common.sh              # Shared functions
│       ├── log_info()         # Blue [INFO] message
│       ├── log_success()      # Green ✓ message
│       ├── log_warn()         # Yellow ⚠ message
│       ├── log_error()        # Red ✗ message
│       ├── log_step()         # Step header with lines
│       ├── is_installed()     # Check if command exists
│       ├── install_package()  # apt-get install wrapper
│       ├── run_as_user()      # Run command as target user
│       ├── run_as_user_login()# Run with login shell (for NVM)
│       ├── create_user_dir()  # mkdir + chown
│       └── fix_ownership()    # chown -R target user
│
├── modules/
│   ├── 00-base-tools.sh       # install_base_tools()
│   ├── 01-java.sh             # install_java()
│   ├── 02-docker.sh           # install_docker()
│   ├── 03-postgres.sh         # install_postgres()
│   ├── 04-browsers.sh         # install_browsers()
│   ├── 05-editors.sh          # install_editors()
│   ├── 06-ides.sh             # install_ides()
│   ├── 07-nodejs.sh           # install_nodejs()
│   └── 08-system-config.sh    # install_system_config()
│
├── roles/
│   ├── developer.sh           # ROLE_MODULES + configure_developer()
│   └── qa.sh                  # ROLE_MODULES + configure_qa()
│
└── templates/
    ├── welcome-developer.md   # Welcome doc template
    └── welcome-qa.md          # Welcome doc template
```

---

## Key Variables (Global)

| Variable | Set By | Description |
|----------|--------|-------------|
| `SCRIPT_DIR` | onboard-employee.sh | Directory where scripts are located |
| `TARGET_USER` | validate_inputs() | Username being onboarded |
| `TARGET_HOME` | validate_inputs() | User's home directory |
| `ROLE` | validate_inputs() | Role: developer or qa |
| `LOG_FILE` | setup_logging() | Path to log file |
| `ROLE_NAME` | roles/*.sh | Human-readable role name |
| `ROLE_DESCRIPTION` | roles/*.sh | Role description |
| `ROLE_MODULES` | roles/*.sh | Array of modules to install |

---

## Changes Made (Latest)

### Fix: User Creation
- Changed from `adduser` to `useradd -m -s /bin/bash`
- `useradd` is more universally available
- Added `passwd` prompt for setting password
- Added validation for TARGET_HOME directory

### Fix: Module Function Mapping
- Added explicit mapping: module name → function name
- No more string manipulation issues

### New: System Config Module
- Disables Wayland in GDM3
- Adds user to netdev group

---

## Testing Checklist

Before running on fresh Ubuntu:

- [ ] VirtualBox snapshot taken
- [ ] Internet connection available
- [ ] At least 10GB free disk space
- [ ] Running Ubuntu 20.04/22.04/24.04

Run:
```bash
cd /path/to/OS-setup-script
sudo ./onboard-employee.sh testdev developer
```

Expected output:
```
╔════════════════════════════════════════════════════════════╗
║       Employee Workstation Onboarding System               ║
╚════════════════════════════════════════════════════════════╝

User 'testdev' does not exist.
Create user 'testdev'? (y/n): y
Set password for testdev:
...
[Installation proceeds with 9 modules]
...
╔════════════════════════════════════════════════════════════╗
║             Onboarding Complete! ✓                         ║
╚════════════════════════════════════════════════════════════╝
```
