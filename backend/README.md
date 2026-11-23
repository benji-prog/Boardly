# Boardly – szerver (Laravel)

A telepítés és az indítás leírása a [fő README-ben](../README.md) található.

## Felépítés

| Mappa / fájl | Tartalom |
| --- | --- |
| `database/boardly.sql` | Az adatbázisséma MySQL-hez: 11 tábla, elsődleges és idegen kulcsok, indexek, ellenőrző megszorítások |
| `routes/web.php` | Útvonalak |
| `tests/Feature` | Automatikus tesztek (`php artisan test`) |

## Adatbázisséma

| Tábla | Tartalom |
| --- | --- |
| `users` | Felhasználói fiókok |
| `projects` | Projektek |
| `project_members` | Projekttagságok és projektszintű szerepkörök |
| `board_columns` | A Kanban-tábla státuszoszlopai |
| `labels` | Projektszintű címkék |
| `tasks` | Feladatkártyák |
| `task_labels` | Feladatok és címkék kapcsolata |
| `task_assignees` | Feladatok felelősei |
| `comments` | Hozzászólások |
| `activity_logs` | Tevékenységnapló |
| `notifications` | Értesítések |

A táblák részletes leírása a projektdokumentáció adatszótárában található.
