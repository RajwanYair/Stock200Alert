/**
 * Settings card adapter — CardModule wrapper for the settings view.
 */
import { renderSettings } from "./settings";
import { loadConfig, saveConfig } from "../core/config";
import { initTheme } from "../ui/theme";
import type { CardModule } from "./registry";

const settingsCard: CardModule = {
  mount(container, _ctx) {
    const config = loadConfig();
    renderSettings(container, config, {
      onThemeChange(theme) {
        saveConfig({ ...loadConfig(), theme });
        initTheme(theme);
      },
      onExport() {
        /* wired by main */
      },
      onImport() {
        /* wired by main */
      },
      onClearWatchlist() {
        /* wired by main */
      },
      onClearCache() {
        /* wired by main */
      },
    });
    return {};
  },
};

export default settingsCard;
