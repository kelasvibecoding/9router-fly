# 9router-fly

Deploy **9router** to **Fly.io** with persistent storage, using a clean image (no preloaded seed data).

Created by **kelasvibecoding (KVC)**.

---

## What is this project?

`9router-fly` is a Fly.io-ready deployment wrapper for [9router](https://github.com/decolua/9router).  
This repository contains:

- A production `Dockerfile` for building and running 9router
- `fly.toml` configuration for Fly.io app/service settings
- A startup script (`scripts/start.sh`) that ensures runtime data directory exists
- Persistent data setup via Fly Volume mounted at `/data`

This means your app data survives redeploys/restarts as long as the volume remains attached.

---

## Prerequisites

- A Fly.io account
- `flyctl` installed and authenticated

```bash
fly auth login
```

---

## 1) Configure app name

Edit `fly.toml`:

- Change `app = "diyrouter"` to your own app name
- Update `NEXT_PUBLIC_BASE_URL` to match your app URL (for example `https://your-app-name.fly.dev`)

---

## 2) Create Fly app

You can create an app explicitly:

```bash
fly apps create <app-name>
```

Or let Fly create one during first deploy (explicit create is recommended for predictable naming).

---

## 3) Create persistent volume (required)

Create a volume named `data` in the same region as your app (example: `sin`):

```bash
fly volumes create data --region sin --size 1 --app <app-name>
```

Notes:

- Volume name should match `source = "data"` in `fly.toml`
- Increase `--size` if you need more storage

---

## 4) Deploy

From this repository root:

```bash
fly deploy -a <app-name>
```

---

## 5) Verify deployment

```bash
fly status -a <app-name>
fly logs -a <app-name>
```

Open in browser:

- Dashboard: `https://<app-name>.fly.dev/dashboard`
- API base: `https://<app-name>.fly.dev/v1`

---

## Runtime data location

- Persistent data directory: `/data/.9router`
- Mounted from Fly Volume: `data`
- No seed files are bundled in this repo/image

---

## Useful operations

### Restart app

```bash
fly machine restart -a <app-name>
```

### Check attached volumes

```bash
fly volumes list -a <app-name>
```

### Scale memory/CPU (if needed)

Adjust VM settings in `fly.toml`, then redeploy:

```bash
fly deploy -a <app-name>
```

---

## Security notes

- Do **not** commit API keys or credentials into this repository.
- Configure providers/secrets through the 9router dashboard after deployment.
- If needed, use Fly secrets for sensitive environment variables:

```bash
fly secrets set KEY=VALUE -a <app-name>
```

---

Built and maintained by **kelasvibecoding (KVC)**.