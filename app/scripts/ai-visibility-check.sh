#!/bin/bash
URL="https://daybefore.app"

AGENTS=(
  "OAI-SearchBot"
  "ChatGPT-User"
  "GPTBot"
  "Claude-SearchBot"
  "Claude-User"
  "ClaudeBot"
  "PerplexityBot"
  "Perplexity-User"
  "Googlebot"
  "bingbot"
  "Applebot"
)

echo "# AI Visibility Check" > ../docs/AI_VISIBILITY.md
echo "Ran at $(date)" >> ../docs/AI_VISIBILITY.md
echo "" >> ../docs/AI_VISIBILITY.md
echo "| Agent | Status | Has Content | Challenge |" >> ../docs/AI_VISIBILITY.md
echo "|---|---|---|---|" >> ../docs/AI_VISIBILITY.md

for agent in "${AGENTS[@]}"; do
  RES=$(curl -s -A "$agent" -w "%{http_code}" "$URL")
  STATUS=${RES: -3}
  BODY=${RES:0:${#RES}-3}
  
  HAS_CONTENT="No"
  if echo "$BODY" | grep -qi "private journal"; then
    HAS_CONTENT="Yes"
  fi
  
  CHALLENGE="No"
  if echo "$BODY" | grep -qi "cloudflare"; then
    CHALLENGE="Maybe"
  fi
  
  echo "| $agent | $STATUS | $HAS_CONTENT | $CHALLENGE |" >> ../docs/AI_VISIBILITY.md
done

cat ../docs/AI_VISIBILITY.md
