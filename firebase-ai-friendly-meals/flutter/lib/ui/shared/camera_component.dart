import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../theme/app_theme.dart';

class CameraComponent extends StatelessWidget {
  const CameraComponent({
    super.key,
    required this.onImageTaken,
    required this.showError,
    this.isTopBarIcon = true,
  });

  final void Function(Uint8List? imageBytes, VoidCallback showError)
      onImageTaken;
  final VoidCallback showError;
  final bool isTopBarIcon;

  static final ImagePicker _picker = ImagePicker();

  Future<void> _takePicture() async {
    try {
      if (!kIsWeb) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          return;
        }
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (photo == null) {
        return;
      }

      final rawBytes = await photo.readAsBytes();
      final bakedBytes = await compute(_bakeOrientation, rawBytes);
      onImageTaken(bakedBytes, showError);
    } catch (e) {
      debugPrint('Error taking picture: $e');
      showError();
    }
  }

  static Uint8List _bakeOrientation(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    final oriented = img.bakeOrientation(decoded);
    return Uint8List.fromList(img.encodeJpg(oriented, quality: 90));
  }

  @override
  Widget build(BuildContext context) {
    if (isTopBarIcon) {
      return IconButton(
        onPressed: _takePicture,
        tooltip: 'Camera',
        icon: const Icon(Icons.photo_camera_outlined),
      );
    }

    return CustomPaint(
      painter: _DashedRoundedRectPainter(
        color: Colors.grey.shade400,
        strokeWidth: 2,
        radius: 16,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _takePicture,
          child: const SizedBox(
            width: double.infinity,
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_camera_outlined,
                  color: AppColors.teal,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Take a picture of ingredients',
                  style: TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRoundedRectPainter extends CustomPainter {
  _DashedRoundedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  final Color color;
  final double strokeWidth;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final dashedPath = _createDashedPath(path, dashWidth: 10, dashSpace: 8);
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(
    Path source, {
    required double dashWidth,
    required double dashSpace,
  }) {
    final dest = Path();
    for (final ui.PathMetric metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = (distance + dashWidth).clamp(0.0, metric.length);
        dest.addPath(metric.extractPath(distance, next), Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}
