import Navbar from "@/components/landing/Navbar";
import Footer from "@/components/landing/Footer";
import { Trash2, Settings, User } from "lucide-react";

const AccountDeletion = () => {
  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      <main className="container mx-auto px-4 py-16 max-w-4xl">
        <article className="prose prose-slate dark:prose-invert max-w-none">
          <h1 className="text-4xl font-bold mb-4">Account Deletion</h1>

          <div className="text-muted-foreground mb-8">
            <p><strong>Last Updated:</strong> March 2026</p>
          </div>

          <p className="text-lg mb-6">
            You can delete your MatchVibe account at any time. When you delete your account, all of your data will be permanently removed from our systems.
          </p>

          <section className="mb-12">
            <h2 className="text-2xl font-bold mb-6">How to Delete Your Account</h2>
            <p className="mb-6">
              To delete your account, follow these steps in the MatchVibe app:
            </p>
            <ol className="list-decimal pl-6 space-y-4 mb-6">
              <li className="flex items-start gap-3">
                <span className="flex-shrink-0 w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
                  <User className="w-4 h-4 text-primary" />
                </span>
                <div>
                  <strong>Go to Account</strong>
                  <p className="text-muted-foreground mt-1">Open the MatchVibe app and navigate to your Account section.</p>
                </div>
              </li>
              <li className="flex items-start gap-3">
                <span className="flex-shrink-0 w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
                  <Settings className="w-4 h-4 text-primary" />
                </span>
                <div>
                  <strong>Open Account Settings</strong>
                  <p className="text-muted-foreground mt-1">From your Account, tap on Account Settings.</p>
                </div>
              </li>
              <li className="flex items-start gap-3">
                <span className="flex-shrink-0 w-8 h-8 rounded-full bg-destructive/10 flex items-center justify-center">
                  <Trash2 className="w-4 h-4 text-destructive" />
                </span>
                <div>
                  <strong>Delete Account</strong>
                  <p className="text-muted-foreground mt-1">Select Delete Account and confirm your decision when prompted.</p>
                </div>
              </li>
            </ol>
          </section>

          <section className="mb-12 p-6 rounded-lg bg-muted/50 border border-border">
            <h2 className="text-2xl font-bold mb-4">What Happens When You Delete Your Account</h2>
            <p className="mb-4">
              When you delete your account, <strong>all of your data will be permanently deleted</strong>, including:
            </p>
            <ul className="list-disc pl-6 space-y-2 mb-4">
              <li>Your profile information</li>
              <li>Your chat and message history</li>
              <li>Your match history</li>
              <li>Your preferences and settings</li>
              <li>Any other data associated with your account</li>
            </ul>
            <p>
              This action cannot be undone. If you wish to use MatchVibe again in the future, you will need to create a new account.
            </p>
          </section>

          <p className="text-muted-foreground">
            If you have any questions about account deletion, please contact us at{" "}
            <a href="mailto:support@matchvibe.co.in" className="text-primary hover:underline">
              support@matchvibe.co.in
            </a>
            .
          </p>
        </article>
      </main>
      <Footer />
    </div>
  );
};

export default AccountDeletion;
