#!/bin/bash
# Run this after deploying to notify Bing IndexNow of updated pages.
# Usage: bash scripts/ping-indexnow.sh

KEY="a406ceacdad449189fd520c13eed073b"
HOST="daybefore.app"

curl -s -o /dev/null -w "%{http_code}" \
  -X POST "https://api.indexnow.org/indexnow" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d "{
    \"host\": \"$HOST\",
    \"key\": \"$KEY\",
    \"keyLocation\": \"https://$HOST/$KEY.txt\",
    \"urlList\": [
      \"https://daybefore.app/\",
      \"https://daybefore.app/pricing\",
      \"https://daybefore.app/legal\"
    ]
  }"

echo ""
echo "Done. 200 = accepted, 202 = queued OK."
