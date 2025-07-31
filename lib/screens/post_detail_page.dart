import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PostDetailPage extends StatefulWidget {
  final Map post;
  final List comments;

  const PostDetailPage({
    super.key,
    required this.post,
    this.comments = const [],
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late bool isLiked;
  late int likeCount;
  late int commentCount;
  List previewComments = [];

  @override
  void initState() {
    super.initState();
    isLiked = widget.post['isLikedByCurrentUser'] == true || widget.post['isLikedByCurrentUser'] == 1;
    likeCount = widget.post['likeCount'] ?? 0;
    commentCount = widget.post['commentCount'] ?? 0;
    fetchPreviewComments();
  }

  Future<void> fetchPreviewComments() async {
    final postId = widget.post['id'];
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/app_ulin/posts/$postId/comments?limit=2'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          previewComments = data['data'] ?? [];
        });
      }
    } catch (e) {
      setState(() {
        previewComments = [];
      });
    }
  }

  void _showCommentSheet() async {
    final postId = widget.post['id'];
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return CommentSheet(
          postId: postId,
          onCommentSent: fetchPreviewComments, // agar setelah kirim komen, preview update
        );
      },
    );
    // Setelah modal komentar ditutup, fetch preview terbaru
    await fetchPreviewComments();
  }

  void _toggleLike() async {
    setState(() {
      if (isLiked) {
        likeCount--;
        isLiked = false;
      } else {
        likeCount++;
        isLiked = true;
      }
    });
    // TODO: panggil ApiService.toggleLike() ke backend kalau mau
  }

  @override
  Widget build(BuildContext context) {
    final userImage = widget.post['userProfileImageUrl'];
    final userName = widget.post['userName'] ?? 'User';
    final destination = widget.post['destinationName'] ?? widget.post['locationName'] ?? widget.post['location'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Postingan')),
      body: ListView(
        children: [
          // HEADER (Avatar, Nama, Lokasi)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: (userImage != null && userImage.isNotEmpty)
                      ? NetworkImage(userImage)
                      : null,
                  radius: 25,
                  backgroundColor: Colors.grey[200],
                  child: (userImage == null || userImage.isEmpty)
                      ? const Icon(Icons.person, size: 26, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (destination.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.blueAccent),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                destination,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blueAccent,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // GAMBAR POST
          if ((widget.post['postImageUrl'] ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Image.network(
                widget.post['postImageUrl'],
                width: double.infinity,
                fit: BoxFit.cover,
                height: 250,
              ),
            ),
          // KONTEN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
            child: Text(widget.post['content'] ?? '', style: const TextStyle(fontSize: 15)),
          ),
          // LIKE & COMMENT (INTERAKTIF)
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                    size: 22,
                  ),
                  onPressed: _toggleLike,
                ),
                Text('$likeCount', style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 20),
                  onPressed: _showCommentSheet,
                ),
                const SizedBox(width: 2),
                Text('${previewComments.length}', style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          // KOMENTAR PREVIEW
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (previewComments.isNotEmpty)
                  ...previewComments.map<Widget>((c) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: (c["userProfileImageUrl"] != null && c["userProfileImageUrl"] != "")
                            ? CircleAvatar(
                                radius: 16,
                                backgroundImage: NetworkImage(c["userProfileImageUrl"]),
                              )
                            : (c["image"] != null && c["image"] != "")
                                ? CircleAvatar(
                                    radius: 16,
                                    backgroundImage: NetworkImage(c["image"]),
                                  )
                                : const CircleAvatar(
                                    radius: 16, child: Icon(Icons.person, size: 16)),
                        title: Text(
                          c["userName"] ?? c["name"] ?? c["user_id"]?.toString() ?? '-',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          c["comment_text"] ?? c["commentText"] ?? c["comment"] ?? '-',
                          style: const TextStyle(fontSize: 13),
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================
// BOTTOM SHEET KOMENTAR
// =====================
class CommentSheet extends StatefulWidget {
  final int postId;
  final Function() onCommentSent; // biar parent bisa refresh preview

  const CommentSheet({super.key, required this.postId, required this.onCommentSent});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _controller = TextEditingController();
  List comments = [];
  bool isLoading = true;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    setState(() { isLoading = true; });
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/app_ulin/posts/${widget.postId}/comments'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          comments = data['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          comments = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        comments = [];
        isLoading = false;
      });
    }
  }

  Future<void> sendComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() { isSending = true; });
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/posts/${widget.postId}/comments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'comment_text': text,
          // tambahkan user_id atau token jika perlu, tergantung backend kamu
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _controller.clear();
        await fetchComments(); // Refresh komentar
        widget.onCommentSent(); // Update preview di detail post
      }
    } catch (e) {
      // Handle error
    }
    setState(() { isSending = false; });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.4,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Container(
            width: 44,
            height: 5,
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300], borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : comments.isEmpty
                    ? const Center(child: Text('Belum ada komentar.'))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: comments.length,
                        itemBuilder: (_, i) {
                          final c = comments[i];
                          return ListTile(
                            leading: (c["userProfileImageUrl"] != null && c["userProfileImageUrl"] != "")
                                ? CircleAvatar(backgroundImage: NetworkImage(c["userProfileImageUrl"]))
                                : (c["image"] != null && c["image"] != "")
                                    ? CircleAvatar(backgroundImage: NetworkImage(c["image"]))
                                    : const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(
                              c["userName"] ?? c["name"] ?? c["user_id"]?.toString() ?? "-",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              c["comment_text"] ?? c["commentText"] ?? c["comment"] ?? "-",
                            ),
                          );
                        },
                      ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !isSending,
                      decoration: InputDecoration(
                        hintText: "Tulis komentar...",
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  isSending
                      ? const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(
                          icon: const Icon(Icons.send, color: Colors.blueAccent),
                          onPressed: sendComment,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
