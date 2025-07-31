import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'edit_profile_page.dart';
import 'post_detail_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  List<dynamic> _userPosts = [];
  List<dynamic> _userBookmarks = [];
  bool _isLoading = true;

  final Color blueColor = const Color(0xFF3B9AC4);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ini auto-refresh tiap masuk halaman
    refreshData();
  }

  Future<void> refreshData() async {
    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final userId = user?.id.toString();

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final postsFuture = ApiService.getUserPosts(userId);
      final bookmarksFuture = ApiService.getUserBookmarks(userId);

      final results = await Future.wait([postsFuture, bookmarksFuture]);
      if (!mounted) return;

      setState(() {
        _userPosts = (results[0] as List).map((post) {
          return {
            ...post,
            'userName': post['userName'] ?? user?.name ?? '',
            'userProfileImageUrl': post['userProfileImageUrl'] ?? user?.imageUrl ?? '',
            'destinationName': post['destinationName'] ?? post['destination'] ?? post['locationName'] ?? post['location'] ?? '',
            'likeCount': post['likeCount'] ?? post['likes'] ?? 0,
            'commentCount': post['commentCount'] ?? post['comments']?.length ?? 0,
          };
        }).toList();
        _userBookmarks = results[1];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat data profil: ${e.toString()}")),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // penting untuk AutomaticKeepAliveClientMixin!
    final userProvider = Provider.of<UserProvider>(context);
    final UserModel? user = userProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 260,
                floating: false,
                pinned: true,
                stretch: true,
                backgroundColor: blueColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        (user?.imageUrl?.isNotEmpty ?? false)
                            ? (user!.imageUrl!.startsWith('http')
                                ? user.imageUrl!
                                : "http://localhost:3000${user.imageUrl!}")
                            : 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.38),
                              Colors.black.withOpacity(0.16),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    color: Colors.white,
                    width: double.infinity,
                    child: _buildProfileHeader(context, user, blueColor),
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: blueColor,
                    unselectedLabelColor: Colors.black45,
                    indicatorColor: blueColor,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on), text: "Postingan"),
                      Tab(icon: Icon(Icons.bookmark_border), text: "Favorit"),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPostsGrid(blueColor),
                    _buildBookmarksList(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel? user, Color blueColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 12, left: 18, right: 18),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: blueColor, width: 3),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 14)],
                ),
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: (user?.imageUrl?.isNotEmpty ?? false)
                      ? NetworkImage(
                          user!.imageUrl!.startsWith('http')
                              ? user.imageUrl!
                              : "http://localhost:3000${user.imageUrl!}")
                      : null,
                  child: (user?.imageUrl?.isEmpty ?? true)
                      ? const Icon(Icons.person, size: 48, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user?.name ?? 'Profil Pengguna',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                user?.email ?? 'email.tidak.tersedia@mail.com',
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
              if ((user?.bio?.isNotEmpty ?? false))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    user!.bio!,
                    style: const TextStyle(color: Colors.black87, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatColumn("Postingan", _userPosts.length),
                  const SizedBox(width: 22),
                  _buildStatColumn("Favorit", _userBookmarks.length),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blueColor,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        minimumSize: const Size.fromHeight(45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.edit, size: 20),
                      label: const Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      onPressed: () async {
                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfilePage(user: userProvider.user!),
                          ),
                        );
                        if (updated == true) {
                          await refreshData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profil diperbarui!')),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: blueColor,
                      side: BorderSide(color: blueColor, width: 1.2),
                      elevation: 0,
                      minimumSize: const Size(45, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Apakah Anda yakin ingin keluar?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
                            TextButton(
                              onPressed: () {
                                Provider.of<UserProvider>(context, listen: false).logout();
                                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                              },
                              child: const Text('Logout', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Icon(Icons.logout, size: 22),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 3.5),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildPostsGrid(Color blueColor) {
    if (_userPosts.isEmpty) {
      return const Center(child: Text("Belum ada postingan."));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6.0,
        mainAxisSpacing: 6.0,
        childAspectRatio: 1,
      ),
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostDetailPage(post: post),
              ),
            );
          },
          child: Hero(
            tag: 'postImage${post['id'] ?? index}',
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(1, 2))],
              ),
              clipBehavior: Clip.hardEdge,
              child: post['postImageUrl'] != null && post['postImageUrl'] != ""
                  ? Image.network(post['postImageUrl'], fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 34, color: Colors.grey),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookmarksList() {
    if (_userBookmarks.isEmpty) {
      return const Center(child: Text("Belum ada destinasi favorit."));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      itemCount: _userBookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = _userBookmarks[index];
        return Card(
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                bookmark['imageUrl'] ?? '',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 48,
                  height: 48,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            title: Text(
              bookmark['name'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Text(
              bookmark['location'] ?? '',
              style: const TextStyle(fontSize: 13),
            ),
            onTap: () {
              // TODO: Navigasi ke detail destinasi favorit
            },
            trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black26),
          ),
        );
      },
    );
  }
}

// Delegate TabBar Sliver
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: _tabBar);
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
