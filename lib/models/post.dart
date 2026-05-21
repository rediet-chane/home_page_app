class Post {
  final int userId;
  final int id;
  String title;
  String body;
  int likes;
  int comments;
  bool isLiked;

  Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}