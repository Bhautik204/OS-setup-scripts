# Welcome Document Template - Developer

Welcome to your development workstation, {{USERNAME}}!

## 🚀 Your Setup is Complete!

**Role:** Developer  
**Setup Date:** {{DATE}}  

---

## 🛠️ Installed Software

### Development
- **Java 17** - `java -version`
- **Maven** - `mvn -version`
- **Node.js** - `node --version`
- **npm** - `npm --version`

### Tools
- **Docker** - `docker --version`
- **Git** - `git --version`

### Database
- **PostgreSQL** - `psql --version`
- **Your Database:** {{USERNAME}}_dev
  - Connect: `psql -d {{USERNAME}}_dev`
- **pgAdmin** - Launch from Applications menu

### Editors & IDEs
- **VS Code** - `code` command
- **Sublime Text** - `subl` command
- **Eclipse IDE** - `eclipse` command or Applications menu

### Other
- **Postman** - Applications menu
- **Chrome** - Default browser

---

## 📁 Your Directories

- **Workspace:** ~/workspace
- **Projects:** ~/projects

---

## 🎯 Getting Started

### 1. Set up Git
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@company.com"
```

### 2. Verify Docker works
```bash
docker run hello-world
```

### 3. Create your first Spring Boot app
```bash
cd ~/projects
mvn archetype:generate -DgroupId=com.company -DartifactId=my-app -DarchetypeArtifactId=maven-archetype-quickstart
```

---

## ⚠️ Important Notes

- **Docker:** Logout and login again for Docker group to take effect
- **NVM:** Node.js is managed via NVM - `nvm ls` to see versions
- **PostgreSQL:** Service starts automatically on boot

---

## 📞 Need Help?

Contact IT Support if you have any issues.

Happy Coding! 🎉
