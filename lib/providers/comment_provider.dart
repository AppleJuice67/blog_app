import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class CommentProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  final ImagePicker picker = ImagePicker();

  List<Map<String, dynamic>> comments = [];
  bool isLoading = false; // Add loading state

  // State for new comment images
  List<XFile> selectedCommentImages = [];

  // State for editing comments
  int? editingCommentId;
  bool isEditing = false;
  List<XFile> selectedEditImages = [];

  // Load comments for a specific post
  Future<void> loadComments(int postId) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await supabase
          .from('comments')
          .select('*, comment_images(*)')
          .eq('post_id', postId)
          .order('created_at');

      List<Map<String, dynamic>> loadedComments = [];

      for (final comment in data) {
        final profile = await supabase
            .from('profiles')
            .select('username')
            .eq('id', comment['user_id'])
            .maybeSingle();

        comment['username'] = profile?['username'] ?? "Unknown User";

        loadedComments.add(comment);
      }

      comments = loadedComments;
    } catch (e) {
      debugPrint('Error loading comments: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Pick images for a new comment
  Future<void> pickCommentImages() async {
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      selectedCommentImages = images;
      notifyListeners();
    }
  }

  // Upload images to Supabase storage
  Future<List<String>> uploadCommentImages() async {
    List<String> imageUrls = [];

    for (final image in selectedCommentImages) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${image.name}';

      await supabase.storage
          .from('comment-images')
          .uploadBinary(
        fileName,
        await image.readAsBytes(),
      );

      final url = supabase.storage
          .from('comment-images')
          .getPublicUrl(fileName);

      imageUrls.add(url);
    }

    return imageUrls;
  }

  // Add a new comment to a post
  Future<void> addComment(int postId, String commentText) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      List<String> imageUrls = [];

      if (selectedCommentImages.isNotEmpty) {
        imageUrls = await uploadCommentImages();
      }

      final comment = await supabase
          .from('comments')
          .insert({
        'post_id': postId,
        'user_id': user.id,
        'comment': commentText,
      })
          .select()
          .single();

      final commentId = comment['id'];

      for (final url in imageUrls) {
        await supabase
            .from('comment_images')
            .insert({
          'comment_id': commentId,
          'image_url': url,
        });
      }

      selectedCommentImages.clear();
      await loadComments(postId);
    } catch (e) {
      debugPrint('Error adding comment: $e');
    }
  }

  // Delete a specific comment and its images
  Future<void> deleteComment(int commentId, int postId) async {
    try {
      // First delete associated images
      await supabase
          .from('comment_images')
          .delete()
          .eq('comment_id', commentId);

      // Then delete the comment itself
      await supabase
          .from('comments')
          .delete()
          .eq('id', commentId);

      await loadComments(postId);
    } catch (e) {
      debugPrint('Error deleting comment: $e');
    }
  }

  // Delete a specific comment image
  Future<void> deleteCommentImage(int imageId, int postId) async {
    try {
      await supabase
          .from('comment_images')
          .delete()
          .eq('id', imageId);

      await loadComments(postId);
    } catch (e) {
      debugPrint('Error deleting comment image: $e');
    }
  }

  // Set the comment to be edited
  void setEditingComment(int commentId) {
    editingCommentId = commentId;
    isEditing = true;
    notifyListeners();
  }

  // Clear editing state
  void clearEditState() {
    editingCommentId = null;
    isEditing = false;
    selectedEditImages.clear();
    notifyListeners();
  }

  // Pick images for editing a comment
  Future<void> pickEditImages() async {
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      selectedEditImages = images;
      notifyListeners();
    }
  }

  // Upload images during comment update
  Future<List<String>> uploadEditImages() async {
    List<String> imageUrls = [];

    for (final image in selectedEditImages) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${image.name}';

      await supabase.storage
          .from('comment-images')
          .uploadBinary(
        fileName,
        await image.readAsBytes(),
      );

      final imageUrl = supabase.storage
          .from('comment-images')
          .getPublicUrl(fileName);

      imageUrls.add(imageUrl);
    }

    return imageUrls;
  }

  // Update an existing comment
  Future<void> updateComment(int postId, String commentText) async {
    if (editingCommentId == null) return;

    try {
      // Update comment text
      await supabase
          .from('comments')
          .update({'comment': commentText})
          .eq('id', editingCommentId!);

      // Upload new images if any
      if (selectedEditImages.isNotEmpty) {
        final imageUrls = await uploadEditImages();

        for (final url in imageUrls) {
          await supabase
              .from('comment_images')
              .insert({
            'comment_id': editingCommentId!,
            'image_url': url,
          });
        }
      }

      clearEditState();
      await loadComments(postId);
    } catch (e) {
      debugPrint('Error updating comment: $e');
    }
  }
}