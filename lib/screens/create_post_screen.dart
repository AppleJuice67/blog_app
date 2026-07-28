import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';


class CreatePostScreen extends StatefulWidget {
  final int? id;
  final String? title;
  final String? subtitle;
  final String? content;
  final String? imageUrl;

  const CreatePostScreen({
    super.key,
    this.id,
    this.title,
    this.subtitle,
    this.content,
    this.imageUrl,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState(  );

}

class _CreatePostScreenState extends State<CreatePostScreen> {

  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final contentController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  List<XFile> selectedImages = [];

  @override
  void initState() {
    super.initState();

    titleController.text = widget.title ?? '';
    subtitleController.text = widget.subtitle ?? '';
    contentController.text = widget.content ?? '';
  }

  Future<void> pickImages() async {
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        selectedImages = images;
      });
    }
  }

  Future<List<String>> uploadImages() async {
    List<String> imageUrls = [];

    for (final image in selectedImages) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${image.name}';

      await Supabase.instance.client.storage
          .from('post-images')
          .uploadBinary(
        fileName,
        await image.readAsBytes(),
      );

      final imageUrl = Supabase.instance.client.storage
          .from('post-images')
          .getPublicUrl(fileName);

      imageUrls.add(imageUrl);
    }

    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            ElevatedButton.icon(
              onPressed: pickImages,
              icon: const Icon(Icons.image),
              label: const Text('Add Image'),
            ),

            if (selectedImages.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Image.network(
                        selectedImages[index].path,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: subtitleController,
              decoration: const InputDecoration(
                labelText: 'Subtitle',
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
              ),
              maxLines: 5,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {

                List<String> imageUrls = [];

                if (selectedImages.isNotEmpty) {
                  imageUrls = await uploadImages();
                }

                if (widget.id == null) {

                  final user = Supabase.instance.client.auth.currentUser;

                  final post = await Supabase.instance.client
                      .from('posts')
                      .insert({
                    'title': titleController.text,
                    'subtitle': subtitleController.text,
                    'content': contentController.text,
                    'user_id': user!.id,
                  })
                      .select()
                      .single();

                  final postId = post['id'];

                  for (String url in imageUrls) {
                    await Supabase.instance.client
                        .from('post_images')
                        .insert({
                      'post_id': postId,
                      'image_url': url,
                    });
                  }

                } else {

                  await Supabase.instance.client
                      .from('posts')
                      .update({
                    'title': titleController.text,
                    'subtitle': subtitleController.text,
                    'content': contentController.text,

                  })
                      .eq('id', widget.id!);
                }

                Navigator.pop(context);
              },
              child: const Text('Save Post'),
            ),
          ],
        ),
      ),
    );
  }
}