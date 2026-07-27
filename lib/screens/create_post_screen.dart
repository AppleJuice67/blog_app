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

  XFile? selectedImage;

  @override
  void initState() {
    super.initState();

    titleController.text = widget.title ?? '';
    subtitleController.text = widget.subtitle ?? '';
    contentController.text = widget.content ?? '';
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );



    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  Future<String?> uploadImage() async {
    if (selectedImage == null) return null;

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${selectedImage!.name}';

    await Supabase.instance.client.storage
        .from('post-images')
        .uploadBinary(
      fileName,
      await selectedImage!.readAsBytes(),
    );

    final imageUrl = Supabase.instance.client.storage
        .from('post-images')
        .getPublicUrl(fileName);

    return imageUrl;
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
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Add Image'),
            ),

            if (selectedImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Image.network(
                  selectedImage!.path,
                  height: 200,
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

                String? imageUrl = widget.imageUrl;

                if (selectedImage != null) {
                  imageUrl = await uploadImage();
                }

                if (widget.id == null) {


                  await Supabase.instance.client.from('posts').insert({
                    'title': titleController.text,
                    'subtitle': subtitleController.text,
                    'content': contentController.text,
                    'image_url': imageUrl,
                  });

                } else {

                  await Supabase.instance.client
                      .from('posts')
                      .update({
                    'title': titleController.text,
                    'subtitle': subtitleController.text,
                    'content': contentController.text,
                    'image_url': imageUrl,
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