import { Download, Shield, X } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useState } from "react";

const StickyBanner = () => {
  const [isVisible, setIsVisible] = useState(true);

  if (!isVisible) return null;

  return (
    <div className="fixed top-0 left-0 right-0 z-50 gradient-primary py-3 px-4">
      <div className="container flex items-center justify-between gap-4">
        <div className="flex items-center gap-3 flex-1 justify-center">
          <span className="text-lg">🔥</span>
          <p className="text-primary-foreground text-sm md:text-base font-medium">
            Download Match Vibe App & Start Free 1v1 Video Chat Now!
          </p>
        </div>
        <div className="flex items-center gap-3">
          <Button variant="heroOutline" size="sm" className="hidden sm:flex" asChild>
            <a href="/app-release.apk" download="Match-Vibe.apk">
              <Download className="w-4 h-4" />
              Download APK
            </a>
          </Button>
          <div className="hidden md:flex items-center gap-1 text-primary-foreground/80 text-xs">
            <Shield className="w-3 h-3" />
            <span>Safe & Secure</span>
          </div>
          <button
            onClick={() => setIsVisible(false)}
            className="text-primary-foreground/70 hover:text-primary-foreground transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  );
};

export default StickyBanner;
