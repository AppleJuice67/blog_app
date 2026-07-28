import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
  List<Map<String, dynamic>> comments = [];

  int? editingCommentId;
  bool isEditing = false;

  final commentController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  List<XFile> selectedCommentImages = [];

  Future<List<String>> uploadCommentImages() async {
    List<String> imageUrls = [];

    for (final image in selectedCommentImages) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${image.name}';

      await Supabase.instance.client.storage
          .from('comment-images')
          .uploadBinary(
        fileName,
        await image.readAsBytes(),
      );

      final url = Supabase.instance.client.storage
          .from('comment-images')
          .getPublicUrl(fileName);

      imageUrls.add(url);
    }

    return imageUrls;
  }

  Future<void> pickCommentImages() async {
    final images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        selectedCommentImages = images;
      });
    }
  }

  Future<void> addComment() async {


    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) return;

      List<String> imageUrls = [];

      if (selectedCommentImages.isNotEmpty) {
        imageUrls = await uploadCommentImages();
      }

      final comment = await Supabase.instance.client
          .from('comments')
          .insert({
        'post_id': widget.postId,
        'user_id': user.id,
        'comment': commentController.text,
      })
          .select()
          .single();

      final commentId = comment['id'];

      for (final url in imageUrls) {
        await Supabase.instance.client
            .from('comment_images')
            .insert({
          'comment_id': commentId,
          'image_url': url,
        });
      }

      commentController.clear();

      selectedCommentImages.clear();

      await loadComments();

      setState(() {});
    }catch (e) {
      print(e);
    }
  }

  Future<void> updateComment() async {
    if (editingCommentId == null) return;

    await Supabase.instance.client
        .from('comments')
        .update({
      'comment': commentController.text,
    })
        .eq('id', editingCommentId!);

    commentController.clear();

    editingCommentId = null;
    isEditing = false;

    await loadComments();

    setState(() {});
  }

  Future<void> loadComments() async {
    final data = await Supabase.instance.client
        .from('comments')
        .select('*, comment_images(*)')
        .eq('post_id', widget.postId)
        .order('created_at');

    List<Map<String, dynamic>> loadedComments = [];

    for (final comment in data) {

      final profile = await Supabase.instance.client
          .from('profiles')
          .select('username')
          .eq('id', comment['user_id'])
          .maybeSingle();

      comment['username'] = profile?['username'] ?? 'Unknown User';

      loadedComments.add(comment);
    }

    setState(() {
      comments = loadedComments;
    });
  }

  @override
  void initState() {
    super.initState();
    loadImages();
    loadComments();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: SingleChildScrollView(
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

                          Text(
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

                                    if (comment['user_id'] ==
                                        Supabase.instance.client.auth.currentUser?.id)
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () async {
                                            await Supabase.instance.client
                                                .from('comment_images')
                                                .delete()
                                                .eq('id', image['id']);

                                            await loadComments();
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
                        Row(
                          children: [

                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                setState(() {
                                  commentController.text = comment['comment'];
                                  editingCommentId = comment['id'];
                                  isEditing = true;
                                });
                              },
                            ),

                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {

                                await Supabase.instance.client
                                    .from('comment_images')
                                    .delete()
                                    .eq('comment_id', comment['id']);

                                await Supabase.instance.client
                                    .from('comments')
                                    .delete()
                                    .eq('id', comment['id']);

                                await loadComments();
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

            if (Supabase.instance.client.auth.currentUser != null) ...[

              ElevatedButton.icon(
                onPressed: pickCommentImages,
                icon: const Icon(Icons.image),
                label: const Text('Add Images'),
              ),

              if (selectedCommentImages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedCommentImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              selectedCommentImages[index].path,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isEditing ? updateComment : addComment,
                  child: Text(
                    isEditing
                        ? 'Update Comment'
                        : 'Post Comment',
                  ),
                ),
              ),

            ] else ...[

              Card(
                color: Colors.blue.shade50,
                elevation: 0,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [

                      Icon(
                        Icons.lock_outline,
                        color: Colors.blue,
                      ),

                      SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          "Login to write a comment or upload images.",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}