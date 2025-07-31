import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart'; // untuk kIsWeb

class EditProfilePage extends StatefulWidget {
  final UserModel user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  XFile? _imageFile;
  bool _loading = false;

  final Color blueColor = const Color(0xFF3B9AC4);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() => _imageFile = picked);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _loading = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final updatedUser = await ApiService.updateUserProfile(
      userId: widget.user.id.toString(),
      name: _nameController.text,
      bio: _bioController.text,
      imageFile: _imageFile,
    );

    setState(() => _loading = false);

    if (updatedUser != null) {
      userProvider.setUser(updatedUser);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal update profil.')),
        );
      }
    }
  }

  Widget buildAvatar() {
    Widget avatarImg;
    if (_imageFile != null) {
      if (kIsWeb) {
        avatarImg = FutureBuilder<Uint8List>(
          future: _imageFile!.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return CircleAvatar(
                radius: 54,
                backgroundImage: MemoryImage(snapshot.data!),
              );
            }
            return const CircleAvatar(radius: 54, child: Icon(Icons.person, size: 50));
          },
        );
      } else {
        avatarImg = CircleAvatar(
          radius: 54,
          backgroundImage: FileImage(File(_imageFile!.path)),
        );
      }
    } else if (widget.user.imageUrl != null && widget.user.imageUrl!.isNotEmpty) {
      avatarImg = CircleAvatar(
        radius: 54,
        backgroundImage: NetworkImage(widget.user.imageUrl!),
      );
    } else {
      avatarImg = const CircleAvatar(
        radius: 54,
        backgroundColor: Color(0xFFf5f5f5),
        child: Icon(Icons.person, size: 54, color: Colors.grey),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Lingkaran luar (border biru + shadow)
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            border: Border.all(color: blueColor, width: 3.5),
          ),
          child: avatarImg,
        ),
        // Icon edit (pensil) di pojok kanan bawah
        Positioned(
          bottom: 6,
          right: 8,
          child: InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              decoration: BoxDecoration(
                color: blueColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white, width: 2),
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.edit, size: 20, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: blueColor,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(child: buildAvatar()),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: "Nama Lengkap",
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: blueColor, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.person_outline, color: blueColor),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _bioController,
                      decoration: InputDecoration(
                        labelText: "Bio (tentang kamu)",
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: blueColor, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.info_outline, color: blueColor),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blueColor,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.save_alt, size: 22),
                        label: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        onPressed: _saveProfile,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
