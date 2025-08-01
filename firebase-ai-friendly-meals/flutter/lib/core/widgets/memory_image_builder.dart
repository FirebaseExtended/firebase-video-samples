import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MemoryImageBuilder extends StatelessWidget {
  const MemoryImageBuilder({
    required this.imageBytes,
    super.key,
  });

  final Uint8List imageBytes;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey.shade300,
            child: const Center(
              child: Icon(
                Icons.broken_image,
                size: 48,
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}
