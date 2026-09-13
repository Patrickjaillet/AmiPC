class AmiPCBiosCheck {
	constructor() {
		fe.add_ticks_callback(this, "on_tick")
		affiche = false
	}

	function lire_json(chemin) {
		local f = file(chemin, "r")
		local contenu = f.readblob(f.len()).readstring(f.len())
		f.close()
		return contenu
	}

	function lire_valeur(json_brut, cle_a, cle_b) {
		local pos_bloc = json_brut.find("\"" + cle_a + "\"")
		if (pos_bloc == null) return ""
		local pos_champ = json_brut.find("\"" + cle_b + "\"", pos_bloc)
		if (pos_champ == null) return ""
		local pos_dp = json_brut.find(":", pos_champ)
		local pos_go = json_brut.find("\"", pos_dp + 1)
		local pos_gf = json_brut.find("\"", pos_go + 1)
		return json_brut.slice(pos_go + 1, pos_gf)
	}

	function langue_active() {
		try {
			local c = file("/etc/amipc/amipc.conf", "r")
			local contenu = c.readblob(c.len()).readstring(c.len())
			c.close()
			if (contenu.find("AMIPC_DEFAULT_LANG=en") != null) return "en"
		} catch (e) {}
		return "fr"
	}

	function on_tick(ttime) {
		if (affiche) return
		if (!file_exists("/data/.amipc-bios-avertissement")) return

		local langue = langue_active()
		local json_brut = lire_json("/data/i18n/" + langue + ".json")
		local titre_texte = lire_valeur(json_brut, "bios_avertissement", "titre")
		local message_texte = lire_valeur(json_brut, "bios_avertissement", "message")

		local fond = fe.add_image("", 460, 400, 1000, 280)
		fond.set_rgb(120, 20, 20)
		fond.alpha = 230

		local titre = fe.add_text(titre_texte, 500, 430, 920, 50)
		titre.charsize = 28
		titre.set_rgb(255, 255, 255)

		local message = fe.add_text(message_texte, 500, 500, 920, 140)
		message.charsize = 20
		message.set_rgb(255, 230, 230)

		affiche = true
	}

	function file_exists(chemin) {
		try {
			local f = file(chemin, "r")
			f.close()
			return true
		} catch (e) {
			return false
		}
	}
}

fe.plugin["amipc_bios_check"] <- AmiPCBiosCheck()
