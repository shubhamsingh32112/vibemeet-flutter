import { useEffect, useRef, useState } from "react";
import { Button } from "@/components/ui/button";
import { GooglePlayIcon } from "@/components/icons/GooglePlayIcon";
import { PLAY_STORE_URL } from "@/lib/constants";
import { trackPlayStoreClick } from "@/lib/metaPixel";

const COUNTDOWN_SECONDS = 5;

const PlayStoreRedirectOverlay = () => {
  const [secondsLeft, setSecondsLeft] = useState(COUNTDOWN_SECONDS);
  const hasRedirected = useRef(false);

  const redirectToPlayStore = (placement: string) => {
    if (hasRedirected.current) return;
    hasRedirected.current = true;
    trackPlayStoreClick(placement);
    window.location.replace(PLAY_STORE_URL);
  };

  useEffect(() => {
    if (secondsLeft <= 0) {
      redirectToPlayStore("countdown_overlay_auto");
      return;
    }

    const timer = setTimeout(() => setSecondsLeft((s) => s - 1), 1000);
    return () => clearTimeout(timer);
  }, [secondsLeft]);

  const handleOpenNow = () => {
    redirectToPlayStore("countdown_overlay_manual");
  };

  return (
    <div className="fixed inset-0 z-[60] flex items-center justify-center bg-black/70 p-4">
      <div className="bg-card rounded-2xl shadow-glow border border-border p-8 max-w-md w-full text-center animate-slide-up">
        <p className="text-lg font-medium text-muted-foreground mb-2">Opening Play Store in</p>
        <p
          className="text-7xl font-extrabold text-primary tabular-nums mb-8"
          aria-live="polite"
          aria-label={`${secondsLeft} seconds remaining`}
        >
          {secondsLeft}
        </p>
        <p className="text-sm text-muted-foreground mb-4">If you don&apos;t want to wait</p>
        <Button variant="hero" size="xl" className="w-full" onClick={handleOpenNow}>
          <GooglePlayIcon className="w-5 h-5" />
          Open Play Store
        </Button>
      </div>
    </div>
  );
};

export default PlayStoreRedirectOverlay;
