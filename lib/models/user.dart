class UserModel {
  final String email;
  final String uid;
  final bool active;

  UserModel({
    required this.email,
    required this.uid,
    this.active = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      uid: json['uid'],
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'uid': uid,
      'active': active,
    };
  }
}
