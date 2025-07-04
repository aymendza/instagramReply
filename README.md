# SociloReply - Smart Comment Moderation App

A Flutter mobile application for managing Instagram comments with AI analysis integration.

## Features

- 📱 Cross-platform (iOS & Android)
- 🔐 Firebase Authentication
- 📊 Real-time comment monitoring
- 🤖 AI comment analysis integration
- 📝 Reply template management
- 🎯 Active post management
- 🔄 n8n workflow integration

## Firebase Setup

### 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `socilo-reply` (or your preferred name)
4. Enable Google Analytics (optional)
5. Create project

### 2. Configure Authentication

1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" provider
5. Create your first user account in the "Users" tab

### 3. Configure Firestore Database

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (or production mode with proper rules)
4. Select your preferred location
5. Create the following collections:

#### Collection: `comments_for_review`
```json
{
  "commenter_name": "string",
  "comment_text": "string", 
  "status": "pending|approved|rejected",
  "created_at": "timestamp",
  "comment_type": "string",
  "analysis": "map",
  "reply_text": "string"
}
```

#### Collection: `reply_templates`
```json
{
  "category": "string",
  "template_text": "string"
}
```

#### Collection: `active_posts`
```json
{
  "post_id": "string",
  "post_thumbnail_url": "string",
  "is_active": "boolean"
}
```

### 4. Configure the Flutter App

1. Install Flutter and Firebase CLI
2. Run the FlutterFire configuration:
   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

3. This will automatically generate `firebase_options.dart` with your project configuration

4. Update `lib/config/firebase_config.dart` with your n8n webhook URL:
   ```dart
   static const String n8nWebhookUrl = 'https://your-n8n-instance.com/webhook/execute-reply';
   ```

### 5. Firestore Security Rules

Update your Firestore rules for proper security:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their data
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## n8n Workflow Integration

### Webhook Structure

The app expects an n8n webhook that receives:
```json
{
  "id": "comment_document_id"
}
```

### Workflow Requirements

Your n8n workflow should:
1. Receive Instagram comments via webhook
2. Analyze comments using AI (OpenAI, etc.)
3. Store results in Firestore `comments_for_review` collection
4. Handle reply execution when called by the app

### Sample n8n Workflow Nodes

1. **Instagram Webhook** - Receives comment notifications
2. **AI Analysis** - Processes comment sentiment/type
3. **Firestore Insert** - Stores comment for review
4. **Reply Webhook** - Handles approved replies
5. **Instagram API** - Posts replies back to Instagram

## Installation & Development

### Prerequisites

- Flutter SDK (>= 3.0.0)
- Firebase account
- Android Studio / Xcode for mobile development

### Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   cd socilo_reply
   flutter pub get
   ```

3. Configure Firebase (see Firebase Setup section)

4. Run the app:
   ```bash
   flutter run
   ```

## App Structure

```
lib/
├── config/
│   └── firebase_config.dart     # Firebase configuration
├── models/
│   ├── comment.dart            # Comment data model
│   ├── reply_template.dart     # Template data model
│   └── active_post.dart        # Post data model
├── providers/
│   ├── auth_provider.dart      # Authentication state
│   ├── comment_provider.dart   # Comment management
│   ├── template_provider.dart  # Template management
│   └── post_provider.dart      # Post management
├── screens/
│   ├── login_screen.dart       # Authentication screen
│   ├── main_dashboard.dart     # Main app navigation
│   ├── comments_list_screen.dart    # Comment list view
│   ├── comment_detail_screen.dart   # Comment details & reply
│   ├── settings_screen.dart    # Settings navigation
│   ├── manage_templates_screen.dart # Template management
│   └── manage_posts_screen.dart     # Post management
├── widgets/
│   └── reply_templates_modal.dart   # Template selection modal
├── theme/
│   └── app_theme.dart          # App styling
├── firebase_options.dart       # Firebase platform config
└── main.dart                   # App entry point
```

## Usage

### Login
1. Use your Firebase Auth credentials to log in
2. First-time setup requires creating a user in Firebase Console

### Comment Management
1. New comments appear automatically in the main dashboard
2. Tap a comment to view details and AI analysis
3. Choose to approve with reply, edit reply, or reject
4. Use templates for quick responses

### Template Management
1. Go to Settings > Templates
2. Create categorized reply templates
3. Use templates when replying to comments

### Post Management
1. Go to Settings > Active Posts
2. Add Instagram post IDs to monitor
3. Toggle active/inactive status

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For questions or support, please contact the development team.
