class AppUser {
  final String authId;

  const AppUser({this.authId = ''});

  Map<String, dynamic> toMap() {
    return {'authId': authId};
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(authId: map['authId'] as String? ?? '');
  }
}
