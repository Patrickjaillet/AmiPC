class AmiPCAbout {
	overlay_visible = false
	elements = []

	constructor() {
		fe.add_signal_handler(this, "on_signal")
	}

	function charger_json(chemin) {
		local fichier = file(chemin, "r")
		local contenu = fichier.readblob(fichier.len()).readstring(fichier.len())
		fichier.close()
		return contenu
	}

	function lire_valeur(json_brut, cle_a, cle_b) {
		local motif_bloc = "\"" + cle_a + "\""
		local pos_bloc = json_brut.find(motif_bloc)
		if (pos_bloc == null) return ""
		local motif_champ = "\"" + cle_b + "\""
		local pos_champ = json_brut.find(motif_champ, pos_bloc)
		if (pos_champ == null) return ""
		local pos_deux_points = json_brut.find(":", pos_champ)
		local pos_guillemet_ouvrant = json_brut.find("\"", pos_deux_points + 1)
		local pos_guillemet_fermant = json_brut.find("\"", pos_guillemet_ouvrant + 1)
		return json_brut.slice(pos_guillemet_ouvrant + 1, pos_guillemet_fermant)
	}

	function extraire_noms_composants(json_brut) {
		local noms = []
		local motif = "\"nom\""
		local position = 0
		while (true) {
			position = json_brut.find(motif, position)
			if (position == null) break
			local pos_deux_points = json_brut.find(":", position)
			local pos_guillemet_ouvrant = json_brut.find("\"", pos_deux_points + 1)
			local pos_guillemet_fermant = json_brut.find("\"", pos_guillemet_ouvrant + 1)
			noms.append(json_brut.slice(pos_guillemet_ouvrant + 1, pos_guillemet_fermant))
			position = pos_guillemet_fermant + 1
		}
		return noms.reduce(function(a, b) { return a + ", " + b })
	}

	function langue_active() {
		local conf = file("/etc/amipc/amipc.conf", "r")
		local contenu = conf.readblob(conf.len()).readstring(conf.len())
		conf.close()
		if (contenu.find("AMIPC_DEFAULT_LANG=en") != null) return "en"
		return "fr"
	}

	function afficher() {
		local langue = langue_active()
		local chemin_i18n = "/data/i18n/" + langue + ".json"
		local json_brut = charger_json(chemin_i18n)

		local version = ""
		try {
			local vf = file("/etc/amipc/VERSION", "r")
			version = vf.readblob(vf.len()).readstring(vf.len())
			vf.close()
		} catch (e) {
			version = "0.0.0"
		}

		local fond = fe.add_image("", 260, 140, 1400, 800)
		fond.set_rgb(10, 14, 23)
		fond.alpha = 235
		elements.append(fond)

		local titre = fe.add_text(lire_valeur(json_brut, "a_propos", "titre"), 300, 180, 1320, 60)
		titre.charsize = 34
		titre.set_rgb(0, 168, 232)
		elements.append(titre)

		local nom = fe.add_text(lire_valeur(json_brut, "a_propos", "nom_logiciel") + " - " + lire_valeur(json_brut, "a_propos", "libelle_version") + " " + version, 300, 260, 1320, 40)
		nom.charsize = 26
		nom.set_rgb(230, 230, 230)
		elements.append(nom)

		local copyright = fe.add_text(lire_valeur(json_brut, "a_propos", "libelle_copyright"), 300, 320, 1320, 40)
		copyright.charsize = 20
		copyright.set_rgb(230, 230, 230)
		elements.append(copyright)

		local email = fe.add_text(lire_valeur(json_brut, "a_propos", "libelle_email") + " : sandefjord.development@proton.me", 300, 380, 1320, 40)
		email.charsize = 20
		email.set_rgb(138, 147, 166)
		elements.append(email)

		local site = fe.add_text(lire_valeur(json_brut, "a_propos", "libelle_site_web") + " : https://patrickjaillet.github.io/AmiPC", 300, 420, 1320, 40)
		site.charsize = 20
		site.set_rgb(138, 147, 166)
		elements.append(site)

		local credits_titre = fe.add_text(lire_valeur(json_brut, "a_propos", "titre_credits"), 300, 490, 1320, 40)
		credits_titre.charsize = 24
		credits_titre.set_rgb(0, 168, 232)
		elements.append(credits_titre)

		local credits_json = charger_json("/data/i18n/credits.json")
		local credits_texte = extraire_noms_composants(credits_json)
		local credits_liste = fe.add_text(credits_texte, 300, 540, 1320, 200)
		credits_liste.charsize = 18
		credits_liste.set_rgb(200, 200, 200)
		elements.append(credits_liste)

		overlay_visible = true
	}

	function masquer() {
		foreach (element in elements) {
			fe.remove_from_layout(element)
		}
		elements.clear()
		overlay_visible = false
	}

	function on_signal(signal_name) {
		if (signal_name == "custom2") {
			if (overlay_visible) masquer()
			else afficher()
			return true
		}
		if (signal_name == "back" && overlay_visible) {
			masquer()
			return true
		}
		return false
	}
}

fe.plugin["amipc_about"] <- AmiPCAbout()
