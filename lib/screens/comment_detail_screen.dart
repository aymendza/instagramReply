import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/comment.dart';
import '../providers/comment_provider.dart';
import '../providers/template_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/reply_templates_modal.dart';

class CommentDetailScreen extends StatefulWidget {
  final Comment comment;

  const CommentDetailScreen({
    super.key,
    required this.comment,
  });

  @override
  State<CommentDetailScreen> createState() => _CommentDetailScreenState();
}

class _CommentDetailScreenState extends State<CommentDetailScreen> {
  final _replyController = TextEditingController();
  bool _isReplying = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Color _getCommentTypeColor(String commentType) {
    switch (commentType.toLowerCase()) {
      case 'compliment':
        return AppColors.complimentColor;
      case 'question':
        return AppColors.questionColor;
      case 'criticism':
        return AppColors.criticismColor;
      default:
        return AppColors.pendingColor;
    }
  }

  String _getCommentTypeLabel(String commentType) {
    switch (commentType.toLowerCase()) {
      case 'compliment':
        return 'Compliment';
      case 'question':
        return 'Question';
      case 'criticism':
        return 'Criticism';
      default:
        return 'Unknown';
    }
  }

  Future<void> _openInstagramPost() async {
    // Extract post ID from analysis or use a default
    String? postId;
    if (widget.comment.aiAnalysis != null && 
        widget.comment.aiAnalysis!.containsKey('post_id')) {
      postId = widget.comment.aiAnalysis!['post_id'];
    }
    
    if (postId != null) {
      final url = 'https://instagram.com/p/$postId';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open Instagram post')),
          );
        }
      }
    }
  }

  void _showTemplatesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ReplyTemplatesModal(
        onTemplateSelected: (template) {
          _replyController.text = template.templateText;
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _approveAndSendReply() async {
    if (_replyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a reply message'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() {
      _isReplying = true;
    });

    final commentProvider = context.read<CommentProvider>();
    final success = await commentProvider.approveComment(
      widget.comment.id,
      _replyController.text.trim(),
    );

    setState(() {
      _isReplying = false;
    });

    if (success) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reply sent successfully!'),
            backgroundColor: AppColors.approvedColor,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(commentProvider.errorMessage ?? 'Failed to send reply'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _rejectComment() async {
    final shouldReject = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Comment'),
        content: const Text('Are you sure you want to reject this comment? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (shouldReject == true) {
      final commentProvider = context.read<CommentProvider>();
      final success = await commentProvider.rejectComment(widget.comment.id);
      
      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment rejected'),
            backgroundColor: AppColors.rejectedColor,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(commentProvider.errorMessage ?? 'Failed to reject comment'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('MMMM dd, yyyy • HH:mm');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comment Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: _openInstagramPost,
            tooltip: 'Open Instagram Post',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Comment Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppTheme.primaryColor,
                                child: Text(
                                  widget.comment.commenterName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.comment.commenterName,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      timeFormat.format(widget.comment.createdAt),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getCommentTypeColor(widget.comment.commentType),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getCommentTypeLabel(widget.comment.commentType),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.textDisabledColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              widget.comment.commentText,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // AI Analysis Card
                  if (widget.comment.aiAnalysis != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.psychology,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'AI Analysis',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...widget.comment.aiAnalysis!.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        '${entry.key.replaceAll('_', ' ').toUpperCase()}:',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        entry.value.toString(),
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Reply Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Reply',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: _showTemplatesModal,
                                icon: const Icon(Icons.library_books, size: 18),
                                label: const Text('Use Template'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _replyController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Write your reply...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isReplying ? null : _rejectComment,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: (_isReplying || _replyController.text.trim().isEmpty) 
                        ? null 
                        : _approveAndSendReply,
                    child: _isReplying
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Approve & Send Reply'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
