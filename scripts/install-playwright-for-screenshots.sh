#!/bin/sh
# Chrome extension relay: screenshots need full "playwright", not only playwright-core.
# Docs: https://docs.openclaw.ai/tools/browser — "Playwright requirement"
set -e
ROOT="${OPENCLAW_NPM_ROOT:-$(npm root -g 2>/dev/null)/openclaw}"
if [ ! -f "$ROOT/package.json" ]; then
  echo "Could not find global openclaw at $ROOT. Set OPENCLAW_NPM_ROOT to the openclaw package folder."
  exit 1
fi
echo "Using: $ROOT"
cd "$ROOT"
npm install playwright@1.58.2
npx playwright install chromium
echo "Done. Restart the OpenClaw gateway, then try screenshots with profile chrome again."
