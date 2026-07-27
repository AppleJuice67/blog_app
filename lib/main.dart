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

    bool isLoggedIn = false;

    void checkLoginStatus() {
      final session = Supabase.instance.client.auth.currentSession;

      setState(() {
        isLoggedIn = session != null;
      });
    }

    Future<void> fetchPosts() async {
      final response = await Supabase.instance.client
          .from('posts')
          .select();

      setState(() {
        posts = List<Map<String, dynamic>>.from(response);
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
        home: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Blog App'),
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
              body: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return PostCard(
                    id: posts[index]['id'],
                    title: posts[index]['title'] ?? '',
                    subtitle: posts[index]['subtitle'] ?? '',
                    content: posts[index]['content'] ?? '',
                    imageUrl: posts[index]['image_url'],
                    isLoggedIn: isLoggedIn,
                    onRefresh: fetchPosts,
                  );
                },
              ),

              floatingActionButton: isLoggedIn
                  ? FloatingActionButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreatePostScreen(),
                    ),
                  );

                  fetchPosts();
                },
                child: const Icon(Icons.add),
              )
                  : null,
            );
          },
        ),
      );
    }
  }


