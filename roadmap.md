# Feuille de route — Core FiveM Standalone (Monolithique)

**Contexte du projet**

- Développeur solo, aucun contrainte de délai — priorité à la qualité et à la propreté du code
- Style 100% custom, sans base ESX/QBCore
- Objectif : un seul core qui gère (quasi) tout le serveur RP

Cette roadmap est organisée en **phases logiques**, pas en dates fixes, puisque vous avancez à votre rythme. Chaque phase a des objectifs clairs et des "critères de sortie" (quand on peut dire que la phase est terminée).

---

## Phase 0 — Fondations & Architecture

L'étape la plus importante pour un core monolithique : si l'architecture est bancale ici, tout le reste en pâtira.

**Objectifs**

- Choisir la stack technique : `oxmysql` pour la base de données (standard actuel, remplace `mysql-async`), et décider si vous utilisez `ox_lib` uniquement comme utilitaire (notifications, progressbar, zones) sans dépendre de son framework — c'est courant même en standalone.
- Définir la structure interne du core en **modules internes** plutôt qu'en sous-ressources séparées, par exemple :
  ```
  mon_core/
  ├── fxmanifest.lua
  ├── config/
  │   ├── shared.lua
  │   ├── server.lua
  ├── server/
  │   ├── main.lua
  │   ├── modules/
  │   │   ├── player.lua
  │   │   ├── character.lua
  │   │   ├── inventory.lua
  │   │   ├── jobs.lua
  │   │   ├── economy.lua
  │   │   ├── vehicles.lua
  │   │   ├── housing.lua
  │   │   ├── permissions.lua
  │   ├── database/
  │   │   ├── schema.sql
  │   │   ├── queries.lua
  ├── client/
  │   ├── main.lua
  │   ├── modules/
  │   │   ├── hud.lua
  │   │   ├── interactions.lua
  ├── shared/
  │   ├── utils.lua
  │   ├── classes.lua (OOP si vous utilisez des metatables Lua pour Player/Character)
  ```
- Définir une convention de nommage stricte pour les exports et events internes (`monCore:server:action`, `monCore:client:action`) pour éviter les collisions.
- Décider du modèle objet : est-ce que "Player" et "Character" seront des tables Lua simples ou des objets avec metatables (`self:getMoney()`, etc.) ? Ce choix structure tout le reste du code.
- Mettre en place un dépôt Git dès le départ (branches, commits atomiques) — indispensable en solo pour pouvoir revenir en arrière proprement.

**Critère de sortie** : vous avez un squelette de resource qui démarre sans erreur, avec `oxmysql` connecté, et une structure de dossiers/modules qui vous convient pour la suite.

---

## Phase 1 — Système Joueur & Session

Le cœur du cœur : la gestion du joueur, de la connexion à la déconnexion.

**Objectifs**

- Système de connexion (identifiants Rockstar/Steam/license) et création de compte en base
- Gestion des personnages (multi-personnages ou un seul par compte — à décider)
- Système de session (chargement des données à la connexion, sauvegarde périodique + à la déconnexion, protection contre la perte de données en cas de crash serveur)
- Système de permissions/grades (ACE permissions FiveM, ou système custom en base de données)
- Gestion des spawns et du premier chargement du joueur dans le monde

**Critère de sortie** : un joueur peut se connecter, créer un personnage, apparaître dans le monde, se déconnecter, et retrouver exactement son état à la reconnexion.

---

## Phase 2 — Persistance des données & Économie de base

**Objectifs**

- Schéma de base de données complet (players, characters, inventories, vehicles, jobs, etc.) pensé dès maintenant pour éviter les migrations douloureuses plus tard
- Système d'argent (cash + banque), avec toutes les fonctions serveur pour ajouter/retirer/vérifier de façon sécurisée (jamais de confiance côté client)
- Système d'inventaire (slots, poids, métadonnées d'objets) — c'est un des modules les plus complexes, prévoyez du temps dessus
- Logs des transactions importantes (argent, objets) pour la modération future

**Critère de sortie** : un joueur peut gagner/dépenser de l'argent, avoir des objets dans son inventaire, et tout persiste correctement en base.

---

## Phase 3 — Gameplay RP (Jobs, Véhicules, Logements)

**Objectifs**

- Système de métiers (jobs) avec grades, salaires, et actions spécifiques par métier
- Système de véhicules (propriété, garages, clés, dégâts persistants si souhaité)
- Système de logements (propriété, meubles/déco si souhaité, stockage)
- Système de gangs/organisations si prévu pour votre serveur

**Critère de sortie** : les piliers du gameplay RP fonctionnent de bout en bout et sont liés au système de personnage/économie.

---

## Phase 4 — Interface (UI/UX)

**Objectifs**

- HUD (santé, faim, soif, argent, etc.)
- Menus NUI pour l'inventaire, le téléphone si prévu, les interactions
- Notifications, progressbars, menus contextuels
- Cohérence visuelle sur l'ensemble des interfaces (un seul système de design plutôt que du bricolage par module)

**Critère de sortie** : l'expérience joueur est fluide visuellement, pas seulement fonctionnelle en arrière-plan.

---

## Phase 5 — Outils d'administration & Sécurité

**Objectifs**

- Panel/menu admin en jeu (téléportation, spawn d'objets/véhicules, gestion des joueurs, kick/ban)
- Système de logs centralisé (Discord webhook ou base de données) pour toute action sensible
- Anti-exploit côté serveur : ne jamais faire confiance aux events envoyés par le client, valider systématiquement (distances, cooldowns, possession d'objets, etc.)
- Système de rapports/tickets si vous voulez un support in-game

**Critère de sortie** : vous pouvez modérer votre serveur sans toucher à la base de données à la main, et les failles évidentes (exploits d'argent/objets) sont couvertes.

---

## Phase 6 — Optimisation, Tests & Documentation

**Objectifs**

- Passage au peigne fin des performances (profiling avec `resmon`, éviter les boucles `Citizen.Wait(0)` inutiles, threads bien dimensionnés)
- Tests de charge avec plusieurs joueurs simulés si possible
- Documentation interne de votre propre core (même solo, votre "vous du futur" vous remerciera) : liste des exports, structure de la base de données, conventions
- Nettoyage du code, suppression du code mort, cohérence de style

**Critère de sortie** : le core tient la charge, est documenté, et vous pourriez y revenir dans 6 mois sans tout redécouvrir.

---

## Phase 7 — Lancement & Après

**Objectifs**

- Tests en environnement de préproduction avec de vrais joueurs (bêta fermée)
- Système de sauvegarde automatique de la base de données (backups réguliers, non négociable pour un serveur RP)
- Plan de mises à jour et de correctifs post-lancement
- Canal de retour joueurs (Discord, formulaire) pour prioriser les prochaines features

---

## Points d'architecture à trancher tôt (recommandé avant la Phase 1)

Ces décisions sont coûteuses à changer une fois beaucoup de code écrit :

1. **Un seul personnage par compte, ou plusieurs ?** Impacte tout le schéma de base de données.
2. **Objets Lua avec metatables ou tables simples ?** Impacte le style de code de tout le projet.
3. **Faut-il garder `ox_lib` comme simple boîte à outils, ou tout recoder soi-même (NUI, progressbar, zones) ?** Pur standalone = plus de contrôle mais plus de temps.
4. **OneSync Infinity activé dès le départ ?** Impacte la gestion des entités et la scalabilité du nombre de joueurs.

Je vous recommande de trancher ces 4 points avant d'écrire la moindre ligne de la Phase 1.
