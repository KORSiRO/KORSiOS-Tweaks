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
- Remove WinSxS
- Modify the servicing stack
- Touch protected system files

## ❓ Can Windows Defender flag this?

The application: 
- Injects nothing 
- Does not install persistent services
- Does not modify protected system binaries

## ❓ Why use it rather than scripts found on the web?

KORSiOS Tweks provides:

- A structured interface
- Clear categorization
- Individual rollback
- Detailed documentation (Description / Impact / Risk / Rating)<br>

It prioritizes control and transparency over a global script.

## 🔍 What KORSiOS Tweaks does NOT do:

- No telemetry
- No network communication
- No hidden services
- No scheduled tasks
- No auto-updates unless the "Check for updates on startup" option is selected
- No persistent processes

Everything runs locally.
