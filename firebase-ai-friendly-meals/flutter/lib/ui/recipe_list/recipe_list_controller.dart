import 'package:flutter/foundation.dart';

import '../../data/app_repositories.dart';
import '../../data/model/recipe.dart';
import 'filter_options.dart';

class RecipeListController extends ChangeNotifier {
  RecipeListController(this._repositories);

  final AppRepositories _repositories;

  FilterOptions _filterOptions = const FilterOptions();
  FilterOptions get filterOptions => _filterOptions;

  List<String> _tags = const [];
  List<String> get tags => _tags;

  List<RecipeListItem> _recipes = const [];
  List<RecipeListItem> get recipes => _recipes;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repositories.databaseRepository.getAllRecipes(),
        _repositories.databaseRepository.getPopularTags(),
      ]);
      _recipes = results[0] as List<RecipeListItem>;
      _tags = results[1] as List<String>;
    } catch (e) {
      debugPrint('Error loading recipes and popular tags: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void updateRecipeTitle(String recipeName) {
    _filterOptions = _filterOptions.copyWith(recipeTitle: recipeName);
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _filterOptions = _filterOptions.copyWith(searchQuery: query);
    notifyListeners();
  }

  void updateFilterByMine() {
    _filterOptions = _filterOptions.copyWith(
      filterByMine: !_filterOptions.filterByMine,
    );
    notifyListeners();
  }

  void updateRating(int rating) {
    _filterOptions = _filterOptions.copyWith(rating: rating);
    notifyListeners();
  }

  void removeTag(String tag) {
    _filterOptions = _filterOptions.copyWith(
      selectedTags:
          _filterOptions.selectedTags.where((item) => item != tag).toList(),
    );
    notifyListeners();
  }

  void addTag(String tag) {
    _filterOptions = _filterOptions.copyWith(
      selectedTags: [..._filterOptions.selectedTags, tag],
    );
    notifyListeners();
  }

  void updateSortBy(SortByFilter sortByFilter) {
    _filterOptions = _filterOptions.copyWith(sortBy: sortByFilter);
    notifyListeners();
  }

  Future<void> resetFilters() async {
    _filterOptions = const FilterOptions();
    _loading = true;
    notifyListeners();
    try {
      _recipes = await _repositories.databaseRepository.getAllRecipes();
    } catch (e) {
      debugPrint('Error resetting recipe filters: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> applyFilters() async {
    final filter = _filterOptions;
    final userId = _repositories.authRepository.currentUser?.uid ?? '';
    _loading = true;
    notifyListeners();
    try {
      _recipes = await _repositories.databaseRepository.getFilteredRecipes(
        filter,
        userId,
      );
    } catch (e) {
      debugPrint('Error applying recipe filters: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
