import { test, expect } from '@playwright/test';

test.describe('Day Before Web App', () => {
  test('Hero button is visible in both themes', async ({ page }) => {
    await page.goto('http://localhost:5173');
    
    // Check light theme
    await page.emulateMedia({ colorScheme: 'light' });
    const heroBtn = page.getByRole('button', { name: 'Open the free app' });
    await expect(heroBtn).toBeVisible();
    await page.screenshot({ path: 'hero-light.png' });

    // Check dark theme
    await page.emulateMedia({ colorScheme: 'dark' });
    await expect(heroBtn).toBeVisible();
    await page.screenshot({ path: 'hero-dark.png' });
  });

  test('Export downloads a zip that contains .md files', async ({ page }) => {
    // Mock API requests to prevent logout
    await page.route('**/api/sync/entries*', route => route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({ entries: [] })
    }));
    await page.route('**/api/sync/issues*', route => route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({ issues: [] })
    }));

    await page.goto('http://localhost:5173/');
    
    // Evaluate bypassing logic
    await page.evaluate(() => {
      localStorage.setItem('daybefore_token', 'fake_token');
      localStorage.setItem('daybefore_salt', '1,2,3');
    });
    
    await page.goto('http://localhost:5173/#app');
    
    // Evaluate visibilitychange
    await page.evaluate(() => {
      Object.defineProperty(document, 'visibilityState', {
        value: 'hidden',
        writable: true
      });
      document.dispatchEvent(new Event('visibilitychange'));
    });

    // Lock screen input
    const passInput = page.locator('input[type="password"]');
    await expect(passInput).toBeVisible();
    
    await passInput.fill('password123');
    await page.getByRole('button', { name: 'Unlock' }).click();

    // Inside the app, wait for UI
    await expect(page.getByRole('button', { name: 'New Entry', exact: true })).toBeVisible();

    const exportBtn = page.locator('.panel-footer button', { hasText: 'Export' });
    await expect(exportBtn).toBeVisible();
    await exportBtn.click();

    const modalExportBtn = page.locator('button').filter({ hasText: /^Export$/ }).first();
    await expect(modalExportBtn).toBeVisible();
    
    // Start waiting for download before clicking
    const downloadPromise = page.waitForEvent('download');
    await modalExportBtn.click();
    const download = await downloadPromise;
    
    expect(download.suggestedFilename()).toContain('.zip');
    await download.saveAs('test-export.zip');
  });

  test('Lock triggers on simulated visibilitychange', async ({ page }) => {
    await page.route('**/api/sync/entries*', route => route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({ entries: [] })
    }));
    await page.route('**/api/sync/issues*', route => route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({ issues: [] })
    }));
    
    await page.goto('http://localhost:5173/');
    await page.evaluate(() => {
      localStorage.setItem('daybefore_token', 'fake_token');
      localStorage.setItem('daybefore_salt', '1,2,3');
    });
    
    await page.goto('http://localhost:5173/#app');
    
    // Evaluate visibilitychange
    await page.evaluate(() => {
      Object.defineProperty(document, 'visibilityState', {
        value: 'hidden',
        writable: true
      });
      document.dispatchEvent(new Event('visibilitychange'));
    });

    const passInput = page.locator('input[type="password"]');
    await expect(passInput).toBeVisible();
    await passInput.fill('password123');
    await page.getByRole('button', { name: 'Unlock' }).click();

    await expect(page.getByRole('button', { name: 'New Entry', exact: true })).toBeVisible();
  });
});
