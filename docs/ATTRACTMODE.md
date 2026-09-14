# Intégration AttractMode — AmiPC

Ce document détaille la configuration du frontend AttractMode, en complément de la section « 4. Intégration d'AttractMode » du [ROADMAP.md](../ROADMAP.md).

---

## 1. Compilation

AttractMode est intégré comme paquet Buildroot local : [buildroot-external/package/attractmode/](../buildroot-external/package/attractmode/). Il est activé par `BR2_PACKAGE_ATTRACTMODE=y` dans le defconfig et compilé au sein du même flux que le reste du système (cf. [COMPILATION.md](../COMPILATION.md)). Aucune compilation manuelle séparée n'est nécessaire.

## 2. Configuration des Émulateurs

Deux émulateurs sont définis dans `config/attract/emulators/` :

- `amiga500.cfg` : lance RetroArch avec le core `puae_libretro.so` et le profil `amiga500.opt`.
- `amiga1200.cfg` : lance RetroArch avec le core `puae_libretro.so` et le profil `amiga1200.opt`.

Chaque définition précise le chemin des ROMs (`rompath`), les extensions prises en charge, la touche de sortie (`exit_hotkey`, `F12+Escape`) et les répertoires d'illustrations associés.

## 3. Génération du Romlist

Le romlist Amiga 500 est généré automatiquement à partir du contenu réel de `roms/amiga500/` via :

```sh
sh scripts/generer_romlist.sh
```

Résultat : `config/attract/romlists/amiga500.txt`, au format standard AttractMode (`#Name;Title;Emulator;...`), avec extraction automatique du titre et de l'année depuis le nom de fichier. 206 jeux générés lors de la dernière exécution.

Le romlist Amiga 1200 (`config/attract/romlists/amiga1200.txt`) est généré de la même façon à partir de `roms/amiga1200/` via :

```sh
sh scripts/generer_romlist.sh amiga1200
```

Les jeux Amiga 1200 suivent la convention de nommage No-Intro (`Titre (Région) (Tags)`, sans année) : le script détecte l'absence d'année et retire alors les groupes entre parenthèses/crochets pour ne conserver que le titre. 89 jeux (AGA) générés lors de la dernière exécution.

## 4. Scraping et Métadonnées

Les répertoires d'illustrations sont préparés dans `config/attract/artwork/<systeme>/{flyer,marquee,snap,wheel}/`. Le scraping effectif (téléchargement des jaquettes, snapshots, descriptions et genres depuis TheGamesDB, configuré via `info_source thegamesdb` dans les fichiers émulateur) doit être lancé depuis l'utilitaire de scraping intégré à AttractMode (menu d'affichage → *Generate/Scrape*), exécuté sur la machine cible après compilation — nécessite un accès réseau et n'est pas automatisable depuis cet environnement de préparation.

Procédure sur la machine cible :

1. Activer le Wi-Fi depuis le menu Paramètres AmiPC (option **Réseau Wi-Fi**), ou brancher une connexion filaire.
2. Ouvrir le menu d'affichage AttractMode (touche `Tab`) pour le display concerné (Amiga 500 ou Amiga 1200).
3. Sélectionner **Generate/Scrape** puis choisir les catégories à récupérer (jaquettes, snapshots, descriptions, genres) — AttractMode interroge automatiquement TheGamesDB via `info_source thegamesdb`.
4. Les fichiers récupérés sont déposés dans les répertoires `artwork/` déjà déclarés ; aucune configuration supplémentaire n'est nécessaire.

Un script de contrôle réseau (`amipc-verifier-reseau`, paquet `amipc-init`) s'exécute automatiquement au chargement du plugin de paramètres et consigne l'état de connectivité (test de résolution/ping vers `thegamesdb.net`) dans `/data/attract/dernier-controle-reseau.log`, afin de diagnostiquer rapidement un scraping resté vide faute de réseau. Il peut aussi être lancé manuellement :

```sh
amipc-verifier-reseau
```

Ce contrôle est activable/désactivable via l'option **Vérifier le réseau avant scraping** du menu Paramètres.

## 5. Thème Visuel

Le thème `amipc` (`themes/amipc/`) définit une interface sobre en résolution 1920x1080 :

- Fond sombre (bleu nuit `#0A0E17`), accent cyan (`#00A8E8`).
- Liste des jeux (wheel) à gauche, aperçu (snapshot, jaquette, bandeau) à droite.
- Titre du jeu en évidence, année/éditeur et filtre actif en pied de page.

Fichiers : [themes/amipc/layout.nut](../themes/amipc/layout.nut) (logique d'affichage Squirrel) et [themes/amipc/layout.txt](../themes/amipc/layout.txt) (descripteur).

## 6. Navigation et Filtres

La navigation manette/clavier est définie dans `config/attract/attract.cfg` (section `input_map`) : croix directionnelle, validation, retour, bascule entre displays (Amiga 500 / Amiga 1200).

Cinq filtres sont configurés sur le display Amiga 500 : Tous, A-E, F-M, N-S, T-Z (par première lettre du titre) et Favoris (basé sur le champ `Favourite` du romlist).

## 7. Bascule Frontend ↔ Émulateur

Gérée nativement par AttractMode/RetroArch sans script supplémentaire :

1. Sélection d'un jeu → AttractMode suspend son affichage et lance l'émulateur défini (`executable` + `args` du fichier `.cfg`).
2. Sortie de RetroArch (combinaison `F12+Escape`, ou fermeture du core) → AttractMode reprend automatiquement la main.
3. `min_run_time` (2 secondes) évite un retour instantané en cas d'erreur de lancement.

## 8. Menu de Configuration

Un plugin AttractMode (`config/attract/plugins/amipc_settings/plugin.nut`) expose un panneau de configuration dans le menu natif du frontend (accessible par la combinaison de menu AttractMode) :

- **Langue** (Français / English) → applique `amipc-set-langue`.
- **Luminosité** (50 à 100 %) → applique `amipc-set-luminosite` (pilotage `/sys/class/backlight`).
- **Réseau Wi-Fi** (Oui / Non) → applique `amipc-set-reseau` (`ifup`/`ifdown wlan0`).
- **Filtre vidéo** (Pixel Perfect / Scanlines) → applique `amipc-set-shader`, qui modifie `video_shader` dans `retroarch.cfg`.
- **Vérifier le réseau avant scraping** (Oui / Non) → exécute `amipc-verifier-reseau` au démarrage du plugin et journalise le résultat.

Les scripts `amipc-set-*` et `amipc-verifier-reseau` sont installés par le paquet Buildroot `amipc-init` dans `/usr/bin/`.

---

## Statut

Configuration complète et prête à l'emploi. Compilation réelle du binaire AttractMode, scraping des métadonnées en ligne et validation de la navigation manette à réaliser sur machine Linux cible (cf. [COMPILATION.md](../COMPILATION.md)).
