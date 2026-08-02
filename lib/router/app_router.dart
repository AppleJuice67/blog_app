import 'package:go_router/go_router.dart';
import '../screens/create_post_screen.dart';
import '../screens/login_screen.dart';
import '../screens/post_details_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: '/create-post',
      builder: (context, state) => const CreatePostScreen(),
    ),

    GoRoute(
      path: '/post',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;

        return PostDetailsScreen(
          postId: extra['postId'],
          title: extra['title'],
          subtitle: extra['subtitle'],
          content: extra['content'],
        );
      },
    ),
  ],
);