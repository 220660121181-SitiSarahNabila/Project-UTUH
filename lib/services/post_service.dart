import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> toggleLike(int postId, int userId) async {
  final response = await http.post(
    Uri.parse('http://<IP-API-ANDA>:<PORT>/posts/$postId/like'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'userId': userId}),
  );
  // Handle response jika perlu
  
}
