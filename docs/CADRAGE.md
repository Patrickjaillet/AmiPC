# Cadrage du Projet — AmiPC

Ce document fixe le périmètre technique et fonctionnel d'AmiPC avant le début de l'implémentation. Il correspond à la section « 1. Analyse et Cadrage du Projet » du fichier [ROADMAP.md](../ROADMAP.md).

---

## 1. Périmètre Matériel Cible

- Architecture : x86_64 PC générique (compatible BIOS legacy et UEFI).
- Support de sortie : image disque unique, hybride ISO/IMG, bootable par clé USB ou gravure optique.
- Aucune dépendance à un matériel propriétaire (pas de carte spécifique requise).

### Prérequis matériels minimaux

| Composant | Minimum       | Recommandé      |
|-----------|---------------|-----------------|
| CPU       | x86_64 1 GHz  | x86_64 dual-core 1,6 GHz+ |
| RAM       | 512 Mo        | 1 Go ou plus    |
| GPU       | VESA/VGA compatible KMS | GPU avec support Mesa/DRM |
| Stockage  | 1 Go (image système) | 4 Go+ (avec bibliothèque de jeux étendue) |
| Entrée    | Clavier USB   | Clavier + manette USB/Bluetooth |
| Audio     | Contrôleur AC97/HDA compatible ALSA | idem |

---

## 2. Distribution de Base du Système Embarqué

- **Outil retenu : Buildroot.**
- Justification : image minimale, temps de build court, empreinte disque réduite (quelques dizaines de Mo hors BIOS/ROMs), suffisant pour un système mono-usage (frontend + émulateur), contrairement à Yocto plus adapté à des besoins multi-produits/multi-couches.
- Le choix est documenté ici pour éviter toute ambiguïté lors de l'implémentation de la section 2 du ROADMAP.

---

## 3. Inventaire des BIOS / Kickstart (`bios/amiga/`)

État constaté au démarrage du projet : 24 fichiers présents, aucune vérification d'intégrité en place.

| Fichier                        | Machine cible      | Rôle                          |
|---------------------------------|--------------------|-------------------------------|
| kick33180.A500                  | Amiga 500          | Kickstart 1.2                 |
| kick34005.A500                  | Amiga 500          | Kickstart 1.3                 |
| kick34005.CDTV                  | CDTV               | Kickstart 1.3 (CDTV)          |
| amiga-os-120.rom                | Amiga 500 (générique) | Kickstart 1.2 (alias)      |
| amiga-os-130.rom                | Amiga 500 (générique) | Kickstart 1.3 (alias)      |
| amiga-ext-130-cdtv.rom          | CDTV               | Extension Kickstart 1.3 CDTV  |
| kick37175.A500                  | Amiga 500+         | Kickstart 2.04                |
| amiga-os-204.rom                | Amiga 500+/2000    | Kickstart 2.04 (alias)        |
| amiga-os-205.rom                | Amiga 600/3000     | Kickstart 2.05 (alias)        |
| kick37350.A600                  | Amiga 600          | Kickstart 2.05                |
| kick40063.A600                  | Amiga 600          | Kickstart 3.1                 |
| amiga-os-310-a600.rom           | Amiga 600          | Kickstart 3.1 (alias)         |
| kick39106.A1200                 | Amiga 1200         | Kickstart 3.0                 |
| amiga-os-300-a1200.rom          | Amiga 1200         | Kickstart 3.0 (alias)         |
| kick40068.A1200                 | Amiga 1200         | Kickstart 3.1                 |
| amiga-os-310-a1200.rom          | Amiga 1200         | Kickstart 3.1 (alias)         |
| amiga-os-310-a3000.rom          | Amiga 3000         | Kickstart 3.1                 |
| amiga-os-310-a4000.rom          | Amiga 4000         | Kickstart 3.1                 |
| kick40068.A4000                 | Amiga 4000         | Kickstart 3.1                 |
| amiga-os-310.rom                | Générique          | Kickstart 3.1 (référence commune) |
| kick40060.CD32                  | CD32               | Kickstart 3.1 (CD32)          |
| kick40060.CD32.ext              | CD32               | Extension Kickstart CD32      |
| amiga-os-310-cd32.rom           | CD32               | Kickstart 3.1 (alias)         |
| amiga-ext-310-cd32.rom          | CD32               | Extension Kickstart 3.1 CD32  |
| aros-rom.bin                    | Générique (libre)  | AROS ROM (alternative libre)  |
| aros-ext.bin                    | Générique (libre)  | Extension AROS                |

**Machines prioritaires du projet** (conformément au titre du dépôt) :
- **Amiga 500** → `kick34005.A500` (Kickstart 1.3, standard) ou `kick37175.A500` (Kickstart 2.04, meilleure compatibilité logicielle).
- **Amiga 1200** → `kick40068.A1200` (Kickstart 3.1, standard).

---

## 4. Inventaire de la Ludothèque (`roms/amiga500/`)

- 141 fichiers `.zip` recensés.
- Aucun sous-répertoire `amiga1200/` pour le moment (à créer, cf. section 7 du ROADMAP).
- Volume total : environ 187 Mo.
- Aucune vérification de somme de contrôle en place à ce stade.

---

## 5. Cahier des Charges Fonctionnel

Flux utilisateur cible :

1. Mise sous tension → démarrage du système Linux embarqué (sans shell visible).
2. Lancement automatique du frontend AttractMode.
3. Navigation dans la liste des jeux (Amiga 500 puis, à terme, Amiga 1200).
4. Sélection d'un jeu → lancement de l'émulateur PUAE (libretro-uae) avec le profil machine/Kickstart adapté.
5. Fin de session de jeu (combinaison clavier/manette dédiée) → retour automatique au frontend AttractMode.
6. Accès à un menu de configuration (langue, affichage, entrées) et à un onglet « À propos » depuis le frontend.

---

## 6. Dépendances Logicielles Tierces

| Composant       | Rôle                                   | Dépôt / Origine                                  |
|-----------------|-----------------------------------------|---------------------------------------------------|
| Buildroot       | Génération du système Linux embarqué    | https://buildroot.org                              |
| PUAE / libretro-uae | Cœur d'émulation Amiga (via RetroArch) | https://github.com/libretro/libretro-uae          |
| RetroArch       | Frontend d'exécution du core libretro   | https://github.com/libretro/RetroArch             |
| AttractMode     | Frontend de sélection des jeux          | https://github.com/mickelson/attract               |
| SDL2            | Rendu vidéo/audio/entrées bas niveau    | https://www.libsdl.org                             |

Décision d'architecture : RetroArch est utilisé comme conteneur d'exécution du core `libretro-uae`, lancé directement par AttractMode via son système d'émulateurs externes, sans interface RetroArch visible pour l'utilisateur final.

---

## Statut

Cadrage initial réalisé. Prochaine étape : section 2 du ROADMAP (« Système Linux Embarqué Minimal »), démarrage de la configuration Buildroot.
