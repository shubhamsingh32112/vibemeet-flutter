import { MousePointerClick, Search, Heart, Video } from "lucide-react";

const steps = [
  {
    icon: MousePointerClick,
    step: "01",
    title: "Switch",
    description: "One-tap instant matching connects you with someone new in seconds.",
    color: "bg-primary",
  },
  {
    icon: Search,
    step: "02",
    title: "Discover",
    description: "Browse real profiles and find people who share your interests.",
    color: "bg-secondary",
  },
  {
    icon: Heart,
    step: "03",
    title: "Match",
    description: "Like someone? When they like you back, it's a match!",
    color: "bg-primary",
  },
  {
    icon: Video,
    step: "04",
    title: "Connect",
    description: "Start with text, move to voice, then video – at your pace.",
    color: "bg-secondary",
  },
];

const HowItWorksSection = () => {
  return (
    <section id="how-it-works" className="py-24 gradient-hero relative overflow-hidden">
      <div className="container px-4">
        <div className="text-center mb-16">
          <span className="inline-block text-primary font-semibold mb-4">How It Works</span>
          <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold mb-6">
            Find Your Match in <span>4 Simple Steps</span>
          </h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto">
            Getting started is easy. Follow these simple steps to start meeting amazing people today.
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
          {steps.map((step, index) => (
            <div key={index} className="relative">
              {/* Connector line */}
              {index < steps.length - 1 && (
                <div className="hidden lg:block absolute top-12 left-[60%] w-full h-0.5 bg-gradient-to-r from-primary/30 to-secondary/30" />
              )}

              <div className="relative bg-card rounded-3xl p-8 shadow-card hover:shadow-glow transition-all duration-300 text-center group">
                {/* Step number */}
                <div className="absolute -top-4 left-1/2 -translate-x-1/2 bg-accent text-primary font-bold text-sm px-4 py-1 rounded-full">
                  Step {step.step}
                </div>

                <div className={`w-20 h-20 ${step.color} rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-glow group-hover:scale-110 transition-transform`}>
                  <step.icon className="w-10 h-10 text-primary-foreground" />
                </div>

                <h3 className="text-xl font-bold mb-3">{step.title}</h3>
                <p className="text-muted-foreground">{step.description}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default HowItWorksSection;
