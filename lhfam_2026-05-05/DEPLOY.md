# LHFAM 2026-05-05 — Deploy Notes

This subpath is for **internal team review only** — not indexed, not crawled.

## Contents

- `index.html` — single-page review with sections, lightbox, tabbed bibles, password gate
- `img/` — 4 character bibles (Mason FLUX, Synth FLUX v1, Synth FLUX v2, Mason SDXL rejected)
- `vid/` — 2 validation talking-heads + 8 PiP demos
- `aud/` — Mason reference + 6 Turbo-cloned reaction lines

Total ~47 MB.

## Local preview

From the parent `posixparty.com/` directory:

```bash
python3 -m http.server 8037 --bind 127.0.0.1
# then open http://127.0.0.1:8037/lhfam_2026-05-05/
```

JS-gate passphrase: `havechickenwithjello`

## Deploy to VPS

The site rsyncs via `posixparty.com/deploy.sh`, which excludes `.git/`, `.well-known/`, `archive/`. This subdir gets included automatically.

**Recommended:** add nginx Basic Auth on top of the JS gate so it's not crawlable even if the URL leaks. The JS gate is purely casual UX deterrence — anyone can view-source and grab the passphrase.

### Step 1 — htpasswd file on VPS

```bash
ssh vultr 'sudo apt-get install -y apache2-utils'
ssh vultr 'sudo htpasswd -c /etc/nginx/.lhfam_htpasswd team'
# enter a strong password when prompted; share with team via 1Password / signal
```

### Step 2 — nginx site config

Add this `location` block inside the `posixparty.com` server block (typically `/etc/nginx/sites-available/posixparty.com`):

```nginx
location /lhfam_2026-05-05/ {
    auth_basic "LHFAM team review";
    auth_basic_user_file /etc/nginx/.lhfam_htpasswd;

    # don't let search engines see this even if Basic Auth is bypassed somehow
    add_header X-Robots-Tag "noindex, nofollow, noarchive" always;
}
```

Then reload nginx:

```bash
ssh vultr 'sudo nginx -t && sudo systemctl reload nginx'
```

### Step 3 — robots.txt

Confirm the site root has a `robots.txt` that blocks the path:

```
User-agent: *
Disallow: /lhfam_2026-05-05/
```

### Step 4 — share with team

URL: `https://posixparty.com/lhfam_2026-05-05/`
Basic auth user: `team` (or whatever you set in step 1)
Password: (from step 1, share via secure channel)

The JS gate inside the page asks for `havechickenwithjello` after Basic Auth — that's a one-time-per-session unlock that hides content even if someone gets a screenshot of the URL bar.

## Removing later

When the team review is done and we don't need the page anymore:

```bash
# locally
rm -rf /home/trashh_panda/code/PROJECTS/VULTR_0/sites/posixparty.com/lhfam_2026-05-05/

# on VPS, remove the location block + reload nginx, then re-deploy
ssh vultr 'sudo rm /etc/nginx/.lhfam_htpasswd'
```
