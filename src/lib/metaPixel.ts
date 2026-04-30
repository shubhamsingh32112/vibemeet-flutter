declare global {
  interface Window {
    fbq?: (...args: unknown[]) => void;
  }
}

export function trackPlayStoreClick(placement: string) {
  // Standard event for optimization (common choice for outbound app install intent)
  window.fbq?.("track", "Lead", { placement });
  // Custom event for easier debugging/segmentation
  window.fbq?.("trackCustom", "PlayStoreClick", { placement });
}

