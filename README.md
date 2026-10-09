# Amai's Candles

Website for Amai's Candles: hand-poured soy candles and handmade crochet.

It's a plain static site: `index.html` plus the `images/` folder, with no build step. Open `index.html` in a browser to view it locally.

- **Products and wording are edited from the admin page at `/admin/`**, with no redeploy. They're stored in Supabase (free plan); see [ADMIN-SETUP.md](ADMIN-SETUP.md) for the one-time setup.
- `config.js` holds the Supabase project URL and public key. While it's empty, the site shows the products and text written in `index.html`, which also stay as the fallback if Supabase can't be reached.
- Any element with a `data-text="..."` attribute shows up in the admin's Site text tab automatically. Give new wording its own key to make it editable.
- The custom order form goes inside `<div id="order-form">`.
