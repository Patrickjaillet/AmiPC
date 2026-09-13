# Guide de Dépannage — AmiPC

Ce guide recense les problèmes courants et leur résolution. Voir aussi [docs/TESTS.md](TESTS.md) pour les protocoles de validation détaillés.

---

## L'image ne démarre pas sur ma machine

- Vérifier que l'image a été écrite en mode « disque brut » (DD) et non en mode « fichier ISO simple », qui ne préserverait pas le partitionnement GPT attendu (cf. [docs/INSTALLATION.md](INSTALLATION.md)).
- Vérifier dans le BIOS/UEFI que le démarrage sur périphérique USB est autorisé et prioritaire.
- Si la machine est en mode UEFI strict avec Secure Boot activé, désactiver temporairement le Secure Boot (GRUB2 non signé par défaut dans cette configuration).

## Un jeu ne se lance pas ou affiche un écran noir

- Vérifier qu'aucun avertissement BIOS n'est affiché au démarrage d'AttractMode (bannière rouge, cf. [docs/GESTION_ROMS_BIOS.md](GESTION_ROMS_BIOS.md)). Si c'est le cas, le Kickstart requis par ce jeu est probablement manquant ou corrompu.
- Consulter le rapport détaillé dans `/data/amipc-bios-etat.txt` sur la machine cible.
- Vérifier que le format du fichier de jeu (`.zip`, `.adf`, `.ipf`, `.dms`, `.hdf`) est bien pris en charge par le core PUAE (cf. section 5 de [docs/PUAE.md](PUAE.md)).
- Certains jeux nécessitent un profil mémoire/chipset spécifique : créer un fichier de configuration par jeu (`.opt`) dans `config/retroarch/config/PUAE/`, comme documenté en section 10 de [docs/PUAE.md](PUAE.md).

## La manette n'est pas détectée

- Vérifier que la manette est bien reconnue par le système (pilote HID générique ou spécifique, cf. `linux-amipc.fragment`).
- Pour une manette Bluetooth, vérifier l'appairage préalable (le pilote `CONFIG_BT_HIDP` doit être actif dans le noyau).
- Redémarrer AttractMode après branchement si la détection à chaud échoue (`input_autodetect_enable` dans `retroarch.cfg`).

## Le son est absent ou déformé pendant le jeu

- Vérifier que le contrôleur audio de la machine est bien pris en charge par ALSA (`CONFIG_SND_HDA_INTEL` ou `CONFIG_SND_USB_AUDIO` selon le matériel, cf. `linux-amipc.fragment`).
- Ajuster la latence audio dans `config/retroarch/retroarch.cfg` (`audio_latency`), une valeur trop basse pouvant provoquer des craquements sur certains matériels.

## Ma sauvegarde de partie a disparu après une mise à jour de l'image

- Les sauvegardes résident sur la partition de données (`/data/retroarch/saves/`), séparée de la partition système : une mise à jour via `amipc-update` ne doit pas les affecter si elle ne réinitialise pas cette partition.
- Vérifier qu'aucune réinstallation complète (effacement total du disque) n'a été effectuée à la place d'une mise à jour.

## Je ne trouve pas mes jeux ajoutés depuis une clé USB externe

- Vérifier que l'arborescence sur la clé externe respecte exactement `amipc/roms/` et `amipc/bios/` (cf. [docs/INSTALLATION.md](INSTALLATION.md), section 3).
- Le montage automatique copie le contenu vers `/data/roms/` et `/data/bios/` ; il ne remplace jamais un fichier déjà présent (`cp -n`), donc un nom de fichier identique à un jeu déjà installé ne sera pas copié.
- Régénérer le romlist après ajout manuel (`sh scripts/generer_romlist.sh amiga500`), si les jeux ont été ajoutés côté développement plutôt que via la clé USB de la machine cible.

## L'interface reste dans la mauvaise langue

- La langue par défaut n'est déterminée automatiquement qu'au tout premier démarrage (cf. [docs/I18N.md](I18N.md)). Un changement de la locale système après ce premier démarrage n'a plus d'effet automatique.
- Changer la langue manuellement depuis le menu de configuration d'AttractMode (champ « Langue »).

## Le formulaire de paramètres n'affiche pas mes traductions

- Il s'agit d'une limite technique connue et documentée : le formulaire natif AttractMode (`UserConfig`) ne peut pas être internationalisé, contrairement au reste de l'interface AmiPC. Voir la section 2 de [docs/I18N.md](I18N.md) pour le détail.

## Le temps de démarrage me semble trop long

- Mesurer le temps réel avec le protocole de la section 8 de [docs/TESTS.md](TESTS.md) et comparer aux valeurs de référence une fois celles-ci consignées.
- Vérifier le timeout du menu GRUB2 (`buildroot-external/configs/amipc_x86_64_defconfig`), qui peut être réduit.

---

## Je ne trouve pas la réponse à mon problème

Consulter :
- [docs/CADRAGE.md](CADRAGE.md) pour le périmètre et les choix techniques du projet.
- [COMPILATION.md](../COMPILATION.md) pour tout problème lié à la compilation.
- L'onglet « À propos » du logiciel (touche F1) pour les coordonnées de contact du développeur (cf. [docs/A_PROPOS.md](A_PROPOS.md)).
