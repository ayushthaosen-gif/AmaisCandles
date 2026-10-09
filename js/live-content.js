// Fills the page with the products and wording saved from the admin page (admin/).
// If Supabase isn't set up or can't be reached, the page keeps what's written in the HTML.
(function () {
  var cfg = window.AMAI_SUPABASE || {};
  if (!cfg.url || !cfg.key || !window.fetch) return;
  var base = cfg.url.replace(/\/+$/, '') + '/rest/v1/';

  function get(path) {
    var ctrl = window.AbortController ? new AbortController() : null;
    if (ctrl) setTimeout(function () { ctrl.abort(); }, 8000);
    return fetch(base + path, { headers: { apikey: cfg.key }, signal: ctrl && ctrl.signal })
      .then(function (r) { if (!r.ok) throw new Error(r.status); return r.json(); });
  }

  function el(tag, cls, text) {
    var e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text != null) e.textContent = text;
    return e;
  }

  function safeSrc(src) {
    try {
      var u = new URL(src, location.href);
      return u.protocol === 'https:' || u.protocol === 'http:' ? src : '';
    } catch (e) { return ''; }
  }

  function slug(s) { return s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') || 'more'; }

  function applyText(rows) {
    var map = {};
    rows.forEach(function (r) { map[r.key] = r.value; });
    document.querySelectorAll('[data-text]').forEach(function (node) {
      var v = map[node.getAttribute('data-text')];
      if (v != null && v !== '') node.textContent = v;
    });
  }

  function renderProducts(rows) {
    var work = document.querySelector('#work .wrap');
    if (!work || !rows.length) return;
    var order = ['candles', 'crochet'];
    var groups = {};
    var names = [];
    rows.forEach(function (p) {
      var name = (p.category || 'More').trim();
      var key = name.toLowerCase();
      if (!groups[key]) { groups[key] = { name: name, items: [] }; names.push(key); }
      groups[key].items.push(p);
    });
    names.sort(function (a, b) {
      var ia = order.indexOf(a), ib = order.indexOf(b);
      return (ia < 0 ? 99 : ia) - (ib < 0 ? 99 : ib);
    });

    work.querySelectorAll('.category').forEach(function (c) { c.remove(); });
    names.forEach(function (key) {
      var g = groups[key];
      var cat = el('div', 'category');
      cat.id = slug(g.name);
      cat.appendChild(el('h3', 'category-title', g.name));
      var grid = el('div', key === 'candles' ? 'gallery' : 'gallery three');
      g.items.forEach(function (p) {
        var src = safeSrc(p.image_url);
        if (!src) return;
        var art = el('article', 'piece');
        var fig = el('figure');
        var img = el('img');
        img.src = src;
        img.alt = p.alt || p.description || p.name;
        img.width = 1200; img.height = 1200;
        img.loading = 'lazy';
        fig.appendChild(img);
        var meta = el('div', 'meta');
        meta.appendChild(el('h3', null, p.name));
        if (p.description) meta.appendChild(el('p', 'notes', p.description));
        art.appendChild(fig); art.appendChild(meta);
        grid.appendChild(art);
      });
      if (!grid.children.length) return;
      cat.appendChild(grid);
      work.appendChild(cat);
    });
  }

  get('site_text?select=key,value').then(applyText).catch(function () {});
  if (document.getElementById('work')) {
    get('products?select=category,name,description,image_url,alt&visible=eq.true&order=position.asc,created_at.asc')
      .then(renderProducts).catch(function () {});
  }
})();
