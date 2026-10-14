import 'package:flutter/material.dart';

import '../shared/rating_button.dart';
import '../theme/app_theme.dart';
import 'filter_options.dart';
import 'recipe_list_controller.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({
    super.key,
    required this.controller,
    required this.navigateBack,
  });

  final RecipeListController controller;
  final VoidCallback navigateBack;

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late final TextEditingController _searchController;
  late final TextEditingController _recipeTitleController;

  @override
  void initState() {
    super.initState();
    final filter = widget.controller.filterOptions;
    _searchController = TextEditingController(text: filter.searchQuery);
    _recipeTitleController = TextEditingController(text: filter.recipeTitle);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _recipeTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.borderColor),
    );

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final filterOptions = widget.controller.filterOptions;
        final tags = widget.controller.tags;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'Filter Recipes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            leading: IconButton(
              onPressed: widget.navigateBack,
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Search',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        TextField(
                          controller: _searchController,
                          onChanged: widget.controller.updateSearchQuery,
                          decoration: InputDecoration(
                            hintText: 'Search recipes…',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: outlineBorder,
                            enabledBorder: outlineBorder,
                            focusedBorder: outlineBorder,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Recipe Title',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        TextField(
                          controller: _recipeTitleController,
                          onChanged: widget.controller.updateRecipeTitle,
                          decoration: InputDecoration(
                            hintText: 'e.g. Arrabbiata sauce',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: outlineBorder,
                            enabledBorder: outlineBorder,
                            focusedBorder: outlineBorder,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'My recipes only',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Switch(
                          value: filterOptions.filterByMine,
                          onChanged: (_) =>
                              widget.controller.updateFilterByMine(),
                          activeThumbColor: Colors.white,
                          activeTrackColor: AppColors.teal,
                          inactiveThumbColor: AppColors.charcoal,
                          inactiveTrackColor: AppColors.lightTeal,
                          trackOutlineColor:
                              WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.transparent;
                            }
                            return AppColors.teal;
                          }),
                        ),
                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Rating',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Row(
                          children: [
                            for (int index = 0; index < 5; index++) ...[
                              if (index > 0) const SizedBox(width: 12),
                              RatingButton(
                                rating: index + 1,
                                isSelected: (index + 1) == filterOptions.rating,
                                isFilled: (index + 1) < filterOptions.rating,
                                onClick: () =>
                                    widget.controller.updateRating(index + 1),
                              ),
                            ],
                          ],
                        ),
                        if (tags.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Tags',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: tags.map((tagName) {
                              final isSelected = filterOptions.selectedTags
                                  .contains(tagName);
                              return _TagFilterChip(
                                text: tagName,
                                isSelected: isSelected,
                                onClick: () {
                                  if (isSelected) {
                                    widget.controller.removeTag(tagName);
                                  } else {
                                    widget.controller.addTag(tagName);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Sort By',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        RadioGroup<SortByFilter>(
                          groupValue: filterOptions.sortBy,
                          onChanged: (SortByFilter? value) {
                            if (value != null) {
                              widget.controller.updateSortBy(value);
                            }
                          },
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () => widget.controller
                                        .updateSortBy(SortByFilter.defaultSort),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Radio<SortByFilter>(
                                            value: SortByFilter.defaultSort,
                                            activeColor: AppColors.teal,
                                          ),
                                          Text(SortByFilter.defaultSort.title),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () => widget.controller
                                        .updateSortBy(SortByFilter.rating),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Radio<SortByFilter>(
                                            value: SortByFilter.rating,
                                            activeColor: AppColors.teal,
                                          ),
                                          Text(SortByFilter.rating.title),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () => widget.controller.updateSortBy(
                                      SortByFilter.alphabetical,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Radio<SortByFilter>(
                                            value: SortByFilter.alphabetical,
                                            activeColor: AppColors.teal,
                                          ),
                                          Text(SortByFilter.alphabetical.title),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () => widget.controller
                                        .updateSortBy(SortByFilter.popularity),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Radio<SortByFilter>(
                                            value: SortByFilter.popularity,
                                            activeColor: AppColors.teal,
                                          ),
                                          Text(SortByFilter.popularity.title),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: OutlinedButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    _recipeTitleController.clear();
                                    widget.navigateBack();
                                    widget.controller.resetFilters();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.teal,
                                    side: const BorderSide(
                                      color: AppColors.teal,
                                      width: 1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Reset',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () {
                                    widget.navigateBack();
                                    widget.controller.applyFilters();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.teal,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Apply Filters',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _TagFilterChip extends StatelessWidget {
  const _TagFilterChip({
    required this.text,
    required this.isSelected,
    required this.onClick,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightTeal : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            width: 1,
            color: isSelected ? AppColors.lightTeal : AppColors.borderColor,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? AppColors.teal : AppColors.textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
