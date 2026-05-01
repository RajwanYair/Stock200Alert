/**
 * Chart card adapter — CardModule wrapper for the chart view.
 *
 * Renders OHLC table and provides a "Run Backtest" action
 * that executes off the main thread via compute Worker.
 */
import { renderChart } from "./chart";
import { runBacktestAsync } from "../core/backtest-worker";
import { fetchTickerData } from "../core/data-service";
import { showToast } from "../ui/toast";
import type { CardModule, CardContext } from "./registry";
import type { BacktestConfig } from "../domain/backtest-engine";

function defaultBacktestConfig(ticker: string): BacktestConfig {
  return {
    ticker,
    initialCapital: 10_000,
    methods: ["RSI", "MACD", "Bollinger"],
    windowSize: 50,
  };
}

function renderBacktestUI(container: HTMLElement, ticker: string): void {
  let section = container.querySelector<HTMLElement>(".backtest-section");
  if (!section) {
    section = document.createElement("div");
    section.className = "backtest-section";
    container.appendChild(section);
  }

  section.innerHTML = `
    <button class="btn btn-sm" id="btn-run-backtest" ${!ticker ? "disabled" : ""}>
      Run Backtest (Worker)
    </button>
    <div id="backtest-result" class="backtest-result"></div>
  `;

  const btn = section.querySelector<HTMLButtonElement>("#btn-run-backtest")!;
  const resultDiv = section.querySelector<HTMLElement>("#backtest-result")!;

  btn.addEventListener("click", () => {
    if (!ticker) return;
    btn.disabled = true;
    btn.textContent = "Running…";
    resultDiv.textContent = "";

    void (async () => {
      try {
        const data = await fetchTickerData(ticker);
        if (!data.candles || data.candles.length < 30) {
          resultDiv.textContent = "Insufficient data (need 30+ candles).";
          return;
        }
        const t0 = performance.now();
        const result = await runBacktestAsync(defaultBacktestConfig(ticker), data.candles);
        const elapsed = (performance.now() - t0).toFixed(0);

        resultDiv.innerHTML = `
          <table class="mini-table">
            <tr><td>Trades</td><td>${result.trades.length}</td></tr>
            <tr><td>Total Return</td><td>${result.totalReturnPercent.toFixed(2)}%</td></tr>
            <tr><td>Win Rate</td><td>${(result.winRate * 100).toFixed(1)}%</td></tr>
            <tr><td>Max Drawdown</td><td>${(result.maxDrawdown * 100).toFixed(2)}%</td></tr>
            <tr><td>Computed in</td><td>${elapsed} ms (Worker)</td></tr>
          </table>
        `;
        showToast({ message: `Backtest done: ${result.trades.length} trades in ${elapsed}ms`, type: "success" });
      } catch (err) {
        resultDiv.textContent = `Error: ${(err as Error).message}`;
        showToast({ message: "Backtest failed", type: "error" });
      } finally {
        btn.disabled = false;
        btn.textContent = "Run Backtest (Worker)";
      }
    })();
  });
}

const chartCard: CardModule = {
  mount(container, ctx) {
    const ticker = ctx.params["symbol"] ?? "";
    renderChart(container, { ticker, candles: [] });
    renderBacktestUI(container, ticker);
    return {
      update(newCtx: CardContext): void {
        const t = newCtx.params["symbol"] ?? "";
        renderChart(container, { ticker: t, candles: [] });
        renderBacktestUI(container, t);
      },
    };
  },
};

export default chartCard;
