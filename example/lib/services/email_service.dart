import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  //! GMAIL SMTP CONFIGURATION
  static const String _smtpHost = 'smtp.gmail.com';
  static const int _smtpPort = 587;
  static const String _username = ''; // Update this
  static const String _password = ''; // Update this

  //! SEND VERIFICATION CODE ON EMAIL
  static Future<void> sendVerificationCode(String email, String code) async {
    try {
      final smtpServer = SmtpServer(
        _smtpHost,
        port: _smtpPort,
        username: _username,
        password: _password,
        ssl: false,
        allowInsecure: true,
      );

      //! MESSAGE DESIGN
      final message = Message()
        ..from = Address(_username, 'CyberAR')
        ..recipients.add(email)
        ..subject = 'Password Reset Verification Code'
        ..text =
            'Your password reset code is: $code\n\nThis code will expire in 10 minutes.';

      await send(message, smtpServer);
    } catch (e) {
      throw Exception('Failed to send email: $e');
    }
  }
}
