#!/bin/bash
# Snapshot the family tree data from Supabase into this repo.
# Usage: ./backup.sh   (then review and git push the changes)
#
# Set these in your environment (or create a .env file and source it first):
#   export SUPABASE_URL="https://czvjsuhsubhffostxhwm.supabase.co"
#   export SUPABASE_KEY="<your publishable key>"
set -euo pipefail

SUPABASE_URL="${SUPABASE_URL:-}"
SUPABASE_KEY="${SUPABASE_KEY:-}"
TREE_ID="${TREE_ID:-famiglia-principale}"

if [[ -z "$SUPABASE_URL" || -z "$SUPABASE_KEY" ]]; then
  echo "Error: SUPABASE_URL and SUPABASE_KEY must be set."
  echo "Copy .env.example to .env, fill in the values, and run: source .env && ./backup.sh"
  exit 1
fi

cd "$(dirname "$0")"

curl -s "${SUPABASE_URL}/rest/v1/trees?id=eq.${TREE_ID}&select=data" \
  -H "apikey: ${SUPABASE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_KEY}" \
  | python3 -c "import sys,json; print(json.dumps(json.load(sys.stdin)[0]['data'], indent=2, ensure_ascii=False))" \
  > albero-famiglia.json

echo "Saved snapshot to albero-famiglia.json"
echo "Run: git add albero-famiglia.json && git commit -m 'Update family tree snapshot' && git push"
