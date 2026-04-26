/**
 * Consensus card adapter — CardModule wrapper for the consensus view.
 */
import { renderConsensus } from "./consensus";
import type { CardModule } from "./registry";

const consensusCard: CardModule = {
  mount(container, ctx) {
    const ticker = ctx.params["symbol"] ?? "";
    renderConsensus(container, ticker, null);
    return {
      update(newCtx): void {
        const t = newCtx.params["symbol"] ?? "";
        renderConsensus(container, t, null);
      },
    };
  },
};

export default consensusCard;
