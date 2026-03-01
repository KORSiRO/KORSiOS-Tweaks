# 🧩 KORSiOS Tweaks
<br>
<p align="right">
  <strong>🇬🇧 English</strong> | <a href="documents/Readme/README_fr.md">🇫🇷 Français</a>
</p><br><br>


![GitHub release](https://img.shields.io/github/v/release/KORSiRO/KORSiOS-Tweaks?style=flat-square) ![Platform](https://img.shields.io/badge/platform-Windows-blue?style=flat-square) 
![Architecture](https://img.shields.io/badge/arch-x64-lightgrey?style=flat-square) 
![License](https://img.shields.io/badge/license-Proprietary-red?style=flat-square) 
![Status](https://img.shields.io/badge/status-Stable-brightgreen?style=flat-square) 
![Type](https://img.shields.io/badge/type-Desktop%20Application-informational?style=flat-square) 
![System](https://img.shields.io/badge/system%20changes-Yes-orange?style=flat-square) 
![Admin](https://img.shields.io/badge/admin%20rights-Required-critical?style=flat-square) 
![Backup](https://img.shields.io/badge/registry%20backup-Supported-success?style=flat-square) 
![Control](https://img.shields.io/badge/user%20controlled-Yes-success?style=flat-square) 
![Telemetry](https://img.shields.io/badge/telemetry-None-success?style=flat-square) 
![Data](https://img.shields.io/badge/data%20collection-None-success?style=flat-square)

<br><br>
### KORSiOS Tweaks is a customization tool for Windows 11 designed for advanced configuration and optimization.
### Designed to cleanly apply targeted system tweaks (registry, Windows features, components, system behaviors), this tool is focused on transparency for the user.<br><br>

## 🖥️ Interface Preview

![Welcome](screenshots/KORSiOS_Tweaks_Welcome_en.png)

![Tweaks](screenshots/KORSiOS_Tweaks_tweaks_détail_en.png)

![ScriptsAppliqués](screenshots/KORSiOS_Tweaks_scripts_en.png)

![EtatRegistre](screenshots/KORSiOS_Tweaks_registre_en.png)

![AppUWP](screenshots/KORSiOS_Tweaks_AppsUWP_en.png)

![RestorePoint](screenshots/KORSiOS_Tweaks_RestorePoint_en.png)

![Settings](screenshots/KORSiOS_Tweaks_Setting_en.png)

![InfosSystem](screenshots/KORSiOS_Tweaks_InfosSystem_en.png)

## 🎤 Introduction

KORSiOS Tweaks is designed for users who want control over Windows 11 behavior without running massive and questionable debloat scripts.

It offers:

- A clear and structured user interface
- Registry-based tweaks
- Script-based tweaks
- A local snapshot system per tweak
- Documentation of the impact and risk level before application
- No background services
- Does not create any scheduled tasks
- No telemetry
- An integrated application update system

## 🎯 Philosophy

KORSiOS Tweaks prioritizes:

- Transparency over blind automation
- Reversible modifications
- Clear documentation
- Precise control
- No hidden behavior
- It is not an aggressive "one-click" debloat tool.

---

## ✨ Main Features

### ⚙️ System Tweaks<br>
- Organized by category: Power, Taskbar, File Explorer, Performance, UI, etc.
- Tweaks are executed in two different ways: Registry .reg or Scripts .ps1<br>
- Each tweak includes a dedicated **Details** block that displays :
- Description
- Expected impact
- Potential risks
- Important notes<br>

So you know exactly what it does and what it offers before you commit.

### 💾 Applied Scripts / Registry State<br>
Allows you to restore previous values ​​(before applying the tweak(s))
  - **Applied Scripts**: restores tweaks Scripts (.ps1)
  - **Registry State**: restores tweaks Regist (.reg)<br>

Before applying a tweak :
- The original values ​​are saved locally.
- The snapshot is associated only with that tweak.
- The rollback restores only the modified elements.
- No dependency on a global restore point is required.

### 🧠 UWP Apps<br>
Allows you to remove UWP Apps present in the OS
  - Click the **Refresh** button to scan the apps
  - Once loaded, you can delete them

### 🛠️ Settings
  - Allows you to update the app when a new one is available (checking at launch is possible)
  - Allows you to change the app language (Fr/En)

### ↩️ **Integrated System Restore Point Creation**
  - Create a system restore point before any changes
  - Displays the last restore point created from the application

### 💻 **System Info**
- Quick access to your system information (Windows Version/CPU/GPU/Memory etc.)

### 🖥️ **Interface Modern graphical interface**
  - Simple, readable, and efficiency-oriented

---

## 🚀 Installation

1. Go to **Releases**
2. Download the **latest stable version**
3. Run the installer (French/English)
4. Run **KORSiOS Tweaks** in **Administrator** mode

> ⚠️ **Administrator rights required**

> Some system modifications require elevated privileges.

---

## 🔄 Updates

- Updates are distributed via **GitHub Releases**
- Each version is:
  - tested
  - versioned
  - accompanied by a clear changelog

---

## ⚠️ Important Warning

KORSiOS Tweaks modifies advanced Windows settings.

- Some options may :
  - affect stability (explicitly detailed)
  - change system behavior
  - disable Windows features
  - Use of the software is **at your own risk**

👉 **It is strongly recommended to:**

- create a system restore point
- back up your important data
- carefully read the tweak descriptions before applying

---

## 📌 Support & Feedback

- 🐞 A bug?

- 💡 A suggestion?

- ❓ A question?

👉 Use the **Report a bug/suggestion** button from within the application:

- Click the **Report a bug/suggestion** button
- Confirm the pop-up
- A window will open providing access to the **BugReport_XXXXXXXX.zip** file
- To **report a bug**, upload the **BugReport_XXXXXXXX.zip** file to Drive/OneDrive/WeTransfer, etc.

- Copy the link at the bottom of the form
- Submit the request

---

## 👤 Author

Developed by **KORSiRO**
Personal project focused on performance, system mastery, and Windows optimization.

---

## [❓ FAQ](documents/FAQ/FAQ.en.md#faq)

---

## ⭐ Thanks

Thank you to everyone who tests, reports bugs, and contributes to improving the stability and quality of KORSiOS Tweaks.
