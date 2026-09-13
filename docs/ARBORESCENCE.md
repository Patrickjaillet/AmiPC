# Arborescence du Projet — AmiPC

Ce document décrit l'organisation complète du dépôt, en complément de la section « 9. Documentation » du [ROADMAP.md](../ROADMAP.md).

```
AmiEmul/
├── ROADMAP.md                    Feuille de route du projet (norme SemVer, suivi par cases à cocher)
├── CHANGELOG.md                  Journal des modifications (Keep a Changelog + SemVer)
├── COMPILATION.md                Procédure complète de compilation depuis les sources
├── README.md                     Présentation, installation et utilisation du logiciel
├── VERSION                       Numéro de version courant (source unique de vérité SemVer)
├── .gitignore                    Exclusion des BIOS, ROMs et artefacts de build
│
├── bios/
│   └── amiga/                    Fichiers BIOS/Kickstart Amiga (non versionnés, fournis par l'utilisateur)
│
├── roms/
│   ├── amiga500/                 Jeux Amiga 500 (non versionnés, fournis par l'utilisateur)
│   └── amiga1200/                Jeux Amiga 1200 (non versionnés, fournis par l'utilisateur)
│
├── buildroot-external/           Arborescence externe Buildroot (BR2_EXTERNAL)
│   ├── external.desc             Déclaration de l'arborescence externe
│   ├── external.mk               Point d'entrée Makefile des paquets locaux
│   ├── Config.in                 Point d'entrée Kconfig des paquets locaux
│   ├── configs/
│   │   └── amipc_x86_64_defconfig    Configuration Buildroot principale
│   ├── board/amipc/
│   │   ├── linux-amipc.fragment      Fragment de configuration noyau
│   │   ├── post-build.sh             Script post-build (autologin, démarrage AttractMode)
│   │   ├── post-image.sh             Script post-image (génération de l'image finale)
│   │   ├── genimage.cfg              Description des partitions de l'image (EFI + rootfs)
│   │   └── overlay/                  Fichiers copiés directement dans le rootfs (udev, etc.)
│   └── package/
│       ├── amipc-init/                Paquet du superviseur de démarrage et scripts système AmiPC
│       │   └── files/                 Scripts shell embarqués sur la cible
│       └── attractmode/               Paquet de compilation d'AttractMode depuis les sources
│
├── config/
│   ├── retroarch/                 Configuration RetroArch et profils du core PUAE
│   │   ├── retroarch.cfg              Configuration générale (mode kiosque)
│   │   ├── config/PUAE/                Profils machine (.opt) et mappage manette (.rmp)
│   │   ├── shaders/amipc/              Préréglages de rendu vidéo
│   │   └── system/amiga/               Arborescence BIOS standard (générée par installer_bios.sh)
│   └── attract/                   Configuration du frontend AttractMode
│       ├── attract.cfg                Configuration générale, displays, filtres, plugins
│       ├── emulators/                 Définitions d'émulateurs (amiga500.cfg, amiga1200.cfg)
│       ├── romlists/                  Listes de jeux générées (amiga500.txt, amiga1200.txt)
│       ├── artwork/                   Illustrations (jaquettes, snapshots, bandeaux)
│       └── plugins/                   Plugins Squirrel (à propos, paramètres, alerte BIOS)
│
├── themes/
│   └── amipc/                     Thème visuel du frontend (layout.nut, layout.txt)
│
├── i18n/
│   ├── fr.json                    Traductions françaises
│   ├── en.json                    Traductions anglaises
│   └── credits.json               Composants tiers et licences
│
├── scripts/                       Scripts d'automatisation exécutables depuis la racine du dépôt
│   ├── construire_image.sh            Orchestration complète du build Buildroot
│   ├── installer_bios.sh              Mapping des BIOS vers l'arborescence système
│   ├── generer_romlist.sh             Génération d'un romlist AttractMode
│   └── verifier_roms.sh               Génération des sommes de contrôle SHA-256
│
├── build/                          Répertoire de travail Buildroot (généré, non versionné)
│
└── docs/                           Documentation technique complémentaire
    ├── CADRAGE.md                     Cadrage initial du projet (section 1 du ROADMAP)
    ├── PUAE.md                        Intégration PUAE/libretro-uae (section 3)
    ├── ATTRACTMODE.md                 Intégration AttractMode (section 4)
    ├── A_PROPOS.md                    Écran « À propos » (section 5)
    ├── I18N.md                        Internationalisation (section 6)
    ├── GESTION_ROMS_BIOS.md           Gestion des ROMs et BIOS (section 7)
    ├── TESTS.md                       Protocoles de test (section 8)
    ├── ARBORESCENCE.md                Le présent document (section 9)
    ├── INSTALLATION.md                Guide d'installation utilisateur (section 9)
    ├── DEPANNAGE.md                   Guide de dépannage / FAQ (section 9)
    └── roms-amiga500.sha256           Sommes de contrôle générées (non versionné)
```

---

## Statut

Arborescence documentée et à jour. Ce document doit être mis à jour à chaque ajout ou déplacement de répertoire significatif, conformément aux conventions strictes du projet.
