class PostLike {
  final String user_id;
  final String post_id;
  final DateTime created_at;

  PostLike({
    required this.user_id,
    required this.post_id,
    required this.created_at,
  });
}
