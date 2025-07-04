import 'package:flutter/material.dart';
import '../screens/manage_templates_screen.dart';
import '../screens/manage_posts_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.library_books),
                text: 'Templates',
              ),
              Tab(
                icon: Icon(Icons.post_add),
                text: 'Active Posts',
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              ManageTemplatesScreen(),
              ManagePostsScreen(),
            ],
          ),
        ),
      ],
    );
  }
}
