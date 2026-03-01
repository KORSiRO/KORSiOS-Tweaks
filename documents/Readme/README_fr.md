# 🧩 KORSiOS Tweaks
<br>
<p align="right">
  <strong>🇫🇷 Français</strong> | <a href="main\README.md">🇬🇧 English</a>
</p><br><br>


![GitHub release](https://img.shields.io/github/v/release/KORSiRO/KORSiOS-Tweaks?style=flat-square) ![Platform](https://img.shields.io/badge/platform-Windows-blue?style=flat-square) ![Architecture](https://img.shields.io/badge/arch-x64-lightgrey?style=flat-square) ![License](https://img.shields.io/badge/license-Proprietary-red?style=flat-square) ![Status](https://img.shields.io/badge/status-Stable-brightgreen?style=flat-square) ![Type](https://img.shields.io/badge/type-Desktop%20Application-informational?style=flat-square) ![System](https://img.shields.io/badge/system%20changes-Yes-orange?style=flat-square) ![Admin](https://img.shields.io/badge/admin%20rights-Required-critical?style=flat-square) ![Backup](https://img.shields.io/badge/registry%20backup-Supported-success?style=flat-square) ![Control](https://img.shields.io/badge/user%20controlled-Yes-success?style=flat-square) ![Telemetry](https://img.shields.io/badge/telemetry-None-success?style=flat-square) ![Data](https://img.shields.io/badge/data%20collection-None-success?style=flat-square)

<br><br>
### KORSiOS Tweaks est un outil de personnalisation pour Windows 11 destiné à la configuration et l’optimisation avancée.
### Conçu pour appliquer proprement des réglages système ciblés (registre, fonctionnalités Windows, composants, comportements système), cet outil est axé sur la transparance pour l'utilisateur.<br><br>

## 🖥️ Aperçu de l’interface

![Welcome](screenshots/KORSiOS_Tweaks_Welcom.png)

![Tweaks](screenshots/KORSiOS_Tweaks_tweaks_détail.png)

![ScriptsAppliqués](screenshots/KORSiOS_Tweaks_scripts.png)

![EtatRegistre](screenshots/KORSiOS_Tweaks_registre.png)

![AppUWP](screenshots/KORSiOS_Tweaks_AppsUWP.png)

![RestorePoint](screenshots/KORSiOS_Tweaks_RestorePoint.png)

![Settings](screenshots/KORSiOS_Tweaks_Setting.png)

![InfoSystem](screenshots/KORSiOS_Tweaks_InfoSystem.png)

## 🎤 Présentation

KORSiOS Tweaks est conçu pour les utilisateurs souhaitant un contrôle du comportement de Windows 11, sans exécuter de scripts de debloat massifs et douteux.

Il propose :

- Interface utilisateur claire et structurée
- Tweaks basés sur le registre
- Tweaks basés sur des scripts
- Système de snapshot local par tweak
- Documentation de l’impact et du niveau de risque avant application
- Aucun service en arrière-plan
- Ne crée aucune tâche planifiée
- Aucune télémétrie
- Un système de mise à jour de l'application intégré

## 🎯 Philosophie

KORSiOS Tweaks privilégie :

- La transparence plutôt que l’automatisation aveugle
- Des modifications réversibles
- Une documentation claire
- Un contrôle précis
- Aucun comportement caché
- Ce n’est pas un outil de debloat agressif “en un clic”.

---

## ✨ Fonctionnalités principales

### ⚙️ Tweaks système
 - Organisés par catégories : Alimentation, Barre des Tâches, Explorateur, Performance, Interface UI etc.
 - Les tweaks sont exécutés de deux façons différentes : Registre .reg ou Scripts .ps1<br>
 - Chaque tweak inclut un bloc **Détails** dédié qui permet d'afficher :
    - Description
    - Impact attendu
    - Risques potentiels
    - Notes importantes<br>

Afin de savoir exactement sont utilité et ce qu'il apporte avant validation.

### 💾 Scripts appliqués / État du registre<br>
Système de rollback par tweak (restaure les valeurs précédentes (avant application du/des tweaks)
  - **Scripts appliqués** : restauration des tweaks Scripts (.ps1)
  - **État du registre** : restauration des tweaks Registe (.reg)<br>
  
Avant l’application d’un tweak :
- Les valeurs originales sont sauvegardées localement
- Le snapshot est associé uniquement à ce tweak
- Le rollback restaure uniquement les éléments modifiés
- Aucune dépendance à un point de restauration global n’est requise.

### 🧠 Apps UWP<br>
Permet de supprimer les Applications UWP présentes dans l'OS
  - Cliquez sur le bouton **Rafraîchir** pour analyser les applications
  - Une fois chargées, vous pouvez les supprimer

### 🛠️ Paramètres
  - Permet d'effectuer la mise à jour de l'application quand une nouvelle est disponible (vérification au lancement possible)
  - Permet de modifier la langue de l'application (Fr/En)
 
### ↩️ **Création de point de restauration système directement intégré**
  - Créez un point de restauration système avant toutes modifications
  - Affiche le dernier point de restauration créé depuis l'application

### 💻 **Info système**
  - Accès rapide aux informations de votre système (Version Windows/CPU/GPU/Mémoire etc.)

### 🖥️ **Interface graphique moderne**
  - Simple, lisible et orientée efficacité

---

## 🚀 Installation

1. Rendez-vous dans les **Releases**
2. Téléchargez la **dernière version stable**
3. Lancez l’installateur (Fr/En)
4. Lancez **KORSiOS Tweaks** en mode **Administrateur**

> ⚠️ **Droits administrateur requis**  
> Certaines modifications système nécessitent des privilèges élevés.

---

## 🔄 Mises à jour

- Les mises à jour sont distribuées via les **Releases GitHub**
- Chaque version est :
    - testée
    - versionnée
    - accompagnée d’un changelog clair

---

## ⚠️ Avertissement important

KORSiOS Tweaks modifie des paramètres avancés de Windows.

- Certaines options peuvent :
    - affecter la stabilité (explicitement détaillé)
    - modifier le comportement du système
    - désactiver des fonctionnalités Windows

👉 **Il est fortement recommandé de :**
- créer un point de restauration système
- sauvegarder vos données importantes
- lire attentivement les descriptions des tweaks avant application

---

## 📌 Support & retours

- 🐞 Un bug ?
- 💡 Une suggestion ?
- ❓ Une question ?

👉 Utilisez le bouton **Signaler un bug/suggestion** depuis l'application :
- Cliquez sur le bouton **Signaler un bug/suggestion**
- Validez la pop-up
- Une fenêtre s'ouvre pour donner accès au fichier **BugReport_XXXXXXXX.zip**
- Pour **signaler un bug**, uploader le fichier **BugReport_XXXXXXXX.zip sur Drive/OneDrive/Wetransfer etc.
- Copiez le lien en bas du formulaire
- Envoyez la demande

---

## 👤 Auteur

Développé par **KORSiRO**  
Projet personnel axé performance, maîtrise système et optimisation Windows.

---

## ⭐ Remerciements

Merci à toutes les personnes qui testent, remontent des bugs et contribuent à améliorer la stabilité et la qualité de KORSiOS Tweaks.
