class Review {
  final String userId;
  final String recipeId;
  final int rating;

  const Review({
    this.userId = '',
    this.recipeId = '',
    this.rating = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'recipeId': recipeId,
      'rating': rating,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      userId: map['userId'] as String? ?? '',
      recipeId: map['recipeId'] as String? ?? '',
      rating: (map['rating'] as num?)?.toInt() ?? 0,
    );
  }
}
