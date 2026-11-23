<p align="center">
  <img src="frontend/src/assets/logo.png" alt="Boardly" width="320">
</p>

# Boardly

Webes projekt- és feladatkezelő alkalmazás Kanban-táblával.

**Vizsgaremek:** Szoftverfejlesztés és -tesztelés  
**Készítették:** Berta Krisztián Attila, Theodos Benjamin  
**Iskola:** Érdi SZC MOL Százhalombattai Széchenyi István Technikum és Gimnázium

## Tartalom

- Az alkalmazás adatbázissémája MySQL-hez (`backend/database/boardly.sql`)
- Laravel szerveralkalmazás
- Vue webes kliens navigációs sávval

## Technológiák

| Réteg | Technológia |
| --- | --- |
| Kliens | Vue 3, Vite |
| Szerver | PHP 8.3, Laravel 13 |
| Adatbázis | MySQL 8 |

## Könyvtárszerkezet

```
boardly/
├── backend/    Laravel szerveralkalmazás és az adatbázisséma
├── frontend/   Vue webes kliens
└── docs/       Projektdokumentáció és adatbázis-diagramok
```

## Rendszerkövetelmények

- PHP 8.3 vagy újabb, a `mbstring`, `openssl`, `fileinfo` és `curl` bővítménnyel
- Composer 2
- MySQL 8.0 vagy újabb
- Node.js 22 LTS (legalább 20.19) és npm

## Telepítés

### Adatbázis

A séma létrehozza a `boardly` adatbázist és annak 11 tábláját:

```bash
mysql -u root -p < backend/database/boardly.sql
```

A fájl phpMyAdminban az *Importálás* menüponttal is betölthető.

### Szerver

```bash
cd backend
composer install
copy .env.example .env
php artisan key:generate
```

### Kliens

```bash
cd frontend
npm install
```

## Futtatás

```bash
cd backend
php artisan serve
```

```bash
cd frontend
npm run dev
```

A szerver a `http://127.0.0.1:8000`, a kliens a `http://localhost:5173` címen érhető el.

## Tesztek

```bash
cd backend
php artisan test
```

## Dokumentáció

| Dokumentum | Fájl |
| --- | --- |
| Projektdokumentáció | [`docs/Boardly-Projektdokumentacio.pdf`](docs/Boardly-Projektdokumentacio.pdf), [`.docx`](docs/Boardly-Projektdokumentacio.docx) |
| Egyed-kapcsolat diagram | [`docs/Boardly-EK-diagram-Chen.png`](docs/Boardly-EK-diagram-Chen.png) |
| Relációs adatmodell | [`docs/Boardly-Relacios-adatmodell.png`](docs/Boardly-Relacios-adatmodell.png) |
| Adatbázisséma | [`backend/database/boardly.sql`](backend/database/boardly.sql) |
