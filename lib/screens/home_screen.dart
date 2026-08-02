import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';

import '../widgets/post_card.dart';
import 'create_post_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {

    final postProvider = context.watch<PostProvider>();
    final authProvider = context.watch<AuthProvider>();


    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_rounded,
              color: Colors.blue,
            ),
            SizedBox(width: 8),
            Text(
              "Supabase Blog App",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          if (!authProvider.isLoggedIn) ...[
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () async {
                await context.push('/register');
              },
            ),

            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () async {
                await context.push('/login');
              },
            ),
          ],

          if (authProvider.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authProvider.logout();
              },
            ),
        ],
      ),
      body: Column(
        children: [

          Expanded(
            child: ListView.builder(
              itemCount: postProvider.posts.length,
              itemBuilder: (context, index) {
                return PostCard(
                  id: postProvider.posts[index]['id'],
                  title: postProvider.posts[index]['title'] ?? '',
                  subtitle: postProvider.posts[index]['subtitle'] ?? '',
                  content: postProvider.posts[index]['content'] ?? '',
                  imageUrl: postProvider.posts[index]['image_url'],
                  createdAt: postProvider.posts[index]['created_at'],
                  username: postProvider.posts[index]['username'] ?? 'Unknown User',
                  isLoggedIn: authProvider.isLoggedIn,
                  onRefresh: postProvider.fetchPosts,
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            ElevatedButton.icon(
              onPressed: postProvider.currentPage > 0
                  ? () => postProvider.previousPage()
                  : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
            ),


            Text(
              'Page ${postProvider.currentPage + 1}',
            ),


            ElevatedButton.icon(
              onPressed: postProvider.posts.length == postProvider.pageSize
                  ? () => postProvider.nextPage()
                  : null,

              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next'),
            ),

          ],
        ),
      ),

      floatingActionButton: authProvider.isLoggedIn
          ? FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/create-post');

          postProvider.fetchPosts();
        },
        icon: const Icon(Icons.add),
        label: const Text("New Post"),
      )
          : null,
      );
    }
  }
