import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostProvider extends ChangeNotifier {
  List<Map<String, dynamic>> posts = [];



  int currentPage = 0;
  final int pageSize = 5;

  void nextPage() {
    currentPage++;
    fetchPosts();
  }

  void previousPage() {
    if (currentPage > 0) {
      currentPage--;
      fetchPosts();
    }
  }

  Future<void> fetchPosts() async {
    final from = currentPage * pageSize;
    final to = from + pageSize - 1;

    final response = await Supabase.instance.client
        .from('posts')
        .select()
        .order('id', ascending: false)
        .range(from, to);

    List<Map<String, dynamic>> loadedPosts = [];

    for (final post in response) {
      final images = await Supabase.instance.client
          .from('post_images')
          .select('image_url')
          .eq('post_id', post['id'])
          .limit(1);

      post['image_url'] =
      images.isNotEmpty ? images.first['image_url'] : null;

      if (post['user_id'] != null) {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('username')
            .eq('id', post['user_id'])
            .maybeSingle();

        post['username'] = profile?['username'] ?? 'Unknown User';
      } else {
        post['username'] = 'Unknown User';
      }

      loadedPosts.add(post);
    }


    posts = loadedPosts;
    notifyListeners();
  }

  Future<void> deletePost(int postId) async {
    await Supabase.instance.client
        .from('posts')
        .delete()
        .eq('id', postId);

    await fetchPosts();
  }
  Future<void> createPost({
    required String title,
    required String subtitle,
    required String content,
    required List<String> imageUrls,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;

    final post = await Supabase.instance.client
        .from('posts')
        .insert({
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'user_id': user!.id,
    })
        .select()
        .single();

    final postId = post['id'];

    for (final url in imageUrls) {
      await Supabase.instance.client
          .from('post_images')
          .insert({
        'post_id': postId,
        'image_url': url,
      });
    }

    await fetchPosts();
  }
  Future<void> updatePost({
    required int id,
    required String title,
    required String subtitle,
    required String content,
  }) async {
    await Supabase.instance.client
        .from('posts')
        .update({
      'title': title,
      'subtitle': subtitle,
      'content': content,
    })
        .eq('id', id);

    await fetchPosts();
  }

}