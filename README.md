# OpenClaw site pulse template

**Repo:** [github.com/Mugeshgithub/openclaw-Setup-pulse](https://github.com/Mugeshgithub/openclaw-Setup-pulse)  
(If you rename the repo again, use the green **Code** button on GitHub — the clone URL stays correct.)

```bash
git clone https://github.com/Mugeshgithub/openclaw-Setup-pulse.git
cd openclaw-Setup-pulse
```

A **no-code template** (copy files + edit config) to run **[OpenClaw](https://github.com/openclaw/openclaw)** with **WhatsApp** and a reusable **site pulse** skill (HTTP check + optional macOS “open in browser”). There is **no** application-specific domain or product baked in: you set **any** URL in `.site-pulse-url`.

### How useful is this for other people?

**Good fit** if someone already uses (or plans to use) OpenClaw and wants:

- A **ready-made agent skill** so the model runs a **fixed script** instead of improvising `curl` with the wrong host  
- **WhatsApp or CLI** as the interface (“is my site up?”, “open it in my browser”)  
- A **short checklist** (install OpenClaw, WhatsApp linking, optional browser) in one place next to the skill

**Not** a full monitoring platform (no dashboards, on-call rotations, or multi-region probes). It’s a **small, reusable pattern** — easy to fork and point at any URL or extend with your own skills.

---

## Do I need to write code?

**No.** You need:

- **Node.js ≥ 22** on the machine that runs the gateway (usually your Mac)
- A few **terminal commands** (install OpenClaw, copy files, edit JSON)
- **One text file** with your site URL (`.site-pulse-url`)

Optional: change the skill wording in `SKILL.md` after you copy it — still no programming required.

---

## Part A — Install OpenClaw

1. **Install Node 22+** (e.g. from [nodejs.org](https://nodejs.org/) or Homebrew).

2. **Install OpenClaw globally:**

   ```bash
   npm install -g openclaw@latest
   ```

3. **Run the onboarding wizard** (creates `~/.openclaw`, model auth, optional gateway daemon):

   ```bash
   openclaw onboard --install-daemon
   ```

4. **Official docs** (deeper reference): [docs.openclaw.ai](https://docs.openclaw.ai/) · [Getting started](https://docs.openclaw.ai/)

---

## Part B — Install this template into your workspace

Default workspace is **`~/.openclaw/workspace`**. If yours differs, set **`OPENCLAW_WORKSPACE`** when running the script, or edit paths in the skill.

```bash
# From the cloned repo:
cp -R workspace/skills/site-pulse ~/.openclaw/workspace/skills/
mkdir -p ~/.openclaw/workspace/scripts
cp workspace/scripts/site-pulse-curl.sh ~/.openclaw/workspace/scripts/
chmod +x ~/.openclaw/workspace/scripts/site-pulse-curl.sh
cp workspace/.site-pulse-url.example ~/.openclaw/workspace/.site-pulse-url
```

**Edit** `~/.openclaw/workspace/.site-pulse-url` — **one line**, your real URL, e.g.:

```text
https://yourdomain.com/
```

Optionally merge **`workspace/TOOLS.md.example`** into **`~/.openclaw/workspace/TOOLS.md`**.

**Restart the gateway** after changes (macOS example):

```bash
launchctl kickstart -k "gui/$(id -u)/ai.openclaw.gateway"
```

---

## Part C — Browser (optional, for screenshots / page checks)

In **`~/.openclaw/openclaw.json`**, ensure browser is enabled (merge with your existing JSON):

```json
"browser": {
  "enabled": true,
  "defaultProfile": "openclaw",
  "headless": false
}
```

Then restart the gateway. Details: [Browser tool](https://docs.openclaw.ai/tools/browser).

### Does this only work with one browser or one website?

**No.** Two different things:

| What | Works how |
|------|-----------|
| **“Open in my browser”** (macOS) | The skill runs `open "https://…"`, which opens the URL in **whatever app is your system default browser** — Safari, Chrome, Brave, Edge, etc. You choose that in **System Settings → Desktop & Dock → Default web browser** (macOS). |
| **OpenClaw browser / screenshots** | OpenClaw drives its own **managed browser profile** (see upstream docs — often Chromium / Playwright). That is **not** the same as your daily Safari/Chrome unless you wire extension relay yourself. It still loads **any URL** you configure in `.site-pulse-url`; nothing is locked to a single site. |

The **HTTP pulse** (`curl` in the script) does not use a browser at all — it only needs the URL in `.site-pulse-url`.

---

## Part D — WhatsApp

1. **Edit** **`~/.openclaw/openclaw.json`** — under **`channels.whatsapp`**, set at least:
   - **`allowFrom`**: your number in **E.164** (e.g. `+15551234567`)
   - **`dmPolicy`**: `"allowlist"` or `"pairing"` (pairing is safer for unknown senders)
   - **`selfChatMode`: `true`** only if you use **the same WhatsApp account** as the bot and chat with yourself

   Example shape (adjust values):

   ```json
   "channels": {
     "whatsapp": {
       "dmPolicy": "allowlist",
       "selfChatMode": false,
       "allowFrom": ["+15551234567"]
     }
   }
   ```

2. **Link WhatsApp Web** (QR), with gateway **stopped** if the CLI asks you to:

   ```bash
   openclaw channels login --channel whatsapp
   ```

   On your phone: **WhatsApp → Settings → Linked devices → Link a device** → scan the QR.

3. **Pairing** (if you use `dmPolicy: "pairing"`): approve from terminal:

   ```bash
   openclaw pairing list whatsapp
   openclaw pairing approve whatsapp <CODE>
   ```

4. **Start / keep the gateway running** (LaunchAgent if you used `--install-daemon`):

   ```bash
   openclaw channels status
   openclaw gateway status
   ```

5. **WhatsApp channel docs:** [WhatsApp](https://docs.openclaw.ai/channels/whatsapp) (paths may vary; search “OpenClaw WhatsApp” if the link moves).

---

## Part E — Test

**Terminal** (always run from a folder that exists, e.g. `cd ~`):

```bash
cd ~
openclaw agent --agent main --message "Run site pulse: execute bash $HOME/.openclaw/workspace/scripts/site-pulse-curl.sh and summarize the three lines."
```

**WhatsApp:** send something like *“Run site pulse”* or *“Check if my site is up”* (wording may vary; the skill describes triggers).

---

## What’s in this repo

| Path | Purpose |
|------|--------|
| `workspace/skills/site-pulse/SKILL.md` | Agent skill (copy to `~/.openclaw/workspace/skills/site-pulse/`) |
| `workspace/scripts/site-pulse-curl.sh` | HTTP pulse script |
| `workspace/.site-pulse-url.example` | Template → copy to **`.site-pulse-url`** and edit |
| `workspace/TOOLS.md.example` | Optional notes merged into `TOOLS.md` |
| `scripts/install-playwright-for-screenshots.sh` | Optional: Playwright for **Chrome extension relay** screenshots |

---

## Troubleshooting

| Issue | What to do |
|-------|------------|
| **`ENOENT … uv_cwd`** | Your shell `cd`’d into a **deleted folder**. Run **`cd ~`**, then try again. |
| **`~/.openclaw` missing** after rename | Symlink: `ln -sfn "/path/to/your/folder" ~/.openclaw` |
| **WhatsApp media / `1008` device token** | Match **`gateway.auth.token`** in **`openclaw.json`** with **`OPENCLAW_GATEWAY_TOKEN`** in **`~/Library/LaunchAgents/ai.openclaw.gateway.plist`**, restart gateway. [Issue #18274](https://github.com/openclaw/openclaw/issues/18274) |
| **Screenshots** | Managed profile: `openclaw browser --browser-profile openclaw screenshot`. Extension relay may need Playwright — see script in **`scripts/`** and [browser docs](https://docs.openclaw.ai/tools/browser). |

---

## License

MIT — see [LICENSE](LICENSE).

OpenClaw itself: [github.com/openclaw/openclaw](https://github.com/openclaw/openclaw).
