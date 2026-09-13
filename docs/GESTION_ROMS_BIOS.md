# Gestion des ROMs et BIOS — AmiPC

Ce document détaille les procédures d'ajout de contenu et le mécanisme de vérification d'intégrité, en complément de la section « 7. Gestion des ROMs et BIOS » du [ROADMAP.md](../ROADMAP.md).

---

## 1. Ajout de BIOS / Kickstart

1. Placer le(s) fichier(s) BIOS dans `bios/amiga/` (formats `.rom`, `.bin`, ou fichiers Kickstart nommés `kickXXXXX.<machine>`).
2. Si le fichier correspond à une machine déjà couverte par [scripts/installer_bios.sh](../scripts/installer_bios.sh), l'ajouter à la liste `copier` de ce script.
3. Exécuter :
   ```sh
   sh scripts/installer_bios.sh
   ```
   Ceci copie le fichier vers l'arborescence système standard `config/retroarch/system/amiga/`, utilisée par le core PUAE.
4. Ajouter la référence du fichier (nom exact + taille en octets) dans `buildroot-external/package/amipc-init/files/amipc-bios-reference.txt`, au format `nom;taille`, pour qu'il soit couvert par la vérification d'intégrité au démarrage (section 4 ci-dessous).
5. Ces fichiers ne sont **jamais commités dans Git** (cf. `.gitignore`) : ils doivent être fournis par l'utilisateur final, pour des raisons de droits d'auteur (Kickstart Amiga sous copyright de Cloanto/Amiga Corp., à l'exception d'AROS qui est libre).

## 2. Ajout de Jeux

1. Placer le(s) fichier(s) de jeu (`.zip`, `.adf`, `.ipf`, `.dms`, `.hdf`) dans `roms/amiga500/` pour l'Amiga 500, ou `roms/amiga1200/` pour l'Amiga 1200.
2. Régénérer le romlist correspondant :
   ```sh
   sh scripts/generer_romlist.sh amiga500
   sh scripts/generer_romlist.sh amiga1200
   ```
3. Régénérer les sommes de contrôle de vérification d'intégrité :
   ```sh
   sh scripts/verifier_roms.sh amiga500
   sh scripts/verifier_roms.sh amiga1200
   ```
4. Comme pour les BIOS, ces fichiers ne sont jamais commités dans Git (droits d'auteur des jeux commerciaux Amiga).

## 3. Répertoire `roms/amiga1200/`

Le répertoire `roms/amiga1200/` est créé et pris en charge par l'ensemble de la chaîne d'outils (génération de romlist, vérification d'intégrité, configuration d'émulateur `amiga1200.cfg` définie en section 4 du ROADMAP) dès la présente version, même s'il ne contient actuellement aucun jeu.

## 4. Vérification d'Intégrité des BIOS au Démarrage

Le script `amipc-verifier-bios` (paquet Buildroot `amipc-init`) s'exécute automatiquement à chaque démarrage, avant le lancement d'AttractMode (appelé depuis `amipc-start.sh`) :

1. Il lit la liste de référence `/etc/amipc/bios-reference.txt` (nom de fichier + taille attendue en octets).
2. Pour chaque entrée, il vérifie la présence du fichier dans `/data/retroarch/system/amiga/` et compare sa taille réelle à la taille attendue.
3. Un rapport détaillé est écrit dans `/data/amipc-bios-etat.txt` (liste des fichiers manquants ou de taille invalide).
4. En cas d'anomalie, un marqueur `/data/.amipc-bios-avertissement` est créé ; en son absence (tout est correct), ce marqueur est supprimé s'il existait.

Cette vérification porte sur la présence et la taille des fichiers (méthode rapide, adaptée à une exécution systématique au démarrage) ; pour une vérification cryptographique complète, utiliser [scripts/verifier_roms.sh](../scripts/verifier_roms.sh) côté développement.

## 5. Avertissement Utilisateur

Le plugin AttractMode `amipc_bios_check` (`config/attract/plugins/amipc_bios_check/plugin.nut`) surveille la présence du marqueur `/data/.amipc-bios-avertissement` dès le démarrage du frontend. S'il est présent, une bannière d'avertissement rouge s'affiche à l'écran avec un message explicite (clé i18n `bios_avertissement`, traduite en français et en anglais), invitant l'utilisateur à consulter le rapport détaillé.

---

## Statut

Implémentation complète. Test réel du déclenchement de l'avertissement (BIOS volontairement retiré) à réaliser sur machine Linux cible après compilation, cf. [COMPILATION.md](../COMPILATION.md).
