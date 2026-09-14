# Journal des Modifications — AmiPC

Toutes les modifications notables de ce projet sont documentées dans ce fichier.

Le format suit les recommandations de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/), et ce projet respecte le [Versionnage Sémantique](https://semver.org/lang/fr/).

## [Non publié]

## [0.10.21] - 2026-09-15

### Modifié

- Mise à jour du ROADMAP.md pour refléter le premier succès complet de compilation (release v0.10.19) : cases cochées pour la compilation effective du core libretro-uae, la compilation/liaison/installation d'AttractMode, et la publication réelle d'une release GitHub avec image téléchargeable (`amipc.img`, ~1,53 Go).

## [0.10.20] - 2026-09-15

### Ajouté

- Workflow `mesurer-temps-boot.yml` : mesure automatisée du temps de démarrage sous QEMU/KVM en CI, déclenchée à chaque publication de release ou manuellement. Télécharge l'image de la release testée, la démarre, et mesure le temps écoulé entre le boot du noyau Linux et le lancement d'AttractMode via un marqueur (`AMIPC_BOOT_MARKER`) écrit sur la console série.
- Marqueur de fin de démarrage dans `amipc-start.sh` (basé sur `/proc/uptime`, écrit sur `/dev/console` et `/dev/ttyS0`).
- Support de la console série dans le noyau (`CONFIG_SERIAL_8250`, `CONFIG_SERIAL_8250_CONSOLE`, `CONFIG_SERIAL_8250_PCI`), utile à la fois pour cette mesure automatisée et pour le diagnostic sur matériel physique réel.
- Documentation de la procédure de mesure automatisée dans `docs/TESTS.md` (section 8 du ROADMAP), avec limite explicite : cette mesure ne couvre pas le temps de firmware/GRUB2, propre à chaque machine physique.

## [0.10.19] - 2026-09-14

### 🎉 Premier succès complet de bout en bout

- **Le pipeline Buildroot complet a réussi de bout en bout pour la première fois** (`amipc.img` généré avec succès sur le tag v0.10.18) — noyau Linux, GRUB2, Mesa3D/X11, RetroArch/libretro-uae, SFML, AttractMode et image disque finale, validant l'ensemble des dix-huit corrections réelles appliquées successivement dans cette session (dépendances de compilation du noyau, sélection et configuration de SFML, boucles de dépendance Kconfig, patchs de compilation et de liaison d'AttractMode, activation minimale de X11 pour Mesa/GLX, permissions d'exécution Git, outil `genimage`, génération de la partition EFI).

### Corrigé

- Publication de la release GitHub : le build de l'image a réussi intégralement, mais la publication échouait avec `403 Resource not accessible by integration` — le paramètre `default_workflow_permissions` du dépôt était réglé sur `read`, plafonnant le `GITHUB_TOKEN` en lecture seule quelle que soit la permission déclarée dans le workflow (`permissions: contents: write` ne peut qu'élever une permission dans la limite de ce plafond, jamais au-delà).
- Ajout explicite de `permissions: contents: write` à `publier-release.yml` et changement du paramètre `default_workflow_permissions` du dépôt à `write` au niveau GitHub.

## [0.10.18] - 2026-09-14

### Corrigé

- Génération de l'image disque finale : `host-genimage` est construit avec succès (dix-septième correctif validé), AttractMode et `post-build.sh` fonctionnent intégralement (seizième correctif validé). `genimage` s'exécutait mais échouait avec `ERROR: hdimage(amipc.img): could not setup efi-part.vfat` — `genimage.cfg` référence un fichier `efi-part.vfat` que `post-image.sh` ne générait jamais.
- Buildroot construit déjà automatiquement un répertoire `output/images/efi-part/` (bootloader GRUB2 EFI prêt à l'emploi, généré grâce à `BR2_TARGET_GRUB2_X86_64_EFI`) — la même logique que celle qu'il utilise en interne pour son propre générateur d'image ISO9660 (`mkfs.vfat` + `mcopy`). `post-image.sh` construit désormais explicitement `efi-part.vfat` à partir de ce répertoire avant d'invoquer `genimage`, en réutilisant les outils hôtes `mkfs.vfat`/`mcopy` déjà fournis par Buildroot (`$HOST_DIR/sbin` et `$HOST_DIR/bin`).

## [0.10.17] - 2026-09-14

### Corrigé

- Construction de l'image finale : `post-build.sh` s'exécute désormais sans erreur de permission (validant le seizième correctif) et le rootfs cible complet est empaqueté avec succès (`rootfs.tar` généré via `fakeroot`). Le build échouait ensuite sur `target-post-image` avec `genimage: command not found` (`Error 127`) — l'outil `genimage`, utilisé par `post-image.sh` (`buildroot-external/board/amipc/post-image.sh`) pour assembler l'image disque finale à partir de `genimage.cfg`, n'était jamais construit par Buildroot ni disponible sur l'hôte de build.
- Ajout de `BR2_PACKAGE_HOST_GENIMAGE=y` au defconfig, qui compile `genimage` comme outil hôte Buildroot standard (placé automatiquement dans le `PATH` utilisé par `support/scripts/genimage.sh`).

## [0.10.16] - 2026-09-14

### Corrigé

- **Étape majeure** : le paquet Buildroot `attractmode` compile, lie (`Creating executable: attract`) et s'installe désormais intégralement (`>>> attractmode v2.6.1 Installing to target`) — validant les quinze corrections précédentes de cette session (toolchain, Kconfig, SFML, AttractMode, GCC, linker, X11, Mesa). Le build échouait ensuite sur `target-finalize` avec `post-build.sh: Permission denied` (`Error 126`).
- Cause : l'ensemble des scripts shell du dépôt (`post-build.sh`, `post-image.sh`, tous les scripts du paquet `amipc-init`, tous les scripts sous `scripts/`) étaient enregistrés dans Git en mode `100644` (non exécutable) au lieu de `100755`, malgré des `chmod +x` exécutés localement à leur création — ceux-ci ne s'étaient jamais reflétés dans l'index Git, l'environnement de développement (Windows/Git Bash) ne préservant pas toujours fidèlement les permissions Unix lors des `git add` successifs.
- Correction du mode exécutable de tous les scripts concernés directement dans l'index Git (`git update-index --chmod=+x`), sans modification de leur contenu.

## [0.10.15] - 2026-09-14

### Corrigé

- Compilation du paquet Buildroot `attractmode` : le patch `0002-link-explicitly-against-shared-glapi.patch` (v0.10.14) échouait à s'appliquer (`Hunk #1 FAILED`), car il avait été construit à partir d'une copie du Makefile récupérée sans préciser la référence exacte du tag `v2.6.1` (probablement `master`, dont la numérotation de lignes diffère). Cause racine du problème de lien également mal diagnostiquée jusqu'ici : la liaison OpenGL (`-lGL`/`GLES_LIB`) dans le vrai Makefile du tag `v2.6.1` est imbriquée dans le même bloc conditionnel que le module `gameswf` (`ifneq ($(NO_SWF),1)`) — en désactivant `NO_SWF=1` (nécessaire, `gameswf` ne compile pas avec GCC 12), toute liaison OpenGL disparaissait purement et simplement du binaire final, expliquant l'échec systématique de résolution de `glGetString` observé sur plusieurs itérations, indépendamment du choix GL/GLES ou de `libglapi`.
- Patch régénéré et testé de bout en bout (extraction du vrai tarball `v2.6.1`, application séquentielle des deux patches comme le fait Buildroot) : ajoute une branche `else` au bloc `NO_SWF` fournissant la liaison `-ldl -lGL -lglapi` (toujours nécessaire pour `shared-glapi`, cf. section précédente) lorsque SWF est désactivé, sans modifier le comportement existant lorsque SWF reste actif.

## [0.10.14] - 2026-09-14

### Corrigé

- Compilation du paquet Buildroot `attractmode` : `GL/gl.h` est désormais bien installé (Mesa/GLX fonctionnel, cf. section précédente), et toutes les unités de compilation réussissent (`Creating executable: attract`). L'édition de liens échouait toujours sur `undefined reference to glGetString`, cette fois avec `-lGL` (le même symptôme rencontré précédemment avec GLES n'était donc pas spécifique à GLES). Cause racine identifiée : Mesa3D est construit par Buildroot avec `shared-glapi` activé (option meson `-Dshared-glapi=enabled`), ce qui déplace les symboles OpenGL réels comme `glGetString` dans une bibliothèque séparée `libglapi.so`, tandis que `libGL.so` (GLX) ne contient que la table de dispatch. Le linker GNU moderne (`--as-needed` par défaut) ne résout pas systématiquement cette dépendance transitive via la seule liaison à `-lGL`.
- Ajout d'un troisième patch au paquet `attractmode` (`0002-link-explicitly-against-shared-glapi.patch`, testé localement avant intégration) : ajoute `-lglapi` immédiatement après `-lGL` dans le cas OpenGL desktop du Makefile amont, sans modifier le cas GLES (déjà distinct) ni les autres plateformes. `libglapi.so` est déjà construite et installée par Mesa dans le staging, aucune dépendance Buildroot supplémentaire n'est nécessaire.

## [0.10.13] - 2026-09-14

### Corrigé

- Compilation du paquet Buildroot `attractmode` : le retour à OpenGL desktop (v0.10.12) réintroduisait `fatal error: GL/gl.h: No such file or directory` alors que ce header avait été installé dans un build précédent. Cause racine identifiée : `BR2_PACKAGE_MESA3D_OPENGL_GLX` dépend strictement de `BR2_PACKAGE_XORG7` (jamais activé, système headless voulu) — Kconfig ignore silencieusement une option `depends on` non satisfaite même si elle est écrite `=y` dans le defconfig, donc `GL/gl.h` n'était en réalité jamais réellement construit malgré l'apparence de configuration correcte.
- Activation de `BR2_PACKAGE_XORG7=y`, qui ne construit qu'une catégorie de bibliothèques X11 de développement (aucun serveur Xorg n'est sélectionné ni lancé au runtime) — strictement nécessaire pour satisfaire la dépendance Kconfig de `MESA3D_OPENGL_GLX`, qui sélectionne alors automatiquement les libs X11 minimales requises (`libX11`, `libXext`, etc. via `MESA3D_NEEDS_X11`). Retrait de `BR2_PACKAGE_MESA3D_OPENGL_ES` du defconfig et du paquet `sfml` (Config.in), devenu inutile après l'abandon de la piste GLES.

## [0.10.12] - 2026-09-14

### Corrigé

- Compilation du paquet Buildroot `attractmode` : `GLES_LIB=-lGLESv2` n'a pas résolu l'échec de lien `undefined reference to glGetString` — la bibliothèque `libGLESv2.so` construite par Mesa 24.0.9 en compilation croisée Buildroot n'exporte apparemment pas ce symbole de façon exploitable par le lien, indépendamment du choix `-lGLESv1_CM`/`-lGLESv2`.
- Retour à OpenGL desktop classique plutôt que poursuivre l'investigation GLES : retrait de `USE_GLES=1`/`GLES_LIB=-lGLESv2` de l'invocation `make` d'`attractmode` (conservant `USE_DRM=1`, indépendant du choix GL/GLES) et de `OPENGL_ES=TRUE` du paquet `sfml` (repassé à `FALSE`). Mesa fournit déjà un `libGL.so` desktop complet et fonctionnel via GLX (confirmé par les builds précédents), qu'AttractMode et SFML utilisent désormais de façon cohérente. Le patch SFML évitant `find_package(OpenGL)` en mode DRM reste actif et nécessaire, indépendamment de ce choix.

## [0.10.11] - 2026-09-14

### Corrigé

- Compilation du paquet Buildroot `attractmode` : toutes les unités de compilation d'AttractMode compilent désormais avec succès (`Creating executable: attract`) — plus aucune erreur de compilation. L'édition de liens échouait sur `undefined reference to 'glGetString'`. Cause probable : le Makefile amont lie par défaut `-lGLESv1_CM` dès que `USE_GLES=1` (sauf cas Raspberry Pi/BCM non applicable ici), or bien que Mesa3D construise et installe cette bibliothèque, son symbole `glGetString` n'est apparemment pas exporté de façon exploitable dans ce contexte de compilation croisée Buildroot.
- Ajout de `GLES_LIB=-lGLESv2` à l'invocation `make` du paquet `attractmode`, forçant explicitement la liaison contre `libGLESv2.so` (implémentation OpenGL ES 2.0 standard de Mesa, dont l'export de `glGetString` est mieux établi) au lieu de laisser le Makefile amont choisir `-lGLESv1_CM` par défaut.

## [0.10.10] - 2026-09-14

### Corrigé

- Compilation du paquet Buildroot `attractmode` : plus aucune erreur `GL/gl.h`, `squirrel.h` ni `libavutil` (patch `SFML_OPENGL_ES` validé). Dernier échec restant sur `src/swf.cpp` : le module interne `gameswf` (support Flash SWF, embarqué en sources dans `extlibs/gameswf/`) contient du code C++ ancien incompatible avec les règles d'accès strictement appliquées par GCC 12 (`array<as_value>::array` hérité en `private` mais utilisé comme s'il était accessible). Ce module gère un usage non nécessaire à AmiPC (animations Flash dans les thèmes du frontend).
- Ajout de `NO_SWF=1` à l'invocation `make` du paquet `attractmode` (déjà actif par défaut sous FreeBSD dans le Makefile amont, mais pas sous Linux), désactivant proprement la compilation du module `gameswf` plutôt que de tenter de corriger du code tiers obsolète.

## [0.10.9] - 2026-09-14

### Corrigé

- Compilation du paquet Buildroot `attractmode` : `libavutil/log.h` n'est plus une erreur (`NO_MOVIE=1` validé), la compilation atteint désormais le vrai code source d'AttractMode. Nouvel échec sur `SFML/OpenGL.hpp:54:18: fatal error: GL/gl.h: No such file or directory` — le symétrique côté « code consommant SFML » du problème déjà corrigé côté compilation interne de SFML : ce header public de SFML inclut `GL/gl.h` (OpenGL desktop, absent sur ce système headless) sauf si la macro `SFML_OPENGL_ES` est définie au moment de la compilation du code appelant, ce qu'AttractMode ne fait jamais.
- Activation de `BR2_PACKAGE_MESA3D_OPENGL_ES` (Mesa3D) et `OPENGL_ES=TRUE` (option CMake de SFML), garantissant que Mesa fournit bien les headers/bibliothèques GLES et que SFML se compile lui-même en cohérence avec ce choix.
- Ajout d'un second patch au paquet `attractmode` (`0001-define-SFML_OPENGL_ES-when-USE_GLES-is-enabled.patch`, testé localement avant intégration) : définit `SFML_OPENGL_ES` dès que la variable `USE_GLES` du Makefile amont est active, exactement comme SFML le fait pour son propre compte. Activation de `USE_GLES=1` et `USE_DRM=1` (variables `make` simples, sans risque d'écraser `CPPFLAGS`) à l'invocation du paquet, qui pilotent également la liaison correcte à `libGLESv1_CM`/`libdrm`/`libgbm` au lieu de `libGL`.

## [0.10.8] - 2026-09-14

### Corrigé

- Compilation du paquet Buildroot `attractmode` : les boucles Kconfig sont résolues (aucune erreur au démarrage du build v0.10.7), SFML compile et s'installe intégralement, `squirrel.h` n'est plus une erreur — seul `libavutil/log.h` (FFmpeg) restait introuvable. Cause : FFmpeg n'a jamais été ajouté comme dépendance Buildroot (ni au defconfig, ni au paquet `attractmode`), or le Makefile amont d'AttractMode le requiert inconditionnellement pour la prévisualisation vidéo des jeux, fonctionnalité non nécessaire à ce stade du projet (les aperçus prévus sont des snapshots statiques, cf. section 4 du ROADMAP).
- Ajout de `NO_MOVIE=1` à l'invocation `make` du paquet `attractmode`, désactivant proprement la dépendance FFmpeg côté Makefile amont (mécanisme documenté et prévu par AttractMode lui-même) plutôt que d'ajouter FFmpeg comme dépendance Buildroot supplémentaire, ce qui aurait alourdi l'image pour une fonctionnalité non utilisée.

## [0.10.7] - 2026-09-14

### Corrigé

- Configuration Kconfig : deux boucles de dépendance récursive détectées au démarrage du build v0.10.6 (`recursive dependency detected!`), sans bloquer la compilation mais invalidant silencieusement certaines options (dont `BR2_PACKAGE_MESA3D_GBM`, retombé à `n` malgré son activation explicite, d'où la persistance de `libavutil/log.h` introuvable — FFmpeg n'était plus réellement sélectionné une fois le solveur Kconfig en échec).
  - Boucle triviale : `sfml/Config.in` combinait `depends on BR2_PACKAGE_HAS_UDEV` et `select BR2_PACKAGE_EUDEV`, ce dernier sélectionnant lui-même `HAS_UDEV` en interne — un cycle direct. Le `depends on` redondant est retiré, `select EUDEV` suffit à garantir la présence d'udev.
  - Boucle plus large impliquant des paquets tiers Buildroot : `attractmode → (depends on) sdl2 ← (selected by) ffmpeg_ffplay ← ffmpeg ← kodi ← (depends on) has_libegl ← libglvnd ← mesa3d_opengl_egl ← mesa3d_gallium_driver_v3d ← mesa3d ← (selected by) sfml`. Remplacement de `depends on BR2_PACKAGE_SDL2` par `select BR2_PACKAGE_SDL2` dans `attractmode/Config.in`, qui reste fonctionnellement équivalent (SDL2 est de toute façon requis) sans refermer la boucle avec la chaîne Kodi/FFmpeg/EGL propre à l'arbre Kconfig standard de Buildroot.

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
