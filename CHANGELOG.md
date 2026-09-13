# Journal des Modifications — AmiPC

Toutes les modifications notables de ce projet sont documentées dans ce fichier.

Le format suit les recommandations de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/), et ce projet respecte le [Versionnage Sémantique](https://semver.org/lang/fr/).

## [Non publié]

## [0.9.0] - 2026-09-13

### Ajouté

- Workflows GitHub Actions : `build-image.yml` (compilation à chaque tag), `publier-release.yml` (release publique avec image et notes de version extraites du CHANGELOG), `publier-site.yml` (déploiement GitHub Pages), `verifier-conformite.yml` (contrôle CI d'absence de mentions d'IA générative).
- Script `scripts/publier_version.sh` : automatisation de l'incrément SemVer et de la bascule de la section `[Non publié]` du CHANGELOG vers une version datée.
- Script `scripts/verifier_mentions_ia.sh` : détection de toute mention de Claude, Anthropic ou d'IA générative dans le dépôt (hors ROADMAP.md, qui énonce la règle elle-même).
- Script `scripts/empaqueter_release_personnelle.sh` : génération d'une archive locale complète (image + BIOS + ROMs), strictement réservée à un usage privé et jamais publiée sur GitHub.
- Source du site web du projet (`site/index.html`), déployé sur https://patrickjaillet.github.io/AmiPC avec mise à jour automatique du numéro de version.
- Documentation complète du processus de publication dans `docs/PUBLICATION.md`.
- Section `[Non publié]` ajoutée en tête du CHANGELOG pour accueillir les modifications avant chaque publication.

### Modifié

- `ROADMAP.md` confirmé comme document de suivi interne, exclu du dépôt Git public ; retrait de sa référence du tableau de documentation public dans README.md.

## [0.8.0] - 2026-09-13

### Ajouté

- Fichier README.md complet : présentation, fonctionnalités, installation, compilation, utilisation, contenu utilisateur, index de documentation, licence et copyright.
- Guide d'installation utilisateur dans `docs/INSTALLATION.md` (écriture de l'image, ajout de contenu personnel, premier démarrage, mise à jour).
- Guide de dépannage / FAQ dans `docs/DEPANNAGE.md` (problèmes courants et résolutions).
- Documentation complète de l'arborescence du projet dans `docs/ARBORESCENCE.md`.

### Note

- La capture d'écran du README.md reste à intégrer après la première compilation et le premier démarrage réel de l'image, aucune exécution n'ayant encore été réalisée.

## [0.7.1] - 2026-09-13

### Ajouté

- Protocoles de test détaillés dans `docs/TESTS.md` couvrant la section 8 du ROADMAP (démarrage physique/VM, jouabilité Amiga 500/1200, manette, sauvegarde/reprise, comportement BIOS manquant, mesure du temps de démarrage, checklist de non-régression).

### Note

- Aucun test réel n'a été exécuté : l'environnement de préparation (Windows sans WSL/Linux) ne permet ni de compiler l'image ni de la démarrer. Les cases de la section 8 du ROADMAP restent volontairement décochées jusqu'à exécution effective sur machine Linux/QEMU/matériel réel.

## [0.7.0] - 2026-09-13

### Ajouté

- Répertoire `roms/amiga1200/` créé et pris en charge par l'ensemble des scripts (romlist, vérification d'intégrité).
- Scripts `scripts/generer_romlist.sh` et `scripts/verifier_roms.sh` généralisés pour accepter le système en paramètre (`amiga500` ou `amiga1200`).
- Fichier de référence `amipc-bios-reference.txt` (nom + taille attendue) pour les 14 BIOS/Kickstart couverts.
- Script `amipc-verifier-bios` : vérification d'intégrité des BIOS (présence, taille) exécutée automatiquement au démarrage, avant le lancement d'AttractMode.
- Plugin AttractMode `amipc_bios_check` : bannière d'avertissement visible en cas de BIOS manquant ou de taille invalide, entièrement traduite (clé i18n `bios_avertissement`).
- Documentation complète des procédures d'ajout de BIOS et de jeux dans `docs/GESTION_ROMS_BIOS.md`.
- Extension du `.gitignore` pour couvrir `roms/amiga1200/` et les fichiers de sommes de contrôle générés.

### Modifié

- Renommage du fichier de sommes de contrôle `docs/roms.sha256` en `docs/roms-amiga500.sha256`, pour cohérence avec la prise en charge multi-systèmes.

## [0.6.0] - 2026-09-13

### Ajouté

- Script `amipc-detecter-langue` : définit la langue par défaut selon la locale système (`LANG`) au premier démarrage, sans écraser un choix utilisateur ultérieur.
- Documentation complète de l'internationalisation dans `docs/I18N.md`, incluant l'audit d'absence de texte codé en dur et la limite technique du formulaire natif AttractMode.

### Corrigé

- Plugin `amipc_about` : la liste des composants tiers est désormais extraite dynamiquement de `i18n/credits.json` au lieu d'une chaîne statique, garantissant sa synchronisation avec le fichier de données.

## [0.5.0] - 2026-09-13

### Ajouté

- Écran « À propos » sous forme de plugin AttractMode (`config/attract/plugins/amipc_about/`), accessible via la combinaison F1/bouton 4 (signal `custom2`).
- Fichiers d'internationalisation `i18n/fr.json` et `i18n/en.json` couvrant l'écran « À propos », le menu principal et l'écran de paramètres.
- Fichier `i18n/credits.json` listant les composants tiers (PUAE, libretro-uae, RetroArch, AttractMode, Buildroot, SDL2) avec rôle et licence.
- Lecture dynamique du numéro de version depuis `/etc/amipc/VERSION` sur l'écran « À propos », garantissant la cohérence avec le fichier VERSION du dépôt.
- Déploiement des fichiers i18n et VERSION vers l'image cible via le paquet Buildroot `amipc-init`.
- Documentation complète dans `docs/A_PROPOS.md`.

## [0.4.0] - 2026-09-13

### Ajouté

- Paquet Buildroot local `attractmode` (compilation depuis les sources GitHub officielles).
- Configurations d'émulateur AttractMode `amiga500.cfg` et `amiga1200.cfg` pointant vers RetroArch/PUAE.
- Script `scripts/generer_romlist.sh` : génération automatique du romlist Amiga 500 (141 jeux) depuis `roms/amiga500/`.
- Romlist Amiga 1200 initialisé (vide, prêt pour extension future).
- Filtres de navigation par lettre (A-E, F-M, N-S, T-Z) et par favoris (`amiga500.tag`, `attract.cfg`).
- Thème visuel `amipc` (`themes/amipc/`) : liste des jeux, aperçu snapshot/jaquette/bandeau, palette sombre avec accent cyan.
- Répertoires d'illustrations (`config/attract/artwork/`) pour le scraping de métadonnées (TheGamesDB).
- Plugin de menu de configuration in-frontend (`amipc_settings`) : langue, luminosité, réseau Wi-Fi, filtre vidéo.
- Scripts systèmes `amipc-set-langue`, `amipc-set-luminosite`, `amipc-set-reseau`, `amipc-set-shader` (paquet `amipc-init`).
- Documentation complète de l'intégration AttractMode dans `docs/ATTRACTMODE.md`.
- Intégration de la configuration AttractMode et du thème dans le paquet Buildroot `amipc-init` (copie vers `/data/attract/` et `/usr/share/attract/layouts/amipc/`).

## [0.3.0] - 2026-09-13

### Ajouté

- Configuration RetroArch minimale en mode kiosque (`config/retroarch/retroarch.cfg`) : plein écran direct, sans menu ni écran de démarrage visibles.
- Script `scripts/installer_bios.sh` : mapping automatique des BIOS/Kickstart de `bios/amiga/` vers l'arborescence système standard `config/retroarch/system/amiga/`.
- Profils de core PUAE par défaut : `amiga500.opt` (Kickstart 1.3, OCS/ECS, 1 Mo Chip), `amiga1200.opt` (Kickstart 3.1, AGA, 68020, 2 Mo Chip + 8 Mo Fast), `cd32.opt` (bonus).
- Mappage manette/clavier compatible joystick Amiga et pad CD32 (`amipc_joystick_amiga.rmp`).
- Préréglages de shaders vidéo : `pixel-perfect.glslp` (par défaut) et `scanlines.glslp` (optionnel).
- Mécanisme de configuration par jeu (overrides `.opt` nommés par contenu), avec exemple pour « Agony ».
- Documentation complète de l'intégration PUAE dans `docs/PUAE.md` (formats de jeux supportés, persistance des sauvegardes/NVRAM/WHDLoad, audio Paula).
- Intégration de la configuration RetroArch/PUAE dans le paquet Buildroot `amipc-init` (copie vers `/data/retroarch/` sur l'image cible).

## [0.2.0] - 2026-09-13

### Ajouté

- Arborescence externe Buildroot (`buildroot-external/`) pour la distribution AmiPC.
- Configuration `amipc_x86_64_defconfig` : noyau minimal, GRUB2, BusyBox init, ALSA, Mesa/DRM, SDL2, RetroArch, libretro-uae.
- Fragment de configuration noyau (`linux-amipc.fragment`) : DRM, ALSA, USB HID/manettes, Bluetooth, systèmes de fichiers.
- Scripts `post-build.sh` et `post-image.sh` : autologin sans shell visible, démarrage automatique d'AttractMode, génération d'image via `genimage.cfg`.
- Paquet Buildroot `amipc-init` : superviseur de démarrage (`amipc-start`), montage automatique USB avec règle udev (`amipc-usb-mount.sh`), script de mise à jour de l'image (`amipc-update`).
- Script `scripts/construire_image.sh` : automatisation complète du téléchargement et de la compilation Buildroot.
- Fichier COMPILATION.md détaillant la procédure de compilation, le déploiement et le nettoyage.
- Fichier `.gitignore` excluant les BIOS/Kickstart et les jeux du dépôt Git.

## [0.1.0] - 2026-09-13

### Ajouté

- Création du fichier ROADMAP.md définissant les 10 grandes étapes du projet.
- Cadrage initial du projet dans `docs/CADRAGE.md` : périmètre matériel, choix de Buildroot, cahier des charges fonctionnel, dépendances tierces.
- Inventaire complet des 24 fichiers BIOS/Kickstart présents dans `bios/amiga/` avec table de correspondance par machine Amiga.
- Inventaire des 141 jeux Amiga 500 présents dans `roms/amiga500/`.
- Script `scripts/verifier_roms.sh` de génération des sommes de contrôle SHA-256 de la ludothèque.
- Génération du fichier `docs/roms.sha256` (141 sommes de contrôle).
- Mise en place de l'arborescence initiale du dépôt (`docs/`, `system/`, `config/`, `themes/`, `build/`, `scripts/`).
- Initialisation du fichier VERSION à 0.1.0.
