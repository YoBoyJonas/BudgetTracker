class UserModel {
  String nickName;

  UserModel({
    required this.nickName,
  });

  Map<String, dynamic> toJson() => {
        'nickName': nickName,
      };
}
