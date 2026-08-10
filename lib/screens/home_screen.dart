import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Import for custom typography
import 'package:intl/intl.dart'; // Added missing import for DateFormat
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/web_painter.dart'; // Spider-web decoration

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
        // The red top bar with a subtle web pattern
        flexibleSpace: CustomPaint(
          painter: WebPainter(color: Colors.white24),
          child: Container(),
        ),
        title: const Text("ARE YOU INFORMED?"),
        actions: [
          if (!authProvider.isLoggedIn) ...[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: () => context.push('/login'),
              child: const Text("LOGIN"),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2980B9), // Spidey Blue
                  foregroundColor: Colors.white,
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                onPressed: () => context.push('/register'),
                child: const Text("JOIN"),
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // DAILY BUGLE BRANDING SECTION
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: const Border(bottom: BorderSide(color: Colors.black, width: 3)),
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Stack(
                    children: [
                      // Background Web
                      Positioned.fill(
                        child: CustomPaint(
                          painter: WebPainter(color: Colors.black12),
                        ),
                      ),
                      Column(
                        children: [
                          // Iconic Newspaper Title
                          Text(
                            "DAILY BUGLE",
                            style: GoogleFonts.bebasNeue(
                              fontSize: 76,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: 3,
                            ),
                          ),
                          // The decorative black lines and metadata
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: const BoxDecoration(
                              border: Border.symmetric(
                                horizontal: BorderSide(color: Colors.black, width: 3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("SPECIAL EDITION", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                                Text(
                                  DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()).toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                                ),
                                const Text("PRICE 50¢", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Featured Stories Headline
                if (postProvider.posts.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "FACT OR FICTION",
                          style: GoogleFonts.bebasNeue(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          "LATEST NEWS FROM THE CITY",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(color: Colors.black, thickness: 3),
                      ],
                    ),
                  ),

                // Main Feed
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: postProvider.posts.length,
                    separatorBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(color: Colors.black26),
                    ),
                    itemBuilder: (context, index) {
                      final post = postProvider.posts[index];
                      return PostCard(
                        id: post['id'],
                        authorId: post['user_id'] ?? '',
                        title: post['title'] ?? '',
                        subtitle: post['subtitle'] ?? '',
                        content: post['content'] ?? '',
                        imageUrl: post['image_url'],
                        createdAt: post['created_at'],
                        username: post['username'] ?? 'Unknown User',
                        isLoggedIn: authProvider.isLoggedIn,
                        onRefresh: postProvider.fetchPosts,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black, width: 2)),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(12),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EDITION ${postProvider.currentPage + 1}',
                style: GoogleFonts.bebasNeue(fontSize: 18),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: postProvider.currentPage > 0 ? () => postProvider.previousPage() : null,
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: EdgeInsets.only(right: authProvider.isLoggedIn ? 70 : 0),
                    child: IconButton(
                      onPressed: postProvider.posts.length == postProvider.pageSize ? () => postProvider.nextPage() : null,
                      icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: authProvider.isLoggedIn
          ? FloatingActionButton(
              onPressed: () async {
                await context.push('/create-post');
                postProvider.fetchPosts();
              },
              backgroundColor: const Color(0xFFC0392B),
              shape: const CircleBorder(side: BorderSide(color: Colors.black, width: 2)),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
