import 'user.dart';

class Review {
  User user;
  String description;
  int review;
  DateTime createdAt;

  Review.fromJson(Map<String, dynamic> map)
      : user = User.fromJson(map['user']),
        description = map['description'] ?? "",
        createdAt = DateTime.fromMillisecondsSinceEpoch(map['date']??0),
        review = map['review'];
}
