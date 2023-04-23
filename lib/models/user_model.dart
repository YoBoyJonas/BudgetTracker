class UserModel {
  String nickName;
  String imageUrl;

  UserModel({
    required this.nickName,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'nickName': nickName,
        'imageUrl': imageUrl,
      };
}
