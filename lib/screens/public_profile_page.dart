import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class PublicProfilePage extends StatefulWidget {
  final int userId;

  const PublicProfilePage({super.key, required this.userId});

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> with SingleTickerProviderStateMixin {
  UserModel? _user;
  List<dynamic> _userPosts = [];
  bool _isLoading = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() { _isLoading = true; });
    try {
      // Ambil detail user
      final user = await ApiService.getUserById(widget.userId);
      // Ambil postingan user
      final posts = await ApiService.getUserPosts(widget.userId.toString());

      setState(() {
        _user = user;
        _userPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat profil pengguna: $e")),
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
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Pengguna tidak ditemukan'))
              : DefaultTabController(
                  length: 1,
                  child: NestedScrollView(
                    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        SliverAppBar(
                          automaticallyImplyLeading: true,
                          expandedHeight: 220.0,
                          floating: false,
                          pinned: true,
                          stretch: true,
                          flexibleSpace: FlexibleSpaceBar(
                            centerTitle: true,
                            titlePadding: const EdgeInsets.only(bottom: 32),
                            title: Text(
                              _user?.name ?? 'Profil Pengguna',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                shadows: [Shadow(blurRadius: 2, color: Color.fromARGB(115, 127, 127, 127))]
                              ),
                            ),
                            background: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  _user?.imageUrl ?? 'https://via.placeholder.com/400x300?text=Profil',
                                  fit: BoxFit.cover,
                                  errorBuilder: (c,e,s) => Container(color: Colors.grey),
                                ),
                                const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment(0.0, 0.5),
                                      end: Alignment(0.0, 0.0),
                                      colors: <Color>[
                                        Color(0x60000000),
                                        Color(0x00000000),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _buildProfileHeader(context, _user),
                        ),
                        SliverPersistentHeader(
                          delegate: _SliverAppBarDelegate(
                            TabBar(
                              controller: _tabController,
                              labelColor: Theme.of(context).primaryColor,
                              unselectedLabelColor: const Color.fromARGB(255, 0, 0, 0),
                              indicatorColor: Theme.of(context).primaryColor,
                              tabs: const [
                                Tab(icon: Icon(Icons.grid_on), text: "Postingan"),
                              ],
                            ),
                          ),
                          pinned: true,
                        ),
                      ];
                    },
                    body: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPostsGrid(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.grey[300],
            backgroundImage: (user?.imageUrl?.isNotEmpty ?? false)
                ? NetworkImage(user!.imageUrl!)
                : null,
            child: (user?.imageUrl?.isEmpty ?? true)
                ? const Icon(Icons.person, size: 48, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 14),
          Text(
            user?.email ?? '',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatColumn("Postingan", _userPosts.length),
            ],
          ),
        ],
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
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildPostsGrid() {
    if (_userPosts.isEmpty) {
      return const Center(child: Text("Belum ada postingan."));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(4.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        return Image.network(post['postImageUrl'] ?? '', fit: BoxFit.cover);
      },
    );
  }
}

// Helper class (bisa di-share dengan profile_page.dart)
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white, // Latar belakang TabBar
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
