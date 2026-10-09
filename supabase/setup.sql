-- Amai's Candles: one-time setup for the admin page.
-- Paste this whole file into Supabase > SQL Editor > New query, change the email
-- on the line marked CHANGE ME, and press Run. It is safe to run more than once.

-- Who is allowed to edit the site. Only people listed here can save changes.
create table if not exists public.admins (
  email text primary key
);
insert into public.admins (email) values ('CHANGE-ME@example.com')  -- CHANGE ME: the email you will log in with
on conflict do nothing;

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where lower(email) = lower(auth.jwt() ->> 'email'));
$$;

-- Products shown in the "What I make" gallery.
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  category text not null default 'Candles',
  name text not null,
  description text not null default '',
  image_url text not null,
  alt text not null default '',
  position integer not null default 0,
  visible boolean not null default true,
  created_at timestamptz not null default now()
);

-- Edited wording for the site. Anything not listed here keeps the text written in the page.
create table if not exists public.site_text (
  key text primary key,
  value text not null,
  updated_at timestamptz not null default now()
);

-- Let the website (anon) and logged-in users reach the tables; the policies below decide what each may do.
grant select on public.products, public.site_text to anon, authenticated;
grant insert, update, delete on public.products, public.site_text to authenticated;
grant select on public.admins to authenticated;
grant execute on function public.is_admin() to anon, authenticated;

alter table public.admins enable row level security;
alter table public.products enable row level security;
alter table public.site_text enable row level security;

drop policy if exists "admins can see themselves" on public.admins;
create policy "admins can see themselves" on public.admins for select using (public.is_admin());

drop policy if exists "anyone can see visible products" on public.products;
create policy "anyone can see visible products" on public.products for select using (visible or public.is_admin());
drop policy if exists "admins manage products" on public.products;
create policy "admins manage products" on public.products for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "anyone can read site text" on public.site_text;
create policy "anyone can read site text" on public.site_text for select using (true);
drop policy if exists "admins manage site text" on public.site_text;
create policy "admins manage site text" on public.site_text for all using (public.is_admin()) with check (public.is_admin());

-- Photo storage: anyone can view, only admins can upload or delete.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('products', 'products', true, 10485760, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

drop policy if exists "admins upload product photos" on storage.objects;
create policy "admins upload product photos" on storage.objects for insert
  with check (bucket_id = 'products' and public.is_admin());
drop policy if exists "admins change product photos" on storage.objects;
create policy "admins change product photos" on storage.objects for update
  using (bucket_id = 'products' and public.is_admin());
drop policy if exists "admins delete product photos" on storage.objects;
create policy "admins delete product photos" on storage.objects for delete
  using (bucket_id = 'products' and public.is_admin());

-- The pieces already on the site. Only added the first time, while the table is empty.
do $$
begin
  if not exists (select 1 from public.products) then
    insert into public.products (category, name, description, image_url, alt, position) values
      ('Candles', 'Pink daisy pillar', 'A white pillar candle with a pink wax daisy on top.', 'images/work/candle-pink-daisy-pillar.jpg', 'A white pillar candle topped with a pink wax daisy', 10),
      ('Candles', 'Sage daisy ribbed candle', 'A ribbed white candle with a green daisy on top.', 'images/work/candle-green-daisy-ribbed.jpg', 'A ribbed white candle with a sage-green wax daisy on top', 20),
      ('Candles', 'Pink daisy jar', 'A pink daisy candle in a glass jar with a lid.', 'images/work/candle-pink-daisy-jar.jpg', 'A pink daisy candle in a cut-glass jar with its lid lifted', 30),
      ('Candles', 'Bouquet pillar', 'A cream pillar with little wax flowers on top.', 'images/work/candle-bouquet-pillars.jpg', 'A cream pillar candle topped with pastel wax flowers, with a purple pillar behind it', 40),
      ('Candles', 'Ribbed flower pillars', 'One cream and one lavender, each with a flower on top.', 'images/work/candle-ribbed-flower-pillars.jpg', 'A cream ribbed pillar with an orange flower and a lavender ribbed pillar with a pink flower, on a white tray', 50),
      ('Candles', 'Daisy wax melts', 'Little daisies for your wax warmer.', 'images/work/candle-daisy-wax-melts.jpg', 'Two white daisy-shaped wax melts with purple centres', 60),
      ('Candles', 'Holly pillar', 'A sage pillar with holly leaves and berries, for Christmas.', 'images/work/candle-holly-pillar.jpg', 'A sage-green pillar candle decorated with wax holly leaves and red berries', 70),
      ('Candles', 'Pinecone candle', 'A little orange candle shaped like a pinecone.', 'images/work/candle-pinecone.jpg', 'An orange candle shaped like a pinecone', 80),
      ('Candles', 'Rose print pillar', 'A pale pillar wrapped in red roses.', 'images/work/candle-rose-print-pillar.jpg', 'A pale green pillar candle printed with red roses', 90),
      ('Candles', 'Blossom print pillars', 'A tall and a short pillar with pink blossoms, on a teal tray.', 'images/work/candle-blossom-print-pillars.jpg', 'Two pillar candles printed with pink blossoms, standing on a teal tray', 100),
      ('Candles', 'Daisy glass bowl', 'A white daisy floating in a ribbed glass bowl.', 'images/work/candle-daisy-glass-bowl.jpg', 'A white daisy candle in a ribbed glass bowl', 110),
      ('Candles', 'Flower glass bowls', 'Three glass bowls, each with its own flowers.', 'images/work/candle-flower-glass-bowls.jpg', 'Three glass bowl candles with pink, blue and white wax flowers', 120),
      ('Candles', 'Mosaic bowl', 'A yellow lotus and green succulents in a mosaic glass bowl.', 'images/work/candle-mosaic-bowl.jpg', 'A mosaic glass bowl candle with a yellow lotus flower and green wax succulents', 130),
      ('Candles', 'Jar and pillar collection', 'Some of my jars and pillars, with flowers set into the wax.', 'images/work/candle-jar-collection.jpg', 'A group of jar and pillar candles with wax flowers and pressed petals', 140),
      ('Candles', 'Flower candle trays', 'Wax flowers poured into wooden trays and little bowls.', 'images/work/candle-flower-trays.jpg', 'Wax flower candles in a wooden paddle tray, an oval dish and small round bowls', 150),
      ('Candles', 'Scented wax sachets', 'Little wax shapes with dried flowers, to hang in a wardrobe or car.', 'images/work/candle-wax-sachets.jpg', 'Scented wax sachets in round, star and rectangle shapes with dried flowers and hanging holes', 160),
      ('Crochet', 'Earring collection', 'Some of the earrings I''ve made. I can do lots of shapes and colours.', 'images/work/earring-collection.jpg', 'A selection of crocheted earrings: hoops, fans, flowers and tasselled drops in pink, cream, green, blue and red', 10),
      ('Crochet', 'Turquoise fan earrings', 'A turquoise fan on a silver hook.', 'images/work/blue-fan-earring.jpg', 'A turquoise crocheted fan earring', 20),
      ('Crochet', 'Ivory rose earrings', 'A little crochet rose with a pearl in the middle.', 'images/work/ivory-flower-earrings.jpg', 'An ivory crocheted rose earring with a pearl centre', 30),
      ('Crochet', 'Tricolour hoop earrings', 'Saffron, white and green hoops linked together.', 'images/work/tricolour-hoop-earrings.jpg', 'Interlinked crocheted hoop earrings in saffron, white and green', 40),
      ('Crochet', 'Leaf earrings', 'Long crochet leaves in cream and gold.', 'images/work/leaf-earrings.jpg', 'A pair of long crochet leaf earrings in cream and gold', 50),
      ('Crochet', 'Lilac fan earrings', 'Fan earrings in lilac.', 'images/work/lilac-fan-earrings.jpg', 'A pair of lilac crocheted fan earrings', 60),
      ('Crochet', 'Necklace and earring sets', 'A blue necklace with star earrings to match, next to a few other pairs.', 'images/work/jewellery-set.jpg', 'A blue crocheted necklace with matching star earrings, beside pink flower and layered purple earrings', 70),
      ('Crochet', 'Coasters', 'Coasters in red, turquoise, beige and cream.', 'images/work/coasters.jpg', 'Crocheted coasters in red, turquoise, beige and cream with lilac edging', 80),
      ('Crochet', 'Drawstring pouch', 'A sea-green pouch with small white flowers on the strings.', 'images/work/drawstring-pouch.jpg', 'A sea-green crocheted drawstring pouch with white crocheted flowers on the ties', 90);
  end if;
end $$;
