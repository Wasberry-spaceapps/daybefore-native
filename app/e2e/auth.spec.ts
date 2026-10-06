import { test, expect } from '@playwright/test';

test.describe('Authentication & Crypto Envelope', () => {
  test('User can register and gets a recovery key', async ({ page }) => {
    await page.goto('http://localhost:5173/#auth');
    
    // Switch to Register
    await page.click('text=Don\'t have an account? Register');
    
    // Fill form
    const email = `test-${Date.now()}@example.com`;
    await page.fill('input[type="email"]', email);
    await page.fill('input[type="password"]', 'secure-passphrase');
    
    await page.click('button[type="submit"]');
    
    // Should see recovery key modal
    await expect(page.locator('text=Save Your Recovery Key')).toBeVisible({ timeout: 10000 });
    const keyEl = await page.locator('div[style*="monospace"]').textContent();
    expect(keyEl).toMatch(/^([0-9a-f]{4}-){3}[0-9a-f]{4}$/);
    
    // Acknowledge
    await page.click('text=I have saved it');
    await expect(page).toHaveURL('http://localhost:5173/#app');
  });
});
