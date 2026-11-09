import '../../ui/recipe_list/filter_options.dart';
import '../datasource/database_remote_datasource.dart';
import '../model/grocery_item.dart';
import '../model/like.dart';
import '../model/recipe.dart';
import '../model/review.dart';
import '../model/user.dart';

class DatabaseRepository {
  DatabaseRepository(this._databaseRemoteDataSource);

  final DatabaseRemoteDataSource _databaseRemoteDataSource;

  Future<void> addUser(AppUser user) {
    return _databaseRemoteDataSource.addUser(user);
  }

  Future<String> addRecipe(Recipe recipe) {
    return _databaseRemoteDataSource.addRecipe(recipe);
  }

  Future<Recipe> getRecipe(String recipeId) {
    return _databaseRemoteDataSource.getRecipe(recipeId);
  }

  Future<List<RecipeListItem>> getAllRecipes() {
    return _databaseRemoteDataSource.getAllRecipes();
  }

  Future<List<String>> getPopularTags() {
    return _databaseRemoteDataSource.getPopularTags();
  }

  Future<void> setReview(Review review) {
    return _databaseRemoteDataSource.setReview(review);
  }

  Future<int> getRating(String userId, String recipeId) {
    return _databaseRemoteDataSource.getRating(userId, recipeId);
  }

  Future<void> setFavorite(Like like) {
    return _databaseRemoteDataSource.setFavorite(like);
  }

  Future<void> removeFavorite(Like like) {
    return _databaseRemoteDataSource.removeFavorite(like);
  }

  Future<bool> getFavorite(String userId, String recipeId) {
    return _databaseRemoteDataSource.getFavorite(userId, recipeId);
  }

  Future<List<RecipeListItem>> getFilteredRecipes(
    FilterOptions filterOptions,
    String userId,
  ) {
    return _databaseRemoteDataSource.getFilteredRecipes(filterOptions, userId);
  }

  Stream<List<GroceryItem>> getGroceriesStream(String userId) {
    return _databaseRemoteDataSource.getGroceriesStream(userId);
  }

  Future<void> addGroceryItem(GroceryItem item) {
    return _databaseRemoteDataSource.addGroceryItem(item);
  }

  Future<void> updateGroceryItemChecked(String itemId, bool checked) {
    return _databaseRemoteDataSource.updateGroceryItemChecked(itemId, checked);
  }

  Future<void> deleteGroceryItem(String itemId) {
    return _databaseRemoteDataSource.deleteGroceryItem(itemId);
  }

  Future<void> addIngredientsToGroceries(
    String userId,
    List<String> ingredients,
  ) {
    return _databaseRemoteDataSource.addIngredientsToGroceries(
      userId,
      ingredients,
    );
  }
}
