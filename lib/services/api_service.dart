import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../models/destination_model.dart';
import '../models/user_model.dart';
import '../models/comment_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/app_ulin'; // GANTI ke IP server Anda kalau deploy
  
  // ==============================
  // SIGNUP USER
  // ==============================
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );
      final Map<String, dynamic> responseData = json.decode(response.body);
      return {
        'statusCode': response.statusCode,
        'message': responseData['message'],
      };
    } catch (e) {
      return {'statusCode': 500, 'message': 'Terjadi kesalahan koneksi: ${e.toString()}'};
    }
  }

  // ==============================
  // LOGIN USER
  // ==============================
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      final Map<String, dynamic> responseData = json.decode(response.body);
      return {
        'statusCode': response.statusCode,
        'message': responseData['message'],
        'data': responseData['user'],
      };
    } catch (e) {
      return {'statusCode': 500, 'message': 'Terjadi kesalahan koneksi: ${e.toString()}'};
    }
  }

  // ==============================
  // FETCH DESTINATIONS
  // ==============================
  static Future<List<dynamic>> fetchDestinations() async {
    final url = Uri.parse('$baseUrl/destinations');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        if (jsonBody['success'] == true && jsonBody['data'] is List) {
          return jsonBody['data'] as List<dynamic>;
        } else {
          throw Exception('Format data dari server tidak sesuai.');
        }
      } else {
        throw Exception('Gagal memuat destinasi - Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal memuat destinasi: $e');
    }
  }

  // ==============================
  // FETCH ALL POSTS
  // ==============================
  static Future<List<dynamic>> getAllPosts() async {
    final url = Uri.parse('$baseUrl/posts');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        if (jsonBody['success'] == true && jsonBody['data'] is List) {
          return jsonBody['data'] as List<dynamic>;
        } else {
          throw Exception('Format data postingan dari server tidak sesuai.');
        }
      } else {
        throw Exception('Gagal memuat postingan (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Gagal memuat postingan: $e');
    }
  }

  // ==============================
  // ADD DESTINATION
  // ==============================
  static Future<Map<String, dynamic>> addDestination({
    required String name,
    required String location,
    required String time,
    required int price,
    required String imageUrl,
    required String description,
  }) async {
    final url = Uri.parse('$baseUrl/destinations');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'location': location,
          'time': time,
          'price': price,
          'imageUrl': imageUrl,
          'description': description,
        }),
      );
      return {
        'statusCode': response.statusCode,
        'data': jsonDecode(response.body),
      };
    } catch (e) {
      throw Exception('Gagal menambahkan destinasi: $e');
    }
  }

  // ==============================
  // POST USER (Add Post)
  // ==============================
  static Future<Map<String, dynamic>> addPost({
    required String caption,
    required String locationId,
    required int usersId,
    required XFile imageXFile,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/posts'),
    );
    request.fields['content'] = caption;
    request.fields['destinationId'] = locationId;
    request.fields['userId'] = usersId.toString();
    try {
      String fileName = imageXFile.name;
      MediaType? mediaType;
      List<int> fileBytes = await imageXFile.readAsBytes();

      if (kIsWeb) {
        String? webMimeType = imageXFile.mimeType ?? lookupMimeType(fileName, headerBytes: fileBytes);
        if (webMimeType != null) {
          final typeParts = webMimeType.split('/');
          if (typeParts.length == 2) mediaType = MediaType(typeParts[0], typeParts[1]);
        }
        request.files.add(http.MultipartFile.fromBytes(
          'postImage',
          fileBytes,
          filename: fileName,
          contentType: mediaType,
        ));
      } else {
        String? mobileMimeType = lookupMimeType(imageXFile.path, headerBytes: fileBytes.sublist(0, fileBytes.length > 256 ? 256 : fileBytes.length));
        if (mobileMimeType != null) {
          final typeParts = mobileMimeType.split('/');
          if (typeParts.length == 2) mediaType = MediaType(typeParts[0], typeParts[1]);
        }
        request.files.add(
          await http.MultipartFile.fromPath(
            'postImage',
            imageXFile.path,
            filename: fileName,
            contentType: mediaType,
          ),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      final decodedBody = json.decode(responseBody);
      return {
        'statusCode': response.statusCode,
        'data': decodedBody,
      };
    } catch (e) {
      throw Exception('Gagal menambahkan postingan: $e');
    }
  }

  // ==============================
  // SEARCH
  // ==============================
  static Future<List<dynamic>> search(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('$baseUrl/search?q=$encodedQuery');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        if (jsonBody['success'] == true && jsonBody['data'] is List) {
          return jsonBody['data'] as List<dynamic>;
        } else {
          throw Exception('Format data pencarian tidak sesuai.');
        }
      } else {
        throw Exception('Gagal melakukan pencarian (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Gagal melakukan pencarian: $e');
    }
  }

  // ==============================
  // FETCH SINGLE DESTINATION BY ID
  // ==============================
  static Future<Map<String, dynamic>> fetchDestinationById(String id) async {
    final url = Uri.parse('$baseUrl/destinations/$id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        if (jsonBody['success'] == true && jsonBody['data'] is Map<String, dynamic>) {
          return jsonBody['data'] as Map<String, dynamic>;
        } else {
          throw Exception('Format data detail destinasi tidak sesuai.');
        }
      } else {
        throw Exception('Gagal memuat detail destinasi (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Gagal memuat detail destinasi: $e');
    }
  }

  // ==============================
  // FETCH USER'S POSTS
  // ==============================
  static Future<List<dynamic>> getUserPosts(String userId) async {
    final url = Uri.parse('$baseUrl/users/$userId/posts');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        if (jsonBody['success'] == true && jsonBody['data'] is List) {
          return jsonBody['data'] as List<dynamic>;
        } else {
          throw Exception('Format data postingan pengguna tidak sesuai.');
        }
      } else {
        throw Exception('Gagal memuat postingan pengguna (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Gagal memuat postingan pengguna: $e');
    }
  }

  // ==============================
  // FETCH USER'S BOOKMARKS
  // ==============================
  static Future<List<dynamic>> getUserBookmarks(String userId) async {
    final url = Uri.parse('$baseUrl/users/$userId/bookmarks');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        if (jsonBody['success'] == true && jsonBody['data'] is List) {
          return jsonBody['data'] as List<dynamic>;
        } else {
          throw Exception('Format data bookmark tidak sesuai.');
        }
      } else {
        throw Exception('Gagal memuat bookmark (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Gagal memuat bookmark: $e');
    }
  }

  // ==============================
  // TOGGLE BOOKMARK DESTINATION
  // ==============================
  static Future<bool> checkBookmarkStatus({required String destinationId, required String userId}) async {
    final url = Uri.parse('$baseUrl/destinations/$destinationId/bookmark-status?userId=$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body)['bookmarked'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> toggleBookmark({required String destinationId, required String userId}) async {
    final url = Uri.parse('$baseUrl/destinations/$destinationId/bookmark');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Gagal mengubah status bookmark: ${response.body}');
      }
    } catch (e) {
      throw Exception('Gagal mengubah status bookmark: $e');
    }
  }

  // ==============================
  // TOGGLE LIKE ON A POST
  // ==============================
  static Future<void> toggleLike(int postId, int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/like'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Gagal melakukan like/unlike");
    }
  }

  // ==============================
  // COMMENTS - GET ALL COMMENTS FOR POST
  // ==============================
  static Future<List<CommentModel>> fetchComments(int postId) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/$postId/comments'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((e) => CommentModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat komentar');
    }
  }

  // ==============================
  // COMMENTS - ADD COMMENT TO POST
  // ==============================
  static Future<bool> addComment(int postId, int userId, String content) async {
  final response = await http.post(
    Uri.parse('$baseUrl/posts/$postId/comments'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'userId': userId, 'content': content}), // field 'content' -> backend
  );
  return response.statusCode == 201 || response.statusCode == 200;
}


  // ==============================
  // GET USER BY ID (for public profile)
  // ==============================
  static Future<UserModel> getUserById(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return UserModel.fromJson(data);
    } else {
      throw Exception('User tidak ditemukan');
    }

    
  }
// ==============================
  // UPDATE USER PROFILE
  // ==============================
 // Di ApiService.dart

static Future<UserModel?> updateUserProfile({
  required String userId,
  required String name,
  required String bio,
  XFile? imageFile,
}) async {
  var uri = Uri.parse('$baseUrl/users/$userId');
  var request = http.MultipartRequest('PUT', uri);
  request.fields['name'] = name;
  request.fields['bio'] = bio;
  if (imageFile != null) {
    if (kIsWeb) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'imageUrl', // field sesuai backend
          bytes,
          filename: imageFile.name,
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath('imageUrl', imageFile.path),
      );
    }
  }

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

 if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  // Kembalikan objek UserModel dari field 'user'
  
  return UserModel.fromJson(data['user'] ?? {});
}
return null;
}
static Future<bool> deletePost(int postId, int userId) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/posts/$postId?userId=$userId'),
    headers: {'Content-Type': 'application/json'},
  );
  // Success kalau response 200 dan success:true
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }
  return false;
}


}






