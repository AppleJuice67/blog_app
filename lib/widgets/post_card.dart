import 'package:flutter/material.dart';
import '../screens/post_details_screen.dart';
import '../screens/create_post_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class PostCard extends StatelessWidget {
  final int id;
  final String title;
  final String subtitle;
  final String content;
  final String? imageUrl;
  final String username;
  final String? createdAt;
  final VoidCallback onRefresh;
  final bool isLoggedIn;


  const PostCard({
    super.key,
    required this.id,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
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
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              if (imageUrl != null && imageUrl!.isNotEmpty)
                Image.network(
                  imageUrl!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 220,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 60,
                        ),
                      ),
                    );
                  },
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "By $username",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      createdAt != null
                          ? DateFormat('MMM dd, yyyy').format(
                        DateTime.parse(createdAt!),
                      )
                          : 'Unknown date',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [

                        const Icon(
                          Icons.article_outlined,
                          color: Colors.blue,
                        ),

                        const SizedBox(width: 6),

                        const Text(
                          "Read More",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Spacer(),

                        if (isLoggedIn) ...[

                          IconButton(
                            icon: const Icon(Icons.edit),
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
                            icon: const Icon(Icons.delete),
                            onPressed: () async {

                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Delete Post"),
                                    content: const Text(
                                      "Are you sure you want to delete this post?",
                                    ),
                                    actions: [

                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, false);
                                        },
                                        child: const Text("Cancel"),
                                      ),

                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },
                                        child: const Text("Delete"),
                                      ),

                                    ],
                                  );
                                },
                              );

                              if (confirm == true) {
                                await Supabase.instance.client
                                    .from('posts')
                                    .delete()
                                    .eq('id', id);

                                onRefresh();
                              }
                            },
                          ),
                        ],

                        const Icon(Icons.arrow_forward_ios, size: 18),

                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}