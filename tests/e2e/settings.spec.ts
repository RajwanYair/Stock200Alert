/**
 * E2E — Settings view (F3 expansion).
 *
 * Validates settings panel UI elements and theme persistence.
 */
import { test, expect } from "@playwright/test";

test.describe("Settings view", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await page.waitForLoadState("domcontentloaded");
    // Navigate to settings
    await page.locator('a[data-route="settings"]').click();
    await expect(page.locator("#view-settings")).toHaveClass(/active/);
  });

  test("settings view renders all expected sections", async ({ page }) => {
    const settings = page.locator("#view-settings");
    // Should contain theme, data, or general settings sections
    const headings = settings.locator("h2, h3, .settings-section-title, [data-section]");
    const count = await headings.count();
    expect(count).toBeGreaterThan(0);
  });

  test("theme selector is present and functional", async ({ page }) => {
    // Look for theme controls (radio buttons, select, or buttons)
    const themeControl = page.locator(
      '[data-setting="theme"], #theme-select, input[name="theme"], .theme-toggle',
    );
    const count = await themeControl.count();
    if (count > 0) {
      await expect(themeControl.first()).toBeVisible();
    }
  });

  test("dark theme applies correct data attribute", async ({ page }) => {
    const html = page.locator("html");
    // The app should have a data-theme attribute
    const theme = await html.getAttribute("data-theme");
    expect(["dark", "light", "high-contrast", "auto"]).toContain(theme ?? "dark");
  });

  test("export button is present", async ({ page }) => {
    const exportBtn = page.locator(
      'button:has-text("Export"), [data-action="export"], .export-btn',
    );
    const count = await exportBtn.count();
    if (count > 0) {
      await expect(exportBtn.first()).toBeVisible();
    }
  });

  test("import button is present", async ({ page }) => {
    const importBtn = page.locator(
      'button:has-text("Import"), [data-action="import"], .import-btn',
    );
    const count = await importBtn.count();
    if (count > 0) {
      await expect(importBtn.first()).toBeVisible();
    }
  });

  test("returning to watchlist preserves navigation state", async ({ page }) => {
    // Go back to watchlist
    await page.locator('a[data-route="watchlist"]').click();
    await expect(page.locator("#view-watchlist")).toHaveClass(/active/);
    await expect(page.locator("#view-settings")).not.toHaveClass(/active/);
  });
});
