# Welcome Document Template - QA

Welcome to your QA workstation, {{USERNAME}}!

## 🚀 Your Setup is Complete!

**Role:** QA Engineer  
**Setup Date:** {{DATE}}  

---

## 🛠️ Installed Software

### Testing Tools
- **Postman** - API Testing (Applications menu)
- **Newman** - Postman CLI (`newman --version`)
- **Chrome** - Browser testing

### Development
- **Java 17** - For Selenium (`java -version`)
- **Node.js** - For test frameworks (`node --version`)
- **npm** - Package manager (`npm --version`)

### Tools
- **Docker** - Test environments (`docker --version`)
- **Git** - Version control (`git --version`)

### Editors
- **VS Code** - `code` command
- **Sublime Text** - `subl` command

---

## 📁 Your Directories

- **Test Projects:** ~/test-projects
- **Test Results:** ~/test-results

---

## 🎯 Getting Started

### 1. Set up Git
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@company.com"
```

### 2. Run Postman collection via CLI
```bash
newman run your-collection.json
```

### 3. Install additional test frameworks
```bash
npm install -g cypress
npm install -g @playwright/test
```

---

## ⚠️ Important Notes

- **Docker:** Logout and login again for Docker group to take effect
- **NVM:** Node.js is managed via NVM - `nvm ls` to see versions

---

## 📞 Need Help?

Contact IT Support if you have any issues.

Happy Testing! 🧪
