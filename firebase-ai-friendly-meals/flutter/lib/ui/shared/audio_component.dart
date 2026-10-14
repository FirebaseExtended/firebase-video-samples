import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioComponent {
  AudioPlayer? _player;
  StreamSubscription<void>? _completionSub;

  Future<void> play(Uint8List pcmData, VoidCallback onCompletion) async {
    await stop();

    if (pcmData.isEmpty) {
      onCompletion();
      return;
    }

    try {
      final wavBytes = pcmToWav(
        pcmData,
        sampleRate: 24000,
        numChannels: 1,
        bitsPerSample: 16,
      );

      final player = AudioPlayer();
      _player = player;
      _completionSub = player.onPlayerComplete.listen((_) {
        onCompletion();
      });

      await player.play(BytesSource(wavBytes, mimeType: 'audio/wav'));
    } catch (e) {
      debugPrint('Failed to initialize or play AudioComponent: $e');
      onCompletion();
    }
  }

  Future<void> pause() async {
    try {
      await _player?.pause();
    } catch (e) {
      debugPrint('Error pausing AudioComponent: $e');
    }
  }

  Future<void> resume() async {
    try {
      await _player?.resume();
    } catch (e) {
      debugPrint('Error resuming AudioComponent: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _completionSub?.cancel();
      _completionSub = null;
      final player = _player;
      _player = null;
      if (player != null) {
        await player.stop();
        await player.dispose();
      }
    } catch (e) {
      debugPrint('Error stopping AudioComponent: $e');
    }
  }

  Future<void> release() async {
    await stop();
  }

  /// Wraps raw PCM 16-bit little-endian samples in a standard 44-byte RIFF/WAVE header.
  static Uint8List pcmToWav(
    Uint8List pcmBytes, {
    int sampleRate = 24000,
    int numChannels = 1,
    int bitsPerSample = 16,
  }) {
    final byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
    final blockAlign = numChannels * (bitsPerSample ~/ 8);
    final dataLength = pcmBytes.length;
    final totalLength = 36 + dataLength;

    final header = ByteData(44);
    // "RIFF"
    header.setUint8(0, 0x52);
    header.setUint8(1, 0x49);
    header.setUint8(2, 0x46);
    header.setUint8(3, 0x46);
    header.setUint32(4, totalLength, Endian.little);
    // "WAVE"
    header.setUint8(8, 0x57);
    header.setUint8(9, 0x41);
    header.setUint8(10, 0x56);
    header.setUint8(11, 0x45);
    // "fmt "
    header.setUint8(12, 0x66);
    header.setUint8(13, 0x6D);
    header.setUint8(14, 0x74);
    header.setUint8(15, 0x20);
    header.setUint32(16, 16, Endian.little); // Subchunk1Size for PCM
    header.setUint16(20, 1, Endian.little); // AudioFormat = 1 (PCM)
    header.setUint16(22, numChannels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    // "data"
    header.setUint8(36, 0x64);
    header.setUint8(37, 0x61);
    header.setUint8(38, 0x74);
    header.setUint8(39, 0x61);
    header.setUint32(40, dataLength, Endian.little);

    final wavBytes = Uint8List(44 + dataLength);
    wavBytes.setRange(0, 44, header.buffer.asUint8List());
    wavBytes.setRange(44, 44 + dataLength, pcmBytes);
    return wavBytes;
  }
}
