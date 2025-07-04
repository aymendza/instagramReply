class FirebaseConfig {
  // Firebase collections
  static const String commentsCollection = 'comments_for_review';
  static const String templatesCollection = 'reply_templates';
  static const String postsCollection = 'active_posts';
  
  // n8n webhook URL for executing replies
  static const String n8nWebhookUrl = 'https://your-n8n-instance.com/webhook/execute-reply';
}
