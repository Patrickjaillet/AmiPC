# Publication et Distribution — AmiPC

Ce document détaille le processus de publication, en complément de la section « 10. Publication et Distribution » du [ROADMAP.md](../ROADMAP.md).

---

## 0. Statut de ROADMAP.md

Le fichier [ROADMAP.md](../ROADMAP.md) est un document de suivi interne et reste volontairement exclu du dépôt Git public (`.gitignore`). Il n'est donc jamais publié sur GitHub ni référencé depuis le [README.md](../README.md) public. Toute la documentation technique destinée à accompagner une publication publique se trouve dans `docs/` et dans les fichiers CHANGELOG.md / COMPILATION.md / README.md, qui restent versionnés.

## 1. Intégration Continue

Trois workflows GitHub Actions sont définis dans `.github/workflows/` :

- **`build-image.yml`** : compile l'image AmiPC à chaque tag `v*.*.*` (et manuellement via `workflow_dispatch`), archive `amipc.img` comme artefact de build (30 jours de rétention).
- **`publier-release.yml`** : à chaque tag `v*.*.*`, recompile l'image, extrait automatiquement les notes de version correspondantes depuis [CHANGELOG.md](../CHANGELOG.md) (section `## [x.y.z]` correspondant au tag), et publie une **Release GitHub publique** contenant uniquement l'image système compilée — **sans aucun BIOS ni ROM**.
- **`verifier-conformite.yml`** : à chaque push/pull request, exécute `scripts/verifier_mentions_ia.sh` pour garantir l'absence de toute mention de Claude AI ou d'IA générative dans le dépôt.

## 2. Automatisation du Versionnage SemVer

Le script [scripts/publier_version.sh](../scripts/publier_version.sh) automatise l'incrément de version :

```sh
sh scripts/publier_version.sh patch   # ou minor / major
```

Ce script :
1. Lit la version actuelle dans [VERSION](../VERSION).
2. Incrémente le composant demandé (majeur, mineur ou correctif), conformément à SemVer.
3. Convertit la section `## [Non publié]` du CHANGELOG en `## [x.y.z] - AAAA-MM-JJ`.
4. Met à jour le fichier VERSION.

Une nouvelle section `## [Non publié]` doit être ajoutée manuellement en tête du CHANGELOG après chaque publication, pour accueillir les modifications suivantes avant la prochaine version.

## 3. Releases GitHub Publiques

Déclenchées automatiquement par `publier-release.yml` sur push d'un tag `v*.*.*`. Contenu strictement limité à l'image système compilée (`amipc.img`) et aux notes de version issues du CHANGELOG. **Aucun BIOS ni ROM commerciale n'est jamais inclus dans une release publique**, conformément au droit d'auteur (cf. [docs/GESTION_ROMS_BIOS.md](GESTION_ROMS_BIOS.md)).

## 4. Release Personnelle Complète (Usage Privé Uniquement)

Un script distinct, [scripts/empaqueter_release_personnelle.sh](../scripts/empaqueter_release_personnelle.sh), permet de générer une archive locale complète contenant l'image compilée **ainsi que** le contenu actuel de `bios/` et `roms/` :

```sh
sh scripts/empaqueter_release_personnelle.sh
```

**Cette archive est strictement destinée à un usage personnel et privé** (sauvegarde locale, transfert hors ligne vers son propre matériel). Elle :

- N'est générée par aucun workflow GitHub Actions et n'est jamais publiée sur le dépôt public.
- Est produite dans `build/release-personnelle/`, répertoire exclu de Git (`.gitignore`).
- Ne doit **jamais** être téléversée sur GitHub (Release, dépôt, gist) ni sur tout autre service public, les BIOS Kickstart Amiga étant sous copyright (Cloanto Corporation / Amiga Corp., à l'exception d'AROS qui est libre) et les jeux commerciaux Amiga sous copyright de leurs éditeurs respectifs.

## 5. Site Web du Projet

Le site https://patrickjaillet.github.io/AmiPC est généré depuis le répertoire `site/` et publié via GitHub Pages par le workflow `publier-site.yml`, déclenché à chaque tag `v*.*.*`. Le numéro de version affiché est mis à jour automatiquement depuis le fichier [VERSION](../VERSION) au moment du déploiement.

## 6. Vérification de l'Absence de Mentions d'IA Générative

Le script [scripts/verifier_mentions_ia.sh](../scripts/verifier_mentions_ia.sh) recherche dans l'ensemble du dépôt (hors `.git/`, `build/` et lui-même) toute mention de Claude, Anthropic, ChatGPT, OpenAI, Copilot ou d'IA générative en général. Le fichier [ROADMAP.md](../ROADMAP.md) est explicitement exclu de cette recherche, car il énonce lui-même cette règle de conformité en toutes lettres (ce qui constitue la politique, non une violation).

Exécuté automatiquement en CI sur chaque push et pull request via `verifier-conformite.yml`.

---

## Statut

Automatisation complète et prête à l'emploi. Exécution réelle des workflows GitHub Actions (nécessitant un dépôt Git distant configuré) et validation du déploiement Pages à réaliser lors de la première publication effective du projet.
