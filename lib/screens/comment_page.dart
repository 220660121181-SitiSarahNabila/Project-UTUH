import 'package:flutter/material.dart';

class CommentPage extends StatefulWidget {
  final List<Map<String, String>> initialComments;

  const CommentPage({super.key, this.initialComments = const []});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _comments = [];

void _addComment() {
  final text = _controller.text.trim();
  if (text.isNotEmpty) {
    setState(() {
      _comments.add({
        "image": "assets/images/toni.jpeg", // Ganti sesuai user login
        "name": "You", // Ganti nama user jika ada
        "comment": text,
      });
      _controller.clear();
    });
  }
}

 // Di dalam _CommentPageState (Stateful)
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black.withOpacity(0.4),
    body: Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tambahkan tombol close
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    Navigator.of(context).pop(_comments);
                  },
                ),
              ),
              ..._comments.map((c) => _buildCommentItem(
                image: c["image"]!,
                name: c["name"]!,
                comment: c["comment"]!,
              )),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Reply',
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (value) => _addComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


  Widget _buildCommentItem({
    required String image,
    required String name,
    required String comment,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundImage: AssetImage(image)),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(comment),
    );
  }
}
