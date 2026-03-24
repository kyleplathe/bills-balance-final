#!/usr/bin/env bash
# Test Resend delivery for the Weekly Financial Snapshot HTML (same shape as EmailService).
# Usage: chmod +x scripts/test-weekly-snapshot-email.sh && ./scripts/test-weekly-snapshot-email.sh
# Requires in .env.local: RESEND_API_KEY, WEEKLY_SNAPSHOT_TO_EMAIL
# Use RESEND_FROM_EMAIL with a verified domain, or default onboarding@resend.dev for sandbox.

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ -f .env.local ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env.local
  set +a
fi

: "${RESEND_API_KEY:?Set RESEND_API_KEY in .env.local}"

FROM="${RESEND_FROM_EMAIL:-Bills & Balance <onboarding@resend.dev>}"
TO="${WEEKLY_SNAPSHOT_TO_EMAIL:-}"
if [[ -z "$TO" ]]; then
  echo "Set WEEKLY_SNAPSHOT_TO_EMAIL in .env.local to your inbox."
  exit 1
fi

HTML='<!DOCTYPE html><html><body><div style="font-family: -apple-system, BlinkMacSystemFont, Segoe UI, sans-serif; line-height: 1.5; color: #111827;">
<h1 style="margin-bottom: 8px;">Weekly Financial Snapshot</h1>
<p style="margin-top: 0;">Stay a few steps ahead this week.</p>
<h2 style="margin-bottom: 6px;">Bills Due This Week</h2>
<ul style="margin-top: 0;"><li>Rent - $1,650.00 due 2026-03-23</li><li>Electricity - $120.00 due 2026-03-26</li></ul>
<h2 style="margin-bottom: 6px;">Current Ledger Balance</h2>
<p style="font-size: 20px; font-weight: 700; margin-top: 0;">$4,250.00</p>
<p style="font-size: 12px; color: #6b7280;">This is a manual test send from scripts/test-weekly-snapshot-email.sh</p>
</div></body></html>'

export FROM TO HTML
PAYLOAD=$(python3 <<'PY'
import json, os
payload = {
    "from": os.environ["FROM"],
    "to": [os.environ["TO"]],
    "subject": "[TEST] Your Weekly Financial Snapshot",
    "html": os.environ["HTML"],
}
print(json.dumps(payload))
PY
)

HTTP_CODE=$(curl -sS -o /tmp/resend-weekly-test.json -w "%{http_code}" \
  -X POST "https://api.resend.com/emails" \
  -H "Authorization: Bearer ${RESEND_API_KEY}" \
  -H "Content-Type: application/json" \
  --data-binary "$PAYLOAD")

echo "HTTP $HTTP_CODE"
cat /tmp/resend-weekly-test.json
echo ""

if [[ "$HTTP_CODE" -ge 200 && "$HTTP_CODE" -lt 300 ]]; then
  echo "OK — check inbox for: $TO"
else
  exit 1
fi
