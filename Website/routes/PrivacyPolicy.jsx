import { Card, Container } from "react-bootstrap";
import Header from "../components/Header";

export const PrivacyPolicy = () => {
    return (
        <>
            <Header />
            <div className="mt-2">
                <Container>
                    <Card className="p-2 p-lg-4 shadow-sm">
                        <Card.Title className="text-center mb-4 fs-2">Privacy Policy</Card.Title>
                        <Card.Body>
                            <p>
                                CyberQuest (“we,” “our,” “us”) is committed to protecting the privacy and security of your personal information. This Privacy Policy outlines how we collect, use, disclose, and safeguard your information when you use our app, which is designed to provide immersive, hands-on cybersecurity training experiences. By using our services, you consent to the practices described in this policy. Please read this policy carefully to understand our practices regarding your personal data.
                            </p>

                            <h4 className="mt-4">1. Information We Collect</h4>
                            <p>We collect different types of information to provide, personalize, and improve our services.</p>

                            <h5>1.1 Personal Information</h5>
                            <p>When you register and use our services, we may collect personal data that you voluntarily provide:</p>
                            <ul>
                                <li><strong>Name</strong> – Your full name for account creation and personalized communication.</li>
                                <li><strong>Email address</strong> – For sending updates, account information, and support requests.</li>
                                <li><strong>Account credentials</strong> – Username and password for authenticating your account and ensuring secure access to the app.</li>
                            </ul>

                            <h5>1.2 Usage Data</h5>
                            <p>We also collect data automatically as you interact with our services to improve functionality and your user experience:</p>
                            <ul>
                                <li><strong>Interaction data</strong> – Details about how you engage with modules, simulations, quizzes, and other features in the app.</li>
                                <li><strong>Progress, scores, badges, and achievements</strong> – Data on your learning progress and milestones to track your success and help personalize your experience.</li>
                                <li><strong>Device information</strong> – Information about the device you are using, such as operating system, browser type, device type, and IP address, which help us optimize the app for your device.</li>
                            </ul>

                            <h5>1.3 Cookies and Tracking Technologies</h5>
                            <p>We use cookies and other tracking technologies to enhance your experience and improve the functionality of the app. This includes:</p>
                            <ul>
                                <li><strong>Session management</strong> – Cookies to manage your session, ensuring you remain logged in and that your preferences are remembered.</li>
                                <li><strong>Analytics and performance tracking</strong> – Tools like Google Analytics to gather data on how you use the app, which helps us improve performance, content, and user experience.</li>
                            </ul>

                            <h4 className="mt-4">2. How We Use Your Information</h4>
                            <p>The information we collect helps us provide you with a better user experience, improve our services, and communicate with you more effectively. We use your information for the following purposes:</p>
                            <ul>
                                <li><strong>Provide and personalize your learning experience</strong> – Customizing the app’s content, quizzes, and learning modules to suit your progress and preferences.</li>
                                <li><strong>Track and display your progress</strong> – Monitoring your scores, progress, badges, and achievements to give you feedback on your learning journey.</li>
                                <li><strong>Improve app functionality</strong> – Analyzing usage data to enhance the app’s features, fix bugs, and create new tools that benefit users.</li>
                                <li><strong>Respond to support requests</strong> – Addressing your inquiries, troubleshooting issues, and providing customer service support.</li>
                                <li><strong>Send updates and promotional offers</strong> – Providing you with important news about updates, new features, and offers related to CyberQuest, subject to your communication preferences.</li>
                            </ul>

                            <h4 className="mt-4">3. How We Share Your Information</h4>
                            <p>We understand the importance of your privacy and only share your data in limited circumstances, as outlined below:</p>

                            <h5>3.1 Service Providers</h5>
                            <p>We may share your information with trusted third-party service providers who help us operate the app, process payments, or improve our services. These service providers are bound by confidentiality agreements and are not permitted to use your data for any other purposes.</p>

                            <h5>3.2 Legal Obligations</h5>
                            <p>We may disclose your personal information when required to do so by law or when we believe in good faith that such disclosure is necessary to comply with a legal obligation, protect our rights, or respond to lawful requests by public authorities.</p>

                            <h5>3.3 Business Transfers</h5>
                            <p>In the event that CyberQuest undergoes a merger, acquisition, or sale, your personal data may be transferred as part of the transaction. We will notify you of any changes to ownership or use of your information through updates to this Privacy Policy.</p>

                            <h4 className="mt-4">4. Your Rights and Choices</h4>
                            <p>You have the following rights regarding your personal information:</p>
                            <ul>
                                <li><strong>Access and update your personal information</strong> – You can view and edit your personal details (such as name and email address) within the app settings at any time.</li>
                                <li><strong>Opt-out of promotional communications</strong> – You can unsubscribe from marketing emails and notifications by clicking the unsubscribe link included in our communications.</li>
                                <li><strong>Request deletion of your account</strong> – You may request to delete your account and personal data by contacting us directly. Please note that certain data may be retained for legal or operational purposes.</li>
                            </ul>

                            <h4 className="mt-4">5. Data Security</h4>
                            <p>We implement industry-standard security measures, including encryption, access controls, and secure data storage, to protect your personal information. However, please be aware that no method of electronic transmission or storage is completely secure, and we cannot guarantee 100% security of your data.</p>

                            <h4 className="mt-4">6. Children’s Privacy</h4>
                            <p>CyberQuest is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13. If you believe that we have unintentionally collected such information, please contact us immediately so we can take appropriate action.</p>

                            <h4 className="mt-4">7. Changes to This Privacy Policy</h4>
                            <p>We reserve the right to update or modify this Privacy Policy at any time. Any changes will be posted within the app with an updated “Effective Date.” We encourage you to periodically review this page to stay informed about how we are protecting your information.</p>

                            <h4 className="mt-4">8. Contact Us</h4>
                            <p>If you have any questions, concerns, or requests regarding this Privacy Policy or our data practices, please don’t hesitate to reach out to us:</p>
                            <p><strong>Email: </strong><a href="mailto:ayaasahina16@gmail.com">ayaasahina16@gmail.com</a></p>
                            <p><strong>CyberQuest Team</strong></p>
                        </Card.Body>
                    </Card>
                </Container>
            </div>

        </>
    );
};
