import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/comment_provider.dart';
import '../providers/template_provider.dart';
import '../providers/post_provider.dart';
import '../theme/app_theme.dart';
import 'comments_list_screen.dart';
import 'settings_screen.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
    
    // Initialize data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeData() {
    final commentProvider = context.read<CommentProvider>();
    final templateProvider = context.read<TemplateProvider>();
    final postProvider = context.read<PostProvider>();

    // Fetch initial data
    commentProvider.fetchPendingComments();
    templateProvider.fetchTemplates();
    postProvider.fetchPosts();

    // Subscribe to realtime updates
    commentProvider.subscribeToComments();
  }

  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
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
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      final commentProvider = context.read<CommentProvider>();
      commentProvider.unsubscribeFromComments();
      
      final authProvider = context.read<AuthProvider>();
      await authProvider.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SociloReply'),
        elevation: 0,
        actions: [
          Consumer<CommentProvider>(
            builder: (context, commentProvider, child) {
              final pendingCount = commentProvider.pendingComments.length;
              if (pendingCount > 0 && _currentIndex == 0) {
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.pendingColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$pendingCount pending',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.comment),
              text: 'Comments',
            ),
            Tab(
              icon: Icon(Icons.settings),
              text: 'Settings',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CommentsListScreen(),
          SettingsScreen(),
        ],
      ),
    );
  }
}
