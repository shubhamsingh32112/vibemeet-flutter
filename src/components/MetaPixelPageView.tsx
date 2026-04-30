import { useEffect } from "react";
import { useLocation } from "react-router-dom";

declare global {
  interface Window {
    fbq?: (...args: unknown[]) => void;
  }
}

export default function MetaPixelPageView() {
  const location = useLocation();

  useEffect(() => {
    window.fbq?.("track", "PageView");
  }, [location.pathname, location.search]);

  return null;
}

