import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:blog_app/providers/comment_provider.dart';

class PostDetailsScreen extends StatefulWidget {
  final int postId;
  final String title;
  final String subtitle;
  final String content;

  const PostDetailsScreen({
    super.key,
    required this.postId,
    required this.title,
    required this.subtitle,
    required this.content,
  });

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();

}

class _PostDetailsScreenState extends State<PostDetailsScreen> {

  List<String> imageUrls = [];

  final editCommentController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadImages();
    // Load comments using the provider after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CommentProvider>().loadComments(widget.postId);
      }
    });
  }

  Future<void> loadImages() async {
    final data = await Supabase.instance.client
        .from('post_images')
        .select()
        .eq('post_id', widget.postId);

    setState(() {
      imageUrls =
          data.map<String>((e) => e['image_url'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = context.watch<CommentProvider>();
    final comments = commentProvider.comments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrls.isNotEmpty)
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrls[index],
                          width: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),



            const SizedBox(height: 16),

            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.subtitle,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              widget.content,
              style: const TextStyle(
                fontSize: 17,
                height: 1.7,
              ),
            ),

            const SizedBox(height: 30),

// COMMENT INPUT


            const SizedBox(height: 30),

            const Divider(),
            const Divider(),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  "Comments (${comments.length})",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ...comments.map(
                  (comment) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            comment['username'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            comment['created_at'] != null
                                ? DateFormat('MMM dd, yyyy • hh:mm a').format(
                              DateTime.parse(comment['created_at']),
                            )
                                : 'Unknown date',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 6),

                          commentProvider.editingCommentId == comment['id']
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              TextField(
                                controller: editCommentController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),

                              const SizedBox(height: 10),

                              ElevatedButton.icon(
                                onPressed: commentProvider.pickEditImages,
                                icon: const Icon(Icons.image),
                                label: const Text("Add Images"),
                              ),

                              if (commentProvider.selectedEditImages.isNotEmpty)
                                SizedBox(
                                  height: 80,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: commentProvider.selectedEditImages.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: Image.network(
                                          commentProvider.selectedEditImages[index].path,
                                          width: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                                ),

                            ],
                          )
                              : Text(
                            comment['comment'],
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                       ],
                      ),

                      const SizedBox(height: 10),

                      if ((comment['comment_images'] as List).isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: (comment['comment_images'] as List).length,
                            itemBuilder: (context, index) {
                              final image = comment['comment_images'][index];

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [

                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        image['image_url'],
                                        width: 120,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
           // Comment X button issue
                                    if (commentProvider.isEditing &&
                                        commentProvider.editingCommentId == comment['id'] &&
                                        comment['user_id'] ==
                                            Supabase.instance.client.auth.currentUser?.id)
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                        onTap: () async {
                                          await commentProvider.deleteCommentImage(
                                            image['id'],
                                            widget.postId,
                                          );
                                        },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),

                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                      if (comment['user_id'] ==
                          Supabase.instance.client.auth.currentUser?.id)
                        commentProvider.editingCommentId == comment['id']
                            ? Row(
                          children: [

                            ElevatedButton.icon(
                              onPressed: () async {
                                await commentProvider.updateComment(
                                  widget.postId,
                                  editCommentController.text,
                                );
                                editCommentController.clear();
                              },
                              icon: const Icon(Icons.save),
                              label: const Text("Save"),
                            ),

                            const SizedBox(width: 8),

                            OutlinedButton(
                              onPressed: () {
                                commentProvider.clearEditState();
                                editCommentController.clear();
                              },
                              child: const Text("Cancel"),
                            ),

                          ],
                        )
                        // Edit button editable right where it is.
                            : Row(
                          children: [

                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                commentProvider.setEditingComment(comment['id']);
                                editCommentController.text = comment['comment'];
                              },
                            ),

                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Delete Comment"),
                                    content: const Text(
                                      "Are you sure you want to delete this comment?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );

                                if (shouldDelete == true) {
                                  await commentProvider.deleteComment(
                                    comment['id'],
                                    widget.postId,
                                  );
                                }
                              },
                            ),

                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ).toList(),

            const SizedBox(height: 10),



            const SizedBox(height: 20),

            const SizedBox(height: 20),

          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: const Border(
              top: BorderSide(color: Colors.grey),
            ),
          ),
          child: Supabase.instance.client.auth.currentUser != null
              ? (commentProvider.isEditing
              ? const SizedBox.shrink()
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              if (commentProvider.selectedCommentImages.isNotEmpty)
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: commentProvider.selectedCommentImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            commentProvider.selectedCommentImages[index].path,
                            width: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),

              if (commentProvider.selectedCommentImages.isNotEmpty)
                const SizedBox(height: 10),

              Row(
                children: [

                  Expanded(
                    child: TextField(
                      controller: editCommentController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: "Write a comment...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  IconButton(
                    onPressed: commentProvider.pickCommentImages,
                    icon: const Icon(Icons.image),
                  ),

                  IconButton(
                    onPressed: () async {
                      await commentProvider.addComment(
                        widget.postId,
                        editCommentController.text,
                      );
                      editCommentController.clear();
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ],
          ))
              : const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Login to write a comment.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}