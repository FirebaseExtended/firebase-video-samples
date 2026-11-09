import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../ui/recipe_list/filter_options.dart';
import '../model/grocery_item.dart';
import '../model/like.dart';
import '../model/recipe.dart';
import '../model/review.dart';
import '../model/user.dart';

class DatabaseRemoteDataSource {
  DatabaseRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ??
            FirebaseFirestore.instanceFor(
              app: Firebase.app(),
              databaseId: 'default',
            );

  final FirebaseFirestore _firestore;

  // Collections
  static const String usersCollection = 'users';
  static const String recipesCollection = 'recipes';
  static const String likesCollection = 'likes';
  static const String reviewsSubcollection = 'reviews';
  static const String groceriesCollection = 'groceries';

  // Fields
  static const String ratingField = 'rating';
  static const String averageRatingField = 'averageRating';
  static const String authorIdField = 'authorId';
  static const String titleField = 'title';
  static const String tagsField = 'tags';
  static const String likesField = 'likes';
  static const String imageUriField = 'imageUri';
  static const String prepTimeField = 'prepTime';
  static const String cookTimeField = 'cookTime';
  static const String servingsField = 'servings';
  static const String instructionsField = 'instructions';
  static const String ingredientsField = 'ingredients';
  static const String recipeIdField = 'recipeId';
  static const String userIdField = 'userId';
  static const String checkedField = 'checked';

  // Field aliases
  static const String avgRatingAlias = 'avg_rating';
  static const String tagNameAlias = 'tagName';
  static const String tagCountAlias = 'tagCount';
  static const String likesCountAlias = 'likesCount';
  static const String scoreAlias = 'score';

  // Field paths
  static const String nameFieldPath = '__name__';

  Future<void> addUser(AppUser user) async {
    await _firestore.collection(usersCollection).add(user.toMap());
  }

  Future<String> addRecipe(Recipe recipe) async {
    final recipeRef = await _firestore
        .collection(recipesCollection)
        .add(recipe.toFirestore());
    return recipeRef.id;
  }

  Future<Recipe> getRecipe(String recipeId) async {
    if (recipeId.isEmpty) {
      return const Recipe();
    }

    final resultsFuture = _firestore
        .pipeline()
        .collection(recipesCollection)
        .where(
          Expression.field(nameFieldPath).documentId().equalValue(recipeId),
        )
        .execute();
    final avgRatingFuture = _firestore
        .pipeline()
        .collection('$recipesCollection/$recipeId/$reviewsSubcollection')
        .aggregate(Expression.field(ratingField).average().as(avgRatingAlias))
        .execute();

    final docSnapshot = await resultsFuture;
    final docResults = docSnapshot.result;

    if (docResults.isEmpty) {
      return const Recipe();
    }

    final itemData = Map<String, dynamic>.from(docResults.first.data() ?? {});
    try {
      final ratingSnapshot = await avgRatingFuture;
      final ratingResults = ratingSnapshot.result;
      if (ratingResults.isNotEmpty) {
        final ratingData = ratingResults.first.data();
        final computedAvg = (ratingData?[avgRatingAlias] as num?)?.toDouble();
        if (computedAvg != null) {
          itemData[averageRatingField] = computedAvg;
        }
      }
    } catch (e) {
      debugPrint('Error aggregating recipe rating: $e');
    }

    return _mapToRecipe(itemData);
  }

  Future<List<RecipeListItem>> getAllRecipes() async {
    final recipesFuture =
        _firestore.pipeline().collection(recipesCollection).execute();
    final ratingsFuture = _getAverageRatingsByRecipeId();

    final results = await Future.wait([recipesFuture, ratingsFuture]);
    final pipelineResults = (results[0] as PipelineSnapshot).result;
    final ratingsMap = results[1] as Map<String, double>;

    return _toRecipeListItems(pipelineResults, ratingsMap: ratingsMap);
  }

  Future<List<String>> getPopularTags() async {
    final snapshot = await _firestore
        .pipeline()
        .collection(recipesCollection)
        .unnest(Expression.field(tagsField).as(tagNameAlias))
        .aggregateWithOptions(
          AggregateStageOptions(
            accumulators: [CountAll().as(tagCountAlias)],
            groups: [Expression.field(tagNameAlias)],
          ),
        )
        .sort(Expression.field(tagCountAlias).descending())
        .limit(10)
        .execute();

    return snapshot.result
        .map((r) => r.data()?[tagNameAlias])
        .whereType<String>()
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  /// Enforces a "one review per user" constraint using deterministic document ID "${recipeId}_${userId}".
  Future<void> setReview(Review review) async {
    final reviewRef = _firestore
        .collection(recipesCollection)
        .doc(review.recipeId)
        .collection(reviewsSubcollection)
        .doc('${review.recipeId}_${review.userId}');

    await reviewRef.set(review.toMap());
  }

  Future<int> getRating(String userId, String recipeId) async {
    if (userId.isEmpty || recipeId.isEmpty) return 0;
    final reviewId = '${recipeId}_$userId';

    final snapshot = await _firestore
        .pipeline()
        .collection('$recipesCollection/$recipeId/$reviewsSubcollection')
        .where(
          Expression.field(nameFieldPath).documentId().equalValue(reviewId),
        )
        .execute();
    final results = snapshot.result;
    if (results.isEmpty) return 0;

    final reviewData = results.first.data();
    if (reviewData == null) return 0;
    return (reviewData[ratingField] as num?)?.toInt() ?? 0;
  }

  /// Enforces a "one favorite per user" constraint using deterministic document ID "${recipeId}_${userId}".
  Future<void> setFavorite(Like like) async {
    final likeRef = _firestore
        .collection(likesCollection)
        .doc('${like.recipeId}_${like.userId}');

    await likeRef.set(like.toMap());
  }

  Future<void> removeFavorite(Like like) async {
    await _firestore
        .collection(likesCollection)
        .doc('${like.recipeId}_${like.userId}')
        .delete();
  }

  Future<bool> getFavorite(String userId, String recipeId) async {
    if (userId.isEmpty || recipeId.isEmpty) return false;
    final favoriteId = '${recipeId}_$userId';

    final snapshot = await _firestore
        .pipeline()
        .collection(likesCollection)
        .where(
          Expression.field(nameFieldPath).documentId().equalValue(favoriteId),
        )
        .execute();
    return snapshot.result.any((r) => r.data() != null);
  }

  Future<List<RecipeListItem>> getFilteredRecipes(
    FilterOptions filterOptions,
    String userId,
  ) async {
    var pipeline = _firestore.pipeline().collection(recipesCollection);

    if (filterOptions.searchQuery.trim().isNotEmpty) {
      final searchStage = SearchStage.withQuery(filterOptions.searchQuery);
      pipeline = pipeline.search(searchStage);
    } else if (filterOptions.recipeTitle.trim().isNotEmpty) {
      pipeline = pipeline.where(
        Expression.field(titleField)
            .toLowerCase()
            .stringIndexOf(filterOptions.recipeTitle.toLowerCase())
            .greaterThanOrEqualValue(0),
      );
    }

    if (filterOptions.filterByMine) {
      pipeline = pipeline.where(
        Expression.field(authorIdField).equalValue(userId),
      );
    }

    if (filterOptions.selectedTags.isNotEmpty) {
      pipeline = pipeline.where(
        Expression.field(tagsField).arrayContainsAny(filterOptions.selectedTags),
      );
    }

    if (filterOptions.sortBy == SortByFilter.alphabetical) {
      pipeline = pipeline.sort(Expression.field(titleField).ascending());
    }

    final recipesFuture = pipeline.execute();
    final ratingsFuture = _getAverageRatingsByRecipeId();
    final likesFuture = filterOptions.sortBy == SortByFilter.popularity
        ? _getLikesCountByRecipeId()
        : Future.value(<String, int>{});

    final results = await Future.wait([
      recipesFuture,
      ratingsFuture,
      likesFuture,
    ]);

    final pipelineResults = (results[0] as PipelineSnapshot).result;
    final ratingsMap = results[1] as Map<String, double>;
    final likesMap = results[2] as Map<String, int>;

    var items = _toRecipeListItems(pipelineResults, ratingsMap: ratingsMap);

    if (filterOptions.rating > 0) {
      items = items
          .where((item) => item.averageRating >= filterOptions.rating)
          .toList();
    }

    switch (filterOptions.sortBy) {
      case SortByFilter.defaultSort:
      case SortByFilter.alphabetical:
        break;
      case SortByFilter.rating:
        items.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        break;
      case SortByFilter.popularity:
        items.sort(
          (a, b) => (likesMap[b.id] ?? 0).compareTo(likesMap[a.id] ?? 0),
        );
        break;
    }

    return items;
  }

  Future<Map<String, double>> _getAverageRatingsByRecipeId() async {
    try {
      final snapshot = await _firestore
          .pipeline()
          .collectionGroup(reviewsSubcollection)
          .aggregateWithOptions(
            AggregateStageOptions(
              accumulators: [
                Expression.field(ratingField).average().as(avgRatingAlias),
              ],
              groups: [
                Expression.field(recipeIdField),
              ],
            ),
          )
          .execute();

      final map = <String, double>{};
      for (final r in snapshot.result) {
        final data = r.data();
        if (data == null) continue;
        final recipeId = data[recipeIdField] as String?;
        final avgRating = (data[avgRatingAlias] as num?)?.toDouble();
        if (recipeId != null && avgRating != null) {
          map[recipeId] = avgRating;
        }
      }
      return map;
    } catch (e) {
      debugPrint('Error aggregating ratings across recipes: $e');
      return {};
    }
  }

  Future<Map<String, int>> _getLikesCountByRecipeId() async {
    try {
      final snapshot = await _firestore
          .pipeline()
          .collectionGroup(likesCollection)
          .aggregateWithOptions(
            AggregateStageOptions(
              accumulators: [CountAll().as(likesCountAlias)],
              groups: [Expression.field(recipeIdField)],
            ),
          )
          .execute();

      final map = <String, int>{};
      for (final r in snapshot.result) {
        final data = r.data();
        if (data == null) continue;
        final recipeId = data[recipeIdField] as String?;
        final count = (data[likesCountAlias] as num?)?.toInt();
        if (recipeId != null && count != null) {
          map[recipeId] = count;
        }
      }
      return map;
    } catch (e) {
      debugPrint('Error aggregating likes across recipes: $e');
      return {};
    }
  }

  Recipe _mapToRecipe(Map<String, dynamic> itemData) {
    return Recipe(
      title: itemData[titleField] as String? ?? '',
      instructions: itemData[instructionsField] as String? ?? '',
      ingredients: (itemData[ingredientsField] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
      authorId: itemData[authorIdField] as String? ?? '',
      tags: (itemData[tagsField] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
      averageRating: (itemData[averageRatingField] as num?)?.toDouble() ?? 0.0,
      prepTime: itemData[prepTimeField] as String? ?? '',
      cookTime: itemData[cookTimeField] as String? ?? '',
      servings: itemData[servingsField] as String? ?? '',
      imageUri: itemData[imageUriField] as String?,
    );
  }

  List<RecipeListItem> _toRecipeListItems(
    List<PipelineResult> results, {
    required Map<String, double> ratingsMap,
  }) {
    final list = <RecipeListItem>[];
    for (final result in results) {
      final id = result.document?.id;
      final itemData = result.data();
      if (id == null || id.isEmpty || itemData == null) {
        debugPrint('DatabaseRemoteDataSource: Empty recipe ID or data');
        continue;
      }

      final avgRating = ratingsMap[id] ??
          (itemData[averageRatingField] as num?)?.toDouble() ??
          0.0;

      list.add(
        RecipeListItem(
          id: id,
          title: itemData[titleField] as String? ?? '',
          averageRating: avgRating,
          imageUri: itemData[imageUriField] as String?,
        ),
      );
    }
    return list;
  }

  Stream<List<GroceryItem>> getGroceriesStream(String userId) {
    if (userId.isEmpty) {
      return Stream.value(const []);
    }

    return _firestore
        .collection(groceriesCollection)
        .where(userIdField, isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return GroceryItem.fromMap(doc.data(), docId: doc.id);
      }).toList();
    });
  }

  Future<void> addGroceryItem(GroceryItem item) async {
    final docRef = _firestore.collection(groceriesCollection).doc();
    final itemWithId = item.copyWith(id: docRef.id);
    await docRef.set(itemWithId.toMap());
  }

  Future<void> updateGroceryItemChecked(String itemId, bool checked) async {
    await _firestore
        .collection(groceriesCollection)
        .doc(itemId)
        .update({checkedField: checked});
  }

  Future<void> deleteGroceryItem(String itemId) async {
    await _firestore.collection(groceriesCollection).doc(itemId).delete();
  }

  Future<void> addIngredientsToGroceries(
    String userId,
    List<String> ingredients,
  ) async {
    if (userId.isEmpty || ingredients.isEmpty) return;

    final batch = _firestore.batch();
    final collection = _firestore.collection(groceriesCollection);

    for (final ingredient in ingredients) {
      final docRef = collection.doc();
      final item = GroceryItem(
        id: docRef.id,
        userId: userId,
        name: ingredient,
        checked: false,
      );
      batch.set(docRef, item.toMap());
    }
    await batch.commit();
  }
}
