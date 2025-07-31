import 'package:flutter/material.dart';
import 'settings_page.dart'; // pastikan file ini di-import dengan benar
import 'posting_page.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header dengan Settings di kanan atas
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF42A5F5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Stack(
              children: [
                // Tombol setting di pojok kanan atas
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      );
                    },
                  ),
                ),

                // Isi Profil
                Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/profile_cat.png'),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'CARMENTZZ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Indonesia',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context); // Kembali ke Profile
                          },
                          icon: const Icon(Icons.camera_alt_outlined),
                          color: Colors.white,
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () {}, // Sudah di halaman bookmark
                          icon: const Icon(Icons.bookmark_border),
                          color: Colors.yellowAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Grid Bookmarked Gambar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: 6,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.pink[100],
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/bookmark${(index % 3) + 1}.jpg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar & FAB
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.blue,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home),
                color: Colors.white,
                onPressed: () {
                  Navigator.pop(context); // balik ke home
                },
              ),
              const SizedBox(width: 48),
              IconButton(
                icon: const Icon(Icons.person),
                color: Colors.white,
                onPressed: () {
                  Navigator.pop(context); // balik ke profile
                },
              ),
            ],
          ),
        ),
      ),
       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Material(
        color: Colors.transparent,
        elevation: 10,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
           onTap: () {
           Navigator.push(
           context,
           MaterialPageRoute(builder: (context) => PostingPage()),
           );
            },
            
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}
