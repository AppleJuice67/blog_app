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

      // SPIDER-MAN THEME: Fetching Hero/Menace interaction counts
      // We wrap this in a try-catch so that if the interaction table isn't created yet,
      // the rest of the blog posts still load correctly.
      try {
        final heroCount = await Supabase.instance.client
            .from('post_interactions')
            .select()
            .eq('post_id', post['id'])
            .eq('type', 'hero');
        
        final menaceCount = await Supabase.instance.client
            .from('post_interactions')
            .select()
            .eq('post_id', post['id'])
            .eq('type', 'menace');

        post['hero_count'] = (heroCount as List).length;
        post['menace_count'] = (menaceCount as List).length;

        // Checking if the current user has already voted
        final currentUser = Supabase.instance.client.auth.currentUser;
        if (currentUser != null) {
          final userInteraction = await Supabase.instance.client
              .from('post_interactions')
              .select('type')
              .eq('post_id', post['id'])
              .eq('user_id', currentUser.id)
              .maybeSingle();
          
          post['user_vote'] = userInteraction?['type'];
        }
      } catch (e) {
        // If the table doesn't exist, we just default to 0 votes
        post['hero_count'] = 0;
        post['menace_count'] = 0;
        post['user_vote'] = null;
        debugPrint("Citizen: Interaction table not found. Did you run the SQL script?");
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

  // SPIDER-MAN THEME: Logic for the "Hero or Menace" voting system
  // This method handles adding, changing, or removing a user's vote on a post.
  Future<void> toggleInteraction(int postId, String type) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return; // Must be logged in to vote

    // Check if the user has already voted on this post
    final existing = await Supabase.instance.client
        .from('post_interactions')
        .select()
        .eq('post_id', postId)
        .eq('user_id', user.id)
        .maybeSingle();

    if (existing != null) {
      if (existing['type'] == type) {
        // If clicking the same button again, we "un-vote" (remove the record)
        await Supabase.instance.client
            .from('post_interactions')
            .delete()
            .eq('id', existing['id']);
      } else {
        // If changing from Hero to Menace (or vice-versa), we update the record
        await Supabase.instance.client
            .from('post_interactions')
            .update({'type': type})
            .eq('id', existing['id']);
      }
    } else {
      // If no vote exists, create a new record
      await Supabase.instance.client
          .from('post_interactions')
          .insert({
        'post_id': postId,
        'user_id': user.id,
        'type': type,
      });
    }

    // Refresh the posts list to show updated counts and active states
    await fetchPosts();
  }

}