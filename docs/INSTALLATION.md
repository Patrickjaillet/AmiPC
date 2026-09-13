# Guide d'Installation — AmiPC

Ce guide s'adresse à l'utilisateur final souhaitant installer AmiPC sur une clé USB ou un support de démarrage, à partir d'une image déjà compilée (fichier `amipc.img`). Pour compiler l'image depuis les sources, voir [COMPILATION.md](../COMPILATION.md).

---

## 1. Matériel Nécessaire

- Une clé USB de 2 Go minimum (le contenu de la clé sera intégralement effacé).
- Un PC x86_64 compatible BIOS ou UEFI (cf. prérequis matériels dans [docs/CADRAGE.md](CADRAGE.md)).
- Optionnel : vos propres fichiers BIOS/Kickstart Amiga et vos jeux, si vous souhaitez enrichir la ludothèque fournie (cf. [docs/GESTION_ROMS_BIOS.md](GESTION_ROMS_BIOS.md)).

---

## 2. Écriture de l'Image sur la Clé USB

### Sous Linux / macOS

1. Identifier le périphérique de la clé USB :
   ```sh
   lsblk
   ```
2. Démonter la clé si elle est montée automatiquement :
   ```sh
   sudo umount /dev/sdX*
   ```
3. Écrire l'image (remplacer `/dev/sdX` par le périphérique identifié à l'étape 1) :
   ```sh
   sudo dd if=amipc.img of=/dev/sdX bs=4M status=progress conv=fsync
   ```

**Attention** : vérifier impérativement le nom du périphérique avant exécution. Une erreur de cible efface le disque indiqué de façon irréversible.

### Sous Windows

Utiliser un outil dédié à l'écriture d'images disque brutes (par exemple Rufus ou balenaEtcher) :

1. Lancer l'outil, sélectionner le fichier `amipc.img`.
2. Sélectionner la clé USB cible.
3. Lancer l'écriture en mode « image DD » (pas en mode ISO).

---

## 3. Ajout de Contenu Personnel (Optionnel)

Avant le premier démarrage, ou après via le montage automatique USB (cf. section 2 du ROADMAP), vous pouvez ajouter vos propres BIOS et jeux :

1. Créer sur une clé USB séparée (ou sur une seconde partition) l'arborescence suivante :
   ```
   amipc/
   ├── bios/    (vos fichiers Kickstart)
   └── roms/    (vos jeux Amiga)
   ```
2. Insérer cette clé sur la machine AmiPC : le contenu est automatiquement copié vers les répertoires de données internes (cf. `amipc-usb-mount.sh`, section 2 du ROADMAP).

---

## 4. Premier Démarrage

1. Insérer la clé USB AmiPC dans la machine cible.
2. Démarrer ou redémarrer la machine, en accédant si nécessaire au menu de boot (touche variable selon le fabricant : F12, F11, Échap, Suppr...).
3. Sélectionner la clé USB comme périphérique de démarrage.
4. Le système démarre directement sur l'interface AttractMode, sans étape de configuration manuelle requise.

La langue de l'interface est détectée automatiquement à partir de la configuration régionale du système au premier démarrage (cf. [docs/I18N.md](I18N.md)), et peut être modifiée à tout moment depuis le menu de configuration.

---

## 5. Mise à Jour

Pour mettre à jour une installation existante avec une nouvelle image, utiliser l'utilitaire embarqué (accessible en ligne de commande sur la machine cible) :

```sh
amipc-update /chemin/vers/nouvelle-image.img
```

ou, avec téléchargement direct :

```sh
amipc-update https://exemple.tld/amipc-x.y.z.img
```

Voir [docs/CADRAGE.md](CADRAGE.md) et la section 2 du [ROADMAP.md](../ROADMAP.md) pour le détail du mécanisme de mise à jour.

---

## Statut

Guide rédigé et complet. Validation de la procédure sur clé USB réelle et machine physique à réaliser après première compilation effective de l'image (cf. [docs/TESTS.md](TESTS.md), test 1).
