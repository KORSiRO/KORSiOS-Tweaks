# 🔎 KORSiOS Tweaks – FAQ

## ❓ How does rollback work?

KORSiOS Tweaks uses a local snapshot system for each tweak.

Before application:

- The original value is saved locally.
- A dedicated rollback restores only what has been modified.

It does not depend on:
- A global restore point.
- A full registry export.
- A full system snapshot.
- The rollback is isolated for each tweak.

## ❓ Does it remove system applications?

Depending on the tweaks selected, some features may be disabled or removed.

KORSiOS Tweaks does not:
- Modify the kernel
- Remove WinSxS
- Modify the servicing stack
- Touch protected system files

## ❓ Can Windows Defender flag this?

The application: 
- Injects nothing 
- Does not install persistent services
- Does not modify protected system binaries

## ❓ Why use it rather than scripts found on the web?

KORSiOS Tweaks provides:

- A structured interface
- Clear categorization
- Individual rollback
- Detailed documentation (Description / Impact / Risk / Rating)<br>

It prioritizes control and transparency over a global script.

## ❓ Does the application require an internet connection?

KORSiOS runs entirely locally:

- No network connection is required
- No data is sent
- No remote servers are contacted
You can block the application via firewall if you wish: its operation will not be affected (except for the update system)

## ❓ Does the application collect data?

KORSiOS Tweaks:
- Does not collect any user data
- Does not analyze the system
- Does not send any reports automatically
- Does not integrate any analytics tools

## ❓ Are logs generated?

The actions applied can be logged locally in order to:
- Facilitate debugging
- Enable structured feedback (via a dedicated button and manual submission of log files)
- Understand potential errors
- Logs are stored locally and are never transmitted without user action.

## ❓ What happens if a tweak is applied twice?

Tweaks are designed to be:
- Without further modification upon re-execution
- Verified before application
- If a value is already defined, the application does not unnecessarily rewrite the configuration.

## ❓ Can it make the system unstable?

Any system modification can have an impact.

Each tweak indicates:
- Its impact
- Its risk level

High-risk tweaks should be applied with caution.

## ❓ Does KORSiOS permanently modify Windows?

The changes persist until they are reverted.

However:

- Each tweak can be restored individually
- No irreversible changes are intentionally applied

## ❓ Why does SmartScreen display a warning?

SmartScreen works by reputation.

If the application:
- Is recent
- Is not signed
- Has few downloads

Windows may display a warning.

This does not mean the application is malicious.

VirusTotal links and SHA256 checksums are provided for independent verification.

## ❓ Why should I trust this tool?

You should never blindly trust a system tool.

That's why KORSiOS Tweaks:
- Documents every change
- Does not perform any hidden actions
- Does not communicate with the internet (except for an application update via the dedicated section)
- Allows individual rollbacks

## 🔍 What KORSiOS Tweaks does NOT do:

- No telemetry
- No network communication
- No hidden services
- No scheduled tasks
- No auto-updates unless the "Check for updates on startup" option is selected
- No persistent processes

Everything runs locally.


