import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/template_provider.dart';
import '../models/reply_template.dart';
import '../theme/app_theme.dart';

class ManageTemplatesScreen extends StatelessWidget {
  const ManageTemplatesScreen({super.key});

  void _showTemplateDialog(BuildContext context, {ReplyTemplate? template}) {
    showDialog(
      context: context,
      builder: (context) => TemplateDialog(template: template),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TemplateProvider>(
        builder: (context, templateProvider, child) {
          if (templateProvider.isLoading && templateProvider.templates.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (templateProvider.templates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 64,
                    color: AppTheme.textDisabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No templates yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textDisabledColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first reply template',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textDisabledColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showTemplateDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Template'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: templateProvider.templates.length,
            itemBuilder: (context, index) {
              final template = templateProvider.templates[index];
              return TemplateListItem(
                template: template,
                onEdit: () => _showTemplateDialog(context, template: template),
                onDelete: () => _showDeleteDialog(context, template),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTemplateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ReplyTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.templateText.substring(0, 50)}..."?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final templateProvider = context.read<TemplateProvider>();
              final success = await templateProvider.deleteTemplate(template.id);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Template deleted' : 'Failed to delete template'),
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

class TemplateListItem extends StatelessWidget {
  final ReplyTemplate template;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TemplateListItem({
    super.key,
    required this.template,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                template.category,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            template.templateText,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        trailing: PopupMenuButton<String>(
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
      ),
    );
  }
}

class TemplateDialog extends StatefulWidget {
  final ReplyTemplate? template;

  const TemplateDialog({
    super.key,
    this.template,
  });

  @override
  State<TemplateDialog> createState() => _TemplateDialogState();
}

class _TemplateDialogState extends State<TemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _templateController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.template != null) {
      _categoryController.text = widget.template!.category;
      _templateController.text = widget.template!.templateText;
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _templateController.dispose();
    super.dispose();
  }

  Future<void> _saveTemplate() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final templateProvider = context.read<TemplateProvider>();
      bool success;

      if (widget.template != null) {
        success = await templateProvider.updateTemplate(
          widget.template!.id,
          _categoryController.text.trim(),
          _templateController.text.trim(),
        );
      } else {
        success = await templateProvider.createTemplate(
          _categoryController.text.trim(),
          _templateController.text.trim(),
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
              content: Text(widget.template != null ? 'Template updated' : 'Template created'),
              backgroundColor: AppColors.approvedColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(templateProvider.errorMessage ?? 'Failed to save template'),
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
      title: Text(widget.template != null ? 'Edit Template' : 'Add Template'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'e.g., Compliment, General Question',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _templateController,
              decoration: const InputDecoration(
                labelText: 'Template Text',
                hintText: 'Enter your reply template...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter template text';
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
          onPressed: _isLoading ? null : _saveTemplate,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.template != null ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}
