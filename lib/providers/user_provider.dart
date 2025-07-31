import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? user;

  // Simpan user setelah login
  Future<void> setUser(UserModel newUser) async {
  user = newUser;
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('userId', newUser.id.toString());
  prefs.setString('userName', newUser.name);
  prefs.setString('userEmail', newUser.email ?? '');
  prefs.setString('userImageUrl', newUser.imageUrl ?? '');
  prefs.setString('userBio', newUser.bio ?? '');
  notifyListeners();
}

  // TAMBAHAN: Method untuk update user setelah edit profil
  Future<void> updateUser(UserModel updatedUser) async {
    user = updatedUser;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', updatedUser.id.toString());
    prefs.setString('userName', updatedUser.name);
    prefs.setString('userEmail', updatedUser.email ?? '');
    prefs.setString('userImageUrl', updatedUser.imageUrl ?? '');
    prefs.setString('userBio', updatedUser.bio ?? '');
    notifyListeners(); // Penting! Ini yang membuat widget rebuild
  }

 


  // Ambil user dari lokal storage saat app dijalankan
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userId')) {
      user = UserModel(
        id: int.tryParse(prefs.getString('userId') ?? '') ?? 0,
        name: prefs.getString('userName') ?? '',
        email: prefs.getString('userEmail') ?? '', 
        imageUrl: prefs.getString('userImageUrl') ?? '',
        bio: prefs.getString('userBio') ?? '',
      );
      notifyListeners();
    }
  }

  // Logout, bersihkan storage
  Future<void> logout() async {
    user = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userId');
    prefs.remove('userName');
    prefs.remove('userEmail');             
    prefs.remove('userImageUrl');
    prefs.remove('userBio');
    notifyListeners();
  }
}
