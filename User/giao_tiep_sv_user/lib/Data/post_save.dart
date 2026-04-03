class PostSave {
  final String post_id;
  final String user_id;
  final DateTime created_at;

  PostSave({
    required this.post_id,
    required this.user_id,
    required this.created_at,
  });
}
