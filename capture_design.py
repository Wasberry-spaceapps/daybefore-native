import asyncio
import subprocess
import time
from playwright.async_api import async_playwright

async def main():
    # Start Vite server
    server = subprocess.Popen(["npm", "run", "dev", "--", "--port", "5173"], cwd="D:/daybefore-web/app")
    
    # Wait for server to be ready
    time.sleep(5)
    
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page()
        
        # Navigate to the design page
        await page.goto("http://localhost:5173/#design")
        
        # Wait for fonts to load
        await page.wait_for_timeout(2000)
        
        # Take Light Theme screenshot
        import os
        os.makedirs('D:/daybefore-native/docs/screens', exist_ok=True)
        await page.screenshot(path="D:/daybefore-native/docs/screens/design_dark.png", full_page=True)
        
        # Click the toggle button to switch to light theme
        await page.click("text=Toggle Light")
        await page.wait_for_timeout(1000)
        
        # Take Dark Theme screenshot
        await page.screenshot(path="D:/daybefore-native/docs/screens/design_light.png", full_page=True)
        
        await browser.close()
    
    # Kill the server
    server.terminate()
    print("Screenshots captured successfully.")

asyncio.run(main())
