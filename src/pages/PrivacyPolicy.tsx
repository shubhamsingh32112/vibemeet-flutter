import Navbar from "@/components/landing/Navbar";
import Footer from "@/components/landing/Footer";

const PrivacyPolicy = () => {
  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      <main className="container mx-auto px-4 py-16 max-w-4xl">
        <article className="prose prose-slate dark:prose-invert max-w-none">
          <h1 className="text-4xl font-bold mb-4">MatchVibe App's Privacy Policy</h1>
          
          <div className="text-muted-foreground mb-8">
            <p><strong>Effective Date:</strong> 27th Feb 2026</p>
            <p><strong>Updated Date:</strong> 4th March 2026</p>
          </div>

          <p className="text-lg mb-6">
            Welcome to MatchVibe App's Privacy Policy. This document explains how Loft Tech Private Limited ("MatchVibe App", "we", "us", or "our") collects, uses, stores, and shares your personal information while you use the MatchVibe App, and how you can manage your data and privacy choices while using the app.
          </p>

          <p className="mb-6">
            We believe in being transparent about how your data is handled. This policy outlines the types of information we collect, the purposes for which we use it, and the tools we offer to help you control what you share and with whom.
          </p>

          <p className="mb-6">
            This Privacy Policy applies to all features, products, and services offered through MatchVibe App.
          </p>

          <p className="mb-8">
            Please read this Privacy Policy along with our Terms and Conditions of Use. In case of any conflict between the two, this Privacy Policy will override the Terms.
          </p>

          <p className="mb-8">
            If you have any questions, feel free to reach out at <a href="mailto:support@matchvibe.co.in" className="text-primary hover:underline">support@matchvibe.co.in</a>.
          </p>

          <section className="mb-12">
            <h2 className="text-3xl font-bold mb-6">THE INFORMATION WE COLLECT AND HOW WE USE IT</h2>
            <p className="mb-6">
              We collect personal information to help set up and operate your account, provide our services, comply with legal requirements, and improve the MatchVibe App. The table below outlines the categories of data we collect, how we collect it, and how we use it.
            </p>

            <div className="overflow-x-auto mb-6">
              <table className="w-full border-collapse border border-border">
                <thead>
                  <tr className="bg-muted">
                    <th className="border border-border p-3 text-left">Category</th>
                    <th className="border border-border p-3 text-left">Data We Collect</th>
                    <th className="border border-border p-3 text-left">Purpose of Collection and Use</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td className="border border-border p-3 font-semibold">Account Setup and log-in data</td>
                    <td className="border border-border p-3">User ID, name, age, mobile number, gender, voice sample, IP address</td>
                    <td className="border border-border p-3">
                      <ul className="list-disc list-inside space-y-1">
                        <li>To create and manage your account</li>
                        <li>To send notifications (including policy updates)</li>
                        <li>To communicate with you and provide support</li>
                        <li>To personalise language, location, and experience</li>
                        <li>To detect fraud and enforce platform Terms</li>
                        <li>For internal operations like troubleshooting and analytics</li>
                        <li>To develop and improve services</li>
                      </ul>
                    </td>
                  </tr>
                  <tr>
                    <td className="border border-border p-3 font-semibold">Profile information</td>
                    <td className="border border-border p-3">Username, birth year, gender, language preference</td>
                    <td className="border border-border p-3">
                      <ul className="list-disc list-inside space-y-1">
                        <li>To populate your user profile</li>
                        <li>To personalise your experience</li>
                      </ul>
                    </td>
                  </tr>
                  <tr>
                    <td className="border border-border p-3 font-semibold">Moderation of audio/video call and chat</td>
                    <td className="border border-border p-3">Voice and video data, call activity patterns</td>
                    <td className="border border-border p-3">
                      <ul className="list-disc list-inside space-y-1">
                        <li>To detect and prevent violations of Community Guidelines</li>
                        <li>To support real-time and post-call or post-chat moderation for safety and compliance</li>
                        <li>To generate content suggestions or prompts based on user conversations</li>
                        <li>To improve our automated safety tools and moderation systems including through model retraining</li>
                      </ul>
                    </td>
                  </tr>
                  <tr>
                    <td className="border border-border p-3 font-semibold">AI-generated interaction features</td>
                    <td className="border border-border p-3">Audio, video, chat content, transcripts, usage patterns</td>
                    <td className="border border-border p-3">
                      <ul className="list-disc list-inside space-y-1">
                        <li>To generate real-time prompts, replies, or suggestions using AI models</li>
                        <li>To support chatbot-based interactions with users</li>
                        <li>To improve interaction quality and responsiveness</li>
                        <li>Some AI services are provided by third-party tools and may involve data processing outside the app</li>
                        <li>To improve the accuracy, relevance, and responsiveness of AI-driven features</li>
                      </ul>
                    </td>
                  </tr>
                  <tr>
                    <td className="border border-border p-3 font-semibold">Device data</td>
                    <td className="border border-border p-3">Device model, OS version, app version, browser type, plugins, battery level, available storage, signal strength, foreground / background status, language of the device as set by the user</td>
                    <td className="border border-border p-3">
                      <ul className="list-disc list-inside space-y-1">
                        <li>To optimise app performance</li>
                        <li>For internal operations like troubleshooting and analytics</li>
                        <li>To customise the experience for your device</li>
                      </ul>
                    </td>
                  </tr>
                  <tr>
                    <td className="border border-border p-3 font-semibold">Identifiers and signals</td>
                    <td className="border border-border p-3">Device ID, advertising IDs, Bluetooth signals, nearby Wi-Fi and cell towers</td>
                    <td className="border border-border p-3">
                      <ul className="list-disc list-inside space-y-1">
                        <li>To personalise content based on source of install</li>
                        <li>To enhance security and app functionality</li>
                      </ul>
                    </td>
                  </tr>
                  <tr>
                    <td className="border border-border p-3 font-semibold">Location and media access</td>
                    <td className="border border-border p-3">GPS location, address, time zone access to camera, microphone, image/audio/video files (only with your permission)</td>
                    <td className="border border-border p-3">
                      <ul className="list-disc list-inside space-y-1">
                        <li>To enable app features that require media or camera/mic access (e.g. calling, uploading content)</li>
                        <li>To personalise content based on location</li>
                        <li>To detect suspicious activity, prevent unauthorised access, and maintain the overall security and integrity of the platform</li>
                      </ul>
                    </td>
                  </tr>
                  <tr>
                    <td className="border border-border p-3 font-semibold">Network and connection info</td>
                    <td className="border border-border p-3">Mobile carrier, ISP, IP address, time zone, connection speed, language</td>
                    <td className="border border-border p-3">
                      <ul className="list-disc list-inside space-y-1">
                        <li>To ensure service availability and optimise performance</li>
                        <li>To detect suspicious activity, prevent unauthorised access, and maintain the overall security and integrity of the platform</li>
                      </ul>
                    </td>
                  </tr>
                  <tr>
                    <td className="border border-border p-3 font-semibold">Call, chat and interaction data</td>
                    <td className="border border-border p-3">List of users you interact with, call/chat timestamps, duration of communication, call pick-up rate</td>
                    <td className="border border-border p-3">
                      <ul className="list-disc list-inside space-y-1">
                        <li>To enable audio/video calls and the chat feature</li>
                        <li>For safety monitoring and moderation</li>
                        <li>To enforce Community Guidelines</li>
                        <li>To detect suspicious activity, prevent unauthorised access, and maintain the overall security and integrity of the platform</li>
                      </ul>
                    </td>
                  </tr>
                  <tr>
                    <td className="border border-border p-3 font-semibold">Log data and technical info</td>
                    <td className="border border-border p-3">Cookies, beacons, scripts, logs, crash reports, referral URLs</td>
                    <td className="border border-border p-3">
                      <ul className="list-disc list-inside space-y-1">
                        <li>For diagnostics, usage tracking, and performance optimisation</li>
                      </ul>
                    </td>
                  </tr>
                  <tr>
                    <td className="border border-border p-3 font-semibold">Information from other sources</td>
                    <td className="border border-border p-3">Data from service providers, technical subcontractors, analytics providers. This may include your name, profile image, email address, phone number, country, device details, and information about advertising campaign you interacted with to install the app</td>
                    <td className="border border-border p-3">
                      <ul className="list-disc list-inside space-y-1">
                        <li>To perform analytics, and detect abuse or fraud</li>
                        <li>To provide AI-generated features such as interaction suggestions or moderation outcomes</li>
                        <li>To enable login through an existing account on a different platform</li>
                      </ul>
                    </td>
                  </tr>
                  <tr>
                    <td className="border border-border p-3 font-semibold">Marketing Metadata</td>
                    <td className="border border-border p-3">Source of traffic, marketing medium, campaign details, type of ad or content</td>
                    <td className="border border-border p-3">
                      <ul className="list-disc list-inside space-y-1">
                        <li>To understand how users discover and reach our platform, including when an interest form is submitted via the website</li>
                        <li>To enhance the effectiveness of our marketing and user engagement efforts</li>
                      </ul>
                    </td>
                  </tr>
                  <tr>
                    <td className="border border-border p-3 font-semibold">Account security</td>
                    <td className="border border-border p-3">Phone number, access to SMS for OTPs</td>
                    <td className="border border-border p-3">
                      <ul className="list-disc list-inside space-y-1">
                        <li>To verify your identity</li>
                        <li>To protect account access and prevent misuse</li>
                      </ul>
                    </td>
                  </tr>
                  <tr>
                    <td className="border border-border p-3 font-semibold">Customer support</td>
                    <td className="border border-border p-3">Any data you share with our support team</td>
                    <td className="border border-border p-3">
                      <ul className="list-disc list-inside space-y-1">
                        <li>To investigate and resolve your issue</li>
                        <li>To improve support quality</li>
                      </ul>
                    </td>
                  </tr>
                  <tr>
                    <td className="border border-border p-3 font-semibold">Transactional and financial data</td>
                    <td className="border border-border p-3">Purchase records (e.g. coins or in-app features), biller name/id, amount, transaction ID, average order value, lifetime spends</td>
                    <td className="border border-border p-3">
                      <ul className="list-disc list-inside space-y-1">
                        <li>To process payments</li>
                        <li>To maintain transaction records</li>
                        <li>To comply with applicable legal and tax requirements</li>
                        <li>To show you offers relevant to you</li>
                      </ul>
                    </td>
                  </tr>
                  <tr>
                    <td className="border border-border p-3 font-semibold">Verification and banking details</td>
                    <td className="border border-border p-3">PAN Card, Aadhaar card and number, PAN - Aadhaar link status, PAN and Aadhaar details such as name, date of birth and gender, UPI ID, bank account, details, name associated with bank account</td>
                    <td className="border border-border p-3">
                      <ul className="list-disc list-inside space-y-1">
                        <li>To verify your identity for payment-related purposes</li>
                        <li>To process payments securely</li>
                        <li>To comply with our obligations under applicable laws</li>
                      </ul>
                    </td>
                  </tr>
                  <tr>
                    <td className="border border-border p-3 font-semibold">Information from other users and third parties</td>
                    <td className="border border-border p-3">Reports or data from other users, affiliates, third-party providers, and authorities</td>
                    <td className="border border-border p-3">
                      <ul className="list-disc list-inside space-y-1">
                        <li>To investigate complaints or suspected policy violations</li>
                        <li>To identify and prevent abusive or fraudulent behaviour</li>
                        <li>To comply with legal obligations</li>
                      </ul>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <p className="mb-6">
              In addition to the above, we may also use your personal data to perform analytics and usage analysis (including through aggregated or pseudonymised data) to understand how users interact with the platform and improve the performance, design, and safety of MatchVibe App.
            </p>
          </section>

          <section className="mb-12">
            <h2 className="text-3xl font-bold mb-6">HOW WE SHARE YOUR INFORMATION</h2>
            <p className="mb-6">
              We do not share your personal information publicly or make it visible to other users outside of private, user-initiated interactions such as audio or video calls. However, we may share your information in the following circumstances:
            </p>

            <div className="space-y-4 mb-6">
              <div>
                <h3 className="text-xl font-semibold mb-2">Other users you interact with:</h3>
                <p>
                  When you participate in an audio or video call, or chat with other users on MatchVibe App, limited profile information, such as your username, profile picture (if applicable), and call status, may be visible to the person you are speaking with. We do not share your phone number or any sensitive personal information unless you choose to disclose it during the interaction.
                </p>
              </div>

              <div>
                <h3 className="text-xl font-semibold mb-2">With your consent:</h3>
                <p>
                  We may share your information with third-party services or platforms only when you explicitly allow us to do so. For example, if you choose to send a call invitation via WhatsApp or SMS, those platforms' privacy policies will apply to the shared data.
                </p>
              </div>

              <div>
                <h3 className="text-xl font-semibold mb-2">With our service providers:</h3>
                <p className="mb-2">We engage trusted third-party service providers to help operate and maintain MatchVibe App. These may include:</p>
                <ul className="list-disc list-inside space-y-1 ml-4">
                  <li>Cloud storage and hosting services</li>
                  <li>Call infrastructure providers</li>
                  <li>Analytics and diagnostics partners</li>
                  <li>Customer support tools</li>
                  <li>Security and fraud detection services</li>
                  <li>User engagement and notification platforms</li>
                  <li>AI service providers, including providers of content moderation tools, chatbot infrastructure, and prompt generation systems</li>
                </ul>
                <p className="mt-2">
                  These providers only process your information on our behalf and under strict confidentiality and data protection obligations.
                </p>
              </div>

              <div>
                <h3 className="text-xl font-semibold mb-2">For legal and safety reasons:</h3>
                <p className="mb-2">We may disclose your information if necessary to:</p>
                <ul className="list-disc list-inside space-y-1 ml-4">
                  <li>Comply with applicable laws, legal proceedings, or valid government requests</li>
                  <li>Respond to law enforcement inquiries</li>
                  <li>Enforce our Terms and Conditions of Use or investigate policy violations</li>
                  <li>Detect or prevent fraud, abuse, or technical issues</li>
                  <li>Protect the rights, safety, and property of MatchVibe App, our users, or the public</li>
                </ul>
              </div>

              <div>
                <h3 className="text-xl font-semibold mb-2">With our group entities:</h3>
                <p>
                  We may share your information with our parent company, subsidiaries, and affiliated entities to support the provision, improvement, and security of MatchVibe App.
                </p>
              </div>

              <div>
                <h3 className="text-xl font-semibold mb-2">In case of a business transfer:</h3>
                <p>
                  If MatchVibe App is involved in a merger, acquisition, restructuring, or sale of assets, your data may be transferred to the relevant third party as part of that transaction. If such a transfer affects your rights, we will notify you as required by law.
                </p>
              </div>

              <div>
                <h3 className="text-xl font-semibold mb-2">Aggregated or de-identified information:</h3>
                <p>
                  We may share aggregated or de-identified data (which cannot be used to personally identify you) with partners or third parties for analytics, research, or service improvement purposes.
                </p>
              </div>
            </div>
          </section>

          <section className="mb-12">
            <h2 className="text-3xl font-bold mb-6">HOW WE PROTECT YOUR PERSONAL INFORMATION</h2>
            <p className="mb-4">
              We use a combination of technical, physical, and administrative measures to help keep your personal information safe from loss, misuse, unauthorised access, disclosure, alteration, or destruction. These safeguards are designed based on the type of information we collect, and the risks involved.
            </p>
            <p className="mb-4">
              However, your account security also depends on you. Please keep your login details, especially your password, confidential and do not share them with anyone.
            </p>
            <p className="mb-4">
              While we take reasonable steps to protect your information, no system is completely secure. Information shared over the internet always carries some risk. We cannot guarantee that our safeguards will stop every unauthorized attempt to access or misuse your personal data.
            </p>
            <p>
              If we ever identify a suspected breach of your personal information, we have procedures in place to respond. Where required by law, we will notify you and the relevant authorities as soon as possible.
            </p>
          </section>

          <section className="mb-12">
            <h2 className="text-3xl font-bold mb-6">CHANGES TO THIS POLICY</h2>
            <p className="mb-4">
              We may update this Privacy Policy from time to time. For material changes that affect your rights or how we use your data, we will reach out to you directly, such as through an in-app notification, or SMS.
            </p>
            <p>
              We encourage you to review this Privacy Policy periodically to stay informed about how your information is protected.
            </p>
          </section>

          <section className="mb-12">
            <h2 className="text-3xl font-bold mb-6">DATA RETENTION</h2>
            <p className="mb-4">
              We retain your personal information only for as long as it is needed to provide our services and for other lawful purposes.
            </p>
            <p className="mb-4">
              If you request deletion of your account or content, we will remove your data from our active systems. However, copies of certain information may continue to exist in backup storage or archived versions of the platform.
            </p>
            <p>
              Also, because of the way the internet works, content that has been shared or saved by other users may continue to exist outside our control, even after deletion. This includes screenshots or downloads shared through other platforms.
            </p>
          </section>

          <section className="mb-12">
            <h2 className="text-3xl font-bold mb-6">YOUR RIGHTS</h2>
            <p className="mb-4">
              Under Indian data protection laws, you have certain rights in relation to your personal data. These include:
            </p>

            <div className="space-y-4 mb-6">
              <div>
                <h3 className="text-xl font-semibold mb-2">Review and correction:</h3>
                <p>
                  You have the right to review the personal data you have provided and request correction of any incomplete or inaccurate information we hold. We may need to verify the accuracy of the updated data before making the change.
                </p>
              </div>

              <div>
                <h3 className="text-xl font-semibold mb-2">Withdraw consent:</h3>
                <p>
                  Where we rely on your consent to process your personal data, you may withdraw that consent at any time. This will not affect the lawfulness of processing carried out prior to your withdrawal.
                </p>
                <p className="mt-2">
                  Additionally, if you withdraw your consent, object to processing, or choose not to provide certain personal information, we may be unable to provide some or all of our services to you.
                </p>
              </div>

              <div>
                <h3 className="text-xl font-semibold mb-2">How to exercise your rights:</h3>
                <p>
                  To exercise any of these rights, please contact us at <a href="mailto:support@matchvibe.co.in" className="text-primary hover:underline">support@matchvibe.co.in</a>. For your safety, we may ask you to verify your identity before we process your request.
                </p>
              </div>

              <div>
                <h3 className="text-xl font-semibold mb-2">Marketing communications:</h3>
                <p>
                  You can opt out of receiving marketing communications from us at any time by emailing us at <a href="mailto:support@matchvibe.co.in" className="text-primary hover:underline">support@matchvibe.co.in</a>. Please note that even if you opt out of marketing, we may still contact you with important service-related or administrative messages, as permitted by law.
                </p>
              </div>
            </div>
          </section>

          <section className="mb-12">
            <h2 className="text-3xl font-bold mb-6">GRIEVANCE REDRESSAL MECHANISM</h2>
            <p className="mb-6">
              If you have any complaints, concerns, or grievances regarding your personal data or this Privacy Policy, you can contact us through the following channels. We will require the phone number linked to your account in order to process and resolve any grievance.
            </p>

            <div className="space-y-6">
              <div>
                <h3 className="text-xl font-semibold mb-2">In-App Reporting:</h3>
                <p>
                  You can report user profiles or make complaints directly within the MatchVibe App using the Help & Support section.
                </p>
              </div>

              <div>
                <h3 className="text-xl font-semibold mb-2">Email Support:</h3>
                <p>
                  For service-related issues such as app performance, please contact our support team at <a href="mailto:support@matchvibe.co.in" className="text-primary hover:underline">support@matchvibe.co.in</a>.
                </p>
              </div>

              <div>
                <h3 className="text-xl font-semibold mb-2">Grievance Officer:</h3>
                <p className="mb-2">
                  For complaints relating to your rights under these Terms, or the Services provided to you, please contact our grievance officer at the details provided below:
                </p>
                <div className="bg-muted p-4 rounded-lg">
                  <p><strong>Name:</strong> Shruti Gupta</p>
                  <p><strong>Email:</strong> <a href="mailto:grievance.officer@matchvibe.co.in" className="text-primary hover:underline">grievance.officer@matchvibe.co.in</a></p>
                  <p><strong>Address:</strong> No 39, WolfPack Workspaces, 39, 8th Main Rd, Vasanth Nagar, Bengaluru, Karnataka 560001</p>
                </div>
              </div>

              <div>
                <h3 className="text-xl font-semibold mb-2">Nodal Contact Person:</h3>
                <p className="mb-2">
                  The Nodal Officer (applicable only for law enforcement agencies) is designated exclusively for communication with law enforcement authorities. This contact should not be used for user support, general inquiries, or complaints.
                </p>
                <div className="bg-muted p-4 rounded-lg">
                  <p><strong>Name:</strong> Shruti Gupta</p>
                  <p><strong>Email:</strong> <a href="mailto:grievance.officer@matchvibe.co.in" className="text-primary hover:underline">grievance.officer@matchvibe.co.in</a></p>
                  <p><strong>Address:</strong> No 39, WolfPack Workspaces, 39, 8th Main Rd, Vasanth Nagar, Bengaluru, Karnataka 560001</p>
                </div>
              </div>
            </div>
          </section>
        </article>
      </main>
      <Footer />
    </div>
  );
};

export default PrivacyPolicy;

