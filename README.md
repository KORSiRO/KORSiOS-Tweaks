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

### <p align =center>THEME</p>
### <p align =center>SOMBRE / CLAIR</p>

![Theme](../screenshots/theme/KORSiOS_Tweaks_theme_fr.png)<br>


<details>
  <summary>Dark Theme</summary>
<br>
  
![Welcom](../screenshots/dark/en/KORSiOS_Tweaks_Welcome_Dark.png)
  
![Tweaks](../../screenshots/dark/en/KORSiOS_Tweaks_Tweaks_Dark.png)

![ScriptsAppliqués](../../screenshots/dark/en/KORSiOS_Tweaks_Scripts_Dark.png)

![EtatRegistre](../../screenshots/dark/en/KORSiOS_Tweaks_Registry_Dark.png)

![AppUWP](../../screenshots/dark/en/KORSiOS_Tweaks_UWP_Dark.png)

![RestorePoint](../../screenshots/dark/en/KORSiOS_Tweaks_SRP_Dark.png)

![Settings](../../screenshots/dark/en/KORSiOS_Tweaks_Parametres_Dark.png)

![InfoSystem](../../screenshots/dark/en/KORSiOS_Tweaks_InfoSystem_Dark.png)

</details><br>

<details>
  <summary>Light Theme</summary>
<br>

![Welcome](../../screenshots/light/en/KORSiOS_Tweaks_Welcome_Light.png)
  
![Tweaks](../../screenshots/light/en/KORSiOS_Tweaks_Tweaks_Light.png)

![ScriptsAppliqués](../../screenshots/light/en/KORSiOS_Tweaks_Scripts_Light.png)

![EtatRegistre](../../screenshots/light/en/KORSiOS_Tweaks_Registry_Light.png)

![AppUWP](../../screenshots/light/en/KORSiOS_Tweaks_UWP_Light.png)

![RestorePoint](../../screenshots/light/en/KORSiOS_Tweaks_SRP_Light.png)

![Settings](../../screenshots/light/en/KORSiOS_Tweaks_Settings_Light.png)

![InfoSystem](../../screenshots/light/en/KORSiOS_Tweaks_InfoSystem_Light.png)

</details><br>
## 🎤 Introduction

KORSiOS Tweaks is designed for users who want control over Windows 11 behavior without running massive and questionable debloat scripts.

It offers:

- A clear and structured user interface (Light/Dark Theme)
- Registry-based tweaks
- Script-based tweaks
- Snapshot & rollback system per tweak
- Import/Export by ID of Tweaks applied to the machine
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

After applying a tweak :
- The rollback restores only the modified elements.
- No dependency on a global restore point is required.

### 🧠 UWP Apps<br>
Allows you to remove UWP Apps present in the OS
  - Click the **Refresh** button to scan the apps
  - Once loaded, you can delete them

### 🛠️ Settings
  - Allows you to update the app when a new one is available (checking at launch is possible)
  - Allows you to change the app language (Fr/En)
  - Allows you to switch between a dark or light theme

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

## ❓ FAQ

<details>
<summary> ✔️ How does snapshot & rollback work ?</summary><br>

KORSiOS Tweaks uses a system of local snapshots per tweak.

Before application:

- The original value is saved locally.

After application:
- A dedicated rollback restores only what has been modified.

It does not depend on:

- A global restore point.
- A full registry export.
- A full system snapshot.
- The rollback is isolated for each tweak.

</details>
<details>
<summary> ✔️ Is rollback 100% guaranteed ?</summary><br> 

The rollback restores the values ​​saved at the time the tweak was applied.

However:

- If the user manually modifies the same key after application.
- If Windows updates or modifies a related component.

The result may vary.

</details>
<details>
<summary> ✔️ Does KORSiOS Tweaks remove system applications ?</summary><br>

Depending on the tweaks selected, some features may be disabled or removed.

KORSiOS Tweaks does not:

- Modify the kernel
- Remove WinSxS
- Modify the servicing stack
- Touch protected system files
</details>
<details>
<summary> ✔️ Why use KORSiOS Tweaks?</summary><br>

KORSiOS Tweaks provides:

- A structured interface
- Clear categorization
- Individual rollback
- Detailed documentation (Description / Impact / Risk / Rating)

It prioritizes control and transparency over a blanket script.

</details>
<details>
<summary> ✔️ Does the application require an internet connection?</summary><br>

KORSiOS runs entirely locally:

- No network connection is required
- No data is sent
- No remote servers are contacted. You can block the application via firewall if you wish: its operation will not be affected (except for the update system).
</details>
<details>
<summary> ✔️ Are logs generated?</summary><br>

Actions taken can be logged locally in order to:

- Facilitate debugging
- Enable structured feedback (via a dedicated button and manual submission of log files)
- Understand potential errors
- Logs are stored locally and are never transmitted without user action.

</details>
<details>
<summary> ✔️ What happens if a tweak is applied twice?</summary><br>

Tweaks are designed to be:

- Without further modification upon re-execution
- Verified before application
- If a value is already defined, the application does not unnecessarily rewrite the configuration.

</details>
<details>
<summary> ✔️ Can it make the system unstable?</summary><br>

Any system modification can have an impact.

Each tweak indicates:

- Its purpose
- Its impact
- Its risk level

High-risk tweaks should be applied with caution.

</details>
<details>
<summary> ✔️ Does KORSiOS Tweaks permanently modify Windows?</summary><br>

The modifications persist until they are undone.

However:

- Each tweak can be restored individually.
- No irreversible changes are intentionally applied.
</details>
<details>
<summary> ✔️ Why should I trust this tool?</summary><br>

You should never blindly trust a system tool.

This is why KORSiOS Tweaks:

- Documents every change
- Doesn't perform any hidden actions
- Doesn't communicate with the internet (except for an application update via the dedicated section)
- Allows individual rollbacks
</details>

<details>
<summary> ✔️ What does KORSiOS Tweaks NOT do?</summary><br>

- No telemetry
- No network communication
- No hidden services
- No scheduled tasks
- No auto-updates (the user chooses whether or not to update the application)
- No persistent processes
</details><br>

---

## 👤 Author

Developed by **KORSiRO**
Personal project focused on performance, system mastery, and Windows optimization.

---

## ⭐ Thanks

Thank you to everyone who tests, reports bugs, and contributes to improving the stability and quality of this tool.

KORSiOS Tweaks is developed independently.

If you find the application useful and would like to support its development, you can do so entirely at your own discretion.

<a href="https://www.paypal.me/korsiro" target="_blank"> <img src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif" /> </a>
