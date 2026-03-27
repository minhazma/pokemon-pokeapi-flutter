import 'dart:io';
import 'package:audio_converter_native/audio_converter_native.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';

class AudioCacheManager {
  static final AudioCacheManager _instance = AudioCacheManager._internal();
  factory AudioCacheManager() => _instance;
  AudioCacheManager._internal();

  final Map<String, Future<String?>> _ongoingConversions = {};

  Future<String?> getAudioPath(int id, String url, String type) async {
    final fileName = 'pokemon_${id}_$type.mp3';
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = Directory(p.join(directory.path, 'audio_cache'));

    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }

    final outputPath = p.join(audioDir.path, fileName);
    final outputFile = File(outputPath);

    if (await outputFile.exists()) {
      return outputPath;
    }

    if (_ongoingConversions.containsKey(url)) {
      return _ongoingConversions[url];
    }

    final future = _downloadAndConvert(id, url, outputPath);
    _ongoingConversions[url] = future;

    try {
      return await future;
    } finally {
      _ongoingConversions.remove(url);
    }
  }

  Future<void> preCache(int id, String url, String type) async {
    await getAudioPath(id, url, type);
  }

  Future<String?> _downloadAndConvert(int id, String url, String outputPath) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 0 && response.statusCode != 200) {
        return null;
      }

      if (response.bodyBytes.isEmpty) return null;

      final tempDir = await getTemporaryDirectory();
      final tempInputPath = p.join(tempDir.path, 'temp_${id}_${DateTime.now().microsecondsSinceEpoch}.ogg');
      final tempInputFile = File(tempInputPath);
      await tempInputFile.writeAsBytes(response.bodyBytes);

      final result = await AudioConverterService.instance.convertToMP3(inputPath: tempInputPath, outputPath: outputPath);

      if (await tempInputFile.exists()) {
        try {
          await tempInputFile.delete();
        } catch (_) {}
      }

      if (result.success) {
        return outputPath;
      }

      if (await File(outputPath).exists()) {
        return outputPath;
      }

      return null;
    } catch (e) {
      debugPrint('Error converting audio: $e');
      return null;
    }
  }
}
