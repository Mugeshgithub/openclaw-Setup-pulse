---
name: site-pulse
description: Quick HTTP health check for a URL you configure (site pulse). Use when the user asks to "pulse", "check the site", "is it up", "site status", or similar. On macOS, can open the same URL in the default browser when they ask to "open in my browser". Always run the workspace script for curl — do not hand-type curl URLs.
---

# Site pulse (generic)

## Where your URL lives

1. **File (recommended):** `$HOME/.openclaw/workspace/.site-pulse-url` — **one line**, your full URL, e.g. `https://yourdomain.com/`
2. **Optional:** `TOOLS.md` → section **### Site pulse** — same URL for humans + agent context
3. **Override:** env `SITE_PULSE_URL` for a single run

If none is set, the **script** exits with setup instructions — do not invent a URL.

## HTTP check (always use the script)

Models often paste wrong URLs into `curl`. Run **only**:

```bash
bash "$HOME/.openclaw/workspace/scripts/site-pulse-curl.sh"
```

If the workspace path differs, use the path from **`agents.defaults.workspace`** in `openclaw.json`.

Parse **`url=`**, **`http_code=`**, **`time_total_s=`** from stdout.

## Open in the user’s default browser (macOS)

When they ask **“open the site”**, **“open in my browser”**, **“Safari / Chrome”**:

1. Read the first line of **`$HOME/.openclaw/workspace/.site-pulse-url`** (or `TOOLS.md` / user message).
2. Run:

```bash
open "PASTE_URL_HERE"
```

Then optionally run **`site-pulse-curl.sh`** and summarize.

## Browser tool (optional)

After the script, you may use the **browser** tool on the same URL for title/visible text. Do not log in unless asked.

## Reply format

- Status: OK / DEGRADED / DOWN / UNKNOWN  
- URL checked  
- Short bullets  
- One “next step” if degraded  

## Safety

Read-only checks unless the user asks otherwise.
