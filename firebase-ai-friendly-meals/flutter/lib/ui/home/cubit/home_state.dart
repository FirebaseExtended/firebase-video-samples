part of 'home_cubit.dart';

enum HomeViewState {
  initial,
  loading,
  success,
  failure;

  bool get isLoading => this == loading;
  bool get isFailure => this == failure;
}

final class HomeState extends Equatable {
  const HomeState({
    this.ingredients = '',
    this.notes = '',
    this.selectedImage,
    this.recipe,
    this.status = HomeViewState.initial,
    this.errorMessage,
  });

  final String ingredients;
  final String notes;
  final Uint8List? selectedImage;
  final Recipe? recipe;
  final HomeViewState status;
  final String? errorMessage;

  HomeState copyWith({
    String? ingredients,
    String? notes,
    ValueGetter<Uint8List?>? selectedImage,
    ValueGetter<Recipe?>? recipe,
    HomeViewState? status,
    ValueGetter<String?>? errorMessage,
  }) {
    return HomeState(
      ingredients: ingredients ?? this.ingredients,
      notes: notes ?? this.notes,
      selectedImage: selectedImage != null
          ? selectedImage()
          : this.selectedImage,
      recipe: recipe != null ? recipe() : this.recipe,
      status: status ?? this.status,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    ingredients,
    notes,
    selectedImage,
    recipe,
    status,
    errorMessage,
  ];
}
