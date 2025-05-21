import 'dart:io';

import 'package:flutter/material.dart';
import 'package:snaptext_ai/constants/colors.dart';

class ImagePreview extends StatelessWidget {
  final String? imagePath;
  
  const ImagePreview({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: mainColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          // ignore: deprecated_member_use
          color: mainColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: imagePath == null 
          ? const Center(child: Icon(Icons.image,size: 100,))
          : Image.file(
              File(imagePath!),
              fit: BoxFit.contain,
            ),
    );
  }
}