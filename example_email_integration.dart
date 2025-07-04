import 'package:flutter/material.dart';
import 'test_email_config.dart';

// Example of how to integrate test email functionality in your Flutter app
class EmailTestScreen extends StatefulWidget {
  const EmailTestScreen({Key? key}) : super(key: key);

  @override
  _EmailTestScreenState createState() => _EmailTestScreenState();
}

class _EmailTestScreenState extends State<EmailTestScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    // Pre-fill with test credentials
    _emailController.text = TestEmailConfig.testEmail;
    _passwordController.text = TestEmailConfig.testPassword;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _testEmailSending() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing email functionality...';
    });

    try {
      // Test email sending
      bool emailSent = await TestEmailService.sendTestEmail(
        to: TestEmailConfig.testRecipients.first,
        subject: 'Test Email from Flutter App',
        body: TestEmailConfig.testEmailTemplates['welcome']!,
      );

      setState(() {
        _statusMessage = emailSent 
            ? '✅ Test email sent successfully!' 
            : '❌ Failed to send test email';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testEmailValidation() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Validating email credentials...';
    });

    try {
      bool credentialsValid = await TestEmailService.validateEmailCredentials(
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() {
        _statusMessage = credentialsValid 
            ? '✅ Email credentials are valid!' 
            : '❌ Invalid email credentials';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPresetCredentials(String type) async {
    setState(() {
      switch (type) {
        case 'test':
          _emailController.text = TestEmailConfig.testEmail;
          _passwordController.text = TestEmailConfig.testPassword;
          break;
        case 'firebase':
          _emailController.text = FirebaseAuthTestHelper.testFirebaseEmail;
          _passwordController.text = FirebaseAuthTestHelper.testFirebasePassword;
          break;
        case 'admin':
          _emailController.text = FirebaseAuthTestHelper.adminTestEmail;
          _passwordController.text = FirebaseAuthTestHelper.adminTestPassword;
          break;
        case 'moderator':
          _emailController.text = FirebaseAuthTestHelper.moderatorTestEmail;
          _passwordController.text = FirebaseAuthTestHelper.moderatorTestPassword;
          break;
      }
      _statusMessage = 'Loaded $type credentials';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Test Configuration'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test Email Credentials',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            
            // Email field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Password field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            
            // Preset credential buttons
            const Text(
              'Load Preset Credentials:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _loadPresetCredentials('test'),
                    child: const Text('Test'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _loadPresetCredentials('firebase'),
                    child: const Text('Firebase'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _loadPresetCredentials('admin'),
                    child: const Text('Admin'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _loadPresetCredentials('moderator'),
                    child: const Text('Moderator'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // Test buttons
            ElevatedButton(
              onPressed: _isLoading ? null : _testEmailSending,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Test Email Sending',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testEmailValidation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Test Email Validation',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            
            // Status message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _statusMessage.isEmpty ? 'Ready to test email functionality' : _statusMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: _statusMessage.startsWith('✅') ? Colors.green : 
                         _statusMessage.startsWith('❌') ? Colors.red : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Configuration info
            ExpansionTile(
              title: const Text('SMTP Configuration'),
              children: [
                ListTile(
                  title: const Text('Host'),
                  subtitle: Text(TestEmailConfig.smtpHost),
                ),
                ListTile(
                  title: const Text('Port'),
                  subtitle: Text(TestEmailConfig.smtpPort.toString()),
                ),
                ListTile(
                  title: const Text('SSL'),
                  subtitle: Text(TestEmailConfig.useSSL.toString()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Example usage in your app
class EmailTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Email Test App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const EmailTestScreen(),
    );
  }
}

// Helper function to demonstrate email functionality
Future<void> demonstrateEmailFunctionality() async {
  print('🚀 Starting Email Functionality Demo...\n');
  
  // Test 1: Email sending
  print('📧 Testing Email Sending...');
  bool emailSent = await TestEmailService.sendTestEmail(
    to: TestEmailConfig.testRecipients.first,
    subject: 'Demo Email',
    body: TestEmailConfig.testEmailTemplates['welcome']!,
  );
  print('Result: ${emailSent ? "SUCCESS" : "FAILED"}\n');
  
  // Test 2: Credential validation
  print('🔐 Testing Credential Validation...');
  bool credentialsValid = await TestEmailService.validateEmailCredentials(
    email: TestEmailConfig.testEmail,
    password: TestEmailConfig.testPassword,
  );
  print('Result: ${credentialsValid ? "SUCCESS" : "FAILED"}\n');
  
  // Test 3: Email history
  print('📋 Testing Email History...');
  List<String> history = await TestEmailService.getTestEmailHistory();
  print('History entries: ${history.length}');
  for (String entry in history) {
    print('  - $entry');
  }
  print('\n✅ Email functionality demonstration complete!');
}

// To run the demo:
// demonstrateEmailFunctionality();
