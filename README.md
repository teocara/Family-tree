# Albero Genealogico – Famiglia Caramaschi

Interactive family tree web app for the Caramaschi family. Single self-contained
HTML file (vanilla JS, no build step). Everyone opens the same link and edits one
shared tree stored in the cloud.

## Live sites

- GitHub Pages: https://teocara.github.io/Family-tree/
- Netlify: https://ornate-cheesecake-283c5a.netlify.app/

Both serve the same `index.html` and auto-deploy on every push to `main`.

## How the pieces fit together

```
   Browser (index.html)  ──edit & Save──►  Supabase  (shared tree data)
        ▲                                       │
        │ auto-deploy on push                   │ daily backup (GitHub Action)
        │                                       ▼
   GitHub repo (teocara/Family-tree)  ◄──  albero-famiglia.json
        │
        ├─► GitHub Pages   (hosting)
        └─► Netlify        (hosting)
```

- **Supabase** — stores the tree. Table `trees` (`id text PK`, `data jsonb`,
  `updated_at`). Row id used by the app: `famiglia-principale`. Public RLS
  policies allow read/insert/update. The **publishable** key is safe to ship in
  the HTML; the secret/service key must never be committed.
- **GitHub** — source of truth for the code + daily data backups.
- **Netlify + GitHub Pages** — two mirrors of the same static site.

## Files

- `index.html` — the entire app (UI, layout engine, Supabase sync).
- `albero-famiglia.json` — daily snapshot of the tree data (auto-committed).
- `.github/workflows/backup.yml` — GitHub Action, runs daily at 02:00 UTC +
  manual trigger; fetches the tree from Supabase and commits the JSON.
- `backup.sh` — manual on-demand backup; reads credentials from `.env`.
- `.env` — Supabase credentials (gitignored, never commit). See `.env.example`.

> Note: a working copy also lives at `../famiglia-caramaschi.html` on the
> original author's desktop. When editing `index.html`, keep that copy in sync.

## Config (in `index.html`)

```js
const SUPABASE_URL = "https://czvjsuhsubhffostxhwm.supabase.co";
const SUPABASE_KEY = "sb_publishable_...";   // publishable key — safe in client
const TREE_ID      = "famiglia-principale";
```

GitHub Action secrets required: `SUPABASE_URL`, `SUPABASE_KEY`.

## Layout engine (auto-layout rules)

The tree positions everyone automatically (people can also be dragged; manual
positions are saved per-person and always win). Current rules:

1. **Strict generations** — oldest generation on top (row 0); every child sits
   exactly one row below their parents; spouses share their partner's row.
   A married-in spouse is pulled down to their partner's generation, never
   floats to the top.
2. **Partners adjacent** — couples are glued side-by-side (tight gap).
3. **Siblings contiguous & compact** — each generation row is packed to the
   minimum spacing so siblings/cousins sit as close as possible without
   overlapping. Connector lines are allowed to stretch.
4. **Centered** — parents are centered over the midpoint of their children;
   the whole tree is centered in the viewport.

`↺ Riordina` clears all manual positions, re-applies the auto-layout, and saves
to the cloud for everyone.

## Mobile

On phones the top bar, hint chips and help button are hidden — the tree fills
the screen. A single floating **💾 Salva** button (bottom-right) saves changes
to the shared cloud. Pinch to zoom, drag to pan, tap a person to add relatives.

## Editing / deploying

Edit `index.html`, commit, and push to `main`. Both live sites redeploy
automatically. No build step. Validate the inline JS parses before pushing:

```sh
node -e "const fs=require('fs');new Function(fs.readFileSync('index.html','utf8').match(/<script>([\s\S]*?)<\/script>/)[1]);console.log('OK')"
```
