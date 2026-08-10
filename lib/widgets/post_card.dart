import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; // Import for newspaper fonts
import '../screens/post_details_screen.dart';
import '../screens/create_post_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';

class PostCard extends StatelessWidget {
  final int id;
  final String title;
  final String subtitle;
  final String content;
  final String? imageUrl;
  final String authorId;
  final String username;
  final String? createdAt;
  final VoidCallback onRefresh;
  final bool isLoggedIn;

  const PostCard({
    super.key,
    required this.id,
    required this.authorId,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.imageUrl,
    required this.username,
    required this.createdAt,
    required this.onRefresh,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        // Thick black border like a newspaper section
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailsScreen(
                postId: id,
                title: title,
                subtitle: subtitle,
                content: content,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE SECTION with a thick black frame
            if (imageUrl != null && imageUrl!.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, color: Colors.black),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Centered Column
                children: [
                  // Loud, uppercase headline using Bebas Neue
                  Text(
                    title.toUpperCase(),
                    maxLines: 2, // Strict 2-line limit
                    overflow: TextOverflow.ellipsis,
                    softWrap: true, // Allow wrapping for sentences
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bebasNeue(
                      fontSize: 22, // Reduced size to prevent layout breaks
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Newspaper By-line centered
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Horizontal centering
                    children: [
                      Text(
                        "BY ${username.toUpperCase()}",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text("•", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text(
                        createdAt != null
                            ? DateFormat('MMM dd, yyyy').format(DateTime.parse(createdAt!)).toUpperCase()
                            : 'LATEST EDITION',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: Colors.black, thickness: 1.5),
                  ),

                  // Subtitle using Serif font, centered
                  Text(
                    subtitle,
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom Action Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Centered Action
                    children: [
                      // "READ MORE" button styled like a heroic label
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2980B9), // Spidey Blue for highlights
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                          ],
                        ),
                        child: const Text(
                          "FULL STORY",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Edit/Delete actions for author (positioned below the story button if present)
                  if (isLoggedIn && authorId == Supabase.instance.client.auth.currentUser?.id)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.edit, size: 18, color: Colors.black),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreatePostScreen(
                                    id: id,
                                    title: title,
                                    subtitle: subtitle,
                                    content: content,
                                    imageUrl: imageUrl,
                                  ),
                                ),
                              );
                              onRefresh();
                            },
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.delete, size: 18, color: Color(0xFFC0392B)),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFFF4F1EA),
                                  shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.black, width: 2)),
                                  title: Text("REDACT STORY?", style: GoogleFonts.bebasNeue(fontSize: 24)),
                                  content: const Text("This action will permanently delete this article."),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("CANCEL", style: TextStyle(color: Colors.black)),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("DELETE"),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await context.read<PostProvider>().deletePost(id);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}