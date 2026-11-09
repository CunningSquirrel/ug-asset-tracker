# Handover: moving the app from Kyle to the new owner

Kyle is leaving the company. This is the checklist for handing the asset tracker over so it keeps running without him.

> **The one rule:** don't delete Kyle's GitHub repo, images or account until **step 4** is done and the live app has been checked. The live server downloads the app from Kyle's account (`ghcr.io/cunningsquirrel/...`) every time it updates or restarts. If those images vanish first, the app can't update and may not start after a reboot.

Tick each box as you go.

---

## What there is to hand over

| Thing | Where it lives today | Who needs it after |
|---|---|---|
| The code | GitHub repo `CunningSquirrel/ug-asset-tracker` (private) | New owner |
| The built app (images) | `ghcr.io/cunningsquirrel/ug-asset-tracker-web` and `-migrate` (public) | Rebuilt under the new owner's account |
| The live app + database | TrueNAS **10.0.0.11**, app `ug-asset-tracker`, data in `/mnt/SmartHome/Apps/ug-asset-tracker/pgdata` | Stays where it is |
| Public address | Cloudflare: domain `ultimate-group.app`, tunnel `ug-assets` → `http://10.0.0.11:30090` | Company / new owner |
| Passwords | Kyle's Mac: `truenas-secrets-10.0.0.11.local.txt` (not in GitHub) | Company password manager |
| Old test install | TrueNAS **10.0.0.5**, app `ug-asset-tracker` | Can be removed |
| Leftover copy | TrueNAS 10.0.0.11, app `ug-tracking-app` (stopped, broken) | Delete it. It shares the live database folder, so it must never be started |

---

## Step 1: Passwords (Kyle)

- [ ] Copy everything in `truenas-secrets-10.0.0.11.local.txt` into the company password manager:
  - **Postgres password**: needed for Adminer and for editing the TrueNAS YAML.
  - **API (authenticator) password**: needed for editing the TrueNAS YAML.
  - **Russell Ralph's current PIN**.
- [ ] Make sure the new owner has a **TrueNAS admin login** on 10.0.0.11.
- [ ] Revoke any temporary TrueNAS **API keys** you created: TrueNAS → user icon (top right) → **API Keys**.
- [ ] Then delete the `.local.txt` and `.local.yaml` files from Kyle's Mac.

## Step 2: Transfer the GitHub repo (Kyle, then new owner)

Use **Transfer**, not fork. Transfer keeps the full history, and GitHub forwards the old link.

- [ ] If the new owner already has a repo called `ug-asset-tracker` (for example under `mussellralph`), **they rename or delete it first**, otherwise the transfer is refused.
- [ ] Kyle: GitHub → `ug-asset-tracker` → **Settings → General → Danger Zone → Transfer ownership** → enter the new owner's username.
- [ ] New owner: accept the transfer from the email GitHub sends.

## Step 3: Build the app under the new owner (new owner)

The build works out the account name by itself. **No code changes are needed.**

- [ ] In the transferred repo, open the **Actions** tab. If GitHub asks, click **"I understand my workflows, go ahead and enable them"**.
- [ ] Start a build: **Actions → Publish images → Run workflow** (or push any small change to `main`). Wait for the green tick (about 2–4 minutes).
- [ ] Make both new images **public**: GitHub → your profile → **Packages** → `ug-asset-tracker-web` → **Package settings** → **Change visibility → Public**. Repeat for `ug-asset-tracker-migrate`.
  - Prefer them private? Then add a registry login in TrueNAS instead (README-TRUENAS.md, Step 2).

## Step 4: Point TrueNAS at the new images (new owner, or Kyle on his last day)

- [ ] TrueNAS 10.0.0.11 → **Apps** → `ug-asset-tracker` → **Edit**.
- [ ] Change these two lines, replacing `cunningsquirrel` with the new owner's GitHub username **in lowercase**:
  ```yaml
  image: ghcr.io/cunningsquirrel/ug-asset-tracker-migrate:latest
  image: ghcr.io/cunningsquirrel/ug-asset-tracker-web:latest
  ```
  **Change nothing else.** The passwords, ports and `pgdata` path must stay exactly the same, or the app loses its data.
- [ ] **Save**. Wait for the app to show **Running** (`migrate` shows **Exited**, which is normal).

## Step 5: Check it (new owner)

- [ ] Open the app (http://10.0.0.11:30090 and the public Cloudflare address). The staff names appear in the sign-in list.
- [ ] Sign in as a Master Admin. The assets and activity log are all there.
- [ ] TrueNAS → Apps → `ug-asset-tracker` → the `web` container's image now shows the new owner's name.

**Only after all of step 5 passes:**

## Step 6: Clean up (Kyle)

- [ ] Delete Kyle's old images: GitHub → profile → **Packages** → each `ug-asset-tracker-*` → **Package settings → Delete**.
- [ ] Kyle's GitHub account can now be deleted without affecting the app.

## Step 7: Cloudflare (Kyle, before leaving)

The public address runs through **Kyle's Cloudflare account**. If that account goes, the public address stops working (the app still works on the office network).

- [ ] Either invite the new owner to the Cloudflare account (**Manage Account → Members**, role Administrator), or move the `ultimate-group.app` domain to a company Cloudflare account.
- [ ] If the domain moves to a new account: create a new tunnel there, put its token into the TrueNAS **cloudflared** app, and add the public hostname again → `http://10.0.0.11:30090`.
- [ ] Check **domain renewal** is on a company card, not Kyle's.

## Step 8: Tidy up (new owner, any time)

- [ ] Delete `ug-tracking-app` on 10.0.0.11 (stopped, broken, shares the live database folder).
- [ ] Remove the old test install on **10.0.0.5** if no longer needed.
- [ ] Replace `CunningSquirrel` / `cunningsquirrel` with the new owner's name in `README-TRUENAS.md`, `CHANGES.md` and `truenas-app.yaml`.
- [ ] Work through "Still to do" at the end of `CHANGES.md` (own PINs for every staff member, remove SMB/NFS shares on the dataset, and so on).

---

## Making changes after the handover

1. Edit the code (an AI assistant is fine). **Before pushing, check `html/index.html` is still about 4,000 lines long** and doesn't contain phrases like "remains unchanged". AI tools sometimes cut the file short, which is how the staff list once went blank.
2. Test it on a computer with Docker: `docker compose up -d --build` → http://localhost:30080 (Russell Ralph, PIN 4321).
3. Push to `main` → wait for the green tick under **Actions**.
4. TrueNAS → Apps → `ug-asset-tracker` → **Update** (or **Edit → Save**).

**Updates never change staff PINs or delete data.** If every Master Admin is ever locked out, see "PINs and updates" in `CHANGES.md` (`RESET_ADMIN_PIN`).
