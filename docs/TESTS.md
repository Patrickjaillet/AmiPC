# Protocoles de Test — AmiPC

Ce document définit les protocoles de test à exécuter pour valider la section « 8. Qualité, Tests et Validation » du [ROADMAP.md](../ROADMAP.md).

**Important** : ces tests nécessitent une image AmiPC compilée (cf. [COMPILATION.md](../COMPILATION.md)) et une exécution sur machine physique, machine virtuelle ou émulateur réel. Aucun d'entre eux n'a été exécuté à ce stade de la préparation du projet ; les cases correspondantes du ROADMAP ne doivent être cochées qu'après exécution effective et consignation du résultat dans ce document.

---

## 1. Démarrage sur Machine Physique (BIOS/UEFI)

**Prérequis** : image `amipc.img` gravée sur clé USB (cf. section « Déploiement de l'image » de [COMPILATION.md](../COMPILATION.md)).

**Procédure** :
1. Démarrer la machine cible avec la clé USB insérée, forcer le boot sur USB (menu de boot ou ordre de démarrage du BIOS/UEFI).
2. Vérifier le démarrage en mode BIOS legacy (Boot Menu classique).
3. Vérifier le démarrage en mode UEFI (Secure Boot désactivé, GRUB2 configuré pour EFI dans `amipc_x86_64_defconfig`).
4. Constater l'arrivée directe sur l'interface AttractMode, sans invite shell visible.

**Critères de réussite** : démarrage sans erreur dans les deux modes, interface AttractMode fonctionnelle, aucune trace de console visible à l'écran.

**Résultat** : _non exécuté_.

---

## 2. Démarrage en Machine Virtuelle (QEMU/VirtualBox)

**Procédure** :
```sh
qemu-system-x86_64 -m 1024 -drive file=amipc.img,format=raw -vga std -enable-kvm
```
Répéter avec VirtualBox (import de l'image en disque IDE/SATA, 1 Go de RAM minimum, contrôleur graphique VBoxVGA ou VMSVGA).

**Critères de réussite** : démarrage complet, résolution graphique correcte, pas de blocage au niveau du noyau ou de l'init.

**Résultat** : _non exécuté_.

---

## 3. Jouabilité — Échantillon Amiga 500

**Échantillon recommandé** (représentatif des genres et tailles présents dans `roms/amiga500/`) :

| Jeu                                              | Genre          | Intérêt du test                  |
|---------------------------------------------------|----------------|-------------------------------------|
| Kick Off 2                                         | Sport          | Réactivité manette, jeu léger       |
| Agony                                              | Shoot'em up     | Chipset OCS/ECS, action rapide      |
| Another World                                      | Aventure/Action| Séquences cinématiques, timing      |
| Monkey Island 2 - LeChuck's Revenge                | Point & Click  | Disquettes multiples, sauvegarde    |
| Cannon Fodder                                      | Stratégie      | Souris + clavier                    |
| Flashback                                          | Plateforme     | Fast RAM, performance CPU           |

**Procédure** : pour chaque jeu, lancer depuis AttractMode, valider l'affichage, le son, les contrôles, et une sauvegarde/reprise si le jeu le permet. Noter tout écran noir, plantage, ou désynchronisation audio/vidéo.

**Résultat** : _non exécuté_.

---

## 4. Jouabilité — Échantillon Amiga 1200

**Statut** : `roms/amiga1200/` est actuellement vide (cf. section 7 du ROADMAP). Ce test devra être exécuté après l'ajout d'un échantillon de jeux AGA dans ce répertoire (par exemple des titres nécessitant le chipset AGA et une CPU 68020, afin de valider spécifiquement le profil `amiga1200.opt`).

**Résultat** : _non exécuté — en attente de contenu de test_.

---

## 5. Prise en Charge Manette

**Procédure** :
1. Brancher une manette USB filaire générique, vérifier sa détection (`input_autodetect_enable` dans `retroarch.cfg`) et tester la navigation dans AttractMode puis en jeu.
2. Appairer une manette Bluetooth (pilote `CONFIG_BT_HIDP` activé dans le fragment noyau), répéter le test.
3. Valider le mappage défini dans `config/retroarch/config/PUAE/amipc_joystick_amiga.rmp` (1 bouton standard, 2 boutons CD32).
4. Valider le montage/démontage à chaud (branchement/débranchement en cours de session).

**Résultat** : _non exécuté_.

---

## 6. Sauvegarde / Reprise de Partie

**Procédure** :
1. Lancer un jeu supportant la sauvegarde native (ex. Monkey Island 2) ou WHDLoad, créer une sauvegarde.
2. Quitter vers AttractMode, relancer le jeu, charger la sauvegarde.
3. Vérifier la persistance après redémarrage complet de la machine (les répertoires `saves`/`states` doivent résider sur la partition de données, hors image système, cf. `docs/PUAE.md`).

**Résultat** : _non exécuté_.

---

## 7. Comportement en Cas de BIOS/ROM Absent ou Corrompu

**Procédure** :
1. Retirer temporairement un fichier de `config/retroarch/system/amiga/` (ex. `kick34005.A500`) ou en corrompre la taille.
2. Redémarrer l'image, vérifier que `amipc-verifier-bios` détecte l'anomalie (cf. `docs/GESTION_ROMS_BIOS.md`).
3. Vérifier l'affichage de la bannière d'avertissement du plugin `amipc_bios_check` dans AttractMode, dans les deux langues (FR/EN).
4. Restaurer le fichier, vérifier la disparition de l'avertissement au redémarrage suivant.

**Résultat** : _non exécuté_.

---

## 8. Mesure du Temps de Démarrage

**Automatisé** : le workflow [`.github/workflows/mesurer-temps-boot.yml`](../.github/workflows/mesurer-temps-boot.yml) télécharge automatiquement l'image de la dernière release (ou d'un tag donné, via déclenchement manuel), la démarre sous QEMU/KVM sur le runner GitHub Actions, et mesure le temps écoulé entre le boot du noyau Linux et le lancement effectif d'AttractMode. Le script [`amipc-start.sh`](../buildroot-external/package/amipc-init/files/amipc-start.sh) écrit un marqueur (`AMIPC_BOOT_MARKER <secondes>`, basé sur `/proc/uptime`) sur la console série juste avant de lancer AttractMode ; le workflow lit ce marqueur pour calculer la durée et la publie dans le résumé du run ainsi qu'un journal de démarrage complet en artefact.

Se déclenche automatiquement à chaque publication de release, ou manuellement via `workflow_dispatch` (onglet Actions du dépôt, en précisant éventuellement un tag).

**Limite connue** : cette mesure couvre le temps depuis le boot du noyau jusqu'à AttractMode ; elle n'inclut ni le temps de firmware (BIOS/UEFI) ni celui du menu GRUB2, propres à chaque machine physique et non mesurables en CI. Une mesure complémentaire sur machine physique réelle (chronométrage manuel de la mise sous tension à l'affichage d'AttractMade) reste à documenter ci-dessous pour compléter cette donnée automatisée.

| Environnement                          | Temps mesuré (noyau → AttractMode) | Date       |
|-----------------------------------------|--------------------------------------|------------|
| QEMU/KVM (GitHub Actions, automatisé)   | _voir résumé du dernier run du workflow_ | _voir historique Actions_ |
| Machine physique (BIOS/UEFI)            | _à renseigner_                       | _à renseigner_ |

**Résultat** : mesure automatisée en place et exécutable dès la prochaine release ; mesure sur machine physique réelle toujours à réaliser manuellement.

---

## 9. Tests de Non-Régression

Avant chaque publication de version (incrément du fichier [VERSION](../VERSION) et entrée [CHANGELOG.md](../CHANGELOG.md)), exécuter à minima :

- [ ] Rebuild complet de l'image via `scripts/construire_image.sh` sans erreur.
- [ ] Test 1 (boot physique) ou Test 2 (boot VM) au choix selon disponibilité matérielle.
- [ ] Relance de 3 jeux de l'échantillon de la section 3 (ou 4 si applicable).
- [ ] Vérification de l'écran « À propos » (numéro de version à jour, cf. `docs/A_PROPOS.md`).
- [ ] Vérification de l'absence d'avertissement BIOS sur une image correctement provisionnée.

Consigner le résultat de chaque campagne de non-régression dans une nouvelle section datée ci-dessous.

### Historique des campagnes

_Aucune campagne exécutée à ce jour._

---

## Statut

Protocoles rédigés et prêts à l'exécution. Aucun test de cette section n'a été réalisé : l'environnement de préparation (Windows sans WSL/Linux) ne permet ni de compiler l'image, ni de la démarrer. Les cases correspondantes du ROADMAP resteront décochées jusqu'à exécution effective sur machine Linux/QEMU/matériel réel, avec consignation des résultats dans ce document.
