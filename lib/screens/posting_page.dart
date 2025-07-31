import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../services/api_service.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../models/destination_model.dart';
import '../providers/user_provider.dart'; // Import UserProvider

class PostingPage extends StatefulWidget {
  const PostingPage({super.key});

  @override
  State<PostingPage> createState() => _PostingPageState();
}

class _PostingPageState extends State<PostingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _captionController = TextEditingController();

  XFile? _pickedImageXFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  List<DestinationModel> _destinations = [];
  DestinationModel? _selectedDestination;

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    try {
      // Mengambil data dari ApiService dan mengubahnya menjadi List<DestinationModel>
      final List<dynamic> data = await ApiService.fetchDestinations();
      if (!mounted) return;
      setState(() {
        _destinations = data.map((item) => DestinationModel.fromJson(item as Map<String, dynamic>)).toList();
      });
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(msg: 'Gagal memuat destinasi: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1000,
      );
      if (pickedFile != null) {
        setState(() {
          _pickedImageXFile = pickedFile;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal memilih gambar: $e');
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
             
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitAddForm() async {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(msg: 'Harap lengkapi semua field.');
      return;
    }
    if (_pickedImageXFile == null) {
      Fluttertoast.showToast(msg: 'Anda harus memilih gambar.');
      return;
    }

    // Ambil user ID dari Provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id;

    if (userId == null) {
      Fluttertoast.showToast(msg: 'Gagal mendapatkan ID pengguna. Silakan login ulang.');
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final caption = _captionController.text.trim();
      final locationId = _selectedDestination?.id.toString() ?? '';

      final response = await ApiService.addPost(
        caption: caption,
        locationId: locationId,
        imageXFile: _pickedImageXFile!,
        usersId: userId,
      );

      if (!mounted) return;

      if (response['statusCode'] == 201) {
        Fluttertoast.showToast(msg: 'Postingan berhasil ditambahkan');
        Navigator.pop(context, true); // Kirim 'true' untuk sinyal refresh
      } else {
        String errorMessage = response['message'] as String? ?? 'Gagal menambahkan postingan';
        Fluttertoast.showToast(msg: 'Error: $errorMessage (Status: ${response['statusCode']})');
      }
    } catch (e) {
      print('Error caught during _submitAddForm: $e');
      Fluttertoast.showToast(msg: 'Terjadi masalah saat mengirim data. ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final blueColor = const Color(0xFF4399CD);
    final lightBlueGradient = const LinearGradient(
      colors: [Color(0xFF5EA1D6), Color(0xFF2F7DBD)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Postingan Baru'),
        backgroundColor: blueColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tambah Postingan Baru',
                      style: TextStyle(
                        color: blueColor,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Caption
                    Text('Caption',
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _captionController,
                      decoration: _inputDecoration(
                          hintText: 'Masukkan Caption', icon: Icons.edit_outlined),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Caption tidak boleh kosong'
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // Dropdown Lokasi
                    Text('Lokasi',
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownSearch<DestinationModel>(
                      items: _destinations,
                      selectedItem: _selectedDestination,
                      itemAsString: (d) => "${d.name} - ${d.location}", // Tampilkan nama dan lokasi
                      onChanged: (value) {
                        setState(() {
                          _selectedDestination = value;
                        });
                      },
                      // validator tidak wajib karena lokasi opsional
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchDelay: const Duration(milliseconds: 100),
                        itemBuilder: (context, item, isSelected) => ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              // --- PERBAIKAN DI SINI ---
                              item.primaryImageUrl, // Gunakan getter primaryImageUrl
                              width: 50, height: 50, fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                            ),
                          ),
                          title: Text(item.name),
                          subtitle: Text(item.location),
                        ),
                        searchFieldProps: const TextFieldProps(decoration: InputDecoration(hintText: 'Cari destinasi...')),
                      ),
                      dropdownBuilder: (context, selectedItem) {
                         if (selectedItem == null) {
                           return const Text("Pilih lokasi jika ada", style: TextStyle(color: Colors.grey));
                         }
                         return Text(selectedItem.name, style: const TextStyle(fontSize: 14));
                      },
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: _inputDecoration(
                          hintText: 'Pilih Lokasi Wisata',
                          icon: Icons.location_on_outlined,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),

                    // Gambar
                    Text('Gambar Postingan',
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _pickedImageXFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(11.0),
                              child: kIsWeb
                                  ? Image.network(_pickedImageXFile!.path, fit: BoxFit.cover)
                                  : Image.file(File(_pickedImageXFile!.path), fit: BoxFit.cover),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined,
                                      size: 50, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text('Belum ada gambar dipilih',
                                      style: TextStyle(color: Colors.grey[600]))
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text('Pilih Gambar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blueColor.withOpacity(0.1),
                        foregroundColor: blueColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showImageSourceActionSheet(context),
                    ),
                    const SizedBox(height: 30),

                    // Tombol Submit
                    InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: _isLoading ? null : _submitAddForm,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: _isLoading ? null : lightBlueGradient,
                          color: _isLoading ? Colors.grey : null,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: _isLoading
                              ? []
                              : const [
                                  BoxShadow(
                                    color: Color(0x992F7DBD),
                                    offset: Offset(0, 4),
                                    blurRadius: 8,
                                  )
                                ],
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 3))
                              : const Text(
                                  'TAMBAH POSTINGAN',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String hintText, IconData? icon, bool isDense = true}) {
    final blueColor = const Color(0xFF4399CD);
    return InputDecoration(
      hintText: hintText,
      prefixIcon: icon != null ? Icon(icon, color: blueColor.withOpacity(0.7)) : null,
      filled: true,
      fillColor: Colors.grey[50],
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      contentPadding:
          EdgeInsets.symmetric(horizontal: 16, vertical: isDense ? 12 : 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: blueColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[700]!, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[700]!, width: 1.5),
      ),
    );
  }
}
