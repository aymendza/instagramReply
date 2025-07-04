// Test Email Configuration for Development
// DO NOT USE IN PRODUCTION

class TestEmailConfig {
  // Test email credentials for development
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'testPassword123';
  
  // For Gmail SMTP testing (using app-specific password)
  static const String gmailTestEmail = 'your-test-email@gmail.com';
  static const String gmailTestPassword = 'your-app-specific-password';
  
  // SMTP Configuration for testing
  static const String smtpHost = 'smtp.gmail.com';
  static const int smtpPort = 587;
  static const bool useSSL = true;
  
  // Test email recipients
  static const List<String> testRecipients = [
    'test-recipient@example.com',
    'another-test@example.com',
  ];
  
  // Email templates for testing
  static const Map<String, String> testEmailTemplates = {
    'welcome': '''
      Subject: Welcome to SocioReply!
      
      Hello,
      
      Welcome to our platform! This is a test email.
      
      Best regards,
      SocioReply Team
    ''',
    
    'notification': '''
      Subject: New Comment Notification
      
      Hello,
      
      You have a new comment to moderate.
      
      Best regards,
      SocioReply Team
    ''',
    
    'reset_password': '''
      Subject: Password Reset Request
      
      Hello,
      
      You requested a password reset. This is a test email.
      
      Best regards,
      SocioReply Team
    ''',
  };
}

// Test email service class
class TestEmailService {
  static Future<bool> sendTestEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    // Simulate email sending delay
    await Future.delayed(Duration(seconds: 2));
    
    print('📧 TEST EMAIL SENT');
    print('To: $to');
    print('Subject: $subject');
    print('Body: $body');
    print('Status: Success (Simulated)');
    
    // Return true to simulate successful email sending
    return true;
  }
  
  static Future<bool> validateEmailCredentials({
    required String email,
    required String password,
  }) async {
    // Simulate credential validation
    await Future.delayed(Duration(seconds: 1));
    
    print('🔐 VALIDATING EMAIL CREDENTIALS');
    print('Email: $email');
    print('Password: ${'*' * password.length}');
    print('Status: Valid (Simulated)');
    
    return true;
  }
  
  static Future<List<String>> getTestEmailHistory() async {
    // Simulate getting email history
    await Future.delayed(Duration(milliseconds: 500));
    
    return [
      'Test email sent to user@example.com at ${DateTime.now().subtract(Duration(minutes: 5))}',
      'Welcome email sent to newuser@example.com at ${DateTime.now().subtract(Duration(hours: 1))}',
      'Password reset sent to forgot@example.com at ${DateTime.now().subtract(Duration(hours: 2))}',
    ];
  }
}

// Firebase Auth test helpers
class FirebaseAuthTestHelper {
  static const String testFirebaseEmail = 'test-user@firebase-test.com';
  static const String testFirebasePassword = 'Test123456!';
  
  static const String adminTestEmail = 'admin@socilo-reply.com';
  static const String adminTestPassword = 'Admin123456!';
  
  static const String moderatorTestEmail = 'moderator@socilo-reply.com';
  static const String moderatorTestPassword = 'Moderator123456!';
  
  // Test user data
  static const Map<String, dynamic> testUserData = {
    'uid': 'test-uid-12345',
    'email': testFirebaseEmail,
    'displayName': 'Test User',
    'role': 'user',
    'createdAt': '2024-01-01T00:00:00.000Z',
    'isEmailVerified': true,
  };
  
  static const Map<String, dynamic> adminUserData = {
    'uid': 'admin-uid-12345',
    'email': adminTestEmail,
    'displayName': 'Admin User',
    'role': 'admin',
    'createdAt': '2024-01-01T00:00:00.000Z',
    'isEmailVerified': true,
  };
}

// Usage Example:
/*
void main() async {
  // Test email sending
  bool emailSent = await TestEmailService.sendTestEmail(
    to: TestEmailConfig.testRecipients.first,
    subject: 'Test Email',
    body: TestEmailConfig.testEmailTemplates['welcome']!,
  );
  
  if (emailSent) {
    print('✅ Test email sent successfully!');
  } else {
    print('❌ Failed to send test email');
  }
  
  // Test credential validation
  bool credentialsValid = await TestEmailService.validateEmailCredentials(
    email: TestEmailConfig.testEmail,
    password: TestEmailConfig.testPassword,
  );
  
  if (credentialsValid) {
    print('✅ Email credentials are valid!');
  } else {
    print('❌ Invalid email credentials');
  }
  
  // Get email history
  List<String> history = await TestEmailService.getTestEmailHistory();
  print('📧 Email History:');
  for (String entry in history) {
    print('  - $entry');
  }
}
*/
