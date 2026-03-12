import { Download, Video, Heart, Sparkles } from "lucide-react";
import { Button } from "@/components/ui/button";

const CTASection = () => {
  return (
    <section className="py-24 relative overflow-hidden">
      {/* Background gradient */}
      <div className="absolute inset-0 gradient-primary opacity-95" />
      
      {/* Decorative elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-10 left-10 text-5xl animate-float opacity-20">💕</div>
        <div className="absolute top-20 right-20 text-4xl animate-float opacity-20" style={{ animationDelay: '-2s' }}>✨</div>
        <div className="absolute bottom-10 left-1/4 text-5xl animate-float opacity-20" style={{ animationDelay: '-1s' }}>💖</div>
        <div className="absolute bottom-20 right-1/4 text-4xl animate-float opacity-20" style={{ animationDelay: '-3s' }}>🌟</div>
        <div className="absolute top-1/2 left-5 text-3xl animate-bounce opacity-20">❤️</div>
        <div className="absolute top-1/2 right-5 text-3xl animate-bounce opacity-20" style={{ animationDelay: '-1s' }}>💝</div>
      </div>

      <div className="container relative z-10 px-4">
        <div className="max-w-4xl mx-auto text-center">
          <div className="inline-flex items-center gap-2 bg-primary-foreground/10 backdrop-blur-sm rounded-full px-4 py-2 mb-6">
            <Sparkles className="w-4 h-4 text-primary-foreground" />
            <span className="text-sm font-medium text-primary-foreground">
              Start Your Journey Today
            </span>
          </div>

          <h2 className="text-3xl md:text-4xl lg:text-6xl font-extrabold text-primary-foreground mb-6">
            Start 1v1 Video Chat with Match Vibe Now
          </h2>

          <p className="text-xl text-primary-foreground/80 mb-10 max-w-2xl mx-auto">
            Join millions of users finding love, friendship, and meaningful connections every day. Your next great conversation is just one tap away.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center mb-8">
            <Button variant="heroOutline" size="xl" className="bg-primary-foreground text-primary hover:bg-primary-foreground/90" asChild>
              <a href="/app-release.apk" download="Match-Vibe.apk">
                <Download className="w-5 h-5" />
                Download APK Now
              </a>
            </Button>
            <Button variant="heroOutline" size="xl">
              <Video className="w-5 h-5" />
              Join Match Vibe Today
            </Button>
          </div>

          <div className="flex items-center justify-center gap-4 text-primary-foreground/70 text-sm">
            <span className="flex items-center gap-1">
              <Heart className="w-4 h-4" />
              Free to use
            </span>
            <span>•</span>
            <span>No credit card required</span>
            <span>•</span>
            <span>Safe & Secure</span>
          </div>
        </div>
      </div>
    </section>
  );
};

export default CTASection;
