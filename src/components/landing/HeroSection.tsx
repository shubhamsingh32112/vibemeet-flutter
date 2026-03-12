import { Play, Download, Shield, Users, Zap, Heart } from "lucide-react";
import { Button } from "@/components/ui/button";
import { APK_DOWNLOAD_URL } from "@/lib/constants";

const HeroSection = () => {
  return (
    <section className="relative min-h-screen gradient-hero pt-40 pb-20 overflow-hidden">
      {/* Background decorations */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-20 left-10 w-72 h-72 bg-primary/10 rounded-full blur-3xl animate-float" />
        <div className="absolute bottom-20 right-10 w-96 h-96 bg-secondary/10 rounded-full blur-3xl animate-float" style={{ animationDelay: '-3s' }} />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-primary/5 rounded-full blur-3xl" />
      </div>

      <div className="container relative z-10 px-4">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Left Content */}
          <div className="text-center lg:text-left animate-slide-up">
            <div className="inline-flex items-center gap-2 bg-accent/80 backdrop-blur-sm rounded-full px-4 py-2 mb-6">
              <Heart className="w-4 h-4 text-primary animate-pulse" />
              <span className="text-sm font-medium text-accent-foreground">
                Join 2M+ Happy Users Worldwide
              </span>
            </div>

            <h1 className="text-4xl md:text-5xl lg:text-6xl font-extrabold leading-tight mb-6">
              Start <span>1v1 Video Chat</span> with Match Vibe
            </h1>

            <p className="text-lg md:text-xl text-muted-foreground mb-8 max-w-xl mx-auto lg:mx-0">
              Connect instantly and securely — enjoy meaningful private 1-on-1 video chats with real people around the world.
            </p>

            <div className="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start mb-10">
              <Button variant="hero" size="xl" asChild>
                <a href={APK_DOWNLOAD_URL} target="_blank" rel="noopener noreferrer">
                  <Play className="w-5 h-5" />
                  Start Video Call – FREE
                </a>
              </Button>
              <Button variant="outline" size="xl" asChild>
                <a href={APK_DOWNLOAD_URL} target="_blank" rel="noopener noreferrer">
                  <Download className="w-5 h-5" />
                  Download APK
                </a>
              </Button>
            </div>

            {/* Trust Badges */}
            <div className="flex flex-wrap gap-6 justify-center lg:justify-start">
              <div className="flex items-center gap-2 text-muted-foreground">
                <div className="w-10 h-10 rounded-full bg-accent flex items-center justify-center">
                  <Users className="w-5 h-5 text-primary" />
                </div>
                <span className="text-sm font-medium">Real Users</span>
              </div>
              <div className="flex items-center gap-2 text-muted-foreground">
                <div className="w-10 h-10 rounded-full bg-accent flex items-center justify-center">
                  <Shield className="w-5 h-5 text-primary" />
                </div>
                <span className="text-sm font-medium">Private & Secure</span>
              </div>
              <div className="flex items-center gap-2 text-muted-foreground">
                <div className="w-10 h-10 rounded-full bg-accent flex items-center justify-center">
                  <Zap className="w-5 h-5 text-primary" />
                </div>
                <span className="text-sm font-medium">Instant Matching</span>
              </div>
            </div>
          </div>

          {/* Right Content - Hero Visual (no person images) */}
          <div className="relative animate-fade-in" style={{ animationDelay: '0.3s' }}>
            <div className="relative">
              {/* Main visual container */}
              <div className="relative bg-gradient-to-br from-primary/20 to-secondary/20 rounded-3xl p-2 shadow-glow">
                <div className="w-full h-[360px] md:h-[420px] rounded-2xl bg-gradient-to-br from-primary/10 via-background to-secondary/10 flex flex-col items-center justify-center gap-4">
                  <div className="flex items-center gap-3 px-6 py-3 rounded-full bg-card/80 shadow-card border border-border/60">
                    <div className="w-3 h-3 rounded-full bg-success animate-pulse" />
                    <span className="text-sm font-medium text-foreground">Live 1v1 video chats happening now</span>
                  </div>
                  <div className="grid grid-cols-3 gap-4 max-w-sm w-full px-6">
                    <div className="rounded-2xl bg-card/80 border border-border/60 px-4 py-3 text-center">
                      <p className="text-xs text-muted-foreground mb-1">Users online</p>
                      <p className="text-lg font-semibold">12,847</p>
                    </div>
                    <div className="rounded-2xl bg-card/80 border border-border/60 px-4 py-3 text-center">
                      <p className="text-xs text-muted-foreground mb-1">New matches today</p>
                      <p className="text-lg font-semibold">3,204</p>
                    </div>
                    <div className="rounded-2xl bg-card/80 border border-border/60 px-4 py-3 text-center">
                      <p className="text-xs text-muted-foreground mb-1">Countries</p>
                      <p className="text-lg font-semibold">190+</p>
                    </div>
                  </div>
                </div>
                
                {/* Floating UI Elements */}
                <div className="absolute -top-4 -right-4 bg-card rounded-2xl p-4 shadow-card animate-float">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 rounded-full bg-gradient-to-br from-primary/60 to-secondary/60 flex items-center justify-center text-primary-foreground font-semibold">
                      MV
                    </div>
                    <div>
                      <p className="font-semibold text-sm">Incoming call...</p>
                      <p className="text-xs text-muted-foreground">Match Vibe</p>
                    </div>
                  </div>
                </div>

                <div className="absolute -bottom-4 -left-4 bg-card rounded-2xl p-4 shadow-card animate-float" style={{ animationDelay: '-2s' }}>
                  <div className="flex items-center gap-2">
                    <div className="w-3 h-3 bg-success rounded-full animate-pulse" />
                    <span className="text-sm font-medium">12,847 users online</span>
                  </div>
                </div>
              </div>

              {/* Decorative hearts */}
              <div className="absolute -top-8 left-1/4 text-4xl animate-bounce">💕</div>
              <div className="absolute top-1/3 -right-8 text-3xl animate-bounce" style={{ animationDelay: '-1s' }}>✨</div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default HeroSection;
