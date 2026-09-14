# Compilation — AmiPC

Ce document décrit la procédure complète de compilation de l'image AmiPC depuis les sources.

---

## Prérequis

La compilation repose sur **Buildroot** et doit obligatoirement s'exécuter sous **Linux** (natif, WSL2, ou conteneur Docker/Podman Linux). Buildroot ne fonctionne pas sous Windows natif.

### Système hôte requis

- Distribution Linux x86_64 (Debian/Ubuntu recommandé).
- Espace disque : 15 Go minimum libres (sources + build + ccache).
- RAM : 4 Go minimum, 8 Go recommandés.
- Paquets système nécessaires :

```sh
sudo apt-get update
sudo apt-get install -y build-essential git curl unzip rsync bc \
    libncurses-dev python3 cpio file wget libelf-dev flex bison \
    libssl-dev
```

---

## Arborescence du projet

```
AmiEmul/
├── bios/amiga/              Fichiers BIOS/Kickstart (non versionnés dans Git)
├── roms/amiga500/           Jeux Amiga 500 (non versionnés dans Git)
├── buildroot-external/      Arborescence externe Buildroot (BR2_EXTERNAL)
│   ├── configs/             Defconfig(s) AmiPC
│   ├── board/amipc/         Overlay rootfs, scripts post-build/post-image, fragment noyau
│   └── package/amipc-init/  Paquet Buildroot du superviseur de démarrage AmiPC
├── scripts/                 Scripts d'automatisation (build, vérification ROMs)
├── docs/                    Documentation technique complémentaire
└── build/                   Répertoire de travail Buildroot (généré, non versionné)
```

---

## Compilation automatisée

Un script unique orchestre le téléchargement de Buildroot et la compilation complète :

```sh
sh scripts/construire_image.sh
```

Ce script :

1. Vérifie que l'hôte est bien Linux.
2. Télécharge et extrait Buildroot (version figée, voir en-tête du script) dans `build/`.
3. Applique la configuration `amipc_x86_64_defconfig` via `BR2_EXTERNAL=buildroot-external`.
4. Lance la compilation complète (`make -j$(nproc)`).

L'image finale est générée dans :

```
build/buildroot-<version>/output/images/
```

---

## Accélération des Compilations Répétées (ccache)

Le defconfig active `BR2_CCACHE`, qui compile et utilise automatiquement `ccache` (stocké par défaut dans `$HOME/.buildroot-ccache`) pour éviter de recompiler des fichiers sources inchangés d'une exécution à l'autre. Le gain n'apparaît qu'à partir du **deuxième** build (le premier doit construire `host-ccache` lui-même avant de pouvoir s'en servir).

En intégration continue (GitHub Actions), ce répertoire est automatiquement mis en cache entre les exécutions (`.github/workflows/build-image.yml` et `publier-release.yml`), tout comme le répertoire des sources téléchargées (`build/buildroot-*/dl`), qui ne change que si la version de Buildroot ou la liste des paquets évolue.

En local, pour purger le cache après un changement de version de compilateur ou de configuration incompatible :

```sh
rm -rf "$HOME/.buildroot-ccache"
```

---

## Compilation manuelle (pas à pas)

```sh
git clone https://github.com/buildroot/buildroot.git build/buildroot
cd build/buildroot

make BR2_EXTERNAL=../../buildroot-external amipc_x86_64_defconfig
make BR2_EXTERNAL=../../buildroot-external menuconfig   # optionnel : ajuster la configuration
make BR2_EXTERNAL=../../buildroot-external -j$(nproc)
```

---

## Intégration des BIOS et des jeux

Les fichiers de `bios/amiga/` et `roms/amiga500/` ne sont pas compilés dans l'image : ils sont copiés séparément sur la partition de données au moment du déploiement, conformément à la section 7 du [ROADMAP.md](ROADMAP.md) (procédure détaillée à venir).

Avant toute compilation, vérifier l'intégrité de la ludothèque :

```sh
sh scripts/verifier_roms.sh
```

---

## Déploiement de l'image

```sh
sudo dd if=build/buildroot-<version>/output/images/amipc.img of=/dev/sdX bs=4M status=progress conv=fsync
```

Remplacer `/dev/sdX` par le périphérique cible (clé USB). **Vérifier impérativement le périphérique avant exécution : cette commande est destructive.**

---

## Nettoyage

```sh
rm -rf build/buildroot-*/output
```

Pour repartir d'un environnement totalement propre :

```sh
rm -rf build/
```
