# AmiPC

Distribution Linux embarquée minimale dédiée à l'émulation Amiga 500 et Amiga 1200, combinant **PUAE** (via le core **libretro-uae**) et le frontend **AttractMode** pour une expérience de type borne d'arcade, prête à l'emploi dès le démarrage.

---

## Capture d'Écran

> Capture d'écran à intégrer après la première compilation et le premier démarrage réel de l'image (cf. [docs/TESTS.md](docs/TESTS.md)). Aucune image n'a encore été produite à ce stade de la préparation du projet.

---

## Fonctionnalités

- Démarrage direct sur l'interface AttractMode, sans shell visible.
- Émulation Amiga 500 (Kickstart 1.3, chipset OCS/ECS) et Amiga 1200 (Kickstart 3.1, chipset AGA) via PUAE/libretro-uae.
- Prise en charge des formats de jeux ADF, IPF, ZIP, DMS et HDF.
- Frontend graphique avec navigation manette/clavier, filtres, favoris et prévisualisations.
- Interface entièrement disponible en français et en anglais.
- Écran « À propos » avec informations de version, copyright et crédits des composants tiers.
- Vérification automatique de l'intégrité des BIOS au démarrage, avec avertissement visible en cas d'anomalie.
- Montage automatique de clés USB pour l'ajout de jeux et de BIOS.
- Mécanisme de mise à jour intégré de l'image système.

## Installation

Voir le [Guide d'Installation](docs/INSTALLATION.md) pour la procédure complète d'écriture de l'image sur clé USB et de premier démarrage.

## Compilation depuis les Sources

Voir [COMPILATION.md](COMPILATION.md) pour la procédure complète de compilation (Buildroot, sous Linux natif, WSL2 ou conteneur).

## Utilisation

1. Démarrer la machine sur la clé USB AmiPC.
2. Naviguer dans la ludothèque avec la manette ou le clavier.
3. Valider pour lancer un jeu ; PUAE prend le relais en plein écran.
4. Utiliser la combinaison **F12 + Échap** pour revenir au frontend.
5. Accéder à l'écran « À propos » avec la touche **F1**.
6. Accéder au menu de configuration (langue, luminosité, réseau, filtre vidéo) depuis le menu principal d'AttractMode.

## Contenu Utilisateur

AmiPC ne fournit **aucun BIOS ni aucune ROM commerciale**. Les fichiers BIOS/Kickstart et les jeux doivent être fournis par l'utilisateur, conformément à la législation applicable aux droits d'auteur, et placés respectivement dans `bios/amiga/` et `roms/amiga500/` (ou `roms/amiga1200/`). Voir [docs/GESTION_ROMS_BIOS.md](docs/GESTION_ROMS_BIOS.md) pour la procédure détaillée.

## Documentation

| Document | Contenu |
|----------|---------|
| [CHANGELOG.md](CHANGELOG.md) | Journal des modifications (SemVer) |
| [COMPILATION.md](COMPILATION.md) | Procédure de compilation |
| [docs/CADRAGE.md](docs/CADRAGE.md) | Cadrage technique et fonctionnel |
| [docs/PUAE.md](docs/PUAE.md) | Intégration du moteur d'émulation |
| [docs/ATTRACTMODE.md](docs/ATTRACTMODE.md) | Intégration du frontend |
| [docs/A_PROPOS.md](docs/A_PROPOS.md) | Écran « À propos » |
| [docs/I18N.md](docs/I18N.md) | Internationalisation |
| [docs/GESTION_ROMS_BIOS.md](docs/GESTION_ROMS_BIOS.md) | Gestion des ROMs et BIOS |
| [docs/TESTS.md](docs/TESTS.md) | Protocoles de test |
| [docs/ARBORESCENCE.md](docs/ARBORESCENCE.md) | Arborescence complète du projet |
| [docs/INSTALLATION.md](docs/INSTALLATION.md) | Guide d'installation utilisateur |
| [docs/DEPANNAGE.md](docs/DEPANNAGE.md) | Guide de dépannage / FAQ |

## Licence et Copyright

**AmiPC**
Copyright © 2026 Patrick JAILLET — Tous droits réservés
E-mail : sandefjord.development@proton.me
Site web : https://patrickjaillet.github.io/AmiPC

Les informations de copyright, contact et site web sont également accessibles depuis le logiciel via l'écran « À propos » (touche F1).
