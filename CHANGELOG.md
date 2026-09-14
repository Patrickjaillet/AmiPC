# Journal des Modifications — AmiPC

Toutes les modifications notables de ce projet sont documentées dans ce fichier.

Le format suit les recommandations de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/), et ce projet respecte le [Versionnage Sémantique](https://semver.org/lang/fr/).

## [Non publié]

## [0.10.6] - 2026-09-14

### Corrigé

- Compilation du paquet Buildroot `attractmode` : le patch SFML/DRM (section précédente) est validé — SFML compile désormais intégralement sans rechercher X11/OpenGL desktop. La compilation d'AttractMode échouait cependant toujours ensuite sur `squirrel.h`, `libavutil/log.h`, `nowide/cstdio.hpp` introuvables. Cause racine identifiée : `attractmode.mk` invoquait `$(MAKE) $(TARGET_CONFIGURE_OPTS) ...`, or cette macro standard Buildroot définit `CPPFLAGS="$(TARGET_CPPFLAGS)"` sur la ligne de commande — en GNU Make, une variable définie en ligne de commande a priorité absolue sur toute réaffectation `+=` ultérieure dans le Makefile, ce qui annulait silencieusement tous les `CPPFLAGS += -I$(EXTLIBS_DIR)/...` (squirrel, nowide, FFmpeg, etc.) que le Makefile amont d'AttractMode ajoute normalement lui-même selon les bibliothèques détectées via pkg-config.
- `attractmode.mk` reconstruit pour ne transmettre explicitement que les variables d'outils du toolchain croisé (`PATH`, `AR`, `AS`, `LD`, `CC`, `CXX`, `RANLIB`, `STRIP`, `PKG_CONFIG`), sans jamais fixer `CPPFLAGS`/`CFLAGS`/`CXXFLAGS` en ligne de commande, laissant le Makefile amont gérer entièrement ses propres chemins d'inclusion et flags de compilation additifs.

## [0.10.5] - 2026-09-14

### Corrigé

- Compilation du paquet Buildroot `sfml` : DRM et GBM sont désormais trouvés avec succès (fixes précédents validés), mais la configuration CMake échouait ensuite sur `Could NOT find OpenGL (missing: OPENGL_opengl_LIBRARY OPENGL_glx_LIBRARY OPENGL_INCLUDE_DIR)`. Cause : le module Window de SFML 2.6.1/2.6.2 exige inconditionnellement une interface OpenGL desktop (`find_package(OpenGL)`) sur Linux, y compris lorsque `SFML_USE_DRM` est actif — alors que le backend DRM n'utilise en réalité que des bindings EGL/GLES générés en interne (`glad/egl.h`, `DRMContext.cpp`) et n'a jamais besoin de `libGL`/`GL/gl.h`. Or dans Buildroot, l'interface libGL desktop (`BR2_PACKAGE_HAS_LIBGL`) n'est fournie que par `MESA3D_OPENGL_GLX`, lui-même verrouillé derrière `BR2_PACKAGE_XORG7` — sans alternative headless.
- Ajout d'un patch Buildroot (`0001-window-skip-desktop-opengl-detection-under-drm.patch`) au paquet `sfml` : ignore la recherche d'OpenGL desktop lorsque `SFML_USE_DRM` est actif, sans toucher au comportement standard X11/desktop de SFML sur les autres plateformes.

## [0.10.4] - 2026-09-14

### Corrigé

- Compilation du paquet Buildroot `sfml` : le backend DRM se configure désormais correctement (`SFML_USE_DRM=TRUE` validé, libdrm trouvé, X11 n'est plus recherché), mais la détection GBM échouait ensuite avec `Could NOT find GBM`. Cause : `BR2_PACKAGE_MESA3D_GBM` est une option Kconfig `depends on` (jamais activée automatiquement par un simple pilote Gallium ou par `MESA3D_OPENGL_EGL`, contrairement à ce que documentait le commentaire Kconfig amont), et n'était donc jamais réellement activée malgré la présence d'un pilote Gallium compatible (`IRIS`).
- Ajout explicite de `BR2_PACKAGE_MESA3D_GBM=y` au defconfig et en `select` dans le paquet `sfml` (`Config.in`), garantissant que `libgbm.so`/`gbm.h` sont bien construits et présents dans le sysroot cible.

## [0.10.3] - 2026-09-14

### Corrigé

- Compilation du paquet Buildroot `sfml` : le noyau et GRUB2 compilent désormais avec succès (fixes précédents validés), mais la configuration CMake de SFML échouait sur `Could NOT find X11 (missing: X11_X11_INCLUDE_PATH X11_X11_LIB)`. Cause : AmiPC est un système headless KMS/DRM sans serveur Xorg, mais SFML utilise par défaut son backend de fenêtrage X11 sur Linux, qu'aucune option n'écartait explicitement.
- Activation du backend natif DRM de SFML (`-DSFML_USE_DRM=TRUE`, disponible depuis SFML 2.6), qui s'appuie sur libdrm/GBM/EGL/eudev au lieu de X11 — cohérent avec l'architecture headless du système.
- Ajout des pilotes Gallium Mesa3D nécessaires à GBM (`IRIS`, `RADEONSI`, `NOUVEAU`, `VIRGL`, `SWRAST`), absents du defconfig bien que requis dès que `MESA3D_OPENGL_EGL` est activé — sans pilote Gallium, le support GBM n'est pas construit malgré l'option activée.

## [0.10.2] - 2026-09-13

### Corrigé

- Compilation du paquet Buildroot `attractmode` : le noyau compile désormais avec succès (correctif `libelf-dev` précédent validé), mais la compilation d'AttractMode échouait ensuite avec `fatal error: squirrel.h` et `fatal error: SFML/...`. Cause identifiée : SFML (bibliothèque C++ requise pour le fenêtrage, le rendu graphique et l'audio d'AttractMode) n'était déclarée nulle part comme dépendance, provoquant l'échec de détection via `pkg-config` puis la désactivation en cascade d'autres chemins d'inclusion du Makefile amont (dont Squirrel, pourtant fourni en sources dans `extlibs/`).
- Ajout d'un nouveau paquet Buildroot local `sfml` (`buildroot-external/package/sfml/`), compilé via CMake avec ses dépendances système (eudev, Mesa3D, FLAC, libvorbis, OpenAL, FreeType).
- `attractmode.mk` : dépendances corrigées (`sfml`, `expat`, `freetype` au lieu de `sdl2_image`/`sdl2_ttf`, non utilisés par le Makefile réel d'AttractMode), et transmission explicite de `PKG_CONFIG_PATH`/`PKG_CONFIG_SYSROOT_DIR` pointant vers le staging Buildroot afin que la détection SFML aboutisse lors de la compilation croisée.

## [0.10.1] - 2026-09-13

### Corrigé

- Site web : le fond animé Three.js du hero restait figé à sa taille de canvas par défaut (300×150), confiné en haut à gauche, car sa taille était mesurée via `clientWidth`/`clientHeight` avant que la mise en page (polices, hauteur du hero) ne soit stabilisée. Le rendu se dimensionne désormais sur `.hero` via `getBoundingClientRect`, se remesure au chargement complet, après le chargement des polices, et en continu via `ResizeObserver`.

## [0.10.0] - 2026-09-13

### Ajouté

- Refonte complète du site web du projet (`site/index.html`) : hero animé en Three.js (champ d'étoiles et grille en dérive, désactivé si `prefers-reduced-motion`), bandeau de spécifications techniques, galerie de trois aperçus d'interface cliquables ouvrant une visionneuse plein écran, grille de fonctionnalités, présentation de l'architecture logicielle en couches, section d'installation résumée, avertissement légal sur l'absence de BIOS/ROMs fournis.
- Trois maquettes SVG fidèles au thème réel du logiciel (`site/assets/mockup-*.svg`) : écran de sélection des jeux, écran « À propos », écran de paramètres — en attente de vraies captures d'écran issues d'un démarrage réel de l'image.
- Exclusion de `.claude/` (fichiers locaux de l'environnement de développement) du dépôt Git.

### Corrigé

- Workflow `publier-site.yml` : ciblait un identifiant `#version` obsolète depuis la refonte du site, ne mettant plus à jour le numéro de version affiché. Corrigé pour cibler les nouveaux identifiants `#version-affichee` et `#version-footer`.
- Script `scripts/verifier_mentions_ia.sh` : nouveaux faux positifs sur `.claude/` (nom de l'environnement de développement local, sans rapport avec une mention publique) et `.gitignore` (qui référence ce même nom de répertoire à exclure) ; ajout aux exclusions du scan.
- Dépendances système de compilation (`build-image.yml`, `publier-release.yml`, `COMPILATION.md`) : le premier build réel en CI (tag v0.9.0) a échoué à la compilation du noyau Linux avec `fatal error: libelf.h / gelf.h: No such file or directory` (`tools/objtool` du noyau nécessite `libelf-dev`). Ajout de `libelf-dev`, `flex`, `bison` et `libssl-dev` à la liste des paquets requis, absents jusqu'ici bien que documentés comme nécessaires à un build noyau complet.

## [0.9.1] - 2026-09-13

### Corrigé

- Script `scripts/verifier_mentions_ia.sh` : le motif de recherche incluait l'expression générique « IA générative », se déclenchant sur son propre nom de job dans `verifier-conformite.yml` (faux positif détecté lors du premier déclenchement CI). Le motif est resserré aux seules mentions d'outils/fournisseurs concrets (Claude, Anthropic, ChatGPT, OpenAI, Copilot, GPT-N), rendant le contrôle robuste sans liste d'exclusions à maintenir au coup par coup.
- Environnement GitHub Pages : ajout d'une règle de déploiement autorisant les tags `v*`, la politique de branche par défaut bloquant tout déploiement du site.

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
