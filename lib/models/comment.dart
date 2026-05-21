class Comment {
  final int id;
  final int postId;
  final String name;
  final String email;
  String body;
  int likes;
  bool isLiked;

  Comment({
    required this.id,
    required this.postId,
    required this.name,
    required this.email,
    required this.body,
    this.likes = 0,
    this.isLiked = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['postId'],
      name: json['name'],
      email: json['email'],
      body: json['body'],
    );
  }
}