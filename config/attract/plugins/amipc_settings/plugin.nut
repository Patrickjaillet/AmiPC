class UserConfig {
	</ Langue de l'interface ( Francais ou English ) >
	langue = "Francais", { "Francais", "English" }

	</ Luminosite de l'affichage ( pourcentage ) >
	luminosite = "100", { "50", "60", "70", "80", "90", "100" }

	</ Activer le reseau Wi-Fi >
	reseau_actif = "Non", { "Oui", "Non" }

	</ Filtre video par defaut >
	filtre_video = "Pixel Perfect", { "Pixel Perfect", "Scanlines" }

	</ Verifier le reseau avant scraping (menu Afficher > Recharger/Scraper) >
	verifier_reseau_scraping = "Oui", { "Oui", "Non" }
}

fe.plugin_config["amipc_settings"] <- {}

local config = fe.get_config()

function appliquer_langue() {
	local langue = config["langue"] == "Francais" ? "fr" : "en"
	system("/usr/bin/amipc-set-langue " + langue)
}

function appliquer_luminosite() {
	system("/usr/bin/amipc-set-luminosite " + config["luminosite"])
}

function appliquer_reseau() {
	local etat = config["reseau_actif"] == "Oui" ? "on" : "off"
	system("/usr/bin/amipc-set-reseau " + etat)
}

function appliquer_filtre_video() {
	local fichier = config["filtre_video"] == "Scanlines" ? "scanlines.glslp" : "pixel-perfect.glslp"
	system("/usr/bin/amipc-set-shader " + fichier)
}

appliquer_langue()
appliquer_luminosite()
appliquer_reseau()
appliquer_filtre_video()

if (config["verifier_reseau_scraping"] == "Oui") {
	system("/usr/bin/amipc-verifier-reseau >/data/attract/dernier-controle-reseau.log 2>&1")
}
