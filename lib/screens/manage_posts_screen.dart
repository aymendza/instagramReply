import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/post_provider.dart';
import '../models/active_post.dart';
import '../theme/app_theme.dart';

class ManagePostsScreen extends StatelessWidget {
  const ManagePostsScreen({super.key});

  void _showPostDialog(BuildContext context, {ActivePost? post}) {
    showDialog(
      context: context,
      builder: (context) => PostDialog(post: post),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          if (postProvider.isLoading && postProvider.posts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (postProvider.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.post_add_outlined,
                    size: 64,
                    color: AppTheme.textDisabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No active posts yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textDisabledColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add Instagram posts to manage',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textDisabledColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showPostDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Post'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: postProvider.posts.length,
            itemBuilder: (context, index) {
              final post = postProvider.posts[index];
              return PostListItem(
                post: post,
                onToggle: () async {
                  final success = await postProvider.togglePostStatus(post.id);
                  if (context.mounted && !success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(postProvider.errorMessage ?? 'Failed to update post'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                },
                onEdit: () => _showPostDialog(context, post: post),
                onDelete: () => _showDeleteDialog(context, post),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPostDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ActivePost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: Text('Are you sure you want to remove post "${post.postId}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final postProvider = context.read<PostProvider>();
              final success = await postProvider.deletePost(post.id);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Post deleted' : 'Failed to delete post'),
                    backgroundColor: success ? AppColors.approvedColor : AppTheme.errorColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class PostListItem extends StatelessWidget {
  final ActivePost post;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PostListItem({
    super.key,
    required this.post,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: post.postThumbnailUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: post.postThumbnailUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60,
                    height: 60,
                    color: AppTheme.backgroundColor,
                    child: const Icon(Icons.image),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60,
                    height: 60,
                    color: AppTheme.backgroundColor,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image),
              ),
        title: Text(
          post.postId,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: post.isActive 
                    ? AppColors.approvedColor.withOpacity(0.2)
                    : AppTheme.textDisabledColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                post.isActive ? 'Active' : 'Inactive',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: post.isActive 
                      ? AppColors.approvedColor
                      : AppTheme.textDisabledColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: post.isActive,
              onChanged: (_) => onToggle(),
              activeColor: AppColors.approvedColor,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PostDialog extends StatefulWidget {
  final ActivePost? post;

  const PostDialog({
    super.key,
    this.post,
  });

  @override
  State<PostDialog> createState() => _PostDialogState();
}

class _PostDialogState extends State<PostDialog> {
  final _formKey = GlobalKey<FormState>();
  final _postIdController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _postIdController.text = widget.post!.postId;
      _thumbnailUrlController.text = widget.post!.postThumbnailUrl ?? '';
    }
  }

  @override
  void dispose() {
    _postIdController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  Future<void> _savePost() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final postProvider = context.read<PostProvider>();
      bool success;

      final thumbnailUrl = _thumbnailUrlController.text.trim().isEmpty 
          ? null 
          : _thumbnailUrlController.text.trim();

      if (widget.post != null) {
        success = await postProvider.updatePost(
          widget.post!.id,
          _postIdController.text.trim(),
          thumbnailUrl,
        );
      } else {
        success = await postProvider.createPost(
          _postIdController.text.trim(),
          thumbnailUrl,
        );
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.post != null ? 'Post updated' : 'Post added'),
              backgroundColor: AppColors.approvedColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(postProvider.errorMessage ?? 'Failed to save post'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.post != null ? 'Edit Post' : 'Add Post'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _postIdController,
              decoration: const InputDecoration(
                labelText: 'Post ID *',
                hintText: 'e.g., CXnBu9wJYzm',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a post ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _thumbnailUrlController,
              decoration: const InputDecoration(
                labelText: 'Thumbnail URL (optional)',
                hintText: 'https://example.com/image.jpg',
              ),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  final uri = Uri.tryParse(value.trim());
                  if (uri == null || !uri.hasAbsolutePath) {
                    return 'Please enter a valid URL';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _savePost,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.post != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
