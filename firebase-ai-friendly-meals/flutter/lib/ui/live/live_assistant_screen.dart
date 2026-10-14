import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:record/record.dart';

import '../../data/app_repositories.dart';
import '../../data/datasource/live_ai_remote_datasource.dart';
import '../../data/model/grocery_item.dart';
import '../../data/model/recipe.dart';
import '../shared/audio_component.dart';
import '../theme/app_theme.dart';

sealed class LiveAssistantUiState {
  const LiveAssistantUiState();
}

class LiveAssistantLoading extends LiveAssistantUiState {
  const LiveAssistantLoading();
}

class LiveAssistantSuccess extends LiveAssistantUiState {
  const LiveAssistantSuccess(this.recipe);
  final Recipe recipe;
}

class LiveAssistantError extends LiveAssistantUiState {
  const LiveAssistantError(this.message);
  final String message;
}

class LiveAssistantScreen extends StatefulWidget {
  const LiveAssistantScreen({
    super.key,
    required this.recipeId,
    required this.repositories,
    required this.navigateBack,
    required this.showError,
  });

  final String recipeId;
  final AppRepositories repositories;
  final VoidCallback navigateBack;
  final VoidCallback showError;

  @override
  State<LiveAssistantScreen> createState() => _LiveAssistantScreenState();
}

class _LiveAssistantScreenState extends State<LiveAssistantScreen> {
  static const String _mimeType = 'image/jpeg';
  static const String _recipeError = 'Failed to load recipe';
  static const String _connectionError = 'Failed to connect to live assistant';

  LiveAssistantUiState _uiState = const LiveAssistantLoading();

  LiveSession? _liveSession;
  bool _isConnected = false;
  int _lastFrameTimeMs = 0;
  bool _encodingFrame = false;

  CameraController? _cameraController;
  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<Uint8List>? _micSubscription;
  StreamSubscription<LiveServerResponse>? _serverSubscription;

  final BytesBuilder _incomingAudioBuffer = BytesBuilder(copy: false);
  final List<Uint8List> _playbackQueue = [];
  bool _isPlayingAudio = false;
  final AudioComponent _audioComponent = AudioComponent();

  @override
  void initState() {
    super.initState();
    _loadRecipeAndConnect();
  }

  @override
  void dispose() {
    _endConversation();
    super.dispose();
  }

  Future<void> _loadRecipeAndConnect() async {
    try {
      final recipe = await widget.repositories.databaseRepository
          .getRecipe(widget.recipeId);

      if (!mounted) return;
      if (recipe.title.trim().isEmpty) {
        setState(() {
          _uiState = const LiveAssistantError(_recipeError);
        });
        return;
      }

      setState(() {
        _uiState = LiveAssistantSuccess(recipe);
      });
      await _initializeCamera();
      await _setupLiveSession(recipe);
    } catch (e) {
      debugPrint('Error in _loadRecipeAndConnect: $e');
      if (!mounted) return;
      setState(() {
        _uiState = const LiveAssistantError(_recipeError);
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        widget.showError();
        return;
      }

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
      });

      await controller.startImageStream(_onCameraFrame);
    } catch (e) {
      debugPrint('Error initializing camera for Live Assistant: $e');
      widget.showError();
    }
  }

  void _onCameraFrame(CameraImage cameraImage) {
    if (!_isConnected || _liveSession == null || _encodingFrame) return;

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    // Limit sending frames to once per second to conserve bandwidth and processing
    if (nowMs - _lastFrameTimeMs < 1000) return;
    _lastFrameTimeMs = nowMs;
    _encodingFrame = true;

    _convertCameraImageToJpeg(cameraImage).then((jpegBytes) {
      if (jpegBytes != null && _isConnected && _liveSession != null) {
        _liveSession!.sendVideoRealtime(InlineDataPart(_mimeType, jpegBytes));
      }
    }).catchError((Object e) {
      debugPrint('Error sending video frame: $e');
    }).whenComplete(() {
      _encodingFrame = false;
    });
  }

  Future<Uint8List?> _convertCameraImageToJpeg(CameraImage image) async {
    try {
      if (image.planes.isEmpty) return null;
      final width = image.width;
      final height = image.height;
      final yPlane = image.planes[0];
      final yBytes = Uint8List.fromList(yPlane.bytes);
      final yRowStride = yPlane.bytesPerRow;

      return compute(
        _encodeGrayscaleOrYuvFrame,
        _FrameData(
          width: width,
          height: height,
          yBytes: yBytes,
          yRowStride: yRowStride,
        ),
      );
    } catch (e) {
      debugPrint('Error converting camera frame: $e');
      return null;
    }
  }

  static Uint8List _encodeGrayscaleOrYuvFrame(_FrameData data) {
    final buffer = img.Image(width: data.width, height: data.height);
    for (int y = 0; y < data.height; y++) {
      final rowOffset = y * data.yRowStride;
      for (int x = 0; x < data.width; x++) {
        final index = rowOffset + x;
        final lum = index < data.yBytes.length ? data.yBytes[index] : 0;
        buffer.setPixelRgb(x, y, lum, lum, lum);
      }
    }
    return Uint8List.fromList(img.encodeJpg(buffer, quality: 80));
  }

  Future<void> _setupLiveSession(Recipe recipe) async {
    final session =
        await widget.repositories.liveAiRepository.setupLiveSession(recipe);

    if (!mounted) {
      await session?.close();
      return;
    }

    if (session == null) {
      setState(() {
        _uiState = const LiveAssistantError(_connectionError);
      });
    } else {
      _liveSession = session;
      _isConnected = true;
      await _startConversation();
    }
  }

  Future<void> _startConversation() async {
    final session = _liveSession;
    if (session == null) return;

    _serverSubscription = session.receive().listen(
      (response) async {
        final message = response.message;
        if (message is LiveServerContent) {
          final parts = message.modelTurn?.parts ?? const [];
          for (final part in parts) {
            if (part is InlineDataPart &&
                part.mimeType.startsWith('audio/pcm')) {
              _incomingAudioBuffer.add(part.bytes);
            }
          }
          if (message.turnComplete == true ||
              _incomingAudioBuffer.length >= 48000) {
            final bytes = _incomingAudioBuffer.takeBytes();
            if (bytes.isNotEmpty) {
              _enqueueAudioPlayback(bytes);
            }
          }
        } else if (message is LiveServerToolCall) {
          final calls = message.functionCalls ?? const [];
          if (calls.isNotEmpty) {
            final responses = <FunctionResponse>[];
            for (final call in calls) {
              responses.add(await _handleFunctionCall(call));
            }
            await session.sendToolResponse(responses);
          }
        }
      },
      onError: (Object error) {
        debugPrint('LiveSession receive error: $error');
      },
    );

    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (hasPermission) {
        final micStream = await _audioRecorder.startStream(
          const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: 16000,
            numChannels: 1,
          ),
        );
        _micSubscription = micStream.listen((chunk) {
          if (_isConnected && _liveSession != null && chunk.isNotEmpty) {
            _liveSession!.sendAudioRealtime(
              InlineDataPart('audio/pcm;rate=16000', chunk),
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error starting microphone stream: $e');
    }
  }

  void _enqueueAudioPlayback(Uint8List pcmBytes) {
    _playbackQueue.add(pcmBytes);
    if (!_isPlayingAudio) {
      _playNextAudioChunk();
    }
  }

  Future<void> _playNextAudioChunk() async {
    if (_playbackQueue.isEmpty || !mounted) {
      _isPlayingAudio = false;
      return;
    }
    _isPlayingAudio = true;
    final nextChunk = _playbackQueue.removeAt(0);
    await _audioComponent.play(nextChunk, () {
      _playNextAudioChunk();
    });
  }

  Future<FunctionResponse> _handleFunctionCall(FunctionCall functionCall) async {
    if (functionCall.name == LiveAIRemoteDataSource.addIngredientsToolName) {
      final rawArg =
          functionCall.args[LiveAIRemoteDataSource.ingredientFieldName];
      final ingredientName =
          rawArg?.toString().trim().replaceAll('"', '') ?? '';

      if (ingredientName.isNotEmpty) {
        final userId =
            widget.repositories.authRepository.currentUser?.uid ?? '';
        if (userId.isNotEmpty) {
          final item = GroceryItem(
            userId: userId,
            name: ingredientName,
            checked: false,
          );
          await widget.repositories.databaseRepository.addGroceryItem(item);
        }
      }

      return FunctionResponse(
        functionCall.name,
        {'result': 'Successfully added $ingredientName to grocery list'},
        id: functionCall.id,
      );
    }

    return FunctionResponse(
      functionCall.name,
      const {},
      id: functionCall.id,
    );
  }

  Future<void> _endConversation() async {
    _isConnected = false;
    await _micSubscription?.cancel();
    _micSubscription = null;
    try {
      await _audioRecorder.stop();
      await _audioRecorder.dispose();
    } catch (_) {}
    await _serverSubscription?.cancel();
    _serverSubscription = null;
    await _audioComponent.release();
    final cam = _cameraController;
    _cameraController = null;
    if (cam != null) {
      try {
        if (cam.value.isStreamingImages) {
          await cam.stopImageStream();
        }
        await cam.dispose();
      } catch (_) {}
    }
    final session = _liveSession;
    _liveSession = null;
    try {
      await session?.close();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: widget.navigateBack,
                      tooltip: 'Back',
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Live Cooking Assistant',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: switch (_uiState) {
                LiveAssistantLoading() => const Center(
                    child: CircularProgressIndicator(color: AppColors.teal),
                  ),
                LiveAssistantError(:final message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                LiveAssistantSuccess() => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_cameraController != null &&
                              _cameraController!.value.isInitialized)
                            CameraPreview(_cameraController!)
                          else
                            const ColoredBox(color: Colors.black),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              color: Colors.black.withValues(alpha: 0.6),
                              padding: const EdgeInsets.all(16),
                              child: const Text(
                                'Point your camera at your cooking and ask questions',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FrameData {
  const _FrameData({
    required this.width,
    required this.height,
    required this.yBytes,
    required this.yRowStride,
  });

  final int width;
  final int height;
  final Uint8List yBytes;
  final int yRowStride;
}
