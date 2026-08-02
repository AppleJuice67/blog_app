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

  // PageController for the image gallery
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;

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

  @override
  void dispose() {
    _imagePageController.dispose();
    editCommentController.dispose();
    scrollController.dispose();
    super.dispose();
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
    final currentUser = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Article'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {}, // Future feature
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Professional Gallery Header with PageView and Indicators
            if (imageUrls.isNotEmpty)
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 350,
                    width: double.infinity,
                    child: PageView.builder(
                      controller: _imagePageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _showFullScreenImage(context, index),
                          child: Hero(
                            tag: 'gallery_image_$index',
                            child: Image.network(
                              imageUrls[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: Colors.grey.shade100, child: const Icon(Icons.broken_image)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Dots Indicator overlay
                  if (imageUrls.length > 1)
                    Positioned(
                      bottom: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          imageUrls.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentImageIndex == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Image count overlay
                  Positioned(
                    top: 10,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentImageIndex + 1} / ${imageUrls.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Article Header
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2D3436),
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle / Abstract
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider for visual separation
                  Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Main Article Content with optimized reading typography
                  Text(
                    widget.content,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.8,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                ],
              ),
            ),

            // Comments Section Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Discussion (${comments.length})",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      if (currentUser == null)
                        Text(
                          "Log in to participate",
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Comments Feed
                  ...comments.map((comment) => _buildCommentItem(comment, commentProvider, currentUser)).toList(),

                  const SizedBox(height: 80), // Space at bottom for navigation bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomInput(commentProvider, currentUser),
    );
  }

  // Helper to build a clean comment item
  Widget _buildCommentItem(Map<String, dynamic> comment, CommentProvider provider, User? currentUser) {
    final bool isAuthor = comment['user_id'] == currentUser?.id;
    final bool isEditing = provider.editingCommentId == comment['id'];
    final commentImages = (comment['comment_images'] as List? ?? []);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Avatar Initial
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Text(
              comment['username'][0].toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Comment Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comment['username'],
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    Text(
                      comment['created_at'] != null
                          ? DateFormat('MMM dd, hh:mm a').format(DateTime.parse(comment['created_at']))
                          : '',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Edit Mode vs View Mode
                if (isEditing)
                  _buildEditCommentField(comment, provider)
                else
                  Text(
                    comment['comment'],
                    style: const TextStyle(fontSize: 15, height: 1.4, color: Color(0xFF2D3436)),
                  ),

                // Comment Images
                if (commentImages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: commentImages.length,
                        itemBuilder: (context, index) {
                          final img = commentImages[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    img['image_url'],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // Allow author to delete specific image while editing
                                if (isEditing && isAuthor)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => provider.deleteCommentImage(img['id'], widget.postId),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Action row for comment author
                if (isAuthor && !isEditing)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            provider.setEditingComment(comment['id']);
                            editCommentController.text = comment['comment'];
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(40, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text("Edit", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () => _showDeleteConfirm(comment['id'], provider),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(40, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text("Delete", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),
                const Divider(height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Inline editor for comments
  Widget _buildEditCommentField(Map<String, dynamic> comment, CommentProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: editCommentController,
          maxLines: null,
          autofocus: true,
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            hintText: "Edit your comment...",
          ),
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: () async {
                await provider.updateComment(widget.postId, editCommentController.text);
                editCommentController.clear();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                minimumSize: const Size(60, 32),
              ),
              child: const Text("Save", style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => provider.clearEditState(),
              style: TextButton.styleFrom(minimumSize: const Size(60, 32)),
              child: const Text("Cancel", style: TextStyle(fontSize: 12)),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
              onPressed: () => provider.pickEditImages(),
            ),
          ],
        ),
        if (provider.selectedEditImages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.selectedEditImages.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(provider.selectedEditImages[index].path, width: 50, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Clean bottom bar for comment input
  Widget _buildBottomInput(CommentProvider provider, User? currentUser) {
    if (currentUser == null) return const SizedBox.shrink();
    if (provider.isEditing) return const SizedBox.shrink();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (provider.selectedCommentImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.selectedCommentImages.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(provider.selectedCommentImages[index].path, width: 60, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F2F6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: editCommentController,
                            maxLines: null,
                            decoration: const InputDecoration(
                              hintText: "Share your thoughts...",
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
                          onPressed: () => provider.pickCommentImages(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () async {
                    if (editCommentController.text.trim().isNotEmpty) {
                      await provider.addComment(widget.postId, editCommentController.text);
                      editCommentController.clear();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(int commentId, CommentProvider provider) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Comment"),
        content: const Text("Are you sure? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      await provider.deleteComment(commentId, widget.postId);
    }
  }

  // Opens an interactive full-screen image viewer
  void _showFullScreenImage(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: PageView.builder(
            itemCount: imageUrls.length,
            controller: PageController(initialPage: initialIndex),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Hero(
                    tag: 'gallery_image_$index',
                    child: Image.network(
                      imageUrls[index],
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}