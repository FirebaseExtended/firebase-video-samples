import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

class StorageRemoteDataSource {
  StorageRemoteDataSource({Reference? storageRef})
      : _storageRef = storageRef ?? FirebaseStorage.instance.ref();

  static const int _maxImageLength = 800;
  final Reference _storageRef;
  static const Uuid _uuid = Uuid();

  Future<String> addImage(Uint8List imageBytes) async {
    final processedBytes = await compute(_scaleAndCompressImage, imageBytes);
    final randomId = _uuid.v4();
    final imagesRef = _storageRef.child('images/$randomId.jpg');
    await imagesRef.putData(
      processedBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return imagesRef.getDownloadURL();
  }

  static Uint8List _scaleAndCompressImage(Uint8List rawBytes) {
    final decoded = img.decodeImage(rawBytes);
    if (decoded == null) {
      return rawBytes;
    }

    final lastWidth = decoded.width;
    final lastHeight = decoded.height;
    final int outWidth;
    final int outHeight;

    if (lastWidth > lastHeight) {
      outWidth = _maxImageLength;
      outHeight = (lastHeight.toDouble() / lastWidth * _maxImageLength).toInt();
    } else {
      outHeight = _maxImageLength;
      outWidth = (lastWidth.toDouble() / lastHeight * _maxImageLength).toInt();
    }

    final scaled = img.copyResize(
      decoded,
      width: outWidth,
      height: outHeight,
      interpolation: img.Interpolation.linear,
    );
    return Uint8List.fromList(img.encodeJpg(scaled, quality: 70));
  }
}

/// Converts raw image bytes to a JPEG-compressed Base64 string (quality 80),
/// matching Android's `Bitmap.toBase64()`.
Future<String> imageBytesToBase64(Uint8List imageBytes) {
  return compute(_encodeJpegBase64, imageBytes);
}

String _encodeJpegBase64(Uint8List rawBytes) {
  final decoded = img.decodeImage(rawBytes);
  if (decoded == null) {
    return base64Encode(rawBytes);
  }
  final jpegBytes = img.encodeJpg(decoded, quality: 80);
  return base64Encode(jpegBytes);
}
