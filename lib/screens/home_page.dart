import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'search_page.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import '../models/destination_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import 'post_detail_page.dart';
import 'detail_page.dart';
import 'profile_page.dart';
import 'posting_page.dart';
import 'all_destinations_page.dart';
import '../services/api_service.dart';
import 'public_profile_page.dart';

// ... semua import tetap seperti milikmu ...

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final GlobalKey<_HomeFeedState> _homeFeedKey = GlobalKey<_HomeFeedState>();
  final GlobalKey<ProfilePageState> _profilePageKey = GlobalKey<ProfilePageState>();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      HomeFeed(key: _homeFeedKey),
      const ProfilePage(),
      ProfilePage(key: _profilePageKey),
    ];
  }

  void _onItemTapped(int index) {
    if (index < 2) {
      if (index == 1) {
        _profilePageKey.currentState?.refreshData();
      }
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _navigateToAddPost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PostingPage()),
    );
    if (result == true) {
      _homeFeedKey.currentState?.refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF3B9AC4),
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  _selectedIndex == 0 ? Icons.home_filled : Icons.home_outlined,
                  color: _selectedIndex == 0 ? Colors.white : Colors.white.withOpacity(0.7),
                ),
                onPressed: () => _onItemTapped(0),
                tooltip: 'Home',
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: Icon(
                  _selectedIndex == 1 ? Icons.person : Icons.person_outline,
                  color: _selectedIndex == 1 ? Colors.white : Colors.white.withOpacity(0.7),
                ),
                onPressed: () => _onItemTapped(1),
                tooltip: 'Profil',
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPost,
        tooltip: 'Tambah Postingan',
        backgroundColor: const Color(0xFF3B9AC4),
        elevation: 2.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Color.fromARGB(255, 255, 255, 255), size: 32.0,),
      ),
    );
  }
}

// ======================
// HOMEFEED (with fix profile & delete)
// ======================

class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});
  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  List<DestinationModel> _destinations = [];
  List<dynamic> _posts = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  Future<void> refreshData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final responses = await Future.wait([
        ApiService.fetchDestinations(),
        ApiService.getAllPosts(),
      ]);
      if (!mounted) return;
      final destinationsData = responses[0] as List<dynamic>;
      final postsData = responses[1] as List<dynamic>;

      final parsedDestinations = destinationsData
          .map((data) => DestinationModel.fromJson(data as Map<String, dynamic>))
          .take(10)
          .toList();

      setState(() {
        _destinations = parsedDestinations;
        _posts = postsData;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget buildCustomHeader(BuildContext context) {
    final baseUrl = "http://localhost:3000";
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final userName = user?.name.split(' ').first ?? 'Pengguna';
        String imageUrl = user?.imageUrl ?? '';
        if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
          imageUrl = '$baseUrl$imageUrl';
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: (imageUrl.isNotEmpty) ? NetworkImage(imageUrl) : null,
                backgroundColor: Colors.grey[200],
                child: (imageUrl.isEmpty)
                    ? const Icon(Icons.person, size: 32, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hallo, $userName",
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w800,
                        fontSize: 19,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 35,
                      child: TextField(
                        readOnly: true,
                        onTap: () {
                          Navigator.pushNamed(context, '/search');
                        },
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          suffixIcon: const Icon(Icons.search, color: Colors.grey, size: 24),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(fontSize: 17, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onSeeAll) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          if (onSeeAll != null) TextButton(onPressed: onSeeAll, child: const Text('Lihat Semua')),
        ],
      ),
    );
  }

  Widget _buildHorizontalDestinationList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _destinations.length,
        itemBuilder: (context, index) {
          final destination = _destinations[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(initialDestinationData: destination.toJson()),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 150,
                    width: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(destination.primaryImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(destination.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(destination.location,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    int postId = post['id'] ?? post.hashCode;
    int postUserId = post['userId'];
    bool isLiked = post['isLikedByCurrentUser'] == true || post['isLikedByCurrentUser'] == 1;
    int likeCount = post['likeCount'] ?? 0;
    int commentCount = post['commentCount'] ?? 0;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;

    // Perbaiki profile image
    String userProfileUrl = (post['userProfileImageUrl'] ?? '').toString();
    if (userProfileUrl.isNotEmpty && !userProfileUrl.startsWith('http')) {
      userProfileUrl = 'http://localhost:3000$userProfileUrl';
    }

    // Perbaiki gambar postingan
    String postImageUrl = (post['postImageUrl'] ?? '').toString();
    if (postImageUrl.isNotEmpty && !postImageUrl.startsWith('http')) {
      postImageUrl = 'http://localhost:3000$postImageUrl';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== Header: User, Lokasi, dan Hapus ==========
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Info user + lokasi
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      backgroundImage: userProfileUrl.isNotEmpty
                          ? NetworkImage(userProfileUrl)
                          : null,
                      child: userProfileUrl.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['userName'] ?? 'User',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if ((post['destinationName'] ?? '').isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.blueAccent),
                              const SizedBox(width: 3),
                              Text(
                                post['destinationName'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blueAccent,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
                // Tombol Hapus jika post milik user
                if (currentUser != null && postUserId == currentUser.id)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Hapus Postingan',
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Hapus Postingan?'),
                          content: const Text('Yakin ingin menghapus postingan ini?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        final success = await ApiService.deletePost(postId, currentUser.id);
                        if (success) {
                          Fluttertoast.showToast(msg: "Postingan dihapus!");
                          await refreshData();
                        } else {
                          Fluttertoast.showToast(msg: "Gagal menghapus postingan!");
                        }
                      }
                    },
                  ),
              ],
            ),
          ),

          // ========== Gambar Postingan ==========
          if (postImageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  postImageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  height: 250,
                  errorBuilder: (ctx, err, stack) =>
                    Container(height: 250, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                ),
              ),
            ),

          // ========== Konten ==========
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
            child: Text(post['content'] ?? ''),
          ),

          // ========== Like, Comment ==========
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () async {
                    if (currentUser == null) {
                      Fluttertoast.showToast(msg: "Login untuk Like!");
                      return;
                    }
                    await ApiService.toggleLike(postId, currentUser.id);
                    setState(() {
                      if (isLiked) {
                        post['likeCount'] = likeCount - 1;
                        post['isLikedByCurrentUser'] = false;
                      } else {
                        post['likeCount'] = likeCount + 1;
                        post['isLikedByCurrentUser'] = true;
                      }
                    });
                  },
                ),
                Text('$likeCount'),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: Colors.grey,
                  onPressed: () {
                    _showCommentSheet(postId, commentCount: commentCount);
                  },
                ),
                Text('$commentCount'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentSheet(int postId, {int commentCount = 0}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;

    List<Map<String, String>> comments = [];
    try {
      final List<CommentModel> backendComments = await ApiService.fetchComments(postId);
      comments = backendComments.map<Map<String, String>>((e) => {
        "name": e.userName,
        "image": e.userProfileImageUrl,
        "comment": e.commentText,
      }).toList();
    } catch (e) {
      comments = [];
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentBottomSheet(
        postId: postId,
        comments: comments,
        onAddComment: (text) async {
          if (currentUser == null) return;
          await ApiService.addComment(postId, currentUser.id, text);
          await refreshData();
        },
      ),
    );
  }

  Widget _buildVerticalPostList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostDetailPage(
                  post: post,
                  comments: post['comments'] ?? [],
                ),
              ),
            );
          },
          child: _buildPostCard(post),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                  ? Center(
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Gagal memuat data.\n$_errorMessage', textAlign: TextAlign.center)))
                  : RefreshIndicator(
                      onRefresh: refreshData,
                      child: ListView(
                        padding: const EdgeInsets.only(top: 0, bottom: 16),
                        children: [
                          buildCustomHeader(context),
                          _buildSectionHeader('Destinasi Populer', () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AllDestinationsPage()));
                          }),
                          _buildHorizontalDestinationList(),
                          _buildSectionHeader('Jelajahi Postingan', null),
                          _buildVerticalPostList(),
                        ],
                      ),
                    ),
        );
      },
    );
  }
}

// ======================
// COMMENT BOTTOM SHEET
// ======================

class CommentBottomSheet extends StatefulWidget {
  final int postId;
  final List<Map<String, String>> comments;
  final Function(String) onAddComment;

  const CommentBottomSheet({
    super.key,
    required this.postId,
    required this.comments,
    required this.onAddComment,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  late List<Map<String, String>> _comments;

  @override
  void initState() {
    super.initState();
    _comments = List<Map<String, String>>.from(widget.comments);
  }

  void _handleSend() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _comments.add({
          "name": "You",
          "image": "",
          "comment": text,
        });
      });
      await widget.onAddComment(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.96,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300], borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _comments.length,
                itemBuilder: (_, i) {
                  final c = _comments[i];
                  return ListTile(
                    leading: c["image"] != null && c["image"]!.isNotEmpty
                        ? CircleAvatar(backgroundImage: NetworkImage(c["image"]!))
                        : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(c["name"] ?? "-"),
                    subtitle: Text(c["comment"] ?? "-"),
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Reply",
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blueAccent),
                      onPressed: _handleSend,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
