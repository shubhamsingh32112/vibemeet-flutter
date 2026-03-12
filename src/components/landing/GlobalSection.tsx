import { Globe, MessageCircle, Heart, Users } from "lucide-react";
import { Button } from "@/components/ui/button";

const stats = [
  { icon: Users, value: "2M+", label: "Active Users" },
  { icon: Globe, value: "190+", label: "Countries" },
  { icon: MessageCircle, value: "10M+", label: "Chats Daily" },
  { icon: Heart, value: "500K+", label: "Matches Made" },
];

const GlobalSection = () => {
  return (
    <section className="py-24 bg-card relative overflow-hidden">
      {/* Background decoration */}
      <div className="absolute inset-0 opacity-5">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] border-2 border-primary rounded-full" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[400px] h-[400px] border-2 border-secondary rounded-full" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[200px] h-[200px] border-2 border-primary rounded-full" />
      </div>

      <div className="container relative z-10 px-4">
        <div className="grid lg:grid-cols-2 gap-16 items-center">
          {/* Left Content */}
          <div>
            <span className="inline-block text-primary font-semibold mb-4">Global Community</span>
            <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold mb-6">
              Effortless 1v1 Video Chats <span>Across the World</span>
            </h2>
            <p className="text-muted-foreground text-lg mb-8">
              Break down barriers and connect with people from every corner of the globe. Whether you're looking for romance, friendship, or cultural exchange – Match Vibe brings the world to your fingertips.
            </p>

            <ul className="space-y-4 mb-8">
              <li className="flex items-center gap-3">
                <div className="w-6 h-6 rounded-full gradient-primary flex items-center justify-center">
                  <span className="text-primary-foreground text-xs">✓</span>
                </div>
                <span className="text-foreground">Practice languages with native speakers</span>
              </li>
              <li className="flex items-center gap-3">
                <div className="w-6 h-6 rounded-full gradient-primary flex items-center justify-center">
                  <span className="text-primary-foreground text-xs">✓</span>
                </div>
                <span className="text-foreground">Discover new cultures and traditions</span>
              </li>
              <li className="flex items-center gap-3">
                <div className="w-6 h-6 rounded-full gradient-primary flex items-center justify-center">
                  <span className="text-primary-foreground text-xs">✓</span>
                </div>
                <span className="text-foreground">Find romance or meaningful friendships</span>
              </li>
            </ul>

            <Button variant="hero" size="lg" asChild>
              <a href="/app-release.apk" download="Match-Vibe.apk">
                <Globe className="w-5 h-5" />
                Download App
              </a>
            </Button>
          </div>

          {/* Right Content - Stats */}
          <div className="grid grid-cols-2 gap-6">
            {stats.map((stat, index) => (
              <div
                key={index}
                className="bg-background rounded-2xl p-8 shadow-card text-center hover:shadow-glow transition-all duration-300 hover:-translate-y-1"
              >
                <div className="w-16 h-16 rounded-xl gradient-primary flex items-center justify-center mx-auto mb-4 shadow-soft">
                  <stat.icon className="w-8 h-8 text-primary-foreground" />
                </div>
                <div className="text-3xl md:text-4xl font-bold mb-2">{stat.value}</div>
                <div className="text-muted-foreground font-medium">{stat.label}</div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
};

export default GlobalSection;
