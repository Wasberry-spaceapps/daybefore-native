Write-Host "Testing AI visibility for daybefore.app..."
$response = Invoke-WebRequest -Uri "https://daybefore.app" -UseBasicParsing
if ($response.Content -match "journal") {
  Write-Host "SUCCESS: Server-rendered content is visible to crawlers."
} else {
  Write-Host "FAILURE: Could not find 'journal' in raw curl output."
}
