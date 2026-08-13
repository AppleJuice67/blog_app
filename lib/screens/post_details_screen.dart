import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Import for newspaper fonts
import 'package:blog_app/providers/comment_provider.dart';
import 'package:blog_app/providers/post_provider.dart'; // Added missing import for Hero/Menace logic
import '../widgets/web_painter.dart'; // Spider-web decoration

class PostDetailsScreen extends StatefulWidget {
  final int postId;
  final String title;
  final String subtitle;
  final String content;
  
  // SPIDER-MAN THEME: New fields for the "Hero or Menace" voting system
  final int heroCount;
  final int menaceCount;
  final String? userVote;

  const PostDetailsScreen({
    super.key,
    required this.postId,
    required this.title,
    required this.subtitle,
    required this.content,
    this.heroCount = 0,
    this.menaceCount = 0,
    this.userVote,
  });

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  List<String> imageUrls = [];
  final editCommentController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    loadImages();
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
      imageUrls = data.map<String>((e) => e['image_url'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = context.watch<CommentProvider>();
    final comments = commentProvider.comments;
    final currentUser = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EA), // Newsprint background
      appBar: AppBar(
        flexibleSpace: CustomPaint(
          painter: WebPainter(color: Colors.white24),
          child: Container(),
        ),
        title: const Text('EXTRA EDITION'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gallery Section with thick black border and heroic flair
                if (imageUrls.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: const [
                        BoxShadow(color: Colors.black38, offset: Offset(4, 4)),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          height: 400,
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
                                onTap: () => _showFullScreenImage(context, imageUrls, index, 'gallery_image'),
                                child: Hero(
                                  tag: 'gallery_image_$index',
                                  child: Image.network(
                                    imageUrls[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (imageUrls.length > 1)
                          Positioned(
                            bottom: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              color: const Color(0xFF2980B9), // Spidey Blue for labels
                              child: Text(
                                '${_currentImageIndex + 1} OF ${imageUrls.length} EVIDENCE SAMPLES',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // MASSIVE HEADLINE
                      Text(
                        widget.title.toUpperCase(),
                        style: GoogleFonts.bebasNeue(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          height: 0.9,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // SUB-HEADLINE
                      Text(
                        widget.subtitle.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // SPIDER-MAN THEME: Interaction row for voting
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildInteractionButton(
                            context: context,
                            label: "HERO!",
                            count: widget.heroCount,
                            imageUrl: "https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/spider-man-icon.png",
                            isActive: widget.userVote == 'hero',
                            activeColor: const Color(0xFFC0392B),
                            onTap: () => context.read<PostProvider>().toggleInteraction(widget.postId, 'hero'),
                          ),
                          const SizedBox(width: 12),
                          _buildInteractionButton(
                            context: context,
                            label: "MENACE!",
                            count: widget.menaceCount,
                            imageUrl: "https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/spider-man-icon.png",
                            isBlackMask: true,
                            isActive: widget.userVote == 'menace',
                            activeColor: Colors.black,
                            onTap: () => context.read<PostProvider>().toggleInteraction(widget.postId, 'menace'),
                          ),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: Colors.black, thickness: 3),
                      ),

                      // MAIN CONTENT with drop cap effect manually simulated or just strong typography
                      Text(
                        widget.content,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          height: 1.6,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                // COMMENTS SECTION - Styled like a "Letters to the Editor" section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.black, width: 2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "CITIZEN FEEDBACK (${comments.length})",
                        style: GoogleFonts.bebasNeue(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Divider(color: Colors.black, thickness: 2),
                      const SizedBox(height: 16),
                      ...comments.map((comment) => _buildCommentItem(comment, commentProvider, currentUser)).toList(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomInput(commentProvider, currentUser),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment, CommentProvider provider, User? currentUser) {
    final bool isAuthor = comment['user_id'] == currentUser?.id;
    final bool isEditing = provider.editingCommentId == comment['id'];
    final commentImages = (comment['comment_images'] as List? ?? []);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                comment['username'].toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
              ),
              Text(
                comment['created_at'] != null
                    ? DateFormat('MMM dd, hh:mm a').format(DateTime.parse(comment['created_at']))
                    : '',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(color: Colors.black12),
          const SizedBox(height: 8),
          if (isEditing)
            _buildEditCommentField(comment, provider)
          else
            Text(
              comment['comment'],
              style: GoogleFonts.playfairDisplay(fontSize: 16, color: Colors.black87),
            ),

          if (commentImages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: commentImages.length,
                  itemBuilder: (context, index) {
                    final img = commentImages[index];
                    final List<String> allCommentUrls =
                        commentImages.map((e) => e['image_url'] as String).toList();

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _showFullScreenImage(
                          context,
                          allCommentUrls,
                          index,
                          'comment_${comment['id']}_image',
                        ),
                        child: Hero(
                          tag: 'comment_${comment['id']}_image_$index',
                          child: Container(
                            decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
                            child: Image.network(img['image_url'], width: 100, height: 100, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          if (isAuthor && !isEditing)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      provider.setEditingComment(comment['id']);
                      editCommentController.text = comment['comment'];
                    },
                    child: const Text("EDIT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
                  ),
                  TextButton(
                    onPressed: () => _showDeleteConfirm(comment['id'], provider),
                    child: const Text("DELETE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFC0392B))),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditCommentField(Map<String, dynamic> comment, CommentProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: editCommentController,
          maxLines: null,
          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "REVISE STATEMENT..."),
        ),
        Row(
          children: [
            TextButton(
              onPressed: () async => await provider.updateComment(widget.postId, editCommentController.text),
              child: const Text("SAVE"),
            ),
            TextButton(
              onPressed: () => provider.clearEditState(),
              child: const Text("CANCEL"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomInput(CommentProvider provider, User? currentUser) {
    if (currentUser == null || provider.isEditing) return const SizedBox.shrink();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black, width: 2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: editCommentController,
                decoration: const InputDecoration(
                  hintText: "SUBMIT YOUR REPORT...",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Color(0xFF2980B9)), // Spidey Blue for action
              onPressed: () async {
                if (editCommentController.text.trim().isNotEmpty) {
                  await provider.addComment(widget.postId, editCommentController.text);
                  editCommentController.clear();
                }
              },
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
        backgroundColor: const Color(0xFFF4F1EA),
        shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.black, width: 2)),
        title: const Text("REDACT COMMENT?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("NO")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("YES")),
        ],
      ),
    );
    if (shouldDelete == true) {
      await provider.deleteComment(commentId, widget.postId);
    }
  }

  void _showFullScreenImage(BuildContext context, List<String> urls, int initialIndex, String tagPrefix) {
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
            itemCount: urls.length,
            controller: PageController(initialPage: initialIndex),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Hero(
                    tag: '${tagPrefix}_$index',
                    child: Image.network(
                      urls[index],
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

  // SPIDER-MAN THEME: Helper to build the heroic interaction buttons
  // Identical to the one in PostCard to maintain the heroic design language.
  Widget _buildInteractionButton({
    required BuildContext context,
    required String label,
    required int count,
    required String imageUrl,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
    bool isBlackMask = false,
  }) {
    final bool isLoggedIn = Supabase.instance.client.auth.currentUser != null;
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: showActive ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: showActive ? const Offset(1, 1) : const Offset(4, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                isBlackMask ? (showActive ? Colors.white : Colors.black) : (showActive ? Colors.white : Colors.red.shade700),
                BlendMode.srcIn,
              ),
              child: Image.network(
                imageUrl,
                height: 20,
                width: 20,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.face, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "$label $count",
              style: GoogleFonts.bebasNeue(
                fontSize: 16,
                color: showActive ? Colors.white : Colors.black,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}