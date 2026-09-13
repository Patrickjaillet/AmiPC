# Interface « À propos » — AmiPC

Ce document détaille l'implémentation de l'écran « À propos », en complément de la section « 5. Interface « À propos » » du [ROADMAP.md](../ROADMAP.md).

---

## 1. Accès

L'écran « À propos » est un plugin AttractMode (`config/attract/plugins/amipc_about/plugin.nut`) accessible depuis n'importe quel display du frontend via la combinaison assignée au signal `custom2` (touche **F1** au clavier, **bouton 4** à la manette), définie dans `config/attract/attract.cfg` (section `input_map`). Une entrée « À propos » est également prévue dans le menu principal (clé i18n `menu.a_propos`).

## 2. Contenu Affiché

Conformément au ROADMAP, l'écran affiche :

- Le nom du logiciel : **AmiPC**.
- Le numéro de version courant, lu dynamiquement depuis `/etc/amipc/VERSION` (fichier [VERSION](../VERSION) à la racine du dépôt, copié sur l'image par le paquet Buildroot `amipc-init`), garantissant que l'écran reflète toujours la version SemVer réellement installée.
- Le copyright : « Copyright © 2026 Patrick JAILLET — Tous droits réservés ».
- L'e-mail de contact : sandefjord.development@proton.me
- Le site web : https://patrickjaillet.github.io/AmiPC
- La liste des composants tiers utilisés avec leur rôle et leur licence (PUAE, libretro-uae, RetroArch, AttractMode, Buildroot, SDL2), issue de [i18n/credits.json](../i18n/credits.json).

## 3. Internationalisation

Tous les libellés de l'écran sont lus depuis les fichiers `i18n/fr.json` / `i18n/en.json` (clé racine `a_propos`), selon la langue active définie dans `/etc/amipc/amipc.conf` (`AMIPC_DEFAULT_LANG`). Le texte n'est jamais codé en dur dans le plugin, conformément aux conventions strictes du projet.

## 4. Déploiement

Les fichiers `i18n/` et `VERSION` sont copiés sur l'image cible par le paquet Buildroot `amipc-init` :

- `i18n/*.json` → `/data/i18n/`
- `VERSION` → `/etc/amipc/VERSION`

---

## Statut

Implémentation complète. Validation visuelle réelle de l'écran (rendu, lisibilité, navigation manette) à réaliser sur machine Linux cible après compilation, cf. [COMPILATION.md](../COMPILATION.md).
