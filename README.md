<div align="center">

# SWZ Printer

**Imprimantes à argent pour DarkRP : 4 paliers, écran 3D interactif, 100 % configurable.**

[![TÉLÉCHARGER L'ADDON](https://img.shields.io/badge/-T%C3%89L%C3%89CHARGER%20L'ADDON-7c3aed?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Sweezyskz/swz-printer/releases/latest)
[![CONTENU WORKSHOP](https://img.shields.io/badge/-CONTENU%20WORKSHOP-3b82f6?style=for-the-badge&logo=steam&logoColor=white)](https://steamcommunity.com/sharedfiles/filedetails/?id=3829228668)
![VERSION](https://img.shields.io/badge/VERSION-1.0-7c3aed?style=for-the-badge&labelColor=555555)
![LICENCE](https://img.shields.io/badge/LICENCE-TOUS%20DROITS%20R%C3%89SERV%C3%89S-111111?style=for-the-badge&labelColor=555555)
![DARKRP](https://img.shields.io/badge/PR%C3%89REQUIS-DARKRP-0ea5e9?style=for-the-badge&labelColor=555555)

</div>

> [!WARNING]
> En téléchargeant, installant ou utilisant cet addon, vous reconnaissez avoir lu et accepté l'intégralité de la [licence](LICENSE).

## Présentation

Quatre imprimantes (**Bronze**, **Silver**, **Gold**, **Diamond**) avec un vrai modèle 3D et un **écran interactif posé sur le boîtier**. Le joueur regarde l'écran, appuie sur `E` et gère son imprimante : batterie, argent produit, température et santé s'affichent en direct, avec des jauges animées.

### Fonctionnalités

- Retrait de l'argent et recharge de la batterie directement sur l'écran
- Interrupteur ON/OFF et 3 modes (ECO, NORMAL, TURBO) qui changent production, consommation et chaleur
- Statistiques : total imprimé, gain par heure, temps avant stock plein ou batterie vide
- Ventilateur qui tourne, voyants lumineux, bruit de fonctionnement
- Écran lisible de près, version simplifiée de loin
- Achat au F4 (DarkRP) et dans le menu Q, avec une icône par palier
- Imprimante destructible, avec sac d'argent au sol
- Chargeur dans la console au démarrage (état du chargement)

### 100 % configurable

Tout se règle dans **un seul fichier**, sans toucher au code : prix, production, stock, batterie, température, limites par joueur, droits, distances, sons, couleurs de l'écran et **tous les textes** (traduction facile).
**Ajouter une imprimante = ajouter une ligne** dans la liste des paliers : l'entité, la fiche F4 et l'entrée du menu Q sont créées toutes seules. Un tutoriel est écrit en commentaire dans le fichier.

📁 **Fichier de configuration :** [`swz_printer/lua/swz_printer/sh_config.lua`](swz_printer/lua/swz_printer/sh_config.lua)

## Installation

1. Télécharge l'addon : bouton **Télécharger l'addon** ci-dessus (onglet *Releases*), ou **Code → Download ZIP**.
2. Copie le dossier `swz_printer` dans `garrysmod/addons/`.
3. Installe le **contenu Workshop** (voir ci-dessous).
4. Redémarre le serveur. La console affiche l'état du chargement.

### Contenu à installer (obligatoire)

Le modèle 3D et ses textures sont dans un item Workshop séparé :
**https://steamcommunity.com/sharedfiles/filedetails/?id=3829228668**

- Ajoute cet item à la **collection Workshop de ton serveur** (celle de `+host_workshop_collection`),
- **ou**, sans collection, ajoute cette ligne dans un fichier Lua serveur (par exemple `lua/autorun/server/workshop.lua`) :
  ```lua
  resource.AddWorkshop("3829228668")
  ```

Les joueurs téléchargent le contenu automatiquement à la connexion. Sans lui, les imprimantes s'affichent avec un boîtier de remplacement, sans ventilateur ni écran calé.

**Prérequis :** DarkRP.

---

## English

**SWZ Printer** — money printers for DarkRP. Four tiers (Bronze, Silver, Gold, Diamond), a custom 3D model and a **live interactive screen on top of the case** (battery, money, temperature, health, ON/OFF switch, ECO/NORMAL/TURBO modes).

- **Configuration:** one file, `swz_printer/lua/swz_printer/sh_config.lua` (prices, output, permissions, colors, texts...). Adding a printer means adding one line; a guide is in the file's comments.
- **Required content:** the model and textures are in the Workshop item above. Add it to your server's Workshop collection, or put `resource.AddWorkshop("3829228668")` in a server-side Lua file.
- **Install:** copy the `swz_printer` folder into `garrysmod/addons/`, install the Workshop content, restart the server.
- **Requires:** DarkRP.

## Crédits

Créé par **undefined.boy** — [GitHub](https://github.com/Sweezyskz) · [Portfolio](https://sweezy.asoso485576.workers.dev/)
