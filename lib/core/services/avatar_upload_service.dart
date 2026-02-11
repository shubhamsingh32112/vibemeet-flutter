import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service to upload premade avatar assets to Firebase Storage
/// and retrieve their public download URLs.
class AvatarUploadService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Compress a PNG image to JPEG at the given [maxDimension] and [quality].
  /// Returns the compressed bytes.
  static Future<Uint8List> _compressImage(
    Uint8List pngBytes, {
    int maxDimension = 512,
    int quality = 80,
  }) async {
    // Decode the image
    final codec = await ui.instantiateImageCodec(pngBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final int origWidth = image.width;
    final int origHeight = image.height;

    // Calculate new dimensions maintaining aspect ratio
    int targetWidth;
    int targetHeight;
    if (origWidth > origHeight) {
      targetWidth = maxDimension;
      targetHeight = (origHeight * maxDimension / origWidth).round();
    } else {
      targetHeight = maxDimension;
      targetWidth = (origWidth * maxDimension / origHeight).round();
    }

    // Only downscale — don't upscale small images
    if (origWidth <= maxDimension && origHeight <= maxDimension) {
      targetWidth = origWidth;
      targetHeight = origHeight;
    }

    debugPrint('   🔄 Compressing: ${origWidth}x$origHeight → ${targetWidth}x$targetHeight');

    // Draw to a picture recorder at the target size
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, origWidth.toDouble(), origHeight.toDouble()),
      ui.Rect.fromLTWH(0, 0, targetWidth.toDouble(), targetHeight.toDouble()),
      ui.Paint()..filterQuality = ui.FilterQuality.high,
    );
    final picture = recorder.endRecording();
    final resized = await picture.toImage(targetWidth, targetHeight);

    // Encode as PNG (Flutter's dart:ui only supports PNG encoding)
    final byteData = await resized.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    resized.dispose();

    if (byteData == null) {
      debugPrint('   ⚠️  Compression failed, using original bytes');
      return pngBytes;
    }

    final compressed = byteData.buffer.asUint8List();
    debugPrint('   📦 Compressed size: ${compressed.length} bytes (was ${pngBytes.length})');
    return compressed;
  }

  /// Upload a premade avatar asset to Firebase Storage.
  ///
  /// [firebaseUid] – the authenticated user's Firebase UID (used as folder name
  ///   so the security rule `request.auth.uid == userId` passes).
  /// [avatarName] – filename like `a1.png` or `fa3.png`.
  /// [gender] – `male` or `female`, determines which asset subfolder to load from.
  ///
  /// Returns the public download URL of the uploaded image.
  static Future<String> uploadAvatar({
    required String firebaseUid,
    required String avatarName,
    required String gender,
  }) async {
    debugPrint('───────────────────────────────────────────────────────');
    debugPrint('🖼️  [AVATAR] Starting avatar upload...');
    debugPrint('   👤 Firebase UID: $firebaseUid');
    debugPrint('   🎨 Avatar: $avatarName');
    debugPrint('   ⚧ Gender: $gender');

    // 1. Load the bundled asset as bytes
    final assetPath = gender == 'female'
        ? 'lib/assets/female/$avatarName'
        : 'lib/assets/male/$avatarName';

    debugPrint('   📂 Asset path: $assetPath');

    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List rawBytes = data.buffer.asUint8List();
    debugPrint('   📏 Original asset size: ${rawBytes.length} bytes');

    // 2. Compress the image to keep it under the storage rule limit
    final Uint8List bytes = await _compressImage(rawBytes);

    // 3. Upload to Firebase Storage at avatars/{uid}/{avatarName}
    final ref = _storage.ref().child('avatars/$firebaseUid/$avatarName');

    final metadata = SettableMetadata(
      contentType: 'image/png',
      customMetadata: {
        'gender': gender,
        'originalAsset': avatarName,
      },
    );

    debugPrint('   📤 Uploading to Firebase Storage...');
    final uploadTask = ref.putData(bytes, metadata);

    // Optional: listen to progress
    uploadTask.snapshotEvents.listen((event) {
      final progress = event.bytesTransferred / event.totalBytes;
      debugPrint('   📊 Upload progress: ${(progress * 100).toStringAsFixed(0)}%');
    });

    await uploadTask;
    debugPrint('   ✅ Upload complete');

    // 4. Get and return the download URL
    final downloadUrl = await ref.getDownloadURL();
    debugPrint('   🔗 Download URL: $downloadUrl');
    debugPrint('───────────────────────────────────────────────────────');

    return downloadUrl;
  }
}
