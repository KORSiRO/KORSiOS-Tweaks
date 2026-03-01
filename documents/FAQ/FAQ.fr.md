# 🔎 KORSiOS Tweaks – FAQ

## ❓ Comment fonctionne le rollback ?

KORSiOS Tweaks utilise un système de snapshots locaux par tweak.

Avant l’application :
- La valeur originale est sauvegardée localement
- Un rollback dédié permet de restaurer uniquement ce qui a été modifié

Il ne dépend pas :
- D’un point de restauration global
- D’un export complet du registre
- D’un snapshot système complet
- Le rollback est isolé pour chaque tweak.

## ❓ Supprime-t-il des applications système ?

Selon les tweaks sélectionnés, certaines fonctionnalités peuvent être désactivées ou retirées.

KORSiOS Tweaks ne :
- Supprime pas WinSxS
- Ne modifie pas la servicing stack
- Ne touche pas aux fichiers système protégés

## ❓ Windows Defender peut-il le signaler ?

L’application :
- N’injecte rien
- N’installe aucun service persistant
- Ne modifie pas de binaires système protégés

## ❓ Pourquoi l’utiliser plutôt que des scripts trouvés sur la toile ?

KORSiOS Tweks apporte :

- Une interface structurée
- Une catégorisation claire
- Un rollback individuel
- Une documentation détaillée (Description / Impact / Risque / Note)<br>

Il privilégie le contrôle et la transparence plutôt qu’un script global.

## 🔍 Ce que KORSiOS Tweaks ne fait PAS :

- Aucune télémétrie
- Aucune communication réseau
- Aucun service caché
- Aucune tâche planifiée
- Aucun auto-update sauf si l'options "Vérifier les mise à jour au lancement" est sélectionnée
- Aucun processus persistant


Tout fonctionne localement.


