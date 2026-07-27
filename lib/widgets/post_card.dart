import 'package:flutter/material.dart';
import '../screens/post_details_screen.dart';
import '../screens/create_post_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostCard extends StatelessWidget {
  final int id;
  final String title;
  final String subtitle;
  final String content;
  final String? imageUrl;
  final VoidCallback onRefresh;
  final bool isLoggedIn;


  const PostCard({
    super.key,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.imageUrl,
    required this.onRefresh,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Card(
        child: ListTile(
          leading: imageUrl != null && imageUrl!.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image);
              },
            ),
          )
              : const Icon(Icons.article),
              title: Text(title),
              subtitle: Text(subtitle),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [

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
                    await Supabase.instance.client
                        .from('posts')
                        .delete()
                        .eq('id', id);

                    onRefresh();
                  },
                ),
              ],

              const Icon(Icons.arrow_forward),
            ],
          ),
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
            ),
          ),
      );

  }
}