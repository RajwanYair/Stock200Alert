/**
 * Alerts card adapter — CardModule wrapper for the alert history view.
 */
import { renderAlertHistory } from "./alert-history";
import type { CardModule } from "./registry";

const alertsCard: CardModule = {
  mount(container, _ctx) {
    renderAlertHistory(container, []);
    return {};
  },
};

export default alertsCard;
