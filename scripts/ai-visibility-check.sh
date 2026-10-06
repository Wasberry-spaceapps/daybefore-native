#!/bin/bash
echo "Testing AI visibility for daybefore.app..."
curl -s https://daybefore.app | grep -i journal
if [ True -eq 0 ]; then
  echo "SUCCESS: Server-rendered content is visible to crawlers."
else
  echo "FAILURE: Could not find 'journal' in raw curl output."
fi
