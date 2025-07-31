import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header dengan background biru dan rounded bottom
          Container(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 24),
            decoration: const BoxDecoration(
              color: Color(0xFF42A5F5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'GENERAL',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                _buildSettingItem(
                  icon: Icons.person,
                  title: 'Account',
                  onTap: () {},
                ),
                _buildSettingItem(
                  icon: Icons.logout,
                  title: 'LOGOUT',
                  onTap: () {},
                ),
                _buildSettingItem(
                  icon: Icons.delete_forever,
                  title: 'Delete Account',
                  onTap: () {},
                ),
                _buildSettingItem(
                  icon: Icons.bug_report,
                  title: 'Report Bug',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[800]),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
