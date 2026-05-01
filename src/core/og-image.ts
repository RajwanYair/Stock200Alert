/**
 * OG image generator — produces a social-preview SVG string client-side.
 *
 * Generates an 1200×630 SVG suitable for Open Graph / Twitter Card previews.
 * The SVG encodes the ticker, price, change percent and consensus badge
 * and can be downloaded as an .svg file or converted to a data-URI.
 *
 * Usage:
 *   const svg = generateOgImageSvg({ ticker: "AAPL", price: 189.5, changePercent: 1.23, direction: "BUY" });
 *   downloadSvg(svg, "AAPL-preview.svg");
 *   const uri = svgToDataUri(svg);
 */

export type ConsensusDirection = "BUY" | "SELL" | "HOLD" | "NEUTRAL" | "STRONG_BUY" | "STRONG_SELL";

export interface OgImageOptions {
  /** Ticker symbol (e.g. "AAPL"). */
  readonly ticker: string;
  /** Current price. */
  readonly price?: number;
  /** Price change percent (e.g. 1.23 for +1.23%). */
  readonly changePercent?: number;
  /** Consensus direction badge label. */
  readonly direction?: ConsensusDirection | string;
  /** Company/asset name subtitle. */
  readonly name?: string;
  /** Override the primary brand colour (default: #00d4aa). */
  readonly accentColor?: string;
}

const OG_WIDTH = 1200;
const OG_HEIGHT = 630;
const DEFAULT_ACCENT = "#00d4aa";

function directionColor(direction: string | undefined): string {
  if (!direction) return "#888";
  const d = direction.toUpperCase();
  if (d === "BUY" || d === "STRONG_BUY") return "#22c55e";
  if (d === "SELL" || d === "STRONG_SELL") return "#ef4444";
  return "#f59e0b";
}

function formatPrice(price: number): string {
  return price.toLocaleString("en-US", {
    style: "currency",
    currency: "USD",
    maximumFractionDigits: 2,
  });
}

function formatChangePct(pct: number): string {
  const sign = pct >= 0 ? "+" : "";
  return `${sign}${pct.toFixed(2)}%`;
}

function escapeXml(s: string): string {
  return s
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

/**
 * Generate an OG preview SVG string.
 */
export function generateOgImageSvg(opts: OgImageOptions): string {
  const { ticker, price, changePercent, direction, name, accentColor = DEFAULT_ACCENT } = opts;

  const badgeColor = directionColor(direction);
  const badgeLabel = direction ? escapeXml(direction.replace("_", " ")) : "";
  const priceText = price !== undefined ? formatPrice(price) : "";
  const changePctText = changePercent !== undefined ? formatChangePct(changePercent) : "";
  const changeColor = changePercent !== undefined && changePercent < 0 ? "#ef4444" : "#22c55e";
  const tickerSafe = escapeXml(ticker.toUpperCase());
  const nameSafe = name ? escapeXml(name) : "";

  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${OG_WIDTH}" height="${OG_HEIGHT}" viewBox="0 0 ${OG_WIDTH} ${OG_HEIGHT}">
  <!-- Background -->
  <rect width="${OG_WIDTH}" height="${OG_HEIGHT}" fill="#0d1117"/>
  <!-- Accent bar -->
  <rect x="0" y="${OG_HEIGHT - 8}" width="${OG_WIDTH}" height="8" fill="${escapeXml(accentColor)}"/>
  <!-- Left accent stripe -->
  <rect x="0" y="0" width="8" height="${OG_HEIGHT}" fill="${escapeXml(accentColor)}" opacity="0.6"/>

  <!-- Ticker -->
  <text x="80" y="200" font-family="system-ui, -apple-system, sans-serif" font-size="128"
        font-weight="800" fill="#f0f6fc" letter-spacing="-2">${tickerSafe}</text>

  ${
    nameSafe
      ? `<!-- Company name -->
  <text x="82" y="260" font-family="system-ui, -apple-system, sans-serif" font-size="36"
        font-weight="400" fill="#8b949e">${nameSafe}</text>`
      : ""
  }

  ${
    priceText
      ? `<!-- Price -->
  <text x="82" y="370" font-family="system-ui, -apple-system, sans-serif" font-size="72"
        font-weight="700" fill="#f0f6fc">${escapeXml(priceText)}</text>`
      : ""
  }

  ${
    changePctText
      ? `<!-- Change percent -->
  <text x="82" y="450" font-family="system-ui, -apple-system, sans-serif" font-size="48"
        font-weight="600" fill="${changeColor}">${escapeXml(changePctText)}</text>`
      : ""
  }

  ${
    badgeLabel
      ? `<!-- Consensus badge background -->
  <rect x="820" y="180" width="300" height="100" rx="16" fill="${badgeColor}" opacity="0.15"/>
  <rect x="820" y="180" width="300" height="100" rx="16" fill="none" stroke="${badgeColor}" stroke-width="2"/>
  <!-- Consensus badge label -->
  <text x="970" y="245" font-family="system-ui, -apple-system, sans-serif" font-size="44"
        font-weight="700" fill="${badgeColor}" text-anchor="middle">${badgeLabel}</text>`
      : ""
  }

  <!-- CrossTide branding -->
  <text x="${OG_WIDTH - 40}" y="${OG_HEIGHT - 30}" font-family="system-ui, -apple-system, sans-serif"
        font-size="28" font-weight="600" fill="${escapeXml(accentColor)}" text-anchor="end" opacity="0.8">CrossTide</text>
</svg>`;
}

/**
 * Convert an SVG string to a data URI (for use in img src or background-image).
 */
export function svgToDataUri(svg: string): string {
  // Use base64 to handle all characters safely.
  return `data:image/svg+xml;base64,${btoa(unescape(encodeURIComponent(svg)))}`;
}

/**
 * Trigger a browser download of the SVG string as a .svg file.
 */
export function downloadSvg(svg: string, filename = "og-preview.svg"): void {
  const blob = new Blob([svg], { type: "image/svg+xml" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}
