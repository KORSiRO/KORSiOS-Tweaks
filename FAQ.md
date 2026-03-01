🔎 KORSiOS Tweaks – FAQ
❓ Qu’est-ce que KORSiOS Tweaks ?

KORSiOS Tweaks est un utilitaire de personnalisation avancée pour Windows 11 destiné aux power users, permettant un contrôle granulaire du système via des tweaks basés sur le registre et des scripts.

Il met l’accent sur :

La transparence

Le rollback par tweak

Une interface claire

Aucun service en arrière-plan

Aucune télémétrie

Ce n’est pas un script de debloat massif “en un clic”.

❓ Est-ce que c’est sûr ?

KORSiOS modifie des paramètres système (registre, services, stratégies locales), ce qui implique :

⚠️ Privilèges Administrateur requis
⚠️ Utilisation recommandée sur machine de test ou VM

Chaque tweak :

Dispose d’une description

Indique son impact

Indique un niveau de risque

Peut être annulé individuellement

Aucune modification globale aveugle n’est appliquée.

❓ Comment fonctionne le rollback ?

KORSiOS utilise un système de snapshots locaux par tweak.

Avant l’application :

La valeur originale est sauvegardée localement

Un rollback dédié permet de restaurer uniquement ce qui a été modifié

Il ne dépend pas :

D’un point de restauration global

D’un export complet du registre

D’un snapshot système complet

Le rollback est isolé pour chaque tweak.

❓ Est-ce que cela casse Windows Update ?

Les tweaks sont catégorisés et documentés.

Certains tweaks de confidentialité ou performance peuvent :

Désactiver certains composants de télémétrie

Ajuster des services en arrière-plan

Aucun tweak ne supprime intentionnellement les composants critiques de Windows Update.

Cependant :
Toujours tester avant utilisation en environnement de production.

❓ Le projet est-il open source ?

(À adapter selon ta décision)

Si fermé :

Le projet est actuellement fermé durant sa phase de développement.

Si partiellement ouvert :

Les définitions des tweaks sont transparentes et documentées.

❓ Supprime-t-il des applications système ?

Selon les tweaks sélectionnés, certaines fonctionnalités peuvent être désactivées ou retirées.

KORSiOS ne :

Supprime pas WinSxS

Ne modifie pas la servicing stack

Ne touche pas aux fichiers système protégés

❓ Windows Defender peut-il le signaler ?

L’application :

N’injecte rien

N’installe aucun service persistant

Ne modifie pas de binaires système protégés

Cependant :

Tout outil modifiant le registre ou des services peut déclencher des alertes basées sur la réputation (SmartScreen), surtout s’il n’est pas signé.

La signature numérique améliore la confiance, mais n’est pas obligatoire pour le fonctionnement.

❓ Utilise-t-il DISM ou supprime-t-il des packages système ?

Uniquement pour certains tweaks spécifiques et documentés.

Aucune suppression massive ou aveugle de packages provisionnés n’est effectuée.

❓ À qui s’adresse cet outil ?

KORSiOS est destiné à :

✔ Utilisateurs avancés
✔ Enthousiastes IT
✔ Power users
✔ Personnes à l’aise avec les modifications système

Il n’est pas conçu pour un usage grand public.

❓ Pourquoi l’utiliser plutôt que des scripts trouvés sur GitHub ?

KORSiOS apporte :

Une interface structurée

Une catégorisation claire

Un rollback individuel

Une documentation détaillée (Description / Impact / Risque / Note)

Il privilégie le contrôle et la transparence plutôt qu’un script global “exécuter et espérer”.

🔥 Section Transparence (fortement recommandée)
🔍 Ce que KORSiOS ne fait PAS

Aucune télémétrie

Aucune communication réseau

Aucun service caché

Aucune tâche planifiée

Aucun auto-update

Aucun processus persistant

Tout fonctionne localement.