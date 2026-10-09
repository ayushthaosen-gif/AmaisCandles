# Setting up the shop admin

The admin page at **https://amaiscandles.netlify.app/admin/** lets you add, edit, hide, reorder and delete products, upload their photos, and change any wording on the site, all from a browser. Changes show up on the site straight away, with no redeploy.

Products, photos and edited wording are stored in [Supabase](https://supabase.com) on its free plan. You set it up once, which takes about ten minutes.

## 1. Make a Supabase project

1. Sign up at [supabase.com](https://supabase.com) (signing in with GitHub is easiest).
2. Press **New project**. Name it `amaiscandles`, make up a database password (you won't need it again, but keep it somewhere), and pick the region closest to you, for example **Mumbai**.
3. Wait a minute or two while it gets ready.

## 2. Create the tables and move the current products in

1. In the left sidebar, open **SQL Editor** and press **New query**.
2. Open [`supabase/setup.sql`](supabase/setup.sql), copy all of it, and paste it in.
3. Find the line marked `CHANGE ME` and replace `CHANGE-ME@example.com` with the email you'll log in with.
4. Press **Run**. It should say "Success". This also adds the 25 pieces that are on the site today.

## 3. Create your login

1. Open **Authentication → Users** and press **Add user → Create new user**.
2. Enter the same email as in step 2, choose a password, tick **Auto Confirm User**, and press **Create user**.
3. Open **Authentication → Sign In / Providers** and turn off **Allow new users to sign up**. (Only the email from step 2 can edit anything anyway, but this keeps strangers from making accounts.)
4. Open **Authentication → URL Configuration** and set **Site URL** to `https://amaiscandles.netlify.app/admin/`. This is where "I forgot my password" emails send you.

## 4. Connect the site

1. Open **Project Settings → API Keys** (or **Data API**). Copy the **Project URL** and the **anon** / **publishable** key. Both are safe to share; they only allow what the rules from step 2 allow.
2. Put them in [`config.js`](config.js) and push to `main`, or send them to Claude to do it. This is the last time the site needs a deploy for content changes.

## Using it

- Go to `/admin/`, log in, and you'll see two tabs: **Products** and **Site text**.
- **Add a product:** press "Add a product", choose a photo (straight from your phone is fine, it's resized for you), give it a name and a line of description, pick a section, and save.
- **Hide** takes a piece off the site without deleting it. **↑ / ↓** change the order.
- Pick **A new section…** in the Section list to start a new group, such as Bookmarks.
- **Site text** lists every piece of wording on the site, grouped by where it appears. Edit, then press **Save changes**. "Use original" puts back the wording that's written in the page.

## Good to know

- **Free limits:** Supabase's free plan gives 500 MB of data and 1 GB of photo storage. Photos are shrunk to about 200–400 KB each, so that's a few thousand products.
- **Sleeping:** Supabase pauses free projects after a week with no activity. A small GitHub Action (`.github/workflows/keep-supabase-awake.yml`) checks in every three days to stop that. If it ever does pause, the site falls back to the products written in `index.html`, and you can wake the project from the Supabase dashboard.
- **No Claude or Netlify credits are used** by editing products or text. Visitors' browsers load the products straight from Supabase.
