import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onImagePicked});

  final void Function(File pickedImage) onImagePicked;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _image;

  void _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (image == null) return;
    setState(() => _image = File(image.path));
    widget.onImagePicked(_image!);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      spacing: 8,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: colorScheme.primaryContainer,
          foregroundImage: _image != null ? FileImage(_image!) : null,
        ),
        TextButton.icon(
          icon: const Icon(Icons.image),
          label: Text(
            'Add Image',
            style: TextStyle(color: colorScheme.primary),
          ),
          onPressed: _pickImage,
        ),
      ],
    );
  }
}
