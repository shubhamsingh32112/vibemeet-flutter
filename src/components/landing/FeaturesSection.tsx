import { Shield, Video, MessageCircle, Mic, Users, Globe } from "lucide-react";

const features = [
  {
    icon: Shield,
    title: "Private 1v1 Webcam Chat",
    description: "End-to-end encrypted video calls ensure your conversations stay private and secure.",
    color: "from-primary to-primary/60",
  },
  {
    icon: Video,
    title: "HD Video Quality",
    description: "Crystal clear video streaming with adaptive quality for smooth conversations.",
    color: "from-primary to-secondary",
  },
  {
    icon: MessageCircle,
    title: "Text Chat",
    description: "Not ready for video? Start with text messages and transition when you're comfortable.",
    color: "from-secondary/80 to-primary/80",
  },
  {
    icon: Mic,
    title: "Voice Chat",
    description: "Prefer just audio? Switch to voice-only calls anytime during your conversation.",
    color: "from-primary/70 to-secondary/70",
  },
  {
    icon: Users,
    title: "Real Creators",
    description: "Connect with verified creators. No bots – real people ready to chat and connect.",
    color: "from-secondary to-primary",
  },
  {
    icon: Globe,
    title: "Global Community",
    description: "Connect with people from over 190 countries and make friends worldwide.",
    color: "from-secondary/60 to-primary/60",
  },
];

const FeaturesSection = () => {
  return (
    <section id="features" className="py-24 bg-card relative overflow-hidden">
      {/* Background decoration */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[400px] bg-primary/5 rounded-full blur-3xl" />

      <div className="container relative z-10 px-4">
        <div className="text-center mb-16">
          <span className="inline-block text-primary font-semibold mb-4">Features</span>
          <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold mb-6">
            Everything You Need for <span>Perfect Connections</span>
          </h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto">
            Packed with powerful features designed to help you meet amazing people and build meaningful relationships.
          </p>
        </div>

        <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {features.map((feature, index) => (
            <div
              key={index}
              className="group relative bg-background rounded-2xl p-6 shadow-card hover:shadow-glow transition-all duration-300 hover:-translate-y-1"
            >
              <div className={`w-14 h-14 rounded-xl bg-gradient-to-br ${feature.color} flex items-center justify-center mb-5 shadow-soft group-hover:scale-110 transition-transform`}>
                <feature.icon className="w-7 h-7 text-primary-foreground" />
              </div>
              <h3 className="text-lg font-bold mb-2">{feature.title}</h3>
              <p className="text-muted-foreground text-sm leading-relaxed">
                {feature.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default FeaturesSection;
