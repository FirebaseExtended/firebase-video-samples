class GroceryItem {
  final String id;
  final String userId;
  final String name;
  final bool checked;

  const GroceryItem({
    this.id = '',
    this.userId = '',
    this.name = '',
    this.checked = false,
  });

  GroceryItem copyWith({
    String? id,
    String? userId,
    String? name,
    bool? checked,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      checked: checked ?? this.checked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'checked': checked,
    };
  }

  factory GroceryItem.fromMap(Map<String, dynamic> map, {String? docId}) {
    return GroceryItem(
      id: docId ?? (map['id'] as String? ?? ''),
      userId: map['userId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      checked: map['checked'] as bool? ?? false,
    );
  }
}
