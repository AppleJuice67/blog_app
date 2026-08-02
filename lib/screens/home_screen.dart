import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';

import '../widgets/post_card.dart';

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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          "The Daily Byte", // A more "Blog" name
          style: TextStyle(fontFamily: 'Georgia', letterSpacing: 0.5),
        ),
        actions: [
          // Authentication actions styled simply
          if (!authProvider.isLoggedIn) ...[
            TextButton(
              onPressed: () => context.push('/login'),
              child: const Text("Login"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () => context.push('/register'),
                child: const Text("Join"),
              ),
            ),
          ],

          if (authProvider.isLoggedIn)
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout_rounded),
              onPressed: () async => await authProvider.logout(),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => postProvider.fetchPosts(),
        child: Column(
          children: [
            // Welcome or Category Header for that blog feel
            if (postProvider.posts.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Featured Stories",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),

            // Main Blog Feed
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: postProvider.posts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
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

            // Pagination Controls at the bottom
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page ${postProvider.currentPage + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: postProvider.currentPage > 0
                            ? () => postProvider.previousPage()
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: postProvider.posts.length == postProvider.pageSize
                            ? () => postProvider.nextPage()
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Floating action button for new posts
      floatingActionButton: authProvider.isLoggedIn
          ? FloatingActionButton(
              onPressed: () async {
                await context.push('/create-post');
                postProvider.fetchPosts();
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.edit_note_rounded, size: 28),
            )
          : null,
    );
    }
  }
