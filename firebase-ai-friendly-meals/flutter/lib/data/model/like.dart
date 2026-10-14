class Like {
  final String recipeId;
  final String userId;

  const Like({
    this.recipeId = '',
    this.userId = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'userId': userId,
    };
  }

  factory Like.fromMap(Map<String, dynamic> map) {
    return Like(
      recipeId: map['recipeId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
    );
  }
}
