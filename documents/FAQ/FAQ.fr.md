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

## ❓ Le rollback est-il garanti à 100 % ?

Le rollback restaure les valeurs sauvegardées au moment de l’application du tweak.

Cependant :
- Si l’utilisateur modifie manuellement la même clé après application
- Si Windows met à jour ou modifie un composant lié

Le résultat peut varier.

## ❓ Supprime-t-il des applications système ?

Selon les tweaks sélectionnés, certaines fonctionnalités peuvent être désactivées ou retirées.

KORSiOS Tweaks ne :
- Modifie pas le kernel
- Supprime pas WinSxS
- Modifie pas la servicing stack
- Touche pas aux fichiers système protégés

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

## ❓ L’application nécessite-t-elle une connexion Internet ?

KORSiOS fonctionne entièrement en local :
- Aucune connexion réseau n’est requise
- Aucune donnée n’est envoyée
- Aucun serveur distant n’est contacté
Vous pouvez bloquer l’application via pare-feu si vous le souhaitez : son fonctionnement ne sera pas affecté (sauf le système de mise à jour)

## ❓ L’application collecte-t-elle des données ?

KORSiOS Tweaks :
- Ne collecte aucune donnée utilisateur
- N’analyse pas le système
- N’envoie aucun rapport automatiquement
- N’intègre aucun outil d’analytics

## ❓ Des logs sont-ils générés ?

Les actions appliquées peuvent être journalisées localement afin de :
- Faciliter le débogage
- Permettre des retours structurés (via un bouton dédié et la transmission manuel des fichiers logs)
- Comprendre les erreurs éventuelles
- Les logs sont stockés localement et ne sont jamais transmis sans une action de l'utilisateur.

## ❓ Que se passe-t-il si un tweak est appliqué deux fois ?

Les tweaks sont conçus pour être :
- Sans modification supplémentaire lors de réexécution
- Vérifiés avant application
- Si une valeur est déjà définie, l’application ne réécrit pas inutilement la configuration.

## ❓ Peut-il rendre le système instable ?

Toute modification système peut avoir un impact.

Chaque tweak indique :
- Son impact
- Son niveau de risque

Les tweaks à risque élevé doivent être appliqués avec prudence.

## ❓ Est-ce que KORSiOS modifie Windows de manière permanente ?

Les modifications persistent tant qu’elles ne sont pas annulées.

Cependant :
- Chaque tweak peut être restauré individuellement
- Aucune modification irréversible n’est appliquée intentionnellement

## ❓ Pourquoi SmartScreen affiche-t-il un avertissement ?

SmartScreen fonctionne par réputation.

Si l’application :
- Est récente
- N’est pas signée
- Est peu téléchargée

Windows peut afficher un avertissement.

Cela ne signifie pas que l’application est malveillante.

Des liens VirusTotal et des checksums SHA256 sont fournis pour vérification indépendante.

## ❓ Pourquoi devrais-je faire confiance à cet outil ?

Vous ne devez jamais faire confiance aveuglément à un outil système.

C’est pourquoi KORSiOS Tweaks :
- Documente chaque modification
- N’exécute aucune action cachée
- Ne communique pas avec Internet (sauf pour une mise à jour de l'application via la section dédiée)
- Permet un rollback individuel

## 🔍 Ce que KORSiOS Tweaks ne fait PAS :

- Aucune télémétrie
- Aucune communication réseau
- Aucun service caché
- Aucune tâche planifiée
- Aucun auto-update sauf si l'options "Vérifier les mise à jour au lancement" est sélectionnée
- Aucun processus persistant


Tout fonctionne localement.



