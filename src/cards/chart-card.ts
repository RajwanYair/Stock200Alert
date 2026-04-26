/**
 * Chart card adapter — CardModule wrapper for the chart view.
 */
import { renderChart } from "./chart";
import type { CardModule } from "./registry";

const chartCard: CardModule = {
  mount(container, ctx) {
    const ticker = ctx.params["symbol"] ?? "";
    renderChart(container, { ticker, candles: [] });
    return {
      update(newCtx): void {
        const t = newCtx.params["symbol"] ?? "";
        renderChart(container, { ticker: t, candles: [] });
      },
    };
  },
};

export default chartCard;
