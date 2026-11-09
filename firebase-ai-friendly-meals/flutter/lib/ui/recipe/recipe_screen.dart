import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/app_repositories.dart';
import '../../data/model/like.dart';
import '../../data/model/recipe.dart';
import '../../data/model/review.dart';
import '../shared/audio_component.dart';
import '../shared/rating_button.dart';
import '../theme/app_theme.dart';

sealed class RecipeAudioState {
  const RecipeAudioState();
}

class RecipeAudioIdle extends RecipeAudioState {
  const RecipeAudioIdle();
}

class RecipeAudioLoading extends RecipeAudioState {
  const RecipeAudioLoading();
}

class RecipeAudioPlaying extends RecipeAudioState {
  const RecipeAudioPlaying();
}

class RecipeAudioPaused extends RecipeAudioState {
  const RecipeAudioPaused();
}

class RecipeAudioError extends RecipeAudioState {
  const RecipeAudioError(this.message);
  final String message;
}

class RecipeViewState {
  const RecipeViewState({
    this.recipeId = '',
    this.recipe = const Recipe(),
    this.favorite = false,
    this.rating = 0,
    this.audioState = const RecipeAudioIdle(),
  });

  final String recipeId;
  final Recipe recipe;
  final bool favorite;
  final int rating;
  final RecipeAudioState audioState;

  RecipeViewState copyWith({
    String? recipeId,
    Recipe? recipe,
    bool? favorite,
    int? rating,
    RecipeAudioState? audioState,
  }) {
    return RecipeViewState(
      recipeId: recipeId ?? this.recipeId,
      recipe: recipe ?? this.recipe,
      favorite: favorite ?? this.favorite,
      rating: rating ?? this.rating,
      audioState: audioState ?? this.audioState,
    );
  }
}

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({
    super.key,
    required this.recipeId,
    required this.repositories,
    required this.navigateBack,
    required this.navigateToLiveAssistant,
  });

  final String recipeId;
  final AppRepositories repositories;
  final VoidCallback navigateBack;
  final ValueChanged<String> navigateToLiveAssistant;

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  RecipeViewState _recipeViewState = const RecipeViewState();
  final AudioComponent _audioComponent = AudioComponent();
  Uint8List? _cachedAudioData;
  String? _cachedPairingText;

  String get _userId =>
      widget.repositories.authRepository.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  @override
  void dispose() {
    _audioComponent.release();
    super.dispose();
  }

  Future<void> _loadRecipe() async {
    try {
      final results = await Future.wait([
        widget.repositories.databaseRepository.getRecipe(widget.recipeId),
        widget.repositories.databaseRepository
            .getFavorite(_userId, widget.recipeId),
        widget.repositories.databaseRepository
            .getRating(_userId, widget.recipeId),
      ]);

      if (!mounted) return;
      setState(() {
        _recipeViewState = RecipeViewState(
          recipeId: widget.recipeId,
          recipe: results[0] as Recipe,
          favorite: results[1] as bool,
          rating: results[2] as int,
          audioState: const RecipeAudioIdle(),
        );
      });
    } catch (e) {
      debugPrint('Error loading recipe: $e');
    }
  }

  Future<void> _onPairingClick() async {
    switch (_recipeViewState.audioState) {
      case RecipeAudioPlaying():
        await _audioComponent.pause();
        if (!mounted) return;
        setState(() {
          _recipeViewState = _recipeViewState.copyWith(
            audioState: const RecipeAudioPaused(),
          );
        });
      case RecipeAudioPaused():
        await _audioComponent.resume();
        if (!mounted) return;
        setState(() {
          _recipeViewState = _recipeViewState.copyWith(
            audioState: const RecipeAudioPlaying(),
          );
        });
      case RecipeAudioLoading():
        break;
      case RecipeAudioIdle():
      case RecipeAudioError():
        if (_cachedAudioData != null) {
          await _playCachedAudio();
        } else {
          await _generatePairingAndAudio();
        }
    }
  }

  Future<void> _playCachedAudio() async {
    final audioData = _cachedAudioData;
    if (audioData == null) return;

    setState(() {
      _recipeViewState = _recipeViewState.copyWith(
        audioState: const RecipeAudioPlaying(),
      );
    });

    await _audioComponent.play(audioData, () {
      if (!mounted) return;
      setState(() {
        _recipeViewState = _recipeViewState.copyWith(
          audioState: const RecipeAudioIdle(),
        );
      });
    });
  }

  Future<void> _generatePairingAndAudio() async {
    setState(() {
      _recipeViewState = _recipeViewState.copyWith(
        audioState: const RecipeAudioLoading(),
      );
    });

    try {
      if (_cachedPairingText == null || _cachedPairingText!.trim().isEmpty) {
        final recipe = _recipeViewState.recipe;
        final generated = await widget.repositories.aiRepository
            .craftRecipePairing(recipe.title, recipe.ingredients);
        _cachedPairingText = generated;
      }

      final audio = await widget.repositories.aiRepository
          .generateSpeech(_cachedPairingText);

      if (!mounted) return;
      if (audio != null && audio.isNotEmpty) {
        _cachedAudioData = audio;
        setState(() {
          _recipeViewState = _recipeViewState.copyWith(
            audioState: const RecipeAudioPlaying(),
          );
        });
        await _audioComponent.play(audio, () {
          if (!mounted) return;
          setState(() {
            _recipeViewState = _recipeViewState.copyWith(
              audioState: const RecipeAudioIdle(),
            );
          });
        });
      } else {
        setState(() {
          _recipeViewState = _recipeViewState.copyWith(
            audioState: const RecipeAudioError('Could not generate audio'),
          );
        });
      }
    } catch (e) {
      debugPrint('Error generating pairing audio: $e');
      if (!mounted) return;
      setState(() {
        _recipeViewState = _recipeViewState.copyWith(
          audioState: const RecipeAudioError('Could not generate audio'),
        );
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final like = Like(recipeId: widget.recipeId, userId: _userId);
    try {
      if (_recipeViewState.favorite) {
        await widget.repositories.databaseRepository.removeFavorite(like);
      } else {
        await widget.repositories.databaseRepository.setFavorite(like);
      }

      final favorite = await widget.repositories.databaseRepository
          .getFavorite(_userId, widget.recipeId);
      if (!mounted) return;
      setState(() {
        _recipeViewState = _recipeViewState.copyWith(favorite: favorite);
      });
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<void> _leaveReview(int rating) async {
    try {
      await widget.repositories.databaseRepository.setReview(
        Review(
          userId: _userId,
          recipeId: widget.recipeId,
          rating: rating,
        ),
      );

      final updatedRating = await widget.repositories.databaseRepository
          .getRating(_userId, widget.recipeId);
      if (!mounted) return;
      setState(() {
        _recipeViewState = _recipeViewState.copyWith(rating: updatedRating);
      });
    } catch (e) {
      debugPrint('Error leaving review: $e');
    }
  }

  Future<void> _onAddIngredientsToGrocery() async {
    final ingredients = _recipeViewState.recipe.ingredients;
    if (_userId.isEmpty || ingredients.isEmpty) return;

    try {
      await widget.repositories.databaseRepository
          .addIngredientsToGroceries(_userId, ingredients);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to Grocery List!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error adding ingredients to grocery list: $e');
    }
  }

  Future<void> _onLiveAssistantPressed() async {
    if (!kIsWeb) {
      final statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();
      final cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
      final audioGranted = statuses[Permission.microphone]?.isGranted ?? false;

      if (!cameraGranted || !audioGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Camera and Microphone permissions are required to use the Live Assistant.',
            ),
          ),
        );
        return;
      }
    }

    widget.navigateToLiveAssistant(_recipeViewState.recipeId);
  }

  @override
  Widget build(BuildContext context) {
    final recipe = _recipeViewState.recipe;
    final imageUri = recipe.imageUri;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            SizedBox(
              width: double.infinity,
              height: 300,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.grey.shade400,
                    child: imageUri != null && imageUri.isNotEmpty
                        ? Image.network(
                            imageUri,
                            fit: BoxFit.cover,
                            semanticLabel: 'Recipe image',
                            errorBuilder: (_, _, _) => const Center(
                              child: Text(
                                'Could not load image',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        : const Center(
                            child: Text(
                              'Could not load image',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 16,
                          left: 16,
                          right: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _FloatingHeaderIconButton(
                              onPressed: widget.navigateBack,
                              tooltip: 'Back',
                              icon: Icons.arrow_back,
                            ),
                            _FloatingHeaderIconButton(
                              onPressed: _toggleFavorite,
                              tooltip: 'Favorite',
                              icon: _recipeViewState.favorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 34 / 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _onLiveAssistantPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.soup_kitchen_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Live Cooking Assistant',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PairingGuideButton(
                    audioState: _recipeViewState.audioState,
                    onClick: _onPairingClick,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.timer_outlined,
                          label: 'Prep Time',
                          value: recipe.prepTime,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.soup_kitchen_outlined,
                          label: 'Cook Time',
                          value: recipe.cookTime,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.people_outline,
                          label: 'Servings',
                          value: recipe.servings,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ingredients',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.teal,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...recipe.ingredients
                              .map((item) => _IngredientRow(text: item)),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _onAddIngredientsToGrocery,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightTeal,
                                foregroundColor: AppColors.teal,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: AppColors.teal,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Add ingredients to Grocery List',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Instructions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.teal,
                            ),
                          ),
                          const SizedBox(height: 12),
                          MarkdownBody(
                            data: recipe.instructions,
                            styleSheet: MarkdownStyleSheet.fromTheme(
                              Theme.of(context),
                            ).copyWith(
                              p: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textColor,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rate this recipe',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.teal,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (int index = 0; index < 5; index++)
                                RatingButton(
                                  rating: index + 1,
                                  isSelected:
                                      (index + 1) == _recipeViewState.rating,
                                  isFilled:
                                      (index + 1) < _recipeViewState.rating,
                                  onClick: () => _leaveReview(index + 1),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingHeaderIconButton extends StatelessWidget {
  const _FloatingHeaderIconButton({
    required this.onPressed,
    required this.tooltip,
    required this.icon,
  });

  final VoidCallback onPressed;
  final String tooltip;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(
          icon,
          color: AppColors.textColor,
          size: 22,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.lightTeal,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.teal,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.lightTeal,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check,
              size: 14,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PairingGuideButton extends StatelessWidget {
  const _PairingGuideButton({
    required this.audioState,
    required this.onClick,
  });

  final RecipeAudioState audioState;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final Color containerColor = switch (audioState) {
      RecipeAudioPlaying() || RecipeAudioPaused() => AppColors.teal,
      RecipeAudioLoading() || RecipeAudioIdle() => AppColors.lightTeal,
      RecipeAudioError() => const Color(0xFFFFEBEE),
    };

    final Color contentColor = switch (audioState) {
      RecipeAudioPlaying() || RecipeAudioPaused() => Colors.white,
      RecipeAudioError() => Colors.red,
      RecipeAudioLoading() || RecipeAudioIdle() => AppColors.teal,
    };

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onClick,
        style: ElevatedButton.styleFrom(
          backgroundColor: containerColor,
          foregroundColor: contentColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: switch (audioState) {
            RecipeAudioLoading() => const [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: AppColors.teal,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Loading audio…',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.teal,
                  ),
                ),
              ],
            RecipeAudioPlaying() => const [
                Icon(Icons.pause, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  'Playing pairing guide • Tap to pause',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            RecipeAudioPaused() => const [
                Icon(Icons.play_arrow, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  'Paused • Tap to resume',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            RecipeAudioError() => const [
                Text(
                  'Error playing audio • Tap to retry',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            RecipeAudioIdle() => const [
                Icon(Icons.wine_bar_outlined, color: AppColors.teal, size: 20),
                SizedBox(width: 10),
                Text(
                  'Pair this dish with French wine',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.teal,
                  ),
                ),
              ],
          },
        ),
      ),
    );
  }
}
