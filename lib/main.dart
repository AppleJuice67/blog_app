  import 'package:flutter/material.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';
  import 'widgets/post_card.dart';
  import 'screens/create_post_screen.dart';
  import 'screens/register_screen.dart';
  import 'screens/login_screen.dart';

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
      url: 'https://rffcocrodabklbbwazwn.supabase.co',
      anonKey: 'sb_publishable_jgW8dYxT0HLdHW7NzF3WJA_v8jjxjK7',
    );

    runApp(const MyApp());
  }

  class MyApp extends StatefulWidget {
    const MyApp({super.key});

    @override
    State<MyApp> createState() => _MyAppState();
  }

  class _MyAppState extends State<MyApp> {

    List<Map<String, dynamic>> posts = [];
    int currentPage = 0;
    final int pageSize = 5;

    bool isLoggedIn = false;

    void checkLoginStatus() {
      final session = Supabase.instance.client.auth.currentSession;

      setState(() {
        isLoggedIn = session != null;
      });
    }

    Future<void> fetchPosts() async {

      final from = currentPage * pageSize;
      final to = from + pageSize - 1;

      final response = await Supabase.instance.client
          .from('posts')
          .select()
          .order('id', ascending: false)
          .range(from, to);

      List<Map<String, dynamic>> loadedPosts = [];

      for (final post in response) {

        // Get the first image
        final images = await Supabase.instance.client
            .from('post_images')
            .select('image_url')
            .eq('post_id', post['id'])
            .limit(1);

        post['image_url'] =
        images.isNotEmpty ? images.first['image_url'] : null;

        // Get the author's username
        if (post['user_id'] != null) {
          final profile = await Supabase.instance.client
              .from('profiles')
              .select('username')
              .eq('id', post['user_id'])
              .maybeSingle();

          post['username'] = profile?['username'] ?? 'Unknown User';
        } else {
          post['username'] = 'Unknown User';
        }

        loadedPosts.add(post);
      }

      setState(() {
        posts = loadedPosts;
      });
    }

    @override
    void initState() {
      super.initState();
      fetchPosts();
      checkLoginStatus();
    }

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Blog App',

        theme: ThemeData(
          useMaterial3: true,

          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
          ),

          scaffoldBackgroundColor: const Color(0xFFF5F7FA),

          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            centerTitle: true,
            elevation: 0,
          ),

          cardTheme: CardThemeData(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
          ),
        ),

        home: Builder(
          builder: (context) {
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
                  if (!isLoggedIn) ...[
                    IconButton(
                      icon: const Icon(Icons.person_add),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                        checkLoginStatus();
                      },
                    ),

                    IconButton(
                      icon: const Icon(Icons.login),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );

                        checkLoginStatus();
                      },
                    ),
                  ],

                  if (isLoggedIn)
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();

                        checkLoginStatus();
                      },
                    ),
                ],
              ),
              body: Column(
                children: [

                  Expanded(
                    child: ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return PostCard(
                          id: posts[index]['id'],
                          title: posts[index]['title'] ?? '',
                          subtitle: posts[index]['subtitle'] ?? '',
                          content: posts[index]['content'] ?? '',
                          imageUrl: posts[index]['image_url'],
                          createdAt: posts[index]['created_at'],
                          username: posts[index]['username'] ?? 'Unknown User',
                          isLoggedIn: isLoggedIn,
                          onRefresh: fetchPosts,
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
                      onPressed: currentPage > 0
                          ? () {
                        setState(() {
                          currentPage--;
                        });

                        fetchPosts();
                      }
                          : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),


                    Text(
                      'Page ${currentPage + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),


                    ElevatedButton.icon(
                      onPressed: posts.length == pageSize
                          ? () {
                        setState(() {
                          currentPage++;
                        });

                        fetchPosts();
                      }
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                    ),

                  ],
                ),
              ),

              floatingActionButton: isLoggedIn
                  ? FloatingActionButton.extended(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreatePostScreen(),
                    ),
                  );

                  fetchPosts();
                },
                icon: const Icon(Icons.add),
                label: const Text("New Post"),
              )
                  : null,
            );
          },
        ),
      );
    }
  }


