# Intégration PUAE (libretro-uae) — AmiPC

Ce document détaille la configuration du core d'émulation Amiga, en complément de la section « 3. Intégration de PUAE (libretro-uae) » du [ROADMAP.md](../ROADMAP.md).

---

## 1. Compilation du Core

Le core `libretro-uae` est compilé au sein du build Buildroot via le paquet `BR2_PACKAGE_LIBRETRO_UAE` défini dans [buildroot-external/configs/amipc_x86_64_defconfig](../buildroot-external/configs/amipc_x86_64_defconfig). Aucune compilation manuelle séparée n'est nécessaire : elle est intégrée au flux décrit dans [COMPILATION.md](../COMPILATION.md).

## 2. RetroArch en Mode Minimal

RetroArch est utilisé comme conteneur d'exécution du core, sans interface visible pour l'utilisateur :

- Menu RGUI conservé uniquement en secours (accès diagnostique), jamais affiché par défaut.
- Démarrage direct en plein écran (`video_fullscreen = true`), sans écran de démarrage RetroArch (`rgui_show_start_screen = false`).
- Configuration complète : [config/retroarch/retroarch.cfg](../config/retroarch/retroarch.cfg).

AttractMode lance RetroArch avec le core et le contenu en argument ; RetroArch se ferme et rend la main à AttractMode en fin de session (combinaison manette/clavier de sortie configurée dans `input_menu_toggle_gamepad_combo` et `input_exit_emulator`).

## 3. Arborescence BIOS Standard

L'arborescence système attendue par libretro-uae est générée dans `config/retroarch/system/amiga/` à partir des fichiers sources de `bios/amiga/`, via le script [scripts/installer_bios.sh](../scripts/installer_bios.sh) :

```sh
sh scripts/installer_bios.sh
```

Cette arborescence est ensuite copiée sur la partition de données de l'image finale (`/data/retroarch/system/amiga/`) par le paquet Buildroot `amipc-init`.

## 4. Profils Machine par Défaut

Trois profils de core options (`.opt`) sont définis dans `config/retroarch/config/PUAE/` :

| Profil                | Fichier               | Machine     | Kickstart          | Chipset  | Mémoire                     |
|-----------------------|------------------------|-------------|---------------------|----------|------------------------------|
| Amiga 500             | `amiga500.opt`         | A500        | 1.3 (`kick34005.A500`) | OCS/ECS | 1 Mo Chip + 512 Ko Bogo      |
| Amiga 1200            | `amiga1200.opt`        | A1200       | 3.1 (`kick40068.A1200`) | AGA     | 2 Mo Chip + 8 Mo Fast (68020)|
| CD32 (bonus)          | `cd32.opt`             | CD32        | 3.1 (`kick40060.CD32`)  | AGA     | 2 Mo Chip                    |

Le profil actif est sélectionné par AttractMode selon la plateforme du jeu lancé (cf. section 4 du ROADMAP).

## 5. Formats de Jeux Pris en Charge

Le core `libretro-uae` gère nativement les formats suivants, tous compatibles avec le contenu de `roms/amiga500/` :

- **ADF** (Amiga Disk File) — image disquette brute, format de référence.
- **IPF** (Interchangeable Preservation Format) — préservation copie-protégée, nécessite `capsimg`.
- **ZIP** — archive contenant un ou plusieurs ADF (format actuellement utilisé pour les 141 jeux du dépôt).
- **DMS** (DiskMasher) — format de compression historique, décompressé à la volée par le core.
- **HDF** (Hard Disk File) — image de disque dur, utilisée notamment pour les installations WHDLoad.

Aucune conversion préalable n'est requise : le core détecte le format à l'ouverture du fichier.

## 6. Persistance des Sauvegardes

- **Sauvegardes de jeu** : `savefile_directory = /data/retroarch/saves` (persistant sur la partition de données, hors image système).
- **Savestates** : `savestate_directory = /data/retroarch/states`.
- **NVRAM Amiga** (batterie CMOS virtuelle, utilisée par certains jeux/OS) : gérée automatiquement par le core dans le répertoire système, un fichier `.nvr` par configuration machine.
- **WHDLoad** : pris en charge nativement par le core via `puae_use_whdload = auto` ; les fichiers de sauvegarde WHDLoad sont stockés au sein du HDF ou du répertoire de contenu selon le jeu.

## 7. Mappage Manette / Clavier

Le joystick Amiga standard (1 bouton) et le pad CD32 (2 boutons principaux + boutons additionnels) sont mappés par défaut dans [config/retroarch/config/PUAE/amipc_joystick_amiga.rmp](../config/retroarch/config/PUAE/amipc_joystick_amiga.rmp) :

- Croix directionnelle → directions du joystick.
- Bouton B (manette) / Espace (clavier) → bouton de tir principal.
- Bouton A (manette) / Ctrl gauche (clavier) → second bouton (CD32 / jeux compatibles 2 boutons).
- Start/Select → menu en jeu et retour au frontend.

## 8. Rendu Vidéo

Deux préréglages de shader sont fournis dans `config/retroarch/shaders/amipc/` :

- `pixel-perfect.glslp` : rendu net sans filtrage, fidèle au signal d'origine (profil par défaut).
- `scanlines.glslp` : simulation CRT avec balayage, activable en option depuis le menu de configuration AmiPC.

## 9. Audio (Puce Paula)

L'émulation audio Paula est gérée nativement par le core `libretro-uae`. Paramètres de latence définis dans `retroarch.cfg` (`audio_latency = 64`), à ajuster lors des tests réels sur machine cible (dépend du contrôleur audio et du driver ALSA du matériel hôte). Validation fonctionnelle à réaliser lors des tests de la section 8 du ROADMAP (nécessite exécution sur matériel/VM réels).

## 10. Configuration par Jeu (Overrides)

RetroArch charge automatiquement un fichier d'options de core (`.opt`) nommé d'après le contenu lancé, s'il existe dans `config/retroarch/config/PUAE/`, en complément des profils par défaut (section 4). Cela permet d'ajuster la mémoire, le chipset ou la vitesse disquette pour un jeu spécifique sans modifier le profil global.

Convention de nommage : le fichier doit porter exactement le même nom que le fichier de contenu (hors extension), par exemple `Agony (1992)(Psygnosis).opt` pour `Agony (1992)(Psygnosis).zip`. Un exemple est fourni dans le dépôt pour ce jeu (mémoire Chip réduite à 1 Mo, sans Fast RAM, chipset OCS/ECS).

---

## Statut

Configuration complète et prête à l'emploi. Compilation du core, génération de l'image et validation audio/vidéo réelle à réaliser sur une machine Linux (cf. [COMPILATION.md](../COMPILATION.md)), ces opérations n'étant pas exécutables depuis l'environnement de préparation Windows.
