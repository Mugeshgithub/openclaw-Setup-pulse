#!/bin/sh
# Generic site pulse — URL from file or env (avoids LLMs substituting wrong hosts in inline curl).
set -e
W="${OPENCLAW_WORKSPACE:-$HOME/.openclaw/workspace}"
URL_FILE="${SITE_PULSE_URL_FILE:-$W/.site-pulse-url}"
URL="${SITE_PULSE_URL:-}"
if [ -z "$URL" ] && [ -f "$URL_FILE" ]; then
  URL=$(head -n 1 "$URL_FILE" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
fi
case "$URL" in
  ""|*"CHANGEME"*)
    echo "site-pulse: no valid URL." >&2
    echo "Create one line in: $URL_FILE" >&2
    echo "  echo 'https://your-site.com/' > \"$URL_FILE\"" >&2
    echo "Or run: SITE_PULSE_URL='https://yoursite.com/' $0" >&2
    exit 1
    ;;
esac
printf 'url=%s\n' "$URL"
curl -sS -o /dev/null -w "http_code=%{http_code}\ntime_total_s=%{time_total}\n" "$URL"
