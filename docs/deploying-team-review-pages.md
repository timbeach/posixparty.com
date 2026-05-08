# Deploying password-protected team review pages on posixparty.com

How to publish a private team review page (e.g. `lhfam_2026-05-07/`) with two layers of access control: a JS passphrase gate (UX) and nginx Basic Auth (real protection).

This pattern was first set up for `lhfam_2026-05-05/` and reused on each subsequent review. Both layers share the same shared secret, currently `havechickenwithjello`.

## TL;DR

```bash
# 1. Stage the new review dir locally
NEW=lhfam_YYYY-MM-DD
cd /home/trashh_panda/code/PROJECTS/VULTR_0/sites/posixparty.com
mkdir -p $NEW/{img,vid,aud}
# … copy assets, write index.html (start from prev review's index.html) …

# 2. Deploy
bash deploy.sh

# 3. Add nginx auth for the new path (once per review)
ssh vultr  # then on the VPS, see "Step 3" below

# 4. Verify
curl -sIo /dev/null -w "no-auth: %{http_code}\n" https://posixparty.com/$NEW/
curl -sIo /dev/null -u team:havechickenwithjello \
  -w "with-auth: %{http_code}\n" https://posixparty.com/$NEW/
# expect: 401 then 200
```

## Anatomy

```
posixparty.com/                # local checkout at ~/code/PROJECTS/VULTR_0/sites/posixparty.com
  deploy.sh                    # rsync the whole tree to vultr:/var/www/posixparty.com
  lhfam_YYYY-MM-DD/
    index.html                 # JS passphrase gate + page content
    img/, vid/, aud/           # assets
```

```
vultr (45.32.216.23):
  /var/www/posixparty.com/lhfam_YYYY-MM-DD/   # rsync target
  /etc/nginx/.lhfam_htpasswd                  # shared htpasswd, one user `team`
  /etc/nginx/sites-available/vultr-2024       # active site config
```

## Step 1 — Build the page locally

Start from the most recent review's `index.html` — the styling, password gate JS, lightbox, and grid builder are reusable. Copy and edit only the content sections.

The password-gate boilerplate is at the bottom of `index.html`:

```html
<script>
  const PWD = 'havechickenwithjello';
  const gate = document.getElementById('gate');
  const pwd = document.getElementById('pwd');
  // …tryUnlock(), sessionStorage…
</script>
```

Don't change `PWD` unless you also rotate the htpasswd entry on the VPS (see "Rotating the password" below).

Sanity check before deploy:

```bash
# Verify all referenced static assets exist
python3 -c "
from html.parser import HTMLParser
class V(HTMLParser):
    def __init__(self):
        super().__init__(); self.refs = []
    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        for k in ('src', 'href'):
            if k in a and not a[k].startswith(('http', '//', '#', '../')):
                self.refs.append(a[k])
v = V(); v.feed(open('lhfam_YYYY-MM-DD/index.html').read())
import os
for r in v.refs:
    p = os.path.join('lhfam_YYYY-MM-DD', r)
    print('OK ' if os.path.exists(p) else 'MISSING ', p)
" | grep -v ^OK
```

Local preview (no auth in this mode — JS gate only):

```bash
python3 -m http.server 8037 --bind 127.0.0.1
# open http://127.0.0.1:8037/lhfam_YYYY-MM-DD/
```

## Step 2 — Deploy

`deploy.sh` is a one-line rsync that picks up everything new automatically:

```bash
cd /home/trashh_panda/code/PROJECTS/VULTR_0/sites/posixparty.com
bash deploy.sh
```

It rsyncs the entire `posixparty.com/` tree to `vultr:/var/www/posixparty.com/`, excluding `.git`, `.well-known`, `archive`. New review dirs come along automatically.

## Step 3 — Add nginx Basic Auth for the new path

The htpasswd file already exists at `/etc/nginx/.lhfam_htpasswd` with user `team`. We just need a new `location` block in the posixparty server block.

The posixparty server block lives in `/etc/nginx/sites-available/vultr-2024` (the `default` and `vultr-2024_CLEAN-COPY` files exist but are not the active config — `sites-enabled/vultr-2024` is the real one).

**Recommended workflow** (back up first, edit, test, reload):

```bash
ssh vultr

# Back up
sudo cp /etc/nginx/sites-available/vultr-2024 \
        /etc/nginx/sites-available/vultr-2024.bk.$(date +%F)_pre-$NEW

# Open the file and add this block immediately above the existing
# `location /lhfam_YYYY-MM-DD/ {` line:
sudo nano /etc/nginx/sites-available/vultr-2024
```

Block to add (literal — do NOT escape `$uri`):

```nginx
    location /lhfam_YYYY-MM-DD/ {
        auth_basic "LHFAM team review";
        auth_basic_user_file /etc/nginx/.lhfam_htpasswd;
        add_header X-Robots-Tag "noindex, nofollow, noarchive" always;
        try_files $uri $uri/ =404;
    }
```

⚠️ **Common gotcha**: if you script the insertion via `ssh vultr 'sudo python3 -c "..."'` or a sed inside a heredoc, the `$uri` can get shell-escaped to `\$uri` in the resulting file. nginx will syntax-check OK and then return 404 on every request. Always grep the resulting block to confirm `$uri` is literal:

```bash
sudo grep -A5 "/lhfam_YYYY-MM-DD" /etc/nginx/sites-available/vultr-2024
# you should see:  try_files $uri $uri/ =404;
# NOT:             try_files \$uri \$uri/ =404;
```

Test + reload:

```bash
sudo nginx -t                    # config syntax check
sudo systemctl reload nginx
```

Verify (from anywhere):

```bash
curl -sIo /dev/null -w "no-auth: %{http_code}\n" \
  https://posixparty.com/lhfam_YYYY-MM-DD/
curl -sIo /dev/null -u team:havechickenwithjello \
  -w "with-auth: %{http_code}\n" \
  https://posixparty.com/lhfam_YYYY-MM-DD/
```

Expected: `no-auth: 401` then `with-auth: 200`.

If you get `with-auth: 404`, it's almost always the `$uri` escape bug above.

## Rotating the password

If the shared password leaks, rotate both the JS gate and htpasswd in lockstep:

```bash
# Pick a new passphrase, e.g. "newphraseplease"

# 1. Update PWD in every lhfam_*/index.html and re-deploy
grep -l "havechickenwithjello" lhfam_*/index.html | xargs sed -i 's/havechickenwithjello/newphraseplease/g'
bash deploy.sh

# 2. Rotate htpasswd on VPS
ssh vultr 'sudo htpasswd -b /etc/nginx/.lhfam_htpasswd team newphraseplease'
# (no nginx reload needed — auth_basic re-reads htpasswd per request)

# 3. Tell the team via Signal / 1Password
```

## Why two layers?

- **JS gate**: friendly UX. Anyone who knows the URL gets the gate immediately. View-source reveals the passphrase (it's casual deterrence, not security).
- **nginx Basic Auth**: the actual access control. Browser shows a native auth prompt; without credentials the response is HTTP 401 and no asset bytes are delivered.

This means even if the URL leaks, asset URLs (e.g. `lhfam_*/vid/spliced/*.mp4`) are still 401-protected — they aren't reachable without the password. Good enough for internal team review.

## Notes

- `robots.txt` at `/var/www/posixparty.com/robots.txt` already disallows `/lhfam_*` paths. The `X-Robots-Tag` header on the location block is belt-and-suspenders.
- The htpasswd file is owned `root:www-data 640`. Keep that ownership if you ever recreate it.
- The `deploy.sh` rsync also pulls down the existing `lhfam_*` archive dirs that live in `/var/www/posixparty.com/`. Local dirs and remote dirs should stay in sync — don't delete review dirs locally without also cleaning remote.
