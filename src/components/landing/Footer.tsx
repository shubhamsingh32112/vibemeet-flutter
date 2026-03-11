import { Video, Heart } from "lucide-react";
import { Link } from "react-router-dom";

const Footer = () => {
  return (
    <footer className="bg-foreground py-16">
      <div className="container px-4">
        <div className="grid md:grid-cols-4 gap-12 mb-12">
          {/* Logo & Description */}
          <div className="md:col-span-2">
            <a href="#" className="flex items-center gap-2 mb-4">
              <div className="w-10 h-10 rounded-xl gradient-primary flex items-center justify-center">
                <Video className="w-5 h-5 text-primary-foreground" />
              </div>
              <span className="text-xl font-bold text-background">MatchVibe</span>
            </a>
            <p className="text-background/60 mb-6 max-w-sm">
              The #1 video dating app connecting real people worldwide. Find love, friendship, and meaningful connections through 1v1 video chats.
            </p>
            <div className="flex items-center gap-2 text-background/50 text-sm">
              <span>Made with</span>
              <Heart className="w-4 h-4 text-primary fill-primary" />
              <span>for genuine connections</span>
            </div>
          </div>

          {/* Quick Links */}
          <div>
            <h4 className="text-background font-semibold mb-4">Quick Links</h4>
            <ul className="space-y-3">
              <li>
                <a href="#features" className="text-background/60 hover:text-background transition-colors">
                  Features
                </a>
              </li>
              <li>
                <a href="#how-it-works" className="text-background/60 hover:text-background transition-colors">
                  How It Works
                </a>
              </li>
              <li>
                <a href="#testimonials" className="text-background/60 hover:text-background transition-colors">
                  Reviews
                </a>
              </li>
              <li>
                <a href="#faq" className="text-background/60 hover:text-background transition-colors">
                  FAQ
                </a>
              </li>
            </ul>
          </div>

          {/* Legal */}
          <div>
            <h4 className="text-background font-semibold mb-4">Legal</h4>
            <ul className="space-y-3">
              <li>
                <Link to="/privacy-policy" className="text-background/60 hover:text-background transition-colors">
                  Privacy Policy
                </Link>
              </li>
              <li>
                <Link to="/terms-and-conditions" className="text-background/60 hover:text-background transition-colors">
                  Terms of Use
                </Link>
              </li>
              <li>
                <Link to="/account-deletion" className="text-background/60 hover:text-background transition-colors">
                  Delete Account
                </Link>
              </li>
              <li>
                <a href="#" className="text-background/60 hover:text-background transition-colors">
                  Cookies Policy
                </a>
              </li>
            </ul>
          </div>
        </div>

        {/* Company Info */}
        <div className="pt-8 border-t border-background/10">
          <div className="flex flex-col md:flex-row justify-between items-center gap-4">
            <div className="text-background/50 text-sm text-center md:text-left">
              <p className="mb-1">MANTOTECH PRIVATE LIMITED</p>
              <p>No 39, WolfPack Workspaces, 39, 8th Main Rd, Vasanth Nagar, Bengaluru, Karnataka 560001</p>
            </div>
            <p className="text-background/50 text-sm">
              © 2025 MatchVibe Team. All Rights Reserved.
            </p>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
