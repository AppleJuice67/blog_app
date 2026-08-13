import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; // Import for newspaper fonts
import '../screens/post_details_screen.dart';
import '../screens/create_post_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import 'pixel_spidey_icon.dart'; // SPIDER-MAN THEME: Pixel Art Reactions

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
  
  // SPIDER-MAN THEME: Interaction data
  final int heroCount;
  final int menaceCount;
  final String? userVote;

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
    this.heroCount = 0,
    this.menaceCount = 0,
    this.userVote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Tightened margin
      decoration: BoxDecoration(
        color: Colors.white,
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
                heroCount: heroCount,
                menaceCount: menaceCount,
                userVote: userVote,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // IMAGE SECTION
            if (imageUrl != null && imageUrl!.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(4), // Shrunk margin
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
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12), // Shrunk padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bebasNeue(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "BY ${username.toUpperCase()}",
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                      const SizedBox(width: 6),
                      const Text("•", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 6),
                      Text(
                        createdAt != null
                            ? DateFormat('MMM dd, yyyy').format(DateTime.parse(createdAt!)).toUpperCase()
                            : 'LATEST',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const Divider(color: Colors.black, thickness: 1.5, height: 12),

                  Text(
                    subtitle,
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // SPIDER-MAN THEME: Pixel Spidey Reaction Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInteractionButton(
                        context: context,
                        label: "HERO!",
                        count: heroCount,
                        isSymbiote: false,
                        isActive: userVote == 'hero',
                        activeColor: const Color(0xFFC0392B),
                        onTap: () => context.read<PostProvider>().toggleInteraction(id, 'hero'),
                      ),
                      const SizedBox(width: 8),
                      _buildInteractionButton(
                        context: context,
                        label: "MENACE!",
                        count: menaceCount,
                        isSymbiote: true,
                        isActive: userVote == 'menace',
                        activeColor: Colors.black,
                        onTap: () => context.read<PostProvider>().toggleInteraction(id, 'menace'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2980B9),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                    ),
                    child: const Text(
                      "FULL STORY",
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                  
                  if (isLoggedIn && authorId == Supabase.instance.client.auth.currentUser?.id)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.edit, size: 16, color: Colors.black),
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
                            icon: const Icon(Icons.delete, size: 16, color: Color(0xFFC0392B)),
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

  // SPIDER-MAN THEME: Updated for Pixel Spidey Icons
  Widget _buildInteractionButton({
    required BuildContext context,
    required String label,
    required int count,
    required bool isSymbiote,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    final bool showActive = isLoggedIn && isActive;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: isLoggedIn ? onTap : () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("CITIZEN: YOU MUST LOGIN TO VOTE!")),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: showActive ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black, offset: showActive ? const Offset(1, 1) : const Offset(3, 3)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PixelSpideyIcon(size: 18, isSymbiote: isSymbiote), // Custom Pixel Art Icon
            const SizedBox(width: 6),
            Text(
              "$label $count",
              style: GoogleFonts.bebasNeue(
                fontSize: 14,
                color: showActive ? Colors.white : Colors.black,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}