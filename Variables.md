Créer un systeme de variables dynamique et persistante

tout les variables seront stocker en sql

certains variables sont uniquement coter serveur et d'autre coter client

--- Plus tard ajouter la possibilité de modifier les valeurs dans le sql depuis le menu admin

ajouter une sécurité name unique

table sql :

Id
Name
type
data
replicated
created_at
updated_at
updated_by

┌────┬────────────────┬─────────┬──────────────┬────────────┬─────────────────────┬─────────────────────┬────────────┐
│ Id │ Name │ type │ data │ replicated │ created_at │ updated_at │ updated_by │
├────┼────────────────┼─────────┼──────────────┼────────────┼─────────────────────┼─────────────────────┼────────────┤
│ 1 │ DoubleAccount │ boolean │ false │ 0 │ 2026-09-22 18:00:00 │ 2026-09-22 18:00:00 │ system │
│ 2 │ MaxPlayers │ number │ 500 │ 1 │ 2026-09-22 18:01:00 │ 2026-09-22 18:05:00 │ console │
│ 3 │ ServerName │ string │ "My Server" │ 1 │ 2026-09-22 18:02:00 │ 2026-09-22 18:10:00 │ admin │
└────┴────────────────┴─────────┴──────────────┴────────────┴─────────────────────┴─────────────────────┴────────────┘

J'aime beaucoup la logique de créer la variable dans le code avec la function et au chargement de verifier si elle existe en base de donnée ou non si oui alors sa prend les valeurs de la base sinon sa la créer
comme sa si imaginons qlq supprimes une variables qui est nécessaire dans le code sa evitera un crash bête et méchant.

---

exemple d'utilisation:

Variables.Register("bob", {
type = "string",
value = "moimeme",
replicated = false
})
