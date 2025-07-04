import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/comment_provider.dart';
import '../models/comment.dart';
import '../theme/app_theme.dart';
import 'comment_detail_screen.dart';

class CommentsListScreen extends StatelessWidget {
  const CommentsListScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Consumer<CommentProvider>(
      builder: (context, commentProvider, child) {
        if (commentProvider.isLoading && commentProvider.pendingComments.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (commentProvider.pendingComments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.comment_outlined,
                  size: 64,
                  color: AppTheme.textDisabledColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No pending comments',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textDisabledColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'New comments will appear here automatically',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textDisabledColor,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await commentProvider.fetchPendingComments();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: commentProvider.pendingComments.length,
            itemBuilder: (context, index) {
              final comment = commentProvider.pendingComments[index];
              return CommentCard(
                comment: comment,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentDetailScreen(comment: comment),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class CommentCard extends StatelessWidget {
  final Comment comment;
  final VoidCallback onTap;

  const CommentCard({
    super.key,
    required this.comment,
    required this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('MMM dd, yyyy • HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with commenter name and type badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      comment.commenterName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCommentTypeColor(comment.commentType),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getCommentTypeLabel(comment.commentType),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Comment text (truncated)
              Text(
                comment.commentText,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Footer with timestamp and AI analysis info
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.textDisabledColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeFormat.format(comment.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textDisabledColor,
                    ),
                  ),
                  const Spacer(),
                  if (comment.aiAnalysis != null) ...[
                    Icon(
                      Icons.psychology,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI Analyzed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
