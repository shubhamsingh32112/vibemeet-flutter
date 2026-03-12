import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";

const faqs = [
  {
    question: "How does Match Vibe work?",
    answer: "Match Vibe lets you browse creators and connect through 1v1 video calls. Sign in with Fast Login (no account needed), add coins for calls, and start chatting. You can also text chat before or after video calls.",
  },
  {
    question: "Is Match Vibe free to use?",
    answer: "Match Vibe is free to download. Fast Login gets you in with one tap. Video calls use coins – new users get free coins to start. You can purchase more coins or earn them through the app.",
  },
  {
    question: "What devices are supported?",
    answer: "Match Vibe is available for Android. Download our APK from our website. iOS version coming soon!",
  },
  {
    question: "How do you ensure user privacy?",
    answer: "We take privacy seriously. All video calls are end-to-end encrypted. We never record or store your conversations. You can report or block users anytime, and our moderation team works 24/7 to keep the community safe.",
  },
  {
    question: "What is the age requirement?",
    answer: "You must be 18 years or older to use Match Vibe. We have age verification measures in place to ensure all users are adults.",
  },
  {
    question: "How do I report inappropriate behavior?",
    answer: "If you encounter inappropriate behavior, tap the report button during or after any chat. Our trust & safety team reviews all reports within 24 hours and takes appropriate action to keep our community safe.",
  },
  {
    question: "Why do video calls sometimes disconnect?",
    answer: "Video call stability depends on your internet connection. For the best experience, use a stable WiFi connection. If issues persist, try restarting the app or switching networks.",
  },
];

const FAQSection = () => {
  return (
    <section id="faq" className="py-24 bg-card">
      <div className="container px-4">
        <div className="text-center mb-16">
          <span className="inline-block text-primary font-semibold mb-4">FAQ</span>
          <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold mb-6">
            Frequently Asked <span className="text-gradient">Questions</span>
          </h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto">
            Got questions? We've got answers. Find everything you need to know about Match Vibe.
          </p>
        </div>

        <div className="max-w-3xl mx-auto">
          <Accordion type="single" collapsible className="space-y-4">
            {faqs.map((faq, index) => (
              <AccordionItem
                key={index}
                value={`item-${index}`}
                className="bg-background rounded-2xl px-6 border-none shadow-card data-[state=open]:shadow-glow transition-shadow"
              >
                <AccordionTrigger className="text-left font-semibold hover:no-underline py-6 text-foreground">
                  {faq.question}
                </AccordionTrigger>
                <AccordionContent className="text-muted-foreground pb-6 leading-relaxed">
                  {faq.answer}
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        </div>
      </div>
    </section>
  );
};

export default FAQSection;
