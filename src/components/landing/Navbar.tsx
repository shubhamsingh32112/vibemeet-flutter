import { Download, Video, Menu, X } from "lucide-react";
import { Button } from "@/components/ui/button";
import { PLAY_STORE_URL } from "@/lib/constants";
import { useState } from "react";
import { GooglePlayIcon } from "@/components/icons/GooglePlayIcon";
import { trackPlayStoreClick } from "@/lib/metaPixel";

const Navbar = () => {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  return (
    <nav className="fixed top-[60px] left-0 right-0 z-40 bg-card/80 backdrop-blur-xl border-b border-border/50">
      <div className="container flex items-center justify-between h-16 px-4">
        {/* Logo */}
        <a href="#" className="flex items-center gap-2">
          <div className="w-10 h-10 rounded-xl gradient-primary flex items-center justify-center shadow-soft">
            <Video className="w-5 h-5 text-primary-foreground" />
          </div>
          <span className="text-xl font-bold text-gradient">Match Vibe</span>
        </a>

        {/* Desktop Navigation */}
        <div className="hidden md:flex items-center gap-8">
          <a href="#features" className="text-muted-foreground hover:text-foreground transition-colors font-medium">
            Features
          </a>
          <a href="#how-it-works" className="text-muted-foreground hover:text-foreground transition-colors font-medium">
            How It Works
          </a>
          <a href="#faq" className="text-muted-foreground hover:text-foreground transition-colors font-medium">
            FAQ
          </a>
        </div>

        {/* Desktop CTA */}
        <div className="hidden md:flex items-center gap-3">
          <Button variant="outline" size="sm" asChild>
            <a
              href={PLAY_STORE_URL}
              target="_blank"
              rel="noopener noreferrer"
              onClick={() => trackPlayStoreClick("navbar_desktop_outline")}
            >
              <GooglePlayIcon className="w-4 h-4" />
              Google Play
            </a>
          </Button>
          <Button variant="hero" size="sm" asChild>
            <a
              href={PLAY_STORE_URL}
              target="_blank"
              rel="noopener noreferrer"
              onClick={() => trackPlayStoreClick("navbar_desktop_primary")}
            >
              <Video className="w-4 h-4" />
              Download App
            </a>
          </Button>
        </div>

        {/* Mobile Menu Button */}
        <button
          className="md:hidden p-2 text-foreground"
          onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
        >
          {isMobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
        </button>
      </div>

      {/* Mobile Menu */}
      {isMobileMenuOpen && (
        <div className="md:hidden absolute top-full left-0 right-0 bg-card border-b border-border shadow-card z-50">
          <div className="container py-4 flex flex-col gap-4">
            <a href="#features" className="text-foreground font-medium py-2" onClick={() => setIsMobileMenuOpen(false)}>
              Features
            </a>
            <a href="#how-it-works" className="text-foreground font-medium py-2" onClick={() => setIsMobileMenuOpen(false)}>
              How It Works
            </a>
            <a href="#faq" className="text-foreground font-medium py-2" onClick={() => setIsMobileMenuOpen(false)}>
              FAQ
            </a>
            <div className="flex flex-col gap-3 pt-4 border-t border-border">
              <Button variant="outline" className="w-full" asChild>
                <a
                  href={PLAY_STORE_URL}
                  target="_blank"
                  rel="noopener noreferrer"
                  onClick={() => trackPlayStoreClick("navbar_mobile_outline")}
                >
                  <GooglePlayIcon className="w-4 h-4" />
                  Google Play
                </a>
              </Button>
              <Button variant="hero" className="w-full" asChild>
                <a
                  href={PLAY_STORE_URL}
                  target="_blank"
                  rel="noopener noreferrer"
                  onClick={() => trackPlayStoreClick("navbar_mobile_primary")}
                >
                  <Video className="w-4 h-4" />
                  Download App
                </a>
              </Button>
            </div>
          </div>
        </div>
      )}
    </nav>
  );
};

export default Navbar;
