const { chromium } = require('playwright');
const { spawn } = require('child_process');
const fs = require('fs');

async function main() {
  console.log("Starting server...");
  const server = spawn('npm', ['run', 'dev', '--', '--port', '5173'], { cwd: 'D:/daybefore-web/app', shell: true });
  
  await new Promise(resolve => setTimeout(resolve, 5000));
  
  console.log("Launching browser...");
  const browser = await chromium.launch();
  const page = await browser.newPage();
  
  console.log("Navigating to design page...");
  await page.goto('http://localhost:5173/#design');
  await page.waitForTimeout(2000);
  
  fs.mkdirSync('D:/daybefore-native/docs/screens', { recursive: true });
  
  console.log("Taking dark theme screenshot...");
  await page.screenshot({ path: 'D:/daybefore-native/docs/screens/design_dark.png', fullPage: true });
  
  console.log("Toggling theme...");
  await page.click('text=Toggle Light');
  await page.waitForTimeout(1000);
  
  console.log("Taking light theme screenshot...");
  await page.screenshot({ path: 'D:/daybefore-native/docs/screens/design_light.png', fullPage: true });
  
  await browser.close();
  server.kill();
  console.log("Done.");
}

main().catch(console.error);
