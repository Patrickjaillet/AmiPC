function getredval(couleur) { return (couleur >> 24) & 0xFF }
function getgreenval(couleur) { return (couleur >> 16) & 0xFF }
function getblueval(couleur) { return (couleur >> 8) & 0xFF }

fe.layout.width = 1920
fe.layout.height = 1080

local couleur_fond = 0x0A0E17FF
local couleur_accent = 0x00A8E8FF
local couleur_texte = 0xE6E6E6FF
local couleur_texte_secondaire = 0x8A93A6FF

local fond = fe.add_image("bg.png", 0, 0, fe.layout.width, fe.layout.height)
fond.set_rgb(10, 14, 23)

local wheel = fe.add_listbox(80, 140, 640, 800)
wheel.font = "amipc-regular"
wheel.charsize = 28
wheel.spacing = 44
wheel.set_rgb(getredval(couleur_texte), getgreenval(couleur_texte), getblueval(couleur_texte))
wheel.selbg_alpha = 200

local snap = fe.add_artwork("snap", 800, 140, 1040, 585)
local flyer = fe.add_artwork("flyer", 800, 760, 300, 420)
local marquee = fe.add_artwork("marquee", 1140, 760, 700, 200)

local titre = fe.add_text("[Title]", 80, 40, 1760, 70)
titre.font = "amipc-bold"
titre.charsize = 42
titre.set_rgb(getredval(couleur_accent), getgreenval(couleur_accent), getblueval(couleur_accent))
titre.align = Align.Left

local annee_fabricant = fe.add_text("[Year] - [Manufacturer]", 80, 1000, 1760, 40)
annee_fabricant.font = "amipc-regular"
annee_fabricant.charsize = 22
annee_fabricant.set_rgb(getredval(couleur_texte_secondaire), getgreenval(couleur_texte_secondaire), getblueval(couleur_texte_secondaire))

local filtre_actif = fe.add_text("[FilterName]", 1600, 40, 320, 40)
filtre_actif.font = "amipc-regular"
filtre_actif.charsize = 22
filtre_actif.align = Align.Right
filtre_actif.set_rgb(getredval(couleur_texte_secondaire), getgreenval(couleur_texte_secondaire), getblueval(couleur_texte_secondaire))
