import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Added google_fonts for newspaper typography
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/comment_provider.dart';

import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rffcocrodabklbbwazwn.supabase.co',
    anonKey: 'sb_publishable_jgW8dYxT0HLdHW7NzF3WJA_v8jjxjK7',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => PostProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => CommentProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'The Daily Bugle',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      theme: ThemeData(
        useMaterial3: true,
        // SPIDER-MAN & DAILY BUGLE THEME
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC0392B), // Spidey Red
          primary: const Color(0xFFC0392B),
          secondary: const Color(0xFF2980B9), // Spidey Blue
          surface: const Color(0xFFF4F1EA),   // Newsprint
          background: const Color(0xFFF4F1EA),
          onBackground: Colors.black,
          onSurface: Colors.black,
        ),
        // NEWSPAPER TYPOGRAPHY
        textTheme: TextTheme(
          displayLarge: GoogleFonts.bebasNeue(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 1.2,
          ),
          displayMedium: GoogleFonts.bebasNeue(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          titleLarge: GoogleFonts.bebasNeue(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
          bodyLarge: GoogleFonts.playfairDisplay(
            fontSize: 18,
            height: 1.5,
            color: Colors.black87,
          ),
          bodyMedium: GoogleFonts.playfairDisplay(
            fontSize: 16,
            height: 1.4,
            color: Colors.black87,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFC0392B), // Spidey Red
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 4, // More elevation for a "heroic" pop
          shadowColor: Colors.black87,
          titleTextStyle: GoogleFonts.bebasNeue(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actionsIconTheme: const IconThemeData(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 4, // 3D comic effect
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // Slightly rounded for hero feel
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC0392B),
            foregroundColor: Colors.white,
            elevation: 6, // COMIC POP: Strong shadow
            shadowColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Heroic curve
              side: const BorderSide(color: Colors.black, width: 2), // Bold ink outline
            ),
            textStyle: GoogleFonts.bebasNeue(fontSize: 18, letterSpacing: 1.5),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.bebasNeue(fontSize: 18, letterSpacing: 1),
          ),
        ),
      ),
    );
  }
}