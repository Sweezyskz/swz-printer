--[[-----------------------------------------------------------------------------------------------------------------------------
    SWZ PRINTER v1.0 : FICHIER DE CONFIGURATION
    C'est le SEUL fichier à modifier. Après chaque changement : redémarre le serveur (les joueurs se reconnectent).
    Ne supprime aucune ligne : si tu veux désactiver une option, mets false ou 0 à la place.
    Les couleurs s'écrivent Color(rouge, vert, bleu) avec des valeurs de 0 à 255.
-------------------------------------------------------------------------------------------------------------------------------]]

SWZPrinter = SWZPrinter or {}

SWZPrinter.Config = {

    ---------------------------------------------------------------------------------------------------------------------------
    -- GÉNÉRAL
    ---------------------------------------------------------------------------------------------------------------------------

    -- Nom de la catégorie dans le menu Q (onglet Entities).
    Category = "SWZ Printer",

    -- true : seuls les admins peuvent sortir une imprimante depuis le menu Q. Les joueurs passent par le F4 (voir Shop).
    AdminOnlySpawn = true,

    -- Symbole affiché devant les montants (écran de l'imprimante et messages).
    Currency = "$",

    -- Modèle 3D de l'imprimante. FallbackModel est utilisé si le modèle perso est introuvable sur le serveur.
    Model = "models/swz/printer.mdl",
    FallbackModel = "models/props_c17/consolebox01a.mdl",

    ---------------------------------------------------------------------------------------------------------------------------
    -- BOUTIQUE F4 (DarkRP)
    ---------------------------------------------------------------------------------------------------------------------------
    Shop = {
        -- true : chaque imprimante de la liste Tiers est ajoutée au F4. false : seulement le menu Q.
        Enabled = true,

        -- Les commandes de chat sont "préfixe" + identifiant du palier. Exemple : /buyprinterbronze
        CommandPrefix = "buyprinter",

        -- Champs DarkRP ajoutés à CHAQUE imprimante, par exemple pour la réserver à des métiers ou à une catégorie du F4 :
        --     Extra = {allowed = {TEAM_GANG, TEAM_MOB}, category = "Printers"},
        -- (la catégorie doit exister dans DarkRP, sinon laisse vide.)
        Extra = {},
    },

    ---------------------------------------------------------------------------------------------------------------------------
    -- VIE ET DESTRUCTION
    ---------------------------------------------------------------------------------------------------------------------------

    -- Points de vie d'une imprimante (les dégâts reçus les font baisser ; à 0 elle est détruite).
    Health = 100,

    -- Récompense versée par DarkRP à celui qui détruit/saisit l'imprimante (si ton DarkRP la gère).
    SeizeReward = 950,

    -- true : une imprimante plongée dans l'eau est détruite.
    DestroyInWater = true,

    -- true : à la destruction, l'argent stocké tombe au sol en sac d'argent. false : il est perdu.
    DropMoneyOnDestroy = true,

    -- true : effet d'explosion à la destruction.
    ExplosionOnDestroy = true,

    ---------------------------------------------------------------------------------------------------------------------------
    -- COMMANDES SUR L'ÉCRAN
    ---------------------------------------------------------------------------------------------------------------------------

    -- État d'une imprimante neuve : true = allumée, false = éteinte.
    StartPowered = true,

    -- Mode d'une imprimante neuve : numéro dans la liste Modes plus bas (2 = NORMAL).
    DefaultMode = 2,

    -- true : seul le propriétaire (ou un admin, voir AdminBypass) peut allumer/éteindre et changer de mode.
    OwnerOnlyControl = true,

    -- true : les admins peuvent toujours tout commander, même sur l'imprimante d'un autre.
    AdminBypass = true,

    -- true : seul le propriétaire peut retirer l'argent. false : tout le monde (idéal pour les raids).
    OwnerOnlyWithdraw = false,

    -- true : seul le propriétaire peut recharger la batterie.
    OwnerOnlyRecharge = false,

    -- Délai minimum entre deux actions d'un même joueur, en secondes (anti-spam).
    ActionCooldown = 0.4,

    ---------------------------------------------------------------------------------------------------------------------------
    -- TEMPÉRATURE
    ---------------------------------------------------------------------------------------------------------------------------

    -- Température de l'imprimante éteinte, en °C.
    AmbientTemp = 22,

    -- Vitesse à laquelle la température rejoint sa cible (0.05 = très lent, 0.5 = très rapide).
    HeatSpeed = 0.15,

    ---------------------------------------------------------------------------------------------------------------------------
    -- DISTANCES (en unités du jeu ; 1 mètre = environ 52 unités)
    ---------------------------------------------------------------------------------------------------------------------------
    Distance = {
        -- Distance maximale pour cliquer sur l'écran avec E.
        Use = 110,

        -- Jusqu'à cette distance : écran complet avec les textes. Au-delà : version simplifiée sans texte (jauges et couleurs).
        Detail = 400,

        -- Au-delà de cette distance : l'écran n'est plus dessiné du tout.
        Max = 1500,

        -- Jusqu'à cette distance le ventilateur tourne.
        Fan = 1000,
    },

    ---------------------------------------------------------------------------------------------------------------------------
    -- ÉCRAN 3D POSÉ SUR LE DESSUS DU BOÎTIER
    ---------------------------------------------------------------------------------------------------------------------------
    Screen = {
        -- Dimensions du dessus du modèle perso, en unités : Length = avant-arrière, Width = gauche-droite.
        -- À modifier seulement si tu changes le modèle 3D. L'écran garde ses proportions et se cale dans ce rectangle.
        Length = 31.5,
        Width = 31.5,

        -- Taille de l'écran : 1 = remplit tout le dessus, 0.9 = 10 % plus petit, 1.05 = 5 % plus grand.
        Scale = 1,

        -- Décalage de l'écran sur le boîtier, en unités. OffsetX : vers l'avant (+) ou l'arrière (-). OffsetY : vers la gauche (+) ou la droite (-).
        OffsetX = 0,
        OffsetY = 0,

        -- Hauteur de l'écran au-dessus du sol du modèle (le verre du modèle perso est à 11.06).
        Height = 11.1,

        -- Vitesse des animations de l'écran (jauges, interrupteur, mode) : 1 = normal, 2 = deux fois plus vite, 0 = pas d'animation.
        AnimSpeed = 1,

        -- true : texte plus net vu de biais (filtre anisotrope). Mets false si tu constates des problèmes d'affichage.
        SharpText = true,
    },

    -- Teinte de la coque selon le palier : 0 = couleur d'origine, 0.3 = légère teinte, 0.6 = forte teinte.
    Tint = 0.3,

    ---------------------------------------------------------------------------------------------------------------------------
    -- VENTILATEUR ET LUMIÈRES
    ---------------------------------------------------------------------------------------------------------------------------
    Fan = {
        -- false : le ventilateur ne tourne jamais.
        Enabled = true,

        -- Nom de l'os du ventilateur dans le modèle 3D. Ne change que si ton modèle utilise un autre nom.
        Bone = "fan",

        -- Vitesse en degrés par seconde (600 = environ 1,7 tour par seconde).
        Speed = 600,

        -- Rapidité de la montée en vitesse au démarrage, et du ralentissement à l'arrêt (plus grand = plus rapide).
        SpinUp = 1.2,
        SpinDown = 0.4,
    },

    LEDs = {
        -- Les 3 voyants sur la face avant : vert = en marche, orange = stock plein, rouge = batterie vide.
        Enabled = true,

        -- Taille des voyants.
        Size = 3,
    },

    ---------------------------------------------------------------------------------------------------------------------------
    -- SONS
    ---------------------------------------------------------------------------------------------------------------------------
    Sounds = {
        -- Bruit de fonctionnement (joué en boucle quand l'imprimante imprime). "" = aucun bruit.
        Loop = "ambient/levels/labs/equipment_printer_loop1.wav",

        -- Portée du bruit de fonctionnement (plus grand = s'entend de plus loin ; 52 = discret).
        LoopLevel = 52,

        -- Son quand on clique sur un bouton de l'écran. "" = aucun son.
        Click = "buttons/button15.wav",
    },

    ---------------------------------------------------------------------------------------------------------------------------
    -- COULEURS DE L'ÉCRAN
    ---------------------------------------------------------------------------------------------------------------------------
    Theme = {
        bg = Color(12, 14, 19),        -- fond de l'écran
        card = Color(22, 26, 34),      -- fond des cartes
        hi = Color(32, 38, 50),        -- carte survolée
        line = Color(40, 46, 58),      -- fond des jauges
        text = Color(238, 241, 247),   -- texte principal
        mute = Color(128, 138, 156),   -- texte secondaire
        ok = Color(74, 214, 130),      -- vert : tout va bien
        warn = Color(255, 176, 56),    -- orange : attention
        bad = Color(255, 82, 82),      -- rouge : problème
        buttonText = Color(10, 12, 16),-- texte des boutons
    },

    ---------------------------------------------------------------------------------------------------------------------------
    -- TEXTES (traduction possible : remplace simplement les mots entre guillemets)
    -- %s est remplacé par une valeur (un montant, un nom...) : garde-le dans la phrase.
    ---------------------------------------------------------------------------------------------------------------------------
    Lang = {
        Unknown = "Inconnu",
        PrinterSuffix = "PRINTER",

        StateOff = "ÉTEINTE",
        StateOnline = "EN LIGNE",
        StateEmpty = "BATTERIE VIDE",
        StateFull = "STOCK PLEIN",

        Power = "ALIMENTATION",
        PowerOn = "ALLUMÉE",
        PowerOff = "ÉTEINTE",
        Mode = "MODE",

        Battery = "BATTERIE",
        EmptyIn = "vide dans %s",
        Idle = "au repos",
        Recharge = "RECHARGER",

        Money = "ARGENT",
        Max = "max %s",
        PerMinute = "%s/min",
        InStock = "EN STOCK",
        Withdraw = "RETIRER",

        StatTotal = "TOTAL",
        StatPerHour = "PAR HEURE",
        StatFullIn = "PLEIN DANS",
        StatEmptyIn = "VIDE DANS",
        StatFull = "PLEIN",
        Temperature = "TEMP.",
        Health = "SANTÉ",

        NothingToWithdraw = "Il n'y a rien à retirer.",
        Withdrawn = "Vous avez retiré %s.",
        BatteryAlreadyFull = "La batterie est déjà pleine.",
        NeedMoney = "Il vous faut %s.",
        Recharged = "Batterie rechargée pour %s.",
        OwnerOnly = "Seul le propriétaire peut faire ça.",
        PoweredOn = "Imprimante allumée.",
        PoweredOff = "Imprimante éteinte.",
        ModeSet = "Mode %s.",
        Destroyed = "Votre imprimante %s a été détruite.",
    },

    ---------------------------------------------------------------------------------------------------------------------------
    -- MODES (boutons ECO / NORMAL / TURBO de l'écran)
    -- name : texte du bouton | rate : multiplicateur de production | drain : multiplicateur de consommation de batterie
    -- heat : degrés ajoutés à la température de fonctionnement | color : couleur du bouton sélectionné
    -- Tu peux modifier, supprimer ou ajouter des modes (3 ou 4 recommandés, 12 maximum). DefaultMode donne le numéro du mode de départ.
    ---------------------------------------------------------------------------------------------------------------------------
    Modes = {
        {name = "ECO",    rate = 0.6, drain = 0.5, heat = -8, color = Color(74, 214, 130)},
        {name = "NORMAL", rate = 1,   drain = 1,   heat = 0,  color = Color(120, 170, 255)},
        {name = "TURBO",  rate = 1.5, drain = 1.8, heat = 16, color = Color(255, 120, 60)},
    },

    ---------------------------------------------------------------------------------------------------------------------------
    -- LES IMPRIMANTES (PALIERS)
    --
    -- COMMENT AJOUTER UNE IMPRIMANTE
    --   1. Copie une ligne de la liste ci-dessous, colle-la juste avant l'accolade fermante "}" de Tiers.
    --   2. Change l'identifiant (id) : lettres minuscules sans espace, unique. Exemple : "emerald".
    --   3. Règle les chiffres (voir la légende), enregistre, redémarre le serveur. C'est tout.
    --      L'entité "swz_printer_emerald", la fiche du F4 (commande /buyprinteremerald) et l'entrée du menu Q sont créées toutes seules.
    --      Aucun autre fichier n'est à créer.
    --   4. Pour la supprimer : supprime sa ligne.
    --   5. Icône dans le menu Q : ajoute une image PNG de 256 x 256 nommée "swz_printer_<id>.png" (ex. swz_printer_emerald.png)
    --      dans le dossier materials/entities/ de ton addon Workshop (ou de cet addon). Sans image, la case du menu Q reste vide.
    --
    -- LÉGENDE
    --   id       identifiant technique (ne le change plus une fois l'imprimante en circulation : les imprimantes posées disparaîtraient)
    --   name     nom affiché (menu Q, F4 et écran) ; "Emerald" donne "Emerald Printer"
    --   color    couleur du palier (teinte du boîtier, du ventilateur et des accents de l'écran)
    --   price    prix d'achat au F4
    --   rate     argent imprimé par minute en mode NORMAL
    --   max      argent maximum stocké (l'imprimante s'arrête quand c'est plein)
    --   drain    pourcentage de batterie consommé par minute en mode NORMAL (7 = la batterie dure environ 14 minutes)
    --   recharge prix d'une recharge complète de 0 à 100 % (une recharge partielle coûte au prorata)
    --   heat     température de fonctionnement en °C en mode NORMAL
    --   limit    nombre maximum de cette imprimante par joueur (F4)
    --   shop     (facultatif) champs DarkRP propres à cette imprimante, par exemple shop = {allowed = {TEAM_GANG}}
    --
    -- EXEMPLE : une imprimante Emerald très rentable mais chère.
    --   {id = "emerald", name = "Emerald", color = Color(60, 220, 140), price = 30000, rate = 1500, max = 45000, drain = 7, recharge = 3000, heat = 70, limit = 1},
    ---------------------------------------------------------------------------------------------------------------------------
    Tiers = {
        {id = "bronze",  name = "Bronze",  color = Color(205, 127, 80),  price = 1500,  rate = 120, max = 3600,  drain = 7, recharge = 200,  heat = 46, limit = 3},
        {id = "silver",  name = "Silver",  color = Color(190, 199, 214), price = 3500,  rate = 280, max = 8400,  drain = 7, recharge = 400,  heat = 52, limit = 3},
        {id = "gold",    name = "Gold",    color = Color(240, 190, 60),  price = 7000,  rate = 520, max = 15600, drain = 7, recharge = 800,  heat = 58, limit = 2},
        {id = "diamond", name = "Diamond", color = Color(110, 200, 255), price = 14000, rate = 900, max = 27000, drain = 7, recharge = 1600, heat = 64, limit = 2},
    },
}

SWZPrinter.Tier = {}
for _, t in ipairs(SWZPrinter.Config.Tiers) do SWZPrinter.Tier[t.id] = t end

function SWZPrinter.GetModel()
    local c = SWZPrinter.Config
    return file.Exists(c.Model, "GAME") and c.Model or c.FallbackModel
end
