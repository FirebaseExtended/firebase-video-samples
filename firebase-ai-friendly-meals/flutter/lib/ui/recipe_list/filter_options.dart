enum SortByFilter {
  defaultSort('Default'),
  rating('Rating'),
  alphabetical('Alphabetical'),
  popularity('Popularity');

  const SortByFilter(this.title);
  final String title;
}

class FilterOptions {
  const FilterOptions({
    this.recipeTitle = '',
    this.searchQuery = '',
    this.filterByMine = false,
    this.rating = 0,
    this.selectedTags = const [],
    this.sortBy = SortByFilter.defaultSort,
  });

  final String recipeTitle;
  final String searchQuery;
  final bool filterByMine;
  final int rating;
  final List<String> selectedTags;
  final SortByFilter sortBy;

  FilterOptions copyWith({
    String? recipeTitle,
    String? searchQuery,
    bool? filterByMine,
    int? rating,
    List<String>? selectedTags,
    SortByFilter? sortBy,
  }) {
    return FilterOptions(
      recipeTitle: recipeTitle ?? this.recipeTitle,
      searchQuery: searchQuery ?? this.searchQuery,
      filterByMine: filterByMine ?? this.filterByMine,
      rating: rating ?? this.rating,
      selectedTags: selectedTags ?? this.selectedTags,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
