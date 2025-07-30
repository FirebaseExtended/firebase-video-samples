import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  final String description;
  final Uint8List? image;

  const Recipe({
    required this.description,
    this.image,
  });

  Recipe copyWith({
    String? description,
    Uint8List? image,
  }) {
    return Recipe(
      description: description ?? this.description,
      image: image ?? this.image,
    );
  }

  @override
  List<Object?> get props => [description, image];
}
